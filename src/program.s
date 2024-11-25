.include "defines.s"
.include "input.s"


.global _main
.align 4

_exit:
  mov x0, #3
  mov x16, SYS_EXIT
  svc 0

_main:
  bl _log_out_input_prompt
  bl _exit

.data

  


 



    

