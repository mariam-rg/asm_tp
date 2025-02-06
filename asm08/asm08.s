section .data
    newline db 10

section .bss
    buffer resb 32    ; Buffer for output string

section .text
global _start

_start:
    ; Check if we have exactly one argument
    pop rax         ; Get argc
    cmp rax, 2      ; We need exactly 2 arguments (program name + number)
    jne error

    ; Get the argument
    pop rax         ; Skip program name
    pop rdi         ; Get number argument
    call atoi       ; Convert string to integer

    ; Calculate sum of numbers from 1 to n-1
    dec rax         ; Subtract 1 to get upper limit
    call calculate_sum

    ; Convert result to string and print
    mov rdi, buffer
    call itoa

    ; Print the result
    mov rax, 1      ; sys_write
    mov rdi, 1      ; stdout
    mov rsi, buffer
    mov rdx, rbx    ; Length of string (set by itoa)
    syscall

    ; Print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    jmp exit_success

; Function to calculate sum: (n * (n + 1)) / 2
calculate_sum:
    mov rbx, rax    ; Save n
    inc rax         ; n + 1
    mul rbx         ; n * (n + 1)
    shr rax, 1      ; Divide by 2
    ret

; Function to convert string to integer (atoi)
atoi:
    xor rax, rax    ; Clear result
atoi_loop:
    movzx rcx, byte [rdi] ; Get next character
    test rcx, rcx   ; Check for null terminator
    jz atoi_done
    sub rcx, '0'    ; Convert ASCII to number
    jb error        ; Jump if below 0
    cmp rcx, 9
    ja error        ; Jump if above 9
    imul rax, 10    ; Multiply current value by 10
    add rax, rcx    ; Add new digit
    inc rdi         ; Move to next character
    jmp atoi_loop
atoi_done:
    ret

; Function to convert integer to string (itoa)
itoa:
    mov rax, rbx    ; Number to convert
    mov rcx, 0      ; Character counter
    mov rbx, 10     ; Divisor

itoa_loop:
    xor rdx, rdx    ; Clear rdx for division
    div rbx         ; Divide by 10
    add dl, '0'     ; Convert remainder to ASCII
    dec rdi         ; Move buffer pointer back
    mov [rdi], dl   ; Store digit
    inc rcx         ; Increment counter
    test rax, rax   ; Check if we're done
    jnz itoa_loop

    ; Move string to beginning of buffer
    mov rax, buffer
    mov rbx, rcx    ; Save length for printing
    mov rsi, rdi    ; Source: current position
    mov rdi, rax    ; Destination: start of buffer
    rep movsb       ; Move string

    ret

exit_success:
    mov rax, 60     ; sys_exit
    xor rdi, rdi    ; return 0
    syscall

error:
    mov rax, 60     ; sys_exit
    mov rdi, 1      ; return 1
    syscall