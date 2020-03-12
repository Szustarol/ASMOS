
bits 64

keyboard_controler_get_status:
	in al, KBD_CTL_STA_REGS
	ret

keyboard_encoder_read_buffer:
	in al, KBD_ENC_INP_BUFF
	ret

;ah - command
keyboard_encoder_send_command:
	call keyboard_controler_get_status
	test al, KYBRD_CTRL_STATS_MASK_IN_BUF
	jnz keyboard_controler_send_command
	mov al, ah
	out KBD_ENC_CMD_REGS, al
	ret


;ah - command
keyboard_controler_send_command:
	call keyboard_controler_get_status
	test al, KYBRD_CTRL_STATS_MASK_IN_BUF
	jnz keyboard_controler_send_command
	mov al, ah
	out KBD_CTL_CMD_REGS, al
	ret

keyboard_self_test:
	xor rax, rax
	mov ah, 0xAA
	call keyboard_controler_send_command
	.l:	push rbx
	push rax
		call keyboard_controler_get_status
		test al, KYBRD_CTRL_STATS_MASK_OUT_BUF
		jz .l
	call keyboard_encoder_read_buffer
	ret

keyboard_discard_buffer:
	call keyboard_controler_get_status
	test al, KYBRD_CTRL_STATS_MASK_OUT_BUF
	jz .done
	test al, 0x20
	jnz .done
	call keyboard_encoder_read_buffer
	jmp keyboard_discard_buffer
	.done:
	ret

keyboard_getch:
	call keyboard_controler_get_status
	test al, KYBRD_CTRL_STATS_MASK_OUT_BUF
	jz keyboard_getch
	test al, 0x20
	jnz keyboard_getch
	call keyboard_encoder_read_buffer
	test al, 10000000b
	jnz keyboard_getch
	push rbx
	push rax
	xor rbx, rbx
	and rax, 0x00000000000000ff
	.compare_space:
		cmp al, KEY_SPACE
		jne .compare_keys
		mov al, SCAN_SPACE
		jmp .done
	.compare_keys:
		cmp al, KEY_1 
		jge .possible_numeric
		mov al, 0
		jmp .done
	.possible_numeric:
		cmp al, KEY_BACKSPACE
		jg .non_numeric
		sub al, KEY_1
		mov rbx, numMap
		add rbx, rax
		mov byte al, [rbx]
		jmp .done
	.non_numeric:
		cmp al, KEY_Q
		jge .possible_row1
		mov al, 0
		jmp .done
	.possible_row1:
		cmp al, KEY_RETURN
		jg .non_row1
		sub al, KEY_Q
		mov rbx, row1Map
		add rbx, rax
		mov byte al, [rbx]
		jmp .done
	.non_row1:
		cmp al, KEY_A
		jge .possible_row2
		mov al, 0
		jmp .done
	.possible_row2:
		cmp al, KEY_QUOTE
		jg .non_row2
		sub al, KEY_A
		mov rbx, row2Map
		add rbx, rax
		mov byte al, [rbx]
		jmp .done
	.non_row2:
		cmp al, KEY_Z
		jge .possible_row3
		mov al, 0
		jmp .done
	.possible_row3:
		cmp al, KEY_SLASH
		jg .non_row3
		sub al, KEY_Z
		mov rbx, row3Map
		add rbx, rax
		mov byte al, [rbx]
		jmp .done
	.non_row3:
		mov al, 0
		jmp .done
	.done:
	mov byte [alstore], al
	pop rax
	pop rbx
	mov byte al, [alstore]
	ret 

alstore db 0
