;;; initialize the stack
;;; note: that thw following is normally not available
;;;   - 0xA0000  to 0xCFFFF - video card?
;;;   - 0xB8000  to ?       - video card?
;;;   - 0x9FC00  to 0x9FFFF
;;;   - 0xE0000  to 0xEFFFF
;;;   - 0xF00000 to 0xFFFFFF
;;;   - 0xFFE00000 to 0xFFE00000
mov  rax, 0x8000    ; stack pointer
mov  rsp, rax       ; set the stack pointer
mov  rbp, rsp       ; save the stack pointer in the base pointer

;;; try pushing and poping from the stack
push rbp
pop  rbp

cmp  rbp, 0x1000
jmp  $

