section .data
    output_msg db "The largest number is: ", 0
    newline db 0xa ; Newline character

section .bss
    result resb 10 ; Reserve space for the result string (adjust size as needed)

section .text
    global _start

_start:
    ; Check if three arguments are provided (including the program name)
    mov eax, [esp + 4] ; Number of arguments
    cmp eax, 4
    jne error_argc ; Jump to error if not 4 arguments

    ; Load the three numbers from the stack (arguments are strings)
    mov ebx, [esp + 8] ; Address of the first number string
    call string_to_int ; Convert the first string to integer in eax
    mov esi, eax ; Store the first number in esi

    mov ebx, [esp + 12] ; Address of the second number string
    call string_to_int ; Convert the second string to integer in eax
    cmp eax, esi ; Compare eax (second number) with esi (first number)
    jg second_is_larger ; Jump if second number is greater
    mov eax, esi ; Otherwise, keep the first number in eax

second_is_larger:
    mov edi, eax  ; Store the larger of the first two in edi

    mov ebx, [esp + 16] ; Address of the third number string
    call string_to_int ; Convert the third string to integer in eax
    cmp eax, edi ; Compare eax (third number) with edi (larger of first two)
    jg third_is_larger ; Jump if third number is greater
    mov eax, edi ; Otherwise, keep the larger of the first two in eax

third_is_larger:
    ; Convert the largest number (in eax) back to a string
    call int_to_string

    ; Display the message and the result
    mov eax, 4 ; sys_write
    mov ebx, 1 ; stdout
    mov ecx, output_msg
    mov edx, len output_msg
    int 80h

    mov eax, 4 ; sys_write
    mov ebx, 1 ; stdout
    mov ecx, result
    mov edx, eax ; Length of the result string (null-terminated by int_to_string)
    int 80h

    ; Exit program
    mov eax, 1 ; sys_exit
    xor ebx, ebx ; Exit code 0
    int 80h

error_argc:
    ; Handle incorrect number of arguments (optional)
    mov eax, 4
    mov ebx, 2
    mov ecx, error_msg
    mov edx, len error_msg
    int 80h

    mov eax, 1
    mov ebx, 1
    int 80h



; --- Subroutines ---

string_to_int: ; Converts a string to an integer (input: ebx = string address, output: eax = integer)
    push ebx
    push ecx
    push edx
    push esi

    xor eax, eax ; Initialize the result to 0
    mov esi, 10 ; Multiplier (10 for decimal conversion)

.loop:
    mov cl, byte [ebx] ; Get the current character
    cmp cl, 0 ; Check for null terminator
    je .end ; If null, exit the loop

    cmp cl, '0'
    jl .invalid_char
    cmp cl, '9'
    jg .invalid_char

    sub cl, '0' ; Convert char to digit
    mul esi ; Multiply the current result by 10
    add eax, ecx ; Add the digit to the result

    inc ebx ; Move to the next character
    jmp .loop

.invalid_char:
    mov eax, -1 ; Or handle the error as you wish.
    jmp .end

.end:
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

int_to_string: ; Converts an integer (eax) to a string (stored in 'result')
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov esi, result + 9 ; Point to the end of the 'result' buffer (adjust 9 if needed)
    mov byte [esi], 0 ; Null-terminate the string

    mov ebx, 10 ; Divisor (10 for decimal conversion)

.loop_it:
    xor edx, edx ; Clear edx for division
    div ebx ; Divide eax by 10. Remainder in edx, quotient in eax
    push dx ; Store the remainder (digit) on the stack

    test eax, eax ; Check if the quotient is zero
    jnz .loop_it ; If not zero, continue the loop

.loop_back:
    pop dx ; Retrieve the digit from the stack
    add dl, '0' ; Convert digit to ASCII
    mov [esi], dl ; Store the ASCII character
    dec esi ; Move to the next position

    test esp, esp ; Check if the stack is empty
    jnz .loop_back

    mov eax, result + 10 - esi ; Calculate the length of the string (including null)

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

section .data
    error_msg db "Incorrect number of arguments", 0
    len error_msg equ $-error_msg
    len output_msg equ $-output_msg