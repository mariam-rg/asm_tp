section .data
    newline db 10

section .bss
    buffer resb 32

section .text
global _start

_start:
    pop rcx         ; Get argc
    cmp rcx, 4      ; Need exactly 4 arguments
    jne error

    pop rcx         ; Skip program name
    pop rdi         ; First number
    call atoi
    mov r12, rax    ; Store first number

    pop rdi         ; Second number
    call atoi
    mov r13, rax    ; Store second number

    pop rdi         ; Third number
    call atoi
    mov r14, rax    ; Store third number

    ; Find maximum
    mov rax, r12    ; Start with first number
    cmp rax, r13    ; Compare with second
    jge check_third
    mov rax, r13    ; Second is larger

check_third:
    cmp rax, r14    ; Compare with third
    jge print_result
    mov rax, r14    ; Third is larger

print_result:
    mov rdi, buffer
    call itoa

    ; Print number
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer
    mov rdx, rbx
    syscall

    ; Print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    mov rax, 60     ; sys_exit
    xor rdi, rdi    ; return 0
    syscall

error:
    mov rax, 60     ; sys_exit
    mov rdi, 1      ; return 1
    syscall

; Convert string to integer
atoi:
    xor rax, rax
.loop:
    movzx rdx, byte [rdi]
    test dl, dl
    jz .done
    sub dl, '0'
    cmp dl, 9
    ja error
    imul rax, 10
    add rax, rdx
    inc rdi
    jmp .loop
.done:
    ret

; Convert integer to string
itoa:
    mov rsi, buffer
    add rsi, 31
    mov byte [rsi], 0
    mov rbx, 0      ; Length counter

    test rax, rax
    jnz .loop

    dec rsi
    mov byte [rsi], '0'
    inc rbx
    jmp .done

.loop:
    test rax, rax
    jz .done

    xor rdx, rdx
    mov rcx, 10
    div rcx
    add dl, '0'
    dec rsi
    mov [rsi], dl
    inc rbx
    jmp .loop

.done:
    mov rdi, buffer
    mov rcx, rbx
    rep movsb
    ret