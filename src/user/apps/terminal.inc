global app_terminal_blob_start
global app_terminal_blob_end
app_terminal_blob_start:
app_terminal_draw:
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov rbx, rdi
    mov r12, [rbx + WIN_OFF_X]
    mov r13, [rbx + WIN_OFF_Y]
    mov r14, [rbx + WIN_OFF_W]
    mov r15, [rbx + WIN_OFF_H]

    ; Background (sc_gui_rect: rdi=x, rsi=y, rdx=w, r10=h, r8=color)
    mov rdi, r12
    add rdi, BORDER_WIDTH
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT
    mov rdx, r14
    sub rdx, BORDER_WIDTH * 2
    mov rcx, r15
    sub rcx, TITLEBAR_HEIGHT + BORDER_WIDTH
    cmp rcx, 0
    jle .term_draw_done
    mov r10, rcx
    mov r8, 0x00111111
    mov rax, 2
    syscall

    ; Header (sc_gui_text: rdi=x, rsi=y, rdx=str, r10=color)
    mov rdi, r12
    add rdi, BORDER_WIDTH + 6
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 4
    lea rdx, [rel term_blob_welcome]
    mov r10, 0x0000DD00
    mov rax, 3
    syscall

    ; History lines, or help hint when empty
    mov ecx, [rel term_blob_hist_count]
    test ecx, ecx
    jnz .term_draw_hist
    mov rdi, r12
    add rdi, BORDER_WIDTH + 6
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 20
    lea rdx, [rel term_blob_help_hint]
    mov r10, 0x00CCCCCC
    mov rax, 3
    syscall
    jmp .term_after_hist
.term_draw_hist:
    xor r14d, r14d                   ; line index
.term_hist_loop:
    cmp r14d, [rel term_blob_hist_count]
    jge .term_after_hist
    mov rdi, r12
    add rdi, BORDER_WIDTH + 6
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 20
    mov eax, r14d
    imul eax, 14
    add esi, eax
    mov eax, r14d
    imul eax, TERM_HIST_LINE
    lea rdx, [rel term_blob_hist_buf]
    add rdx, rax
    mov r10, 0x00CCCCCC
    mov rax, 3
    syscall
    inc r14d
    jmp .term_hist_loop
.term_after_hist:

    ; Prompt y = below history (or default 28 below header if empty)
    mov eax, [rel term_blob_hist_count]
    test eax, eax
    jnz .term_prompt_y_have
    mov eax, 1                       ; reserve one line for help-hint
.term_prompt_y_have:
    imul eax, 14
    add eax, 24                       ; 20 (hist_y0) + 4 padding
    mov r15d, eax                    ; r15d = prompt y offset

    ; Prompt "C:\> "
    mov rdi, r12
    add rdi, BORDER_WIDTH + 6
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT
    add esi, r15d
    lea rdx, [rel term_blob_prompt]
    mov r10, 0x0000FF00
    mov rax, 3
    syscall

    ; Input text
    mov rdi, r12
    add rdi, BORDER_WIDTH + 6 + 40
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT
    add esi, r15d
    lea rdx, [rel term_blob_input_buf]
    mov r10, 0x00FFFFFF
    mov rax, 3
    syscall

    ; Cursor
    mov eax, [rel term_blob_cursor_val]
    imul eax, FONT_WIDTH
    add eax, BORDER_WIDTH + 6 + 40
    mov rdi, r12
    add edi, eax
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT
    add esi, r15d
    lea rdx, [rel term_blob_cursor]
    mov r10, 0x00FFFFFF
    mov rax, 3
    syscall

.term_draw_done:
    pop r15
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

    mov ecx, [rel term_blob_cursor_val]
    cmp ecx, TERM_INPUT_MAX
    jge .term_key_done
    lea rbx, [rel term_blob_input_buf]
    mov [rbx + rcx], al
    inc ecx
    mov byte [rbx + rcx], 0
    mov [rel term_blob_cursor_val], ecx
    jmp .term_key_done

.term_backspace:
    mov ecx, [rel term_blob_cursor_val]
    test ecx, ecx
    jz .term_key_done
    dec ecx
    lea rbx, [rel term_blob_input_buf]
    mov byte [rbx + rcx], 0
    mov [rel term_blob_cursor_val], ecx
    jmp .term_key_done

.term_enter:
    lea rbx, [rel term_blob_input_buf]
    lea rsi, [rel term_blob_cmd_cls]
    mov rdi, rbx
    call .term_str_eq
    test al, al
    jnz .term_cls
    lea rsi, [rel term_blob_cmd_ver]
    lea rdi, [rel term_blob_input_buf]
    call .term_str_eq
    test al, al
    jnz .term_ver
    lea rsi, [rel term_blob_cmd_help]
    lea rdi, [rel term_blob_input_buf]
    call .term_str_eq
    test al, al
    jnz .term_help
    lea rdi, [rel term_blob_input_buf]
    mov rax, 23
    syscall
    cmp rax, -1
    jne .term_launched
    ; Default: push "C:\> <input>" as a history line.
    lea rdi, [rel term_blob_line_tmp]
    lea rsi, [rel term_blob_prompt]
    call .term_copy_str
    lea rsi, [rel term_blob_input_buf]
    call .term_append_str
    lea rsi, [rel term_blob_line_tmp]
    call .term_push_hist
    jmp .term_clear_input

.term_launched:
    lea rdi, [rel term_blob_line_tmp]
    lea rsi, [rel term_blob_prompt]
    call .term_copy_str
    lea rsi, [rel term_blob_input_buf]
    call .term_append_str
    lea rsi, [rel term_blob_line_tmp]
    call .term_push_hist
    jmp .term_clear_input

.term_cls:
    mov dword [rel term_blob_hist_count], 0
    jmp .term_clear_input

.term_ver:
    lea rsi, [rel term_blob_welcome]
    call .term_push_hist
    jmp .term_clear_input

.term_help:
    lea rsi, [rel term_blob_help_hint]
    call .term_push_hist
    jmp .term_clear_input

; Push string at RSI as a new history line. Shifts older lines up if full.
.term_push_hist:
    push rax
    push rcx
    push rdx
    push rdi
    push rsi
    push r8
    push r9

    mov ecx, [rel term_blob_hist_count]
    cmp ecx, TERM_HIST_MAX
    jl .term_ph_have_slot
    ; Full: shift entries [1..N-1] -> [0..N-2]
    push rsi
    lea rdi, [rel term_blob_hist_buf]
    lea rsi, [rdi + TERM_HIST_LINE]
    mov rcx, (TERM_HIST_MAX - 1) * TERM_HIST_LINE
    cld
    rep movsb
    pop rsi
    mov ecx, TERM_HIST_MAX - 1
.term_ph_have_slot:
    mov eax, ecx
    imul eax, TERM_HIST_LINE
    lea rdi, [rel term_blob_hist_buf]
    add rdi, rax
    xor edx, edx
.term_ph_copy:
    cmp edx, TERM_HIST_LINE - 1
    jge .term_ph_end
    mov al, [rsi]
    test al, al
    jz .term_ph_end
    mov [rdi], al
    inc rdi
    inc rsi
    inc edx
    jmp .term_ph_copy
.term_ph_end:
    mov byte [rdi], 0
    mov eax, [rel term_blob_hist_count]
    cmp eax, TERM_HIST_MAX
    jge .term_ph_done
    inc eax
    mov [rel term_blob_hist_count], eax
.term_ph_done:
    pop r9
    pop r8
    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rax
    ret

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
    mov byte [rel term_blob_input_buf], 0
    mov dword [rel term_blob_cursor_val], 0

.term_key_done:
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

; Per-slot mutable state (lives inside the blob image so each L3 slot gets its
; own copy after l3_copy_app_blob_to_slot). Zero-initialised at boot.
TERM_HIST_MAX  equ 8
TERM_HIST_LINE equ 64
align 8
term_blob_cursor_val: dd 0
term_blob_hist_count: dd 2
term_blob_input_buf:  times 64  db 0
term_blob_line_tmp:   times TERM_HIST_LINE db 0
term_blob_hist_buf:
    db "NexusOS Terminal v3.0", 0
    times TERM_HIST_LINE - 22 db 0
    db "Type 'help', 'ver', or 'cls'", 0
    times TERM_HIST_LINE - 29 db 0
    times (TERM_HIST_MAX - 2) * TERM_HIST_LINE db 0

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

