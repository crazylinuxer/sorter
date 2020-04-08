segment .text
    search_byte_sse:
        ;param rdi - string
        ;param rsi - symbol to search

        mov r11w, di
        and r11w, 1111b
        xor r8, r8 ;stop flag

        mov r12d, 0A0A0A0Ah
        mov xmm1, r12d
        movdqa xmm2, xmm1
        shufps xmm2, xmm1, 0
        ;xmm2 contains 0A0A...0Ah

        mov r15, 0001020304050607h
        movq xmm6, r15
        shufpd xmm6, xmm6, 01b
        mov r15, 08090A0B0C0D0E0Fh
        pxor xmm7, xmm7
        movq xmm7, r15
        paddb xmm6, xmm7
        ;xmm6 contains 0F0E...00h

        pxor xmm7, xmm7
        ;xmm7 contains zeroes

        searching:
            cmp r11w, 0
            jne not_aligned_1
                movdqa xmm0, [rdi]
                jmp continue_alignment_check
            not_aligned_1:
                movdqu xmm0, [rdi]
            continue_alignment_check:
            add rdi, 16
            pshufb xmm0, xmm3
            ;translated little-endian to big-endian

            movdqa xmm1, xmm0
            ;not finished.....

        ret
