extern malloc
extern free

extern readline
extern filemgr_try_open

global ask_file
global ask_mode
global simple_print


segment .rodata
    mode_message db "Choose operation mode:", 10
                 db "    [1] - Fast mode (uses A LOT of memory)", 10
                 db "    [2] - (NOT AVAILABLE YET) Normal mode (uses less memory.. but still uses some)", 10
                 db "    [3] - (NOT AVAILABLE YET) Slow mode (does not use any additional memory)", 10, 10, 0
    mode_message_len equ $-mode_message
    err_message  db "Incorrect input, try again!", 10, 0
    err_message_len equ $-err_message
    cannot_open_message  db "Can not open file, try again!", 10, 0
    cannot_open_message_len equ $-cannot_open_message
    file_message db "Enter the file name: ", 0
    file_message_len equ $-file_message

segment .text
    ask_file:
        ;takes no arguments
        ;returns string entered from keyboard
        ;tests posibility to open file
        push rbp
        mov rbp, rsp

        start_ask_file:
            call ask_filename
            push rax
            mov rdi, rax
            call filemgr_try_open
            cmp rax, 0
            jnl ask_file_ok
                pop rdi
                call free
                mov rax, 1
                xor edi, edi
                mov rsi, cannot_open_message
                mov rdx, cannot_open_message_len
                syscall
                jmp start_ask_file

        ask_file_ok:
        pop rax

        leave
        ret

    ask_filename:
        ;takes no arguments
        ;returns string entered from keyboard
        push rbp
        mov rbp, rsp

        entering:
            mov eax, 1
            mov edi, 1
            mov rsi, file_message
            mov edx, file_message_len
            syscall

            mov edi, 2 ;stdin
            call readline

            cmp rax, 0
            jne af_exit
                mov eax, 1
                xor edi, edi
                mov rsi, err_message
                mov edx, err_message_len
                syscall ;print error message to an stderr
                jmp entering

        af_exit:
        
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
            xor eax, eax
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
                xor edi, edi
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
        mov al, [rdi]
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
