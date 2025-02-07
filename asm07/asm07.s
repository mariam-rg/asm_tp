section .data
    txt db " "

section .text
    global _start

_start:
    pop r8
    cmp r8, 2
    jnz _error

    pop rdi
    pop rdi

    call convert_to_dec


    cmp rax, -1
    jz _error

    cmp rax, 0
    jl _error

    cmp rax, 0
    jz _print_0

    dec rax
    mov rcx, rax
    dec rcx

_loop:
    cmp rcx, 1
    jl _print_number

    add rax, rcx
    dec rcx

    jmp _loop

_print_0:
    mov rax, 0

_print_number:

_push_number_loop:
    xor rdx, rdx
    mov rbx, 10
    div rbx

    add rdx, '0'
    push rdx

    cmp rax, 1
    jl _display_numbers

    jmp _push_number_loop

_display_numbers:
    pop rdx

    test rdx, rdx
    jz _print_number_end


    mov rax, 1
    mov rdi, 1
    mov [txt], rdx
    mov rsi, txt
    mov rdx, 1
    syscall

    jmp _display_numbers

_print_number_end:


    mov rax, 1
    mov rdi, 1
    mov [txt], byte 10
    mov rsi, txt
    mov rdx, 1
    syscall

    xor rcx, rcx

_success:
    mov rax, 60
    mov rdi, 0
    syscall

_error:
    mov rax, 60
    mov rdi, 1
    syscall

convert_to_dec:
    xor rsi, rsi
    call string_len
    mov rcx, rax
    xor rax, rax

_convert_to_dec_loop:

    cmp   rsi, rcx
    jge   _convert_to_dec_end

    mov   dl, byte [rdi + rsi]

    cmp dl, 10
    jz _convert_to_dec_end

    cmp dl, '0'
    jl _convert_to_dec_err

    cmp dl, '9'
    jg _convert_to_dec_err

    add   rax, rax
    lea   rax, [4 * rax + rax]

    sub   dl, "0"
    movzx rdx, dl
    add   rax, rdx

_convert_to_dec_inc:
    inc   rsi
    jmp   _convert_to_dec_loop

_convert_to_dec_err:
    mov rax, -1
    ret

_convert_to_dec_end:
    xor rdx, rdx
    ret


string_len:
    xor rax, rax

_string_len_loop:

    cmp [rdi + rax], byte 0
    jz _string_len_end

    inc rax
    jmp _string_len_loop

_string_len_end:
    ret
