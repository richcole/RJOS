BITS 64
	
init_64:
	xor rdi, rdi
	mov rcx, 32
	
hang:
	jmp hang

        ;; end the bootsector
	times 500-($-$$) db 0 
	db 0x55
	db 0xAA
	