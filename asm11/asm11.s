section .data
    vowels db "aeiouAEIOU", 0
    buffer db 100 dup(0)

section .text
    global _start

_start:
    ; Read input
    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    mov rsi, buffer     ; buffer
    mov rdx, 100        ; size
    syscall

    ; Check if input is empty
    cmp rax, 1          ; If only newline or empty
    jle _print_zero     ; Print 0 for empty input

    ; Initialize result
    mov r9, 1           ; Start assuming all consonants (1)
    mov rsi, buffer     ; Input string pointer

_check_loop:
    movzx rdx, byte [rsi]   ; Load current character
    test dl, dl             ; Check for null terminator
    jz _print_result
    cmp dl, 10              ; Check for newline
    je _print_result

    ; Skip spaces
    cmp dl, ' '             ; Check for space
    je _next_char

    mov rdi, vowels         ; Reset vowels pointer
_check_vowel:
    movzx rcx, byte [rdi]   ; Load current vowel
    test cl, cl             ; Check for end of vowels
    jz _next_char

    cmp dl, cl              ; Compare with current vowel
    je _found_vowel

    inc rdi                 ; Next vowel
    jmp _check_vowel

_found_vowel:
    mov r9, 0              ; Found a vowel, set result to 0
    jmp _print_result      ; No need to check further

_next_char:
    inc rsi                ; Next character
    jmp _check_loop

_print_zero:
    mov r9, 0              ; Set result to 0

_print_result:
    mov rax, r9            ; Move result to rax for printing
    call _print_number

    mov rax, 60            ; sys_exit
    xor rdi, rdi          ; Exit code 0
    syscall

_print_number:
    push rax               ; Save the number
    mov rax, 1            ; sys_write
    mov rdi, 1            ; stdout
    lea rsi, [rsp]        ; Point to number on stack
    add BYTE [rsi], '0'   ; Convert to ASCII
    mov rdx, 1            ; Length 1
    syscall

    mov rax, 1            ; sys_write
    mov rdi, 1            ; stdout
    push 10               ; Newline
    mov rsi, rsp          ; Point to newline
    mov rdx, 1            ; Length 1
    syscall

    add rsp, 16           ; Clean up stack
    ret