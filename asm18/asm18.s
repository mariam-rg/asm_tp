; asm18.asm - UDP client with timeout
; x86-64 NASM syntax program that sends a UDP request to 127.0.0.1:1337
; and waits for a response with a 1-second timeout

section .data
    ; Socket constants
    AF_INET     equ 2            ; IPv4 protocol
    SOCK_DGRAM  equ 2            ; UDP socket type
    IPPROTO_UDP equ 17           ; UDP protocol

    ; Server address details
    server_ip   dd 0x0100007f    ; 127.0.0.1 in network byte order
    server_port dw 0x3905        ; Port 1337 in network byte order

    ; Message to send
    msg         db "Hello, server!", 0
    msg_len     equ $ - msg

    ; Timeout value (1 second)
    timeout:
        tv_sec  dq 1             ; 1 second
        tv_usec dq 0             ; 0 microseconds

    ; Output messages
    resp_prefix db "message: \"", 0
    resp_prefix_len equ $ - resp_prefix
    resp_suffix db "\"", 10, 0   ; newline and null terminator
    resp_suffix_len equ $ - resp_suffix
    timeout_msg db "Timeout: no response from server", 10, 0
    timeout_msg_len equ $ - timeout_msg

section .bss
    ; Socket structures
    sock_addr:
        sin_family  resw 1       ; Address family (AF_INET)
        sin_port    resw 1       ; Port number
        sin_addr    resd 1       ; IP address
        sin_zero    resq 1       ; Padding
    
    sockfd      resd 1           ; Socket file descriptor
    
    ; Buffer for received message
    buf         resb 1024        ; 1KB buffer for response
    buf_len     equ 1024
    
    ; File descriptor set for select()
    fd_set      resq 16          ; Space for fd_set (128 bytes)

section .text
    global _start

_start:
    ; Create UDP socket
    mov rax, 41                 ; sys_socket
    mov rdi, AF_INET            ; Domain: IPv4
    mov rsi, SOCK_DGRAM         ; Type: UDP
    mov rdx, IPPROTO_UDP        ; Protocol: UDP
    syscall
    
    ; Check for errors
    test rax, rax
    js exit_error
    
    ; Save socket descriptor
    mov [sockfd], eax
    
    ; Initialize server address structure
    mov word [sock_addr + sin_family], AF_INET
    mov word [sock_addr + sin_port], [server_port]
    mov dword [sock_addr + sin_addr], [server_ip]
    
    ; Send message to server
    mov rax, 44                 ; sys_sendto
    mov rdi, [sockfd]           ; Socket descriptor
    mov rsi, msg                ; Message buffer
    mov rdx, msg_len            ; Message length
    mov r10, 0                  ; Flags (none)
    mov r8, sock_addr           ; Server address structure
    mov r9, 16                  ; Address length
    syscall
    
    ; Check for errors
    test rax, rax
    js exit_error
    
    ; Prepare for select() to wait with timeout
    ; Clear fd_set
    xor rax, rax
    mov rdi, fd_set
    mov rcx, 16
    rep stosq
    
    ; Add our socket to fd_set
    mov rdi, [sockfd]
    mov rax, rdi
    mov rdx, rdi
    shr rax, 6                  ; Divide by 64 to get qword index
    and rdx, 63                 ; Get bit position within qword
    mov rcx, 1
    shl rcx, rdx                ; Shift bit to correct position
    or [fd_set + rax*8], rcx    ; Set bit in fd_set
    
    ; Call select() to wait for response with timeout
    mov rax, 23                 ; sys_select
    mov rdi, [sockfd]           ; nfds (highest fd + 1)
    inc rdi
    mov rsi, fd_set             ; read fd_set
    xor rdx, rdx                ; write fd_set (NULL)
    xor r10, r10                ; exception fd_set (NULL)
    mov r8, timeout             ; timeout structure
    syscall
    
    ; Check select() result
    test rax, rax
    jz handle_timeout           ; If 0, timeout occurred
    js exit_error               ; If negative, error occurred
    
    ; Receive response
    mov rax, 45                 ; sys_recvfrom
    mov rdi, [sockfd]           ; Socket descriptor
    mov rsi, buf                ; Buffer for response
    mov rdx, buf_len            ; Buffer length
    xor r10, r10                ; Flags (none)
    xor r8, r8                  ; Source address (NULL)
    xor r9, r9                  ; Address length (NULL)
    syscall
    
    ; Check for errors
    test rax, rax
    js exit_error
    
    ; Null-terminate the response
    mov byte [buf + rax], 0
    
    ; Save response length
    mov r12, rax                ; Save received bytes count
    
    ; Print message prefix
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; STDOUT
    mov rsi, resp_prefix        ; Message prefix
    mov rdx, resp_prefix_len    ; Length
    syscall
    
    ; Print received message
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; STDOUT
    mov rsi, buf                ; Response buffer
    mov rdx, r12                ; Response length
    syscall
    
    ; Print message suffix
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; STDOUT
    mov rsi, resp_suffix        ; Message suffix
    mov rdx, resp_suffix_len    ; Length
    syscall
    
    ; Clean exit
    xor rdi, rdi                ; Return 0 (success)
    jmp exit

handle_timeout:
    ; Print timeout message
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; STDOUT
    mov rsi, timeout_msg        ; Timeout message
    mov rdx, timeout_msg_len    ; Length
    syscall

    ; Exit with error code 1
    mov rdi, 1                  ; Return 1 (timeout)
    jmp exit

exit_error:
    ; Exit with generic error code
    mov rdi, 2                  ; Return 2 (error)

exit:
    ; Close socket
    mov rax, 3                  ; sys_close
    mov rdi, [sockfd]           ; Socket descriptor
    syscall

    ; Exit program
    mov rax, 60                 ; sys_exit
    ; rdi already contains exit code
    syscall