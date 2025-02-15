section .data
    search_str: db "1337"       ; String to search for
    replace_str: db "H4CK"      ; String to replace with
    str_len: equ 4              ; Length of both strings

section .bss
    buffer: resb 4096           ; Buffer for reading file
    filesize: resq 1            ; File size storage

section .text
    global _start

_start:
    ; Check arguments
    pop rdi                     ; Get argc
    cmp rdi, 2                 ; Need exactly one argument
    jne exit_error

    ; Get filename
    pop rdi                     ; Skip program name
    pop rdi                     ; Get target filename

    ; Open file read-write
    mov rax, 2                 ; sys_open
    mov rsi, 2                 ; O_RDWR
    syscall

    ; Check if open successful
    cmp rax, 0
    jl exit_error
    mov r8, rax                ; Save file descriptor

read_loop:
    ; Read chunk of file
    mov rax, 0                 ; sys_read
    mov rdi, r8                ; file descriptor
    mov rsi, buffer            ; buffer
    mov rdx, 4096             ; chunk size
    syscall

    ; Check if read successful
    cmp rax, 0
    jle not_found              ; End of file or error

    ; Save read size
    mov r9, rax                ; Save bytes read

    ; Search for "1337" in buffer
    mov rcx, r9                ; Number of bytes to search
    mov rsi, buffer            ; Search in buffer
    mov rdi, search_str        ; Search for this string
    
search_byte:
    cmp rcx, str_len           ; Need at least 4 bytes left
    jl read_next_chunk

    ; Compare current position with search string
    push rcx
    push rsi
    mov rcx, str_len
    mov rdi, search_str
    repe cmpsb
    pop rsi
    pop rcx
    je found_string

    ; Move to next byte
    inc rsi
    dec rcx
    jmp search_byte

read_next_chunk:
    ; Move file pointer back by remaining bytes
    mov rax, 8                 ; sys_lseek
    mov rdi, r8                ; file descriptor
    mov rsi, rcx               ; bytes to move back
    neg rsi                    ; make it negative for moving back
    mov rdx, 1                 ; SEEK_CUR
    syscall
    
    jmp read_loop

found_string:
    ; Calculate position in file
    mov rax, 8                 ; sys_lseek
    mov rdi, r8                ; file descriptor
    mov rsi, -4                ; move back 4 bytes
    mov rdx, 1                 ; SEEK_CUR
    syscall

    ; Write replacement string
    mov rax, 1                 ; sys_write
    mov rdi, r8                ; file descriptor
    mov rsi, replace_str       ; replacement string
    mov rdx, str_len          ; length
    syscall

    ; Close file and exit successfully
    mov rdi, r8
    call close_file
    xor rdi, rdi              ; Exit code 0
    jmp exit

not_found:
    mov rdi, r8
    call close_file
    mov rdi, 1                ; Exit code 1

exit:
    mov rax, 60               ; sys_exit
    syscall

exit_error:
    mov rdi, 1
    mov rax, 60
    syscall

close_file:
    mov rax, 3                ; sys_close
    syscall
    ret