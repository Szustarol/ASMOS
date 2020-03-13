program_info:
    mov ah, 2
    mov dl, 11
    mov rsi, infoString
    .inner_loop:
        mov al, 2
        call [PRINT_STRING_ADDR]
        inc ah
        cmp rsi, infoStringEnd+1
        je .done
        jmp .inner_loop
    .done:
    ret


infoString db "MyOS developed by Karol Szustakowski, 2020", 0x0, \
"Available commands: ", 0x0, \
"    -INFO - display this page ", 0x0, \
"    -PRINT [PARAMS] - print a message", 0x0, \
"    -PRINTLN [PARAMS] - print each param in a new line", 0x0, \
"    -ADD [PARAMS] - add numbers in [PARAMS] and display result", 0x0, \
"    -SUB [PARAMS] - substract numbers in [params] and display result", 0x0, \
"    -HANOI [N=1-8]- hanoi tower solver, with N disks", 0x0, \
"    -REBOOT - restart the system."
infoStringEnd: db 0x0