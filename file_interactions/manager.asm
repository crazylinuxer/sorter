extern array_append_value

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
        push rbp
        mov rbp, rsp
        
        leave
        ret
    
    filemgr_buffer_to_block:
        push rbp
        mov rbp, rsp
        
        leave
        ret
