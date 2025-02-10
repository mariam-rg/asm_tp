section .data
    buffer db 20 dup(0)

section .text
    global _start

_start:
    pop r8          ; Get argc
    cmp r8, 4       ; Need exactly 3 parameters (prog_name + 3 args)
    jne _error

    pop rdi         ; Skip program name
    pop rdi         ; Get first number string
    call _atoi
    mov r9, rax     ; Store first number in r9 (current max)

    pop rdi         ; Get second number
    call _atoi
    cmp rax, r9     ; Compare with current max
    jle _check_third
    mov r9, rax     ; Update max if larger

_check_third:
    pop rdi         ; Get third number
    call _atoi
    cmp rax, r9     ; Compare with current max
    jle _print_result
    mov r9, rax     ; Update max if larger

_print_result:
    mov rax, r9     ; Move max number to rax for printing
    call _print_number
    xor rdi, rdi    ; Exit code 0
    jmp _exit

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

_print_number:
    mov r10, rax        ; Save original number
    xor rcx, rcx        ; Digit counter
    test rax, rax
    jns .convert        ; If positive, start converting
    neg rax             ; Make positive
    push rax            ; Save number
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    push '-'            ; Print minus sign
    mov rsi, rsp        ; Point to minus sign
    mov rdx, 1          ; Length 1
    syscall
    pop rdx             ; Remove minus sign
    pop rax             ; Restore number

.convert:
    mov rbx, 10
    xor rcx, rcx        ; Clear digit counter

.divide_loop:
    xor rdx, rdx        ; Clear remainder
    div rbx             ; Divide by 10
    add dl, '0'         ; Convert to ASCII
    push rdx            ; Save digit
    inc rcx             ; Count digits
    test rax, rax       ; Check if more digits
    jnz .divide_loop

.print_loop:
    test rcx, rcx       ; Check if more digits
    jz .print_newline
    
    pop rdx             ; Get digit
    mov [buffer], dl    ; Store in buffer
    push rcx            ; Save counter
    
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, buffer     ; buffer
    mov rdx, 1          ; length
    syscall
    
    pop rcx             ; Restore counter
    dec rcx             ; Decrement counter
    jmp .print_loop

.print_newline:
    mov byte [buffer], 10    ; newline
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer
    mov rdx, 1
    syscall
    ret

_error:
    mov rdi, 1          ; Exit code 1

_exit:
    mov rax, 60         ; sys_exit
    syscall