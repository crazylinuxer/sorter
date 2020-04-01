extern malloc

extern array_init
extern array_append_value
extern array_get_size
extern array_get_by_index
extern array_clear
extern array_delete
extern array_pop_value

global ask_file
global ask_mode


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
        push 0

        mov rax, 1
        mov rdi, 1
        mov rsi, file_message
        mov rdx, file_message_len
        syscall

        clear_and_input:
            mov rdi, [rsp+8]
            call array_clear
            input_char:
                xor rax, rax
                mov qword [rsp], 0
                mov rdi, 2
                mov rsi, rsp
                mov rdx, 8
                syscall
                mov rdi, [rsp+8]
                mov rsi, [rsp]
                call array_append_value
                mov rax, [rsp]
                mov rcx, 8
                checking_for_endl:
                    cmp al, 10
                    je input_char_end
                    shr rax, 8
                loop checking_for_endl
                jmp input_char
            input_char_end:
            mov rdi, [rsp+8]
            push rcx
            call array_get_size
            pop rcx
            mov [rsp], rax
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

        mov rdi, [rsp]
        inc rdi
        shl rdi, 3
        push rdi
        call malloc
        pop rdi
        pop rcx
        push rax
        add rax, rdi
        cmp rdi, 8
        jng one_time
            sub rax, 8
            mov qword [rax], 0
        one_time:
        sub rax, 8
        mov qword [rax], 0
        
        mov rdi, [rsp+8]
        xor rsi, rsi
        call array_get_by_index
        push rax
        mov rdi, [rsp+16]
        call array_get_size
        pop rsi
        mov rcx, rax
        mov rdi, [rsp]
        rep movsq
        
        mov rdi, [rsp+8]
        call array_delete
        pop rax

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
