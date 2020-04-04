extern malloc
extern free

extern array_init
extern array_append_value
extern array_get_by_index
extern array_get_size

global deque_init              ;initializes empty deque structure
global deque_delete            ;deletes deque structure
global deque_delete_each       ;frees memory using each item as pointer and then deletes deque itself
global deque_push_right        ;appends value to the end of deque
global deque_push_left         ;appends value to the start of deque
global deque_pop_right         ;deletes and returns value from the end of deque
global deque_pop_left          ;deletes and returns value from the start of deque
global deque_get_length        ;returns length of stack in O(1) time
global deque_get_left          ;returns value from the start of deque
global deque_get_right         ;returns value from the end of deque
global deque_to_array          ;creates dynamic array basing on deque contents in O(n)
global deque_extend_from_array ;extends deque from array
global deque_merge             ;merges two deques to one in O(1), deletes second of them
;look function definition to see some details

struc deque_node
    ;node of list-like deque
    ;each field is zero by default
    .data resq 1
    .next resq 1
    .prev resq 1
endstruc

struc deque
    ;list-like deque
    ;each field is zero by default
    .first resq 1
    .last  resq 1
    .len   resq 1
endstruc

DEQUE_NODE_SIZE equ 24
DEQUE_SIZE      equ 24


segment .text
    create_node:
        ;initializes and returns ptr to deque node
        push rbp
        mov rbp, rsp

        mov rdi, DEQUE_NODE_SIZE
        call malloc
        mov ecx, 3
        mov r8, rax
        mov rdi, rax
        xor rax, rax
        rep stosq
        mov rax, r8

        leave
        ret

    deque_init:
        ;initializes and returns ptr to empty deque structure
        push rbp
        mov rbp, rsp

        mov rdi, DEQUE_SIZE
        call malloc
        mov ecx, 3
        mov r8, rax
        mov rdi, rax
        xor eax, eax
        rep stosq
        mov rax, r8

        leave
        ret

    deque_delete:
        ;param rdi - address of deque
        ;deletes deque and all its nodes
        push rbp
        mov rbp, rsp

        mov rcx, [rdi+deque.len]
        cmp rcx, 0
        je end_deleting
        deleting_nodes:
            push rdi
            call deque_pop_right
            pop rdi
            loop deleting_nodes
        end_deleting:
        call free
        xor eax, eax

        leave
        ret
    
    deque_delete_each:
        ;param rdi - address of deque
        ;deletes deque and all its nodes
        ;frees memory using each item as pointer
        push rbp
        mov rbp, rsp

        mov rcx, [rdi+deque.len]
        cmp rcx, 0
        je end_deleting_each
        deleting_each_node:
            push rdi
            call deque_pop_right
            mov rdi, rax
            call free
            pop rdi
            loop deleting_each_node
        end_deleting_each:
        call free
        xor eax, eax

        leave
        ret

    deque_push_right:
        ;param rdi - address of deque
        ;param rsi - value to append
        ;appends value to the end of deque
        ;returns count of items in deque
        push rbp
        mov rbp, rsp

        push rdi
        push rsi
        call create_node
        pop qword [rax+deque_node.data]
        pop rdi
        mov r8, [rdi+deque.last]
        cmp r8, 0
        je right_empty
            mov [r8+deque_node.next], rax
            mov [rax+deque_node.prev], r8
            mov [rdi+deque.last], rax
            jmp end_pushing_right
        right_empty:
            mov [rdi+deque.last], rax
            mov [rdi+deque.first], rax
        end_pushing_right:
        mov rax, [rdi+deque.len]
        inc rax
        mov [rdi+deque.len], rax

        leave
        ret

    deque_push_left:
        ;param rdi - address of deque
        ;param rsi - value to append
        ;appends value to the start of deque
        ;returns count of items in deque
        push rbp
        mov rbp, rsp

        push rdi
        push rsi
        call create_node
        pop qword [rax+deque_node.data]
        pop rdi
        mov r8, [rdi+deque.first]
        cmp r8, 0
        je left_empty
            mov [r8+deque_node.prev], rax
            mov [rax+deque_node.next], r8
            mov [rdi+deque.first], rax
            jmp end_pushing_left
        left_empty:
            mov [rdi+deque.last], rax
            mov [rdi+deque.first], rax
        end_pushing_left:
        mov rax, [rdi+deque.len]
        inc rax
        mov [rdi+deque.len], rax

        leave
        ret

    deque_pop_right:
        ;param rdi - address of deque
        ;pops and returns value from the end of deque
        push rbp
        mov rbp, rsp

        mov rax, [rdi+deque.last]
        cmp rax, 0
        je end_right_pop
            cmp rax, [rdi+deque.first]
            jne not_one_right
                mov qword [rdi+deque.first], 0
                push qword [rax+deque_node.data]
                mov qword [rdi+deque.last], 0
                jmp end_not_one_right
            not_one_right:
                mov r8, [rax+deque_node.prev]
                mov qword [r8+deque_node.next], 0
                push qword [rax+deque_node.data]
                mov [rdi+deque.last], r8
            end_not_one_right:
            push rdi
            mov rdi, rax
            call free
            pop rdi
            mov rax, [rdi+deque.len]
            dec rax
            mov [rdi+deque.len], rax
            pop rax
        end_right_pop:

        leave
        ret

    deque_pop_left:
        ;param rdi - address of deque
        ;pops and returns value from the start of deque
        push rbp
        mov rbp, rsp

        mov rax, [rdi+deque.first]
        cmp rax, 0
        je end_left_pop
            cmp rax, [rdi+deque.last]
            jne not_one_left
                mov qword [rdi+deque.last], 0
                push qword [rax+deque_node.data]
                mov qword [rdi+deque.first], 0
                jmp end_not_one_left
            not_one_left:
                mov r8, [rax+deque_node.next]
                mov qword [r8+deque_node.prev], 0
                push qword [rax+deque_node.data]
                mov [rdi+deque.first], r8
            end_not_one_left:
            push rdi
            mov rdi, rax
            call free
            pop rdi
            mov rax, [rdi+deque.len]
            dec rax
            mov [rdi+deque.len], rax
            pop rax
        end_left_pop:

        leave
        ret

    deque_get_length:
        ;param rdi - address of deque
        ;returns count of items in deque
        mov rax, [rdi+deque.len]
        ret

    deque_get_left:
        ;param rdi - address of deque
        ;returns value of the first item in deque
        mov rax, [rdi+deque.first]
        mov rax, [rax+deque_node.data]
        ret

    deque_get_right:
        ;param rdi - address of deque
        ;returns value of the last item in deque
        mov rax, [rdi+deque.last]
        mov rax, [rax+deque_node.data]
        ret
    
    deque_to_array:
        ;param rdi - address of deque
        ;returns pointer to newly created array
        push rbp
        mov rbp, rsp

        push rdi
        call array_init
        push rax
        mov rdi, [rbp-8]
        mov rbx, [rdi+deque.first]

        appending:
            cmp rbx, 0
            je end_appending
            mov rdi, [rbp-16]
            mov rsi, [rbx+deque_node.data]
            push rbx
            call array_append_value
            pop rbx
            mov [rbp-16], rax
            mov rbx, [rbx+deque_node.next]
            jmp appending
        end_appending:
        mov rax, [rbp-16]

        leave
        ret

    deque_extend_from_array:
        ;param rdi - address of deque
        ;param rsi - address of array
        ;returns count of items in deque or 0 if array is empty
        push rbp
        mov rbp, rsp
        
        push rdi
        push rsi
        mov rdi, rsi
        call array_get_size
        cmp rax, 0
        jng extend_from_empty
            mov rcx, rax
            push rax
            extending:
                push rcx
                mov rsi, rcx
                sub rsi, [rbp-24]
                neg rsi
                mov rdi, [rbp-16]
                call array_get_by_index
                mov rsi, [rax]
                mov rdi, [rbp-8]
                call deque_push_right
                pop rcx
                loop extending
        extend_from_empty:

        leave
        ret

    deque_merge:
        ;param rdi - address of deque
        ;param rsi - address of other deque (will be deleted)
        ;deque in rsi will be merged to the end of deque in rdi
        push rbp
        mov rbp, rsp

        mov rax, [rdi+deque.len]
        add rax, [rsi+deque.len]
        mov [rdi+deque.len], rax

        mov rax, [rdi+deque.last]
        mov rbx, [rsi+deque.last]
        mov rcx, [rsi+deque.first]
        
        cmp rax, 0
        jne first_not_empty
            mov [rdi+deque.first], rcx
        first_not_empty:
        cmp rbx, 0
        je second_empty
            mov [rdi+deque.last], rbx
            mov [rcx+deque_node.prev], rax
            cmp rax, 0
            je first_empty
                mov [rax+deque_node.next], rcx
            first_empty:
            push rdi
            mov rdi, rsi
            call free
            pop rax
        second_empty:
        
        leave
        ret
