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
    xor rax, rax        ; Clear accumulator
    mov rcx, buffer     ; Point to buffer

_convert:
    movzx rdx, byte [rcx]   ; Get current character
    cmp dl, 10              ; Check for newline
    je _check_even
    cmp dl, '0'            ; Check if less than '0'
    jl _error
    cmp dl, '9'            ; Check if greater than '9'
    jg _error
    
    sub dl, '0'            ; Convert ASCII to number
    imul rax, 10           ; Multiply current number by 10
    add rax, rdx           ; Add new digit
    inc rcx                ; Move to next character
    jmp _convert

_check_even:
    test rax, 1            ; Test least significant bit
    jz _even               ; If bit is 0, number is even
    jmp _odd               ; If bit is 1, number is odd

_even:
    xor rdi, rdi           ; Exit code 0
    jmp _exit

_odd:
    mov rdi, 1             ; Exit code 1
    jmp _exit

_error:
    mov rdi, 1             ; Exit with error code 1

_exit:
    mov rax, 60            ; sys_exit
    syscall