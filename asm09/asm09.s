section .data
    hex_chars db "0123456789ABCDEF"
    newline db 10
    binary_flag db "-b"

section .bss
    buffer resb 32    ; Buffer for output

section .text
global _start

_start:
    ; Get argc
    pop rax         ; Get argc
    cmp rax, 2      ; Check if we have exactly 2 or 3 arguments
    je direct_hex   ; If 2 args, go to hex conversion
    cmp rax, 3      ; Check for 3 args (binary flag case)
    je check_flag
    jmp error       ; If not 2 or 3 args, error

check_flag:
    pop rax         ; Skip program name
    pop rdi         ; Get first argument
    mov rsi, binary_flag
    mov rcx, 2
    repe cmpsb      ; Compare with "-b"
    jne error
    pop rdi         ; Get number argument
    call atoi
    jmp convert_binary

direct_hex:
    pop rax         ; Skip program name
    pop rdi         ; Get number argument
    call atoi
    jmp convert_hex

convert_binary:
    mov rcx, 64     ; Counter for bits
    mov rbx, rax    ; Save number in rbx
    mov rdi, buffer ; Output buffer
    
binary_loop:
    mov rax, rbx
    shr rbx, 1      ; Shift right to get next bit
    and rax, 1      ; Check lowest bit
    add al, '0'     ; Convert to ASCII
    mov [rdi], al   ; Store in buffer
    inc rdi
    dec rcx
    jnz binary_loop
    
    ; Print result
    mov rax, 1      ; sys_write
    mov rdi, 1      ; stdout
    mov rsi, buffer ; buffer
    mov rdx, 64     ; length
    syscall
    
    ; Print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    
    jmp exit_success

convert_hex:
    mov rbx, rax    ; Save number in rbx
    mov rdi, buffer ; Output buffer
    mov rcx, 16     ; Process 16 hex digits
    
hex_loop:
    mov rax, rbx
    and rax, 0xF    ; Mask to get lowest 4 bits
    mov al, [hex_chars + rax] ; Get corresponding hex char
    mov [rdi], al   ; Store in buffer
    inc rdi
    shr rbx, 4      ; Shift right by 4 for next digit
    dec rcx
    jnz hex_loop
    
    ; Print result
    mov rax, 1      ; sys_write
    mov rdi, 1      ; stdout
    mov rsi, buffer ; buffer
    mov rdx, 16     ; length
    syscall
    
    ; Print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

exit_success:
    mov rax, 60     ; sys_exit
    xor rdi, rdi    ; return 0
    syscall

error:
    mov rax, 60     ; sys_exit
    mov rdi, 1      ; return 1
    syscall

; Function to convert string to integer (atoi)
atoi:
    xor rax, rax    ; Clear rax
atoi_loop:
    movzx rcx, byte [rdi] ; Get next character
    test rcx, rcx   ; Check for null terminator
    jz atoi_done
    sub rcx, '0'    ; Convert ASCII to number
    jb error        ; Jump if below 0
    cmp rcx, 9
    ja error        ; Jump if above 9
    imul rax, 10    ; Multiply current value by 10
    add rax, rcx    ; Add new digit
    inc rdi         ; Move to next character
    jmp atoi_loop
atoi_done:
    ret