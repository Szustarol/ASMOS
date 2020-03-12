program_reboot:
    mov dl, 11
    mov ah, 2
    mov al, 2
    mov rsi, rebootString
    call [PRINT_STRING_ADDR]
    call [KBD_GETCH]
    mov rsi, rebootingString
    mov ah, 3
    mov al, 2
    call [PRINT_STRING_ADDR]
    .inl:
        in al, KBD_CTL_STA_REGS
        test al, KYBRD_CTRL_STATS_MASK_IN_BUF
        jnz .inl
        mov al, 0xfe ;reboot
        out KBD_CTL_CMD_REGS, al
    hlt
    ret

rebootString db "Press any key to reboot...", 0x0
rebootingString db "Rebooting...", 0x0