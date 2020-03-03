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
	call println
	mov si, LoadGood
	call println
	cli
	lgdt [GDT_PTR]
	sti
	mov si, GDTGood
	call println
	;set cr0 bit 1 to indicate protected mode
	cli
	mov eax, cr0
	or eax, 1
	mov cr0, eax
	jmp 0x08:BITS_32

Yes			db	"yes", 0x0
None		db	"Not", 0x0
StackTest	db	"Stack first insert at 0x7c00", 0x0
LoadGood	db	"Successfully entered second stage.", 0x0
GDTGood		db	"GDT Loaded OK", 0x0
GDT:
	GDT_NULL_DESC:
		.null:			dq	0
	GDT_CODE_DESC:
		.segment_limit	dw	0xffff; addressable memory : 0x0000-0xffff
		.base_low		dw 	0x0000;
		.base_middle	db	0x00;
		.access:		db	10011010b ; no acc bit, readable, code descriptor, code/data sector, ring 0
		.granularity	db	11001111b ; 32-bit segment, bounded by 4KB
		.base_high		db	0x00;
	GDT_DATA_DESC:
		.segment_limit	dw	0xffff
		.base_low		dw	0x0000
		.base_middle	db 	0x00
		.access			db	10010010b ; data descriptor,
		.grannularity	db	11001111b
		.base_high		db	0x00
GDT_PTR:
	.size		dw	$-GDT-1
	.address	dd	GDT

bits 32

keyboard_wait_input:
	in al, 0x64
	test al, 10b ; test bit 1 - input buffer status
	jnz keyboard_wait_input
	ret

keyboard_wait_output:
	in al, 0x64
	test al, 1b ; test bit 0 - output buffer status
	jz keyboard_wait_output
	ret

print_32:
	push edx
	mov eax, 2
	mul edi
	mov edi, eax
	add edi, 0xb8000
	pop edx
	.inner:
		lodsb
		cmp al, 0x0
		je .done
		mov [edi], al
		mov [edi+1], dl
		add edi, 2
		jmp .inner
	.done:
	ret

BITS_32:
	;set data descriptor to 0x10 (as in GDT)
	mov ax, 0x10
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov esp, 0x7c00
	;; enable a20 line

	call keyboard_wait_input
	mov al, 0xAD ; disable keyboard
	out 0x64, al ; write to keyboard register to disable it
	call keyboard_wait_input

	mov al, 0xD0 ;read output port
	out 0x64, al
	call keyboard_wait_output

	in al, 0x60
	push eax
	call keyboard_wait_input

	mov al, 0xD1
	out 0x64, al ;write output port
	call keyboard_wait_input
	pop eax
	or al, 2
	out 0x60, al
	call keyboard_wait_input

	mov al, 0xAE
	out 0x64, al ;enable keyboard
	call keyboard_wait_input

	mov dl, 9
	mov esi, Entered32
	mov edi, 80*6
	call print_32

	jmp $


Entered32	db	"Entered protected mode and set up the A20 line.", 0x0
times 127*512-($-$$) db 0
