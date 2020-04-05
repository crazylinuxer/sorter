extern array_append_value
extern array_pop_value
extern array_get_by_index
extern array_get_size

global heap_get_min   ;returns min value of heap
global heap_get_count ;returns count of items in heap
global heap_append    ;appends value to the heap
global heap_pop       ;pops min value from the heap
;look function definition to see some details

;This min-heap is just basically a set of functions
;that wraps around the dynamic array structure.

;Some functions take parameter with function address.
;Requirwmwnts to that function:
;1. Takes first item in rdi and second in rsi
;2. Returns 0 if they are equal.
;3. Returns -1 if parameter in rdi is less than one in rsi.
;4. Returns 1 if parameter in rdi is greater than one in rsi.

segment .text
    heap_get_min:
        ;param rdi - address of heap
        ;returns min value of heap
        xor esi, esi
        call array_get_by_index
        mov rax, [rax]
        ret
    
    heap_get_count:
        ;param rdi - address of heap
        call array_get_size
        ret

    heap_append:
        ;param rdi - address of heap
        ;param rsi - address of function that compares values
        ;param rdx - value to append
        ;appends value to heap
        push rbp
        mov rbp, rsp

        leave
        ret
    
    heap_pop:
        ;param rdi - address of heap
        ;param rsi - address of function that compares values
        ;deletes and returns min value of heap
        push rbp
        mov rbp, rsp

        leave
        ret
    
    flow_up:
        ;param rdi - address of heap
        ;param rsi - address of function that compares values
        ;param rdx - index of item to flow
        push rbp
        mov rbp, rsp

        leave
        ret
    
    flow_down:
        ;param rdi - address of heap
        ;param rsi - address of function that compares values
        ;param rdx - index of item to flow
        push rbp
        mov rbp, rsp

        leave
        ret
    
    get_parent:
        ;param rdi - address of heap
        ;param rsi - index of element
        ;returns index of parent item of one in rsi or -1 if it does not exist
        push rbp
        mov rbp, rsp

        push rsi
        call array_get_size
        xor ebx, ebx
        cmp rax, rbx
        jg parent_normal
        parent_not_nornal:
            xor eax, eax
            dec rax
            leave
            ret
        parent_normal:
        pop rax
        cmp rax, rbx
        jng parent_not_nornal
        dec rax
        shr rax, 1

        leave
        ret
    
    get_left:
        ;param rdi - address of heap
        ;param rsi - index of element
        ;returns index of item in left of one in rsi or -1 if it does not exist
        mov edx, 1
        call left_right_common
        ret
    
    get_right:
        ;param rdi - address of heap
        ;param rsi - index of element
        ;returns index of item in right of one in rsi or -1 if it does not exist
        mov edx, 2
        call left_right_common
        ret
    
    left_right_common:
        ;param rdi - address of heap
        ;param rsi - index of element
        ;param rdx - will be added to rsi
        push rbp
        mov rbp, rsp

        shl rsi, 1
        add rsi, rdx
        push rsi
        call array_get_size
        pop rsi
        dec rax
        cmp rsi, rax
        jg lrc_error
        cmp rsi, 0
        jl lrc_error
        jmp lrc_normal
        lrc_error:
            xor eax, eax
            dec rax
            leave
            ret
        lrc_normal:
        mov rax, rsi

        leave
        ret