section .text
    global _start

_start:
    ; Lire l'argument de la ligne de commande
    mov ebx, 1          ; Compteur i = 1
    mov ecx, 0          ; Somme totale = 0

    ; Lire l'entrée utilisateur (nombre donné)
    mov eax, 3          ; syscall read
    mov edi, 0          ; stdin
    mov esi, buffer     ; Stockage de l'entrée utilisateur
    mov edx, 10        ; Taille du buffer
    int 0x80

    ; Convertir l'entrée en entier
    call atoi
    dec eax             ; Car on somme jusqu'à N-1
    mov edx, eax        ; Stocker N-1

sum_loop:
    cmp ebx, edx        ; Si i > N-1, terminer
    jg print_result
    add ecx, ebx        ; somme += i
    inc ebx             ; i++
    jmp sum_loop

print_result:
    mov eax, ecx        ; Préparer la somme pour affichage
    call print_int

    mov eax, 1          ; syscall exit
    xor ebx, ebx
    int 0x80

; Conversion ASCII vers entier
atoi:
    xor eax, eax
    xor ecx, ecx
.next_digit:
    movzx edx, byte [esi+ecx]
    cmp dl, 10
    je .done
    sub dl, '0'
    imul eax, eax, 10
    add eax, edx
    inc ecx
    jmp .next_digit
.done:
    ret

; Fonction d'affichage d'un entier
print_int:
    push eax
    mov eax, 4
    mov ebx, 1
    mov ecx, buffer
    mov edx, 10
    int 0x80
    pop eax
    ret

section .bss
    buffer resb 10