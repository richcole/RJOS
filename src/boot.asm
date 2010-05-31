[ORG 0x00007C00]
[BITS 16]

	
bootloader:	
	
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

  				; enable address line A20
in al,92h			; read from port 92h
or al,02h			; or with 02h to turn on A20
out 92h,al			; write the result to the port

;; reset the floppy drive
mov ax,0x0                      ; function 0x0 (reset drive)
mov dx,0x0                      ; drive 0
int 0x13                        

;; Load kernel from floppy disk (0x200 * 0xd = 6656b)
mov ah,0x02			; - function 0x2 (read sector)
mov al,0x0d                     ; - 0xd sectors 
mov bx,0xd000			; - store at 200
mov cx,0x0002			; - track 0, sector 2 (sectors are 1 based)
mov dx,0x0000                   ; - head 0, drive 0
int 0x13
jc $                            ; hang if did not succeed

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

;;; We will allocate the following a single 2M page via
;;;   PML4 (Page Map Level 4 Base Address) 0xa000
;;;     - a single entry pointing to 0xb000
;;;     - zeros for the rest (will create page faults if accessed)
;;;   PDPE (Page Directory Pointer Table) - at 0xb000
;;;     - a single entry pointing to 0xc000
;;;   PDE (Page Directory Offset Table) - at 0xc000
;;;     - a single entry pointing to 0x0000
;;;     - the page type is a 2M page
;;;   Space occupied by the table is from 0xa000 to 0xc000
;;;   Flags: 
;;;   0   P   - present indicates the page is loaded
;;;   1   R/W - 0 means read only
;;;   2   U/S - 0 means supervisor only
;;;   3   PWT - page level write through, 1 means write through, 0 means write back
;;;   4   PCD - 1 means not cacheable
;;;   5   A   - accessed
;;;   6   D   - dirty
;;;   7   PS  - page size (set on PDE for 2M when in PAE mode)
;;;   8   G   - global page 
;;;   9   AVL - user defined meaning
;;;   10  PAT - Page Attribute Table Mechanism
;;;   63  NX  - No execute

xor bx,bx			; zero bx
mov es,bx			; zero es
cld				; clear the address flag

;;; PML4 addr 0xa000, value 0xb00f
;;; - flags: MBZ=0, IGN=0, A=0, PCD=0, PWT=1, U/S=1, R/W=1, P=1
;;; - note that the bottom 12 bits must be zero for a base table address
;;;   the address is then orded with the flags which works because
;;;   the bottom 12 bits of the address are zero leaving room for flags
mov di,0xa000			; set address to write to 0xa000 - 40960
mov ax,0xb00f			; set value to write to 0xb00f
stosw				; store value in ax at index di

;;; Fill rest of PML4 with zeros, 4k-2 bytes
;;; - flags: MBZ=0, IGN=0, A=0, PCD=0, PWT=0, U/S=0, R/W=0, P=0
;;; - flags: AVL=0
;;; - since P=0, any reference here will cause a page fault
xor ax,ax			; zero ax
mov cx,0x07ff			; number of words to write = 2047
rep stosw			; store values cx times

;;; PDPE addr 0xb000, value 0xc00f
;;; - flags: MBZ=0, IGN=0, A=0, PCD=0, PWT=1, U/S=1, R/W=1, P=1
;;; - flags: AVL=0
mov ax,0xc00f                   ; change value to write to 0xc00f
stosw                           ; store value

;;; fill the rest with zeros, since P=0, reference will cause fault
xor ax,ax                       ; set value to store to zero
mov cx,0x07ff                   ; number of entries to write
rep stosw			; store values cx times

;;; PDE addr 0xc000, value of 0x18f
;;; - flags: AVL=0, PAT=0, G=1
;;; - flags: PS=1, IGN=0, A=0, PCD=0, PWT=1, U/S=1, R/W=1, P=1
mov ax,0x018f			; set value to write to 0x018f
stosw				; store values

xor ax,ax			; set value to write to zero
mov cx,0x07ff			; number of entries to write
rep stosw			; store values

;;; Enter long mode
;;; - flags: DE=0, TSD=0, PVI=0, VME=0
;;; - flags: PSE=0, PAE=1, MCE=0, PGE=1,
;;; - flags: PCE=0, OSF=0, OSX=0
mov eax,10100000b		; set PAE and PGE
mov cr4,eax			 

;;; load the PML4 address 0xa000 into the cr3 reg
;;; - note that the bottom 12 bits are zero leaving room for flags
;;; - PWT (bit 3) (page level writethrough)  set to 0
;;; - PCD (bit 4) (page level cache disable) set to 0
mov edx,0x0000a000		; set cr3 to point tob PML4
mov cr3,edx


;;; Enable Long Mode
mov ecx,0xC0000080		; specify EFER as the MSR to be read
rdmsr				; read model specific register
or eax,0x00000100		; set EFER.LME=1
wrmsr				; write model specific registers

mov ebx,cr0			; read CR0
or ebx,0x80000001		; set PE=1, PG=1
mov cr0,ebx			; write CR0

;;; setup the global descriptor table
lgdt [gdt.pointer]		; load 80-bit gdt.pointer below
jmp gdt.code:0xd000		; load cs with 64 bit segment and flush
				; the instruction cache	

;;; beginning of the global descriptor table
gdt:
dq 0x0000000000000000		; 64 bit null descriptor

.code equ $ - gdt		; define code to be $ - gdt
dq 0x0020980000000000           ; what is this word?

.data equ $ - gdt               ; define data to be $ - gdt
dq 0x0000900000000000           ; what is this word?

.pointer:		      
dw $-gdt-1			; size of the global descriptor table
dq gdt				; address of the global descriptor table

times 510-($-$$) db 0		; fill remainder of sector with zeros
dw 0xaa55			; boot sector signature


