section .data
    elf_magic db 0x7f, "ELF"    ; ELF magic numbers

section .bss
    buffer resb 16              ; Buffer for ELF header

section .text
    global _start

_start:
    ; Get argc and check arguments
    pop rcx                     ; Get argc
    cmp rcx, 2                  ; Check if we have exactly one argument
    jne _not_elf_no_close
    
    pop rcx                     ; Skip program name
    pop rsi                     ; Get file path into rsi

    ; Open file
    mov rax, 2                  ; sys_open
    mov rdi, rsi                ; filename
    xor rsi, rsi                ; O_RDONLY
    syscall
    
    ; Check if open succeeded
    cmp rax, 0                  
    jl _not_elf_no_close
    mov rdi, rax                ; Save file descriptor in rdi for read
    
    ; Read file header
    mov rax, 0                  ; sys_read
    mov rsi, buffer             ; buffer
    mov rdx, 16                 ; count
    syscall
    
    ; Save file descriptor for later close
    push rdi
    
    ; Check if read succeeded with 16 bytes
    cmp rax, 16                 
    jne _not_elf

    ; Check ELF magic numbers
    mov rsi, buffer             ; Source for comparison
    mov rdi, elf_magic          ; Target for comparison
    cld                         ; Clear direction flag
    mov rcx, 4                  ; Compare 4 bytes
    repe cmpsb
    jne _not_elf

    ; Check machine type (x86-64 = 0x3E)
    cmp byte [buffer + 0x12], 0x3E
    jne _not_elf

    ; Success - is ELF x86-64
    pop rdi                     ; Restore file descriptor
    mov rax, 3                  ; sys_close
    syscall
    xor rdi, rdi                ; Exit code 0
    jmp _exit

_not_elf:
    pop rdi                     ; Restore file descriptor
    mov rax, 3                  ; sys_close
    syscall
    mov rdi, 1                  ; Exit code 1
    jmp _exit

_not_elf_no_close:
    mov rdi, 1                  ; Exit code 1

_exit:
    mov rax, 60                 ; sys_exit
    syscall