.include "defines.s"
.include "input.s"
.include "utils.s"
.include "parser.s"
.include "balloc.s"

.equ MAX_USER_BYTES, 0x10


.text
.global _main
.align 4

//using malloc for now intell i get my own dynamic allocator. tiresome challenge tbh
.extern malloc

_exit:
  mov x0, #3
  mov x16, SYS_EXIT
  svc 0

// struct users_input_t{
//  pBuffer: 8
//  char_buffer_legth: 4
//}

_executable_loop:
  sub sp, sp, #32
  str x30, [sp, #24]
  mov x0, sp
  mov x1, sp
  add x1, x1, MAX_USER_BYTES 
  mov x2, MAX_USER_BYTES
  bl _input_get_user_input
  mov x0, sp
  ldr x1, [sp, 0x10]
  bl _utils_print_charbuffer
  mov x0, #2000
  ldr x30, [sp, #24]
  add sp, sp, #32
  ret

_main:
  mov x7, #2
  bl _executable_loop
  bl _exit

.bss
.data


    

