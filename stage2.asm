bits 16
org 0x7c00+512
jmp 0x0000:stage2

println:
	mov ah, 0x0e
	.inner:
		lodsb 
		cmp al, 0x0
		je .print_done
		int 0x10
		jmp .inner
	.print_done:
	mov al, 0xD
	int 0x10
	mov al, 0xA
	int 0x10
	ret

stage2:
	mov si, LoadGood
	call println
	cli
	lgdt [GDT_PTR]
	sei
	mov si, GDTGood
	call println
	;set cr0 bit 1 to indicate protected mode
	cli
	mov eax, cr0
	or eax, 1
	mov cr0, eax
	jmp 0x08:BITS_32

LoadGood	db	"Successfully entered second stage.", 0x0
GDTGood	db	"GDT Loaded OK", 0x0
GDT:
	GDT_NULL_DESC:
		.null:		dq	0
	GDT_CODE_DESC:
		.segment_limit	dw	0xffff; addressable memory : 0x0000-0xffff
		.base_low	dw 	0x0000;
		.base_middle	db	0x00;
		.access:	db	10011010b ; no acc bit, readable, code descriptor, code/data sector, ring 0
		.granularity	db	11001111b ; 32-bit segment, bounded by 4KB
		.base_high	db	0x00;
	GDT_DATA_DESC:
		.segment_limit	dw	0xffff
		.base_low	dw	0x0000
		.base_middle	db 	0x00
		.access	db	10010010b ; data descriptor, 
		.grannularity	db	11001111b
		.base_high	db	0x00
GDT_PTR:
	.size		dw	$-GDT-1
	.address	dd	GDT

bits 32
BITS_32:
	;set data descriptor to 0x10 (as in GDT)
	mov ax, 0x10
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov esp, 0x7c00
	jmp $
	
times 127*512-($-$$) db 0
