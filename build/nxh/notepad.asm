; NexusHL generated — do not edit by hand
; app="Notepad" stack=8192
extern notepad_buf
extern np_cursor_col
extern np_cursor_row
extern np_has_saved
extern np_line_len
extern np_menu_open
extern np_num_lines
extern np_open_entry
extern np_save_dialog
extern np_save_done_msg
extern np_save_field
extern np_save_total_bytes
extern np_saveas_83
extern np_saveas_buf
extern np_saveas_cursor
extern np_saved_content
extern np_saveloc_83
extern np_saveloc_buf
extern np_saveloc_cursor
extern np_scroll_top
extern render_rect
extern render_text
extern szCursor
FN_BEGIN app_hl_notepad_display_flags, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 64
    push rbx
    push r12
    mov rax, 24
    syscall
    jmp .fn_end_0_app_hl_notepad_display_flags
.fn_end_0_app_hl_notepad_display_flags:
    FN_END app_hl_notepad_display_flags
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_display_set_flags, 1, 0, FN_RET_SCALAR
FN_ARG 0, flags, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rdi, [rbp-8]
    mov rax, 25
    syscall
    jmp .fn_end_0_app_hl_notepad_display_set_flags
.fn_end_0_app_hl_notepad_display_set_flags:
    FN_END app_hl_notepad_display_set_flags
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_display_set_mode, 3, 0, FN_RET_SCALAR
FN_ARG 0, width, FN_KIND_SCALAR
FN_ARG 1, height, FN_KIND_SCALAR
FN_ARG 2, bpp, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 96
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    push rbx
    push r12
    mov rdx, [rbp-24]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    mov rax, 16
    syscall
    jmp .fn_end_0_app_hl_notepad_display_set_mode
.fn_end_0_app_hl_notepad_display_set_mode:
    FN_END app_hl_notepad_display_set_mode
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_cursor_init, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 64
    push rbx
    push r12
    mov rax, 17
    syscall
    jmp .fn_end_0_app_hl_notepad_cursor_init
.fn_end_0_app_hl_notepad_cursor_init:
    FN_END app_hl_notepad_cursor_init
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_desktop_bg, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 64
    push rbx
    push r12
    mov rax, 26
    syscall
    jmp .fn_end_0_app_hl_notepad_desktop_bg
.fn_end_0_app_hl_notepad_desktop_bg:
    FN_END app_hl_notepad_desktop_bg
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_desktop_set_bg, 1, 0, FN_RET_SCALAR
FN_ARG 0, theme, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rdi, [rbp-8]
    mov rax, 27
    syscall
    jmp .fn_end_0_app_hl_notepad_desktop_set_bg
.fn_end_0_app_hl_notepad_desktop_set_bg:
    FN_END app_hl_notepad_desktop_set_bg
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_display_native_width, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    push rbx
    push r12
    mov rax, 28
    syscall
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 4294967295
    pop rax
    and rax, rcx
    jmp .fn_end_0_app_hl_notepad_display_native_width
.fn_end_0_app_hl_notepad_display_native_width:
    FN_END app_hl_notepad_display_native_width
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_display_native_height, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    push rbx
    push r12
    mov rax, 28
    syscall
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 32
    pop rax
    shr rax, cl
    push rax
    mov rcx, 4294967295
    pop rax
    and rax, rcx
    jmp .fn_end_0_app_hl_notepad_display_native_height
.fn_end_0_app_hl_notepad_display_native_height:
    FN_END app_hl_notepad_display_native_height
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_display_current_width, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    push rbx
    push r12
    mov rax, 29
    syscall
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 4294967295
    pop rax
    and rax, rcx
    jmp .fn_end_0_app_hl_notepad_display_current_width
.fn_end_0_app_hl_notepad_display_current_width:
    FN_END app_hl_notepad_display_current_width
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_display_current_height, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    push rbx
    push r12
    mov rax, 29
    syscall
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 32
    pop rax
    shr rax, cl
    push rax
    mov rcx, 4294967295
    pop rax
    and rax, rcx
    jmp .fn_end_0_app_hl_notepad_display_current_height
.fn_end_0_app_hl_notepad_display_current_height:
    FN_END app_hl_notepad_display_current_height
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_ui_win_x, 1, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    mov rcx, 8
    pop rax
    add rax, rcx
    mov rax, [rax]
    jmp .fn_end_0_app_hl_notepad_ui_win_x
.fn_end_0_app_hl_notepad_ui_win_x:
    FN_END app_hl_notepad_ui_win_x
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_ui_win_y, 1, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    mov rcx, 16
    pop rax
    add rax, rcx
    mov rax, [rax]
    jmp .fn_end_0_app_hl_notepad_ui_win_y
.fn_end_0_app_hl_notepad_ui_win_y:
    FN_END app_hl_notepad_ui_win_y
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_ui_win_w, 1, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    mov rcx, 24
    pop rax
    add rax, rcx
    mov rax, [rax]
    jmp .fn_end_0_app_hl_notepad_ui_win_w
.fn_end_0_app_hl_notepad_ui_win_w:
    FN_END app_hl_notepad_ui_win_w
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_ui_win_h, 1, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    mov rcx, 32
    pop rax
    add rax, rcx
    mov rax, [rax]
    jmp .fn_end_0_app_hl_notepad_ui_win_h
.fn_end_0_app_hl_notepad_ui_win_h:
    FN_END app_hl_notepad_ui_win_h
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_ui_rect, 5, 0, FN_RET_SCALAR
FN_ARG 0, x, FN_KIND_SCALAR
FN_ARG 1, y, FN_KIND_SCALAR
FN_ARG 2, w, FN_KIND_SCALAR
FN_ARG 3, h, FN_KIND_SCALAR
FN_ARG 4, color, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 112
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    mov [rbp-40], r8
    push rbx
    push r12
    mov r8, [rbp-40]
    mov rcx, [rbp-32]
    mov rdx, [rbp-24]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    FN_CALL render_rect, 5
.fn_end_0_app_hl_notepad_ui_rect:
    FN_END app_hl_notepad_ui_rect
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_ui_text, 5, 0, FN_RET_SCALAR
FN_ARG 0, x, FN_KIND_SCALAR
FN_ARG 1, y, FN_KIND_SCALAR
FN_ARG 2, text, FN_KIND_SCALAR
FN_ARG 3, fg, FN_KIND_SCALAR
FN_ARG 4, bg, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 112
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    mov [rbp-40], r8
    push rbx
    push r12
    mov r8, [rbp-40]
    mov rcx, [rbp-32]
    mov rdx, [rbp-24]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    FN_CALL render_text, 5
.fn_end_0_app_hl_notepad_ui_text:
    FN_END app_hl_notepad_ui_text
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_ui_rect_at, 6, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
FN_ARG 1, x, FN_KIND_SCALAR
FN_ARG 2, y, FN_KIND_SCALAR
FN_ARG 3, w, FN_KIND_SCALAR
FN_ARG 4, h, FN_KIND_SCALAR
FN_ARG 5, color, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 112
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    mov [rbp-40], r8
    mov [rbp-48], r9
    push rbx
    push r12
    mov rdi, [rbp-8]
    FN_CALL app_hl_notepad_ui_win_x, 1
    push rax
    mov rcx, 2
    pop rax
    add rax, rcx
    push rax
    mov rcx, [rbp-16]
    pop rax
    add rax, rcx
    push rax
    mov rdi, [rbp-8]
    FN_CALL app_hl_notepad_ui_win_y, 1
    push rax
    mov rcx, 24
    pop rax
    add rax, rcx
    push rax
    mov rcx, [rbp-24]
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_rect, 5
.fn_end_0_app_hl_notepad_ui_rect_at:
    FN_END app_hl_notepad_ui_rect_at
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_ui_text_at, 6, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
FN_ARG 1, x, FN_KIND_SCALAR
FN_ARG 2, y, FN_KIND_SCALAR
FN_ARG 3, text, FN_KIND_SCALAR
FN_ARG 4, fg, FN_KIND_SCALAR
FN_ARG 5, bg, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 112
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    mov [rbp-40], r8
    mov [rbp-48], r9
    push rbx
    push r12
    mov rdi, [rbp-8]
    FN_CALL app_hl_notepad_ui_win_x, 1
    push rax
    mov rcx, 2
    pop rax
    add rax, rcx
    push rax
    mov rcx, [rbp-16]
    pop rax
    add rax, rcx
    push rax
    mov rdi, [rbp-8]
    FN_CALL app_hl_notepad_ui_win_y, 1
    push rax
    mov rcx, 24
    pop rax
    add rax, rcx
    push rax
    mov rcx, [rbp-24]
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_text, 5
.fn_end_0_app_hl_notepad_ui_text_at:
    FN_END app_hl_notepad_ui_text_at
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_ui_fill_client_below, 3, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
FN_ARG 1, top, FN_KIND_SCALAR
FN_ARG 2, color, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 112
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    push rbx
    push r12
    mov rdi, [rbp-8]
    FN_CALL app_hl_notepad_ui_win_w, 1
    push rax
    mov rax, 2
    push rax
    mov rcx, 2
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov [rbp-40], rax
    mov rdi, [rbp-8]
    FN_CALL app_hl_notepad_ui_win_h, 1
    push rax
    mov rcx, 24
    pop rax
    sub rax, rcx
    push rax
    mov rcx, [rbp-16]
    pop rax
    sub rax, rcx
    push rax
    mov rcx, 2
    pop rax
    sub rax, rcx
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setle al
    movzx rax, al
    test rax, rax
    jz .else1
    jmp .fn_end_0_app_hl_notepad_ui_fill_client_below
    jmp .endif2
.else1:
.endif2:
    mov r9, [rbp-24]
    mov r8, [rbp-48]
    mov rcx, [rbp-40]
    mov rdx, [rbp-16]
    mov rsi, 0
    mov rdi, [rbp-8]
    FN_CALL app_hl_notepad_ui_rect_at, 6
.fn_end_0_app_hl_notepad_ui_fill_client_below:
    FN_END app_hl_notepad_ui_fill_client_below
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_ui_menu_bar, 1, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    push rax
    mov rax, 0
    push rax
    mov rdi, [rbp-8]
    FN_CALL app_hl_notepad_ui_win_w, 1
    push rax
    mov rax, 2
    push rax
    mov rcx, 2
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, 22
    push rax
    mov rax, 15527924
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_rect_at, 6
.fn_end_2_app_hl_notepad_ui_menu_bar:
    FN_END app_hl_notepad_ui_menu_bar
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_ui_menu_label, 3, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
FN_ARG 1, x, FN_KIND_SCALAR
FN_ARG 2, text, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 96
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    push rbx
    push r12
    mov r9, 15527924
    mov r8, 988190
    mov rcx, [rbp-24]
    mov rdx, 5
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    FN_CALL app_hl_notepad_ui_text_at, 6
.fn_end_2_app_hl_notepad_ui_menu_label:
    FN_END app_hl_notepad_ui_menu_label
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_ui_dropdown, 5, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
FN_ARG 1, x, FN_KIND_SCALAR
FN_ARG 2, y, FN_KIND_SCALAR
FN_ARG 3, w, FN_KIND_SCALAR
FN_ARG 4, item_count, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 112
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    mov [rbp-40], r8
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-40]
    push rax
    mov rcx, 20
    pop rax
    imul rax, rcx
    push rax
    mov rcx, 4
    pop rax
    add rax, rcx
    push rax
    mov rax, 16777215
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_rect_at, 6
    mov r9, 14212579
    mov r8, 1
    mov rcx, [rbp-32]
    mov rdx, [rbp-24]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    FN_CALL app_hl_notepad_ui_rect_at, 6
.fn_end_2_app_hl_notepad_ui_dropdown:
    FN_END app_hl_notepad_ui_dropdown
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_ui_dropdown_item, 5, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
FN_ARG 1, x, FN_KIND_SCALAR
FN_ARG 2, y, FN_KIND_SCALAR
FN_ARG 3, index, FN_KIND_SCALAR
FN_ARG 4, text, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 112
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    mov [rbp-40], r8
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 8
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-24]
    push rax
    mov rcx, 4
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 20
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, 988190
    push rax
    mov rax, 16777215
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_text_at, 6
.fn_end_2_app_hl_notepad_ui_dropdown_item:
    FN_END app_hl_notepad_ui_dropdown_item
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_ui_caret, 3, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
FN_ARG 1, x, FN_KIND_SCALAR
FN_ARG 2, y, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 96
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    push rbx
    push r12
    mov r9, 2781183
    mov r8, 14
    mov rcx, 2
    mov rdx, [rbp-24]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    FN_CALL app_hl_notepad_ui_rect_at, 6
.fn_end_2_app_hl_notepad_ui_caret:
    FN_END app_hl_notepad_ui_caret
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_ui_ticks, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 64
    push rbx
    push r12
    mov rax, 18
    syscall
    jmp .fn_end_2_app_hl_notepad_ui_ticks
.fn_end_2_app_hl_notepad_ui_ticks:
    FN_END app_hl_notepad_ui_ticks
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_ui_caret_blink, 3, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
FN_ARG 1, x, FN_KIND_SCALAR
FN_ARG 2, y, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 96
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    push rbx
    push r12
    FN_CALL app_hl_notepad_ui_ticks, 0
    push rax
    mov rcx, 30
    pop rax
    cqo
    idiv rcx
    mov rcx, rax
    sar rcx, 63
    shr rcx, 63
    add rax, rcx
    and rax, 1
    sub rax, rcx
    mov [rbp-40], rax
    mov rax, [rbp-40]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else3
    mov rdx, [rbp-24]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    FN_CALL app_hl_notepad_ui_caret, 3
    jmp .endif4
.else3:
.endif4:
.fn_end_2_app_hl_notepad_ui_caret_blink:
    FN_END app_hl_notepad_ui_caret_blink
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_ui_input, 6, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
FN_ARG 1, x, FN_KIND_SCALAR
FN_ARG 2, y, FN_KIND_SCALAR
FN_ARG 3, w, FN_KIND_SCALAR
FN_ARG 4, text, FN_KIND_SCALAR
FN_ARG 5, cursor_col, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 112
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    mov [rbp-40], r8
    mov [rbp-48], r9
    push rbx
    push r12
    mov r9, 16777215
    mov r8, 18
    mov rcx, [rbp-32]
    mov rdx, [rbp-24]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    FN_CALL app_hl_notepad_ui_rect_at, 6
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 4
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-24]
    push rax
    mov rcx, 3
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, 988190
    push rax
    mov rax, 16777215
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_text_at, 6
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 4
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-48]
    push rax
    mov rcx, 8
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-24]
    push rax
    mov rcx, 2
    pop rax
    add rax, rcx
    mov rdx, rax
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_caret_blink, 3
.fn_end_4_app_hl_notepad_ui_input:
    FN_END app_hl_notepad_ui_input
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_ui_button, 6, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
FN_ARG 1, x, FN_KIND_SCALAR
FN_ARG 2, y, FN_KIND_SCALAR
FN_ARG 3, w, FN_KIND_SCALAR
FN_ARG 4, label, FN_KIND_SCALAR
FN_ARG 5, bg, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 112
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    mov [rbp-40], r8
    mov [rbp-48], r9
    push rbx
    push r12
    mov r9, [rbp-48]
    mov r8, 16
    mov rcx, [rbp-32]
    mov rdx, [rbp-24]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    FN_CALL app_hl_notepad_ui_rect_at, 6
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 4
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-24]
    push rax
    mov rcx, 2
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, 988190
    push rax
    mov rax, [rbp-48]
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_text_at, 6
.fn_end_4_app_hl_notepad_ui_button:
    FN_END app_hl_notepad_ui_button
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_ui_button_hit, 5, 0, FN_RET_SCALAR
FN_ARG 0, cx, FN_KIND_SCALAR
FN_ARG 1, cy, FN_KIND_SCALAR
FN_ARG 2, x, FN_KIND_SCALAR
FN_ARG 3, y, FN_KIND_SCALAR
FN_ARG 4, w, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 112
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    mov [rbp-40], r8
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    mov rcx, [rbp-24]
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else5
    mov rax, 0
    jmp .fn_end_4_app_hl_notepad_ui_button_hit
    jmp .endif6
.else5:
.endif6:
    mov rax, [rbp-16]
    push rax
    mov rcx, [rbp-32]
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else7
    mov rax, 0
    jmp .fn_end_4_app_hl_notepad_ui_button_hit
    jmp .endif8
.else7:
.endif8:
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rcx, [rbp-40]
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else9
    mov rax, 0
    jmp .fn_end_4_app_hl_notepad_ui_button_hit
    jmp .endif10
.else9:
.endif10:
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 16
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else11
    mov rax, 0
    jmp .fn_end_4_app_hl_notepad_ui_button_hit
    jmp .endif12
.else11:
.endif12:
    mov rax, 1
    jmp .fn_end_4_app_hl_notepad_ui_button_hit
.fn_end_4_app_hl_notepad_ui_button_hit:
    FN_END app_hl_notepad_ui_button_hit
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_ui_section_title, 3, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
FN_ARG 1, y, FN_KIND_SCALAR
FN_ARG 2, text, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 96
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    push rbx
    push r12
    mov r9, 16119546
    mov r8, 988190
    mov rcx, [rbp-24]
    mov rdx, [rbp-16]
    mov rsi, 12
    mov rdi, [rbp-8]
    FN_CALL app_hl_notepad_ui_text_at, 6
    mov rax, [rbp-16]
    push rax
    mov rcx, 22
    pop rax
    add rax, rcx
    jmp .fn_end_12_app_hl_notepad_ui_section_title
.fn_end_12_app_hl_notepad_ui_section_title:
    FN_END app_hl_notepad_ui_section_title
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_ui_caption, 4, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
FN_ARG 1, x, FN_KIND_SCALAR
FN_ARG 2, y, FN_KIND_SCALAR
FN_ARG 3, text, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 96
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    push rbx
    push r12
    mov r9, 16119546
    mov r8, 4937059
    mov rcx, [rbp-32]
    mov rdx, [rbp-24]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    FN_CALL app_hl_notepad_ui_text_at, 6
    mov rax, [rbp-24]
    push rax
    mov rcx, 12
    pop rax
    add rax, rcx
    push rax
    mov rcx, 6
    pop rax
    add rax, rcx
    jmp .fn_end_12_app_hl_notepad_ui_caption
.fn_end_12_app_hl_notepad_ui_caption:
    FN_END app_hl_notepad_ui_caption
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_ui_checkbox, 5, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
FN_ARG 1, x, FN_KIND_SCALAR
FN_ARG 2, y, FN_KIND_SCALAR
FN_ARG 3, checked, FN_KIND_SCALAR
FN_ARG 4, label, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 112
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    mov [rbp-40], r8
    push rbx
    push r12
    mov r9, 16777215
    mov r8, 16
    mov rcx, 16
    mov rdx, [rbp-24]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    FN_CALL app_hl_notepad_ui_rect_at, 6
    mov r9, 12897235
    mov r8, 1
    mov rcx, 16
    mov rdx, [rbp-24]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    FN_CALL app_hl_notepad_ui_rect_at, 6
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rcx, 16
    pop rax
    add rax, rcx
    push rax
    mov rcx, 1
    pop rax
    sub rax, rcx
    push rax
    mov rax, 16
    push rax
    mov rax, 1
    push rax
    mov rax, 12897235
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_rect_at, 6
    mov r9, 12897235
    mov r8, 16
    mov rcx, 1
    mov rdx, [rbp-24]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    FN_CALL app_hl_notepad_ui_rect_at, 6
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 16
    pop rax
    add rax, rcx
    push rax
    mov rcx, 1
    pop rax
    sub rax, rcx
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    push rax
    mov rax, 16
    push rax
    mov rax, 12897235
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_rect_at, 6
    mov rax, [rbp-32]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else13
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 4
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-24]
    push rax
    mov rcx, 4
    pop rax
    add rax, rcx
    push rax
    mov rax, 8
    push rax
    mov rax, 8
    push rax
    mov rax, 988190
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_rect_at, 6
    jmp .endif14
.else13:
.endif14:
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 16
    pop rax
    add rax, rcx
    push rax
    mov rcx, 8
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-24]
    push rax
    mov rcx, 2
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, 988190
    push rax
    mov rax, 16119546
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_text_at, 6
    mov rax, [rbp-24]
    push rax
    mov rcx, 22
    pop rax
    add rax, rcx
    jmp .fn_end_12_app_hl_notepad_ui_checkbox
.fn_end_12_app_hl_notepad_ui_checkbox:
    FN_END app_hl_notepad_ui_checkbox
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_ui_row_x, 3, 0, FN_RET_SCALAR
FN_ARG 0, x0, FN_KIND_SCALAR
FN_ARG 1, w, FN_KIND_SCALAR
FN_ARG 2, index, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 96
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 8
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    jmp .fn_end_14_app_hl_notepad_ui_row_x
.fn_end_14_app_hl_notepad_ui_row_x:
    FN_END app_hl_notepad_ui_row_x
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_ui_status_bar, 3, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
FN_ARG 1, label, FN_KIND_SCALAR
FN_ARG 2, color, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 112
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    push rbx
    push r12
    mov rdi, [rbp-8]
    FN_CALL app_hl_notepad_ui_win_h, 1
    mov [rbp-40], rax
    mov rdi, [rbp-8]
    FN_CALL app_hl_notepad_ui_win_w, 1
    push rax
    mov rax, 2
    push rax
    mov rcx, 2
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov [rbp-48], rax
    mov rax, [rbp-40]
    push rax
    mov rcx, 24
    pop rax
    sub rax, rcx
    push rax
    mov rcx, 2
    pop rax
    sub rax, rcx
    push rax
    mov rcx, 18
    pop rax
    sub rax, rcx
    mov [rbp-56], rax
    mov r9, [rbp-24]
    mov r8, 18
    mov rcx, [rbp-48]
    mov rdx, [rbp-56]
    mov rsi, 0
    mov rdi, [rbp-8]
    FN_CALL app_hl_notepad_ui_rect_at, 6
    mov rax, [rbp-8]
    push rax
    mov rax, 4
    push rax
    mov rax, [rbp-56]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 4937059
    push rax
    mov rax, [rbp-24]
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_text_at, 6
    mov rax, [rbp-56]
    jmp .fn_end_14_app_hl_notepad_ui_status_bar
.fn_end_14_app_hl_notepad_ui_status_bar:
    FN_END app_hl_notepad_ui_status_bar
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_ui_modal_overlay, 6, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
FN_ARG 1, label, FN_KIND_SCALAR
FN_ARG 2, text, FN_KIND_SCALAR
FN_ARG 3, cursor, FN_KIND_SCALAR
FN_ARG 4, color, FN_KIND_SCALAR
FN_ARG 5, text_x, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 144
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    mov [rbp-40], r8
    mov [rbp-48], r9
    push rbx
    push r12
    mov rdi, [rbp-8]
    FN_CALL app_hl_notepad_ui_win_h, 1
    mov [rbp-64], rax
    mov rdi, [rbp-8]
    FN_CALL app_hl_notepad_ui_win_w, 1
    push rax
    mov rax, 2
    push rax
    mov rcx, 2
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov [rbp-72], rax
    mov rax, [rbp-64]
    push rax
    mov rcx, 24
    pop rax
    sub rax, rcx
    push rax
    mov rcx, 2
    pop rax
    sub rax, rcx
    push rax
    mov rcx, 18
    pop rax
    sub rax, rcx
    push rax
    mov rcx, 22
    pop rax
    sub rax, rcx
    mov [rbp-80], rax
    mov r9, [rbp-40]
    mov r8, 22
    mov rcx, [rbp-72]
    mov rdx, [rbp-80]
    mov rsi, 0
    mov rdi, [rbp-8]
    FN_CALL app_hl_notepad_ui_rect_at, 6
    mov rax, [rbp-8]
    push rax
    mov rax, 4
    push rax
    mov rax, [rbp-80]
    push rax
    mov rcx, 4
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 16777215
    push rax
    mov rax, [rbp-40]
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_text_at, 6
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-80]
    push rax
    mov rcx, 4
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, 16777215
    push rax
    mov rax, [rbp-40]
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_text_at, 6
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 8
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-80]
    push rax
    mov rcx, 3
    pop rax
    add rax, rcx
    mov rdx, rax
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_caret_blink, 3
.fn_end_14_app_hl_notepad_ui_modal_overlay:
    FN_END app_hl_notepad_ui_modal_overlay
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_ui_context_menu, 4, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
FN_ARG 1, x, FN_KIND_SCALAR
FN_ARG 2, y, FN_KIND_SCALAR
FN_ARG 3, count, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 112
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    push rbx
    push r12
    mov rax, [rbp-32]
    push rax
    mov rcx, 20
    pop rax
    imul rax, rcx
    push rax
    mov rcx, 4
    pop rax
    add rax, rcx
    mov [rbp-48], rax
    mov r9, 16777215
    mov r8, [rbp-48]
    mov rcx, 130
    mov rdx, [rbp-24]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    FN_CALL app_hl_notepad_ui_rect_at, 6
    mov r9, 14212579
    mov r8, 1
    mov rcx, 130
    mov rdx, [rbp-24]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    FN_CALL app_hl_notepad_ui_rect_at, 6
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rcx, [rbp-48]
    pop rax
    add rax, rcx
    push rax
    mov rcx, 1
    pop rax
    sub rax, rcx
    push rax
    mov rax, 130
    push rax
    mov rax, 1
    push rax
    mov rax, 14212579
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_rect_at, 6
    mov r9, 14212579
    mov r8, [rbp-48]
    mov rcx, 1
    mov rdx, [rbp-24]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    FN_CALL app_hl_notepad_ui_rect_at, 6
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 130
    pop rax
    add rax, rcx
    push rax
    mov rcx, 1
    pop rax
    sub rax, rcx
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    push rax
    mov rax, [rbp-48]
    push rax
    mov rax, 14212579
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_rect_at, 6
.fn_end_14_app_hl_notepad_ui_context_menu:
    FN_END app_hl_notepad_ui_context_menu
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_ui_context_menu_item, 6, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
FN_ARG 1, x, FN_KIND_SCALAR
FN_ARG 2, y, FN_KIND_SCALAR
FN_ARG 3, index, FN_KIND_SCALAR
FN_ARG 4, label, FN_KIND_SCALAR
FN_ARG 5, fg, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 112
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    mov [rbp-40], r8
    mov [rbp-48], r9
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 8
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-24]
    push rax
    mov rcx, 4
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 20
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
    push rax
    mov rax, 16777215
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_text_at, 6
.fn_end_14_app_hl_notepad_ui_context_menu_item:
    FN_END app_hl_notepad_ui_context_menu_item
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_ui_context_menu_hit, 5, 0, FN_RET_SCALAR
FN_ARG 0, cx, FN_KIND_SCALAR
FN_ARG 1, cy, FN_KIND_SCALAR
FN_ARG 2, x, FN_KIND_SCALAR
FN_ARG 3, y, FN_KIND_SCALAR
FN_ARG 4, count, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 128
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    mov [rbp-40], r8
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    mov rcx, [rbp-24]
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else15
    mov rax, 1
    neg rax
    jmp .fn_end_14_app_hl_notepad_ui_context_menu_hit
    jmp .endif16
.else15:
.endif16:
    mov rax, [rbp-16]
    push rax
    mov rcx, [rbp-32]
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else17
    mov rax, 1
    neg rax
    jmp .fn_end_14_app_hl_notepad_ui_context_menu_hit
    jmp .endif18
.else17:
.endif18:
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rcx, 130
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else19
    mov rax, 1
    neg rax
    jmp .fn_end_14_app_hl_notepad_ui_context_menu_hit
    jmp .endif20
.else19:
.endif20:
    mov rax, [rbp-40]
    push rax
    mov rcx, 20
    pop rax
    imul rax, rcx
    push rax
    mov rcx, 4
    pop rax
    add rax, rcx
    mov [rbp-56], rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rcx, [rbp-56]
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else21
    mov rax, 1
    neg rax
    jmp .fn_end_14_app_hl_notepad_ui_context_menu_hit
    jmp .endif22
.else21:
.endif22:
    mov rax, [rbp-16]
    push rax
    mov rcx, [rbp-32]
    pop rax
    sub rax, rcx
    push rax
    mov rcx, 4
    pop rax
    sub rax, rcx
    mov [rbp-64], rax
    mov rax, [rbp-64]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else23
    mov rax, 1
    neg rax
    jmp .fn_end_14_app_hl_notepad_ui_context_menu_hit
    jmp .endif24
.else23:
.endif24:
    mov rax, [rbp-64]
    push rax
    mov rcx, 20
    pop rax
    cqo
    idiv rcx
    mov [rbp-72], rax
    mov rax, [rbp-72]
    push rax
    mov rcx, [rbp-40]
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else25
    mov rax, 1
    neg rax
    jmp .fn_end_14_app_hl_notepad_ui_context_menu_hit
    jmp .endif26
.else25:
.endif26:
    mov rax, [rbp-72]
    jmp .fn_end_14_app_hl_notepad_ui_context_menu_hit
.fn_end_14_app_hl_notepad_ui_context_menu_hit:
    FN_END app_hl_notepad_ui_context_menu_hit
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_filename_to_83, 2, 0, FN_RET_SCALAR
FN_ARG 0, src, FN_KIND_SCALAR
FN_ARG 1, dst, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 144
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
    mov rax, 0
    mov [rbp-32], rax
.wst27:
    mov rax, [rbp-32]
    push rax
    mov rcx, 11
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend28
    mov rax, [rbp-16]
    push rax
    mov rcx, [rbp-32]
    pop rax
    add rax, rcx
    push rax
    mov rcx, 32
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-32], rax
    jmp .wst27
.wend28:
    mov rax, [rbp-8]
    mov [rbp-40], rax
    mov rax, 0
    mov [rbp-48], rax
    mov rax, 0
    mov [rbp-56], rax
.wst29:
    mov rax, 1
    test rax, rax
    jz .wend30
    mov rax, [rbp-40]
    movzx rax, byte [rax]
    mov [rbp-64], rax
    mov rax, [rbp-64]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else31
    jmp .fn_end_26_app_hl_notepad_filename_to_83
    jmp .endif32
.else31:
.endif32:
    mov rax, [rbp-64]
    push rax
    mov rcx, 46
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else33
    mov rax, 1
    mov [rbp-56], rax
    mov rax, [rbp-40]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-40], rax
    jmp .wend30
    jmp .endif34
.else33:
.endif34:
    mov rax, [rbp-48]
    push rax
    mov rcx, 8
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else35
    mov rax, [rbp-64]
    push rax
    mov rcx, 97
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else37
    mov rax, [rbp-64]
    push rax
    mov rcx, 122
    pop rax
    cmp rax, rcx
    setle al
    movzx rax, al
    test rax, rax
    jz .else39
    mov rax, [rbp-64]
    push rax
    mov rcx, 32
    pop rax
    sub rax, rcx
    mov [rbp-64], rax
    jmp .endif40
.else39:
.endif40:
    jmp .endif38
.else37:
.endif38:
    mov rax, [rbp-16]
    push rax
    mov rcx, [rbp-48]
    pop rax
    add rax, rcx
    push rax
    mov rcx, [rbp-64]
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-48]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-48], rax
    jmp .endif36
.else35:
.endif36:
    mov rax, [rbp-40]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-40], rax
    jmp .wst29
.wend30:
    mov rax, [rbp-56]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else41
    jmp .fn_end_26_app_hl_notepad_filename_to_83
    jmp .endif42
.else41:
.endif42:
    mov rax, 0
    mov [rbp-72], rax
.wst43:
    mov rax, [rbp-72]
    push rax
    mov rcx, 3
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend44
    mov rax, [rbp-40]
    movzx rax, byte [rax]
    mov [rbp-80], rax
    mov rax, [rbp-80]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else45
    jmp .fn_end_26_app_hl_notepad_filename_to_83
    jmp .endif46
.else45:
.endif46:
    mov rax, [rbp-80]
    push rax
    mov rcx, 97
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else47
    mov rax, [rbp-80]
    push rax
    mov rcx, 122
    pop rax
    cmp rax, rcx
    setle al
    movzx rax, al
    test rax, rax
    jz .else49
    mov rax, [rbp-80]
    push rax
    mov rcx, 32
    pop rax
    sub rax, rcx
    mov [rbp-80], rax
    jmp .endif50
.else49:
.endif50:
    jmp .endif48
.else47:
.endif48:
    mov rax, [rbp-16]
    push rax
    mov rcx, 8
    pop rax
    add rax, rcx
    push rax
    mov rcx, [rbp-72]
    pop rax
    add rax, rcx
    push rax
    mov rcx, [rbp-80]
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-72]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-72], rax
    mov rax, [rbp-40]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-40], rax
    jmp .wst43
.wend44:
.fn_end_26_app_hl_notepad_filename_to_83:
    FN_END app_hl_notepad_filename_to_83
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_format_bytes_size, 2, 0, FN_RET_SCALAR
FN_ARG 0, value, FN_KIND_SCALAR
FN_ARG 1, dst, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 112
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else51
    mov rax, [rbp-16]
    push rax
    mov rcx, 48
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    push rax
    mov rcx, 32
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 2
    pop rax
    add rax, rcx
    push rax
    mov rcx, 66
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 3
    pop rax
    add rax, rcx
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_50_app_hl_notepad_format_bytes_size
    jmp .endif52
.else51:
.endif52:
    mov rax, [rbp-8]
    push rax
    mov rcx, 4294967295
    pop rax
    and rax, rcx
    mov [rbp-32], rax
    mov rax, 0
    mov [rbp-40], rax
.wst53:
    mov rax, [rbp-32]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .wend54
    mov rax, [rbp-32]
    push rax
    mov rcx, 10
    pop rax
    cqo
    idiv rcx
    mov rax, rdx
    mov [rbp-48], rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 4
    pop rax
    add rax, rcx
    push rax
    mov rcx, [rbp-40]
    pop rax
    add rax, rcx
    push rax
    mov rax, 48
    push rax
    mov rcx, [rbp-48]
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 10
    pop rax
    cqo
    idiv rcx
    mov [rbp-32], rax
    mov rax, [rbp-40]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-40], rax
    jmp .wst53
.wend54:
    mov rax, 0
    mov [rbp-56], rax
.wst55:
    mov rax, [rbp-56]
    push rax
    mov rcx, [rbp-40]
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend56
    mov rax, [rbp-16]
    push rax
    mov rcx, [rbp-56]
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 4
    pop rax
    add rax, rcx
    push rax
    mov rcx, [rbp-40]
    pop rax
    add rax, rcx
    push rax
    mov rcx, 1
    pop rax
    sub rax, rcx
    push rax
    mov rcx, [rbp-56]
    pop rax
    sub rax, rcx
    movzx rax, byte [rax]
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-56]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-56], rax
    jmp .wst55
.wend56:
    mov rax, [rbp-16]
    push rax
    mov rcx, [rbp-40]
    pop rax
    add rax, rcx
    push rax
    mov rcx, 32
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-16]
    push rax
    mov rcx, [rbp-40]
    pop rax
    add rax, rcx
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    push rax
    mov rcx, 66
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-16]
    push rax
    mov rcx, [rbp-40]
    pop rax
    add rax, rcx
    push rax
    mov rcx, 2
    pop rax
    add rax, rcx
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
.fn_end_50_app_hl_notepad_format_bytes_size:
    FN_END app_hl_notepad_format_bytes_size
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_fs_is_dir, 1, 0, FN_RET_SCALAR
FN_ARG 0, entry, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    mov rcx, 11
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rcx, 16
    pop rax
    and rax, rcx
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else57
    mov rax, 1
    jmp .fn_end_56_app_hl_notepad_fs_is_dir
    jmp .endif58
.else57:
.endif58:
    mov rax, 0
    jmp .fn_end_56_app_hl_notepad_fs_is_dir
.fn_end_56_app_hl_notepad_fs_is_dir:
    FN_END app_hl_notepad_fs_is_dir
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_line_ptr, 1, 0, FN_RET_SCALAR
FN_ARG 0, row, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    mov [rbp-8], rdi
    push rbx
    push r12
    lea rax, [rel notepad_buf]
    push rax
    mov rax, [rbp-8]
    push rax
    mov rcx, 80
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    jmp .fn_end_58_app_hl_notepad_line_ptr
.fn_end_58_app_hl_notepad_line_ptr:
    FN_END app_hl_notepad_line_ptr
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_len_ptr, 1, 0, FN_RET_SCALAR
FN_ARG 0, row, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    mov [rbp-8], rdi
    push rbx
    push r12
    lea rax, [rel np_line_len]
    push rax
    mov rax, [rbp-8]
    push rax
    mov rcx, 4
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    jmp .fn_end_58_app_hl_notepad_len_ptr
.fn_end_58_app_hl_notepad_len_ptr:
    FN_END app_hl_notepad_len_ptr
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_clear_buffer, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    push rbx
    push r12
    mov rax, 0
    mov [rbp-16], rax
.wst59:
    mov rax, [rbp-16]
    push rax
    mov rax, 32
    push rax
    mov rcx, 80
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend60
    lea rax, [rel notepad_buf]
    push rax
    mov rcx, [rbp-16]
    pop rax
    add rax, rcx
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-16], rax
    jmp .wst59
.wend60:
    mov rax, 0
    mov [rbp-24], rax
.wst61:
    mov rax, [rbp-24]
    push rax
    mov rcx, 32
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend62
    lea rax, [rel np_line_len]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rcx, 4
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rcx, 0
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, [rbp-24]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-24], rax
    jmp .wst61
.wend62:
    lea rax, [rel np_cursor_row]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel np_cursor_col]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel np_num_lines]
    push rax
    mov rcx, 1
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel np_scroll_top]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], ecx
    xor rax, rax
.fn_end_58_app_hl_notepad_clear_buffer:
    FN_END app_hl_notepad_clear_buffer
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_ensure_visible, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    push rbx
    push r12
    lea rax, [rel np_cursor_row]
    movsxd rax, dword [rax]
    mov [rbp-16], rax
    lea rax, [rel np_scroll_top]
    movsxd rax, dword [rax]
    mov [rbp-24], rax
    mov rax, [rbp-16]
    push rax
    mov rcx, [rbp-24]
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else63
    lea rax, [rel np_scroll_top]
    push rax
    mov rcx, [rbp-16]
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .fn_end_62_app_hl_notepad_ensure_visible
    jmp .endif64
.else63:
.endif64:
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rcx, 15
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else65
    lea rax, [rel np_scroll_top]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 14
    pop rax
    sub rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif66
.else65:
.endif66:
.fn_end_62_app_hl_notepad_ensure_visible:
    FN_END app_hl_notepad_ensure_visible
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_insert_char, 1, 0, FN_RET_SCALAR
FN_ARG 0, ch, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 128
    mov [rbp-8], rdi
    push rbx
    push r12
    lea rax, [rel np_num_lines]
    movsxd rax, dword [rax]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else67
    lea rax, [rel np_num_lines]
    push rax
    mov rcx, 1
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif68
.else67:
.endif68:
    lea rax, [rel np_cursor_row]
    movsxd rax, dword [rax]
    mov [rbp-24], rax
    lea rax, [rel np_cursor_col]
    movsxd rax, dword [rax]
    mov [rbp-32], rax
    mov rax, [rbp-24]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else69
    jmp .fn_end_66_app_hl_notepad_insert_char
    jmp .endif70
.else69:
.endif70:
    mov rax, [rbp-24]
    push rax
    mov rcx, 32
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else71
    jmp .fn_end_66_app_hl_notepad_insert_char
    jmp .endif72
.else71:
.endif72:
    mov rax, [rbp-24]
    push rax
    lea rax, [rel np_num_lines]
    movsxd rax, dword [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else73
    jmp .fn_end_66_app_hl_notepad_insert_char
    jmp .endif74
.else73:
.endif74:
    mov rax, [rbp-32]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else75
    jmp .fn_end_66_app_hl_notepad_insert_char
    jmp .endif76
.else75:
.endif76:
    mov rax, [rbp-32]
    push rax
    mov rcx, 80
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else77
    jmp .fn_end_66_app_hl_notepad_insert_char
    jmp .endif78
.else77:
.endif78:
    mov rdi, [rbp-24]
    FN_CALL app_hl_notepad_len_ptr, 1
    mov [rbp-40], rax
    mov rax, [rbp-40]
    movsxd rax, dword [rax]
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else79
    jmp .fn_end_66_app_hl_notepad_insert_char
    jmp .endif80
.else79:
.endif80:
    mov rax, [rbp-48]
    push rax
    mov rcx, 80
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else81
    jmp .fn_end_66_app_hl_notepad_insert_char
    jmp .endif82
.else81:
.endif82:
    mov rax, [rbp-32]
    push rax
    mov rcx, [rbp-48]
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else83
    jmp .fn_end_66_app_hl_notepad_insert_char
    jmp .endif84
.else83:
.endif84:
    mov rax, [rbp-48]
    push rax
    mov rax, 80
    push rax
    mov rcx, 1
    pop rax
    sub rax, rcx
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else85
    jmp .fn_end_66_app_hl_notepad_insert_char
    jmp .endif86
.else85:
.endif86:
    mov rdi, [rbp-24]
    FN_CALL app_hl_notepad_line_ptr, 1
    mov [rbp-56], rax
    mov rax, [rbp-48]
    mov [rbp-64], rax
.wst87:
    mov rax, [rbp-64]
    push rax
    mov rcx, [rbp-32]
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .wend88
    mov rax, [rbp-56]
    push rax
    mov rcx, [rbp-64]
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-56]
    push rax
    mov rcx, [rbp-64]
    pop rax
    add rax, rcx
    push rax
    mov rcx, 1
    pop rax
    sub rax, rcx
    movzx rax, byte [rax]
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-64]
    push rax
    mov rcx, 1
    pop rax
    sub rax, rcx
    mov [rbp-64], rax
    jmp .wst87
.wend88:
    mov rax, [rbp-56]
    push rax
    mov rcx, [rbp-32]
    pop rax
    add rax, rcx
    push rax
    mov rcx, [rbp-8]
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, [rbp-56]
    push rax
    mov rcx, [rbp-48]
    pop rax
    add rax, rcx
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel np_cursor_col]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
.fn_end_66_app_hl_notepad_insert_char:
    FN_END app_hl_notepad_insert_char
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_do_backspace, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 208
    push rbx
    push r12
    lea rax, [rel np_cursor_col]
    movsxd rax, dword [rax]
    mov [rbp-16], rax
    lea rax, [rel np_cursor_row]
    movsxd rax, dword [rax]
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else89
    jmp .fn_end_88_app_hl_notepad_do_backspace
    jmp .endif90
.else89:
.endif90:
    mov rax, [rbp-24]
    push rax
    mov rcx, 32
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else91
    jmp .fn_end_88_app_hl_notepad_do_backspace
    jmp .endif92
.else91:
.endif92:
    mov rax, [rbp-24]
    push rax
    lea rax, [rel np_num_lines]
    movsxd rax, dword [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else93
    jmp .fn_end_88_app_hl_notepad_do_backspace
    jmp .endif94
.else93:
.endif94:
    mov rax, [rbp-16]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else95
    jmp .fn_end_88_app_hl_notepad_do_backspace
    jmp .endif96
.else95:
.endif96:
    mov rax, [rbp-16]
    push rax
    mov rcx, 80
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else97
    jmp .fn_end_88_app_hl_notepad_do_backspace
    jmp .endif98
.else97:
.endif98:
    mov rax, [rbp-16]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else99
    mov rdi, [rbp-24]
    FN_CALL app_hl_notepad_line_ptr, 1
    mov [rbp-32], rax
    mov rdi, [rbp-24]
    FN_CALL app_hl_notepad_len_ptr, 1
    mov [rbp-40], rax
    mov rax, [rbp-40]
    movsxd rax, dword [rax]
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else101
    jmp .fn_end_88_app_hl_notepad_do_backspace
    jmp .endif102
.else101:
.endif102:
    mov rax, [rbp-48]
    push rax
    mov rcx, 80
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else103
    jmp .fn_end_88_app_hl_notepad_do_backspace
    jmp .endif104
.else103:
.endif104:
    mov rax, [rbp-16]
    push rax
    mov rcx, [rbp-48]
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else105
    jmp .fn_end_88_app_hl_notepad_do_backspace
    jmp .endif106
.else105:
.endif106:
    mov rax, [rbp-16]
    mov [rbp-56], rax
.wst107:
    mov rax, [rbp-56]
    push rax
    mov rcx, [rbp-48]
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend108
    mov rax, [rbp-32]
    push rax
    mov rcx, [rbp-56]
    pop rax
    add rax, rcx
    push rax
    mov rcx, 1
    pop rax
    sub rax, rcx
    push rax
    mov rax, [rbp-32]
    push rax
    mov rcx, [rbp-56]
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-56]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-56], rax
    jmp .wst107
.wend108:
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
    push rax
    mov rcx, 1
    pop rax
    sub rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, [rbp-32]
    push rax
    mov rcx, [rbp-48]
    pop rax
    add rax, rcx
    push rax
    mov rcx, 1
    pop rax
    sub rax, rcx
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel np_cursor_col]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 1
    pop rax
    sub rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .fn_end_88_app_hl_notepad_do_backspace
    jmp .endif100
.else99:
.endif100:
    mov rax, [rbp-24]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else109
    jmp .fn_end_88_app_hl_notepad_do_backspace
    jmp .endif110
.else109:
.endif110:
    mov rax, [rbp-24]
    push rax
    mov rcx, 1
    pop rax
    sub rax, rcx
    mov [rbp-64], rax
    mov rdi, [rbp-64]
    FN_CALL app_hl_notepad_line_ptr, 1
    mov [rbp-72], rax
    mov rdi, [rbp-64]
    FN_CALL app_hl_notepad_len_ptr, 1
    movsxd rax, dword [rax]
    mov [rbp-80], rax
    mov rdi, [rbp-24]
    FN_CALL app_hl_notepad_line_ptr, 1
    mov [rbp-88], rax
    mov rdi, [rbp-24]
    FN_CALL app_hl_notepad_len_ptr, 1
    movsxd rax, dword [rax]
    mov [rbp-96], rax
    mov rax, [rbp-80]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else111
    jmp .fn_end_88_app_hl_notepad_do_backspace
    jmp .endif112
.else111:
.endif112:
    mov rax, [rbp-96]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else113
    jmp .fn_end_88_app_hl_notepad_do_backspace
    jmp .endif114
.else113:
.endif114:
    mov rax, [rbp-80]
    push rax
    mov rcx, 80
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else115
    jmp .fn_end_88_app_hl_notepad_do_backspace
    jmp .endif116
.else115:
.endif116:
    mov rax, [rbp-96]
    push rax
    mov rcx, 80
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else117
    jmp .fn_end_88_app_hl_notepad_do_backspace
    jmp .endif118
.else117:
.endif118:
    mov rax, [rbp-80]
    push rax
    mov rcx, [rbp-96]
    pop rax
    add rax, rcx
    push rax
    mov rax, 80
    push rax
    mov rcx, 1
    pop rax
    sub rax, rcx
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else119
    jmp .fn_end_88_app_hl_notepad_do_backspace
    jmp .endif120
.else119:
.endif120:
    mov rax, 0
    mov [rbp-104], rax
.wst121:
    mov rax, [rbp-104]
    push rax
    mov rcx, [rbp-96]
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend122
    mov rax, [rbp-72]
    push rax
    mov rcx, [rbp-80]
    pop rax
    add rax, rcx
    push rax
    mov rcx, [rbp-104]
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-88]
    push rax
    mov rcx, [rbp-104]
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-104]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-104], rax
    jmp .wst121
.wend122:
    mov rdi, [rbp-64]
    FN_CALL app_hl_notepad_len_ptr, 1
    push rax
    mov rax, [rbp-80]
    push rax
    mov rcx, [rbp-96]
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, [rbp-72]
    push rax
    mov rcx, [rbp-80]
    pop rax
    add rax, rcx
    push rax
    mov rcx, [rbp-96]
    pop rax
    add rax, rcx
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel np_num_lines]
    movsxd rax, dword [rax]
    mov [rbp-112], rax
    mov rax, [rbp-24]
    mov [rbp-120], rax
.wst123:
    mov rax, [rbp-120]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    push rax
    mov rcx, [rbp-112]
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend124
    mov rax, [rbp-120]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov rdi, rax
    FN_CALL app_hl_notepad_line_ptr, 1
    mov [rbp-128], rax
    mov rdi, [rbp-120]
    FN_CALL app_hl_notepad_line_ptr, 1
    mov [rbp-136], rax
    mov rax, 0
    mov [rbp-144], rax
.wst125:
    mov rax, [rbp-144]
    push rax
    mov rcx, 80
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend126
    mov rax, [rbp-136]
    push rax
    mov rcx, [rbp-144]
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-128]
    push rax
    mov rcx, [rbp-144]
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-144]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-144], rax
    jmp .wst125
.wend126:
    mov rdi, [rbp-120]
    FN_CALL app_hl_notepad_len_ptr, 1
    push rax
    mov rax, [rbp-120]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov rdi, rax
    FN_CALL app_hl_notepad_len_ptr, 1
    movsxd rax, dword [rax]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, [rbp-120]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-120], rax
    jmp .wst123
.wend124:
    lea rax, [rel np_num_lines]
    push rax
    mov rax, [rbp-112]
    push rax
    mov rcx, 1
    pop rax
    sub rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel np_cursor_row]
    push rax
    mov rcx, [rbp-64]
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel np_cursor_col]
    push rax
    mov rcx, [rbp-80]
    pop rax
    mov [rax], ecx
    xor rax, rax
    FN_CALL app_hl_notepad_ensure_visible, 0
.fn_end_88_app_hl_notepad_do_backspace:
    FN_END app_hl_notepad_do_backspace
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_do_enter, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 176
    push rbx
    push r12
    lea rax, [rel np_num_lines]
    movsxd rax, dword [rax]
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 32
    push rax
    mov rcx, 1
    pop rax
    sub rax, rcx
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else127
    jmp .fn_end_126_app_hl_notepad_do_enter
    jmp .endif128
.else127:
.endif128:
    lea rax, [rel np_cursor_row]
    movsxd rax, dword [rax]
    mov [rbp-24], rax
    lea rax, [rel np_cursor_col]
    movsxd rax, dword [rax]
    mov [rbp-32], rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 1
    pop rax
    sub rax, rcx
    mov [rbp-40], rax
.wst129:
    mov rax, [rbp-40]
    push rax
    mov rcx, [rbp-24]
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .wend130
    mov rdi, [rbp-40]
    FN_CALL app_hl_notepad_line_ptr, 1
    mov [rbp-48], rax
    mov rax, [rbp-40]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov rdi, rax
    FN_CALL app_hl_notepad_line_ptr, 1
    mov [rbp-56], rax
    mov rax, 0
    mov [rbp-64], rax
.wst131:
    mov rax, [rbp-64]
    push rax
    mov rcx, 80
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend132
    mov rax, [rbp-56]
    push rax
    mov rcx, [rbp-64]
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-48]
    push rax
    mov rcx, [rbp-64]
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-64]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-64], rax
    jmp .wst131
.wend132:
    mov rax, [rbp-40]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov rdi, rax
    FN_CALL app_hl_notepad_len_ptr, 1
    push rax
    mov rdi, [rbp-40]
    FN_CALL app_hl_notepad_len_ptr, 1
    movsxd rax, dword [rax]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, [rbp-40]
    push rax
    mov rcx, 1
    pop rax
    sub rax, rcx
    mov [rbp-40], rax
    jmp .wst129
.wend130:
    mov rdi, [rbp-24]
    FN_CALL app_hl_notepad_line_ptr, 1
    mov [rbp-72], rax
    mov rax, [rbp-24]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov rdi, rax
    FN_CALL app_hl_notepad_line_ptr, 1
    mov [rbp-80], rax
    mov rdi, [rbp-24]
    FN_CALL app_hl_notepad_len_ptr, 1
    mov [rbp-88], rax
    mov rax, [rbp-88]
    movsxd rax, dword [rax]
    mov [rbp-96], rax
    mov rax, [rbp-32]
    mov [rbp-104], rax
    mov rax, 0
    mov [rbp-112], rax
.wst133:
    mov rax, [rbp-104]
    push rax
    mov rcx, [rbp-96]
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend134
    mov rax, [rbp-80]
    push rax
    mov rcx, [rbp-112]
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-72]
    push rax
    mov rcx, [rbp-104]
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-104]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-104], rax
    mov rax, [rbp-112]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-112], rax
    jmp .wst133
.wend134:
    mov rax, [rbp-80]
    push rax
    mov rcx, [rbp-112]
    pop rax
    add rax, rcx
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-24]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov rdi, rax
    FN_CALL app_hl_notepad_len_ptr, 1
    push rax
    mov rax, [rbp-96]
    push rax
    mov rcx, [rbp-32]
    pop rax
    sub rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, [rbp-72]
    push rax
    mov rcx, [rbp-32]
    pop rax
    add rax, rcx
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-88]
    push rax
    mov rcx, [rbp-32]
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel np_num_lines]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel np_cursor_row]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel np_cursor_col]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], ecx
    xor rax, rax
    FN_CALL app_hl_notepad_ensure_visible, 0
.fn_end_126_app_hl_notepad_do_enter:
    FN_END app_hl_notepad_do_enter
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_do_tab, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    push rbx
    push r12
    mov rax, 0
    mov [rbp-16], rax
.wst135:
    mov rax, [rbp-16]
    push rax
    mov rcx, 4
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend136
    mov rdi, 32
    FN_CALL app_hl_notepad_insert_char, 1
    mov rax, [rbp-16]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-16], rax
    jmp .wst135
.wend136:
.fn_end_134_app_hl_notepad_do_tab:
    FN_END app_hl_notepad_do_tab
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_arrow_up, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    push rbx
    push r12
    lea rax, [rel np_cursor_row]
    movsxd rax, dword [rax]
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else137
    jmp .fn_end_136_app_hl_notepad_arrow_up
    jmp .endif138
.else137:
.endif138:
    mov rax, [rbp-16]
    push rax
    mov rcx, 1
    pop rax
    sub rax, rcx
    mov [rbp-16], rax
    lea rax, [rel np_cursor_row]
    push rax
    mov rcx, [rbp-16]
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rdi, [rbp-16]
    FN_CALL app_hl_notepad_len_ptr, 1
    movsxd rax, dword [rax]
    mov [rbp-24], rax
    lea rax, [rel np_cursor_col]
    movsxd rax, dword [rax]
    push rax
    mov rcx, [rbp-24]
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else139
    lea rax, [rel np_cursor_col]
    push rax
    mov rcx, [rbp-24]
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif140
.else139:
.endif140:
    FN_CALL app_hl_notepad_ensure_visible, 0
.fn_end_136_app_hl_notepad_arrow_up:
    FN_END app_hl_notepad_arrow_up
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_arrow_down, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    push rbx
    push r12
    lea rax, [rel np_cursor_row]
    movsxd rax, dword [rax]
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    lea rax, [rel np_num_lines]
    movsxd rax, dword [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else141
    jmp .fn_end_140_app_hl_notepad_arrow_down
    jmp .endif142
.else141:
.endif142:
    lea rax, [rel np_cursor_row]
    push rax
    mov rcx, [rbp-16]
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rdi, [rbp-16]
    FN_CALL app_hl_notepad_len_ptr, 1
    movsxd rax, dword [rax]
    mov [rbp-24], rax
    lea rax, [rel np_cursor_col]
    movsxd rax, dword [rax]
    push rax
    mov rcx, [rbp-24]
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else143
    lea rax, [rel np_cursor_col]
    push rax
    mov rcx, [rbp-24]
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif144
.else143:
.endif144:
    FN_CALL app_hl_notepad_ensure_visible, 0
.fn_end_140_app_hl_notepad_arrow_down:
    FN_END app_hl_notepad_arrow_down
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_arrow_left, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    push rbx
    push r12
    lea rax, [rel np_cursor_col]
    movsxd rax, dword [rax]
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else145
    lea rax, [rel np_cursor_col]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 1
    pop rax
    sub rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .fn_end_144_app_hl_notepad_arrow_left
    jmp .endif146
.else145:
.endif146:
    lea rax, [rel np_cursor_row]
    movsxd rax, dword [rax]
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else147
    jmp .fn_end_144_app_hl_notepad_arrow_left
    jmp .endif148
.else147:
.endif148:
    mov rax, [rbp-24]
    push rax
    mov rcx, 1
    pop rax
    sub rax, rcx
    mov [rbp-24], rax
    lea rax, [rel np_cursor_row]
    push rax
    mov rcx, [rbp-24]
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel np_cursor_col]
    push rax
    mov rdi, [rbp-24]
    FN_CALL app_hl_notepad_len_ptr, 1
    movsxd rax, dword [rax]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    FN_CALL app_hl_notepad_ensure_visible, 0
.fn_end_144_app_hl_notepad_arrow_left:
    FN_END app_hl_notepad_arrow_left
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_arrow_right, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 96
    push rbx
    push r12
    lea rax, [rel np_cursor_row]
    movsxd rax, dword [rax]
    mov [rbp-16], rax
    lea rax, [rel np_cursor_col]
    movsxd rax, dword [rax]
    mov [rbp-24], rax
    mov rdi, [rbp-16]
    FN_CALL app_hl_notepad_len_ptr, 1
    movsxd rax, dword [rax]
    mov [rbp-32], rax
    mov rax, [rbp-24]
    push rax
    mov rcx, [rbp-32]
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else149
    lea rax, [rel np_cursor_col]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .fn_end_148_app_hl_notepad_arrow_right
    jmp .endif150
.else149:
.endif150:
    mov rax, [rbp-16]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    lea rax, [rel np_num_lines]
    movsxd rax, dword [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else151
    jmp .fn_end_148_app_hl_notepad_arrow_right
    jmp .endif152
.else151:
.endif152:
    lea rax, [rel np_cursor_row]
    push rax
    mov rcx, [rbp-16]
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel np_cursor_col]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], ecx
    xor rax, rax
    FN_CALL app_hl_notepad_ensure_visible, 0
.fn_end_148_app_hl_notepad_arrow_right:
    FN_END app_hl_notepad_arrow_right
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_build_save_content, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 112
    push rbx
    push r12
    lea rax, [rel np_num_lines]
    movsxd rax, dword [rax]
    mov [rbp-16], rax
    mov rax, 0
    mov [rbp-24], rax
    mov rax, 0
    mov [rbp-32], rax
.wst153:
    mov rax, [rbp-24]
    push rax
    mov rcx, [rbp-16]
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend154
    mov rdi, [rbp-24]
    FN_CALL app_hl_notepad_line_ptr, 1
    mov [rbp-40], rax
    mov rdi, [rbp-24]
    FN_CALL app_hl_notepad_len_ptr, 1
    movsxd rax, dword [rax]
    mov [rbp-48], rax
    mov rax, 0
    mov [rbp-56], rax
.wst155:
    mov rax, [rbp-56]
    push rax
    mov rcx, [rbp-48]
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend156
    lea rax, [rel np_saved_content]
    push rax
    mov rcx, [rbp-32]
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-40]
    push rax
    mov rcx, [rbp-56]
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-32], rax
    mov rax, [rbp-56]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-56], rax
    jmp .wst155
.wend156:
    mov rax, [rbp-24]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    push rax
    mov rcx, [rbp-16]
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else157
    lea rax, [rel np_saved_content]
    push rax
    mov rcx, [rbp-32]
    pop rax
    add rax, rcx
    push rax
    mov rcx, 13
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-32], rax
    lea rax, [rel np_saved_content]
    push rax
    mov rcx, [rbp-32]
    pop rax
    add rax, rcx
    push rax
    mov rcx, 10
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-32], rax
    jmp .endif158
.else157:
.endif158:
    mov rax, [rbp-24]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-24], rax
    jmp .wst153
.wend154:
    lea rax, [rel np_save_total_bytes]
    push rax
    mov rcx, [rbp-32]
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, [rbp-32]
    jmp .fn_end_152_app_hl_notepad_build_save_content
.fn_end_152_app_hl_notepad_build_save_content:
    FN_END app_hl_notepad_build_save_content
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_do_save_to, 1, 0, FN_RET_SCALAR
FN_ARG 0, name83, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 96
    mov [rbp-8], rdi
    push rbx
    push r12
    FN_CALL app_hl_notepad_build_save_content, 0
    mov [rbp-24], rax
    mov rax, [rbp-8]
    push rax
    lea rax, [rel np_saved_content]
    push rax
    mov rax, [rbp-24]
    mov rdx, rax
    pop rsi
    pop rdi
    mov rax, 13
    syscall
    mov [rbp-32], rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else159
    lea rax, [rel np_save_done_msg]
    push rax
    mov rcx, 2
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_158_app_hl_notepad_do_save_to
    jmp .endif160
.else159:
.endif160:
    mov rax, 14
    syscall
    lea rax, [rel np_has_saved]
    push rax
    mov rcx, 1
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel np_save_done_msg]
    push rax
    mov rcx, 1
    pop rax
    mov [rax], cl
    xor rax, rax
.fn_end_158_app_hl_notepad_do_save_to:
    FN_END app_hl_notepad_do_save_to
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_str_is_root_or_empty, 1, 0, FN_RET_SCALAR
FN_ARG 0, s, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    movzx rax, byte [rax]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else161
    mov rax, 1
    jmp .fn_end_160_app_hl_notepad_str_is_root_or_empty
    jmp .endif162
.else161:
.endif162:
    mov rax, [rbp-8]
    movzx rax, byte [rax]
    push rax
    mov rcx, 47
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else163
    mov rax, [rbp-8]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else165
    mov rax, 1
    jmp .fn_end_160_app_hl_notepad_str_is_root_or_empty
    jmp .endif166
.else165:
.endif166:
    jmp .endif164
.else163:
.endif164:
    mov rax, 0
    jmp .fn_end_160_app_hl_notepad_str_is_root_or_empty
.fn_end_160_app_hl_notepad_str_is_root_or_empty:
    FN_END app_hl_notepad_str_is_root_or_empty
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_entry_name_eq, 2, 0, FN_RET_SCALAR
FN_ARG 0, ent, FN_KIND_SCALAR
FN_ARG 1, name83, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 96
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
    mov rax, 0
    mov [rbp-32], rax
.wst167:
    mov rax, [rbp-32]
    push rax
    mov rcx, 11
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend168
    mov rax, [rbp-8]
    push rax
    mov rcx, [rbp-32]
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rcx, [rbp-32]
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else169
    mov rax, 0
    jmp .fn_end_166_app_hl_notepad_entry_name_eq
    jmp .endif170
.else169:
.endif170:
    mov rax, [rbp-32]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-32], rax
    jmp .wst167
.wend168:
    mov rax, 1
    jmp .fn_end_166_app_hl_notepad_entry_name_eq
.fn_end_166_app_hl_notepad_entry_name_eq:
    FN_END app_hl_notepad_entry_name_eq
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_find_root_dir_cluster, 1, 0, FN_RET_SCALAR
FN_ARG 0, name83, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 96
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rdi, 0
    mov rax, 6
    syscall
    mov rax, 4
    syscall
    mov [rbp-24], rax
    mov rax, 0
    mov [rbp-32], rax
.wst171:
    mov rax, [rbp-32]
    push rax
    mov rcx, [rbp-24]
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend172
    mov rdi, [rbp-32]
    mov rax, 5
    syscall
    mov [rbp-40], rax
    mov rax, [rbp-40]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else173
    mov rsi, [rbp-8]
    mov rdi, [rbp-40]
    FN_CALL app_hl_notepad_entry_name_eq, 2
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else175
    mov rax, [rbp-40]
    push rax
    mov rcx, 11
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rcx, 16
    pop rax
    and rax, rcx
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else177
    mov rax, [rbp-40]
    push rax
    mov rcx, 26
    pop rax
    add rax, rcx
    movsxd rax, dword [rax]
    jmp .fn_end_170_app_hl_notepad_find_root_dir_cluster
    jmp .endif178
.else177:
.endif178:
    jmp .endif176
.else175:
.endif176:
    jmp .endif174
.else173:
.endif174:
    mov rax, [rbp-32]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-32], rax
    jmp .wst171
.wend172:
    mov rax, 0
    jmp .fn_end_170_app_hl_notepad_find_root_dir_cluster
.fn_end_170_app_hl_notepad_find_root_dir_cluster:
    FN_END app_hl_notepad_find_root_dir_cluster
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_save_dialog_reset, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 64
    push rbx
    push r12
    lea rax, [rel np_save_dialog]
    push rax
    mov rcx, 1
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel np_save_field]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel np_saveas_cursor]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel np_saveloc_cursor]
    push rax
    mov rcx, 1
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel np_saveas_buf]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel np_saveloc_buf]
    push rax
    mov rcx, 47
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel np_saveloc_buf]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
.fn_end_178_app_hl_notepad_save_dialog_reset:
    FN_END app_hl_notepad_save_dialog_reset
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_save_dialog_commit, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    push rbx
    push r12
    lea rax, [rel np_save_dialog]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel np_saveas_buf]
    movzx rax, byte [rax]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else179
    jmp .fn_end_178_app_hl_notepad_save_dialog_commit
    jmp .endif180
.else179:
.endif180:
    mov rax, 0
    mov [rbp-16], rax
    lea rax, [rel np_saveloc_buf]
    mov rdi, rax
    FN_CALL app_hl_notepad_str_is_root_or_empty, 1
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else181
    lea rax, [rel np_saveloc_buf]
    mov [rbp-24], rax
    mov rax, [rbp-24]
    movzx rax, byte [rax]
    push rax
    mov rcx, 47
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else183
    mov rax, [rbp-24]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-24], rax
    jmp .endif184
.else183:
.endif184:
    mov rax, [rbp-24]
    push rax
    lea rax, [rel np_saveloc_83]
    mov rsi, rax
    pop rdi
    FN_CALL app_hl_notepad_filename_to_83, 2
    lea rax, [rel np_saveloc_83]
    mov rdi, rax
    FN_CALL app_hl_notepad_find_root_dir_cluster, 1
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else185
    lea rax, [rel np_save_done_msg]
    push rax
    mov rcx, 2
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rdi, 0
    mov rax, 6
    syscall
    jmp .fn_end_178_app_hl_notepad_save_dialog_commit
    jmp .endif186
.else185:
.endif186:
    jmp .endif182
.else181:
.endif182:
    mov rdi, [rbp-16]
    mov rax, 6
    syscall
    lea rax, [rel np_saveas_buf]
    push rax
    lea rax, [rel np_saveas_83]
    mov rsi, rax
    pop rdi
    FN_CALL app_hl_notepad_filename_to_83, 2
    lea rax, [rel np_saveas_83]
    mov rdi, rax
    FN_CALL app_hl_notepad_do_save_to, 1
    mov rdi, 0
    mov rax, 6
    syscall
.fn_end_178_app_hl_notepad_save_dialog_commit:
    FN_END app_hl_notepad_save_dialog_commit
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_draw, 1, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 240
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    mov rcx, 8
    pop rax
    add rax, rcx
    mov rax, [rax]
    mov [rbp-24], rax
    mov rax, [rbp-8]
    push rax
    mov rcx, 16
    pop rax
    add rax, rcx
    mov rax, [rax]
    mov [rbp-32], rax
    mov rax, [rbp-8]
    push rax
    mov rcx, 24
    pop rax
    add rax, rcx
    mov rax, [rax]
    mov [rbp-40], rax
    mov rax, [rbp-8]
    push rax
    mov rcx, 32
    pop rax
    add rax, rcx
    mov rax, [rax]
    mov [rbp-48], rax
    mov rdi, [rbp-8]
    FN_CALL app_hl_notepad_ui_menu_bar, 1
    mov rax, [rbp-8]
    push rax
    mov rax, 6
    push rax
    lea rax, [rel app_hl_notepad_str0]
    mov rdx, rax
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_menu_label, 3
    mov rax, [rbp-8]
    push rax
    mov rax, 54
    push rax
    lea rax, [rel app_hl_notepad_str1]
    mov rdx, rax
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_menu_label, 3
    mov rax, [rbp-48]
    push rax
    mov rcx, 24
    pop rax
    sub rax, rcx
    push rax
    mov rcx, 24
    pop rax
    sub rax, rcx
    push rax
    mov rcx, 2
    pop rax
    sub rax, rcx
    mov [rbp-56], rax
    mov rax, [rbp-56]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setle al
    movzx rax, al
    test rax, rax
    jz .else187
    jmp .fn_end_186_app_hl_notepad_draw
    jmp .endif188
.else187:
.endif188:
    mov rax, [rbp-24]
    push rax
    mov rcx, 2
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 24
    pop rax
    add rax, rcx
    push rax
    mov rcx, 24
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, 2
    push rax
    mov rcx, 2
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, 16777215
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL render_rect, 5
    mov rax, [rbp-56]
    push rax
    mov rcx, 14
    pop rax
    cqo
    idiv rcx
    mov [rbp-64], rax
    mov rax, [rbp-64]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else189
    jmp .fn_end_186_app_hl_notepad_draw
    jmp .endif190
.else189:
.endif190:
    lea rax, [rel np_scroll_top]
    movsxd rax, dword [rax]
    mov [rbp-72], rax
    lea rax, [rel np_num_lines]
    movsxd rax, dword [rax]
    mov [rbp-80], rax
    mov rax, 0
    mov [rbp-88], rax
    mov rax, [rbp-72]
    mov [rbp-96], rax
.wst191:
    mov rax, [rbp-88]
    push rax
    mov rcx, [rbp-64]
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend192
    mov rax, [rbp-96]
    push rax
    mov rcx, [rbp-80]
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else193
    mov rax, [rbp-64]
    mov [rbp-88], rax
    jmp .endif194
.else193:
.endif194:
    mov rax, [rbp-88]
    push rax
    mov rcx, [rbp-64]
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else195
    mov rdi, [rbp-96]
    FN_CALL app_hl_notepad_line_ptr, 1
    mov [rbp-104], rax
    mov rax, [rbp-104]
    movzx rax, byte [rax]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else197
    mov rax, [rbp-24]
    push rax
    mov rcx, 2
    pop rax
    add rax, rcx
    push rax
    mov rcx, 4
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 24
    pop rax
    add rax, rcx
    push rax
    mov rcx, 24
    pop rax
    add rax, rcx
    push rax
    mov rcx, 2
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-88]
    push rax
    mov rcx, 14
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-104]
    push rax
    mov rax, 0
    push rax
    mov rax, 16777215
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL render_text, 5
    jmp .endif198
.else197:
.endif198:
    mov rax, [rbp-96]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-96], rax
    mov rax, [rbp-88]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-88], rax
    jmp .endif196
.else195:
.endif196:
    jmp .wst191
.wend192:
    lea rax, [rel np_cursor_row]
    movsxd rax, dword [rax]
    mov [rbp-112], rax
    lea rax, [rel np_cursor_col]
    movsxd rax, dword [rax]
    mov [rbp-120], rax
    mov rax, [rbp-112]
    push rax
    mov rcx, [rbp-72]
    pop rax
    sub rax, rcx
    mov [rbp-128], rax
    mov rax, [rbp-128]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else199
    mov rax, [rbp-128]
    push rax
    mov rcx, [rbp-64]
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else201
    mov rax, [rbp-8]
    push rax
    mov rax, 4
    push rax
    mov rax, [rbp-120]
    push rax
    mov rcx, 8
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 24
    push rax
    mov rcx, 2
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-128]
    push rax
    mov rcx, 14
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    mov rdx, rax
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_caret_blink, 3
    jmp .endif202
.else201:
.endif202:
    jmp .endif200
.else199:
.endif200:
    lea rax, [rel np_menu_open]
    movzx rax, byte [rax]
    mov [rbp-136], rax
    mov rax, [rbp-136]
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else203
    mov r8, 3
    mov rcx, 100
    mov rdx, 22
    mov rsi, 0
    mov rdi, [rbp-8]
    FN_CALL app_hl_notepad_ui_dropdown, 5
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    push rax
    mov rax, 22
    push rax
    mov rax, 0
    push rax
    lea rax, [rel app_hl_notepad_str2]
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_dropdown_item, 5
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    push rax
    mov rax, 22
    push rax
    mov rax, 1
    push rax
    lea rax, [rel app_hl_notepad_str3]
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_dropdown_item, 5
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    push rax
    mov rax, 22
    push rax
    mov rax, 2
    push rax
    lea rax, [rel app_hl_notepad_str4]
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_dropdown_item, 5
    jmp .endif204
.else203:
.endif204:
    mov rax, [rbp-136]
    push rax
    mov rcx, 2
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else205
    mov r8, 2
    mov rcx, 110
    mov rdx, 22
    mov rsi, 48
    mov rdi, [rbp-8]
    FN_CALL app_hl_notepad_ui_dropdown, 5
    mov rax, [rbp-8]
    push rax
    mov rax, 48
    push rax
    mov rax, 22
    push rax
    mov rax, 0
    push rax
    lea rax, [rel app_hl_notepad_str5]
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_dropdown_item, 5
    mov rax, [rbp-8]
    push rax
    mov rax, 48
    push rax
    mov rax, 22
    push rax
    mov rax, 1
    push rax
    lea rax, [rel app_hl_notepad_str6]
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_dropdown_item, 5
    jmp .endif206
.else205:
.endif206:
    lea rax, [rel np_save_dialog]
    movzx rax, byte [rax]
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else207
    mov rax, [rbp-40]
    push rax
    mov rax, 2
    push rax
    mov rcx, 2
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rcx, 40
    pop rax
    sub rax, rcx
    mov [rbp-144], rax
    mov rax, [rbp-24]
    push rax
    mov rcx, 2
    pop rax
    add rax, rcx
    push rax
    mov rcx, 20
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 24
    pop rax
    add rax, rcx
    push rax
    mov rcx, 40
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-144]
    push rax
    mov rax, 112
    push rax
    mov rax, 2241348
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL render_rect, 5
    mov rax, [rbp-24]
    push rax
    mov rcx, 2
    pop rax
    add rax, rcx
    push rax
    mov rcx, 20
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 24
    pop rax
    add rax, rcx
    push rax
    mov rcx, 40
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-144]
    push rax
    mov rax, 1
    push rax
    mov rax, 4491434
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL render_rect, 5
    mov rax, [rbp-24]
    push rax
    mov rcx, 2
    pop rax
    add rax, rcx
    push rax
    mov rcx, 30
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 24
    pop rax
    add rax, rcx
    push rax
    mov rcx, 46
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel app_hl_notepad_str7]
    push rax
    mov rax, 11197951
    push rax
    mov rax, 2241348
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL render_text, 5
    mov rax, [rbp-24]
    push rax
    mov rcx, 2
    pop rax
    add rax, rcx
    push rax
    mov rcx, 30
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 24
    pop rax
    add rax, rcx
    push rax
    mov rcx, 66
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel app_hl_notepad_str8]
    push rax
    mov rax, 13421772
    push rax
    mov rax, 2241348
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL render_text, 5
    mov rax, [rbp-40]
    push rax
    mov rax, 2
    push rax
    mov rcx, 2
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rcx, 140
    pop rax
    sub rax, rcx
    mov [rbp-152], rax
    mov rax, [rbp-24]
    push rax
    mov rcx, 2
    pop rax
    add rax, rcx
    push rax
    mov rcx, 104
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 24
    pop rax
    add rax, rcx
    push rax
    mov rcx, 62
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-152]
    push rax
    mov rax, 18
    push rax
    mov rax, 16777215
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL render_rect, 5
    mov rax, [rbp-24]
    push rax
    mov rcx, 2
    pop rax
    add rax, rcx
    push rax
    mov rcx, 108
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 24
    pop rax
    add rax, rcx
    push rax
    mov rcx, 65
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel np_saveas_buf]
    push rax
    mov rax, 0
    push rax
    mov rax, 16777215
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL render_text, 5
    mov rax, [rbp-24]
    push rax
    mov rcx, 2
    pop rax
    add rax, rcx
    push rax
    mov rcx, 30
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 24
    pop rax
    add rax, rcx
    push rax
    mov rcx, 88
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel app_hl_notepad_str9]
    push rax
    mov rax, 13421772
    push rax
    mov rax, 2241348
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL render_text, 5
    mov rax, [rbp-24]
    push rax
    mov rcx, 2
    pop rax
    add rax, rcx
    push rax
    mov rcx, 104
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 24
    pop rax
    add rax, rcx
    push rax
    mov rcx, 84
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-152]
    push rax
    mov rax, 18
    push rax
    mov rax, 16777215
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL render_rect, 5
    mov rax, [rbp-24]
    push rax
    mov rcx, 2
    pop rax
    add rax, rcx
    push rax
    mov rcx, 108
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 24
    pop rax
    add rax, rcx
    push rax
    mov rcx, 87
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel np_saveloc_buf]
    push rax
    mov rax, 0
    push rax
    mov rax, 16777215
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL render_text, 5
    lea rax, [rel np_save_field]
    movzx rax, byte [rax]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else209
    lea rax, [rel np_saveas_cursor]
    movsxd rax, dword [rax]
    mov [rbp-160], rax
    mov rax, [rbp-8]
    push rax
    mov rax, 108
    push rax
    mov rax, [rbp-160]
    push rax
    mov rcx, 8
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 64
    mov rdx, rax
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_caret_blink, 3
    jmp .endif210
.else209:
.endif210:
    lea rax, [rel np_save_field]
    movzx rax, byte [rax]
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else211
    lea rax, [rel np_saveloc_cursor]
    movsxd rax, dword [rax]
    mov [rbp-168], rax
    mov rax, [rbp-8]
    push rax
    mov rax, 108
    push rax
    mov rax, [rbp-168]
    push rax
    mov rcx, 8
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 86
    mov rdx, rax
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_caret_blink, 3
    jmp .endif212
.else211:
.endif212:
    mov rax, [rbp-24]
    push rax
    mov rcx, 2
    pop rax
    add rax, rcx
    push rax
    mov rcx, 30
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 24
    pop rax
    add rax, rcx
    push rax
    mov rcx, 112
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel app_hl_notepad_str10]
    push rax
    mov rax, 8947848
    push rax
    mov rax, 2241348
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL render_text, 5
    jmp .endif208
.else207:
.endif208:
    lea rax, [rel np_save_done_msg]
    movzx rax, byte [rax]
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else213
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-40]
    push rax
    mov rcx, 120
    pop rax
    sub rax, rcx
    mov rcx, rax
    sar rcx, 63
    shr rcx, 63
    add rax, rcx
    sar rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-176], rax
    mov rax, [rbp-176]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 24
    pop rax
    add rax, rcx
    push rax
    mov rcx, 60
    pop rax
    add rax, rcx
    push rax
    mov rax, 120
    push rax
    mov rax, 30
    push rax
    mov rax, 2263842
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL render_rect, 5
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-40]
    push rax
    mov rcx, 48
    pop rax
    sub rax, rcx
    mov rcx, rax
    sar rcx, 63
    shr rcx, 63
    add rax, rcx
    sar rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 24
    pop rax
    add rax, rcx
    push rax
    mov rcx, 68
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel app_hl_notepad_str11]
    push rax
    mov rax, 16777215
    push rax
    mov rax, 2263842
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL render_text, 5
    jmp .endif214
.else213:
.endif214:
    lea rax, [rel np_save_done_msg]
    movzx rax, byte [rax]
    push rax
    mov rcx, 2
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else215
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-40]
    push rax
    mov rcx, 176
    pop rax
    sub rax, rcx
    mov rcx, rax
    sar rcx, 63
    shr rcx, 63
    add rax, rcx
    sar rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-184], rax
    mov rax, [rbp-184]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 24
    pop rax
    add rax, rcx
    push rax
    mov rcx, 60
    pop rax
    add rax, rcx
    push rax
    mov rax, 176
    push rax
    mov rax, 30
    push rax
    mov rax, 9445408
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL render_rect, 5
    mov rax, [rbp-184]
    push rax
    mov rcx, 8
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 24
    pop rax
    add rax, rcx
    push rax
    mov rcx, 68
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel app_hl_notepad_str12]
    push rax
    mov rax, 16777215
    push rax
    mov rax, 9445408
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL render_text, 5
    jmp .endif216
.else215:
.endif216:
.fn_end_186_app_hl_notepad_draw:
    FN_END app_hl_notepad_draw
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_click, 3, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
FN_ARG 1, cx, FN_KIND_SCALAR
FN_ARG 2, cy, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 208
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    push rbx
    push r12
    mov rax, 24
    mov [rbp-40], rax
    lea rax, [rel np_save_done_msg]
    movzx rax, byte [rax]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else217
    lea rax, [rel np_save_done_msg]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_216_app_hl_notepad_click
    jmp .endif218
.else217:
.endif218:
    lea rax, [rel np_save_dialog]
    movzx rax, byte [rax]
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else219
    mov rax, [rbp-24]
    push rax
    mov rcx, 62
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else221
    mov rax, [rbp-24]
    push rax
    mov rcx, 82
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else223
    lea rax, [rel np_save_field]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_216_app_hl_notepad_click
    jmp .endif224
.else223:
.endif224:
    jmp .endif222
.else221:
.endif222:
    mov rax, [rbp-24]
    push rax
    mov rcx, 84
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else225
    mov rax, [rbp-24]
    push rax
    mov rcx, 104
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else227
    lea rax, [rel np_save_field]
    push rax
    mov rcx, 1
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_216_app_hl_notepad_click
    jmp .endif228
.else227:
.endif228:
    jmp .endif226
.else225:
.endif226:
    jmp .fn_end_216_app_hl_notepad_click
    jmp .endif220
.else219:
.endif220:
    lea rax, [rel np_menu_open]
    movzx rax, byte [rax]
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else229
    mov rax, [rbp-48]
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else231
    mov rax, [rbp-24]
    push rax
    mov rcx, 22
    pop rax
    sub rax, rcx
    mov [rbp-56], rax
    mov rax, [rbp-56]
    push rax
    mov rcx, 4
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else233
    lea rax, [rel np_menu_open]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_216_app_hl_notepad_click
    jmp .endif234
.else233:
.endif234:
    mov rax, [rbp-56]
    push rax
    mov rcx, 4
    pop rax
    sub rax, rcx
    push rax
    mov rcx, 20
    pop rax
    cqo
    idiv rcx
    mov [rbp-64], rax
    lea rax, [rel np_menu_open]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-64]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else235
    FN_CALL app_hl_notepad_clear_buffer, 0
    jmp .fn_end_216_app_hl_notepad_click
    jmp .endif236
.else235:
.endif236:
    mov rax, [rbp-64]
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else237
    FN_CALL app_hl_notepad_save_dialog_reset, 0
    jmp .fn_end_216_app_hl_notepad_click
    jmp .endif238
.else237:
.endif238:
    mov rax, [rbp-64]
    push rax
    mov rcx, 2
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else239
    jmp .fn_end_216_app_hl_notepad_click
    jmp .endif240
.else239:
.endif240:
    jmp .fn_end_216_app_hl_notepad_click
    jmp .endif232
.else231:
.endif232:
    mov rax, [rbp-48]
    push rax
    mov rcx, 2
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else241
    mov rax, [rbp-24]
    push rax
    mov rcx, 22
    pop rax
    sub rax, rcx
    mov [rbp-72], rax
    mov rax, [rbp-72]
    push rax
    mov rcx, 4
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else243
    lea rax, [rel np_menu_open]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_216_app_hl_notepad_click
    jmp .endif244
.else243:
.endif244:
    mov rax, [rbp-72]
    push rax
    mov rcx, 4
    pop rax
    sub rax, rcx
    push rax
    mov rcx, 20
    pop rax
    cqo
    idiv rcx
    mov [rbp-80], rax
    lea rax, [rel np_menu_open]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-80]
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else245
    FN_CALL app_hl_notepad_clear_buffer, 0
    jmp .endif246
.else245:
.endif246:
    jmp .fn_end_216_app_hl_notepad_click
    jmp .endif242
.else241:
.endif242:
    lea rax, [rel np_menu_open]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_216_app_hl_notepad_click
    jmp .endif230
.else229:
.endif230:
    mov rax, [rbp-24]
    push rax
    mov rcx, [rbp-40]
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else247
    mov rax, [rbp-16]
    push rax
    mov rcx, 2
    pop rax
    sub rax, rcx
    mov [rbp-88], rax
    mov rax, [rbp-88]
    push rax
    mov rcx, 48
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else249
    lea rax, [rel np_menu_open]
    push rax
    mov rcx, 1
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_216_app_hl_notepad_click
    jmp .endif250
.else249:
.endif250:
    mov rax, [rbp-88]
    push rax
    mov rcx, 96
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else251
    lea rax, [rel np_menu_open]
    push rax
    mov rcx, 2
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_216_app_hl_notepad_click
    jmp .endif252
.else251:
.endif252:
    jmp .fn_end_216_app_hl_notepad_click
    jmp .endif248
.else247:
.endif248:
    lea rax, [rel np_menu_open]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-24]
    push rax
    mov rcx, [rbp-40]
    pop rax
    sub rax, rcx
    push rax
    mov rcx, 2
    pop rax
    sub rax, rcx
    mov [rbp-96], rax
    mov rax, [rbp-96]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else253
    jmp .fn_end_216_app_hl_notepad_click
    jmp .endif254
.else253:
.endif254:
    mov rax, [rbp-96]
    push rax
    mov rcx, 14
    pop rax
    cqo
    idiv rcx
    mov [rbp-104], rax
    mov rax, [rbp-104]
    push rax
    lea rax, [rel np_scroll_top]
    movsxd rax, dword [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-112], rax
    lea rax, [rel np_num_lines]
    movsxd rax, dword [rax]
    mov [rbp-120], rax
    mov rax, [rbp-112]
    push rax
    mov rcx, [rbp-120]
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else255
    mov rax, [rbp-120]
    push rax
    mov rcx, 1
    pop rax
    sub rax, rcx
    mov [rbp-112], rax
    jmp .endif256
.else255:
.endif256:
    lea rax, [rel np_cursor_row]
    push rax
    mov rcx, [rbp-112]
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 4
    pop rax
    sub rax, rcx
    mov [rbp-128], rax
    mov rax, [rbp-128]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else257
    mov rax, 0
    mov [rbp-128], rax
    jmp .endif258
.else257:
.endif258:
    mov rax, [rbp-128]
    mov rcx, rax
    sar rcx, 63
    shr rcx, 61
    add rax, rcx
    sar rax, 3
    mov [rbp-136], rax
    mov rdi, [rbp-112]
    FN_CALL app_hl_notepad_len_ptr, 1
    movsxd rax, dword [rax]
    mov [rbp-144], rax
    mov rax, [rbp-136]
    push rax
    mov rcx, [rbp-144]
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else259
    mov rax, [rbp-144]
    mov [rbp-136], rax
    jmp .endif260
.else259:
.endif260:
    lea rax, [rel np_cursor_col]
    push rax
    mov rcx, [rbp-136]
    pop rax
    mov [rax], ecx
    xor rax, rax
.fn_end_216_app_hl_notepad_click:
    FN_END app_hl_notepad_click
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_saveas_key, 1, 0, FN_RET_SCALAR
FN_ARG 0, k, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 128
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    mov rcx, 255
    pop rax
    and rax, rcx
    mov [rbp-24], rax
    mov rax, [rbp-8]
    push rax
    mov rcx, 8
    pop rax
    shr rax, cl
    push rax
    mov rcx, 255
    pop rax
    and rax, rcx
    mov [rbp-32], rax
    mov rax, [rbp-24]
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else261
    lea rax, [rel np_save_dialog]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_260_app_hl_notepad_saveas_key
    jmp .endif262
.else261:
.endif262:
    mov rax, [rbp-32]
    push rax
    mov rcx, 13
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else263
    FN_CALL app_hl_notepad_save_dialog_commit, 0
    jmp .fn_end_260_app_hl_notepad_saveas_key
    jmp .endif264
.else263:
.endif264:
    mov rax, [rbp-32]
    push rax
    mov rcx, 9
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else265
    lea rax, [rel np_save_field]
    movzx rax, byte [rax]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else267
    lea rax, [rel np_save_field]
    push rax
    mov rcx, 1
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_260_app_hl_notepad_saveas_key
    jmp .endif268
.else267:
.endif268:
    lea rax, [rel np_save_field]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_260_app_hl_notepad_saveas_key
    jmp .endif266
.else265:
.endif266:
    mov rax, [rbp-32]
    push rax
    mov rcx, 8
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else269
    lea rax, [rel np_save_field]
    movzx rax, byte [rax]
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else271
    lea rax, [rel np_saveloc_cursor]
    movsxd rax, dword [rax]
    mov [rbp-40], rax
    mov rax, [rbp-40]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else273
    jmp .fn_end_260_app_hl_notepad_saveas_key
    jmp .endif274
.else273:
.endif274:
    mov rax, [rbp-40]
    push rax
    mov rcx, 1
    pop rax
    sub rax, rcx
    mov [rbp-40], rax
    lea rax, [rel np_saveloc_buf]
    push rax
    mov rcx, [rbp-40]
    pop rax
    add rax, rcx
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel np_saveloc_cursor]
    push rax
    mov rcx, [rbp-40]
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .fn_end_260_app_hl_notepad_saveas_key
    jmp .endif272
.else271:
.endif272:
    lea rax, [rel np_saveas_cursor]
    movsxd rax, dword [rax]
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else275
    jmp .fn_end_260_app_hl_notepad_saveas_key
    jmp .endif276
.else275:
.endif276:
    mov rax, [rbp-48]
    push rax
    mov rcx, 1
    pop rax
    sub rax, rcx
    mov [rbp-48], rax
    lea rax, [rel np_saveas_buf]
    push rax
    mov rcx, [rbp-48]
    pop rax
    add rax, rcx
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel np_saveas_cursor]
    push rax
    mov rcx, [rbp-48]
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .fn_end_260_app_hl_notepad_saveas_key
    jmp .endif270
.else269:
.endif270:
    mov rax, [rbp-32]
    push rax
    mov rcx, 32
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else277
    jmp .fn_end_260_app_hl_notepad_saveas_key
    jmp .endif278
.else277:
.endif278:
    mov rax, [rbp-32]
    push rax
    mov rcx, 126
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else279
    jmp .fn_end_260_app_hl_notepad_saveas_key
    jmp .endif280
.else279:
.endif280:
    lea rax, [rel np_save_field]
    movzx rax, byte [rax]
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else281
    lea rax, [rel np_saveloc_cursor]
    movsxd rax, dword [rax]
    mov [rbp-56], rax
    mov rax, [rbp-56]
    push rax
    mov rcx, 22
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else283
    jmp .fn_end_260_app_hl_notepad_saveas_key
    jmp .endif284
.else283:
.endif284:
    lea rax, [rel np_saveloc_buf]
    push rax
    mov rcx, [rbp-56]
    pop rax
    add rax, rcx
    push rax
    mov rcx, [rbp-32]
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel np_saveloc_buf]
    push rax
    mov rcx, [rbp-56]
    pop rax
    add rax, rcx
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel np_saveloc_cursor]
    push rax
    mov rax, [rbp-56]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .fn_end_260_app_hl_notepad_saveas_key
    jmp .endif282
.else281:
.endif282:
    lea rax, [rel np_saveas_cursor]
    movsxd rax, dword [rax]
    mov [rbp-64], rax
    mov rax, [rbp-64]
    push rax
    mov rcx, 22
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else285
    jmp .fn_end_260_app_hl_notepad_saveas_key
    jmp .endif286
.else285:
.endif286:
    lea rax, [rel np_saveas_buf]
    push rax
    mov rcx, [rbp-64]
    pop rax
    add rax, rcx
    push rax
    mov rcx, [rbp-32]
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel np_saveas_buf]
    push rax
    mov rcx, [rbp-64]
    pop rax
    add rax, rcx
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel np_saveas_cursor]
    push rax
    mov rax, [rbp-64]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
.fn_end_260_app_hl_notepad_saveas_key:
    FN_END app_hl_notepad_saveas_key
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_key, 2, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
FN_ARG 1, k, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 96
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
    lea rax, [rel np_save_dialog]
    movzx rax, byte [rax]
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else287
    mov rdi, [rbp-16]
    FN_CALL app_hl_notepad_saveas_key, 1
    jmp .fn_end_286_app_hl_notepad_key
    jmp .endif288
.else287:
.endif288:
    lea rax, [rel np_menu_open]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 255
    pop rax
    and rax, rcx
    mov [rbp-32], rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 8
    pop rax
    shr rax, cl
    push rax
    mov rcx, 255
    pop rax
    and rax, rcx
    mov [rbp-40], rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 200
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else289
    FN_CALL app_hl_notepad_arrow_up, 0
    jmp .fn_end_286_app_hl_notepad_key
    jmp .endif290
.else289:
.endif290:
    mov rax, [rbp-32]
    push rax
    mov rcx, 208
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else291
    FN_CALL app_hl_notepad_arrow_down, 0
    jmp .fn_end_286_app_hl_notepad_key
    jmp .endif292
.else291:
.endif292:
    mov rax, [rbp-32]
    push rax
    mov rcx, 203
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else293
    FN_CALL app_hl_notepad_arrow_left, 0
    jmp .fn_end_286_app_hl_notepad_key
    jmp .endif294
.else293:
.endif294:
    mov rax, [rbp-32]
    push rax
    mov rcx, 205
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else295
    FN_CALL app_hl_notepad_arrow_right, 0
    jmp .fn_end_286_app_hl_notepad_key
    jmp .endif296
.else295:
.endif296:
    mov rax, [rbp-40]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else297
    jmp .fn_end_286_app_hl_notepad_key
    jmp .endif298
.else297:
.endif298:
    mov rax, [rbp-40]
    push rax
    mov rcx, 8
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else299
    FN_CALL app_hl_notepad_do_backspace, 0
    jmp .fn_end_286_app_hl_notepad_key
    jmp .endif300
.else299:
.endif300:
    mov rax, [rbp-40]
    push rax
    mov rcx, 13
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else301
    FN_CALL app_hl_notepad_do_enter, 0
    jmp .fn_end_286_app_hl_notepad_key
    jmp .endif302
.else301:
.endif302:
    mov rax, [rbp-40]
    push rax
    mov rcx, 9
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else303
    FN_CALL app_hl_notepad_do_tab, 0
    jmp .fn_end_286_app_hl_notepad_key
    jmp .endif304
.else303:
.endif304:
    mov rax, [rbp-40]
    push rax
    mov rcx, 32
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else305
    jmp .fn_end_286_app_hl_notepad_key
    jmp .endif306
.else305:
.endif306:
    mov rax, [rbp-40]
    push rax
    mov rcx, 126
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else307
    jmp .fn_end_286_app_hl_notepad_key
    jmp .endif308
.else307:
.endif308:
    mov rdi, [rbp-40]
    FN_CALL app_hl_notepad_insert_char, 1
.fn_end_286_app_hl_notepad_key:
    FN_END app_hl_notepad_key
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
app_hl_notepad_str0: db 70, 105, 108, 101, 0
app_hl_notepad_str1: db 69, 100, 105, 116, 0
app_hl_notepad_str2: db 78, 101, 119, 0
app_hl_notepad_str3: db 83, 97, 118, 101, 0
app_hl_notepad_str4: db 67, 108, 111, 115, 101, 0
app_hl_notepad_str5: db 83, 101, 108, 101, 99, 116, 32, 65, 108, 108, 0
app_hl_notepad_str6: db 67, 108, 101, 97, 114, 32, 65, 108, 108, 0
app_hl_notepad_str7: db 83, 97, 118, 101, 32, 65, 115, 0
app_hl_notepad_str8: db 78, 97, 109, 101, 58, 0
app_hl_notepad_str9: db 76, 111, 99, 97, 116, 105, 111, 110, 58, 0
app_hl_notepad_str10: db 84, 97, 98, 61, 70, 105, 101, 108, 100, 32, 32, 69, 110, 116, 101, 114, 61, 83, 97, 118, 101, 32, 32, 69, 115, 99, 61, 67, 97, 110, 99, 101, 108, 0
app_hl_notepad_str11: db 83, 97, 118, 101, 100, 33, 0
app_hl_notepad_str12: db 76, 111, 99, 97, 116, 105, 111, 110, 32, 110, 111, 116, 32, 102, 111, 117, 110, 100, 0
