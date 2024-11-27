.ifndef UTILS_S
.equ UTILS_S, 1
.include "defines.s"

.text
//(char*, size)
_utils_print_charbuffer:
  mov x2, x1
  mov x1, x0
  mov x0, #1
  mov x16, SYS_WRITE
  svc 0
  ret

.endif
