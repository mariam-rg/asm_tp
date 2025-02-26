section .data
    ; File path
    filepath db "/messages", 0

    ; Listening message
    listen_msg db "Listening on port 1337", 10
    listen_msg_len equ $ - listen_msg

    ; Socket constants
    AF_INET equ 2
    SOCK_DGRAM equ 2

    ; File constants
    O_WRONLY equ 1
    O_CREAT equ 64
    O_APPEND equ 1024
    S_IRUSR equ 00400q
    S_IWUSR equ 00200q

    ; Server socket address
    server_port dw 0x3905       ; port 1337 in network byte order (0x3905 = 0x0539 byte-swapped)

section .bss
    ; Buffer for received data
    recv_buffer resb 2048

    ; Socket address structure for server and client
    server_addr resb 16
    client_addr resb 16
    client_addr_len resd 1

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
    mov dword [server_addr+4], 0          ; sin_addr = INADDR_ANY (0.0.0.0)

    ; Bind socket to address and port
    mov rax, 49                ; sys_bind
    mov rdi, r12               ; sockfd
    mov rsi, server_addr       ; addr
    mov rdx, 16                ; addrlen
    syscall

    ; Check if bind was successful
    cmp rax, 0
    jl close_and_error

    ; Print listening message
    mov rax, 1                 ; sys_write
    mov rdi, 1                 ; stdout
    mov rsi, listen_msg        ; buf
    mov rdx, listen_msg_len    ; count
    syscall

    ; Set client address length
    mov dword [client_addr_len], 16

receive_loop:
    ; Receive message from client
    mov rax, 45                ; sys_recvfrom
    mov rdi, r12               ; sockfd
    mov rsi, recv_buffer       ; buf
    mov rdx, 2048              ; len
    xor r10, r10               ; flags
    mov r8, client_addr        ; src_addr
    mov r9, client_addr_len    ; addrlen
    syscall

    ; Check if receive was successful
    cmp rax, 0
    jle receive_loop

    ; Save bytes received
    mov r13, rax

    ; Open file for append
    mov rax, 2                 ; sys_open
    mov rdi, filepath          ; pathname
    mov rsi, O_WRONLY | O_CREAT | O_APPEND ; flags
    mov rdx, S_IRUSR | S_IWUSR ; mode (0600)
    syscall

    ; Check if file was opened successfully
    cmp rax, 0
    jl receive_loop

    ; Save file descriptor
    mov r14, rax

    ; Write message to file
    mov rax, 1                 ; sys_write
    mov rdi, r14               ; fd
    mov rsi, recv_buffer       ; buf
    mov rdx, r13               ; count
    syscall

    ; Write newline to file
    mov byte [recv_buffer], 10 ; newline character
    mov rax, 1                 ; sys_write
    mov rdi, r14               ; fd
    mov rsi, recv_buffer       ; buf
    mov rdx, 1                 ; count
    syscall

    ; Close file
    mov rax, 3                 ; sys_close
    mov rdi, r14               ; fd
    syscall

    ; Continue listening
    jmp receive_loop

close_and_error:
    ; Close socket
    mov rax, 3                 ; sys_close
    mov rdi, r12               ; fd
    syscall

exit_error:
    mov rdi, 1                 ; Exit code 1
    mov rax, 60                ; sys_exit
    syscall