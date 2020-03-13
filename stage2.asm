bits 16
org 0x7c00+512
jmp 0x0000:stage2

%include 'constants.asm'

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

printnum:
	;num in bx
	cmp bx, 0
	je .done
		;remainder
		xor dx, dx
		mov ax, bx
		mov cx, 10
		div cx
		mov bx, ax
		mov al, dl
		add al, 48
		mov ah, 0x0e
		int 0x10
		jmp printnum
	.done:
	ret


DAP:
	.size			db	0x10
	.unused			db	0x00
	.sectoread		dw	127
	.destoffset		dw	0x0
	.destsegment	dw	0x0
	.firstsector	dq	0x0

stage2:
	mov si, LoadGood
	call println
	xor ax, ax
	mov ds, ax
	;load remaining kernel sectors
	mov al, [DAP_LOAD_SUPPORTED_ADDR]
	cmp al, 0x0
	je .floppy_load
		mov si, DAP
		mov ax, 0x4200
		mov word [DAP.destoffset], 0x0
		mov word [DAP.destsegment], 0x1000
		mov word [DAP.firstsector], 128
		mov byte dl, [BOOT_DRIVE_ADDR]
		int 0x13
		jnc .load_done
	.floppy_load:
		xor dx, dx
		mov ax, 128
		xor cx, cx
		mov cl, [SECTORS_PER_TRACK_ADDR]
		div cx
		inc dx
		mov [Sector], dl
		;ax constains LBA/SPT
		xor dx, dx
		xor ch, ch
		mov cl, [HEADS_PER_CYLINDER_ADDR]
		div cx
		mov [Head], dl
		mov al, [HEADS_PER_CYLINDER_ADDR]
		mov cl, [SECTORS_PER_TRACK_ADDR]
		mul cl
		mov cx, ax
		mov ax, 128
		xor dx, dx
		div cx
		mov [Cylinder], al
		xor ax, 0x1000
		mov es, ax
		mov bx, 0x0000
		mov ah, 0x02
		mov al, 127
		mov ch, [Cylinder]
		mov cl, [Sector]
		mov dh, [Head]
		mov dl, [BOOT_DRIVE_ADDR]
		int 0x13
	.load_done:
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

Cylinder	db 0
Head		db 0
Sector		db 0
Yes			db	"yes", 0x0
None		db	"Not", 0x0
StackTest	db	"Stack first insert at 0x7c00", 0x0
LoadGood	db	"Successfully entered second stage.", 0x0
GDTGood		db	"GDT Loaded OK", 0x0
align 8
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
		.granularity	db	11001111b
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
	lea edi, [edi*2 + 0xb8000]
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

setup_paging:
	mov ecx, 1024
	mov eax, 0x00
	mov edi, 0x1000
	rep stosd
	mov ecx, 1024
	mov edi, 0x2000
	rep stosd
	mov ecx, 1024
	mov edi, 0x3000
	rep stosd

	mov eax, 0x2000 ; first P3 table
	or eax,  0b11
	mov dword [0x1000], eax ; first p4 table is active and points to first p3 table

	mov eax, 0x3000
	or eax,	0b11
	mov dword [0x2000], eax ; first p3 table is active and points to first p2 table

	mov ecx, 0
	.map_p2:
		mov eax, 0x200000 ;2mb pages
		mul ecx
		or eax, 0b10000011;2mb pages, present, writable
		mov [0x3000 + ecx * 8], eax
		inc ecx
		cmp ecx, 512
		jne .map_p2


	;load address of p4 to c0
	mov eax, 0x1000
	mov cr3, eax
	;enable PAE
	mov eax, cr4
	or eax, 1 << 5
	mov cr4, eax

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


	;;prior to entering longmode - check if CPUID is available
	pushfd ; push flags register
	pop eax
	mov ecx, eax ; store flags

	xor eax, 1 << 21
	push eax
	popfd ; from eax to flags

	pushfd
	pop eax

	push ecx
	popfd ;restore old CPUID
	xor eax, ecx ; should not be zero if the bit was flipped

	jnz .cpuid_good
		mov dl, 4
		mov esi, NOCPUID
		mov edi, 80*7
		call print_32
		jmp $

	.cpuid_good:
	mov dl, 9
	mov esi, CPUIDOK,
	mov edi, 80*7
	call print_32
	;if this point is reached then CPUID is supported
	mov eax, 0x80000000
	cpuid
	cmp eax, 0x80000001
	jb .noLongMode
	;if eax is smaller than 0x80000001 - cpuid longmode probing function is not available - no longmode
	mov eax, 0x80000001
	cpuid
	test edx, 1 << 29 ;;cpuid returns to EDX - bit 29 indicates longmode availability
	jz .noLongMode
	jmp .longAvailable

	.noLongMode:
		mov dl, 4
		mov esi, NOLONG
		mov edi, 80*8
		call print_32
		jmp $

	.longAvailable:
	mov dl, 9
	mov esi, LONGOK
	mov edi, 80*8
	call print_32

	;check for PAE paging
	mov eax, 0x00000001
	cpuid
	test edx, 1 << 6
	jz .NoPAE
	jmp .PAEAvailable
	.NoPAE:
		mov dl, 4
		mov esi, NOPAE
		mov edi, 80*9
		call print_32
	.PAEAvailable:
	mov dl, 9
	mov esi, PAEOK
	mov edi, 80*9
	call print_32


	;set up paging
	call setup_paging

	mov ecx, 0xC0000080
	rdmsr
	or eax, 1 << 8 ; longmode bit
	wrmsr

	mov eax, cr0
	or eax, 1 << 31 ;paging bit
	mov cr0, eax

	lgdt [GDT64_PTR]

	mov dl, 9
	mov esi, OK64
	mov edi, 80*10
	call print_32
	jmp 0x08:mode_64

align 8
GDT64:
	;null descriptor
	dq 0
	;code
	dw 0
    dw 0
    db 0
    db 10011010b
    db 00100000b
    db 0
	;data
	dw 0
	dw 0
	db 0
	db 10010010b
	db 00100000b
	db 0
GDT64_PTR:
	.size		dw	$-GDT64-1
	.address	dd	GDT64

Entered32	db	"Entered protected mode and set up the A20 line.", 0x0
NOCPUID		db	"CPUID is not supported on this architecture.", 0x0
CPUIDOK		db	"CPUID is supported...", 0x00
NOLONG		db	"Longmode (x86_64) not available...", 0x0
LONGOK		db	"Longmode is avaiable, switching to 64-bits", 0x0
PAEOK		db	"PAE Paging is available. Setting up pages", 0x0
NOPAE		db	"PAE Paging unavailable...", 0x0
OK64		db	"64 bit GDT and paging set up, entering longmode", 0x0

bits 64

%include 'Utility/screen.asm'
%include 'Utility/keyboard.asm'
%include 'Utility/commandParser.asm'
%include 'Utility/setCursorPos.asm'

mode_64:
	mov rsp, 0x00EFFFFF
	mov rsi, longmodeOn
	mov ah, 12
	mov al, 0
	mov dl, 10
	call print_string
	call parser_setup
	
	mov qword [PRINT_STRING_ADDR], print_string
	mov qword [CLR_SCR_ADDR], clr_scr
	mov qword [KBD_GETCH], keyboard_getch
	mov qword [KBD_DISCARD], keyboard_discard_buffer
	mov qword [CMD_PARSE_ADDR], parse_command
	mov qword [SET_CUR_POS_ADDR], set_cursor_pos
	call keyboard_self_test
	cmp al, 0x55
	je .kbdok
		mov ah, 13
		mov al, 0
		mov dl, 4
		mov rsi, keyboardNP
		call print_string
		jmp $
	.kbdok:
	jmp 0x10000

numMap		db	"1234567890-=", SCAN_BACKSPACE
row1Map		db	"QWERTYUIOP[]", SCAN_ENTER
row2Map		db	"ASDFGHJKL;'"
row3Map		db	"ZXCVBNM,./"
longmodeOn	db	"Longmode entered Successfully.", 0x0
keyboardNP	db	"Keyboard self test failed.", 0x0
times 127*512-($-$$) db 0
