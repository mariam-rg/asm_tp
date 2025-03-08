section .data
    pattern db "1337"         ; Pattern to search for
    replace db "H4CK"         ; Replacement string
    len equ 4                 ; Length of strings (without newline)

section .bss
    buffer resb 1024          ; Buffer for file content

section .text
    global _start

_start:
    ; Check arguments count
    pop rax                   ; Get argc
    cmp rax, 2                ; Need exactly one argument
    jne exit_error

    pop rax                   ; Skip program name
    pop rdi                   ; Get target filename

    ; Open file in read-only first to check if it's valid
    mov rax, 2                ; sys_open
    mov rsi, 0                ; O_RDONLY
    xor rdx, rdx              ; Mode (not needed for read-only)
    syscall

    ; Check if open successful
    cmp rax, 0
    jl exit_error

    ; Save file descriptor
    mov r8, rax

    ; Read some bytes to determine file type
    mov rax, 0                ; sys_read
    mov rdi, r8               ; file descriptor
    mov rsi, buffer           ; buffer
    mov rdx, 4                ; read first 4 bytes
    syscall

    ; Close this file descriptor
    mov rax, 3                ; sys_close
    mov rdi, r8
    syscall

    ; Check ELF magic number (first 4 bytes should be 0x7F, 'E', 'L', 'F')
    cmp byte [buffer], 0x7F
    jne regular_file
    cmp byte [buffer+1], 'E'
    jne regular_file
    cmp byte [buffer+2], 'L'
    jne regular_file
    cmp byte [buffer+3], 'F'
    jne regular_file

    ; It's an ELF file (executable), don't modify it
    jmp exit_error

regular_file:
    ; Reopen file in read-write mode
    pop rax                   ; Get argc again (restore stack)
    pop rax                   ; Skip program name
    pop rdi                   ; Get target filename again

    mov rax, 2                ; sys_open
    mov rsi, 2                ; O_RDWR
    xor rdx, rdx              ; Mode (permissions)
    syscall

    ; Check if open successful
    cmp rax, 0
    jl exit_error

    ; Save file descriptor
    mov r8, rax

read_loop:
    ; Read file content
    mov rax, 0                ; sys_read
    mov rdi, r8               ; file descriptor
    mov rsi, buffer           ; buffer
    mov rdx, 1024             ; read size
    syscall

    ; Check if read successful
    test rax, rax
    jle not_found

    ; Save number of bytes read
    mov r9, rax

    ; Search for pattern
    xor rcx, rcx              ; Initialize counter

search_loop:
    ; Check if we reached end of buffer
    cmp rcx, r9
    jge read_loop

    ; Check if we have enough bytes left for pattern
    mov rax, r9
    sub rax, rcx
    cmp rax, len
    jl next_byte  ; Not enough bytes left, move to next byte

    ; Compare with pattern
    mov rsi, 0
    
pattern_check:
    mov al, byte [buffer+rcx+rsi]
    cmp al, byte [pattern+rsi]
    jne next_byte
    inc rsi
    cmp rsi, len
    jl pattern_check
    
    ; If we get here, pattern found
    jmp found_pattern

next_byte:
    inc rcx
    jmp search_loop

found_pattern:
    ; Seek to found position
    mov rax, 8                ; sys_lseek
    mov rdi, r8               ; file descriptor
    mov rsi, rcx              ; offset
    xor rdx, rdx              ; SEEK_SET
    syscall

    ; Write replacement
    mov rax, 1                ; sys_write
    mov rdi, r8               ; file descriptor
    mov rsi, replace          ; replacement string
    mov rdx, len              ; length
    syscall

    ; Close file and exit successfully
    mov rax, 3                ; sys_close
    mov rdi, r8
    syscall

    xor rdi, rdi              ; Exit code 0
    jmp exit

not_found:
    ; Close file
    mov rax, 3                ; sys_close
    mov rdi, r8
    syscall

exit_error:
    mov rdi, 1                ; Exit code 1

exit:
    mov rax, 60               ; sys_exit
    syscall