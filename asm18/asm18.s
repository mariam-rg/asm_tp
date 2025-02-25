section .data
    ; UDP Server details
    server_ip dd 0x0100007F       ; 127.0.0.1 in network byte order
    server_port dw 0x3905         ; port 1337 in network byte order
    
    ; Message to send
    message db "Hello, server!", 0
    message_len equ $ - message
    
    ; Timeout message
    timeout_msg db "Timeout: no response from server", 10
    timeout_msg_len equ $ - timeout_msg
    
    ; Socket constants
    AF_INET equ 2
    SOCK_DGRAM equ 2
    SOL_SOCKET equ 1
    SO_RCVTIMEO equ 20
    
section .bss
    ; Buffer for received data
    recv_buffer resb 1024
    
    ; Socket address structure for server
    server_addr resb 16
    
    ; Timeout structure (timeval)
    timeout resb 16

section .text
    global _start

_start:
    ; Create UDP socket
    mov rax, 41          ; sys_socket
    mov rdi, AF_INET     ; Domain: IPv4
    mov rsi, SOCK_DGRAM  ; Type: UDP
    xor rdx, rdx         ; Protocol: 0 (default)
    syscall
    
    ; Check if socket creation was successful
    cmp rax, 0
    jl exit_error
    
    ; Save socket descriptor
    mov r12, rax
    
    ; Setup server address structure
    mov dword [server_addr], AF_INET      ; sa_family = AF_INET
    mov word [server_addr+2], [server_port] ; sin_port
    mov dword [server_addr+4], [server_ip]  ; sin_addr
    
    ; Setup timeout structure (1 second)
    mov qword [timeout], 1      ; 1 second
    mov qword [timeout+8], 0    ; 0 microseconds
    
    ; Set socket timeout option
    mov rax, 54                 ; sys_setsockopt
    mov rdi, r12                ; sockfd
    mov rsi, SOL_SOCKET         ; level
    mov rdx, SO_RCVTIMEO        ; optname
    mov r10, timeout            ; optval
    mov r8, 16                  ; optlen
    syscall
    
    ; Check if setting option was successful
    cmp rax, 0
    jl close_and_error
    
    ; Send message to server
    mov rax, 44                 ; sys_sendto
    mov rdi, r12                ; sockfd
    mov rsi, message            ; buf
    mov rdx, message_len        ; len
    xor r10, r10                ; flags
    mov r8, server_addr         ; dest_addr
    mov r9, 16                  ; addrlen
    syscall
    
    ; Check if send was successful
    cmp rax, 0
    jl close_and_error
    
    ; Receive response from server
    mov rax, 45                 ; sys_recvfrom
    mov rdi, r12                ; sockfd
    mov rsi, recv_buffer        ; buf
    mov rdx, 1024               ; len
    xor r10, r10                ; flags
    xor r8, r8                  ; src_addr (NULL)
    xor r9, r9                  ; addrlen (NULL)
    syscall
    
    ; Check if receive was successful
    cmp rax, 0
    jle handle_timeout
    
    ; Save bytes received
    mov r13, rax
    
    ; Print received message
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    mov rsi, recv_buffer        ; buf
    mov rdx, r13                ; count
    syscall
    
    ; Print newline
    mov byte [recv_buffer], 10  ; newline character
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    mov rsi, recv_buffer        ; buf
    mov rdx, 1                  ; count
    syscall
    
    ; Close socket and exit success
    mov rax, 3                  ; sys_close
    mov rdi, r12                ; fd
    syscall
    
    xor rdi, rdi                ; Exit code 0
    jmp exit
    
handle_timeout:
    ; Print timeout message
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    mov rsi, timeout_msg        ; buf
    mov rdx, timeout_msg_len    ; count
    syscall
    
close_and_error:
    ; Close socket
    mov rax, 3                  ; sys_close
    mov rdi, r12                ; fd
    syscall
    
exit_error:
    mov rdi, 1                  ; Exit code 1
    
exit:
    mov rax, 60                 ; sys_exit
    syscall