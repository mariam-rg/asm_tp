section .data
    newline db 10

section .bss
    buffer resb 32    ; Buffer for number output
    tmp resb 1        ; Temporary storage for single character

section .text
global _start

_start:
    pop rcx         ; Get argc
    cmp rcx, 2      ; Check if we have exactly 2 arguments (program name + string)
    jne _error

    pop rcx         ; Skip program name
    pop r8          ; Get string argument

    ; Calculate string length
    xor r11, r11    ; Clear counter

_count_loop:
    mov al, byte [r8 + r11]  ; Get current character
    test al, al              ; Check for null terminator
    jz _count_done           ; If null, we're done
    inc r11                  ; Increment counter
    jmp _count_loop          ; Continue counting

_count_done:
    ; Convert length (in r11) to string for output
    mov rax, r11
    jmp _conv_inv

_conv_inv:
    test rax, rax        ; Check if number is 0
    jnz _start_conv

    ; Handle 0 case
    mov byte [tmp], '0'
    mov rax, 1
    mov rdi, 1
    mov rsi, tmp
    mov rdx, 1
    syscall
    jmp _print_newline

_start_conv:
    xor rcx, rcx        ; Initialize counter

_conv_loop:
    test rax, rax       ; Check if we're done
    jz _print_digits

    xor rdx, rdx        ; Clear for division
    mov rbx, 10
    div rbx             ; Divide by 10
    add rdx, '0'        ; Convert to ASCII
    push rdx            ; Save digit
    inc rcx             ; Increment counter
    jmp _conv_loop

_print_digits:
    test rcx, rcx       ; Check if we have digits to print
    jz _print_newline   ; If not, print newline

    pop rdx             ; Get digit
    mov [tmp], dl       ; Store in tmp
    push rcx            ; Save counter

    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, tmp        ; buffer
    mov rdx, 1          ; length
    syscall

    pop rcx             ; Restore counter
    dec rcx             ; Decrement counter
    jmp _print_digits

_print_newline:
    mov byte [tmp], 10  ; newline character
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, tmp        ; buffer
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