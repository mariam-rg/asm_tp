section .data
    newline db 10

section .bss
    buffer resb 32    ; Buffer for output string

section .text
global _start

_start:
    ; Check if we have exactly one argument
    pop rax         ; Get argc
    cmp rax, 2      ; We need exactly 2 arguments (program name + number)
    jne error

    ; Get the argument
    pop rax         ; Skip program name
    pop rdi         ; Get number argument
    call atoi       ; Convert string to integer
    
    ; Check if number is less than 0
    cmp rax, 0
    jl error
    
    ; Save the original number for later
    mov rbx, rax
    
    ; Calculate sum of numbers from 1 to n-1
    dec rax         ; Subtract 1 to get upper limit
    cmp rax, 0      ; Check if result is negative
    jl zero_result
    
    ; Calculate sum using: (n * (n + 1)) / 2
    mov rcx, rax    ; Save n
    inc rax         ; n + 1
    mul rcx         ; n * (n + 1)
    shr rax, 1      ; Divide by 2
    jmp print_result

zero_result:
    xor rax, rax    ; Return 0 for input of 0 or 1

print_result:
    ; Convert result to string
    mov rdi, buffer
    call itoa
    
    ; Print the result
    mov rax, 1      ; sys_write
    mov rdi, 1      ; stdout
    mov rsi, buffer
    mov rdx, rcx    ; Length of string (set by itoa)
    syscall
    
    ; Print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    
    jmp exit_success

; Function to convert string to integer (atoi)
atoi:
    xor rax, rax    ; Clear result
    xor rcx, rcx    ; Clear counter
atoi_loop:
    movzx rdx, byte [rdi + rcx] ; Get next character
    test dl, dl     ; Check for null terminator
    jz atoi_done
    cmp dl, '0'     ; Check if less than '0'
    jb error
    cmp dl, '9'     ; Check if greater than '9'
    ja error
    sub dl, '0'     ; Convert ASCII to number
    imul rax, 10    ; Multiply current value by 10
    add rax, rdx    ; Add new digit
    inc rcx         ; Move to next character
    jmp atoi_loop
atoi_done:
    test rcx, rcx   ; Check if we converted any digits
    jz error        ; If not, error
    ret

; Function to convert integer to string (itoa)
itoa:
    mov rsi, buffer     ; End of buffer
    add rsi, 31         ; Point to last character
    mov byte [rsi], 0   ; Null terminate
    mov rcx, 0          ; Character counter
    
    ; Handle 0 specially
    test rax, rax
    jnz itoa_loop
    dec rsi
    mov byte [rsi], '0'
    inc rcx
    jmp itoa_done

itoa_loop:
    test rax, rax
    jz itoa_done
    
    xor rdx, rdx
    mov rbx, 10
    div rbx             ; Divide by 10
    add dl, '0'         ; Convert remainder to ASCII
    dec rsi
    mov [rsi], dl
    inc rcx
    jmp itoa_loop

itoa_done:
    mov rdi, buffer     ; Start of buffer
    push rcx            ; Save length
    rep movsb           ; Move string to start of buffer
    pop rcx             ; Restore length
    ret

exit_success:
    mov rax, 60     ; sys_exit
    xor rdi, rdi    ; return 0
    syscall

error:
    mov rax, 60     ; sys_exit
    mov rdi, 1      ; return 1
    syscall