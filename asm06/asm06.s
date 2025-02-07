section .text
    global _start

_start:
    ; Check argument count
    pop rcx         ; Get argc
    cmp rcx, 3      ; Need exactly 3 arguments (program name + 2 numbers)
    jne _error

    ; Skip program name
    pop rcx

    ; Get first number
    pop rdi
    call convert_to_dec
    cmp rax, -1     ; Check for conversion error
    je _error
    push rax        ; Save first number

    ; Get second number
    pop rdi
    call convert_to_dec
    cmp rax, -1     ; Check for conversion error
    je _error

    ; Check both numbers for primality
    mov rbx, rax    ; Save second number
    pop rax         ; Restore first number

    ; Check first number
    push rbx        ; Save second number
    mov rdi, rax
    call is_prime
    cmp rax, 0
    je _error

    ; Check second number
    pop rdi         ; Restore second number
    call is_prime
    cmp rax, 0
    je _error

    jmp _success

; Function to check if a number is prime
; Input: RDI = number to check
; Output: RAX = 1 if prime, 0 if not prime
is_prime:
    ; Handle special cases
    cmp rdi, 2
    jl zero_result  ; Numbers < 2 are not prime

    cmp rdi, 2
    je prime_result ; 2 is prime

    ; Check if even (except 2)
    test rdi, 1
    jz zero_result

    ; Check odd divisors from 3 to sqrt(n)
    mov rcx, 3      ; Start with 3
    mov rax, rdi    ; Get number to test

check_prime_loop:
    mov rax, rdi
    xor rdx, rdx
    div rcx         ; Divide by current divisor

    test rdx, rdx   ; Check remainder
    jz zero_result  ; If divisible, not prime

    add rcx, 2      ; Next odd number
    mov rax, rcx
    mul rax         ; Square current divisor
    cmp rax, rdi    ; Compare with original number
    jbe check_prime_loop

prime_result:
    mov rax, 1
    ret

zero_result:
    xor rax, rax
    ret

; Function to convert string to decimal
; Input: RDI = string address
; Output: RAX = number (-1 if error)
convert_to_dec:
    xor rax, rax        ; Clear result
    xor rcx, rcx        ; Clear counter

    ; Check for negative sign
    cmp byte [rdi], '-'
    jne convert_loop
    inc rdi             ; Skip negative sign

convert_loop:
    movzx rdx, byte [rdi + rcx]  ; Get current char

    ; Check for end of string
    test dl, dl
    jz convert_end
    cmp dl, 10          ; Check for newline
    je convert_end

    ; Validate digit
    sub dl, '0'
    cmp dl, 9
    ja convert_error

    ; Multiply current result by 10 and add new digit
    push rdx
    mov rdx, 10
    mul rdx
    pop rdx
    jo convert_error    ; Check for overflow
    add rax, rdx
    jo convert_error    ; Check for overflow

    inc rcx
    jmp convert_loop

convert_end:
    test rcx, rcx       ; Check if we converted anything
    jz convert_error
    ret

convert_error:
    mov rax, -1
    ret

_success:
    mov rax, 60     ; sys_exit
    xor rdi, rdi    ; return 0
    syscall

_error:
    mov rax, 60     ; sys_exit
    mov rdi, 1      ; return 1
    syscall