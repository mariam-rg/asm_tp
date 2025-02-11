    section .bss
    buffer: resb 1024        ; Buffer for input string
    buflen: equ 1024        ; Buffer length

section .text
    global _start

_start:
    ; Read input string
    mov rax, 0              ; sys_read
    mov rdi, 0              ; stdin
    mov rsi, buffer         ; buffer address
    mov rdx, buflen        ; buffer length
    syscall

    ; Get string length (excluding newline)
    mov rcx, rax            ; Save read bytes count
    dec rcx                 ; Exclude newline character
    test rcx, rcx          ; Check if empty string
    jle palindrome         ; Empty string is a palindrome

    ; Initialize pointers
    mov rsi, buffer        ; Start pointer
    lea rdi, [buffer+rcx-1] ; End pointer

check_palindrome:
    cmp rsi, rdi           ; Check if pointers crossed
    jge palindrome         ; If crossed, it's a palindrome

    mov al, [rsi]          ; Load character from start
    mov bl, [rdi]          ; Load character from end

    cmp al, bl             ; Compare characters
    jne not_palindrome     ; If not equal, not a palindrome

    inc rsi                ; Move start pointer forward
    dec rdi                ; Move end pointer backward
    jmp check_palindrome   ; Continue checking

palindrome:
    mov rdi, 0             ; Exit status 0 (success)
    jmp exit

not_palindrome:
    mov rdi, 1             ; Exit status 1 (failure)

exit:
    mov rax, 60            ; sys_exit
    syscall