section .data
    txt db " "

section .text
    global _start

_start:
    pop r8         ; Get argc
    dec r8         ; Decrease by 1 to get actual argument count
    cmp r8, 1      ; Check if we have exactly 1 argument
    jne _error_input

    pop rdi        ; Program name
    pop rdi        ; Argument

    call convert_to_dec
    cmp rax, -1
    je _error_input

    cmp rax, 1
    jle _not_prime

    mov rcx, 2
    mov r9, rax    ; Store original number

_check_prime:
    mov rax, r9
    xor rdx, rdx
    div rcx
    
    cmp rdx, 0     ; Check if divisible
    je _not_prime
    
    inc rcx
    mov rax, rcx
    mul rax        ; rcx * rcx
    cmp rax, r9    ; Compare with original number
    jle _check_prime

_is_prime:
    mov rax, r9
    call _print_number
    mov rax, 60
    xor rdi, rdi   ; Exit 0 for prime
    syscall

_not_prime:
    mov rax, r9
    call _print_number
    mov rax, 60
    mov rdi, 1     ; Exit 1 for non-prime
    syscall

_print_number:
    push rax       ; Save number
    xor rcx, rcx

_push_number_loop:
    xor rdx, rdx
    mov rbx, 10
    div rbx
    add rdx, '0'
    push rdx
    inc rcx
    test rax, rax
    jnz _push_number_loop

_display_numbers:
    test rcx, rcx
    jz _print_number_end
    pop rdx
    mov [txt], dl
    push rcx
    mov rax, 1
    mov rdi, 1
    mov rsi, txt
    mov rdx, 1
    syscall
    pop rcx
    dec rcx
    jmp _display_numbers

_print_number_end:
    mov byte [txt], 10
    mov rax, 1
    mov rdi, 1
    mov rsi, txt
    mov rdx, 1
    syscall
    pop rax        ; Restore number
    ret

_error_input:
    mov rax, 60
    mov rdi, 2     ; Exit 2 for bad input
    syscall

convert_to_dec:
    xor rsi, rsi
    call string_len
    mov rcx, rax
    xor rax, rax

_convert_to_dec_loop:
    cmp rsi, rcx
    jge _convert_to_dec_end
    mov dl, byte [rdi + rsi]
    cmp dl, 10
    jz _convert_to_dec_end
    cmp dl, '0'
    jl _convert_to_dec_err
    cmp dl, '9'
    jg _convert_to_dec_err
    add rax, rax
    lea rax, [4 * rax + rax]
    sub dl, '0'
    movzx rdx, dl
    add rax, rdx
    inc rsi
    jmp _convert_to_dec_loop

_convert_to_dec_err:
    mov rax, -1
    ret

_convert_to_dec_end:
    ret

string_len:
    xor rax, rax
_string_len_loop:
    cmp byte [rdi + rax], 0
    jz _string_len_end
    inc rax
    jmp _string_len_loop
_string_len_end:
    ret