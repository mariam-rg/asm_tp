section .data

global _start

section .bss
    tmp resb 1

section .text

_start:
    pop r10 ; number of arguments
    cmp r10, 3
    jne _error


    pop r10
    xor r10, r10

    pop r8
    call _conv

    mov r11, rax
    pop r8

    call _conv
    mov r10, rax


    add r11, r10


    xor rax, rax
    xor rdi, rdi
    xor rsi, rsi
    xor rdx, rdx

    jmp _conv_inv

    jmp _error




;_affiche:
;    mov rax, 1
;    mov rdi, 1
;    mov rsi,
;    mov rdx, 1
;    syscall


; rcx, rdx, rax, r8, rbx
_conv:
    xor rax,rax
    xor rcx, rcx
    xor dl, dl
    xor rdx, rdx

_conv_loop:

    mov dl, [r8+rcx]

    cmp dl, byte 0
    je _conv_end

    sub dl, 48
    add al, dl

    cmp [r8+rcx+1], byte 0
    je _conv_end

    mov bl, 10
    mul bl
    inc rcx


    jmp _conv_loop

_conv_end:
    ret



_conv_inv:
   mov rax, r11
_loop:

    cmp rax, byte 1
    jl _affiche

    xor rdx, rdx
    mov rbx, 10
    div rbx
    add rdx, 48
    push rdx
   jmp _loop

_affiche:
_loop_aff:
    xor rdx, rdx
    pop rdx
    test rdx, rdx
    je _end

    mov rax, 1
    mov rdi, 1
    mov [tmp], rdx
    mov rsi, tmp
    mov rdx, 1
    syscall

    jmp _loop_aff



_end:

    mov rax, 1
    mov rdi, 1
    mov [tmp], byte 10
    mov rsi, tmp
    mov rdx, 1
    syscall

_error:
    mov rax, 60
    mov rdi, 0
    syscall