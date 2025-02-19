section .data
    pattern db '1337', 10      ; Pattern to search for (including newline)
    replace db 'H4CK', 10      ; Replacement string (including newline)
    len equ 5                  ; Length of pattern/replace (including newline)

section .bss
    buffer resb 4096           ; Buffer for reading file content

section .text
    global _start

_start:
    ; Check if we have exactly one argument
    pop rcx                     ; Get argc
    cmp rcx, 2                 ; Should be 2 (program name + filepath)
    jne exit_error

    ; Get filepath
    pop rcx                     ; Skip program name
    pop rdi                     ; Get filepath

    ; Open file in read-write mode
    mov rax, 2                 ; sys_open
    mov rsi, 2                 ; O_RDWR
    syscall

    ; Check if open succeeded
    cmp rax, 0
    jl exit_error
    mov r8, rax                ; Save file descriptor

    ; Read file content
    mov rax, 0                 ; sys_read
    mov rdi, r8                ; file descriptor
    mov rsi, buffer            ; buffer
    mov rdx, 4096             ; buffer size
    syscall

    ; Check if read succeeded
    cmp rax, 0
    jle not_found

    ; Search for pattern
    mov rcx, rax               ; Number of bytes read
    mov rsi, buffer            ; Start of buffer
    xor rdx, rdx               ; Initialize counter

search_loop:
    cmp rdx, rcx               ; Check if we reached end of buffer
    jge not_found             ; Pattern not found

    ; Compare current position with pattern
    mov rdi, pattern           ; Pattern to compare
    push rcx
    push rsi
    mov rcx, len               ; Length of pattern
    repe cmpsb                ; Compare bytes
    pop rsi
    pop rcx
    je found_pattern

    inc rsi                    ; Move to next byte
    inc rdx
    jmp search_loop

found_pattern:
    ; Calculate position for writing
    sub rsi, len               ; Move back to start of pattern
    
    ; Seek to position
    mov rax, 8                 ; sys_lseek
    mov rdi, r8                ; file descriptor
    mov rsi, rdx               ; offset
    mov rdx, 0                 ; SEEK_SET
    syscall

    ; Write replacement
    mov rax, 1                 ; sys_write
    mov rdi, r8                ; file descriptor
    mov rsi, replace           ; replacement string
    mov rdx, len              ; length to write
    syscall

    ; Close file and exit successfully
    mov rdi, r8
    call close_file
    xor rdi, rdi              ; Exit with 0
    jmp exit

not_found:
    mov rdi, r8
    call close_file
    mov rdi, 1                ; Exit with 1
    jmp exit

exit_error:
    mov rdi, 1                ; Exit with 1

exit:
    mov rax, 60               ; sys_exit
    syscall

close_file:
    mov rax, 3                ; sys_close
    syscall
    ret