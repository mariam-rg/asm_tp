sys_stdin   equ 0
sys_stdout  equ 1

sys_read    equ 0
sys_write   equ 1
sys_exit    equ 60

section .data
    txt db " "

section .text
    global _start

_start:
    pop r8


    cmp r8, 2
    jnz .error

    pop rdi
    pop rdi

    call atoi


    cmp rax, -1
    jnz .error

    mov r9, rax

.convert_to_binary:
    mov rbx, 2

.convert_to_binary_loop:
    cmp rax, 1
    jl .display_binary


    div rbx
    add rdx, byte 48

    push rdx
    xor rdx, rdx

    jmp .convert_to_binary_loop

.display_binary:
    pop rdx

    test rdx,rdx
    jz .display_binary_end

    mov rax, sys_write
    mov rdi, sys_stdout
    mov [txt], rdx
    mov rsi, txt
    mov rdx, 1
    syscall

    jmp .display_binary

.display_binary_end:

    mov rax, sys_write
    mov rdi, sys_stdout
    mov [txt], byte 10
    mov rsi, txt
    mov rdx, 1
    syscall


    jmp .exit_success

.error:
    mov rax, sys_exit
    mov rdi, 1
    syscall

.exit_success:
    mov rax, sys_exit
    mov rdi, r10
    syscall

atoi:
    xor rsi, rsi
    call strlen
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


strlen:
    xor rax, rax

.strlen_loop:

    cmp [rdi + rax], byte 0
    jz .strlen_end

    inc rax
    jmp .strlen_loop

.strlen_end:
    ret