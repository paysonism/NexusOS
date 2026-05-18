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

; RAX = window ID, R10 = click handler, R11 = key handler.
; Drag handler (optional): install separately via app_set_window_drag below
; (kept as a separate helper so existing callers stay unchanged and we never
; clobber a stale value).
app_set_window_handlers:
    push rax
    imul rax, WINDOW_STRUCT_SIZE
    add rax, WINDOW_POOL_ADDR
    mov qword [rax + WIN_OFF_CLICKFN], r10
    mov qword [rax + WIN_OFF_KEYFN], r11
    pop rax
    ret

; RAX = window ID, R10 = drag handler. Same calling convention as click:
;   drag_fn(rsi=win_ptr, rdx=client_x, rcx=client_y).
; The WM fires drag_fn for every mouse-poll tick where the cursor has moved
; AND the left button is still held AND the initial press landed on this
; window's client area. The cursor may leave the window's bounds — drag
; events keep flowing until the button is released. Pass 0 to detach.
app_set_window_drag:
    push rax
    imul rax, WINDOW_STRUCT_SIZE
    add rax, WINDOW_POOL_ADDR
    mov qword [rax + WIN_OFF_DRAGFN], r10
    pop rax
    ret

; RAX = window ID. Preserve RAX.
; The NexusHL notepad callbacks read state from the window's L3 slot copy of
; the app blob. ALL per-instance notepad state must be written through this
; helper (slot-relative) — never to the kernel image's master copy, which is
; shared across all instances and is only a linker placeholder.
app_seed_notepad_slot:
    push rax
    push rbx
    push rcx
    push rdi

    mov edi, eax
    call l3_copy_app_blob_to_slot
    mov rbx, rax

    ; Starter text "Hello"
    mov byte [rbx + notepad_buf - app_blob_start + 0], 'H'
    mov byte [rbx + notepad_buf - app_blob_start + 1], 'e'
    mov byte [rbx + notepad_buf - app_blob_start + 2], 'l'
    mov byte [rbx + notepad_buf - app_blob_start + 3], 'l'
    mov byte [rbx + notepad_buf - app_blob_start + 4], 'o'
    mov byte [rbx + notepad_buf - app_blob_start + 5], 0
    mov dword [rbx + np_line_len - app_blob_start], 5
    mov dword [rbx + np_cursor_row - app_blob_start], 0
    mov dword [rbx + np_cursor_col - app_blob_start], 5
    mov dword [rbx + np_num_lines - app_blob_start], 1
    mov dword [rbx + np_scroll_top - app_blob_start], 0

    ; Reset transient UI / dialog state in the slot
    mov byte  [rbx + np_menu_open - app_blob_start], 0
    mov byte  [rbx + np_save_dialog - app_blob_start], 0
    mov byte  [rbx + np_save_done_msg - app_blob_start], 0
    mov byte  [rbx + np_has_saved - app_blob_start], 0
    mov dword [rbx + np_save_field - app_blob_start], 0
    mov dword [rbx + np_saveas_cursor - app_blob_start], 0
    mov byte  [rbx + np_saveas_buf - app_blob_start], 0
    mov dword [rbx + np_saveloc_cursor - app_blob_start], 1
    mov byte  [rbx + np_saveloc_buf - app_blob_start], 47       ; '/'
    mov byte  [rbx + np_saveloc_buf - app_blob_start + 1], 0
    mov qword [rbx + np_open_entry - app_blob_start], 0

    pop rdi
    pop rcx
    pop rbx
    pop rax
    ret

; RAX = window ID. Preserve RAX.
; NexusHL app state is read from the per-window L3 slot. When a window slot is
; reused, call_app_l3 sees the existing magic and does not recopy the blob, so
; launch-time state resets done above would otherwise stay invisible.
app_refresh_window_slot:
    push rax
    push rdi

    mov edi, eax
    call l3_copy_app_blob_to_slot

    pop rdi
    pop rax
    ret

; RAX = Explorer window ID. Preserve RAX.
app_reset_explorer_slot:
    push rax
    push rbx
    push rdi

    mov edi, eax
    call l3_slot_base
    mov rbx, rax
    mov dword [rbx + explorer_sel - app_blob_start], 0
    mov dword [rbx + explorer_dir - app_blob_start], 0
    mov byte [rbx + ctx_menu_visible - app_blob_start], 0
    mov byte [rbx + exp_ctx_visible - app_blob_start], 0
    mov byte [rbx + exp_rename_active - app_blob_start], 0
    mov byte [rbx + exp_newfolder_active - app_blob_start], 0
    mov byte [rbx + exp_newfolder_done_msg - app_blob_start], 0
    mov dword [rbx + exp_rename_cursor - app_blob_start], 0
    mov dword [rbx + exp_newfolder_cursor - app_blob_start], 0
    mov byte [rbx + exp_rename_buf - app_blob_start], 0
    mov byte [rbx + exp_newfolder_buf - app_blob_start], 0

    pop rdi
    pop rbx
    pop rax
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
    cmp rdi, APP_SECURITY_PROBE
    je .launch_security_probe
    cmp rdi, APP_TASKMGR
    je .launch_taskmgr
    mov rax, -1
    ret

.launch_explorer:
    SER 'E'
    SER 'e'
    ; Reset explorer state to root
    mov dword [explorer_sel], 0
    mov dword [explorer_dir], 0
    mov byte [ctx_menu_visible], 0
    mov byte [exp_ctx_visible], 0
    mov byte [exp_rename_active], 0
    mov byte [exp_newfolder_active], 0
    mov byte [exp_newfolder_done_msg], 0
    lea rdi, [rel szExplorerTitle]
    mov rsi, 120
    mov rdx, 80
    mov rcx, 420
    mov r8, 340
    mov r9, app_hl_explorer_draw
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
    call app_refresh_window_slot
    call app_reset_explorer_slot
    mov r10, app_hl_explorer_click
    mov r11, app_hl_explorer_key
    call app_set_window_handlers
    SER 'e'
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
    SER 'b'
    ; Per-slot terminal state lives inside the blob image now (zero-initialised
    ; on copy). Empty echo buffer triggers the help-hint fallback in the draw
    ; routine, so no explicit seeding is needed.

    ; Reset filesystem state to root when terminal starts
    ; (Use direct kernel fat16 call; %xdefine aliases are for ring-3 handlers.)
    SER 'r'
    %undef fat16_change_dir
    xor eax, eax
    extern fat16_change_dir
    call fat16_change_dir
    %xdefine fat16_change_dir app_sys_fs_change_dir
    SER 'R'
    
    mov rax, [rsp]
    mov r10, app_terminal_click
    mov r11, app_terminal_key
    call app_set_window_handlers
    SER 't'
    pop rax
    jmp .done

.launch_notepad:
    SER 'N'
    SER 'n'
    ; Per-instance state is owned by the L3 slot; app_seed_notepad_slot below
    ; populates it. Do NOT touch the kernel image's np_* master copies here —
    ; they are linker placeholders, not shared state, and were a source of
    ; cross-instance corruption when used as scratch.
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
    call app_seed_notepad_slot
    mov r10, app_hl_notepad_click
    mov r11, app_hl_notepad_key
    call app_set_window_handlers
    SER 'n'
    jmp .done

.launch_settings:
    SER 'S'
    SER 's'
    lea rdi, [rel szSettingsTitle]
    mov rsi, 300
    mov rdx, 180
    mov rcx, 380
    mov r8, 280
    mov r9, app_hl_settings_draw
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
    mov r10, app_hl_settings_click
    mov r11, app_hl_settings_key
    call app_set_window_handlers
    SER 's'
    jmp .done

.launch_paint:
    SER 'P'
    SER 'p'
    ; Per-instance paint state is owned by the L3 slot via the NexusHL
    ; `state {}` block; the kernel-image paint_* placeholders are unused.
    lea rdi, [rel szPaintTitle]
    mov rsi, 150
    mov rdx, 100
    mov rcx, 340   ; width (toolbar + canvas)
    mov r8, 240    ; height (toolbar + canvas)
    mov r9, app_hl_paint_draw
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
    mov r10, app_hl_paint_click
    mov r11, app_hl_paint_key
    call app_set_window_handlers
    mov r10, app_hl_paint_drag
    call app_set_window_drag
    SER 'p'
    jmp .done

.launch_about:
    SER 'B'
    SER 'b'
    lea rdi, [rel szAboutTitle]
    mov rsi, 280
    mov rdx, 200
    mov rcx, 380
    mov r8, 300
    mov r9, app_hl_about_draw
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
    mov r10, app_hl_about_click
    mov r11, app_hl_about_key
    call app_set_window_handlers
    SER 'b'
    jmp .done

.launch_security_probe:
    lea rdi, [rel szSecurityProbeTitle]
    mov rsi, 80
    mov rdx, 70
    mov rcx, 520
    mov r8, 260
    mov r9, app_security_probe_draw
    sub rsp, 8
    call wm_create_window_ex
    add rsp, 8
    cmp rax, -1
    je .done
    xor r10d, r10d
    xor r11d, r11d
    call app_set_window_handlers
    jmp .done

.launch_taskmgr:
    SER 'M'
    SER 'm'
    lea rdi, [rel szTaskMgrTitle]
    mov rsi, 200
    mov rdx, 120
    mov rcx, 360
    mov r8, 300
    mov r9, app_hl_taskmgr_draw
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
    mov r10, app_hl_taskmgr_click
    mov r11, app_hl_taskmgr_key
    call app_set_window_handlers
    SER 'm'
    jmp .done

.done:
    ret


; ============================================================================
; app_open_file - Open a file, routing by extension
; RDI = pointer to FAT16 dir entry (32 bytes)
; ============================================================================
global app_open_file
app_open_file:
    ; Check extension at entry+8 (3 bytes); BMP files: extension = "BMP"
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
; app_open_file_in_notepad - thin user-mode wrapper.
;   Routes everything through SYS_OPEN_FILE_NP so the heavy lifting (launch
;   notepad, read FAT16, parse lines, push into the notepad slot) runs in
;   kernel mode where the globals it touches actually live. When this code
;   ran in Ring 3 it modified the *caller's* (explorer's) slot copy of
;   notepad_buf, which is why every notepad stayed seeded with "Hello".
; RDI = slot-cached dir entry pointer
; ============================================================================
global app_open_file_in_notepad
app_open_file_in_notepad:
    SYS_OPEN_FILE_NP rdi
    ret

; ============================================================================
; kernel_open_file_in_notepad - runs in kernel context. Same semantics as the
; old user-mode helper, but uses direct kernel calls instead of syscall
; macros and finishes by re-copying the blob into the new notepad's slot so
; the slot reflects the freshly-loaded file contents.
;
; Note: common.inc %xdefine'd FAT16 helpers to user-mode syscall wrappers.
; Locally restore the real kernel symbols for launch helpers that run in ring 0;
; restore the aliases afterwards so the rest of the user blob is unaffected.
; RDI = slot-cached dir entry pointer
; Returns RAX = window id, or -1 on launch failure
; ============================================================================
%undef fat16_file_count
%undef fat16_get_entry
%undef fat16_change_dir
%undef fat16_read_file
extern fat16_file_count
extern fat16_get_entry
extern fat16_change_dir
extern fat16_read_file

; kernel_open_app_command - secure command-line app launcher.
; RDI = validated user cstring: "app" or "app params"
; Returns RAX = window id, or -1.
global kernel_open_app_command
kernel_open_app_command:
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi

    ; Copy the caller string into a bounded kernel-owned buffer before parsing.
    lea rdi, [app_open_cmd_buf]
    mov rsi, r12
    mov ecx, APP_SLOT_PARAM_SZ - 1
.koac_copy_cmd:
    lodsb
    stosb
    test al, al
    jz .koac_cmd_copied
    dec ecx
    jnz .koac_copy_cmd
    mov byte [rdi], 0
.koac_cmd_copied:

    lea rbx, [app_open_cmd_buf]
.koac_skip_lead:
    mov al, [rbx]
    cmp al, ' '
    je .koac_skip_lead_1
    cmp al, 9
    jne .koac_have_name
.koac_skip_lead_1:
    inc rbx
    jmp .koac_skip_lead
.koac_have_name:
    cmp byte [rbx], 0
    je .koac_fail
    mov r12, rbx

.koac_find_name_end:
    mov al, [rbx]
    test al, al
    jz .koac_name_ended
    cmp al, ' '
    je .koac_name_delim
    cmp al, 9
    je .koac_name_delim
    cmp al, ','
    je .koac_name_delim
    inc rbx
    jmp .koac_find_name_end
.koac_name_delim:
    mov byte [rbx], 0
    inc rbx
.koac_name_ended:
    mov rdi, r12
    call app_command_name_to_id
    test eax, eax
    jz .koac_fail
    mov r13d, eax

    ; Copy raw params, trimming leading whitespace/commas only.
.koac_skip_param_lead:
    mov al, [rbx]
    cmp al, ' '
    je .koac_skip_param_1
    cmp al, 9
    je .koac_skip_param_1
    cmp al, ','
    jne .koac_copy_params_start
.koac_skip_param_1:
    inc rbx
    jmp .koac_skip_param_lead
.koac_copy_params_start:
    lea rdi, [app_open_param_buf]
    xor eax, eax
    mov ecx, APP_SLOT_PARAM_SZ
    cld
    rep stosb
    lea rdi, [app_open_param_buf]
    mov rsi, rbx
    mov ecx, APP_SLOT_PARAM_SZ - 1
.koac_copy_param:
    lodsb
    stosb
    test al, al
    jz .koac_param_copied
    dec ecx
    jnz .koac_copy_param
    mov byte [rdi], 0
.koac_param_copied:

    cmp r13d, APP_NOTEPAD
    jne .koac_launch_generic
    cmp byte [app_open_param_buf], 0
    je .koac_launch_generic
    lea rdi, [app_open_param_buf]
    call app_find_entry_by_path
    test rax, rax
    jz .koac_fail
    mov rdi, rax
    call kernel_open_file_in_notepad
    cmp rax, -1
    je .koac_done
    mov edi, eax
    lea rsi, [app_open_param_buf]
    call app_store_launch_params
    jmp .koac_done

.koac_launch_generic:
    mov edi, r13d
    sub rsp, 8
    call app_launch
    add rsp, 8
    cmp rax, -1
    je .koac_done
    mov edi, eax
    lea rsi, [app_open_param_buf]
    call app_store_launch_params
    jmp .koac_done

.koac_fail:
    mov rax, -1
.koac_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

; RDI = app name token, returns EAX = APP_* id or 0.
app_command_name_to_id:
    lea rsi, [szAppNameExplorer]
    call app_str_eq_ci
    test eax, eax
    jnz .acnti_explorer
    lea rsi, [szAppNameTerminal]
    call app_str_eq_ci
    test eax, eax
    jnz .acnti_terminal
    lea rsi, [szAppNameNotepad]
    call app_str_eq_ci
    test eax, eax
    jnz .acnti_notepad
    lea rsi, [szAppNameSettings]
    call app_str_eq_ci
    test eax, eax
    jnz .acnti_settings
    lea rsi, [szAppNamePaint]
    call app_str_eq_ci
    test eax, eax
    jnz .acnti_paint
    lea rsi, [szAppNameAbout]
    call app_str_eq_ci
    test eax, eax
    jnz .acnti_about
    lea rsi, [szAppNameSecurity]
    call app_str_eq_ci
    test eax, eax
    jnz .acnti_security
    lea rsi, [szAppNameSecurityProbe]
    call app_str_eq_ci
    test eax, eax
    jnz .acnti_security
    xor eax, eax
    ret
.acnti_explorer:
    mov eax, APP_EXPLORER
    ret
.acnti_terminal:
    mov eax, APP_TERMINAL
    ret
.acnti_notepad:
    mov eax, APP_NOTEPAD
    ret
.acnti_settings:
    mov eax, APP_SETTINGS
    ret
.acnti_paint:
    mov eax, APP_PAINT
    ret
.acnti_about:
    mov eax, APP_ABOUT
    ret
.acnti_security:
    mov eax, APP_SECURITY_PROBE
    ret

; Case-insensitive ASCII strcmp. RDI=a, RSI=b, EAX=1 on match.
app_str_eq_ci:
    push rdi
    push rsi
.ase_loop:
    mov al, [rdi]
    mov ah, [rsi]
    cmp al, 'A'
    jb .ase_a_ready
    cmp al, 'Z'
    ja .ase_a_ready
    add al, 32
.ase_a_ready:
    cmp ah, 'A'
    jb .ase_b_ready
    cmp ah, 'Z'
    ja .ase_b_ready
    add ah, 32
.ase_b_ready:
    cmp al, ah
    jne .ase_no
    test al, al
    jz .ase_yes
    inc rdi
    inc rsi
    jmp .ase_loop
.ase_yes:
    mov eax, 1
    jmp .ase_done
.ase_no:
    xor eax, eax
.ase_done:
    pop rsi
    pop rdi
    ret

; EDI=window id, RSI=params. Copies params into the target app slot.
app_store_launch_params:
    push rax
    push rcx
    push rdi
    push rsi
    cmp edi, MAX_WINDOWS
    jae .aslp_done
    mov eax, edi
    imul rax, WINDOW_STRUCT_SIZE
    add rax, WINDOW_POOL_ADDR
    mov rdi, [rax + WIN_OFF_APPDATA]
    test rdi, rdi
    jz .aslp_done
    add rdi, APP_SLOT_PARAM_OFF
    mov ecx, APP_SLOT_PARAM_SZ
    cld
    rep movsb
.aslp_done:
    pop rsi
    pop rdi
    pop rcx
    pop rax
    ret

; RDI=path. Resolves root/current FAT16 path to a live dir-entry pointer.
app_find_entry_by_path:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r12
    push r13
    push r14

    mov r12, rdi
    ; A root-qualified path starts at /, \, C:/, C:\, or root/.
    cmp byte [r12], '/'
    je .afebp_root_slash
    cmp byte [r12], '\'
    je .afebp_root_slash
    mov al, [r12]
    cmp al, 'C'
    je .afebp_drive_maybe
    cmp al, 'c'
    jne .afebp_root_name_maybe
.afebp_drive_maybe:
    cmp byte [r12 + 1], ':'
    jne .afebp_root_name_maybe
    mov ax, 0
    call fat16_change_dir
    add r12, 2
    jmp .afebp_skip_slashes
.afebp_root_name_maybe:
    mov rdi, r12
    lea rsi, [szAppNameRoot]
    call app_path_has_prefix
    test eax, eax
    jz .afebp_component_loop
    mov ax, 0
    call fat16_change_dir
    add r12, 4
    jmp .afebp_skip_slashes
.afebp_root_slash:
    mov ax, 0
    call fat16_change_dir
.afebp_skip_slashes:
    cmp byte [r12], '/'
    je .afebp_skip_one
    cmp byte [r12], '\'
    jne .afebp_component_loop
.afebp_skip_one:
    inc r12
    jmp .afebp_skip_slashes

.afebp_component_loop:
    cmp byte [r12], 0
    je .afebp_fail
    lea rdi, [app_open_comp_buf]
    xor ecx, ecx
.afebp_copy_comp:
    mov al, [r12]
    test al, al
    jz .afebp_comp_done
    cmp al, '/'
    je .afebp_comp_done
    cmp al, '\'
    je .afebp_comp_done
    cmp ecx, 63
    jae .afebp_fail
    mov [rdi], al
    inc rdi
    inc r12
    inc ecx
    jmp .afebp_copy_comp
.afebp_comp_done:
    mov byte [rdi], 0
    lea rdi, [app_open_comp_buf]
    lea rsi, [app_open_83_buf]
    call filename_to_83
    lea rdi, [app_open_83_buf]
    call app_find_entry_83
    test rax, rax
    jz .afebp_fail
    mov r14, rax
    ; Skip separators and decide if this is the final component.
.afebp_after_comp_slashes:
    cmp byte [r12], '/'
    je .afebp_after_comp_skip
    cmp byte [r12], '\'
    jne .afebp_after_comp_ready
.afebp_after_comp_skip:
    inc r12
    jmp .afebp_after_comp_slashes
.afebp_after_comp_ready:
    cmp byte [r12], 0
    je .afebp_success
    mov al, [r14 + 11]
    test al, 0x10
    jz .afebp_fail
    mov ax, [r14 + 26]
    call fat16_change_dir
    test eax, eax
    jnz .afebp_fail
    jmp .afebp_component_loop

.afebp_success:
    mov rax, r14
    jmp .afebp_done
.afebp_fail:
    xor eax, eax
.afebp_done:
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

; RDI=path, RSI=literal prefix. EAX=1 if followed by /, \, or NUL.
app_path_has_prefix:
    push rdi
    push rsi
.aphp_loop:
    mov al, [rsi]
    test al, al
    jz .aphp_prefix_done
    mov ah, [rdi]
    cmp ah, 'A'
    jb .aphp_cmp
    cmp ah, 'Z'
    ja .aphp_cmp
    add ah, 32
.aphp_cmp:
    cmp ah, al
    jne .aphp_no
    inc rdi
    inc rsi
    jmp .aphp_loop
.aphp_prefix_done:
    mov al, [rdi]
    test al, al
    jz .aphp_yes
    cmp al, '/'
    je .aphp_yes
    cmp al, '\'
    je .aphp_yes
.aphp_no:
    xor eax, eax
    jmp .aphp_done
.aphp_yes:
    mov eax, 1
.aphp_done:
    pop rsi
    pop rdi
    ret

; RDI=11-byte 8.3 name. Returns matching current-directory entry or 0.
app_find_entry_83:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r12
    mov r12, rdi
    call fat16_file_count
    mov ebx, eax
    xor ecx, ecx
.afe83_loop:
    cmp ecx, ebx
    jge .afe83_fail
    mov edi, ecx
    push rcx
    call fat16_get_entry
    pop rcx
    test rax, rax
    jz .afe83_fail
    mov rsi, r12
    mov rdi, rax
    mov edx, 11
.afe83_cmp:
    mov al, [rdi]
    cmp al, [rsi]
    jne .afe83_next
    inc rdi
    inc rsi
    dec edx
    jnz .afe83_cmp
    sub rdi, 11
    mov rax, rdi
    jmp .afe83_done
.afe83_next:
    inc ecx
    jmp .afe83_loop
.afe83_fail:
    xor eax, eax
.afe83_done:
    pop r12
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

global kernel_open_file_in_notepad
; Open a FAT16 file (RDI = dir-entry ptr) in a fresh Notepad window. All per-
; instance state is written directly into the new window's L3 slot — never
; into the kernel image's np_* master copies. The kernel-side notepad_buf is
; used as a transient raw-bytes scratch, scoped strictly to this call.
kernel_open_file_in_notepad:
    SER 'O'
    SER 'F'
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi                      ; dir entry ptr

    ; Launch a fresh Notepad. app_seed_notepad_slot resets the slot to a
    ; pristine "Hello" baseline; we then overwrite slot state with file data.
    mov rdi, APP_NOTEPAD
    sub rsp, 8
    call app_launch
    add rsp, 8
    cmp rax, -1
    je .kop_fail
    mov r13, rax                      ; new window id (== slot index)

    ; Cascade window position so file viewers don't cover Explorer.
    mov rax, r13
    imul rax, WINDOW_STRUCT_SIZE
    add rax, WINDOW_POOL_ADDR
    mov qword [rax + WIN_OFF_X], 560
    mov rbx, r13
    imul rbx, 24
    add rbx, 80
    mov [rax + WIN_OFF_Y], rbx
    lea rdi, [rax + 48]
    mov rsi, r12
    call fat16_format_name_to

    ; Resolve the slot base. All subsequent writes are slot-relative.
    mov edi, r13d
    call l3_slot_base
    mov r14, rax                      ; r14 = slot base

    ; Save dir entry into slot so Save can find the file later.
    mov [r14 + np_open_entry - app_blob_start], r12

    ; Pre-zero slot's notepad_buf + np_line_len so untouched cells stay clean.
    push rdi
    push rax
    push rcx
    lea rdi, [r14 + notepad_buf - app_blob_start]
    xor eax, eax
    mov ecx, NP_BUF_SIZE
    rep stosb
    lea rdi, [r14 + np_line_len - app_blob_start]
    xor eax, eax
    mov ecx, NP_MAX_LINES
    rep stosd
    pop rcx
    pop rax
    pop rdi

    ; Read raw file bytes into kernel-side notepad_buf (scratch only).
    mov rdi, r12
    lea rsi, [notepad_buf]
    mov edx, NP_BUF_SIZE - 1
    call fat16_read_file
    cmp eax, -1
    je .kop_empty
    test eax, eax
    jz .kop_empty
    ; Clamp the byte count to the scratch capacity; fat16_read_file is
    ; expected to honour edx, but defence-in-depth — this is the only
    ; bound between an attacker-controlled file size and the parse loop.
    cmp eax, NP_BUF_SIZE - 1
    jbe .kop_size_ok
    mov eax, NP_BUF_SIZE - 1
.kop_size_ok:
    lea rbx, [notepad_buf]
    mov byte [rbx + rax], 0

    ; Parse scratch -> slot's per-line layout.
    ;   r14 = slot base, rbx = scratch base, r12d = raw byte count
    mov r12d, eax
    xor ecx, ecx                      ; line index
    xor edx, edx                      ; column
    xor esi, esi                      ; raw offset

.kop_parse_loop:
    cmp esi, r12d
    jge .kop_parse_done
    cmp ecx, NP_MAX_LINES - 1
    jge .kop_parse_done

    movzx eax, byte [rbx + rsi]
    inc esi

    cmp al, 13
    je .kop_parse_cr
    cmp al, 10
    je .kop_parse_lf

    cmp edx, NP_MAX_COLS - 1
    jge .kop_parse_loop               ; clip overlong lines

    push rcx
    imul ecx, NP_MAX_COLS
    add rcx, rdx
    mov [r14 + rcx + notepad_buf - app_blob_start], al
    pop rcx
    inc edx
    jmp .kop_parse_loop

.kop_parse_cr:
    cmp esi, r12d
    jge .kop_parse_newline
    cmp byte [rbx + rsi], 10
    jne .kop_parse_newline
    inc esi
.kop_parse_lf:
.kop_parse_newline:
    push rcx
    imul ecx, NP_MAX_COLS
    add rcx, rdx
    mov byte [r14 + rcx + notepad_buf - app_blob_start], 0
    pop rcx
    mov [r14 + np_line_len - app_blob_start + rcx * 4], edx
    inc ecx
    xor edx, edx
    jmp .kop_parse_loop

.kop_parse_done:
    push rcx
    push rcx
    imul ecx, NP_MAX_COLS
    add rcx, rdx
    mov byte [r14 + rcx + notepad_buf - app_blob_start], 0
    pop rcx
    mov [r14 + np_line_len - app_blob_start + rcx * 4], edx
    pop rcx
    inc ecx
    mov [r14 + np_num_lines - app_blob_start], ecx
    mov dword [r14 + np_cursor_row - app_blob_start], 0
    mov dword [r14 + np_cursor_col - app_blob_start], 0
    mov dword [r14 + np_scroll_top - app_blob_start], 0
    jmp .kop_seed_visible

.kop_empty:
    mov dword [r14 + np_num_lines - app_blob_start], 1
    mov dword [r14 + np_cursor_row - app_blob_start], 0
    mov dword [r14 + np_cursor_col - app_blob_start], 0
    mov dword [r14 + np_scroll_top - app_blob_start], 0
    mov byte  [r14 + notepad_buf - app_blob_start], 0
    mov dword [r14 + np_line_len - app_blob_start], 0

.kop_seed_visible:
    ; Seed slot's szOpenTextScratch with the first visible line so the very
    ; first draw frame (which may fire before copy_line_to_scratch runs)
    ; renders real bytes instead of whatever was there before.
    lea rdi, [r14 + app_hl_notepad_szOpenTextScratch - app_blob_start]
    lea rsi, [r14 + notepad_buf - app_blob_start]
    mov ecx, NP_MAX_COLS - 1
.kop_copy_visible:
    lodsb
    test al, al
    jz .kop_copy_visible_done
    stosb
    dec ecx
    jnz .kop_copy_visible
.kop_copy_visible_done:
    mov byte [rdi], 0

    ; Clear scratch so we don't leave file bytes in the kernel image's master
    ; copy (defence-in-depth — nothing should read them, but stale file
    ; content lingering in kernel .data is a needless info-leak surface).
    push rdi
    push rax
    push rcx
    lea rdi, [notepad_buf]
    xor eax, eax
    mov ecx, NP_BUF_SIZE
    rep stosb
    pop rcx
    pop rax
    pop rdi

    mov rax, r13
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

.kop_fail:
    mov rax, -1
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

; Restore the user-mode alias for the remainder of the blob.
%xdefine fat16_file_count app_sys_fs_count
%xdefine fat16_get_entry app_sys_fs_get_entry
%xdefine fat16_change_dir app_sys_fs_change_dir
%xdefine fat16_read_file app_sys_fs_read

; ============================================================================
; FILE EXPLORER APP
; Virtual filesystem with navigable directories
; ============================================================================

; Draw callback: RDI = window struct ptr
