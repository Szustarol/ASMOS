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

;al - mov1
;ah - mov2
move_disk:
    push rcx
    mov cl, 0
    .l:
        mov ch, 1
        shl ch, cl
        test al, ch
        jnz .altoah
        test ah, ch
        jnz .ahtoal
        inc cl
        jmp .l
    .altoah:
        not ch
        and al, ch
        not ch
        or ah, ch
        jmp .dn
    .ahtoal:
        not ch
        and ah, ch
        not ch
        or al, ch
    .dn:
    pop rcx
    ret


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

numdisks db 8
numiters dw 0
kbduse   db 0

pillarposreal times 3 db 0

program_hanoi: 
    ;parse number of disks
    mov byte [numdisks], 0
    mov byte [numiters], 0
    mov byte [kbduse], 0
    mov qword [steps], 0
    xor rcx, rcx
    mov al, 0
    jmp .in_loop
    .prev_loop:
        inc rcx
    .in_loop:
        mov rbx, [COMMAND_POINTER_ADDR]
        mov byte bl, [rbx+rcx]
        cmp bl, 0
        je .loop_over
        dec bl
        and rbx, 0x00000000000000ff
        mov rsi, [COMMAND_BUFFER_ADDR]
        add rsi, rbx
        mov byte dl, [rsi]
        sub dl, '0'
        cmp dl, 0
        jle .prev_loop
        cmp dl, 8
        jg .prev_loop
        mov al, dl
        jmp .loop_over
    .loop_over:
    mov byte [diskPositions2], 0
    mov byte [diskPositions3], 0

    cmp al, 0
    jne .alok
    mov al, 1

    .alok:

    mov [numdisks], al
    mov cl, 0
    mov dh, 0
    .lp:
        cmp al, 0
        je .dnlp
        mov dl, 1
        shl dl, cl
        inc cl
        dec al
        or dh, dl
        jmp .lp
    .dnlp:

    mov byte [diskPositions1], dh

    mov cl, [numdisks]
    mov ax, 1
    shl ax, cl
    sub ax, 1
    mov word [numiters], ax

    mov byte al, pillarpos1
    mov byte [pillarposreal], al
    mov byte al, pillarpos2
    mov byte [pillarposreal+1], al
    mov byte al, pillarpos3
    mov byte [pillarposreal+2], al
    mov byte al, [numdisks]
    test al, 1
    jnz .hanoi_draw_loop
    mov byte al, pillarpos2
    mov byte [pillarposreal+2], al
    mov byte al, pillarpos3
    mov byte [pillarposreal+1], al
    .hanoi_draw_loop:
        call [CLR_SCR_ADDR]
        xor rax, rax
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
        mov bl, [pillarposreal]
        call stick_draw   
        mov rax, diskPositions2
        mov bl, [pillarposreal+1]
        call stick_draw       
        mov rax, diskPositions3
        mov bl, [pillarposreal+2]
        call stick_draw      
        mov rsi, hanoiP
        mov ah, 17
        mov al, 2
        mov dl, 11
        call [PRINT_STRING_ADDR]   
        cmp byte [kbduse], 0
        jne .nokbd
        call [KBD_GETCH]
        ;calculate div
        .nokbd:
        xor rdx, rdx
        mov qword rax, [steps]
        cmp word ax, [numiters]
        je .hanoi_done
        inc rax
        cmp word ax, [numiters]
        jne .noincrease
            mov byte [kbduse], 1
        .noincrease:
        mov qword [steps], rax
        mov rcx, 3
        div rcx
        cmp rdx, 1
        je .step1
        cmp rdx, 2
        je .step2
        .step3:
            mov byte al, [diskPositions3]
            mov byte ah, [diskPositions2]
            call move_disk
            mov byte [diskPositions3], al
            mov byte [diskPositions2], ah
            jmp .dn
        .step2:
            mov byte al, [diskPositions1]
            mov byte ah, [diskPositions2]
            call move_disk
            mov byte [diskPositions1], al
            mov byte [diskPositions2], ah
            jmp .dn
        .step1:
            mov byte al, [diskPositions1]
            mov byte ah, [diskPositions3]
            call move_disk
            mov byte [diskPositions1], al
            mov byte [diskPositions3], ah
        .dn:
        jmp .hanoi_draw_loop  
    .hanoi_done:
    mov ah, 20
    mov al, 2
    mov dl, 11
    mov rsi, hanoiDoneStr
    call [PRINT_STRING_ADDR]
    ret

    hanoiDoneStr    db  "Solving completed. You can now type commands.", 0x0