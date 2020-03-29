segment .rodata
    start_message db "Choose operation mode:", 10
                  db "    [1] - Fast mode (uses A LOT of memory)", 10
                  db "    [2] - Normal mode (uses less memory.. but still uses)", 10
                  db "    [3] - Slow mode (does not use any additional memory)", 10, 10, 0

segment .text
global main
    main:
        push rbp
        mov rbp, rsp

        xor rax, rax
        leave
        ret
