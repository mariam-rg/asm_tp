section .bss
    buffer resb 33   ; Buffer pour stocker la sortie binaire

section .data
    usage_msg db "Usage: ./asm09 [-b] <number>", 10, 0
    newline db 10, 0
    hex_digits db "0123456789ABCDEF"

section .text
    global _start

_start:
    ; Vérifier le nombre d'arguments
    mov rsi, [rsp+8]   ; Premier argument (option ou nombre)
    test rsi, rsi
    jz error_usage

    mov rdi, [rsp+16]  ; Deuxième argument si présent
    test rdi, rdi
    jz parse_decimal  ; Pas d'option, c'est une conversion hex

    ; Vérifier si l'option est '-b'
    mov rax, [rsi]
    cmp byte [rax], '-'   ; Vérifier le premier caractère
    jne parse_decimal  ; Pas d'option, traiter comme un nombre
    cmp byte [rax+1], 'b'
    jne error_usage   ; Mauvaise option

    mov rsi, rdi  ; Déplacer le nombre en tant qu'argument principal
    call parse_decimal
    call convert_to_binary
    jmp print_output

parse_decimal:
    ; Convertir l'entrée en nombre
    xor rbx, rbx    ; rbx contiendra le nombre converti
.loop:
    movzx rax, byte [rsi]
    test rax, rax
    jz done_parsing
    cmp rax, '0'
    jb error_usage
    cmp rax, '9'
    ja error_usage
    sub rax, '0'
    imul rbx, rbx, 10
    add rbx, rax
    inc rsi
    jmp .loop

done_parsing:
    ; Vérifier si nous sommes en mode binaire ou hex
    cmp byte [rsp+8], '-'
    je convert_to_binary
    call convert_to_hex
    jmp print_output

convert_to_hex:
    mov rcx, 0
    mov rsi, buffer + 32  ; Fin du buffer
    mov byte [rsi], 0
    dec rsi
.loop:
    mov rax, rbx
    and rax, 0xF
    mov al, [hex_digits + rax]
    mov [rsi], al
    shr rbx, 4
    dec rsi
    inc rcx
    test rbx, rbx
    jnz .loop
    inc rsi
    ret

convert_to_binary:
    mov rcx, 0
    mov rsi, buffer + 32  ; Fin du buffer
    mov byte [rsi], 0
    dec rsi
.loop:
    mov rax, rbx
    and rax, 1
    add al, '0'
    mov [rsi], al
    shr rbx, 1
    dec rsi
    inc rcx
    test rbx, rbx
    jnz .loop
    inc rsi
    ret

print_output:
    ; Afficher la sortie
    mov rdx, rcx
    mov rax, 1   ; sys_write
    mov rdi, 1   ; stdout
    syscall

    ; Afficher une nouvelle ligne
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; Quitter proprement
    mov rax, 60
    xor rdi, rdi
    syscall

error_usage:
    ; Afficher message d'usage
    mov rax, 1
    mov rdi, 1
    mov rsi, usage_msg
    mov rdx, 30
    syscall
    mov rax, 60
    mov rdi, 1
    syscall
