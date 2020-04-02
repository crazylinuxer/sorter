global try_open
global read_line
global is_eof

segment .text
    try_open:
        ;param rdi - pointer to filename
        push rbp
        mov rbp, rsp

        mov rsi, 0644o
        mov rax, 2
        xor rdx, rdx
        syscall
        
        leave
        ret
    
    read_line:
        push rbp
        mov rbp, rsp
        
        leave
        ret
    
    is_eof:
        push rbp
        mov rbp, rsp
        
        leave
        ret
