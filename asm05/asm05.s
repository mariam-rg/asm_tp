section .data
    newline db 10

section .bss
    buffer resb 32    ; Buffer for output
    tmp resb 1        ; Temporary storage

section .text
global _start

_start:
    pop rcx         ; Get argc
    cmp rcx, 2      ; Check if we have exactly 2 arguments (program name + string)
    jne _error

    pop rcx         ; Skip program name
    pop r8          ; Get string argument

    ; Calculate string length first
    xor r11, r11    ; Clear counter

_count_loop:
    mov al, byte [r8 + r11]  ; Get current character
    test al, al              ; Check for null terminator
    jz _print_string         ; If null, we're done counting
    inc r11                  ; Increment counter
    jmp _count_loop          ; Continue counting

_print_string:
    ; Print the string
    mov rax, 1      ; sys_write
    mov rdi, 1      ; stdout
    mov rsi, r8     ; string to print
    mov rdx, r11    ; length
    syscall

    ; Print newline
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, newline    ; newline character
    mov rdx, 1          ; length
    syscall

    jmp _success

_success:
    mov rax, 60         ; sys_exit
    xor rdi, rdi        ; return 0
    syscall

_error:
    mov rax, 60         ; sys_exit
    mov rdi, 1          ; return 1
    syscall