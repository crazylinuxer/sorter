extern free

extern array_init
extern array_clear
extern array_append_value
extern array_get_by_index
extern array_get_size
extern array_to_usual


global readline


segment .data
    readline:
        ;rdi - descriptor (from where to read)
        ;returns string (allocates memory for it in heap)
        push rbp
        mov rbp, rsp
        
        push rdi ;[rbp-8] - descriptor
        call array_init
        push rax ;[rbp-16] - array that has been created
        sub rsp, 16 ;[rbp-24] and [rbp-32] - allocated for the future

        mov rdi, rax
        call array_clear
        input_char:

            xor eax, eax
            mov qword [rbp-24], 0 ;zeroed 8-byte buffer to write symbols in it
            mov rdi, [rbp-8]
            lea rsi, [rbp-24]
            mov rdx, 8
            syscall ;read 8 bytes of data
            
            mov rdi, [rbp-16]
            mov rsi, [rbp-24]
            call array_append_value ;writing data to an array
            mov rax, [rbp-24] ;put data into rax to check
            mov rcx, 8 ;max symbols in rax

            checking_for_endl:
                cmp al, 10 ;checking for endline
                je input_char_end
                shr rax, 8
            loop checking_for_endl
            
            jmp input_char ;repeat until read all input
        input_char_end:

        mov rdi, [rbp-16]
        mov [rbp-32], rcx ;saving counter that left from checking_for_endl
        call array_get_size
        mov rcx, [rbp-32]
        mov [rbp-24], rax ;saved array size
        cmp rcx, 8
        jne end_input_error ;first symbol in 8-byte sequence was not an endline
        cmp rax, 1
        jng input_error ;this endline was in the first 8-byte sequence
    
        jmp end_input_error
        input_error:
            mov rdi, [rbp-16]
            call free
            xor eax, eax
            leave
            ret
        end_input_error:
        
        pop rcx ;deleted [rbp-32]
        neg rcx
        add rcx, 8
        shl rcx, 3
        mov r8d, 0FFh
        shl r8, cl
        not r8
        push r8
        dec rax ;array size is in rax now
        mov rsi, rax
        mov rdi, [rbp-16]
        call array_get_by_index
        mov rcx, [rax]
        pop r8
        and rcx, r8
        mov [rax], rcx ;deleted endline (?)

        mov rdi, [rbp-16]
        call array_to_usual

        leave
        ret
