section .data
    elf_magic db 0x7f, "ELF"    ; ELF magic numbers

section .bss
    buffer resb 16

section .test
    global _start

_start:
    ; Get argc
    pop rdi
    cmp rdi, 2                  ; Check if we have exactly one argument
    jne _not_elf

    ; Get argv
    pop rdi                     ; Skip program name
    pop rsi                     ; Get file path into rsi

    ; Open file
    call _open
    cmp rax, 0                 ; Check if open succeeded
    jl _not_elf

    ; Read file
    call _read
    cmp rax, 16                ; Check if we read 16 bytes
    jne _not_elf

    ; Check ELF magic numbers
    mov rsi, buffer
    mov rdi, elf_magic
    mov rcx, 4
    repe cmpsb
    jne _not_elf

    ; Check machine type (x86-64 = 0x3E)
    mov al, byte [buffer + 0x12]
    cmp al, 0x3E
    jne _not_elf

    ; Success - is ELF x86-64
    call _close
    xor rdi, rdi               ; Exit code 0
    jmp _exit

_not_elf:
    call _close
    mov rdi, 1                 ; Exit code 1

_exit:
    mov rax, 60                ; sys_exit
    syscall



_open:
    mov rax,2
    mov rdi, rsi
    mov rsi, 0
    syscall

_read:
    mov rdi, rax
    mov rax,0
    mov rsi, buffer
    mov rdx, 16
    syscall

_close:
    mov rax,3
    syscall