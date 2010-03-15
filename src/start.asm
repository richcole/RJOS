[BITS 64]

extern kernel

;;; disable interupts
cli						

;;; long mode kernel
mov edi,0x00b8000
mov rax,0x0720077407750750
mov [edi],rax
mov rax,0x0767076e076f076c
mov [edi+8],rax
mov rax,0x0764076f076d0720
mov [edi+16],rax
mov rax,0x0765076b07200765
mov [edi+24],rax
mov rax,0x076c0765076e0772
mov [edi+32],rax
mov rax,0x0772076507680720
mov [edi+40],rax
mov rax,0x07200720072e0765
mov [edi+48],rax

;;; print hello world to the screen

xor rax,rax
mov bh,0x0f
mov rdi,0xb8000
mov rcx,hello_string
st:
mov bl,byte [rcx]
cmp bl,0
je next
mov word [rdi],bx
inc rcx
jmp st
	
hello_string db 'Hello World', 0
hello_string_len equ $-hello_string

;;; jump into the kernel
next:
call kernel

;;; hang if kernel returns
jmp $				



