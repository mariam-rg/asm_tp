section .data
    msg db '1337', 10
    msg_true db '0', 10
    msg_false db '1', 10

section .bss
    input resb 1

section .text
    global _start

_start:
    mov rax, 0          
    mov rdi, 0           
    mov rsi, msg      
    mov rdx, 1          
    syscall

    
    sub byte [input], '0' 

    
    cmp byte [input], 42
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