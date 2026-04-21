app_l3_test_draw:
    push rdi
    push r14
    ;SYS_PRINT szL3DrawOk
    mov rdi, [rsp + 8]
    mov r14, [rdi + WIN_OFF_APPDATA]
    cmp byte [r14], 1
    je .skip_selftest
    mov byte [r14], 1
    ;SYS_PRINT szL3T0
    SYS_FS_COUNT
    mov [r14 + 8], eax
    ;SYS_PRINT szL3T4
    xor edi, edi
    SYS_FS_ENTRY rdi
    mov [r14 + 16], rax
    test rax, rax
    jz .skip_selftest
    ;SYS_PRINT szL3T5
    xor edi, edi
    SYS_FS_CHDIR rdi
    ;SYS_PRINT szL3T6
    mov rdi, [r14 + 16]
    lea rsi, [r14 + 256]
    mov rdx, 64
    SYS_FS_READ rdi, rsi, rdx
    mov [r14 + 24], eax
    ;SYS_PRINT szL3T8
    mov rdi, [r14 + 16]
    lea rsi, [r14 + 128]
    SYS_FS_FORMAT_NAME rdi, rsi
    ;SYS_PRINT szL3T11
    lea rdi, [rel szL3Tmp83]
    lea rsi, [rel szL3TmpData]
    mov rdx, 4
    SYS_FS_WRITE rdi, rsi, rdx
    ;SYS_PRINT szL3T13
    SYS_FS_SYNC_ROOT
    ;SYS_PRINT szL3T14
    SYS_CURSOR_INIT
    ;SYS_PRINT szL3T17
.skip_selftest:
    pop r14
    pop rdi
    mov rax, [rdi + WIN_OFF_X]
    add rax, BORDER_WIDTH + 8
    mov rsi, [rdi + WIN_OFF_Y]
    add rsi, TITLEBAR_HEIGHT + 8
    mov rdi, rax
    mov edx, 80
    mov ecx, 24
    mov r8d, 0x0000AA44
    SYS_GUI_RECT rdi, rsi, rdx, rcx, r8
    lea rdx, [szL3DrawOk]
    mov ecx, COLOR_TEXT_WHITE
    mov r8d, 0x0000AA44
    SYS_GUI_TEXT rdi, rsi, rdx, rcx, r8
    ret

app_l3_test_click:
    push rdi
    lea rdi, [szL3ClickOk]
    SYS_PRINT rdi
    pop rdi
    ret

app_l3_test_key:
    push rdi
    lea rdi, [szL3KeyOk]
    SYS_PRINT rdi
    pop rdi
    ret


; ============================================================================
; app_launch - Launch an app by ID
; RDI = app ID (2..6)
; Returns: RAX = window ID or -1
; ============================================================================
global app_launch
app_launch:
    SER 'L'
    SER '['
    push rdi
    call ser_print_hex64
    pop rdi
    SER ']'
    cmp rdi, APP_EXPLORER
    je .launch_explorer
    cmp rdi, APP_TERMINAL
    je .launch_terminal
    cmp rdi, APP_NOTEPAD
    je .launch_notepad
    cmp rdi, APP_SETTINGS
    je .launch_settings
    cmp rdi, APP_PAINT
    je .launch_paint
    cmp rdi, APP_ABOUT
    je .launch_about
    mov rax, -1
    ret

.launch_explorer:
    SER 'E'
    SER 'e'
    ; Reset explorer state to root
    mov dword [explorer_sel], 0
    mov dword [explorer_dir], 0
    mov byte [ctx_menu_visible], 0
    mov byte [exp_rename_active], 0
    mov byte [exp_newfolder_active], 0
    mov byte [exp_newfolder_done_msg], 0
    lea rdi, [rel szExplorerTitle]
    mov rsi, 120
    mov rdx, 80
    mov rcx, 420
    mov r8, 340
    mov r9, app_explorer_draw
    SER '{'
    sub rsp, 8               ; Align stack
    call wm_create_window_ex
    add rsp, 8
    SER '}'
    push rax
    push rdi
    mov rdi, rax
    call ser_print_hex64
    pop rdi
    pop rax
    cmp rax, -1
    je .done
    push rax
    imul rax, WINDOW_STRUCT_SIZE
    add rax, WINDOW_POOL_ADDR
    mov r10, app_explorer_click
    mov qword [rax + WIN_OFF_CLICKFN], r10
    mov r10, app_explorer_key
    mov qword [rax + WIN_OFF_KEYFN], r10
    SER 'e'
    pop rax
    jmp .done

.launch_terminal:
    SER 'T'
    SER 't'
    ; Reset terminal state
    mov dword [term_cursor], 0
    mov byte [term_input], 0
    
    ; Clear entire input buffer for safety
    lea rdi, [term_input]
    xor eax, eax
    mov ecx, 64
    cld
    rep stosb

    mov dword [term_hist_count], 0
    ; Clear history pointers
    lea rcx, [rel term_hist_ptrs]
    xor eax, eax
.clr_hist:
    cmp eax, TERM_MAX_HIST
    jge .hist_cleared
    mov qword [rcx + rax * 8], 0
    inc eax
    jmp .clr_hist
.hist_cleared:
    ; Add welcome lines
    lea rcx, [term_hist_ptrs]
    lea rax, [rel szTermWelcome]
    mov qword [rcx + 0], rax
    lea rax, [rel szTermVer]
    mov qword [rcx + 8], rax
    lea rax, [rel szTermHelpHint]
    mov qword [rcx + 16], rax
    mov dword [term_hist_count], 3
    lea rdi, [rel szTermTitle]
    mov rsi, 200
    mov rdx, 150
    mov rcx, 450
    mov r8, 300
    mov r9, app_terminal_draw
    SER '{'
    sub rsp, 8               ; Align stack
    call wm_create_window_ex
    add rsp, 8
    SER '}'
    cmp rax, -1
    je .done
    SER 'a'
    push rax
    imul rax, WINDOW_STRUCT_SIZE
    add rax, WINDOW_POOL_ADDR
    SER 'b'
    mov r10, app_terminal_click
    mov qword [rax + WIN_OFF_CLICKFN], r10
    SER 'c'
    mov r10, app_terminal_key
    mov qword [rax + WIN_OFF_KEYFN], r10
    SER 'd'
    mov rcx, [rax + WIN_OFF_APPDATA]
    mov dword [rcx + TERM_STATE_CURSOR], 0
    mov byte [rcx + TERM_STATE_INPUT], 0
    lea rdi, [rcx + TERM_STATE_ECHO]
    lea rsi, [rel term_blob_help_hint]
    cld
.init_term_echo_copy:
    lodsb
    stosb
    test al, al
    jnz .init_term_echo_copy
    
    ; Reset filesystem state to root when terminal starts
    ; (Use direct kernel fat16 call; %xdefine aliases are for ring-3 handlers.)
    SER 'r'
    %undef fat16_change_dir
    xor eax, eax
    extern fat16_change_dir
    call fat16_change_dir
    %xdefine fat16_change_dir app_sys_fs_change_dir
    SER 'R'
    
    SER 't'
    pop rax
    jmp .done

.launch_notepad:
    SER 'N'
    SER 'n'
    ; Reset notepad state
    lea rdi, [notepad_buf]
    xor eax, eax
    mov ecx, NP_BUF_SIZE
    rep stosb
    mov dword [np_cursor_row], 0
    mov dword [np_cursor_col], 0
    mov dword [np_num_lines], 1
    mov dword [np_scroll_top], 0
    mov byte [np_menu_open], 0
    mov byte [np_save_dialog], 0
    mov qword [np_open_entry], 0
    ; Initialize line lengths array - line 0 starts with length 0
    lea rdi, [np_line_len]
    xor eax, eax
    mov ecx, NP_MAX_LINES
    rep stosd
    lea rdi, [rel szNotepadTitle]
    mov rsi, 250
    mov rdx, 120
    mov rcx, 400
    mov r8, 300
    mov r9, app_hl_notepad_draw
    SER '{'
    sub rsp, 8               ; Align stack
    call wm_create_window_ex
    add rsp, 8
    SER '}'
    push rax
    push rdi
    mov rdi, rax
    call ser_print_hex64
    pop rdi
    pop rax
    cmp rax, -1
    je .done
    push rax
    imul rax, WINDOW_STRUCT_SIZE
    add rax, WINDOW_POOL_ADDR
    mov r10, app_hl_notepad_key
    mov qword [rax + WIN_OFF_KEYFN], r10
    mov r10, app_hl_notepad_click
    mov qword [rax + WIN_OFF_CLICKFN], r10
    SER 'n'
    pop rax
    jmp .done

.launch_settings:
    SER 'S'
    SER 's'
    lea rdi, [rel szSettingsTitle]
    mov rsi, 300
    mov rdx, 180
    mov rcx, 380
    mov r8, 280
    mov r9, app_settings_draw
    SER '{'
    sub rsp, 8
    call wm_create_window_ex
    add rsp, 8
    SER '}'
    push rax
    push rdi
    mov rdi, rax
    call ser_print_hex64
    pop rdi
    pop rax
    cmp rax, -1
    je .done
    push rax
    imul rax, WINDOW_STRUCT_SIZE
    add rax, WINDOW_POOL_ADDR
    mov r10, app_settings_click
    mov qword [rax + WIN_OFF_CLICKFN], r10
    SER 's'
    pop rax
    jmp .done

.launch_paint:
    SER 'P'
    SER 'p'
    ; Reset paint state before creating the window.
    mov dword [paint_color], 0xFF000000 ; Black
    mov dword [paint_brush_size], 2

    lea rdi, [rel szPaintTitle]
    mov rsi, 150
    mov rdx, 100
    mov rcx, 340   ; width (canvas 200 + border/tools + buttons)
    mov r8, 240    ; height (canvas 150 + toolbar)
    mov r9, app_paint_draw
    SER '{'
    sub rsp, 8
    call wm_create_window_ex
    add rsp, 8
    SER '}'
    push rax
    push rdi
    mov rdi, rax
    call ser_print_hex64
    pop rdi
    pop rax
    cmp rax, -1
    je .done

    ; Setup callback
    push rax
    imul rax, WINDOW_STRUCT_SIZE
    add rax, WINDOW_POOL_ADDR
    mov rdi, [rax + WIN_OFF_APPDATA]
    add rdi, APP_SLOT_PAINT_CANVAS_OFF
    mov ecx, 30000
    mov eax, 0xFFFFFFFF
    rep stosd
    mov rax, [rsp]
    imul rax, WINDOW_STRUCT_SIZE
    add rax, WINDOW_POOL_ADDR
    mov r10, app_paint_click
    mov qword [rax + WIN_OFF_CLICKFN], r10
    mov r10, app_paint_key
    mov qword [rax + WIN_OFF_KEYFN], r10
    SER 'p'
    pop rax
    jmp .done

.launch_about:
    SER 'B'
    SER 'b'
    lea rdi, [rel szAboutTitle]
    mov rsi, 280
    mov rdx, 200
    mov rcx, 340
    mov r8, 220
    mov r9, app_about_draw
    SER '{'
    sub rsp, 8
    call wm_create_window_ex
    add rsp, 8
    SER '}'
    push rax
    push rdi
    mov rdi, rax
    call ser_print_hex64
    pop rdi
    pop rax
    cmp rax, -1
    je .done
    SER 'b'
    jmp .done

.done:
    ret


; ============================================================================
; app_open_file - Open a file, routing by extension
; RDI = pointer to FAT16 dir entry (32 bytes)
; ============================================================================
global app_open_file
app_open_file:
    ; Check extension at entry+8 (3 bytes)
    ; BMP files: extension = "BMP"
    cmp byte [rdi + 8], 'B'
    jne .open_not_bmp
    cmp byte [rdi + 9], 'M'
    jne .open_not_bmp
    cmp byte [rdi + 10], 'P'
    jne .open_not_bmp
    jmp app_open_file_in_bmpview
.open_not_bmp:
    jmp app_open_file_in_notepad

; ============================================================================
; Helper: open file in notepad
; RDI = pointer to FAT16 dir entry
; ============================================================================
global app_open_file_in_notepad
app_open_file_in_notepad:
    push rbx
    push r12
    push r13
    push rdi
    push rsi
    push rcx

    mov r12, rdi             ; save dir entry ptr

    ; Launch notepad (resets buffer) via syscall
    mov rdi, APP_NOTEPAD
    SYS_APP_LAUNCH rdi
    cmp rax, -1
    je .open_done
    mov r13, rax             ; window ID

    ; Format name into title buffer (WIN_OFF_TITLE is +48)
    mov rax, r13
    imul rax, WINDOW_STRUCT_SIZE
    add rax, WINDOW_POOL_ADDR
    lea rdi, [rax + 48]
    mov rsi, r12
    call fat16_format_name_to  ; local call is fine

    ; Save dir entry for notepad (so Save knows the filename)
    mov [np_open_entry], r12

    ; Read file content from FAT16
    mov rdi, r12             ; dir entry ptr
    lea rsi, [notepad_buf]   ; dest = notepad buffer
    mov rdx, NP_BUF_SIZE - 1 ; max bytes
    SYS_FS_READ rdi, rsi, rdx
    ; eax = bytes read
    cmp eax, -1
    je .open_load_empty
    test eax, eax
    jz .open_load_empty

    ; Null-terminate
    lea rbx, [notepad_buf]
    mov byte [rbx + rax], 0

    ; Parse content into lines: split on CR/LF
    mov r12d, eax            ; total bytes
    xor ecx, ecx             ; current line
    xor edx, edx             ; current col
    xor esi, esi             ; source offset

.parse_loop:
    cmp esi, r12d
    jge .parse_done
    cmp ecx, NP_MAX_LINES - 1
    jge .parse_done

    movzx eax, byte [rbx + rsi]
    inc esi

    cmp al, 13               ; CR
    je .parse_cr
    cmp al, 10               ; LF
    je .parse_lf

    ; Regular char - store in current line
    cmp edx, NP_MAX_COLS - 1
    jge .parse_loop           ; skip if line too long

    push rcx
    imul ecx, NP_MAX_COLS
    mov [notepad_buf + rcx + rdx], al
    pop rcx
    inc edx
    jmp .parse_loop

.parse_cr:
    ; Skip following LF if present
    cmp esi, r12d
    jge .parse_newline
    cmp byte [rbx + rsi], 10
    jne .parse_newline
    inc esi
.parse_lf:
.parse_newline:
    ; Null-terminate current line
    push rcx
    imul ecx, NP_MAX_COLS
    mov byte [notepad_buf + rcx + rdx], 0
    pop rcx
    ; Store line length
    mov [np_line_len + rcx * 4], edx
    inc ecx
    xor edx, edx
    jmp .parse_loop

.parse_done:
    ; Terminate last line
    push rcx
    push rcx
    imul ecx, NP_MAX_COLS
    mov byte [notepad_buf + rcx + rdx], 0
    pop rcx
    mov [np_line_len + rcx * 4], edx
    pop rcx
    inc ecx
    mov [np_num_lines], ecx
    mov dword [np_cursor_row], 0
    mov dword [np_cursor_col], 0
    jmp .open_done

.open_load_empty:
    mov dword [np_num_lines], 1
    mov dword [np_cursor_row], 0
    mov dword [np_cursor_col], 0

.open_done:
    pop rcx
    pop rsi
    pop rdi
    pop r13
    pop r12
    pop rbx
    ret

; ============================================================================
; FILE EXPLORER APP
; Virtual filesystem with navigable directories
; ============================================================================

; Draw callback: RDI = window struct ptr
