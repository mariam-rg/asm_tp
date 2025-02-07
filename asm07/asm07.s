
Click to open code
The program:

Takes a string argument
Counts vowels (a,e,i,o,u - both cases)
Prints the count
Returns 0 on success, 1 on error
 Copy
Retry


Claude can make mistakes. Please double-check responses.



Aucun fichier choisi


3.5 Haiku

Concise
1 message
remaining
until
7:00 PM
Subscribe to Pro

Vowel Counter Assembly Program

section .data
    vowels db "aeiouAEIOU", 0
    txt db " "

section .text
    global _start

_start:
    pop r8                 ; Get argc
    dec r8                 ; Actual argument count
    cmp r8, 1             ; Check if exactly 1 argument
    jne _error

    pop rdi               ; Program name
    pop rdi               ; Get string argument

    xor r9, r9           ; Vowel counter
    xor rsi, rsi         ; String index

_count_loop:
    mov dl, byte [rdi + rsi]
    test dl, dl
    jz _print_result     ; End of string

    mov rbx, vowels      ; Reset vowels pointer
_check_vowel:
    mov cl, byte [rbx]
    test cl, cl
    jz _next_char        ; Not a vowel

    cmp dl, cl
    je _found_vowel

    inc rbx
    jmp _check_vowel

_found_vowel:
    inc r9

_next_char:
    inc rsi
    jmp _count_loop

_print_result:
    mov rax, r9
    xor rcx, rcx         ; Digit counter

_convert_loop:
    xor rdx, rdx
    mov rbx, 10
    div rbx
    add rdx, '0'         ; Convert to ASCII
    push rdx
    inc rcx
    test rax, rax
    jnz _convert_loop

_print_loop:
    test rcx, rcx
    jz _print_newline
    
    pop rdx
    mov [txt], dl
    push rcx
    
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, txt        ; buffer
    mov rdx, 1          ; length
    syscall
    
    pop rcx
    dec rcx
    jmp _print_loop

_print_newline:
    mov byte [txt], 10   ; newline
    mov rax, 1
    mov rdi, 1
    mov rsi, txt
    mov rdx, 1
    syscall

    mov rax, 60         ; sys_exit
    xor rdi, rdi        ; status 0
    syscall

_error:
    mov rax, 60         ; sys_exit
    mov rdi, 1          ; status 1
    syscall