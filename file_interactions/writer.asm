extern malloc
extern free

extern filemgr_block_to_buffer
extern filemgr_buffer_to_block
extern filemgr_try_open
extern filemgr_close

struc file_reader
    .descriptor resq 1 ;file descriptor
    .buffer     resq 1 ;pointer to dynamic array with data
    .buffer_max resd 1 ;maximum size of buffer
    .eof        resb 1 ;can be 0 or 1
    .shrink     resb 1 ;can be 0 or 1, if it's 0, buffer will be shrinked on each iteration
endstruc

segment .text
