sys_stdin   equ 0
sys_stdout  equ 1

sys_read    equ 0
sys_write   equ 1
sys_exit    equ 60

section .data

section .bss
    input resb 100

section .text
    global _start

_start:

.read_input:
    mov rax, sys_read
    mov rdi, sys_stdin
    mov rsi, input
    mov rdx, 100
    syscall

    mov rdi, rsi
    call atoi
    mov rbx, rax


.find_sqrt:
    cvtsi2sd xmm0, rbx
    sqrtsd xmm0, xmm0

    cvttsd2si rbx, xmm0

    mov rdi, rbx
    mov rsi, rax
    mov rcx, 2

.is_primary:
    xor rdx, rdx
    mov rax, rsi
    mov rbx, rcx
    div rbx

    cmp rdx, 0
    jz .error

    cmp rcx, rdi
    jz .success

    inc rcx
    jmp .is_primary


.success:
    mov rax, sys_exit
    mov rdi, 0
    syscall

.error:
    mov rax, sys_exit
    mov rdi, 1
    syscall

atoi:
    call store_value
    mov rcx, rax
    xor rax, rax

.atoi_loop:

    cmp   rsi, rcx
    jge   .atoi_end

    mov   dl, byte [rdi + rsi]

    cmp dl, 10
    jz .atoi_end

    cmp dl, '0'
    jl .atoi_err

    cmp dl, '9'
    jg .atoi_err

    add   rax, rax
    lea   rax, [4 * rax + rax]

    sub   dl, "0"
    movzx rdx, dl
    add   rax, rdx

.atoi_inc:
    inc   rsi
    jmp   .atoi_loop

.atoi_err:
    mov rax, -1
    ret

.atoi_end:
    xor rdx, rdx
    ret


store_value:
    xor rax, rax

.store_value_loop:

    cmp [rdi + rax], byte 0
    jz .store_value_end

    inc rax
    jmp .store_value_loop

.store_value_end:
    ret
