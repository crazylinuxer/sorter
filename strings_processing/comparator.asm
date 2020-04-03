global compare_strings_sse

segment .text
    compare_strings_sse:
        ;param rdi - 1st string
        ;param rsi - 2nd strng
        ;compares strings by the alphabet
        ;NOTE: strings must be contained in fields of length that divisible by 16
        ;NOTE: also fields with strings should be aligned to 16
        ;returns 1 if 1st string is greater, -1 if it's less and 0 if they are equal
        ;well, it might work pretty fast...

        xor eax, eax ;will be a result
        xor r8, r8 ;stop flag

        mov r11w, di
        mov r12w, si
        and r11w, 1111b
        and r12w, 1111b

        mov r15, 0001020304050607h
        movq xmm4, r15
        shufpd xmm4, xmm4, 01b
        mov r15, 08090A0B0C0D0E0Fh
        pxor xmm5, xmm5
        movq xmm5, r15
        paddb xmm4, xmm5

        comparing:
            cmp r11w, 0
            jne not_aligned_1
                movdqa xmm0, [rdi]
                jmp continue_alignment_check
            not_aligned_1:
                movdqu xmm0, [rdi]
            continue_alignment_check:
            
            cmp r12w, 0
            jne not_aligned_2
                movdqa xmm1, [rsi]
                jmp end_alignment_check
            not_aligned_2:
                movdqu xmm1, [rsi]
            end_alignment_check:

            add rdi, 16
            add rsi, 16
            ;read xmmword from each string

            pshufb xmm0, xmm4
            pshufb xmm1, xmm4
            ;translated little-endian to big-endian

            movdqa xmm2, xmm0
            pxor xmm3, xmm3
            pcmpeqb xmm3, xmm0
            pmovmskb ecx, xmm3
            cmp cx, 0
            je continue_1
                inc r8
            continue_1:
            pxor xmm3, xmm3
            pcmpeqb xmm3, xmm1
            pmovmskb ecx, xmm3
            cmp cx, 0
            je continue_2
                inc r8
            continue_2:
            
            pcmpgtb xmm0, xmm1
            pmovmskb ecx, xmm0 ;mask of 1 and 2 strings comparsion
            pcmpgtb xmm1, xmm2
            pmovmskb ebx, xmm1 ;mask of 2 and 1 strings comparsion
            cmp ecx, ebx
            jg greater
            jl less
            jmp check_if_end
                
            greater:
                inc eax
                inc r8
                jmp check_if_end
            less:
                dec rax
                inc r8

            check_if_end:
            cmp r8, 0
            je comparing
        
        ret
