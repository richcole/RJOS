[BITS 64]

SECTION .text

global start
start:

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

;;;  copy hello world to screen
mov rcx,hello_string
mov ah,0x07
mov rdi,0xb8000
st:
mov byte al,[rcx]
cmp al,0
je next
mov word [rdi],ax
add rcx,0x1
add rdi,0x2
jmp st
	
next:
call kernel

SECTION .data

hello_string dw 'Hello World', 0

SECTION .bss







