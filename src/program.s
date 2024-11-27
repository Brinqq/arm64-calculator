.include "defines.s"
.include "input.s"
.include "utils.s"

.text
.global _main
.align 4

_exit:
  mov x0, #3
  mov x16, SYS_EXIT
  svc 0


_main:
  mov x7, #2
  bl _input_get_user_input
  bl _exit

.data





    

