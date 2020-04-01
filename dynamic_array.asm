extern malloc
extern realloc
extern free

global array_init
global array_delete
global array_delete_each
global array_append_value
global array_pop_value
global array_get_by_index
global array_shrink_to_fit
global array_get_size
global array_extend
global array_extend_from_mem
global array_clear


INIT_LENGTH equ 4

struc dynamic
    ;structure of dynamic array
    .length resq 1    ;count of qword values
    .allocated resq 1 ;maximum qword values
    .data resq 0      ;offset of data (it is of course not zero, but some varying number)
endstruc


segment .text

    array_init:
        ;generates array with 'length' and 'allocated' in first 2 items
        ;'length' does not include first 2 elements but the 'allocated' does
        ;'length' is needed for counting items in the array
        ;(look for "struc dynamic" in this file to understand better)
        push rbp
        mov rbp, rsp

        mov rdi, INIT_LENGTH*8
        call malloc
        mov qword [rax+dynamic.length], 0
        mov qword [rax+dynamic.allocated], INIT_LENGTH

        leave
        ret
    
    array_delete:
        ;param rdi - address of array
        push rbp
        mov rbp, rsp

        call free
        xor rax, rax

        leave
        ret
    
    array_delete_each:
        ;param rdi - address of array
        push rbp
        mov rbp, rsp

        push rdi
        mov rcx, [rdi+dynamic.length]
        cmp rcx, 0
        jz not_deleting
        
        deleting:
            mov rdi, rcx
            dec rdi
            shl rdi, 3
            add rdi, dynamic.data
            add rdi, [rsp]
            push rcx
            call free
            pop rcx
        loop deleting
        not_deleting:

        pop rdi
        call free
        xor rax, rax
        
        leave
        ret
    
    array_check_space:
        ;param rdi - address of array
        ;returns new address if reallocates (or old one if does not)
        push rbp
        mov rbp, rsp

        mov r8, [rdi+dynamic.length]
        mov r9, [rdi+dynamic.allocated]
        mov rsi, r9
        sub r9, 2
        sub r9, r8
        shl r9, 4
        cmp r9, rsi
        
        jg enough_space
            shl rsi, 1
            mov [rdi+dynamic.allocated], rsi
            shl rsi, 3
            call realloc
            jmp exit_check_space
        enough_space:
            mov rax, rdi
        exit_check_space:

        leave
        ret
    
    array_append_value:
        ;returns new address if reallocates
        ;param rdi - address of array
        ;param rsi - value
        push rbp
        mov rbp, rsp

        push rsi
        call array_check_space
        pop rsi
        mov r8, rax
        add r8, dynamic.data
        mov r9, [rax+dynamic.length]
        mov r10, r9
        inc r10
        mov [rax+dynamic.length], r10
        shl r9, 3
        add r8, r9
        mov [r8], rsi

        leave
        ret
    
    array_get_by_index:
        ;param rdi - address of array
        ;param rsi - index
        ;returns address of item
        mov rax, rsi
        shl rax, 3
        add rax, rdi
        add rax, dynamic.data
        ret
    
    array_pop_value:
        ;param rdi - address of array
        ;deletes last item and returns its value
        mov rdx, [rdi+dynamic.length]
        cmp rdx, 0
        jng nothing_to_pop
            dec rdx
            mov [rdi+dynamic.length], rdx
            mov rsi, rdx
            call array_get_by_index
            mov rax, [rax]
            ret
        nothing_to_pop:
            mov rax, 0
            ret
    
    array_shrink_to_fit:
        ;param rdi - address of array
        ;returns address of reallocated array
        push rbp
        mov rbp, rsp

        mov rsi, [rdi+dynamic.length]
        add rsi, 2
        mov [rdi+dynamic.allocated], rsi
        shl rsi, 3
        call realloc
        
        leave
        ret

    array_get_size:
        ;param rdi - address of array
        ;returns array size
        mov rax, [rdi+dynamic.length]
        ret
    
    array_extend:
        ;param rdi - address of array
        ;param rsi - address of other array
        ;returns address of array
        push rbp
        mov rbp, rsp

        mov rdx, [rsi+dynamic.length]
        add rsi, dynamic.data
        call array_extend_from_mem
       
        leave
        ret

    array_extend_from_mem:
        ;param rdi - address of array
        ;param rsi - address from where to copy
        ;param rdx - count of qwords to copy
        ;returns address of array
        push rbp
        mov rbp, rsp

        cmp rdx, 0
        jng not_extending

        mov rcx, rdx
        push rsi
        push rdi
        push rcx
        mov rsi, rdx
        add rsi, [rdi+dynamic.allocated]
        call realloc
        pop rcx
        pop rdi
        pop rsi
        push rax

        mov r8, [rdi+dynamic.length]
        mov r9, r8
        add r8, rcx
        mov [rdi+dynamic.length], r8

        add rdi, r9
        add rdi, dynamic.data
        rep movsq
        pop rax
        jmp exit_extend

        not_extending:
            mov rax, rdi
        exit_extend:
        leave
        ret

    array_clear:
        ;param rdi - address of array
        mov qword [rdi+dynamic.length], 0
        ret
