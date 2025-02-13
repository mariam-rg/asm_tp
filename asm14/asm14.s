section .data
    message: db "Hello Universe!", 10    ; Message to write (with newline)
    msglen: equ $ - message             ; Length of message

section .text
    global _start

_start:
    ; Check if we have exactly one argument
    pop rdi                 ; Get argc into rdi
    cmp rdi, 2             ; Should be 2 (program name + filename)
    jne exit_error         ; If not 2 arguments, exit with error

    ; Get filename pointer (skip program name)
    pop rdi                ; Skip program name
    pop rdi                ; Get filename pointer

    ; Open file
    mov rax, 2            ; sys_open
    mov rsi, 0102o        ; O_CREAT | O_WRONLY (octal)
    mov rdx, 0666o        ; File permissions (octal)
    syscall

    ; Check if file opened successfully
    cmp rax, 0
    jl exit_error         ; Exit if error (negative value)

    ; Save file descriptor
    mov rdi, rax

    ; Write message to file
    mov rax, 1            ; sys_write
    mov rsi, message      ; Message to write
    mov rdx, msglen       ; Message length
    syscall

    ; Close file
    mov rax, 3            ; sys_close
    syscall

    ; Exit successfully
    xor rdi, rdi          ; Exit code 0
    jmp exit

exit_error:
    mov rdi, 1            ; Exit code 1

exit:
    mov rax, 60           ; sys_exit
    syscall