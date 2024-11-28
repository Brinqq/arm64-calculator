.ifndef BALLOC_S
.equ BALLOC_S, 1

.include "defines.s"


.equ BALLOC_MAP_STANDARD, 0x1002
.equ BALLOC_PROT_RW, 0x3
.equ SYSINFO_PAGE_SIZE, 0x4000

.equ DPB, 0x28
.equ MAX_PAGES_ALLOWED, 0x5

// I have opted to inline the meta of each page at the start of the selected page
//PAGE LAYOUT: | [nPointer - 8 bytes] |
//USER_DATA_NODE | [nbytes - 8 bytes]  [user data - {variable} bytes] |

.text
//int func(int pages, page_arr_index)

// void func(page*)
_balloc_initialize_page_:
  ret

_balloc_allocate_new_page_:
  sub sp, sp, #16
  str x30, [sp]

  //assure we are not at max pages allowed, if so we return 1. else we incrament active pages var and continue allocating
  adrp x2, array_pages_active@PAGE
  add x2, x2, array_pages_active@PAGEOFF
  ldr x3, [x2]
  str x3, [sp, #8]
  mov x4, MAX_PAGES_ALLOWED
  cmp x3, x4
  b.eq max_pages_reached_error
  mov x4, #1
  add x4, x3, x4
  str x4, [x2]
  
  
  mov x6, x1 //saving page arr index for later inside 6 register

  //mmap call to get page
  mov x1, SYSINFO_PAGE_SIZE
  mul x1, x0, x1
  mov x0, #0
  mov x2, BALLOC_PROT_RW
  mov x3, BALLOC_MAP_STANDARD
  mov x4, #-1
  mov x5, #0
  mov x16, SYS_MMAP
  svc 0

  //add pointer to page to the global list of page pointers(array_page_pointers)
  adrp x1, array_page_ptrs@PAGE
  add x1, x1, array_page_ptrs@PAGEOFF
  //get offset into arr_page_pointer buffer to set are new pointer
  mov x2, #8
  mul x2, x6, x2
  add x1, x1, x2

  str x0, [x1] // store mmaped pointer to new allocated page into {arr_page_pointer} buffer

  bl _balloc_initialize_page_

  ldr x30, [sp]
  add sp, sp, #16
  ret
  max_pages_reached_error:
  mov x0, #1
  ldr x30, [sp]
  add sp, sp, #16
  ret

//void func(mem*)
// deallocates a page at a time
_balloc_free_page_:
  ret
 
// void* func[page*, nbytes]
_balloc_try_find_mem_in_page_:
  sub sp, sp, #32
  str x30, [sp]
  str x1, [sp, #16]

  
  //defefence the pointer at the given array page and store in stack for later - should equal the start of a actual page in heap mem
  ldr x0, [x0]
  str x0, [sp, #8]

  //iterate linked list to get next available slot
  
  //allocate space
  mov x3, #8
  add x0, x0, x3
  add x1, x1, x3 
  str x1, [x0]
  add x0, x0, x3

  ldr x30, [sp]
  add sp, sp, #32
  ret

//type* func(nBytes)
_balloc:
  sub sp, sp, #48 
  str x30, [sp]
  str x0, [sp, #8]

  //get the number of active pages
  adrp x0, array_pages_active@PAGE
  add x0, x0, array_pages_active@PAGEOFF
  ldr x1, [x0]
  str x0, [sp, #16]
  str x1, [sp, #40]
  
  //if pages active is zero we jump to alloacate a new page
  mov x1, #0 //index of page array to allocate on
  cmp x0, #0
  b.ne no_active_pages

  get_user_requested_memory:
  //loop through all active pages and allocate on the first one available
  adrp x3, array_page_ptrs@PAGE
  add x3, x3, array_page_ptrs@PAGEOFF
  str x3, [sp, #24]
  ldr x3, [sp, #16]
  ldr x3, [x3]
  mov x1, #0 // gotta store on stack
  str x1, [sp, #32]
  b alloc_loop_s
  alloc_loop:
  mov x4, #8 //const 1 byte
  mul x2, x1, x4  //bytes to offset array of page pointers
  ldr x0, [sp, #24]
  //grows down or up ?
  add x0, x0, x2 //calc into array of page pointers
  //
  add x1, x1, #1
  str x1, [sp, #32]
  bl _balloc_try_find_mem_in_page_
  alloc_loop_s:
  ldr x1, [sp, #32]
  ldr x3, [sp, #40]
  cmp x1, x3
  b.ne alloc_loop

  ldr x30, [sp]
  add sp, sp, #48 
  ret
  
  no_active_pages:
  mov x0, #1
  bl _balloc_allocate_new_page_
  b get_user_requested_memory

// memory is low, or the set max amount of pages allowed to be allocated was reached. if we get here we must find memory on a existing pages or return a error
  memory_amount_critical: 



.data
  array_page_ptrs: .space DPB
  array_pages_active: .word 0

  .endif
