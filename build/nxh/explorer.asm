; NexusHL generated — do not edit by hand
; app="Explorer" stack=8192
extern exp_ctx_visible
extern exp_ctx_x
extern exp_ctx_y
extern exp_newfolder_active
extern exp_newfolder_buf
extern exp_newfolder_cursor
extern exp_newfolder_done_msg
extern exp_rename_active
extern exp_rename_buf
extern exp_rename_cursor
extern explorer_sel
extern fat16_name_buf
extern fat16_size_buf
extern prop_entry_ptr
extern render_rect
extern render_text
FN_BEGIN app_hl_explorer_display_flags, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 64
    push rbx
    push r12
    mov rax, 24
    syscall
    jmp .fn_end_0_app_hl_explorer_display_flags
.fn_end_0_app_hl_explorer_display_flags:
    FN_END app_hl_explorer_display_flags
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_display_set_flags, 1, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_explorer_display_set_flags
.fn_end_0_app_hl_explorer_display_set_flags:
    FN_END app_hl_explorer_display_set_flags
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_display_set_mode, 3, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_explorer_display_set_mode
.fn_end_0_app_hl_explorer_display_set_mode:
    FN_END app_hl_explorer_display_set_mode
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_cursor_init, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 64
    push rbx
    push r12
    mov rax, 17
    syscall
    jmp .fn_end_0_app_hl_explorer_cursor_init
.fn_end_0_app_hl_explorer_cursor_init:
    FN_END app_hl_explorer_cursor_init
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_desktop_bg, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 64
    push rbx
    push r12
    mov rax, 26
    syscall
    jmp .fn_end_0_app_hl_explorer_desktop_bg
.fn_end_0_app_hl_explorer_desktop_bg:
    FN_END app_hl_explorer_desktop_bg
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_desktop_set_bg, 1, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_explorer_desktop_set_bg
.fn_end_0_app_hl_explorer_desktop_set_bg:
    FN_END app_hl_explorer_desktop_set_bg
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_display_native_width, 0, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_explorer_display_native_width
.fn_end_0_app_hl_explorer_display_native_width:
    FN_END app_hl_explorer_display_native_width
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_display_native_height, 0, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_explorer_display_native_height
.fn_end_0_app_hl_explorer_display_native_height:
    FN_END app_hl_explorer_display_native_height
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_display_current_width, 0, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_explorer_display_current_width
.fn_end_0_app_hl_explorer_display_current_width:
    FN_END app_hl_explorer_display_current_width
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_display_current_height, 0, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_explorer_display_current_height
.fn_end_0_app_hl_explorer_display_current_height:
    FN_END app_hl_explorer_display_current_height
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_ui_win_x, 1, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_explorer_ui_win_x
.fn_end_0_app_hl_explorer_ui_win_x:
    FN_END app_hl_explorer_ui_win_x
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_ui_win_y, 1, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_explorer_ui_win_y
.fn_end_0_app_hl_explorer_ui_win_y:
    FN_END app_hl_explorer_ui_win_y
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_ui_win_w, 1, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_explorer_ui_win_w
.fn_end_0_app_hl_explorer_ui_win_w:
    FN_END app_hl_explorer_ui_win_w
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_ui_win_h, 1, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_explorer_ui_win_h
.fn_end_0_app_hl_explorer_ui_win_h:
    FN_END app_hl_explorer_ui_win_h
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_ui_rect, 5, 0, FN_RET_SCALAR
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
.fn_end_0_app_hl_explorer_ui_rect:
    FN_END app_hl_explorer_ui_rect
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_ui_text, 5, 0, FN_RET_SCALAR
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
.fn_end_0_app_hl_explorer_ui_text:
    FN_END app_hl_explorer_ui_text
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_ui_rect_at, 6, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_explorer_ui_win_x, 1
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
    FN_CALL app_hl_explorer_ui_win_y, 1
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
    FN_CALL app_hl_explorer_ui_rect, 5
.fn_end_0_app_hl_explorer_ui_rect_at:
    FN_END app_hl_explorer_ui_rect_at
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_ui_text_at, 6, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_explorer_ui_win_x, 1
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
    FN_CALL app_hl_explorer_ui_win_y, 1
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
    FN_CALL app_hl_explorer_ui_text, 5
.fn_end_0_app_hl_explorer_ui_text_at:
    FN_END app_hl_explorer_ui_text_at
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_ui_fill_client_below, 3, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_explorer_ui_win_w, 1
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
    FN_CALL app_hl_explorer_ui_win_h, 1
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
    jmp .fn_end_0_app_hl_explorer_ui_fill_client_below
    jmp .endif2
.else1:
.endif2:
    mov r9, [rbp-24]
    mov r8, [rbp-48]
    mov rcx, [rbp-40]
    mov rdx, [rbp-16]
    mov rsi, 0
    mov rdi, [rbp-8]
    FN_CALL app_hl_explorer_ui_rect_at, 6
.fn_end_0_app_hl_explorer_ui_fill_client_below:
    FN_END app_hl_explorer_ui_fill_client_below
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_ui_menu_bar, 1, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_explorer_ui_win_w, 1
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
    FN_CALL app_hl_explorer_ui_rect_at, 6
.fn_end_2_app_hl_explorer_ui_menu_bar:
    FN_END app_hl_explorer_ui_menu_bar
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_ui_menu_label, 3, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_explorer_ui_text_at, 6
.fn_end_2_app_hl_explorer_ui_menu_label:
    FN_END app_hl_explorer_ui_menu_label
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_ui_dropdown, 5, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_explorer_ui_rect_at, 6
    mov r9, 14212579
    mov r8, 1
    mov rcx, [rbp-32]
    mov rdx, [rbp-24]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    FN_CALL app_hl_explorer_ui_rect_at, 6
.fn_end_2_app_hl_explorer_ui_dropdown:
    FN_END app_hl_explorer_ui_dropdown
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_ui_dropdown_item, 5, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_explorer_ui_text_at, 6
.fn_end_2_app_hl_explorer_ui_dropdown_item:
    FN_END app_hl_explorer_ui_dropdown_item
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_ui_caret, 3, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_explorer_ui_rect_at, 6
.fn_end_2_app_hl_explorer_ui_caret:
    FN_END app_hl_explorer_ui_caret
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_ui_ticks, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 64
    push rbx
    push r12
    mov rax, 18
    syscall
    jmp .fn_end_2_app_hl_explorer_ui_ticks
.fn_end_2_app_hl_explorer_ui_ticks:
    FN_END app_hl_explorer_ui_ticks
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_ui_caret_blink, 3, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_explorer_ui_ticks, 0
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
    FN_CALL app_hl_explorer_ui_caret, 3
    jmp .endif4
.else3:
.endif4:
.fn_end_2_app_hl_explorer_ui_caret_blink:
    FN_END app_hl_explorer_ui_caret_blink
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_ui_input, 6, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_explorer_ui_rect_at, 6
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
    FN_CALL app_hl_explorer_ui_text_at, 6
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
    FN_CALL app_hl_explorer_ui_caret_blink, 3
.fn_end_4_app_hl_explorer_ui_input:
    FN_END app_hl_explorer_ui_input
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_ui_button, 6, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_explorer_ui_rect_at, 6
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
    FN_CALL app_hl_explorer_ui_text_at, 6
.fn_end_4_app_hl_explorer_ui_button:
    FN_END app_hl_explorer_ui_button
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_ui_button_hit, 5, 0, FN_RET_SCALAR
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
    jmp .fn_end_4_app_hl_explorer_ui_button_hit
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
    jmp .fn_end_4_app_hl_explorer_ui_button_hit
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
    jmp .fn_end_4_app_hl_explorer_ui_button_hit
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
    jmp .fn_end_4_app_hl_explorer_ui_button_hit
    jmp .endif12
.else11:
.endif12:
    mov rax, 1
    jmp .fn_end_4_app_hl_explorer_ui_button_hit
.fn_end_4_app_hl_explorer_ui_button_hit:
    FN_END app_hl_explorer_ui_button_hit
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_ui_section_title, 3, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_explorer_ui_text_at, 6
    mov rax, [rbp-16]
    push rax
    mov rcx, 22
    pop rax
    add rax, rcx
    jmp .fn_end_12_app_hl_explorer_ui_section_title
.fn_end_12_app_hl_explorer_ui_section_title:
    FN_END app_hl_explorer_ui_section_title
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_ui_caption, 4, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_explorer_ui_text_at, 6
    mov rax, [rbp-24]
    push rax
    mov rcx, 12
    pop rax
    add rax, rcx
    push rax
    mov rcx, 6
    pop rax
    add rax, rcx
    jmp .fn_end_12_app_hl_explorer_ui_caption
.fn_end_12_app_hl_explorer_ui_caption:
    FN_END app_hl_explorer_ui_caption
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_ui_checkbox, 5, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_explorer_ui_rect_at, 6
    mov r9, 12897235
    mov r8, 1
    mov rcx, 16
    mov rdx, [rbp-24]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    FN_CALL app_hl_explorer_ui_rect_at, 6
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
    FN_CALL app_hl_explorer_ui_rect_at, 6
    mov r9, 12897235
    mov r8, 16
    mov rcx, 1
    mov rdx, [rbp-24]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    FN_CALL app_hl_explorer_ui_rect_at, 6
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
    FN_CALL app_hl_explorer_ui_rect_at, 6
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
    FN_CALL app_hl_explorer_ui_rect_at, 6
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
    FN_CALL app_hl_explorer_ui_text_at, 6
    mov rax, [rbp-24]
    push rax
    mov rcx, 22
    pop rax
    add rax, rcx
    jmp .fn_end_12_app_hl_explorer_ui_checkbox
.fn_end_12_app_hl_explorer_ui_checkbox:
    FN_END app_hl_explorer_ui_checkbox
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_ui_row_x, 3, 0, FN_RET_SCALAR
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
    jmp .fn_end_14_app_hl_explorer_ui_row_x
.fn_end_14_app_hl_explorer_ui_row_x:
    FN_END app_hl_explorer_ui_row_x
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_ui_status_bar, 3, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_explorer_ui_win_h, 1
    mov [rbp-40], rax
    mov rdi, [rbp-8]
    FN_CALL app_hl_explorer_ui_win_w, 1
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
    FN_CALL app_hl_explorer_ui_rect_at, 6
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
    FN_CALL app_hl_explorer_ui_text_at, 6
    mov rax, [rbp-56]
    jmp .fn_end_14_app_hl_explorer_ui_status_bar
.fn_end_14_app_hl_explorer_ui_status_bar:
    FN_END app_hl_explorer_ui_status_bar
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_ui_modal_overlay, 6, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_explorer_ui_win_h, 1
    mov [rbp-64], rax
    mov rdi, [rbp-8]
    FN_CALL app_hl_explorer_ui_win_w, 1
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
    FN_CALL app_hl_explorer_ui_rect_at, 6
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
    FN_CALL app_hl_explorer_ui_text_at, 6
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
    FN_CALL app_hl_explorer_ui_text_at, 6
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
    FN_CALL app_hl_explorer_ui_caret_blink, 3
.fn_end_14_app_hl_explorer_ui_modal_overlay:
    FN_END app_hl_explorer_ui_modal_overlay
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_ui_context_menu, 4, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_explorer_ui_rect_at, 6
    mov r9, 14212579
    mov r8, 1
    mov rcx, 130
    mov rdx, [rbp-24]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    FN_CALL app_hl_explorer_ui_rect_at, 6
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
    FN_CALL app_hl_explorer_ui_rect_at, 6
    mov r9, 14212579
    mov r8, [rbp-48]
    mov rcx, 1
    mov rdx, [rbp-24]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    FN_CALL app_hl_explorer_ui_rect_at, 6
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
    FN_CALL app_hl_explorer_ui_rect_at, 6
.fn_end_14_app_hl_explorer_ui_context_menu:
    FN_END app_hl_explorer_ui_context_menu
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_ui_context_menu_item, 6, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_explorer_ui_text_at, 6
.fn_end_14_app_hl_explorer_ui_context_menu_item:
    FN_END app_hl_explorer_ui_context_menu_item
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_ui_context_menu_hit, 5, 0, FN_RET_SCALAR
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
    jmp .fn_end_14_app_hl_explorer_ui_context_menu_hit
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
    jmp .fn_end_14_app_hl_explorer_ui_context_menu_hit
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
    jmp .fn_end_14_app_hl_explorer_ui_context_menu_hit
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
    jmp .fn_end_14_app_hl_explorer_ui_context_menu_hit
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
    jmp .fn_end_14_app_hl_explorer_ui_context_menu_hit
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
    jmp .fn_end_14_app_hl_explorer_ui_context_menu_hit
    jmp .endif26
.else25:
.endif26:
    mov rax, [rbp-72]
    jmp .fn_end_14_app_hl_explorer_ui_context_menu_hit
.fn_end_14_app_hl_explorer_ui_context_menu_hit:
    FN_END app_hl_explorer_ui_context_menu_hit
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_filename_to_83, 2, 0, FN_RET_SCALAR
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
    jmp .fn_end_26_app_hl_explorer_filename_to_83
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
    jmp .fn_end_26_app_hl_explorer_filename_to_83
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
    jmp .fn_end_26_app_hl_explorer_filename_to_83
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
.fn_end_26_app_hl_explorer_filename_to_83:
    FN_END app_hl_explorer_filename_to_83
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_format_bytes_size, 2, 0, FN_RET_SCALAR
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
    jmp .fn_end_50_app_hl_explorer_format_bytes_size
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
.fn_end_50_app_hl_explorer_format_bytes_size:
    FN_END app_hl_explorer_format_bytes_size
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_fs_is_dir, 1, 0, FN_RET_SCALAR
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
    jmp .fn_end_56_app_hl_explorer_fs_is_dir
    jmp .endif58
.else57:
.endif58:
    mov rax, 0
    jmp .fn_end_56_app_hl_explorer_fs_is_dir
.fn_end_56_app_hl_explorer_fs_is_dir:
    FN_END app_hl_explorer_fs_is_dir
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_selected_entry, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 64
    push rbx
    push r12
    lea rax, [rel explorer_sel]
    movsxd rax, dword [rax]
    mov rdi, rax
    mov rax, 5
    syscall
    jmp .fn_end_58_app_hl_explorer_selected_entry
.fn_end_58_app_hl_explorer_selected_entry:
    FN_END app_hl_explorer_selected_entry
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_file_count, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 64
    push rbx
    push r12
    mov rax, 4
    syscall
    jmp .fn_end_58_app_hl_explorer_file_count
.fn_end_58_app_hl_explorer_file_count:
    FN_END app_hl_explorer_file_count
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_current_is_root, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    push rbx
    push r12
    mov rdi, 0
    mov rax, 5
    syscall
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else59
    mov rax, 1
    jmp .fn_end_58_app_hl_explorer_current_is_root
    jmp .endif60
.else59:
.endif60:
    mov rax, [rbp-16]
    movzx rax, byte [rax]
    push rax
    mov rcx, 46
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else61
    mov rax, [rbp-16]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rcx, 32
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else63
    mov rax, 0
    jmp .fn_end_58_app_hl_explorer_current_is_root
    jmp .endif64
.else63:
.endif64:
    jmp .endif62
.else61:
.endif62:
    mov rax, 1
    jmp .fn_end_58_app_hl_explorer_current_is_root
.fn_end_58_app_hl_explorer_current_is_root:
    FN_END app_hl_explorer_current_is_root
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_clamp_selection, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    push rbx
    push r12
    FN_CALL app_hl_explorer_file_count, 0
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setle al
    movzx rax, al
    test rax, rax
    jz .else65
    lea rax, [rel explorer_sel]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .fn_end_64_app_hl_explorer_clamp_selection
    jmp .endif66
.else65:
.endif66:
    lea rax, [rel explorer_sel]
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
    jz .else67
    lea rax, [rel explorer_sel]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .fn_end_64_app_hl_explorer_clamp_selection
    jmp .endif68
.else67:
.endif68:
    mov rax, [rbp-24]
    push rax
    mov rcx, [rbp-16]
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else69
    lea rax, [rel explorer_sel]
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
    jmp .endif70
.else69:
.endif70:
.fn_end_64_app_hl_explorer_clamp_selection:
    FN_END app_hl_explorer_clamp_selection
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_clear_buf, 2, 0, FN_RET_SCALAR
FN_ARG 0, buf, FN_KIND_SCALAR
FN_ARG 1, cap, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 96
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
    mov rax, 0
    mov [rbp-32], rax
.wst71:
    mov rax, [rbp-32]
    push rax
    mov rcx, [rbp-16]
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend72
    mov rax, [rbp-8]
    push rax
    mov rcx, [rbp-32]
    pop rax
    add rax, rcx
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-32], rax
    jmp .wst71
.wend72:
.fn_end_70_app_hl_explorer_clear_buf:
    FN_END app_hl_explorer_clear_buf
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_dismiss_overlays, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 64
    push rbx
    push r12
    lea rax, [rel exp_rename_active]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel exp_newfolder_active]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel exp_newfolder_done_msg]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel exp_ctx_visible]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
.fn_end_72_app_hl_explorer_dismiss_overlays:
    FN_END app_hl_explorer_dismiss_overlays
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_start_rename, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    push rbx
    push r12
    FN_CALL app_hl_explorer_selected_entry, 0
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else73
    jmp .fn_end_72_app_hl_explorer_start_rename
    jmp .endif74
.else73:
.endif74:
    lea rax, [rel exp_rename_active]
    push rax
    mov rcx, 1
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel exp_rename_cursor]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel exp_rename_buf]
    push rax
    mov rax, 24
    mov rsi, rax
    pop rdi
    FN_CALL app_hl_explorer_clear_buf, 2
    mov rax, [rbp-16]
    push rax
    lea rax, [rel exp_rename_buf]
    mov rsi, rax
    pop rdi
    mov rax, 11
    syscall
    mov rax, 0
    mov [rbp-24], rax
.wst75:
    mov rax, [rbp-24]
    push rax
    mov rcx, 23
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend76
    lea rax, [rel exp_rename_buf]
    push rax
    mov rcx, [rbp-24]
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
    jz .else77
    lea rax, [rel exp_rename_cursor]
    push rax
    mov rcx, [rbp-24]
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .fn_end_72_app_hl_explorer_start_rename
    jmp .endif78
.else77:
.endif78:
    mov rax, [rbp-24]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-24], rax
    jmp .wst75
.wend76:
    lea rax, [rel exp_rename_cursor]
    push rax
    mov rcx, 22
    pop rax
    mov [rax], ecx
    xor rax, rax
.fn_end_72_app_hl_explorer_start_rename:
    FN_END app_hl_explorer_start_rename
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_start_new_folder, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 64
    push rbx
    push r12
    lea rax, [rel exp_newfolder_active]
    push rax
    mov rcx, 1
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel exp_newfolder_cursor]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel exp_newfolder_buf]
    push rax
    mov rax, 24
    mov rsi, rax
    pop rdi
    FN_CALL app_hl_explorer_clear_buf, 2
.fn_end_78_app_hl_explorer_start_new_folder:
    FN_END app_hl_explorer_start_new_folder
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_enter_selected, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    push rbx
    push r12
    FN_CALL app_hl_explorer_selected_entry, 0
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else79
    jmp .fn_end_78_app_hl_explorer_enter_selected
    jmp .endif80
.else79:
.endif80:
    mov rdi, [rbp-16]
    FN_CALL app_hl_explorer_fs_is_dir, 1
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else81
    mov rax, [rbp-16]
    push rax
    mov rcx, 26
    pop rax
    add rax, rcx
    movsxd rax, dword [rax]
    mov rdi, rax
    mov rax, 6
    syscall
    lea rax, [rel explorer_sel]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .fn_end_78_app_hl_explorer_enter_selected
    jmp .endif82
.else81:
.endif82:
    mov rdi, [rbp-16]
    mov rax, 22
    syscall
.fn_end_78_app_hl_explorer_enter_selected:
    FN_END app_hl_explorer_enter_selected
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_properties_drawfn_addr, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 64
    push rbx
    push r12
    lea rax, [rel app_hl_explorer_properties_draw]
.fn_end_82_app_hl_explorer_properties_drawfn_addr:
    FN_END app_hl_explorer_properties_drawfn_addr
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_open_properties, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    push rbx
    push r12
    FN_CALL app_hl_explorer_selected_entry, 0
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else83
    jmp .fn_end_82_app_hl_explorer_open_properties
    jmp .endif84
.else83:
.endif84:
    lea rax, [rel prop_entry_ptr]
    push rax
    mov rcx, [rbp-16]
    pop rax
    mov [rax], rcx
    xor rax, rax
    lea rax, [rel app_hl_explorer_szPropTitleHL]
    push rax
    mov rax, 250
    push rax
    mov rax, 200
    push rax
    mov rax, 240
    push rax
    mov rax, 140
    push rax
    FN_CALL app_hl_explorer_properties_drawfn_addr, 0
    mov r9, rax
    pop r8
    pop r10
    pop rdx
    pop rsi
    pop rdi
    mov rax, 7
    syscall
.fn_end_82_app_hl_explorer_open_properties:
    FN_END app_hl_explorer_open_properties
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_show_context_menu, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    push rbx
    push r12
    lea rax, [rel explorer_sel]
    movsxd rax, dword [rax]
    mov [rbp-16], rax
    lea rax, [rel exp_ctx_x]
    push rax
    mov rcx, 40
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel exp_ctx_y]
    push rax
    mov rax, 42
    push rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 18
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel exp_ctx_visible]
    push rax
    mov rcx, 1
    pop rax
    mov [rax], cl
    xor rax, rax
.fn_end_84_app_hl_explorer_show_context_menu:
    FN_END app_hl_explorer_show_context_menu
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_draw_path_bar, 2, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
FN_ARG 1, w, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
    mov r9, 14737632
    mov r8, 22
    mov rcx, [rbp-16]
    mov rdx, 0
    mov rsi, 0
    mov rdi, [rbp-8]
    FN_CALL app_hl_explorer_ui_rect_at, 6
    FN_CALL app_hl_explorer_current_is_root, 0
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else85
    mov rax, [rbp-8]
    push rax
    mov rax, 4
    push rax
    mov rax, 3
    push rax
    lea rax, [rel app_hl_explorer_szPathRoot]
    push rax
    mov rax, 3355443
    push rax
    mov rax, 14737632
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_text_at, 6
    jmp .endif86
.else85:
    mov rax, [rbp-8]
    push rax
    mov rax, 4
    push rax
    mov rax, 3
    push rax
    lea rax, [rel app_hl_explorer_szPathSub]
    push rax
    mov rax, 3355443
    push rax
    mov rax, 14737632
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_text_at, 6
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 56
    pop rax
    sub rax, rcx
    push rax
    mov rax, 3
    push rax
    mov rax, 48
    push rax
    lea rax, [rel app_hl_explorer_szBackBtn]
    push rax
    mov rax, 10526880
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_button, 6
.endif86:
.fn_end_84_app_hl_explorer_draw_path_bar:
    FN_END app_hl_explorer_draw_path_bar
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_draw_header, 2, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
FN_ARG 1, w, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
    mov r9, 13684960
    mov r8, 18
    mov rcx, [rbp-16]
    mov rdx, 22
    mov rsi, 0
    mov rdi, [rbp-8]
    FN_CALL app_hl_explorer_ui_rect_at, 6
    mov rax, [rbp-8]
    push rax
    mov rax, 4
    push rax
    mov rax, 22
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel app_hl_explorer_szColName]
    push rax
    mov rax, 3355443
    push rax
    mov rax, 13684960
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_text_at, 6
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 100
    pop rax
    sub rax, rcx
    push rax
    mov rax, 22
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel app_hl_explorer_szColSize]
    push rax
    mov rax, 3355443
    push rax
    mov rax, 13684960
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_text_at, 6
.fn_end_86_app_hl_explorer_draw_header:
    FN_END app_hl_explorer_draw_header
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_draw_row, 4, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
FN_ARG 1, w, FN_KIND_SCALAR
FN_ARG 2, i, FN_KIND_SCALAR
FN_ARG 3, ent, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 144
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    push rbx
    push r12
    mov rax, 42
    push rax
    mov rax, [rbp-24]
    push rax
    mov rcx, 18
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-48], rax
    mov rax, 16777215
    mov [rbp-56], rax
    mov rax, 3355443
    mov [rbp-64], rax
    mov rax, 0
    mov [rbp-72], rax
    mov rax, [rbp-24]
    push rax
    lea rax, [rel explorer_sel]
    movsxd rax, dword [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else87
    mov rax, 1
    mov [rbp-72], rax
    mov rax, 168
    mov [rbp-56], rax
    mov rax, 16777215
    mov [rbp-64], rax
    mov r9, 168
    mov r8, 18
    mov rcx, [rbp-16]
    mov rdx, [rbp-48]
    mov rsi, 0
    mov rdi, [rbp-8]
    FN_CALL app_hl_explorer_ui_rect_at, 6
    jmp .endif88
.else87:
.endif88:
    mov rax, [rbp-32]
    push rax
    lea rax, [rel fat16_name_buf]
    mov rsi, rax
    pop rdi
    mov rax, 11
    syscall
    mov rdi, [rbp-32]
    FN_CALL app_hl_explorer_fs_is_dir, 1
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else89
    mov rax, 13404160
    mov [rbp-80], rax
    mov rax, [rbp-72]
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else91
    mov rax, 16777215
    mov [rbp-80], rax
    jmp .endif92
.else91:
.endif92:
    mov rax, [rbp-8]
    push rax
    mov rax, 8
    push rax
    mov rax, [rbp-48]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel fat16_name_buf]
    push rax
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-56]
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_text_at, 6
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 80
    pop rax
    sub rax, rcx
    push rax
    mov rax, [rbp-48]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel app_hl_explorer_szDirLabel]
    push rax
    mov rax, 6710886
    push rax
    mov rax, [rbp-56]
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_text_at, 6
    jmp .endif90
.else89:
    mov rax, [rbp-8]
    push rax
    mov rax, 8
    push rax
    mov rax, [rbp-48]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel fat16_name_buf]
    push rax
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-56]
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_text_at, 6
    mov rax, [rbp-32]
    push rax
    mov rcx, 28
    pop rax
    add rax, rcx
    movsxd rax, dword [rax]
    push rax
    lea rax, [rel fat16_size_buf]
    mov rsi, rax
    pop rdi
    FN_CALL app_hl_explorer_format_bytes_size, 2
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 80
    pop rax
    sub rax, rcx
    push rax
    mov rax, [rbp-48]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel fat16_size_buf]
    push rax
    mov rax, 6710886
    push rax
    mov rax, [rbp-56]
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_text_at, 6
.endif90:
.fn_end_86_app_hl_explorer_draw_row:
    FN_END app_hl_explorer_draw_row
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_draw_rows, 2, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
FN_ARG 1, w, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 112
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
    FN_CALL app_hl_explorer_file_count, 0
    mov [rbp-32], rax
    mov rax, 0
    mov [rbp-40], rax
.wst93:
    mov rax, [rbp-40]
    push rax
    mov rcx, [rbp-32]
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend94
    mov rax, [rbp-40]
    push rax
    mov rcx, 20
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else95
    jmp .fn_end_92_app_hl_explorer_draw_rows
    jmp .endif96
.else95:
.endif96:
    mov rdi, [rbp-40]
    mov rax, 5
    syscall
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else97
    mov rcx, [rbp-48]
    mov rdx, [rbp-40]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    FN_CALL app_hl_explorer_draw_row, 4
    jmp .endif98
.else97:
.endif98:
    mov rax, [rbp-40]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-40], rax
    jmp .wst93
.wend94:
.fn_end_92_app_hl_explorer_draw_rows:
    FN_END app_hl_explorer_draw_rows
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_draw_context_menu, 1, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 96
    mov [rbp-8], rdi
    push rbx
    push r12
    lea rax, [rel exp_ctx_visible]
    movzx rax, byte [rax]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else99
    jmp .fn_end_98_app_hl_explorer_draw_context_menu
    jmp .endif100
.else99:
.endif100:
    lea rax, [rel exp_ctx_x]
    movsxd rax, dword [rax]
    mov [rbp-24], rax
    lea rax, [rel exp_ctx_y]
    movsxd rax, dword [rax]
    mov [rbp-32], rax
    mov rcx, 4
    mov rdx, [rbp-32]
    mov rsi, [rbp-24]
    mov rdi, [rbp-8]
    FN_CALL app_hl_explorer_ui_context_menu, 4
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, 0
    push rax
    lea rax, [rel app_hl_explorer_szCtxOpen]
    push rax
    mov rax, 3355443
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_context_menu_item, 6
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, 1
    push rax
    lea rax, [rel app_hl_explorer_szCtxRename]
    push rax
    mov rax, 3355443
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_context_menu_item, 6
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, 2
    push rax
    lea rax, [rel app_hl_explorer_szCtxNewFolder]
    push rax
    mov rax, 3355443
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_context_menu_item, 6
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, 3
    push rax
    lea rax, [rel app_hl_explorer_szCtxProperties]
    push rax
    mov rax, 3355443
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_context_menu_item, 6
.fn_end_98_app_hl_explorer_draw_context_menu:
    FN_END app_hl_explorer_draw_context_menu
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_draw_done_message, 2, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
FN_ARG 1, w, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 96
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
    lea rax, [rel exp_newfolder_done_msg]
    movzx rax, byte [rax]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else101
    jmp .fn_end_100_app_hl_explorer_draw_done_message
    jmp .endif102
.else101:
.endif102:
    mov rax, [rbp-16]
    push rax
    mov rcx, 140
    pop rax
    sub rax, rcx
    mov rcx, rax
    sar rcx, 63
    shr rcx, 63
    add rax, rcx
    sar rax, 1
    mov [rbp-32], rax
    mov r9, 2263842
    mov r8, 30
    mov rcx, 140
    mov rdx, 60
    mov rsi, [rbp-32]
    mov rdi, [rbp-8]
    FN_CALL app_hl_explorer_ui_rect_at, 6
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 15
    pop rax
    add rax, rcx
    push rax
    mov rax, 68
    push rax
    lea rax, [rel app_hl_explorer_szNewFolderDone]
    push rax
    mov rax, 16777215
    push rax
    mov rax, 2263842
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_text_at, 6
.fn_end_100_app_hl_explorer_draw_done_message:
    FN_END app_hl_explorer_draw_done_message
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_draw, 1, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rdi, [rbp-8]
    FN_CALL app_hl_explorer_ui_win_w, 1
    push rax
    mov rax, 2
    push rax
    mov rcx, 2
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov [rbp-24], rax
    FN_CALL app_hl_explorer_clamp_selection, 0
    mov rsi, [rbp-24]
    mov rdi, [rbp-8]
    FN_CALL app_hl_explorer_draw_path_bar, 2
    mov rsi, [rbp-24]
    mov rdi, [rbp-8]
    FN_CALL app_hl_explorer_draw_header, 2
    mov rsi, [rbp-24]
    mov rdi, [rbp-8]
    FN_CALL app_hl_explorer_draw_rows, 2
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_explorer_szStatusReady]
    push rax
    mov rax, 15263976
    mov rdx, rax
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_status_bar, 3
    lea rax, [rel exp_rename_active]
    movzx rax, byte [rax]
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else103
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_explorer_szRenameLabel]
    push rax
    lea rax, [rel exp_rename_buf]
    push rax
    lea rax, [rel exp_rename_cursor]
    movsxd rax, dword [rax]
    push rax
    mov rax, 3359829
    push rax
    mov rax, 68
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_modal_overlay, 6
    jmp .endif104
.else103:
.endif104:
    lea rax, [rel exp_newfolder_active]
    movzx rax, byte [rax]
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else105
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_explorer_szNewFolderLabel]
    push rax
    lea rax, [rel exp_newfolder_buf]
    push rax
    lea rax, [rel exp_newfolder_cursor]
    movsxd rax, dword [rax]
    push rax
    mov rax, 4469589
    push rax
    mov rax, 100
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_modal_overlay, 6
    jmp .endif106
.else105:
.endif106:
    mov rsi, [rbp-24]
    mov rdi, [rbp-8]
    FN_CALL app_hl_explorer_draw_done_message, 2
    mov rdi, [rbp-8]
    FN_CALL app_hl_explorer_draw_context_menu, 1
.fn_end_102_app_hl_explorer_draw:
    FN_END app_hl_explorer_draw
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_handle_ctx_click, 2, 0, FN_RET_SCALAR
FN_ARG 0, cx, FN_KIND_SCALAR
FN_ARG 1, cy, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 112
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
    lea rax, [rel exp_ctx_x]
    movsxd rax, dword [rax]
    mov [rbp-32], rax
    lea rax, [rel exp_ctx_y]
    movsxd rax, dword [rax]
    mov [rbp-40], rax
    mov r8, 4
    mov rcx, [rbp-40]
    mov rdx, [rbp-32]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    FN_CALL app_hl_explorer_ui_context_menu_hit, 5
    mov [rbp-48], rax
    lea rax, [rel exp_ctx_visible]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-48]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else107
    FN_CALL app_hl_explorer_enter_selected, 0
    jmp .fn_end_106_app_hl_explorer_handle_ctx_click
    jmp .endif108
.else107:
.endif108:
    mov rax, [rbp-48]
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else109
    FN_CALL app_hl_explorer_start_rename, 0
    jmp .fn_end_106_app_hl_explorer_handle_ctx_click
    jmp .endif110
.else109:
.endif110:
    mov rax, [rbp-48]
    push rax
    mov rcx, 2
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else111
    FN_CALL app_hl_explorer_start_new_folder, 0
    jmp .fn_end_106_app_hl_explorer_handle_ctx_click
    jmp .endif112
.else111:
.endif112:
    mov rax, [rbp-48]
    push rax
    mov rcx, 3
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else113
    FN_CALL app_hl_explorer_open_properties, 0
    jmp .fn_end_106_app_hl_explorer_handle_ctx_click
    jmp .endif114
.else113:
.endif114:
.fn_end_106_app_hl_explorer_handle_ctx_click:
    FN_END app_hl_explorer_handle_ctx_click
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_click, 3, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
FN_ARG 1, cx, FN_KIND_SCALAR
FN_ARG 2, cy, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 112
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    push rbx
    push r12
    lea rax, [rel exp_newfolder_done_msg]
    movzx rax, byte [rax]
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else115
    lea rax, [rel exp_newfolder_done_msg]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_114_app_hl_explorer_click
    jmp .endif116
.else115:
.endif116:
    lea rax, [rel exp_ctx_visible]
    movzx rax, byte [rax]
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else117
    mov rsi, [rbp-24]
    mov rdi, [rbp-16]
    FN_CALL app_hl_explorer_handle_ctx_click, 2
    jmp .fn_end_114_app_hl_explorer_click
    jmp .endif118
.else117:
.endif118:
    lea rax, [rel exp_rename_active]
    movzx rax, byte [rax]
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else119
    lea rax, [rel exp_rename_active]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_114_app_hl_explorer_click
    jmp .endif120
.else119:
.endif120:
    lea rax, [rel exp_newfolder_active]
    movzx rax, byte [rax]
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else121
    lea rax, [rel exp_newfolder_active]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_114_app_hl_explorer_click
    jmp .endif122
.else121:
.endif122:
    mov rdi, [rbp-8]
    FN_CALL app_hl_explorer_ui_win_w, 1
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
    FN_CALL app_hl_explorer_current_is_root, 0
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else123
    mov rax, [rbp-24]
    push rax
    mov rcx, 22
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else125
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-40]
    push rax
    mov rcx, 56
    pop rax
    sub rax, rcx
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else127
    mov rdi, 0
    mov rax, 6
    syscall
    lea rax, [rel explorer_sel]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .fn_end_114_app_hl_explorer_click
    jmp .endif128
.else127:
.endif128:
    jmp .endif126
.else125:
.endif126:
    jmp .endif124
.else123:
.endif124:
    mov rax, [rbp-24]
    push rax
    mov rcx, 42
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else129
    jmp .fn_end_114_app_hl_explorer_click
    jmp .endif130
.else129:
.endif130:
    mov rax, [rbp-24]
    push rax
    mov rcx, 42
    pop rax
    sub rax, rcx
    push rax
    mov rcx, 18
    pop rax
    cqo
    idiv rcx
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    FN_CALL app_hl_explorer_file_count, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else131
    jmp .fn_end_114_app_hl_explorer_click
    jmp .endif132
.else131:
.endif132:
    mov rax, [rbp-48]
    push rax
    lea rax, [rel explorer_sel]
    movsxd rax, dword [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else133
    FN_CALL app_hl_explorer_enter_selected, 0
    jmp .fn_end_114_app_hl_explorer_click
    jmp .endif134
.else133:
.endif134:
    lea rax, [rel explorer_sel]
    push rax
    mov rcx, [rbp-48]
    pop rax
    mov [rax], ecx
    xor rax, rax
.fn_end_114_app_hl_explorer_click:
    FN_END app_hl_explorer_click
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_edit_key, 4, 0, FN_RET_SCALAR
FN_ARG 0, active, FN_KIND_SCALAR
FN_ARG 1, cursor_ptr, FN_KIND_SCALAR
FN_ARG 2, buf, FN_KIND_SCALAR
FN_ARG 3, k, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 128
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    push rbx
    push r12
    mov rax, [rbp-32]
    push rax
    mov rcx, 255
    pop rax
    and rax, rcx
    mov [rbp-48], rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 8
    pop rax
    shr rax, cl
    push rax
    mov rcx, 255
    pop rax
    and rax, rcx
    mov [rbp-56], rax
    mov rax, [rbp-48]
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else135
    mov rax, [rbp-8]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, 1
    jmp .fn_end_134_app_hl_explorer_edit_key
    jmp .endif136
.else135:
.endif136:
    mov rax, [rbp-56]
    push rax
    mov rcx, 8
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else137
    mov rax, [rbp-16]
    movsxd rax, dword [rax]
    mov [rbp-64], rax
    mov rax, [rbp-64]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else139
    mov rax, 1
    jmp .fn_end_134_app_hl_explorer_edit_key
    jmp .endif140
.else139:
.endif140:
    mov rax, [rbp-64]
    push rax
    mov rcx, 1
    pop rax
    sub rax, rcx
    mov [rbp-64], rax
    mov rax, [rbp-24]
    push rax
    mov rcx, [rbp-64]
    pop rax
    add rax, rcx
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-16]
    push rax
    mov rcx, [rbp-64]
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, 1
    jmp .fn_end_134_app_hl_explorer_edit_key
    jmp .endif138
.else137:
.endif138:
    mov rax, [rbp-56]
    push rax
    mov rcx, 32
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else141
    mov rax, 0
    jmp .fn_end_134_app_hl_explorer_edit_key
    jmp .endif142
.else141:
.endif142:
    mov rax, [rbp-56]
    push rax
    mov rcx, 126
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else143
    mov rax, 1
    jmp .fn_end_134_app_hl_explorer_edit_key
    jmp .endif144
.else143:
.endif144:
    mov rax, [rbp-16]
    movsxd rax, dword [rax]
    mov [rbp-72], rax
    mov rax, [rbp-72]
    push rax
    mov rcx, 22
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else145
    mov rax, 1
    jmp .fn_end_134_app_hl_explorer_edit_key
    jmp .endif146
.else145:
.endif146:
    mov rax, [rbp-24]
    push rax
    mov rcx, [rbp-72]
    pop rax
    add rax, rcx
    push rax
    mov rcx, [rbp-56]
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-24]
    push rax
    mov rcx, [rbp-72]
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
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-72]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, 1
    jmp .fn_end_134_app_hl_explorer_edit_key
.fn_end_134_app_hl_explorer_edit_key:
    FN_END app_hl_explorer_edit_key
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_key, 2, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
FN_ARG 1, k, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 128
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
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
    lea rax, [rel exp_ctx_visible]
    movzx rax, byte [rax]
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else147
    lea rax, [rel exp_ctx_visible]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_146_app_hl_explorer_key
    jmp .endif148
.else147:
.endif148:
    lea rax, [rel exp_rename_active]
    movzx rax, byte [rax]
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else149
    mov rax, [rbp-40]
    push rax
    mov rcx, 13
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else151
    FN_CALL app_hl_explorer_selected_entry, 0
    mov [rbp-48], rax
    lea rax, [rel exp_rename_active]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-48]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else153
    jmp .fn_end_146_app_hl_explorer_key
    jmp .endif154
.else153:
.endif154:
    lea rax, [rel exp_rename_buf]
    push rax
    lea rax, [rel fat16_name_buf]
    mov rsi, rax
    pop rdi
    FN_CALL app_hl_explorer_filename_to_83, 2
    mov rax, [rbp-48]
    push rax
    lea rax, [rel fat16_name_buf]
    mov rsi, rax
    pop rdi
    mov rax, 20
    syscall
    jmp .fn_end_146_app_hl_explorer_key
    jmp .endif152
.else151:
.endif152:
    lea rax, [rel exp_rename_active]
    push rax
    lea rax, [rel exp_rename_cursor]
    push rax
    lea rax, [rel exp_rename_buf]
    push rax
    mov rax, [rbp-16]
    mov rcx, rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_edit_key, 4
    jmp .fn_end_146_app_hl_explorer_key
    jmp .endif150
.else149:
.endif150:
    lea rax, [rel exp_newfolder_active]
    movzx rax, byte [rax]
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else155
    mov rax, [rbp-40]
    push rax
    mov rcx, 13
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else157
    lea rax, [rel exp_newfolder_active]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel exp_newfolder_buf]
    movzx rax, byte [rax]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else159
    jmp .fn_end_146_app_hl_explorer_key
    jmp .endif160
.else159:
.endif160:
    lea rax, [rel exp_newfolder_buf]
    push rax
    lea rax, [rel fat16_name_buf]
    mov rsi, rax
    pop rdi
    FN_CALL app_hl_explorer_filename_to_83, 2
    lea rax, [rel fat16_name_buf]
    mov rdi, rax
    mov rax, 21
    syscall
    push rax
    mov rax, 1
    neg rax
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else161
    lea rax, [rel exp_newfolder_done_msg]
    push rax
    mov rcx, 1
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .endif162
.else161:
.endif162:
    jmp .fn_end_146_app_hl_explorer_key
    jmp .endif158
.else157:
.endif158:
    lea rax, [rel exp_newfolder_active]
    push rax
    lea rax, [rel exp_newfolder_cursor]
    push rax
    lea rax, [rel exp_newfolder_buf]
    push rax
    mov rax, [rbp-16]
    mov rcx, rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_edit_key, 4
    jmp .fn_end_146_app_hl_explorer_key
    jmp .endif156
.else155:
.endif156:
    mov rax, [rbp-32]
    push rax
    mov rcx, 200
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else163
    lea rax, [rel explorer_sel]
    movsxd rax, dword [rax]
    mov [rbp-56], rax
    mov rax, [rbp-56]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else165
    lea rax, [rel explorer_sel]
    push rax
    mov rax, [rbp-56]
    push rax
    mov rcx, 1
    pop rax
    sub rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif166
.else165:
.endif166:
    jmp .fn_end_146_app_hl_explorer_key
    jmp .endif164
.else163:
.endif164:
    mov rax, [rbp-32]
    push rax
    mov rcx, 208
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else167
    lea rax, [rel explorer_sel]
    movsxd rax, dword [rax]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-64], rax
    mov rax, [rbp-64]
    push rax
    FN_CALL app_hl_explorer_file_count, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else169
    lea rax, [rel explorer_sel]
    push rax
    mov rcx, [rbp-64]
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif170
.else169:
.endif170:
    jmp .fn_end_146_app_hl_explorer_key
    jmp .endif168
.else167:
.endif168:
    mov rax, [rbp-32]
    push rax
    mov rcx, 28
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else171
    FN_CALL app_hl_explorer_enter_selected, 0
    jmp .fn_end_146_app_hl_explorer_key
    jmp .endif172
.else171:
.endif172:
    mov rax, [rbp-40]
    push rax
    mov rcx, 13
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else173
    FN_CALL app_hl_explorer_enter_selected, 0
    jmp .fn_end_146_app_hl_explorer_key
    jmp .endif174
.else173:
.endif174:
    mov rax, [rbp-40]
    push rax
    mov rcx, 114
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else175
    FN_CALL app_hl_explorer_start_rename, 0
    jmp .fn_end_146_app_hl_explorer_key
    jmp .endif176
.else175:
.endif176:
    mov rax, [rbp-40]
    push rax
    mov rcx, 110
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else177
    FN_CALL app_hl_explorer_start_new_folder, 0
    jmp .fn_end_146_app_hl_explorer_key
    jmp .endif178
.else177:
.endif178:
    mov rax, [rbp-40]
    push rax
    mov rcx, 109
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else179
    FN_CALL app_hl_explorer_show_context_menu, 0
    jmp .fn_end_146_app_hl_explorer_key
    jmp .endif180
.else179:
.endif180:
    mov rax, [rbp-40]
    push rax
    mov rcx, 112
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else181
    FN_CALL app_hl_explorer_open_properties, 0
    jmp .fn_end_146_app_hl_explorer_key
    jmp .endif182
.else181:
.endif182:
    mov rax, [rbp-40]
    push rax
    mov rcx, 127
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else183
    FN_CALL app_hl_explorer_selected_entry, 0
    mov [rbp-72], rax
    mov rax, [rbp-72]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else185
    jmp .fn_end_146_app_hl_explorer_key
    jmp .endif186
.else185:
.endif186:
    mov rdi, [rbp-72]
    mov rax, 19
    syscall
    lea rax, [rel explorer_sel]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .fn_end_146_app_hl_explorer_key
    jmp .endif184
.else183:
.endif184:
.fn_end_146_app_hl_explorer_key:
    FN_END app_hl_explorer_key
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_properties_draw, 1, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    mov [rbp-8], rdi
    push rbx
    push r12
    lea rax, [rel prop_entry_ptr]
    mov rax, [rax]
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else187
    jmp .fn_end_186_app_hl_explorer_properties_draw
    jmp .endif188
.else187:
.endif188:
    mov rax, [rbp-24]
    push rax
    lea rax, [rel fat16_name_buf]
    mov rsi, rax
    pop rdi
    mov rax, 11
    syscall
    mov rax, [rbp-8]
    push rax
    mov rax, 8
    push rax
    mov rax, 8
    push rax
    lea rax, [rel app_hl_explorer_szPropName]
    push rax
    mov rax, 6710886
    push rax
    mov rax, 16777215
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_text_at, 6
    mov rax, [rbp-8]
    push rax
    mov rax, 60
    push rax
    mov rax, 8
    push rax
    lea rax, [rel fat16_name_buf]
    push rax
    mov rax, 0
    push rax
    mov rax, 16777215
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_text_at, 6
    mov rax, [rbp-8]
    push rax
    mov rax, 8
    push rax
    mov rax, 30
    push rax
    lea rax, [rel app_hl_explorer_szPropType]
    push rax
    mov rax, 6710886
    push rax
    mov rax, 16777215
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_text_at, 6
    mov rdi, [rbp-24]
    FN_CALL app_hl_explorer_fs_is_dir, 1
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else189
    mov rax, [rbp-8]
    push rax
    mov rax, 60
    push rax
    mov rax, 30
    push rax
    lea rax, [rel app_hl_explorer_szPropTypeDir]
    push rax
    mov rax, 0
    push rax
    mov rax, 16777215
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_text_at, 6
    jmp .endif190
.else189:
    mov rax, [rbp-8]
    push rax
    mov rax, 60
    push rax
    mov rax, 30
    push rax
    lea rax, [rel app_hl_explorer_szPropTypeFile]
    push rax
    mov rax, 0
    push rax
    mov rax, 16777215
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_text_at, 6
.endif190:
    mov rax, [rbp-8]
    push rax
    mov rax, 8
    push rax
    mov rax, 52
    push rax
    lea rax, [rel app_hl_explorer_szPropSize]
    push rax
    mov rax, 6710886
    push rax
    mov rax, 16777215
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_text_at, 6
    mov rdi, [rbp-24]
    FN_CALL app_hl_explorer_fs_is_dir, 1
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else191
    mov rax, [rbp-8]
    push rax
    mov rax, 60
    push rax
    mov rax, 52
    push rax
    lea rax, [rel app_hl_explorer_szPropSizeDir]
    push rax
    mov rax, 0
    push rax
    mov rax, 16777215
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_text_at, 6
    jmp .endif192
.else191:
    mov rax, [rbp-24]
    push rax
    mov rcx, 28
    pop rax
    add rax, rcx
    movsxd rax, dword [rax]
    push rax
    lea rax, [rel fat16_size_buf]
    mov rsi, rax
    pop rdi
    FN_CALL app_hl_explorer_format_bytes_size, 2
    mov rax, [rbp-8]
    push rax
    mov rax, 60
    push rax
    mov rax, 52
    push rax
    lea rax, [rel fat16_size_buf]
    push rax
    mov rax, 0
    push rax
    mov rax, 16777215
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_text_at, 6
.endif192:
    mov rax, [rbp-8]
    push rax
    mov rax, 8
    push rax
    mov rax, 74
    push rax
    lea rax, [rel app_hl_explorer_szPropLoc]
    push rax
    mov rax, 6710886
    push rax
    mov rax, 16777215
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_text_at, 6
    mov rax, [rbp-8]
    push rax
    mov rax, 60
    push rax
    mov rax, 74
    push rax
    lea rax, [rel app_hl_explorer_szPathRoot]
    push rax
    mov rax, 0
    push rax
    mov rax, 16777215
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_text_at, 6
.fn_end_186_app_hl_explorer_properties_draw:
    FN_END app_hl_explorer_properties_draw
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_properties_click, 3, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
FN_ARG 1, cx, FN_KIND_SCALAR
FN_ARG 2, cy, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 96
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    push rbx
    push r12
.fn_end_192_app_hl_explorer_properties_click:
    FN_END app_hl_explorer_properties_click
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_properties_key, 2, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
FN_ARG 1, k, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
.fn_end_192_app_hl_explorer_properties_key:
    FN_END app_hl_explorer_properties_key
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
app_hl_explorer_szPathRoot: db 67, 58, 92, 0
app_hl_explorer_szPathSub: db 67, 58, 92, 46, 46, 46, 0
app_hl_explorer_szColName: db 78, 97, 109, 101, 0
app_hl_explorer_szColSize: db 83, 105, 122, 101, 0
app_hl_explorer_szDirLabel: db 60, 68, 73, 82, 62, 0
app_hl_explorer_szStatusReady: db 82, 101, 97, 100, 121, 32, 32, 45, 32, 32, 69, 110, 116, 101, 114, 61, 111, 112, 101, 110, 44, 32, 82, 61, 114, 101, 110, 97, 109, 101, 44, 32, 78, 61, 110, 101, 119, 44, 32, 77, 61, 109, 101, 110, 117, 0
app_hl_explorer_szBackBtn: db 91, 85, 112, 93, 0
app_hl_explorer_szRenameLabel: db 82, 101, 110, 97, 109, 101, 58, 0
app_hl_explorer_szNewFolderLabel: db 78, 101, 119, 32, 70, 111, 108, 100, 101, 114, 58, 0
app_hl_explorer_szNewFolderDone: db 70, 111, 108, 100, 101, 114, 32, 67, 114, 101, 97, 116, 101, 100, 33, 0
app_hl_explorer_szCtxOpen: db 79, 112, 101, 110, 0
app_hl_explorer_szCtxRename: db 82, 101, 110, 97, 109, 101, 0
app_hl_explorer_szCtxNewFolder: db 78, 101, 119, 32, 70, 111, 108, 100, 101, 114, 0
app_hl_explorer_szCtxProperties: db 80, 114, 111, 112, 101, 114, 116, 105, 101, 115, 0
app_hl_explorer_szPropTitleHL: db 80, 114, 111, 112, 101, 114, 116, 105, 101, 115, 0
app_hl_explorer_szPropName: db 78, 97, 109, 101, 58, 0
app_hl_explorer_szPropType: db 84, 121, 112, 101, 58, 0
app_hl_explorer_szPropSize: db 83, 105, 122, 101, 58, 0
app_hl_explorer_szPropLoc: db 80, 97, 116, 104, 58, 0
app_hl_explorer_szPropTypeFile: db 70, 105, 108, 101, 0
app_hl_explorer_szPropTypeDir: db 70, 111, 108, 100, 101, 114, 0
app_hl_explorer_szPropSizeDir: db 45, 45, 0
