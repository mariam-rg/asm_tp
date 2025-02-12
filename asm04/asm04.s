section .data

section .bss
    input resb 64

section .text
    global _start

_start:
    ; Read input
    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    mov rsi, input
    mov rdx, 64
    syscall

    ; Initialize conversion
    mov r8, input
    xor rax, rax        ; Clear result
    xor rcx, rcx        ; Clear counter

_conv_loop:
    movzx rdx, byte [r8 + rcx]   ; Load character

    ; Check for end of input
    cmp dl, 10          ; newline
    je _check_number
    cmp dl, 0           ; null terminator
    je _check_number

    ; Validate digit
    cmp dl, '0'
    jl _error
    cmp dl, '9'
    jg _error

    ; Convert and accumulate
    sub dl, '0'         ; Convert to number
    mov rbx, rax        ; Save current number
    imul rax, 10        ; Multiply by 10
    add rax, rdx        ; Add new digit

    inc rcx
    jmp _conv_loop

_check_number:
    ; If no digits were processed, error
    test rcx, rcx
    jz _error

    ; Check if even/odd
    test rax, 1         ; Test least significant bit
    jz _even           ; If zero, number is even
    jmp _odd           ; Otherwise, odd

_even:
    mov rax, 60         ; sys_exit
    xor rdi, rdi        ; return 0
    syscall

_odd:
    mov rax, 60         ; sys_exit
    mov rdi, 1          ; return 1
    syscall

_error:
    mov rax, 60         ; sys_exit
    mov rdi, 2          ; return 2 for invalid input
    syscall