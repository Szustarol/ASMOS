org 0x10000
bits 64
jmp longmode

%include 'constants.asm'
%include 'Programs/add.asm'
%include 'Programs/info.asm'
%include 'Programs/print.asm'
%include 'Programs/reboot.asm'
%include 'Programs/hanoi.asm'

longmode:
	mov rsi, kernelOn
	mov ah, 13
	mov al, 0
	mov dl, 10
	call [PRINT_STRING_ADDR]
	call [KBD_GETCH]
	call [CLR_SCR_ADDR]
	call [KBD_DISCARD]
	call program_info
	.main_loop:
		mov al, 0x0
		;zero flags
		mov byte [sendCommand], al
		.read:
			call [KBD_GETCH]
			cmp al, 0x0	
			je .done_read
			cmp al, SCAN_BACKSPACE
			je .read_backspace
			cmp al, SCAN_ENTER
			je .read_enter
			mov rdi, inputBuffer
			xor rcx, rcx
			mov byte cl, [bufferPointer]
			cmp cl, scrwidth-2
			je .done_read
			add rdi, rcx
			mov byte [rdi], al
			inc cl
			mov byte [bufferPointer], cl
			mov rsi, inputBuffer
			mov ah, 23
			mov al, 1
			mov dl, 11
			call [PRINT_STRING_ADDR]
			jmp .done_read
			.read_backspace:
				xor rbx, rbx
				mov byte bl, [bufferPointer]
				cmp bl, 0
				je .done_read
				dec bl
				mov byte [bufferPointer], bl
				lea rdi, [inputBuffer + rbx]
				mov byte [rdi], ' '
				;call [CLR_SCR_ADDR]
				mov rsi, inputBuffer
				mov ah, 23
				mov al, 1
				mov dl, 11
				call [PRINT_STRING_ADDR]
				jmp .done_read
			.read_enter:
				mov bl, 1
				mov byte [sendCommand], bl
				call [CLR_SCR_ADDR]
				jmp .done_read

		.done_read:
		mov al, [sendCommand]
		cmp al, 0
		je .no_command;if should parse the command
			xor bl, bl
			mov byte [sendCommand], bl
			mov rsi, inputBuffer
			call [CMD_PARSE_ADDR]
			mov rdi, inputBuffer
			mov rcx, 256
			mov al, 0
			rep stosb
			mov byte [bufferPointer], 0
			mov rbx, [COMMAND_ID_ADDR]
			mov byte al, [rbx]
			cmp al, PROG_PRINT_ID
			jl .wrong_command
			je .print_cmd
			jg .pcheck_info
			.print_cmd:
				mov byte [print_ln_flag], 0
				call program_print
				jmp .no_command
			.pcheck_info:
				cmp al, PROG_INFO_ID
				jg .pcheck_reboot
				call program_info
				jmp .no_command
			.pcheck_reboot:
				cmp al, PROG_REBOOT_ID
				jg .pcheck_println
				call program_reboot
				jmp .no_command
			.pcheck_println:
				cmp al, PROG_PRINTLN_ID
				jg .pcheck_add
				mov byte [print_ln_flag], 1
				call program_print
				jmp .no_command
			.pcheck_add:
				cmp al, PROG_ADD_ID
				jg .pcheck_sub
				mov byte [subflag], 0
				call program_add
				jmp .no_command
			.pcheck_sub:
				cmp al, PROG_SUB_ID
				jg .pcheck_hanoi
				mov byte [subflag], 1
				call program_add
				jmp .no_command
			.pcheck_hanoi:
				cmp al, PROG_HANOI_ID
				jg .wrong_command
				call program_hanoi
				jmp .no_command

		.wrong_command:
			mov rsi, cmdNotFound
			mov ah, 2
			mov al, 1
			mov dl, 11
			call [PRINT_STRING_ADDR]
			jmp .no_command
			
		.no_command:
		jmp .main_loop

	;;rsi - source pointer
	;ah - row
	;al - column
	;dl - color
cmdNotFound		db	"Entered command was not found.", 0x0
kernelOn		db	"Entered kernel. Press any key to start.", 0x0
inputBuffer		times 256 db 0
bufferPointer	db 0
sendCommand		db 0
times 127*512-($-$$) db 0
