extern malloc

extern array_init
extern array_append_value
extern array_get_size
extern array_get_by_index
extern array_clear
extern array_delete
extern array_pop_value
extern array_to_usual

global ask_file
global ask_mode
global simple_print


segment .rodata
    mode_message db "Choose operation mode:", 10
                 db "    [1] - Fast mode (uses A LOT of memory)", 10
                 db "    [2] - Normal mode (uses less memory.. but still uses)", 10
                 db "    [3] - Slow mode (does not use any additional memory)", 10, 10, 0
    mode_message_len equ $-mode_message
    err_message  db "Incorrect input, try again!", 10, 0
    err_message_len equ $-err_message
    file_message db "Enter the file name: ", 0
    file_message_len equ $-file_message

segment .text
    ask_file:
        ;takes no arguments
        ;returns string entered from keyboard
        push rbp
        mov rbp, rsp
        
        call array_init
        push rax
        sub rsp, 16

        mov rax, 1
        mov rdi, 1
        mov rsi, file_message
        mov rdx, file_message_len
        syscall

        clear_and_input:
            mov rdi, [rbp-8]
            call array_clear
            input_char:
                xor eax, eax
                mov qword [rbp-16], 0
                mov rdi, 2
                mov rsi, rbp
                sub rsi, 16
                mov rdx, 8
                syscall
                mov rdi, [rbp-8]
                mov rsi, [rbp-16]
                call array_append_value
                mov rax, [rbp-16]
                mov rcx, 8
                checking_for_endl:
                    cmp al, 10
                    je input_char_end
                    shr rax, 8
                loop checking_for_endl
                jmp input_char
            input_char_end:
            mov rdi, [rbp-8]
            mov [rbp-24], rcx
            call array_get_size
            mov rcx, [rbp-24]
            mov [rbp-16], rax
            cmp rcx, 8
            jne end_input_error
            cmp rax, 1
            jng input_error
        
            jmp end_input_error
            input_error:
                mov rax, 1
                mov rdi, 0
                mov rsi, err_message
                mov rdx, err_message_len
                syscall
                jmp clear_and_input
            end_input_error:
        
        pop rcx
        neg rcx
        add rcx, 8
        shl rcx, 3
        mov ebx, 0FFh
        shl rbx, cl
        not rbx
        push rbx
        dec rax
        mov rsi, rax
        mov rdi, [rbp-8]
        call array_get_by_index
        mov rcx, [rax]
        pop rbx
        and rcx, rbx
        mov [rax], rcx

        mov rdi, [rbp-8]
        call array_to_usual

        leave
        ret

    ask_mode:
        ;asks user about sorter operationing mode
        ;returns int between 1 and 3 from input
        push rbp
        mov rbp, rsp

        mov rax, 1
        mov rdi, 1
        mov rsi, mode_message
        mov rdx, mode_message_len
        syscall
        
        read_mode:
            push 0
            xor rax, rax
            mov rdi, 2
            mov rsi, rsp
            mov rdx, 2
            syscall
            pop rax

            cmp al, 31h
            jl mode_input_error
            cmp al, 33h
            jg mode_input_error
            cmp ah, 0Ah
            jne mode_input_error
            
            jmp end_mode_input_error
            mode_input_error:
                cmp al, 0Ah
                je continue_mode_error
                cmp ah, 0Ah
                je continue_mode_error
                jmp read_mode

                continue_mode_error:
                mov rax, 1
                mov rdi, 0
                mov rsi, err_message
                mov rdx, err_message_len
                syscall
                jmp read_mode
            end_mode_input_error:

        sub al, 30h
        cbw

        leave
        ret
    
    simple_print:
        ;prints string from rdi
        ;...and does it really slow
        mov al, byte [rdi]
        cmp al, 0
        je exit_simple_print
            push rdi

            mov eax, 1
            mov rsi, rdi
            mov edi, 1
            mov edx, 1
            syscall
            
            pop rdi
            inc rdi
            jmp simple_print
        exit_simple_print:
        ret
