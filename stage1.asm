org 0x7C00
bits 16
jmp 0x0000:start

%include 'constants.asm'

times 0x20-($-$$) db 0 ; in case bios expects BPB

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

start:
	;setup registers
	mov byte [BOOTDRIVE], dl
	mov byte [BOOT_DRIVE_ADDR], dl
	xor ax, ax
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov ss, ax
	mov sp, 0x7c00; some space is available below
	;set graphics video mode
	mov ax, 0x0003
	int 0x10
	mov si, loadString
	call println
	.loadRemainingSectors:
		;;try to read using DAP
		mov ax, stage2
		mov word [DAP.destoffset], ax
		mov al, 1
		mov byte [DAP.firstsector], al ;little endian
		mov ax, 0x4200
		mov byte dl, [BOOT_DRIVE_ADDR]
		mov si, DAP
		int 0x13
		jnc .DAPDone
		mov si, DAPFail
		call println
		;;try to read as a floppy
		mov byte [DAP_LOAD_SUPPORTED_ADDR], 0x0
		mov ah, 0x02
		mov al, 127
		mov ch, 0
		mov cl, 2
		mov dh, 0
		mov byte dl, [BOOTDRIVE]
		xor bx, bx
		mov es, bx
		mov bx, stage2
		int 0x13
		jnc .floppyDone
		mov si, FLOPPYFail
		call println
		jmp $
	.floppyDone:
	mov si, FLOPPYLoad
	call println
	jmp .loadDone
	.DAPDone:
	mov byte [DAP_LOAD_SUPPORTED_ADDR], 0xff
	mov si, DAPLoad
	call println
	.loadDone:
	;get drive geometry
	mov ah, 0x08
	mov di, 0x0000
	mov byte dl, [BOOTDRIVE]
	int 0x13
	inc dh
	mov [HEADS_PER_CYLINDER_ADDR], dh
	and cl, 0x3f
	mov [SECTORS_PER_TRACK_ADDR], cl
	jmp 0x0000:stage2


loadString	db	"Bootloader OK", 0x0
DAPLoad		db	"DAP Load OK", 0x0
DAPFail		db	"DAP Load Failed", 0x0
FLOPPYLoad	db	"Floppy Load OK", 0x0
FLOPPYFail	db	"Floppy Load FAIL", 0x0

BOOTDRIVE	db	0

DAP:
	.size			db	0x10
	.unused			db	0x00
	.sectoread		dw	127
	.destoffset		dw	0x0
	.destsegment	dw	0x0
	.firstsector	dq	0x0

times 466-($-$$) db 0
;MASTER BOOT RECORD (LBA PROPOSED FORMAT)
MBR:
	.bootable				db	0x80
	.signature1				db	0x14
	.partition_start_h16	dw	0x00
	.systemID				db	0x01
	.signature2				db	0xeb
	.partion_length_h16		dw	0x00
	.partition_start_l32	dd	0x01
	.partition_length_l32	dd	127
;;no more partitions

times 510-($-$$) db 0
dw 0xaa55
stage2:
