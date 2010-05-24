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

;; mov word [0xb8000],0x0748
;; mov word [0xb8002],0x0765
;; mov word [0xb8004],0x0765

;; xor       rax,   rax
;; xor       rcx,   rcx
;; xor       rdx,   rdx
;; mov       rcx,   hello_string
;; mov dword rdx,   0x0b8000
;; mov byte  ah,    0x07
;; mov byte  al,    [hello_string]
;; mov word  [rdx], ax

jmp print_hello

hello_string dw 'Hello World', 0

print_hello:

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







