section .data
    newline db 10

section .bss
    buffer resb 32

section .text
    global _start

_start:
    pop rcx
    cmp rcx, 3
    jne _error

    pop rcx
    pop rdi
    call convert_to_dec
    cmp rax, -1
    je _error
    mov r12, rax

    pop rdi
    call convert_to_dec
    cmp rax, -1
    je _error

    add rax, r12
    mov rdi, rax
    call print_number
    jmp _success

convert_to_dec:
    push r12
    push r13
    push r14
    push r15

    xor rax, rax
    xor rcx, rcx
    xor r12, r12

    cmp byte [rdi], '-'
    jne .convert_loop
    inc rdi
    mov r12, 1

.convert_loop:
    movzx rdx, byte [rdi + rcx]
    test dl, dl
    jz .convert_end
    cmp dl, 10
    je .convert_end

    sub dl, '0'
    cmp dl, 9
    ja .convert_error

    push rdx
    mov rdx, 10
    mul rdx
    pop rdx
    add rax, rdx

    inc rcx
    jmp .convert_loop

.convert_end:
    test rcx, rcx
    jz .convert_error

    test r12, r12
    jz .convert_done
    neg rax

.convert_done:
    pop r15
    pop r14
    pop r13
    pop r12
    ret

.convert_error:
    mov rax, -1
    pop r15
    pop r14
    pop r13
    pop r12
    ret

print_number:
    push r12
    push r13
    push r14
    push r15

    mov rax, rdi
    mov rdi, buffer
    mov rsi, 0
    mov rcx, 0

    test rax, rax
    jns .convert

    neg rax
    mov byte [buffer + rsi], '-'
    inc rsi

.convert:
    mov rdx, 0
    mov rbx, 10
    div rbx
    add rdx, '0'
    push rdx
    inc rcx
    test rax, rax
    jnz .convert

.print_loop:
    pop rdx
    mov [buffer + rsi], dl
    inc rsi
    loop .print_loop

    mov byte [buffer + rsi], 10
    inc rsi

    mov rax, 1
    mov rdi, 1
    mov rdx, rsi
    mov rsi, buffer
    syscall

    pop r15
    pop r14
    pop r13
    pop r12
    ret

_success:
    mov rax, 60
    xor rdi, rdi
    syscall

_error:
    mov rax, 60
    mov rdi, 1
    syscall