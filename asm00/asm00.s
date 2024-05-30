section .data
    msg db '0', 0

section .text
    global _start

_start:
    mov rax, 0x3C
    mov rdi, 0
    syscall