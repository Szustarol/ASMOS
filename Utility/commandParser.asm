bits 64
;this file is included in stage2.asm, so
;constants.asm is already present


;compares strings until 0x0 or space
;rax - string 1 ptr 
;rbx - string 2 ptr
;return:
;rcx - length of strings if equal, 0 if not equal
space_compare:
    push rax
    push rbx
    push rdx

    mov rcx, 0
    .inner_loop:
        mov byte dl, [rax]
        mov byte dh, [rbx]
        cmp dl, ' '
        je .possible_enddl
        cmp dl, 0x0
        je .possible_enddl
        cmp dh, ' '
        je .possible_enddh
        cmp dh, 0x0
        je .possible_enddh

        cmp dl, dh
        je .cont
        mov rcx, 0
        jmp .end

        .cont:
        inc rax
        inc rbx
        inc rcx
        jmp .inner_loop

        .possible_enddh:
            cmp dl, ' '
            je .end
            cmp dl, 0x0
            je .end
            mov rcx, 0
            jmp .end

        .possible_enddl:
            cmp dh, ' '
            je .end
            cmp dh, 0x0
            je .end
            mov rcx, 0
            jmp .end
    .end:
    pop rdx
    pop rbx
    pop rax
    ret

parser_setup:
    mov qword [COMMAND_ID_ADDR], commandID
    mov qword [COMMAND_BUFFER_ADDR], commBuffer
    mov qword [COMMAND_POINTER_ADDR], commptr
    ret

;rsi - command buffer
parse_command:
    ;zero buffers:
    mov rdi, commandID
    mov rcx, CMDDATA_END-CMDDATA
    mov al, 0
    rep stosb
    ;part 1 - translates command name to command ID
    mov rax, rsi
    mov rbx, printName
    call space_compare
    cmp rcx, 0
    jne .got_print
    ;command not found:
    mov rbx, infoName
    call space_compare
    cmp rcx, 0
    jne .got_info
    mov rbx, rebootName
    call space_compare
    cmp rcx, 0
    jne .got_reboot
    mov rbx, printlnName
    call space_compare
    cmp rcx, 0
    jne .got_println
    jmp .done
    .got_print:
        mov byte [commandID], PROG_PRINT_ID
        jmp .parse_params
    .got_info:
        mov byte [commandID], PROG_INFO_ID
        jmp .parse_params
    .got_reboot:
        mov byte [commandID], PROG_REBOOT_ID
        jmp .parse_params
    .got_println:
        mov byte [commandID], PROG_PRINTLN_ID
        jmp .parse_params
    .parse_params:
        xor rdx, rdx
        add rax, rcx
        xor rcx, rcx
        inc rax
        mov byte [commptr], 1
        .cmp:
            mov byte dl, [rax]
            cmp dl, 0x0
            je .done_parsing
            cmp dl, ' '
            je .new
            mov byte [commBuffer + rcx], dl
            inc rax
            inc rcx
            jmp .cmp
            .new:
                inc dh
                push rdx
                mov dl, dh
                and rdx, 0x00000000000000ff
                add cl, 2
                mov byte [commptr + rdx], cl
                sub cl, 2
                mov byte [commBuffer + rcx], 0x0
                pop rdx
                inc rax
                inc rcx
            jmp .cmp
        .done_parsing:
            
    .done:
    ret

printName   db  "PRINT", 0x0
infoName    db  "INFO", 0x0
rebootName  db  "REBOOT", 0x0
printlnName db  "PRINTLN", 0x0
CMDDATA:
commandID   db  0
commBuffer  times 100 db 0
commptr     times 40 db 0 ; up to 40 parameters inside a command
CMDDATA_END: