section .data
    msg db '1337', 10
    message_len equ $ - message

section .bss
    input_buffer resb 16


global _start

section .text

_start:

    mov rdi, 0          
    mov rax, 0          
    mov rsi, input_buffer 
    mov rdx, 16         
    syscall           
    

    mov rax, 1          
    mov rdi, 1          
    mov rsi, msg        
    mov rdx, 5          
    syscall

   
    mov rax, 1         
    mov rdi, 1          
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

