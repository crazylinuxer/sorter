global main
global exit
global exit_normally

segment .text
    main:
        push rbp
        mov rbp, rsp

        xor rax, rax
        leave
        ret

    exit_normally:
        ;no parameters
        mov rdi, 0
        jmp exit

    exit:
        ;param rdi - exit code
        mov rax, 60
        syscall
