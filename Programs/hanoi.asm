bits 64


drawBuff    times 31 db 0x0, 0x0
;ah - row
;al - center position
;dh - size
draw_disk:
    push rax
    push rbx
    push rcx
    push rdx
    inc al
    mov rcx, 31
    mov rdi, drawBuff
    push rax
    mov al, 0x0
    rep stosb
    pop rax

    mov dl, 0xE
    test dh, 1 ; check if parity
    jz .par
    mov dl, 0xF
    .par:
    mov rsi, drawBuff+16
    mov byte [drawBuff+16], 219
    mov rcx, 1
    .draw:
        cmp dh, 2
        jge .cnt
        jmp .draw_f2
        .cnt:
        add rsi, rcx
        mov byte [rsi], 219
        sub rsi, rcx
        sub rsi, rcx
        mov byte [rsi], 219
        add rsi, rcx
        inc rcx
        sub dh, 2
        jmp .draw
    .draw_f2:
        cmp dh, 0
        je .drdn
        add rsi, rcx
        mov byte [rsi], 221
        sub rsi, rcx
        sub rsi, rcx
        mov byte [rsi], 222
        add rsi, rcx
        inc rcx
    .drdn:
    mov bl, ah
    and rax, 0x00000000000000ff
    sub rax, rcx
    mov ah, bl
    mov rsi, drawBuff+16
    sub rsi, rcx
    inc rsi

    call [PRINT_STRING_ADDR]
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

pillarpos1  equ 10
pillarpos2  equ 26
pillarpos3  equ 42

hanoi_block db 219, 0x0
hanoi_base times 11 db(219)
    times 5 db(' ')
    times 11 db(219)
    times 5 db(' ')
    times 11 db(219)
    db 0x0
hanoi_frame_draw:
    ;10 - green
    mov ah, 15
    mov al, 5
    mov dl, 10
    mov rsi, hanoi_base
    call [PRINT_STRING_ADDR]
    mov rcx, 10
    mov ah, 15
    .lp:
        dec ah
        mov rsi, hanoi_block
        mov al, pillarpos1
        call [PRINT_STRING_ADDR]
        mov rsi, hanoi_block
        mov al, pillarpos2
        call [PRINT_STRING_ADDR]
        mov rsi, hanoi_block
        mov al, pillarpos3
        call [PRINT_STRING_ADDR]
        loop .lp
    ret

diskPositions1  db  0xff
diskPositions2  db  0
diskPositions3  db  0

;rax - positions addr
;rbx - stick pos addr
stick_draw:
    mov rsi, rax;diskpositons
    mov ah, 14
    mov byte al, bl
    mov cl, 8
    .l1:
        dec cl
        mov byte dl, [rsi]
        mov bl, 1
        shl bl, cl
        test dl, bl
        jnz .drw
        jmp .ndrw
        .drw:
            mov dh, cl
            inc dh
            push rsi
            call draw_disk
            pop rsi
            dec ah
        .ndrw:
        cmp cl, 0
        jne .l1
    ret

hanoiDesc   db  "Hanoi solver. Steps: "
hanoiDescEnd times 40 db 0x0
steps  dq   0
hanoiP      db  "Press any key for the next step...", 0x0

;assume add program is included first, so number to string function is present

program_hanoi: 
    .hanoi_draw_loop:
        mov rcx, 40
        mov al, 0
        mov rdi, hanoiDescEnd
        rep stosb
        mov qword rax, [steps]
        mov rsi, hanoiDescEnd
        call number_to_string
        mov rsi, hanoiDesc
        mov ah, 2
        mov al, 2
        mov dl, 11
        call [PRINT_STRING_ADDR]
        call hanoi_frame_draw
        mov rax, diskPositions1
        mov bl, pillarpos1
        call stick_draw   
        mov rax, diskPositions2
        mov bl, pillarpos2
        call stick_draw       
        mov rax, diskPositions2
        mov bl, pillarpos2
        call stick_draw      
        mov rsi, hanoiP
        mov ah, 17
        mov al, 2
        mov dl, 11
        call [PRINT_STRING_ADDR]   
        call [KBD_GETCH]
        jmp .hanoi_draw_loop  
    ret