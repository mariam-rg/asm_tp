section .data
    pattern: db "1337"         ; Pattern to search for
    replace: db "H4CK"         ; Replacement string
    len: equ 4                 ; Length of strings

section .bss
    buffer: resb 4096          ; Buffer for file content (increase for safety)

section .text
    global _start

_start:
    ; Check argument count
    pop rax                     ; Get argc
    cmp rax, 2                   ; Need exactly one argument
    jne exit_error

    pop rax                      ; Skip program name
    pop rdi                      ; Get target filename

    ; Open file in read-write mode
    mov rax, 2                   ; sys_open
    mov rsi, 2                   ; O_RDWR
    mov rdx, 0                   ; No special permissions needed
    syscall

    ; Check if file opened successfully
    cmp rax, 0
    jl exit_error

    ; Save file descriptor
    mov r8, rax

read_loop:
    ; Read file content
    mov rax, 0                   ; sys_read
    mov rdi, r8                   ; file descriptor
    mov rsi, buffer               ; buffer
    mov rdx, 4096                 ; Read max buffer size
    syscall

    ; Check if read was successful
    test rax, rax
    jle not_found

    ; Save number of bytes read
    mov r9, rax

    ; Search for pattern
    xor rcx, rcx                  ; Initialize counter

search_loop:
    cmp rcx, r9                    ; Check if end of buffer
    jge not_found

    ; Compare 4 bytes (pattern)
    lea rsi, [buffer + rcx]       ; Point to current position in buffer
    lea rdi, [pattern]            ; Point to search pattern
    mov rdx, len                  ; Compare 4 bytes
    repe cmpsb
    je found_pattern               ; If found, jump to replacement logic

    inc rcx                       ; Move to next byte
    jmp search_loop

found_pattern:
    ; Seek to found position in file
    mov rax, 8                     ; sys_lseek
    mov rdi, r8                     ; file descriptor
    mov rsi, rcx                    ; offset position
    xor rdx, rdx                    ; SEEK_SET (absolute position)
    syscall

    ; Write replacement text
    mov rax, 1                     ; sys_write
    mov rdi, r8                     ; file descriptor
    mov rsi, replace                ; replacement string
    mov rdx, len                    ; length of replacement text
    syscall

    ; Ensure proper file closing
    jmp close_file

not_found:
    ; Close file if not found
    jmp close_file

exit_error:
    mov rdi, 1                      ; Exit code 1 (error)
    jmp exit

close_file:
    mov rax, 3                      ; sys_close
    mov rdi, r8                      ; file descriptor
    syscall

    xor rdi, rdi                     ; Exit code 0 (success)
    jmp exit

exit:
    mov rax, 60                     ; sys_exit
    syscall
