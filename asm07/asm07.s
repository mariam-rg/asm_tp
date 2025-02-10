section .data
    buffer db 20 dup(0)

section .text
    global _start

_start:
    ; Read input
    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    mov rsi, buffer     ; buffer
    mov rdx, 20         ; size
    syscall

    ; Convert string to number
    xor rax, rax        ; Clear rax
    mov rcx, buffer     ; Point to buffer
    xor r9, r9          ; Clear sign flag

    ; Check for negative sign
    movzx rdx, byte [rcx]
    cmp dl, '-'
    jne _convert
    mov r9, 1          ; Set negative flag
    inc rcx            ; Move past the minus sign

_convert:
    movzx rdx, byte [rcx]
    cmp dl, 10          ; Check for newline
    je _process_number
    cmp dl, '0'
    jl _error
    cmp dl, '9'
    jg _error
    
    sub dl, '0'         ; Convert to number
    imul rax, 10        ; Multiply by 10
    add rax, rdx        ; Add digit
    inc rcx
    jmp _convert

_process_number:
    ; If number was negative, make it positive
    test r9, r9
    jz _check_prime
    neg rax

_check_prime:
    ; For negative numbers or 1, not prime
    cmp rax, 1
    jle _not_prime

    mov rcx, 2          ; Start checking from 2
_loop:
    mov rdx, 0
    push rax
    div rcx
    pop rax
    cmp rdx, 0          ; Check remainder
    je _check_if_same
    
    inc rcx
    push rax
    mov rdx, 0
    mov rax, rcx
    mul rcx             ; rcx * rcx
    cmp rax, qword [rsp]
    pop rax
    jle _loop
    jmp _is_prime

_check_if_same:
    cmp rcx, rax        ; If n/2 == n, it's prime
    je _is_prime
    jmp _not_prime

_is_prime:
    mov rdi, 0          ; Return 0
    jmp _exit

_not_prime:
    mov rdi, 1          ; Return 1
    jmp _exit

_error:
    mov rdi, 2          ; Return 2 for invalid input

_exit:
    mov rax, 60         ; sys_exit
    syscall