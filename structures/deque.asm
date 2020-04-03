extern malloc
extern free

global deque_init        ;initializes empty deque structure
global deque_delete      ;deletes deque structure
global deque_delete_each ;frees memory using each item as pointer and then deletes deque itself
global deque_push_right  ;appends value to the end of deque
global deque_push_left   ;appends value to the start of deque
global deque_pop_right   ;deletes and returns value from the end of deque
global deque_pop_left    ;deletes and returns value from the start of deque
global deque_get_length  ;returns length of stack in O(1) time
global deque_get_left    ;returns value from the start of deque
global deque_get_right   ;returns value from the end of deque


struc deque_node
    ;each field is zero by default
    .data resq 1
    .next resq 1
    .prev resq 1
endstruc

struc deque
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
        xor rax, rax
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
        deleting_nodes:
            push rdi
            call deque_pop_right   ;todo: rewrire to optimize this and check size==0
            pop rdi
            loop deleting_nodes
        call free
        xor rax, rax

        leave
        ret
    
    deque_delete_each:
        ;param rdi - address of deque
        ;deletes deque and all its nodes
        ;frees memory using each item as pointer
        push rbp
        mov rbp, rsp

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

        leave
        ret

    deque_pop_left:
        ;param rdi - address of deque
        ;pops and returns value from the start of deque
        push rbp
        mov rbp, rsp

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
