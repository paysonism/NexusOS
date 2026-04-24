global app_terminal_blob_start
global app_terminal_blob_end
app_terminal_blob_start:
app_terminal_draw:
    push rbx
    push r12
    push r13
    push r14

    mov rbx, rdi
    mov r14, rdi
    mov r12, [r14 + TERM_CTX_X]
    mov r13, [r14 + TERM_CTX_Y]
    mov r10, [r14 + TERM_CTX_W]
    mov r11, [r14 + TERM_CTX_H]

    ; Background
    mov rdi, r12
    add rdi, BORDER_WIDTH
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT
    mov rdx, r10
    sub rdx, BORDER_WIDTH * 2
    mov rcx, r11
    sub rcx, TITLEBAR_HEIGHT + BORDER_WIDTH
    cmp rcx, 0
    jle .term_draw_done
    mov r8, 0x00111111
    mov rax, 2
    mov r10, rcx
    syscall

    ; Simple header
    mov rdi, r12
    add rdi, BORDER_WIDTH + 6
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 4
    lea rdx, [rel term_blob_welcome]
    mov ecx, 0x0000DD00
    mov r8, 0x00111111
    mov rax, 3
    mov r10, rcx
    syscall

    ; Last echoed command or hint
    mov rdi, r12
    add rdi, BORDER_WIDTH + 6
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 20
    lea rdx, [r14 + TERM_STATE_ECHO]
    cmp byte [rdx], 0
    jne .term_have_echo
    lea rdx, [rel term_blob_help_hint]
.term_have_echo:
    mov ecx, 0x00CCCCCC
    mov r8, 0x00111111
    mov rax, 3
    mov r10, rcx
    syscall

    ; Draw prompt "C:\> "
    mov rdi, r12
    add rdi, BORDER_WIDTH + 6
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 4
    add rsi, 28
    lea rdx, [rel term_blob_prompt]
    mov rcx, 0x0000FF00
    mov r8, 0x00111111
    mov rax, 3
    mov r10, rcx
    syscall

    ; Draw input text
    mov rdi, r12
    add rdi, BORDER_WIDTH + 6 + 40
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 4
    add rsi, 28
    lea rdx, [r14 + TERM_STATE_INPUT]
    mov rcx, 0x00FFFFFF
    mov r8, 0x00111111
    mov rax, 3
    mov r10, rcx
    syscall

    ; Draw cursor
    mov eax, [r14 + TERM_STATE_CURSOR]
    imul eax, FONT_WIDTH
    add eax, BORDER_WIDTH + 6 + 40
    mov rdi, r12
    add edi, eax
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 4
    add rsi, 28
    lea rdx, [rel term_blob_cursor]
    mov rcx, 0x00FFFFFF
    mov r8, 0x00111111
    mov rax, 3
    mov r10, rcx
    syscall

.term_draw_done:
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

app_terminal_kernel_draw:
    jmp app_terminal_draw

app_terminal_click:
    ret

; Key handler: RDI=window_ptr, ESI=key_event [pressed:8|mods:8|ascii:8|scan:8]
app_terminal_key:
    push rbx
    push rcx
    push rdx
    push r14

    mov rbx, rdi
    mov r14, rdi

    ; Extract ASCII
    mov eax, esi
    shr eax, 8
    and eax, 0xFF
    test eax, eax
    jz .term_key_done

    ; Enter
    cmp al, 13
    je .term_enter
    ; Backspace
    cmp al, 8
    je .term_backspace

    ; Normal printable char
    cmp al, 32
    jl .term_key_done
    cmp al, 126
    jg .term_key_done

    mov ecx, [r14 + TERM_STATE_CURSOR]
    cmp ecx, TERM_INPUT_MAX
    jge .term_key_done
    lea rbx, [r14 + TERM_STATE_INPUT]
    mov [rbx + rcx], al
    inc ecx
    mov byte [rbx + rcx], 0
    mov dword [r14 + TERM_STATE_CURSOR], ecx
    jmp .term_key_done

.term_backspace:
    mov ecx, [r14 + TERM_STATE_CURSOR]
    test ecx, ecx
    jz .term_key_done
    dec ecx
    lea rbx, [r14 + TERM_STATE_INPUT]
    mov byte [rbx + rcx], 0
    mov dword [r14 + TERM_STATE_CURSOR], ecx
    jmp .term_key_done

.term_enter:
    lea rbx, [r14 + TERM_STATE_INPUT]
    lea rsi, [rel term_blob_cmd_cls]
    mov rdi, rbx
    call .term_str_eq
    test al, al
    jnz .term_cls
    lea rsi, [rel term_blob_cmd_ver]
    mov rdi, rbx
    call .term_str_eq
    test al, al
    jnz .term_ver
    lea rsi, [rel term_blob_cmd_help]
    mov rdi, rbx
    call .term_str_eq
    test al, al
    jnz .term_help
    ; Default: build "C:\> <input>" into the echo buffer.
    lea rdi, [r14 + TERM_STATE_ECHO]
    lea rsi, [rel term_blob_prompt]
    call .term_copy_str
    lea rsi, [r14 + TERM_STATE_INPUT]
    call .term_append_str
    jmp .term_clear_input

.term_cls:
    mov byte [r14 + TERM_STATE_ECHO], 0
    jmp .term_clear_input

.term_ver:
    lea rdi, [r14 + TERM_STATE_ECHO]
    lea rsi, [rel term_blob_welcome]
    call .term_copy_str
    jmp .term_clear_input

.term_help:
    lea rdi, [r14 + TERM_STATE_ECHO]
    lea rsi, [rel term_blob_help_hint]
    call .term_copy_str
    jmp .term_clear_input

.term_copy_str:
.copy_loop:
    lodsb
    stosb
    test al, al
    jnz .copy_loop
    dec rdi
    ret

.term_append_str:
.append_loop:
    lodsb
    stosb
    test al, al
    jnz .append_loop
    ret

.term_str_eq:
.cmp_loop:
    mov al, [rdi]
    mov dl, [rsi]
    cmp al, dl
    jne .cmp_no
    test al, al
    jz .cmp_yes
    inc rdi
    inc rsi
    jmp .cmp_loop
.cmp_no:
    xor eax, eax
    ret
.cmp_yes:
    mov al, 1
    ret

.term_clear_input:
    mov byte [r14 + TERM_STATE_INPUT], 0
    mov dword [r14 + TERM_STATE_CURSOR], 0

.term_key_done:
    pop r14
    pop rdx
    pop rcx
    pop rbx
    ret

app_terminal_kernel_key:
    jmp app_terminal_key

term_blob_welcome:
    db "NexusOS Terminal v3.0", 0
term_blob_help_hint:
    db "Type 'help', 'ver', or 'cls'", 0
term_blob_prompt:
    db "C:\> ", 0
term_blob_cursor:
    db "_", 0
term_blob_cmd_help:
    db "help", 0
term_blob_cmd_ver:
    db "ver", 0
term_blob_cmd_cls:
    db "cls", 0

app_terminal_blob_end:

; Helper: add echo buffer pointer to history
term_add_history_echo:
    push rax
    push rcx
    push rdx
    mov eax, [rel term_hist_count]
    cmp eax, TERM_MAX_HIST
    jge .echo_scroll

    lea rcx, [rel term_hist_ptrs]
    lea rdx, [rel term_echo_buf]
    mov [rcx + rax * 8], rdx
    inc dword [rel term_hist_count]
    jmp .echo_done

.echo_scroll:
    lea rcx, [term_hist_ptrs]
    mov eax, 0
.echo_shift:
    cmp eax, TERM_MAX_HIST - 1
    jge .echo_shift_done
    mov rdx, [rcx + rax * 8 + 8]
    mov [rcx + rax * 8], rdx
    inc eax
    jmp .echo_shift
.echo_shift_done:
    lea rdx, [rel term_echo_buf]
    mov [rcx + (TERM_MAX_HIST - 1) * 8], rdx
.echo_done:
    pop rdx
    pop rcx
    pop rax
    ret

; Internal helper: string compare (case insensitive)
; RSI = input, RDI = cmd string
; Returns EAX=1 if match, 0 if not
term_strcmp:
    push rsi
    push rdi
.tcmp_loop:
    mov al, [rsi]
    mov bl, [rdi]
    
    ; Lowercase AL
    cmp al, 'A'
    jl .al_lower
    cmp al, 'Z'
    jg .al_lower
    add al, 32
.al_lower:

    ; Lowercase BL (should be already, but safe)
    cmp bl, 'A'
    jl .bl_lower
    cmp bl, 'Z'
    jg .bl_lower
    add bl, 32
.bl_lower:

    cmp al, bl
    jne .tcmp_fail
    test bl, bl
    jz .tcmp_match
    inc rsi
    inc rdi
    jmp .tcmp_loop
.tcmp_fail:
    pop rdi
    pop rsi
    xor eax, eax
    ret
.tcmp_match:
    pop rdi
    pop rsi
    mov eax, 1
    ret

; Helper: starts with
term_starts_with:
    push rsi
    push rdi
.tsw_loop:
    mov bl, [rdi]
    test bl, bl
    jz .tsw_match
    mov al, [rsi]
    or al, 0x20
    cmp al, bl
    jne .tsw_fail
    inc rsi
    inc rdi
    jmp .tsw_loop
.tsw_fail:
    pop rdi
    pop rsi
    xor eax, eax
    ret
.tsw_match:
    pop rdi
    pop rsi
    mov eax, 1
    ret

; ============================================================================
; NOTEPAD APP
; Multi-line text editor with arrow navigation, Enter, File/Edit menus
; Buffer layout: NP_MAX_LINES lines, each NP_MAX_COLS bytes
; np_line_len[i] = length of line i
; ============================================================================

