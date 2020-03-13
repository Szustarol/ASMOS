bits 64

;ah - row
;al - col
set_cursor_pos:
    xor bx, bx
    xor cx, cx
    mov dl, scrwidth
    mov bl, al
    mov al, ah
    mul dl
    add bx, ax
    ;bx contains offset

    mov dx, 0x3d4
    mov al, 0x0f
    out dx, al

    inc dx
    mov al, bl
    out dx, al

    dec dx
    mov al, 0x0e
    out dx, al

    inc dx
    mov al, bh
    out dx, al
    ret