section .data
    fmt_input   db "%d", 0           ; Format string for fscanf
    fmt_output  db "Sum: %d", 10, 0   ; Format string for printf
    error_msg   db "Error opening file", 10, 0
    array       times 1000 dd 0       ; Array to store integers
    mode        db "r", 0             ; Read mode for fopen

section .bss
    file_ptr    resd 1                ; File pointer
    count       resd 1                ; Number of integers
    sum         resd 1                ; Store sum

section .text
    global main
    extern fopen, fscanf, printf, fclose

main:
    ; Extract command-line argument (filename)
    mov eax, [esp+8]   ; Get pointer to argv[1]
    test eax, eax      ; Check if filename was provided
    jz error           ; If NULL, print error and exit

    ; Open the file
    push mode          ; Push file mode "r"
    push eax           ; Push filename
    call fopen
    add esp, 8         ; Clean up stack
    cmp eax, 0
    je error           ; If fopen fails, print error and exit
    mov [file_ptr], eax ; Save file pointer

    ; Read the first line to get the number of integers
    push dword [file_ptr]
    push count
    push fmt_input
    call fscanf
    add esp, 12

    ; Initialize sum and index
    xor ebx, ebx        ; sum = 0
    xor edi, edi        ; index = 0

read_loop:
    cmp edi, [count]    ; Check if all numbers read
    jge done_reading
    push dword [file_ptr]
    lea eax, [array + edi * 4]  ; Get address of array[index]
    push eax
    push fmt_input
    call fscanf
    add esp, 12
    add ebx, [array + edi * 4]
    inc edi
    jmp read_loop

done_reading:
    mov [sum], ebx      ; Store sum

    ; Print sum
    push ebx
    push fmt_output
    call printf
    add esp, 8

    ; Close the file
    push dword [file_ptr]
    call fclose
    add esp, 4

    ; Exit
    mov eax, 1          ; syscall for exit
    xor ebx, ebx
    int 0x80

error:
    push error_msg
    call printf
    add esp, 4
    mov eax, 1
    mov ebx, -1
    int 0x80
