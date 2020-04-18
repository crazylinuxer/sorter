extern malloc
extern posix_memalign
extern free

extern array_init
extern array_clear
extern array_get_by_index
extern array_get_size
extern array_shrink_to_fit

extern filemgr_try_open
extern filemgr_buffer_to_block
extern filemgr_block_to_buffer
extern filemgr_close
extern filemgr_clear_buffer

global reader_init       ;initializes new file_reader
global reader_delete     ;deletes file_reader and closes file
global reader_getline    ;returns one more string from file or nullptr on eof
global reader_set_size   ;changes block size in range from MIN_BLOCK_SIZE to MAX_BLOCK_SIZE
global reader_get_size   ;returns block size
global reader_set_shrink ;sets bool field 'shrink'
global reader_get_shrink ;returns bool field 'shrink'
global reader_is_eof     ;returns true if new line can be read
;look function definition to see some details


struc file_reader
    .descriptor  resq 1 ;file descriptor
    .buffer      resq 1 ;pointer to dynamic array with data
    .block_size  resd 1 ;size of block to read from file at once
    .position    resd 1 ;position in buffer
    .last_closed resb 1 ;bool, "if the last string in buffer is closed properly"
    .eof         resb 1 ;bool, end of file
    .shrink      resb 1 ;bool, if it's 0, buffer will be shrinked on each iteration
endstruc

MIN_BLOCK_SIZE equ 8
MAX_BLOCK_SIZE equ 10000000h ;256M
SIZEOF_FREADER equ 27


segment .text
    reader_init:
        ;param rdi - file name
        ;param rsi - initial block size
        ;param rdx - buffer shrinking (bool)
        ;returns new file_reader on success or nullptr on error
        push rbp
        mov rbp, rsp

        push rdi ;[rbp-8] - file name
        push rsi ;[rbp-16] - block size
        movzx rdx, dl
        push rdx ;[rbp-24] - 'shrink'
        call filemgr_try_open
        cmp rax, 0
        jnl init_can_open
            xor eax, eax
            leave
            ret
        init_can_open:
        mov rsi, 0644o
        mov rax, 2
        xor edx, edx
        mov rdi, [rbp-8]
        syscall
        push rax ;[rbp-32] - descriptor
        mov rdi, SIZEOF_FREADER
        call malloc
        push rax ;[rbp-40] - object ptr
        call array_init
        mov r8, [rbp-16]
        cmp r8, MIN_BLOCK_SIZE
        jnl greater_than_min
            mov r8, MIN_BLOCK_SIZE
            jmp less_than_max
        greater_than_min:
        cmp r8, MAX_BLOCK_SIZE
        jng less_than_max
            mov r8, MAX_BLOCK_SIZE
        less_than_max:
        mov r9, [rbp-40]
        mov [r9+file_reader.block_size], r8d
        mov r8, [rbp-32]
        mov [r9+file_reader.descriptor], r8
        mov r8, [rbp-24]
        shl r8, 8
        mov [r9+file_reader.eof], r8w
        mov byte [r9+file_reader.last_closed], 1
        xor r8, r8
        mov [r9+file_reader.position], r8d
        mov [r9+file_reader.buffer], rax
        mov rax, r9

        leave
        ret

    reader_delete:
        ;param rdi - address of reader
        ;deletes file reader: closes file and frees memory
        push rbp
        mov rbp, rsp
        
        leave
        ret
    
    reader_getline:
        ;param rdi - address of reader
        ;the name speaks for itself
        ;returns nullptr if cannot read
        push rbp
        mov rbp, rsp

        push rdi ;[rbp-8] - reader
        call check_buffer
        mov rdi, [rbp-8]
        mov rdi, [rdi+file_reader.buffer]
        call array_get_size
        cmp eax, 0
        jng end_getline ;return nullptr
            mov rdi, [rbp-8]
            mov esi, [rdi+file_reader.position]
            mov eax, esi
            inc eax
            mov [rdi+file_reader.position], eax
            mov rdi, [rdi+file_reader.buffer]
            call array_get_by_index
            cmp rax, 0
            je end_getline
                mov rdi, [rax]
                push rdi ;[rbp-16] - source string
                xor ecx, ecx
                dec ecx
                shr ecx, 1
                xor al, al
                repne scasb
                sub rdi, [rbp-16]
                push rdi ;[rbp-24] - string length
                mov rdx, rdi
                shr rdx, 4
                inc rdx
                shl rdx, 4
                push 0 ;[rbp-32] - 0
                mov rdi, rsp
                mov rsi, 16
                call posix_memalign ;[rbp-32] - new string
                mov rcx, [rbp-24]
                shr rcx, 4
                inc rcx
                shl rcx, 1
                mov rdi, [rbp-32]
                mov rsi, [rbp-16]
                rep movsq
                pop rax
        end_getline:
        
        leave
        ret
    
    check_buffer:
        ;param rdi - address of reader
        ;looks for ability to read line
        ;refills buffer if needed and posible
        push rbp
        mov rbp, rsp

        push rdi ;[rbp-8] - reader
        mov esi, [rdi+file_reader.position]
        mov rdi, [rdi+file_reader.buffer]
        push rsi
        call array_get_size
        pop rsi
        sub eax, esi
        push rax ;[rbp-16] - "length-position"
        cmp eax, 1
        jg exit_check_buffer
            mov rdi, [rbp-8]
            mov al, [rdi+file_reader.eof]
            cmp al, 0
            je cb_not_eof
                pop rax
                cmp al, 1
                jnl cb_not_clearing
                    pop rdi
                    mov rdi, [rdi+file_reader.buffer]
                    xor esi, esi
                    call filemgr_clear_buffer
                cb_not_clearing:
                jmp end_check_buffer
            cb_not_eof:
            mov rdi, [rbp-8]
            mov dword [rdi+file_reader.position], 0
            reading_blocks:

                mov al, [rdi+file_reader.eof]
                cmp al, 0
                jne exit_check_buffer

                mov rdi, [rbp-8]
                call read_block

                mov rdi, [rbp-8]
                mov rdi, [rdi+file_reader.buffer]
                call array_get_size
                cmp rax, 1
                jg exit_check_buffer

                mov rdi, [rbp-8]
            jmp reading_blocks
        exit_check_buffer:

        mov rdi, [rbp-8]
        mov rdi, [rdi+file_reader.buffer]
        call array_get_size
        mov ecx, eax
        mov rdi, [rbp-8]
        mov rdi, [rdi+file_reader.buffer]
        mov esi, [rdi+file_reader.position]
        sub rcx, rsi
        push rcx
        call array_get_by_index
        pop rcx
        mov rdi, rax
        xor eax, eax
        repe scasq
        cmp rcx, 0
        je reading_blocks
        push rcx
        mov rdi, [rbp-8]
        mov rdi, [rdi+file_reader.buffer]
        call array_get_size
        pop rcx
        inc ecx
        sub ecx, eax
        neg ecx
        mov rdi, [rbp-8]
        mov [rdi+file_reader.position], ecx

        end_check_buffer:
        
        xor eax, eax
        leave
        ret

    read_block:
        ;param rdi - address of reader
        ;reads block of text to buffer
        push rbp
        mov rbp, rsp

        push rdi ;[rbp-8] - reader
        mov edi, [rdi+file_reader.block_size]
        call malloc
        push rax ;[rbp-16] - block address
        mov rsi, rax
        xor eax, eax
        mov rdi, [rbp-8]
        mov edx, [rdi+file_reader.block_size]
        mov rdi, [rdi+file_reader.descriptor]
        syscall
        push rax ;[rbp-24] - real block length
        
        mov rbx, [rbp-8]
        cmp eax, dword [rbx+file_reader.block_size]
        je not_eof
            mov byte [rbx+file_reader.eof], 1
            cmp rax, 0
            jne not_eof
                mov rdi, [rbp-16]
                call free
                mov rdi, [rbp-8]
                mov al, [rdi+file_reader.last_closed]
                cmp al, 0
                jne already_closed
                    mov rdi, [rdi+file_reader.buffer]
                    push rdi
                    call array_get_size
                    mov esi, eax
                    pop rdi
                    call array_get_by_index
                    cmp rax, 0
                    je already_closed
                        mov rdi, [rax]
                        xor al, al
                        repne scasb
                        mov word [rdi], 10
                        mov rdi, [rbp-8]
                        mov byte [rdi+file_reader.last_closed], 1
                already_closed:
                xor eax, eax
                leave
                ret
        not_eof:
        movzx edx, byte [rbx+file_reader.last_closed]
        xor dl, 1
        
        push rdx ;[rbp-32] - not "properly closed"
        mov rsi, rdx
        mov rdi, [rbp-8]
        mov rdi, [rdi+file_reader.buffer]
        call filemgr_clear_buffer

        pop rdx ;deleted [rbp-32]
        pop rcx ;deleted [rbp-24]
        mov rdi, [rbp-16]
        mov rsi, [rbp-8]
        add rsi, file_reader.buffer
        call filemgr_block_to_buffer
        mov rdi, [rbp-8]
        xor al, 1
        mov [rdi+file_reader.last_closed], al

        mov rax, [rbp-8]
        mov bl, [rax+file_reader.shrink]
        cmp bl, 0
        je skip_shrinking
            mov rdi, [rbp-8]
            mov rdi, [rdi+file_reader.buffer]
            call array_shrink_to_fit
            mov rdi, [rbp-8]
            mov [rdi+file_reader.buffer], rax
        skip_shrinking:

        pop rdi ;deleted [rbp-16]
        call free
        xor eax, eax

        leave
        ret
    
    reader_is_eof:
        ;param rdi - address of reader
        ;param rsi - force recheck (bool), works slower if true
        ;returns true if eof is reached
        push rbp
        mov rbp, rsp

        push rdi ;[rbp-8] - reader
        cmp esi, 0
        je recheck_not_forced
            mov rsi, rsp
            dec rsi ;reading to place with "trash"
            xor eax, eax
            mov edx, 1
            mov rdi, [rdi+file_reader.descriptor]
            syscall
            mov rdi, [rbp-8]
            mov [rdi+file_reader.eof], al
            cmp rax, 0
            je recheck_not_forced
                mov rdi, [rdi+file_reader.descriptor]
                mov rsi, rax
                neg rsi
                mov edx, 1
                mov eax, 8
                syscall
        recheck_not_forced:
        pop rdi ;deleted [rbp-8]
        mov al, [rdi+file_reader.eof]
        cmp al, 0
        je ie_not_eof
            mov rdi, [rdi+file_reader.buffer]
            call array_get_size
            cmp eax, 0
            jg ie_not_eof
                mov eax, 1
                jmp end_eof_check
        ie_not_eof:
        mov eax, 0
        end_eof_check:

        leave
        ret
