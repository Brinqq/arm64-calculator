.ifndef INPUT_S
.equ INPUT_S, 1

.include "defines.s"
.include "utils.s"

.text

// right now user iput has a fixed size of {MAX_USER_INPUT_S} chars in static memory
.equ MAX_USER_INPUT_S, 32
//TODO: maybe allocate dynamically

// char* func()
_input_get_user_input:
  mov x4, x30
  mov x0, #0
  adrp x1, user_input_buffer@PAGE
  add x1, x1, user_input_buffer@PAGEOFF
  mov x6, x1
  mov x2, MAX_USER_INPUT_S
  mov x16, SYS_READ
  svc 0
  mov x5, #0
  cmp x0, x5
  cmp x0, x2
  b.gt max_size_exceeded_error 
  b.ne read_no_error
  mov x0, #1
  adrp x0, user_input_error_read@PAGE
  add x0, x0 , user_input_error_read@PAGEOFF
  mov x1, #31
  bl _utils_print_charbuffer
  mov x6, x30
  ret
  max_size_exceeded_error:
  mov x0, #-1
  ret
  read_no_error:
  mov x1, x0
  mov x0, x6
  bl _utils_print_charbuffer
  mov x30, x4
  ret

.data
user_input_error_read: .ascii "Error while reading user input!\n"

.bss
user_input_buffer: .skip MAX_USER_INPUT_S

.endif


  
