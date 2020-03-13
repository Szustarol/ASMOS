bits 64

;rax - input number
;rsi - input buffer target
number_to_string:
    push rdi
    mov bl, 0
    cmp rax, 0
    jne .nozero
        mov byte [rsi], '0'
        jmp .dn
    .nozero:
    mov rcx, (1 << 63)
    test rax, rcx
    jz .positive
        mov bl, 1
        neg rax
    .positive:
    mov rdi, rsi
    mov rcx, 10
    .inl:
        xor rdx, rdx
        div rcx
        cmp rax, 0
        jne .remaining
            cmp rdx, 0
            je .done
        .remaining:
        ;remainder in rdx
        ;result in rax
        add dl, '0'
        mov byte [rsi], dl
        inc rsi 
        jmp .inl
    .done:
    cmp bl, 1 ;if negative
    jne .positive2
        mov byte [rsi], '-'
        inc rsi
    .positive2:
    dec rsi
    ;reverse the string
    .rev:
        cmp rdi, rsi
        jge .dn
        mov byte dl, [rdi]
        mov byte dh, [rsi]
        mov byte [rdi], dh
        mov byte [rsi], dl
        inc rdi
        dec rsi
        jmp .rev
    .dn:
    pop rdi
    ret

;rsi - input string
;rax - output number
string_to_number:
    push rbx
    push rcx
    push rdx
    xor rax, rax
    mov byte dl, [rsi]
    cmp dl, '-'
    je .negative
        mov dl, 0
        jmp .done
    .negative:
        inc rsi
        mov dl, 1
    .done:
    .l:
        mov byte dh, [rsi]
        cmp dh, 0x0
        je .la
        sub dh, '0'
        cmp dh, 9
        jg .la
        ;multiply rax by 10
        push rdx
        xor rbx, rbx
        mov bl, dh
        mov rcx, 10
        mul rcx
        add rax, rbx
        pop rdx
        inc rsi
        jmp .l
    .la:
    cmp dl, 1
    je .neg
    jmp .noneg
    .neg:
        neg rax
    .noneg:
    pop rdx
    pop rcx
    pop rbx
    ret

program_add:
    mov ah, 2
    mov al, 2
    mov dl, 11
    mov rsi, Addingstr
    cmp byte [subflag], 0
    je .addn
        mov rsi, Substrstr
    .addn:
    call [PRINT_STRING_ADDR]
    xor rcx, rcx
    xor rdx, rdx
    mov qword [Result], rcx
    .in:
        xor rcx, rcx
        push rdx
        xor rdx, rdx
        .zero_in:
            mov byte [NumBuffer + rdx], 0
            inc rdx
            cmp rdx, 30
            jl .zero_in
        pop rdx
        mov rbx, [COMMAND_POINTER_ADDR]
        mov byte bl, [rbx+rdx]
        and rbx, 0x00000000000000ff
        cmp rbx, 0
        je .done
        dec rbx
        mov rsi, [COMMAND_BUFFER_ADDR]
        add rsi, rbx
        .inl:
            cmp byte [rsi], ' '
            je .dn_in
            cmp byte [rsi], 0x0
            je .dn_in
            cmp byte [rsi], '-'
            je .check_rcx
            jmp .no_min
            .check_rcx:
                cmp rcx, 0
                jne .dn_in
            .no_min:
            push rdx
            mov byte dl, [rsi]
            mov byte [NumBuffer+rcx], dl
            pop rdx
            inc rcx
            inc rsi
            jmp .inl
        .dn_in:
        inc rdx
        push rdx
        inc ah,
        mov al, 2
        mov dl, 11
        mov rsi, NumBuffer
        call [PRINT_STRING_ADDR]
        pop rdx
        mov rsi, NumBuffer
        push rax
        call string_to_number
        push rcx
        mov byte cl, [subflag]
        cmp cl, 0
        je .add
            cmp rdx, 1
            je .add
            neg rax
            add qword rax, [Result]
            jmp .arm_d
        .add:
            add qword rax, [Result]
        .arm_d:
        mov [Result], rax
        pop rcx
        pop rax
        mov byte [AhStore], ah
        jmp .in
    .done:
    xor rdx, rdx
    .zero_in2:
        mov byte [NumBuffer + rdx], 0
        inc rdx
        cmp rdx, 30
        jl .zero_in2
    mov qword rax, [Result]
    mov rsi, NumBuffer
    call number_to_string
    mov al, 2
    mov byte ah, [AhStore]
    add ah, 2
    mov dl, 11
    mov rsi, Resultstr
    call [PRINT_STRING_ADDR]
    add al, 10
    mov rsi, NumBuffer
    call [PRINT_STRING_ADDR]
    ret

subflag     db  0
AhStore     db  0
Result      dq  0
NumBuffer   times 30 db 0
Addingstr   db  "Adding: ", 0x0
Substrstr   db  "Substracting: ", 0x0
Resultstr    db  "Result: ", 0x0