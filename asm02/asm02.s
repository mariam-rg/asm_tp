section .data
    msg db '1337', 10

global _start

section .bss
    input resb 1

section .text

_start:
    ; Affiche '1337'
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
    cmp byte [input+1], '2'
    je equal
    jne not_equal

not_equal:
    mov rax, 60
    mov rdi, 1
    syscall

equal:
    mov rax, 60
    mov rdi, 0
    syscall
