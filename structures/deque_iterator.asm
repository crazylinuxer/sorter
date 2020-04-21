extern free

extern deque_pop_left
extern deque_pop_right
extern deque_push_left
extern deque_push_right
extern create_deque_node

global iterator_get_start    ;get iterator that points to the deque start
global iterator_get_end      ;get iterator that points to the deque end
global iterator_get_left     ;get iterator for right element
global iterator_get_right    ;get iterator for left element
global iterator_get_value    ;get value of element that iterator points to
global iterator_set_value    ;set value of element that iterator points to
global iterator_insert_left  ;insert value in left of iterator
global iterator_insert_right ;insert value in right of iterator
global iterator_delete       ;delete item by iterator
;iterator here is basically poorly encrypted node pointer
;such strange design is needed to prevent dereferencing by negligence
;a kind of "encapsulation" in assembly (=
;NOTE: if iterator is null, it is like nullptr and it can cause segfault


struc deque_node
    .data resq 1
    .next resq 1
    .prev resq 1
endstruc

struc deque
    .first resq 1
    .last  resq 1
    .len   resq 1
endstruc

segment .bss
    mask resq 1

segment .data
    random_source db "/dev/urandom", 0

segment .text
    get_mask:
        ;no params
        ;returns mask
        push rbp
        mov rbp, rsp

        mov rax, [mask]
        cmp rax, 0
        jne mask_not_null
            mov rsi, 0644o
            mov rax, 2
            xor edx, edx
            mov rdi, random_source
            syscall
            push rax
            reading_mask:
                mov rdi, [rbp-8]
                xor eax, eax
                mov rdx, 8
                mov rsi, mask
                syscall
                mov rax, [mask]
                cmp rax, 0
                je reading_mask
            pop rdi
            mov rax, 3
            syscall
            mov rax, [mask]
        mask_not_null:

        leave
        ret

    crypt:
        ;masks (or unmasks) an address
        cmp rdi, 0
        je crypt_null
            push rdi
            call get_mask
            pop rdi
            cmp rdi, rax
            je end_crypt
            xor rax, rdi
            jmp end_crypt
        crypt_null:
            xor eax, eax
        end_crypt:
        xor edi, edi
        ret
    
    iterator_get_start:
        ;param rdi - address of deque
        ;returns iterator
        mov rdi, [rdi+deque.first]
        call crypt
        ret

    iterator_get_end:
        ;param rdi - address of deque
        ;returns iterator
        mov rdi, [rdi+deque.last]
        call crypt
        ret
    
    iterator_get_value:
        ;param rdi - iterator
        ;returns value
        call crypt
        mov rax, [rax+deque_node.data]
        ret
    
    iterator_set_value:
        ;param rdi - iterator
        ;param rsi - value
        ;sets value
        push rsi
        call crypt
        pop rsi
        mov [rax+deque_node.data], rsi
        mov rax, rsi
        ret
    
    iterator_get_left:
        ;param rdi - iterator
        ;returns iterator
        call crypt
        mov rdi, [rax+deque_node.prev]
        call crypt
        ret

    iterator_get_right:
        ;param rdi - iterator
        ;returns iterator
        call crypt
        mov rdi, [rax+deque_node.next]
        call crypt
        ret
    
    iterator_delete:
        ;param rdi - iterator
        ;param rsi - deque
        ;returns simple struct of left (rax) and right (rdx) iterators
        push rbp
        mov rbp, rsp
        
        push rsi ;[rbp-8] - deque
        call crypt
        xor edx, edx
        cmp rax, 0
        je exit_iter_del
            push rax ;[rbp-16] - current node
            mov rdi, [rax+deque_node.prev]
            cmp rdi, 0
            jne del_left_not_null
                mov rdi, [rbp-8]
                call deque_pop_left
                mov rdi, [rbp-8]
                call iterator_get_start
                mov rdx, rax
                xor eax, eax
                jmp exit_iter_del
            del_left_not_null:
            mov rsi, [rax+deque_node.next]
            cmp rsi, 0
            jne del_right_not_null
                mov rdi, [rbp-8]
                call deque_pop_right
                mov rdi, [rbp-8]
                call iterator_get_end
                xor edx, edx
                jmp exit_iter_del
            del_right_not_null:

            mov rcx, [rbp-8]
            mov rbx, [rcx+deque.len]
            dec rbx
            mov [rcx+deque.len], rbx

            mov rbx, [rax+deque_node.next]
            mov [rbx+deque_node.prev], rdi
            mov rbx, [rax+deque_node.prev]
            mov [rbx+deque_node.next], rsi
            push rdi ;[rbp-24] - left
            push rsi ;[rbp-32] - right
            mov rdi, rax
            call free
            mov rdi, [rbp-32]
            call crypt
            mov [rbp-32], rax
            mov rdi, [rbp-24]
            call crypt
            pop rdx
        exit_iter_del:

        leave
        ret
    
    iterator_insert_right:
        ;param rdi - iterator
        ;param rsi - deque
        ;param rdx - value to insert
        ;returns iterator for new item
        push rbp
        mov rbp, rsp

        push rsi ;[rbp-8] - deque
        push rdx ;[rbp-16] - value
        xor eax, eax
        cmp rdi, 0
        je end_insert_right
            call crypt
            push rax ;[rbp-24] - node

            mov rdi, [rbp-8]
            mov rbx, [rdi+deque.len]
            inc rbx
            mov [rdi+deque.len], rbx

            mov rdi, [rax+deque_node.next]
            cmp rdi, 0
            jne ins_right_not_null
                mov rdi, [rbp-8]
                mov rsi, [rbp-16]
                call deque_push_right
                mov rdi, [rbp-8]
                call iterator_get_end
                jmp end_insert_right
            ins_right_not_null:
            call create_deque_node
            mov rbx, [rbp-24]
            mov rcx, [rbx+deque_node.next]

            mov [rax+deque_node.next], rcx
            mov [rax+deque_node.prev], rbx
            mov [rbx+deque_node.next], rax
            mov [rcx+deque_node.prev], rax
            mov rdi, [rbp-16]
            mov [rax+deque_node.data], rdi
            mov rdi, rax
            call crypt
        end_insert_right:

        leave
        ret
    
    iterator_insert_left:
        ;param rdi - iterator
        ;param rsi - deque
        ;param rdx - value to insert
        ;returns iterator for new item
        push rbp
        mov rbp, rsp

        push rsi ;[rbp-8] - deque
        push rdx ;[rbp-16] - value
        xor eax, eax
        cmp rdi, 0
        je end_insert_left
            call crypt
            push rax ;[rbp-24] - node

            mov rdi, [rbp-8]
            mov rbx, [rdi+deque.len]
            inc rbx
            mov [rdi+deque.len], rbx

            mov rdi, [rax+deque_node.prev]
            cmp rdi, 0
            jne ins_left_not_null
                mov rdi, [rbp-8]
                mov rsi, [rbp-16]
                call deque_push_left
                mov rdi, [rbp-8]
                call iterator_get_start
                jmp end_insert_right
            ins_left_not_null:
            call create_deque_node
            mov rbx, [rbp-24]
            mov rcx, [rbx+deque_node.prev]

            mov [rax+deque_node.prev], rcx
            mov [rax+deque_node.next], rbx
            mov [rbx+deque_node.prev], rax
            mov [rcx+deque_node.next], rax
            mov rdi, [rbp-16]
            mov [rax+deque_node.data], rdi
            mov rdi, rax
            call crypt
        end_insert_left:

        leave
        ret
