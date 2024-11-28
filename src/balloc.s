.ifndef BALLOC_S
.equ BALLOC_S, 1

.include "defines.s"

.equ BALLOC_MAP_STANDARD, 0x1002
.equ BALLOC_PROT_RW, 0x3
.equ SYSINFO_PAGE_SIZE, 0x4000

.equ DPB, 0x28
.equ MAX_PAGES_ALLOWED, 0x5

.text

# TODO: Gotta clean up the main interface allocation function optimze and everything, more stack utilization

//void func(int pages)
_balloc_allocate_new_page_:
    cmp x0, #0x0
    sub sp, sp, #16
    b.eq pages_zero_error
    mov x6, SYSINFO_PAGE_SIZE
    mul x1, x0, x6
    mov x0, #0
    mov x2, BALLOC_PROT_RW
    mov x3, BALLOC_MAP_STANDARD
    mov x4, #-1
    mov x5, #0
    mov x16, SYS_MMAP
    svc 0
    adrp x1, array_page_ptrs@PAGE
    add x1, x1, array_page_ptrs@PAGEOFF
    adrp x2, array_pages_active@PAGE
    add x2, x2, array_pages_active@PAGEOFF
    str x2, [sp, 8]
    ldr x2, [x2]
    str x0, [x1, x2]
    ldr x3, [sp, 8]
    add x2, x2, #1
    str x2, [x3]
    add sp, sp, #16
    ret
    pages_zero_error:
    add sp, sp, #16
    ret

//void func(mem*)
// deallocates a page at a time
_balloc_free:
  mov x1, SYSINFO_PAGE_SIZE
  mov x16, SYS_MUNMAP
  svc 0
  ret
 
// int func[block_ptr*, nbytes]
  _balloc_find_mem_in_page_:
  sub sp, sp, #8
  add sp, sp, #8
  ret

  

//type* func(nBytes)
// TODO: Find a way to page arr not in reverse
_balloc:
  sub sp, sp, #48
  str x30, [sp, #48]
  str x0, [sp, #32]
  adrp x1, array_pages_active@PAGE
  add x1, x1,array_pages_active@PAGEOFF
  str x1, [sp, #8]
  ldr x1, [x1]
  cmp x1, #0
  b.eq get_new_page
  get_memory_for_user:
  adrp x1, array_page_ptrs@PAGE
  add x1, x1,array_page_ptrs@PAGEOFF
  str x1, [sp, #16]
  mov x3, #8
  mov x2, x4
  mov x7, x4
  mov x6, #0
  add x0, sp, 0x18
  loop:
  //TODO: optimize
  ldr x1, [sp, #8]
  ldr x4, [x1]

  mul x5, x7, x3
  add x5, x1, x5
  sub x5, x5, #8
  bl _balloc_find_mem_in_page_
  add x6, x6, #1
  add x7, x7, #1
  cmp x6, x4
  b.ne loop


  ldr x30, [sp]
  add sp, sp, #40
  ret
  get_new_page:
  mov x0, #0x1
  bl _balloc_allocate_new_page_
  b get_memory_for_user
  no_pages_can_alloc:
  //if we get here must must find space or return with error

.endif

.data
  array_page_ptrs: .space DPB
  array_pages_active: .word 0


