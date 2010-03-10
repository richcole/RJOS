[ORG 0x00007C00]
[BITS 16]

cli 				; turn interupts off
xor bx,bx			; zero the general purpose registers
mov es,bx
mov fs,bx
mov gs,bx
mov ds,bx
mov ss,bx
mov sp,0x7C00			; stack starts at 7C00
sti				; turn registers back on

jmp 0:.clear_cs			; zero the code segment register
.clear_cs:

				; Load kernel from floppy disk
mov ax,0x020D			; - function 0x2, 0xd sectors
mov bx,startLongMode		; - location to load to
mov cx,0x0002			; - cylinder 0x0, sector 0x2
mov dx,0x0000  			; - driver number
int 0x13		        ; - software interupt - load sectors

  				; enable address line A20
in al,92h			; read from port 92h
or al,02h			; or with 02h to turn on A20
out 92h,al			; write the result to the port

;;; Build page tables
;;; A virtual address is
;;; [ sign , PML4E , PDPE , PDE , PTE , Offset ]
;;; CR3    - Page Map Base Register
;;; PML4E  - Page Map Level 4 Offset
;;; PDPE   - Page Directory Pointer Offset
;;; PDE    - Page Directory Offset
;;; PTE    - Page Table Offset
;;; Offset - Offset
;;; ----
;;; CR0.PG  (bit 31) - enable page translation bit (required for long mode)
;;; CR4.PAE (bit 4)  - enable physical address extensions (required for lm)
;;; CR4.PSE (bit 4)  - page size extention 
;;;   PAE=1 -> large physical page size = 2M
;;; PDE.PS (bit 7)   - page size bit, if 1 then large page size is used
;;; ----
;;; CR3 (PML4): 0x0000a000				

				; The page tables will look like this:
; PML4:
; dq 0x000000000000b00f =
;	00000000 00000000 00000000 00000000 00000000 00000000 10010000 00001111
;       times 511 dq 0x0000000000000000
; PDP:
; dq 0x000000000000c00f =
;       00000000 00000000 00000000 00000000 00000000 00000000 10100000 00001111
;       times 511 dq 0x0000000000000000
; PD:
; dq 0x000000000000018f =
;       00000000 00000000 00000000 00000000 00000000 00000000 00000001 10001111
;       times 511 dq 0x0000000000000000
; This defines one 2MB page at the start of memory, so we can access
; the first 2MBs as if paging was disabled 
xor bx,bx			; zero bx
mov es,bx			; zero es
cld				; clean the address flag
mov di,0xa000			; set address to write to 0xa000
mov ax,0xb00f			; set value to write to 0xb00f
stosw				; store value in ax at index di

xor ax,ax			; zero ax
mov cx,0x07ff			; number of values to write
rep stosw			; store values cx times

mov ax,0xc00f                   ; change value to write to 0xc00f
stosw                           ; store value

xor ax,ax                       ; set value to store to zero
mov cx,0x07ff                   ; number of entries to write
rep stosw			; store values cx times

mov ax,0x018f			; set value to write to 0x018f
stosw				; store values

xor ax,ax			; set value to write to zero
mov cx,0x07ff			; number of entries to write
rep stosw			; store values


;;; Enter long mode
mov eax,10100000b		; set PAE and PGE
mov cr4,eax			 

mov edx, 0x0000a000		; set cr3 to point to PML4
mov cr3,edx

;;; UP TO HERE
mov ecx,0xC0000080		; Specify EFER MSR


; Enable Long Mode
rdmsr						
or eax,0x00000100
wrmsr

mov ebx,cr0					; Activate long mode
or ebx,0x80000001				; by enabling paging and protection simultaneously
mov cr0,ebx					; skipping protected mode entirely

lgdt [gdt.pointer]				; load 80-bit gdt.pointer below

jmp gdt.code:startLongMode			; Load CS with 64 bit segment and flush the instruction cache



; Global Descriptor Table
gdt:
dq 0x0000000000000000				;Null Descriptor

.code equ $ - gdt
dq 0x0020980000000000                   

.data equ $ - gdt
dq 0x0000900000000000                   

.pointer:
dw $-gdt-1					;16-bit Size (Limit)
dq gdt						;64-bit Base Address
						;Changed from "dd gdt"
						;Ref: Intel System Programming Manual V1 - 2.1.1.1


times 510-($-$$) db 0				;Fill boot sector
dw 0xAA55					;Boot loader signature


[BITS 64]

startLongMode:

; Interupts are disabled because no IDT has been set up
cli						

; Display:Put long mode kernel here.
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

; Hang the system
jmp $						

