extern posix_memalign
extern realloc

extern array_append_value
extern array_get_by_index
extern array_get_size

global filemgr_try_open
global filemgr_close
global filemgr_block_to_buffer
global filemgr_buffer_to_block

segment .text
    filemgr_try_open:
        ;param rdi - pointer to filename
        ;opens file, reads some shit, closes file back and returns descriptor
        ;if rax < 0 it means that the file could not be opened
        push rbp
        mov rbp, rsp

        mov rsi, 0644o
        mov rax, 2
        xor edx, edx
        syscall

        cmp rax, 0
        jng did_not_open
            push rax
            sub rsp, 8
            mov rdi, rax
            xor eax, eax
            mov rdx, 8
            mov rsi, rsp
            syscall
            add rsp, 8
            cmp rax, 0
            jnl try_open_success
                push rax
            try_open_success:
            mov rdi, rax
            mov rax, 3
            syscall
            pop rax
        did_not_open:

        leave
        ret
    
    filemgr_close:
        push rbp
        mov rbp, rsp
        
        leave
        ret
    
    filemgr_block_to_buffer:
        ;rdi - address of block
        ;rsi - pointer to address of dynamic array (buffer) (like array** in C)
        ;rdx - (bool) append 1st string from block to last one in buffer
        ;rcx - block length
        ;returns 1 if last string needs to be appended next time
        push rbp
        mov rbp, rsp

        push rdi ;[rbp-8] - block
        push rsi ;[rbp-16] - buffer
        push rdx ;[rbp-24] - append
        push rcx ;[rbp-32] - length
        push 1   ;[rbp-40] - first time flag
        push 0   ;[rbp-48] - result
        splitting:
            push rcx ;[rbp-56] - main iterator
            
            mov rdi, [rbp-8]
            mov rcx, [rbp-32]
            mov bl, [rdi]
            cmp bl, 0
            jne continue_splitting_1
                mov bh, [rdi-1]
                cmp bh, 0Ah
                je eol_detected
                    mov qword [rbp-48], 1
                    mov qword [rbp-56], 1
                    jmp skip_appending
                eol_detected:
                    mov qword [rbp-48], 0
                    mov qword [rbp-56], 1
                    jmp skip_appending
            continue_splitting_1:
            cmp bl, 0Ah
            jne continue_splitting_2
                push 1
                jmp skip_appending
            continue_splitting_2:
            mov al, 0Ah
            repne scasb
            cmp rcx, 0
            jg not_end
                mov qword [rbp-56], 1
                mov r8b, [rdi]
                cmp r8b, 0Ah
                je not_end
                    mov rdx, [rbp-40]
                    cmp rdx, 1
                    jne not_end
                        mov qword [rbp-48], 1
            not_end:
            sub rcx, [rbp-32]
            neg rcx
            push rcx ;[rbp-64] - length of current string
            inc rcx
            mov rdx, [rbp-40]
            cmp rdx, 1
            jne not_try_to_add
                mov rdx, [rbp-24]
                cmp rdx, 1
                jne not_try_to_add
                    mov rdi, [rbp-16]
                    mov rdi, [rdi]
                    call array_get_size
                    mov rsi, rax
                    dec rsi
                    mov rdi, [rbp-16]
                    mov rdi, [rdi]
                    call array_get_by_index
                    cmp rax, 0
                    je not_try_to_add
                        mov rdi, [rax]
                        push rax ;[rbp-72] - place to save new address to
                        push rdi ;[rbp-80] - old string address
                        xor ecx, ecx
                        dec ecx
                        shr rcx, 1
                        xor eax, eax
                        mov rbx, [rdi]
                        repne scasb
                        mov rsi, rdi
                        pop r8
                        sub rsi, r8
                        push rsi ;[rbp-80] - length of old
                        mov rdi, r8
                        add rsi, [rbp-64]
                        inc rsi
                        call realloc
                        pop rdi ;freed [rbp-80]
                        add rdi, rax
                        pop r8  ;freed [rbp-72]
                        mov [r8], rax
                        mov rsi, [rbp-8]
                        mov rcx, [rbp-64]
                        cmp rcx, 0
                        jng skip_appending
                            dec rdi
                            rep movsb
                            dec rdi
                            mov al, [rdi]
                            cmp al, 0Ah
                            je add_newline_exists
                                mov qword [rbp-48], 1
                            add_newline_exists:
                            mov byte [rdi+1], 0
                    jmp skip_appending
            not_try_to_add:
                mov rdx, [rbp-64]
                shr rdx, 4
                inc rdx
                shl rdx, 4
                push 0
                mov rdi, rsp
                mov rsi, 16
                call posix_memalign
                pop rax
                cmp rax, 0
                je skip_appending
                    push rax ;[rbp-72] - new string address
                    mov rsi, rax
                    mov rdi, [rbp-16]
                    mov rdi, [rdi]
                    call array_append_value
                    mov rdi, [rbp-16]
                    mov [rdi], rax
                    pop rdi
                    mov rsi, [rbp-8]
                    mov rcx, [rbp-64]
                    rep movsb
                    dec rdi
                    mov al, [rdi]
                    cmp al, 0Ah
                    je append_newline_exists
                        mov qword [rbp-48], 1
                    append_newline_exists:
                    mov byte [rdi+1], 0
            skip_appending:

            mov qword [rbp-40], 0
            mov rsi, [rbp-8]
            mov rdi, [rbp-32]
            pop r8
            sub rdi, r8
            jg continue
                mov qword [rbp-56], 1
            continue:
            add rsi, r8
            mov [rbp-32], rdi
            mov [rbp-8], rsi
            pop rcx
            
            dec rcx
            jg splitting ;loop far

        mov rax, [rbp-48]
        
        leave
        ret
    
    filemgr_buffer_to_block:
        push rbp
        mov rbp, rsp
        
        leave
        ret
