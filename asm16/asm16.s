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

    ; Open file in read-write mode
    mov rax, 2                ; sys_open
    mov rsi, 2                ; O_RDWR
    xor rdx, rdx              ; Mode (permissions - important to set)
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

    ; Compare with pattern
    mov rsi, buffer
    add rsi, rcx
    mov rdi, pattern

    ; Save important registers before comparison
    push rcx
    push r8
    push r9

    ; Set up for comparison
    mov rcx, len
    repe cmpsb

    ; Save flags
    pushf

    ; Restore registers
    pop rax  ; Flags into rax
    pop r9
    pop r8
    pop rcx

    ; Check if match found (ZF=1)
    and rax, 0x40  ; ZF is bit 6
    jnz found_pattern

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