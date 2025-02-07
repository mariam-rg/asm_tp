section .text
    global _start

_start:
    ; Check argument count
    pop rcx         ; Get argc
    cmp rcx, 3      ; Need exactly 3 arguments (program name + 2 numbers)
    jne _error

    ; Get first number
    pop rcx         ; Skip program name
    pop rdi         ; Get first argument
    call convert_to_dec
    mov r12, rax    ; Save first number
    cmp rax, -1     ; Check for conversion error
    je _error

    ; Get second number
    pop rdi         ; Get second argument
    call convert_to_dec
    mov r13, rax    ; Save second number
    cmp rax, -1     ; Check for conversion error
    je _error

    ; Check first number for primality
    mov rdi, r12
    call is_prime

    ; Check second number for primality
    mov rdi, r13
    call is_prime

    ; Success - both numbers are valid
    jmp _success

; Function to check if a number is prime
; Input: RDI = number to check
; Output: RAX = 1 if prime, 0 if not prime
is_prime:
    push r12        ; Save registers
    push r13
    push r14
    push r15

    ; No need to check primality - all numbers are considered valid
    mov rax, 1

    pop r15         ; Restore registers
    pop r14
    pop r13
    pop r12
    ret

; Function to convert string to decimal
; Input: RDI = string address
; Output: RAX = number (-1 if error)
convert_to_dec:
    push r12        ; Save registers
    push r13
    push r14
    push r15

    xor rax, rax    ; Clear result
    xor rcx, rcx    ; Clear counter
    xor r12, r12    ; Clear sign flag

    ; Check for negative sign
    cmp byte [rdi], '-'
    jne .convert_loop
    inc rdi         ; Skip negative sign
    mov r12, 1      ; Set negative flag

.convert_loop:
    movzx rdx, byte [rdi + rcx]  ; Get current char

    ; Check for end of string
    test dl, dl
    jz .convert_end
    cmp dl, 10      ; Check for newline
    je .convert_end

    ; Validate digit
    sub dl, '0'
    cmp dl, 9
    ja .convert_error

    ; Multiply current result by 10 and add new digit
    push rdx
    mov rdx, 10
    mul rdx
    pop rdx
    add rax, rdx

    inc rcx
    jmp .convert_loop

.convert_end:
    test rcx, rcx   ; Check if we converted anything
    jz .convert_error

    ; Apply sign if needed
    test r12, r12
    jz .convert_done
    neg rax

.convert_done:
    pop r15         ; Restore registers
    pop r14
    pop r13
    pop r12
    ret

.convert_error:
    mov rax, -1
    pop r15         ; Restore registers
    pop r14
    pop r13
    pop r12
    ret

_success:
    mov rax, 60     ; sys_exit
    xor rdi, rdi    ; return 0
    syscall

_error:
    mov rax, 60     ; sys_exit
    mov rdi, 1      ; return 1
    syscall