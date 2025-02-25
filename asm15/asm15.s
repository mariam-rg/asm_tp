section .bss
    header: resb 16         ; Buffer for ELF header (first 16 bytes)

section .data
    elf_magic: db 0x7F, "ELF"  ; ELF magic numbers
    x86_64_machine: equ 0x3E   ; Machine type for x86-64

section .text
    global _start

_start:
    ; Check if we have exactly one argument
    pop rdi                 ; Get argc
    cmp rdi, 2             ; Should be 2 (program name + filepath)
    jne not_elf            ; If not 2 arguments, exit with error

    ; Get filepath pointer (skip program name)
    pop rdi                ; Skip program name
    pop rdi                ; Get filepath pointer

    ; Open file
    mov rax, 2            ; sys_open
    xor rsi, rsi          ; O_RDONLY
    syscall

    ; Check if file opened successfully
    cmp rax, 0
    jl not_elf            ; Exit if error (negative value)

    ; Save file descriptor
    mov r8, rax           ; Store fd in r8

    ; Read first 16 bytes (ELF header)
    mov rax, 0            ; sys_read
    mov rdi, r8           ; fd
    mov rsi, header       ; buffer
    mov rdx, 16           ; count
    syscall

    ; Check if read was successful
    cmp rax, 16
    jne close_and_not_elf ; If couldn't read 16 bytes, not an ELF

    ; Check ELF magic numbers (0x7F 'E' 'L' 'F')
    mov rsi, header
    mov rdi, elf_magic
    mov rcx, 4            ; Compare 4 bytes
    repe cmpsb
    jne close_and_not_elf ; If not equal, not an ELF

    ; Check machine type (x86-64 = 0x3E at offset 18)
    mov al, byte [header + 0x12]  ; e_machine field
    cmp al, x86_64_machine
    jne close_and_not_elf

    ; Close file and exit success
    mov rax, 3            ; sys_close
    mov rdi, r8           ; fd
    syscall
    xor rdi, rdi          ; Exit code 0
    jmp exit

close_and_not_elf:
    ; Close file
    mov rax, 3            ; sys_close
    mov rdi, r8           ; fd
    syscall

not_elf:
    mov rdi, 1            ; Exit code 1

exit:
    mov rax, 60           ; sys_exit
    syscall