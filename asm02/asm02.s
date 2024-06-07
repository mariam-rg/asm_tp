section .data
    msg db '1337', 10

global _start

section .bss
    input resb 1

section .text

_start:

    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, 5
    syscall

    mov rax, 0
    mov rdi, 0
    mov rsi, input
    mov rdx, 255
    syscall

    cmp byte [input], '4'
    jne not_equal

    cmp byte [input+1], '2'
    jne not_equal

    cmp byte [input+2], 10
    jne not_equal

    jmp equal

not_equal:
    mov rax, 60
    mov rdi, 1
    syscall

equal:
    mov rax, 60
    mov rdi, 0
    syscall
