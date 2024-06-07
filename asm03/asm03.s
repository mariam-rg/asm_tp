section .data
    msg db '1337', 10

global _start

section .text
_start:
    pop rax ; Number of arguments

    cmp rax, 2
    jne _error

    pop rax
    pop rax

    cmp byte [rax], '4'
    jne _error

    cmp byte [rax+1], '2'
    jne _error

    cmp byte [rax+2], 0
    jne _error

_affiche:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, 5
    syscall

_success:
    mov rax, 60
    mov rdi, 0
    syscall

_error:
    mov rax, 60
    mov rdi, 1
    syscall