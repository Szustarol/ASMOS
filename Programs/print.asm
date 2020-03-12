program_print:
    mov rcx, 0
    mov al, 2
    mov ah, 3
    mov dl, 11
    xor rbx, rbx
    .in:
        mov rbx, [COMMAND_POINTER_ADDR]
        mov byte bl, [rbx+rcx]
        and rbx, 0x00000000000000ff
        cmp rbx, 0
        je .done
        dec rbx
        mov byte dh, [print_ln_flag]
        cmp dh, 1
        je .newline
            mov al, bl
            add al, 2
            jmp .cmp_done
        .newline:
            inc ah
        .cmp_done:
        mov rsi, [COMMAND_BUFFER_ADDR]
        add rsi, rbx
        call [PRINT_STRING_ADDR]
        inc rcx
        jmp .in
    .done:
    ret

print_ln_flag   db 0