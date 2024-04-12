section .data
    input db 0
    output db 0

section .text
    global _start

_start:
    ; Affiche le message pour demander à l'utilisateur d'entrer un nombre
    mov rax, 0          
    mov rdi, 1          
    mov rsi, message    
    mov rdx, message_len 
    syscall

    ; Lit l'entrée utilisateur
    mov rax, 0          
    mov rdi, 0          
    mov rsi, input      
    mov rdx, 1          
    syscall

    ; Convertit le caractère en nombre
    sub byte [input], '0'

    ; Vérifie si le nombre est pair ou impair
    test byte [input], 1 
    jnz .odd             
    mov byte [output], '0' 
    jmp .end_prog
.odd:
    mov byte [output], '1' 
.end_prog:

    
    mov rax, 0          
    mov rdi, 1          
    mov rsi, output     
    mov rdx, 1          
    syscall

    
    mov rax, 60         
    xor rdi, rdi        
    syscall

section .bss
    message resb 30     
    message_len equ $ - message
