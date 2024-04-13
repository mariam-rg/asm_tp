section .data
    result db "Result: ", 0
    newline db 0xA
    buffer db 32

section .text
    global _start

_start:
    ; Lecture du premier nombre passé en paramètre
    mov rdi, 1          ; descripteur de fichier (1 pour stdout)
    mov rsi, [rsp + 8]  
    call print_string   
    call read_number    

    ; Conversion du premier nombre en entier
    call ascii_to_int   ; convertit le nombre ASCII en entier
    mov ebx, eax        

    ; Lecture du deuxième nombre passé en paramètre
    mov rsi, [rsp + 16] 
    call print_string   
    call read_number    

    ; Conversion du deuxième nombre en entier
    call ascii_to_int   ; convertit le nombre ASCII en entier
    add eax, ebx        ; additionne le premier et le deuxième nombre

    ; Affichage du résultat
    mov rdi, 1          ; descripteur de fichier (1 pour stdout)
    mov rsi, result     
    call print_string   ; affiche le message "Result: "
    call int_to_ascii   
    call print_string   
    mov rsi, newline    
    call print_string   

    ; Sortie du programme
    mov rax, 60         
    xor rdi, rdi        
    syscall

; Fonction pour lire un nombre depuis l'entrée standard
read_number:
    mov rax, 0          
    mov rdi, 0          
    mov rdx, 32         
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
    movzx edx, byte [rsi + rcx] ; charge le caractère ASCII
    test dl, dl        
    jz .done           
    sub dl, '0'        
    imul rax, 10       
    add rax, rdx       
    inc rcx            
    jmp .loop          
.done:
    ret

; Fonction pour convertir un entier en ASCII
int_to_ascii:
    mov rdi, buffer     
    mov rcx, 10         
    mov rbx, 10         
    .again:
        mov rdx, 0      
        div rbx         
        add dl, '0'     
        dec rdi         
        mov [rdi], dl   
        test rax, rax  
        jnz .again      
    mov rsi, rdi        
    ret