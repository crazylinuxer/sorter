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

        xor rax, rax ;will be a result
        xor r8, r8 ;stop flag

        mov r11w, di
        mov r12w, si
        and r11w, 1111b
        and r12w, 1111b

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

            mov r15, 0001020304050607h
            movq xmm3, r15
            shufpd xmm3, xmm3, 00b
            mov r15, 08090A0B0C0D0E0Fh
            movq xmm3, r15
            pshufb xmm0, xmm3
            pshufb xmm1, xmm3
            ;translated little-endian to big-endian

            movdqa xmm2, xmm0
            pxor xmm3, xmm3
            pcmpeqb xmm3, xmm0
            pmovmskb eax, xmm3
            cmp ax, 0
            je continue_1
                inc r8
            continue_1:
            pxor xmm3, xmm3
            pcmpeqb xmm3, xmm1
            pmovmskb eax, xmm3
            cmp ax, 0
            je continue_2
                inc r8
            continue_2:
            
            pcmpgtb xmm0, xmm1
            pmovmskb eax, xmm0 ;mask of 1 and 2 strings substraction
            pcmpgtb xmm1, xmm2
            pmovmskb ebx, xmm1 ;mask of 2 and 1 strings substraction
            cmp ax, bx
            jg greater
            jl less
            jmp check_if_end
                
            greater:
                dec rax
                inc r8
                jmp check_if_end
            less:
                inc rax
                inc r8

            check_if_end:
            cmp r8, 0
            je comparing
        
        ret
