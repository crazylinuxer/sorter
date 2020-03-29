extern malloc
extern realloc
extern free

global init
global delete
global delete_each
global append_value
global pop_value
global get_by_index
global shrink_to_fit
global get_size


INIT_LENGTH equ 32

struc dynamic
    .length resq 1    ;count of qword values
    .allocated resq 1 ;maximum qword values
    .data resq 0      ;offset of data
endstruc


segment .text
    mov rax, 60
    mov rbx, 0
    syscall

    init:
        ;generates array with length and allocated in first 2 items
        ;length does not include first 2 elements but the allocated_length does
        ;length is needed for counting items in the array
        push rbp
        mov rbp, rsp

        push INIT_LENGTH*8
        call malloc
        add rsp, 8

        mov qword [rax+dynamic.length], 0
        mov qword [rax+dynamic.allocated], INIT_LENGTH
        mov rsp, rbp
        pop rbp
        ret
    
    delete:
        push rbp
        mov rbp, rsp

        mov rdi, rcx
        call free
        xor rax, rax

        mov rsp, rbp
        pop rbp
        ret
    
    delete_each:
        ;param rcx - address of array
        push rbp
        mov rbp, rsp

        push rcx
        mov rcx, [rcx]
        cmp rcx, 0
        jz not_deleting
        
        deleting:
            mov rdi, rcx
            dec rdi
            shl rdi, 3
            add rdi, dynamic.data
            add rdi, qword [rcx]
            call free
        loop deleting
        not_deleting:

        pop rdi
        call free
        xor rax, rax
        
        mov rsp, rbp
        pop rbp
        ret
    
    check_space:
        ;returns new address if reallocates (or old one if does not)
        push rbp
        mov rbp, rsp

        mov r8, [rcx+dynamic.length]
        mov r9, [rcx+dynamic.allocated]
        mov rsi, r9
        sub r9, r8
        shl r9, 4
        cmp r9, rsi
        
        jg enough_space
            shl rsi, 1
            mov [rcx+dynamic.allocated], rsi
            shl rsi, 3
            mov rdi, rcx
            call realloc
            jmp exit_check_space
        enough_space:
            mov rax, rcx
        exit_check_space:

        mov rsp, rbp
        pop rbp
        ret
    
    append_value:
        ;returns new address if reallocates
        ;param rcx - address of array
        ;param rdx - value
        push rbp
        mov rbp, rsp

        call check_space
        mov r8, rax
        add r8, dynamic.data
        mov r9, [rax+dynamic.length]
        mov r10, r9
        inc r10
        mov [rax+dynamic.length], r10
        shl r9, 3
        add r8, r9
        mov [r8], rdx

        mov rsp, rbp
        pop rbp
        ret
    
    get_by_index:
        ;param rcx - address of array
        ;param rdx - index
        ;returns address of item
        mov rax, rdx
        shl rax, 3
        add rax, rcx
        add rax, dynamic.data
        ret
    
    pop_value:
        ;param rcx - address of array
        ;deletes last item and returns its value
        mov rdx, [rcx+dynamic.length]
        cmp rdx, 0
        jng nothing_to_pop
            dec rdx
            mov [rcx+dynamic.length], rdx
            call get_by_index
            mov rax, [rax]
            ret
        nothing_to_pop:
            mov rax, 0
            ret
    
    shrink_to_fit:
        ;param rcx - address of array
        ;returns address of reallocated array
        push rbp
        mov rbp, rsp

        mov rsi, [rcx+dynamic.length]
        add rsi, 2
        mov [rcx+dynamic.allocated], rsi
        shl rsi, 3
        mov rdi, rcx
        call realloc
        
        mov rsp, rbp
        pop rbp
        ret

    get_size:
        ;param rcx - address of array
        ;returns array size
        mov rax, [rcx+dynamic.length]
        ret
