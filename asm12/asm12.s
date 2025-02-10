section .data
    buffer times 1024 db 0   ; Input buffer
    len dq 0                 ; Length of input string

section .text
    global _start

_start:
    ; Read input
    mov rax, 0              ; sys_read
    mov rdi, 0              ; stdin
    mov rsi, buffer         ; buffer
    mov rdx, 1024          ; size
    syscall

    ; Store length and adjust for newline
    dec rax                 ; Remove newline from count
    mov qword [len], rax    ; Store length
    
    ; Set up for printing in reverse
    mov rsi, buffer         ; Start of buffer
    add rsi, rax            ; Point to last character (before newline)
    mov rdx, 1              ; Print one char at a time

_print_reverse:
    ; Check if we're done
    cmp rsi, buffer
    jl _exit               ; If we've printed all characters

    ; Print current character
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    push rsi                ; Save current position
    syscall
    pop rsi                 ; Restore position

    ; Move to previous character
    dec rsi
    jmp _print_reverse

_exit:
    ; Print newline
    mov byte [buffer], 10   ; newline character
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, buffer         ; buffer with newline
    mov rdx, 1              ; length 1
    syscall

    ; Exit program
    mov rax, 60             ; sys_exit
    xor rdi, rdi            ; status 0
    syscall