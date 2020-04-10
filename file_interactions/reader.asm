extern malloc
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

global reader_init       ;initializes new file_reader
global reader_delete     ;deletes file_reader
global reader_getline    ;returns one more string from file
global reader_set_size   ;changes block size in range from MIN_BLOCK_SIZE to MAX_BLOCK_SIZE
global reader_get_size   ;returns block size
global reader_set_shrink ;sets bool field 'shrink'
global reader_get_shrink ;returns bool field 'shrink'
global reader_is_eof     ;returns falue of field 'eof'
;look function definition to see some details


struc file_reader
    .descriptor resq 1 ;file descriptor
    .buffer     resq 1 ;pointer to dynamic array with data
    .block_size resd 1 ;size of block to read from file at once
    .position   resd 1 ;position in buffer
    .eof        resb 1 ;can be 0 or 1
    .shrink     resb 1 ;can be 0 or 1, if it's 0, buffer will be shrinked on each iteration
endstruc

MIN_BLOCK_SIZE equ 8
MAX_BLOCK_SIZE equ 10000000h ;256M
SIZEOF_FREADER equ 26


segment .text
    reader_init:
        ;param rdi - file name
        ;param rsi - initial block size
        ;param rdx - buffer recreation (bool)
        ;returns new file_reader on success or nullptr on error
        push rbp
        mov rbp, rsp

        push rdi ;[rbp-8] - file name
        push rsi ;[rbp-16] - block size
        movzx rdx, dl
        push rdx ;[rbp-24] - recreation
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
        push rbp
        mov rbp, rsp
        
        leave
        ret

    read_block:
        ;param rdi - address of reader
        ;reads block of text to buffer
        push rbp
        mov rbp, rsp

        push rdi ;[rbp-8] - reader
        mov rdi, [rdi+file_reader.block_size]
        call malloc
        push rax ;[rbp-16] - buffer address
        mov rsi, rax
        xor eax, eax
        mov rdi, [rbp-8]
        mov rdx, [rdi+file_reader.block_size]
        mov rdi, [rdi+file_reader.descriptor]
        syscall
        pop rax
        
        ;todo finish
        ;todo check 0Ah in eof and append if absent

        leave
        ret
    
    reader_is_eof:
        ;param rdi - address of reader
        ;param rsi - force recheck (bool), works slower if true
        ;returns true if eof is reached
        push rbp
        mov rbp, rsp
        
        leave
        ret
