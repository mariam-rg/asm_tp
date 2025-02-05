section .text
    global _start

_start:
   
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 10
    int 0x80

    call atoi

    cmp byte [buffer], '-'
    je binary_convert

    call int_to_hex
    jmp exit

binary_convert:
    call int_to_bin
    jmp exit

exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80

int_to_hex:
    mov ecx, 8
.hex_loop:
    rol eax, 4
    mov dl, al
    and dl, 0xF
    add dl, '0'
    cmp dl, '9'
    jbe .print_hex
    add dl, 7
.print_hex:
    mov [hex_buffer+ecx-1], dl
    loop .hex_loop
    mov eax, 4
    mov ebx, 1
    mov ecx, hex_buffer
    mov edx, 8
    int 0x80
    ret

int_to_bin:
    mov ecx, 32
.bin_loop:
    shl eax, 1
    mov dl, '0'
    jc .set_one
    jmp .store
.set_one:
    mov dl, '1'
.store:
    mov [bin_buffer+ecx-1], dl
    loop .bin_loop
    mov eax, 4
    mov ebx, 1
    mov ecx, bin_buffer
    mov edx, 32
    int 0x80
    ret

section .bss
    buffer resb 10
    hex_buffer resb 8
    bin_buffer resb 32
