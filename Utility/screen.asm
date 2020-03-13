bits 64

clr_scr:
	mov rdi, 0xb8000
	mov rcx, scrwidth*scrheight
	mov ah, 11
	mov al, 0x0
	rep stosw
	mov al, 205
	mov ah, 13
	mov rcx, scrwidth
	mov rdi, 0xb8000
	rep stosw
	mov rcx, scrwidth
	mov rdi, 0xb8000 + 2*(scrheight-1)*scrwidth
	rep stosw
	mov al, 186
	mov rdi, 0xb8000 + scrwidth*2
	mov ecx, scrheight-2
	.v1:
		mov word [rdi], ax
		mov word [rdi+scrwidth*2-2], ax
		add rdi, scrwidth*2
		loop .v1
	mov rdi, 0xb8000 + scrwidth*2*(scrheight-3) + 2
	mov ecx, scrwidth - 2
	mov al, 205
	.v2:
		mov word [rdi], ax
		add rdi, 2
		loop .v2
	mov al, 201
	mov word [0xb8000], ax
	mov al, 188
	mov word [0xb8000 + scrwidth*scrheight*2-2], ax
	mov al, 187
	mov word [0xb8000 + scrwidth*2-2], ax
	mov al, 200
	mov word [0xb8000 + (scrheight-1)*scrwidth*2], ax
	mov al, 204
	mov word [0xb8000 + (scrheight-3)*scrwidth*2], ax
	mov al, 185
	mov word [0xb8000 +  (scrheight-2)*scrwidth*2-2], ax
	mov al, 1
	mov ah, 23
	call [SET_CUR_POS_ADDR]
	ret 

;;rsi - source pointer
;ah - row
;al - column
;dl - color
print_string:
	push rcx
	push rdx
    push rax
	mov cl, al
	mov ch, ah
	xor rax, rax
	mov al, ch ; row
	mov bl, scrwidth*2
	mul bl
	xor rdi, rdi
	add rdi, rax
	xor rax, rax
	mov al, cl
	mov bl, 2
	mul bl
	add rdi, rax
	lea rdi, [rdi + 0xb8000]
	.inner:
		lodsb
		cmp al, 0x0
		je .done
		mov byte [rdi], al
		mov byte [rdi+1], dl
		add rdi, 2
		jmp .inner
	.done:
    pop rax
	pop rdx
	pop rcx
	ret