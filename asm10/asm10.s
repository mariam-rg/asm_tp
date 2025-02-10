section .text
    global _start

_start:
    pop r8          ; Get argc
    cmp r8, 4       ; Need exactly 3 parameters (prog_name + 3 args)
    jne _error

    pop rdi         ; Skip program name
    pop rdi         ; Get first number string
    call _atoi
    mov r9, rax     ; Store first number in r9

    pop rdi         ; Get second number string
    call _atoi
    cmp rax, r9     ; Compare with first number
    jne _not_same

    pop rdi         ; Get third number string
    call _atoi
    cmp rax, r9     ; Compare with first number
    jne _not_same

    jmp _all_same   ; If we get here, all numbers are same

_atoi:
    xor rax, rax        ; Clear result
    xor rcx, rcx        ; Clear index
    mov r10b, 0         ; Clear negative flag
    
    ; Check for negative sign
    cmp byte [rdi], '-'
    jne .loop
    inc rdi             ; Skip minus sign
    mov r10b, 1         ; Set negative flag

.loop:
    movzx rdx, byte [rdi + rcx]
    test dl, dl         ; Check for end of string
    jz .done
    
    cmp dl, '0'
    jl _error
    cmp dl, '9'
    jg _error
    
    sub dl, '0'
    imul rax, 10
    add rax, rdx
    inc rcx
    jmp .loop

.done:
    test r10b, r10b     ; Check if number was negative
    jz .return
    neg rax             ; Make number negative

.return:
    ret

_all_same:
    xor rdi, rdi        ; Return 0
    jmp _exit

_not_same:
    mov rdi, 1          ; Return 1
    jmp _exit

_error:
    mov rdi, 2          ; Return 2 for error

_exit:
    mov rax, 60         ; sys_exit
    syscall