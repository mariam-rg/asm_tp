section .data
    is_prime db 1       
    newline db 0xA      
    buffer db 32        
    prime_msg db "Le nombre est premier", 0xA
    not_prime_msg db "Le nombre n'est pas premier", 0xA

section .text
    global _start

_start:
    ; Lecture du nombre depuis l'entrée standard
    mov rdi, 0          
    mov rsi, buffer     
    mov rdx, 32         
    call read_number    

    ; Conversion du nombre en entier
    call ascii_to_int   
    mov ebx, eax        

    ; Vérification de primalité
    mov ecx, 2          
.loop:
    cmp ecx, ebx        
    jge .prime          
    mov eax, ebx        
    xor edx, edx        
    div ecx             
    test edx, edx       
    jz .not_prime       
    inc ecx             
    jmp .loop           
.prime:
    mov byte [is_prime], 0  
    jmp .end_program
.not_prime:
    mov byte [is_prime], 1  
.end_program:
    ; Affiche le résultat
    cmp byte [is_prime], 0
    je .print_prime
    mov rdi, not_prime_msg
    call print_string
    jmp .exit_program
.print_prime:
    mov rdi, prime_msg
    call print_string
.exit_program:
    
    mov eax, 60         
    xor edi, edi        
    syscall

; Lire un nombre depuis l'entrée standard
read_number:
    mov rax, 0          
    syscall
    ret

; Fonction pour afficher une chaîne de caractères
print_string:
    mov rax, 1         
    mov rdx, 32         
    syscall
    ret

; Fonction pour convertir un nombre ASCII en entier
ascii_to_int:
    xor rcx, rcx        
    xor rax, rax        
.loop:
    movzx edx, byte [rsi + rcx] ; Charge le caractère ASCII
    test dl, dl        
    jz .done           
    sub dl, '0'        
    imul rax, 10       
    add rax, rdx       
    inc rcx            
    jmp .loop          
.done:
    ret