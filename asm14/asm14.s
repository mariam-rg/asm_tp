    section .bss




_write:
    mov rax,1
    mov rdi,





_open:
    mov rax,2
    mov rdi,rsi
    mov rsi,0x241
    mov rdx,0644
    syscall

_exit:
    mov rax,60
    mov rdi,0
    syscall