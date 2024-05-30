section .data
   
   
global _start

section .bss
    input resb 64

section .text

_start:
    mov rax, 0      
    mov rdi, 0    
    mov rsi, input      
    mov rdx, 64      
    syscall


    mov r8, rsi
    call _conv

    mov rbx, 2
    xor rdx, rdx
    div rbx
    cmp rdx, 0
    je _pair
    jne _notpair

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
    cmp dl, 10
    je _conv_end

    sub dl, 48
    add al, dl

    cmp [r8+rcx+1], byte 0
    je _conv_end
    cmp [r8+rcx+1], byte 10
    je _conv_end

    mov bl, 10
    mul bl
    inc rcx
    jmp _conv_loop

_conv_end:
    ret

 

_pair:
    mov rax, 60          
    mov rdi, 0                    
    syscall



   
_notpair:
    mov rax, 60          
    mov rdi, 1                    
    syscall

   