org 0x10000
bits 64
jmp longmode

%include 'constants.asm'

longmode:
	mov rsi, kernelOn
	mov ah, 13
	mov al, 0
	mov dl, 10
	call [PRINT_STRING_ADDR]
	jmp $

	;;rsi - source pointer
	;ah - row
	;al - column
	;dl - color
kernelOn	db	"Entered kernel. Press any key to start.", 0x0
times 127*512-($-$$) db 0
