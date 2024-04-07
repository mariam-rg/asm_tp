section .data
    msg db '1337', 10
    msg_true db 'O', 10
    msg_false db '1', 10

section .text
    global _start

_start:
    
    cmp qword [rsp + 8], 2
    jne error

    
    mov rdi, [rsp + 16]
    
    
    cmp rdi, 42
    jne not_equal

    
    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, 4
    syscall

    
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_true
    mov rdx, 2
    syscall
    jmp end

not_equal:
    
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_false
    mov rdx, 2
    syscall

end:
    
    mov rax, 60         
    xor rdi, rdi        
    syscall

error:
    
    mov rax, 1
    mov rdi, 1
    mov rsi, error_msg
    mov rdx, error_len
    syscall

    
    mov rax, 60         
    mov rdi, 1          
    syscall

