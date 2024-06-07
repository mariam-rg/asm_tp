section .data

section .bss
    input resb 100

section .text
    global _start

_start:

_read_input:
    mov rax, 0
    mov rdi, 0
    mov rsi, input
    mov rdx, 100
    syscall

    mov rdi, rsi
    call convert_to_dec
    mov rbx, rax

    cmp rax, 2
    jl _error

_find_sqrt:
    cvtsi2sd xmm0, rbx
    sqrtsd xmm0, xmm0

    cvttsd2si rbx, xmm0

    mov rdi, rbx
    inc rdi
    mov rsi, rax
    mov rcx, 2

_primary:
    xor rdx, rdx
    mov rax, rsi
    mov rbx, rcx
    div rbx

    cmp rcx, rdi
    jz _success

    cmp rdx, 0
    jz _error

    inc rcx
    jmp _primary


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
