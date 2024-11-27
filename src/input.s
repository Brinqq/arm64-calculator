.ifndef INPUT_S
.equ INPUT_S, 1

.include "defines.s"
.include "utils.s"

.text

//TODO: maybe allocate dynamically
//TODO: if user inputed string is longer than max count passed to get input function program will cease to function. But dont know how to fix rn so....

// int func(char*, &length, max_count)
_input_get_user_input:
  mov x3, x0
  mov x4, x1
  mov x0, #0
  mov x1, x3
  mov x16, SYS_READ
  svc 0
  str x0, [x4]
  mov x3, #0
  cmp x0, x3
  b.eq read_error
  cmp x0, x2
  b.gt max_chars_exceeded_error
  ret
  read_error:
  mov x5, x30
  adrp x0, user_input_error_read@PAGE
  add x0, x0, user_input_error_read@PAGEOFF 
  mov x1, #31
  bl _utils_print_charbuffer
  mov x0, #1
  mov x30, x5
  ret
  max_chars_exceeded_error:
  mov x5, x30
  adrp x0, user_input_mce_error@PAGE
  add x0, x0, user_input_mce_error@PAGEOFF 
  mov x1, #58
  bl _utils_print_charbuffer
  mov x0, #1
  mov x30, x5
  ret

.data
user_input_error_read: .ascii "Error while reading user input!\n"
user_input_mce_error: .ascii "Maximum characters allowed exceeded by user inputed string\n"

.bss
.endif


  
