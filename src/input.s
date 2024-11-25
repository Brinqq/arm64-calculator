.include "defines.s"


.text
_input_get_user_input:

_log_out_input_prompt:
  mov x0, #1
  adrp x1, input_prompt@PAGE
  add x1, x1, input_prompt@PAGEOFF
  mov x2, #11
  mov x16, #4
  svc 0
  ret

.data
input_prompt: .asciz "Test Prompt"


  
