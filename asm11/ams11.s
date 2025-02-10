section .data
    vowels db "aeiouAEIOU", 0   ; List of vowels to check against
    buffer db 100 dup(0)         ; Input buffer

section .text
    global _start

_start:
    ; Read input
    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    mov rsi, buffer     ; buffer
    mov rdx, 100        ; size
    syscall

    ; Initialize counter
    xor r9, r9          ; Vowel counter
    mov rsi, buffer     ; Input string pointer

_count_loop:
    movzx rdx, byte [rsi]   ; Load current character
    test dl, dl             ; Check for null terminator
    jz _print_result
    cmp dl, 10              ; Check for newline
    je _print_result

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
    inc r9                  ; Increment vowel counter

_next_char:
    inc rsi                 ; Next character
    jmp _count_loop

_print_result:
    mov rax, r9             ; Move count to rax for printing
    call _print_number

    xor rdi, rdi            ; Exit code 0
    mov rax, 60             ; sys_exit
    syscall

_print_number:
    mov rbx, 10             ; Divisor
    xor rcx, rcx            ; Digit counter

_convert_loop:
    xor rdx, rdx            ; Clear remainder
    div rbx                 ; Divide by 10
    add dl, '0'             ; Convert to ASCII
    push rdx                ; Save digit
    inc rcx                 ; Count digits
    test rax, rax           ; Check if more digits
    jnz _convert_loop

_print_digits:
    test rcx, rcx           ; Check if more digits
    jz _print_newline

    pop rdx                 ; Get digit
    push rcx                ; Save counter

    push rdx                ; Save digit for printing
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, rsp            ; Point to digit on stack
    mov rdx, 1              ; Length 1
    syscall
    pop rdx                 ; Clean up digit

    pop rcx                 ; Restore counter
    dec rcx                 ; Decrease counter
    jmp _print_digits

_print_newline:
    push 10                 ; Newline character
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, rsp            ; Point to newline
    mov rdx, 1              ; Length 1
    syscall
    pop rax                 ; Clean up newline
    ret