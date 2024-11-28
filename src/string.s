.include "defines.s"

.equ STING_MD_BYTES, 0x8
.equ STRING_MD_DEF_CAPACITY, 0x5 // 5 + this size given by the user

//string metadata is inlined inside of the allocated heap memory
//string | size - 4 bytes | capacity - 4 bytes | buffer_data |

//TODO: switch to my dynamic allocator once finished

.text
//char* func(string*)
_string_data:
  ret

//void func(string*)
_string_delete:
  sub sp, sp, #16
  str x30, [sp]
  bl _free
  ldr x30, [sp]
  add sp, sp, #16
  ret

// string* func(char* str, int bytes)
_string_new:
  sub sp, sp, #32
  str x30, [sp]
  str x0, [sp, #8]
  str w1, [sp, #16]

  //initialize meta data
  mov w3, STRING_MD_DEF_CAPACITY
  add w2, w1, w3
  str w2, [sp, #20]
  
  //allocate buffer
  mov x0, x2
  bl _malloc 
  cmp x0, #0
  b.eq alloc_error

  str x0, [sp, #24]

  //store meta data to allocated buffer
  mov w1, #4 
  ldr w2, [sp, #16]
  ldr w3, [sp, #20]
  str w2, [x0]
  add x0, x0, x1
  str w3, [x0]
  add x0, x0, x1

  //memcpy char buffer into new string data sagment
  ldr x0, [sp, #24]
  ldr x1, [sp, #8]
  ldr w2, [sp, #16]
  bl _memcpy

  ldr x0, [sp, #24]

  alloc_error:
  ldr x30, [sp]
  add sp, sp, #32
  ret
  

  


