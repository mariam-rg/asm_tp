section .bss
    buffer: resb 1024          ; Input buffer
    result: resb 1024          ; Output buffer

section .text
    global _start

_start:
    ; Check arguments count
    pop rcx                    ; Get argc
    cmp rcx, 2                ; Need exactly one argument
    jne exit_error

    ; Skip program name
    pop rcx

    ; Get shift value from argument
    pop rdi                    ; Get shift argument
    call atoi                  ; Convert ASCII to integer
    mov r12, rax              ; Store shift value

    ; Normalize shift value to be within 0-25
    mov rdx, 0                ; Clear rdx for division
    mov rax, r12              ; Get shift value
    mov rbx, 26               ; Divisor
    div rbx                   ; Divide by 26
    mov r12, rdx              ; Store remainder as shift value

    ; Read input string
    mov rax, 0                ; sys_read
    mov rdi, 0                ; stdin
    mov rsi, buffer           ; buffer
    mov rdx, 1024            ; size
    syscall

    ; Check read success
    cmp rax, 0
    jle exit_error
    mov r13, rax              ; Store length

    ; Process each character
    xor rcx, rcx              ; Initialize counter
    mov rsi, buffer           ; Source buffer
    mov rdi, result           ; Destination buffer

process_loop:
    cmp rcx, r13              ; Check if we're done
    jge write_output

    movzx rax, byte [rsi]     ; Get current character

    ; Check if uppercase
    cmp al, 'A'
    jl not_alpha
    cmp al, 'Z'
    jle process_upper

    ; Check if lowercase
    cmp al, 'a'
    jl not_alpha
    cmp al, 'z'
    jle process_lower

    jmp not_alpha

process_upper:
    sub al, 'A'               ; Convert to 0-25
    add rax, r12              ; Add shift
    mov rdx, 0                ; Clear for division
    mov rbx, 26
    div rbx                   ; Divide by 26 for wrap-around
    add dl, 'A'               ; Convert back to ASCII
    mov [rdi], dl             ; Store result
    jmp next_char

process_lower:
    sub al, 'a'               ; Convert to 0-25
    add rax, r12              ; Add shift
    mov rdx, 0                ; Clear for division
    mov rbx, 26
    div rbx                   ; Divide by 26 for wrap-around
    add dl, 'a'               ; Convert back to ASCII
    mov [rdi], dl             ; Store result
    jmp next_char

not_alpha:
    mov [rdi], al             ; Keep unchanged

next_char:
    inc rsi
    inc rdi
    inc rcx
    jmp process_loop

write_output:
    mov rax, 1                ; sys_write
    mov rdi, 1                ; stdout
    mov rsi, result           ; output buffer
    mov rdx, r13              ; length
    syscall

    xor rdi, rdi              ; Exit code 0
    jmp exit

exit_error:
    mov rdi, 1                ; Exit code 1

exit:
    mov rax, 60               ; sys_exit
    syscall

; Convert ASCII string to integer
atoi:
    xor rax, rax              ; Initialize result
    xor rcx, rcx              ; Initialize index
.loop:
    movzx rdx, byte [rdi+rcx] ; Get current digit
    test dl, dl               ; Check for null terminator
    jz .done
    sub dl, '0'               ; Convert ASCII to number
    imul rax, 10              ; Multiply current result by 10
    add rax, rdx              ; Add new digit
    inc rcx                   ; Move to next digit
    jmp .loop
.done:
    ret