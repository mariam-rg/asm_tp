section .data
    txt db " "

section .text
    global _start

_start:
    pop r8              ; Récupère le nombre d'arguments
    cmp r8, 2           ; Vérifie si le nombre d'arguments est exactement 2
    jnz _error          ; Si ce n'est pas le cas, saute à l'erreur

    pop rdi             ; Ignore le premier argument (nom du programme)
    pop rdi             ; Récupère le deuxième argument (nombre à convertir)

    call convert_to_dec ; Convertit l'argument en entier

    cmp rax, -1         ; Vérifie si la conversion a échoué
    jz _error           ; Si c'est le cas, saute à l'erreur

    cmp rax, 0          ; Vérifie si le nombre est inférieur ou égal à 0
    jle _error          ; Si c'est le cas, saute à l'erreur

    ; Vérifie si le nombre est premier
    call is_prime
    cmp rax, 1
    jz _success         ; Si le nombre est premier, termine avec succès

    ; Si le nombre n'est pas premier, affiche 0
    mov rax, 0
    call _print_number

_success:
    mov rax, 60         ; Appel système pour quitter
    mov rdi, 0          ; Code de sortie 0 (succès)
    syscall

_error:
    mov rax, 60         ; Appel système pour quitter
    mov rdi, 1          ; Code de sortie 1 (erreur)
    syscall

convert_to_dec:
    xor rsi, rsi        ; Initialise rsi à 0
    call string_len     ; Calcule la longueur de la chaîne
    mov rcx, rax        ; Stocke la longueur dans rcx
    xor rax, rax        ; Initialise rax à 0

_convert_to_dec_loop:
    cmp rsi, rcx        ; Compare rsi avec la longueur de la chaîne
    jge _convert_to_dec_end ; Si rsi >= rcx, fin de la conversion

    mov dl, byte [rdi + rsi] ; Charge le caractère courant

    cmp dl, 10          ; Vérifie si c'est un saut de ligne
    jz _convert_to_dec_end ; Si c'est le cas, fin de la conversion

    cmp dl, '0'         ; Vérifie si le caractère est inférieur à '0'
    jl _convert_to_dec_err ; Si c'est le cas, erreur

    cmp dl, '9'         ; Vérifie si le caractère est supérieur à '9'
    jg _convert_to_dec_err ; Si c'est le cas, erreur

    sub dl, '0'         ; Convertit le caractère en chiffre
    imul rax, rax, 10   ; Multiplie rax par 10
    add rax, rdx        ; Ajoute le chiffre à rax

    inc rsi             ; Passe au caractère suivant
    jmp _convert_to_dec_loop ; Répète la boucle

_convert_to_dec_err:
    mov rax, -1         ; Retourne -1 en cas d'erreur
    ret

_convert_to_dec_end:
    ret

string_len:
    xor rax, rax        ; Initialise rax à 0

_string_len_loop:
    cmp byte [rdi + rax], 0 ; Vérifie si le caractère courant est nul
    jz _string_len_end  ; Si c'est le cas, fin de la boucle

    inc rax             ; Incrémente rax
    jmp _string_len_loop ; Répète la boucle

_string_len_end:
    ret

is_prime:
    cmp rdi, 1          ; Vérifie si le nombre est 1
    jle _not_prime      ; 1 n'est pas premier

    mov rcx, 2          ; Commence à diviser par 2

_is_prime_loop:
    cmp rcx, rdi        ; Compare rcx avec rdi
    jge _is_prime       ; Si rcx >= rdi, le nombre est premier

    xor rdx, rdx        ; Initialise rdx à 0
    mov rax, rdi        ; Charge rdi dans rax
    div rcx             ; Divise rax par rcx

    cmp rdx, 0          ; Vérifie si le reste est 0
    jz _not_prime       ; Si c'est le cas, le nombre n'est pas premier

    inc rcx             ; Incrémente rcx
    jmp _is_prime_loop  ; Répète la boucle

_is_prime:
    mov rax, 1          ; Retourne 1 (premier)
    ret

_not_prime:
    mov rax, 0          ; Retourne 0 (non premier)
    ret

_print_number:
    mov rbx, 10         ; Base 10 pour la conversion
    xor rcx, rcx        ; Compteur de chiffres

_push_number_loop:
    xor rdx, rdx        ; Initialise rdx à 0
    div rbx             ; Divise rax par 10
    add rdx, '0'        ; Convertit le reste en caractère
    push rdx            ; Empile le caractère
    inc rcx             ; Incrémente le compteur

    cmp rax, 0          ; Vérifie si rax est 0
    jne _push_number_loop ; Si ce n'est pas le cas, continue

_display_numbers:
    pop rdx             ; Dépile un caractère

    mov rax, 1          ; Appel système pour écrire
    mov rdi, 1          ; Descripteur de fichier (stdout)
    mov [txt], dl       ; Stocke le caractère dans txt
    mov rsi, txt        ; Adresse du buffer
    mov rdx, 1          ; Longueur du buffer
    syscall

    loop _display_numbers ; Répète pour chaque chiffre

    mov rax, 1          ; Appel système pour écrire
    mov rdi, 1          ; Descripteur de fichier (stdout)
    mov [txt], byte 10  ; Nouvelle ligne
    mov rsi, txt        ; Adresse du buffer
    mov rdx, 1          ; Longueur du buffer
    syscall

    ret