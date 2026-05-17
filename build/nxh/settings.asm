; NexusHL generated — do not edit by hand
; app="Settings" stack=4096
extern render_rect
extern render_text
FN_BEGIN app_hl_settings_display_flags, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 64
    push rbx
    push r12
    mov rax, 24
    syscall
    jmp .fn_end_0_app_hl_settings_display_flags
.fn_end_0_app_hl_settings_display_flags:
    FN_END app_hl_settings_display_flags
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_display_set_flags, 1, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_settings_display_set_flags
.fn_end_0_app_hl_settings_display_set_flags:
    FN_END app_hl_settings_display_set_flags
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_display_set_mode, 3, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_settings_display_set_mode
.fn_end_0_app_hl_settings_display_set_mode:
    FN_END app_hl_settings_display_set_mode
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_cursor_init, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 64
    push rbx
    push r12
    mov rax, 17
    syscall
    jmp .fn_end_0_app_hl_settings_cursor_init
.fn_end_0_app_hl_settings_cursor_init:
    FN_END app_hl_settings_cursor_init
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_desktop_bg, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 64
    push rbx
    push r12
    mov rax, 26
    syscall
    jmp .fn_end_0_app_hl_settings_desktop_bg
.fn_end_0_app_hl_settings_desktop_bg:
    FN_END app_hl_settings_desktop_bg
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_desktop_set_bg, 1, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_settings_desktop_set_bg
.fn_end_0_app_hl_settings_desktop_set_bg:
    FN_END app_hl_settings_desktop_set_bg
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_display_native_width, 0, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_settings_display_native_width
.fn_end_0_app_hl_settings_display_native_width:
    FN_END app_hl_settings_display_native_width
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_display_native_height, 0, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_settings_display_native_height
.fn_end_0_app_hl_settings_display_native_height:
    FN_END app_hl_settings_display_native_height
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_display_current_width, 0, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_settings_display_current_width
.fn_end_0_app_hl_settings_display_current_width:
    FN_END app_hl_settings_display_current_width
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_display_current_height, 0, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_settings_display_current_height
.fn_end_0_app_hl_settings_display_current_height:
    FN_END app_hl_settings_display_current_height
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_ui_win_x, 1, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_settings_ui_win_x
.fn_end_0_app_hl_settings_ui_win_x:
    FN_END app_hl_settings_ui_win_x
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_ui_win_y, 1, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_settings_ui_win_y
.fn_end_0_app_hl_settings_ui_win_y:
    FN_END app_hl_settings_ui_win_y
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_ui_win_w, 1, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_settings_ui_win_w
.fn_end_0_app_hl_settings_ui_win_w:
    FN_END app_hl_settings_ui_win_w
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_ui_win_h, 1, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_settings_ui_win_h
.fn_end_0_app_hl_settings_ui_win_h:
    FN_END app_hl_settings_ui_win_h
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_ui_rect, 5, 0, FN_RET_SCALAR
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
.fn_end_0_app_hl_settings_ui_rect:
    FN_END app_hl_settings_ui_rect
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_ui_text, 5, 0, FN_RET_SCALAR
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
.fn_end_0_app_hl_settings_ui_text:
    FN_END app_hl_settings_ui_text
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_ui_rect_at, 6, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_settings_ui_win_x, 1
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
    FN_CALL app_hl_settings_ui_win_y, 1
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
    FN_CALL app_hl_settings_ui_rect, 5
.fn_end_0_app_hl_settings_ui_rect_at:
    FN_END app_hl_settings_ui_rect_at
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_ui_text_at, 6, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_settings_ui_win_x, 1
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
    FN_CALL app_hl_settings_ui_win_y, 1
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
    FN_CALL app_hl_settings_ui_text, 5
.fn_end_0_app_hl_settings_ui_text_at:
    FN_END app_hl_settings_ui_text_at
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_ui_fill_client_below, 3, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_settings_ui_win_w, 1
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
    FN_CALL app_hl_settings_ui_win_h, 1
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
    jmp .fn_end_0_app_hl_settings_ui_fill_client_below
    jmp .endif2
.else1:
.endif2:
    mov r9, [rbp-24]
    mov r8, [rbp-48]
    mov rcx, [rbp-40]
    mov rdx, [rbp-16]
    mov rsi, 0
    mov rdi, [rbp-8]
    FN_CALL app_hl_settings_ui_rect_at, 6
.fn_end_0_app_hl_settings_ui_fill_client_below:
    FN_END app_hl_settings_ui_fill_client_below
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_ui_menu_bar, 1, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_settings_ui_win_w, 1
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
    FN_CALL app_hl_settings_ui_rect_at, 6
.fn_end_2_app_hl_settings_ui_menu_bar:
    FN_END app_hl_settings_ui_menu_bar
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_ui_menu_label, 3, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_settings_ui_text_at, 6
.fn_end_2_app_hl_settings_ui_menu_label:
    FN_END app_hl_settings_ui_menu_label
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_ui_dropdown, 5, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_settings_ui_rect_at, 6
    mov r9, 14212579
    mov r8, 1
    mov rcx, [rbp-32]
    mov rdx, [rbp-24]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    FN_CALL app_hl_settings_ui_rect_at, 6
.fn_end_2_app_hl_settings_ui_dropdown:
    FN_END app_hl_settings_ui_dropdown
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_ui_dropdown_item, 5, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_settings_ui_text_at, 6
.fn_end_2_app_hl_settings_ui_dropdown_item:
    FN_END app_hl_settings_ui_dropdown_item
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_ui_caret, 3, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_settings_ui_rect_at, 6
.fn_end_2_app_hl_settings_ui_caret:
    FN_END app_hl_settings_ui_caret
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_ui_ticks, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 64
    push rbx
    push r12
    mov rax, 18
    syscall
    jmp .fn_end_2_app_hl_settings_ui_ticks
.fn_end_2_app_hl_settings_ui_ticks:
    FN_END app_hl_settings_ui_ticks
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_ui_caret_blink, 3, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_settings_ui_ticks, 0
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
    FN_CALL app_hl_settings_ui_caret, 3
    jmp .endif4
.else3:
.endif4:
.fn_end_2_app_hl_settings_ui_caret_blink:
    FN_END app_hl_settings_ui_caret_blink
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_ui_input, 6, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_settings_ui_rect_at, 6
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
    FN_CALL app_hl_settings_ui_text_at, 6
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
    FN_CALL app_hl_settings_ui_caret_blink, 3
.fn_end_4_app_hl_settings_ui_input:
    FN_END app_hl_settings_ui_input
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_ui_button, 6, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_settings_ui_rect_at, 6
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
    FN_CALL app_hl_settings_ui_text_at, 6
.fn_end_4_app_hl_settings_ui_button:
    FN_END app_hl_settings_ui_button
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_ui_button_hit, 5, 0, FN_RET_SCALAR
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
    jmp .fn_end_4_app_hl_settings_ui_button_hit
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
    jmp .fn_end_4_app_hl_settings_ui_button_hit
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
    jmp .fn_end_4_app_hl_settings_ui_button_hit
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
    jmp .fn_end_4_app_hl_settings_ui_button_hit
    jmp .endif12
.else11:
.endif12:
    mov rax, 1
    jmp .fn_end_4_app_hl_settings_ui_button_hit
.fn_end_4_app_hl_settings_ui_button_hit:
    FN_END app_hl_settings_ui_button_hit
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_ui_section_title, 3, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_settings_ui_text_at, 6
    mov rax, [rbp-16]
    push rax
    mov rcx, 22
    pop rax
    add rax, rcx
    jmp .fn_end_12_app_hl_settings_ui_section_title
.fn_end_12_app_hl_settings_ui_section_title:
    FN_END app_hl_settings_ui_section_title
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_ui_caption, 4, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_settings_ui_text_at, 6
    mov rax, [rbp-24]
    push rax
    mov rcx, 12
    pop rax
    add rax, rcx
    push rax
    mov rcx, 6
    pop rax
    add rax, rcx
    jmp .fn_end_12_app_hl_settings_ui_caption
.fn_end_12_app_hl_settings_ui_caption:
    FN_END app_hl_settings_ui_caption
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_ui_checkbox, 5, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_settings_ui_rect_at, 6
    mov r9, 12897235
    mov r8, 1
    mov rcx, 16
    mov rdx, [rbp-24]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    FN_CALL app_hl_settings_ui_rect_at, 6
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
    FN_CALL app_hl_settings_ui_rect_at, 6
    mov r9, 12897235
    mov r8, 16
    mov rcx, 1
    mov rdx, [rbp-24]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    FN_CALL app_hl_settings_ui_rect_at, 6
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
    FN_CALL app_hl_settings_ui_rect_at, 6
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
    FN_CALL app_hl_settings_ui_rect_at, 6
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
    FN_CALL app_hl_settings_ui_text_at, 6
    mov rax, [rbp-24]
    push rax
    mov rcx, 22
    pop rax
    add rax, rcx
    jmp .fn_end_12_app_hl_settings_ui_checkbox
.fn_end_12_app_hl_settings_ui_checkbox:
    FN_END app_hl_settings_ui_checkbox
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_ui_row_x, 3, 0, FN_RET_SCALAR
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
    jmp .fn_end_14_app_hl_settings_ui_row_x
.fn_end_14_app_hl_settings_ui_row_x:
    FN_END app_hl_settings_ui_row_x
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_ui_status_bar, 3, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_settings_ui_win_h, 1
    mov [rbp-40], rax
    mov rdi, [rbp-8]
    FN_CALL app_hl_settings_ui_win_w, 1
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
    FN_CALL app_hl_settings_ui_rect_at, 6
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
    FN_CALL app_hl_settings_ui_text_at, 6
    mov rax, [rbp-56]
    jmp .fn_end_14_app_hl_settings_ui_status_bar
.fn_end_14_app_hl_settings_ui_status_bar:
    FN_END app_hl_settings_ui_status_bar
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_ui_modal_overlay, 6, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_settings_ui_win_h, 1
    mov [rbp-64], rax
    mov rdi, [rbp-8]
    FN_CALL app_hl_settings_ui_win_w, 1
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
    FN_CALL app_hl_settings_ui_rect_at, 6
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
    FN_CALL app_hl_settings_ui_text_at, 6
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
    FN_CALL app_hl_settings_ui_text_at, 6
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
    FN_CALL app_hl_settings_ui_caret_blink, 3
.fn_end_14_app_hl_settings_ui_modal_overlay:
    FN_END app_hl_settings_ui_modal_overlay
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_ui_context_menu, 4, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_settings_ui_rect_at, 6
    mov r9, 14212579
    mov r8, 1
    mov rcx, 130
    mov rdx, [rbp-24]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    FN_CALL app_hl_settings_ui_rect_at, 6
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
    FN_CALL app_hl_settings_ui_rect_at, 6
    mov r9, 14212579
    mov r8, [rbp-48]
    mov rcx, 1
    mov rdx, [rbp-24]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    FN_CALL app_hl_settings_ui_rect_at, 6
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
    FN_CALL app_hl_settings_ui_rect_at, 6
.fn_end_14_app_hl_settings_ui_context_menu:
    FN_END app_hl_settings_ui_context_menu
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_ui_context_menu_item, 6, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_settings_ui_text_at, 6
.fn_end_14_app_hl_settings_ui_context_menu_item:
    FN_END app_hl_settings_ui_context_menu_item
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_ui_context_menu_hit, 5, 0, FN_RET_SCALAR
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
    jmp .fn_end_14_app_hl_settings_ui_context_menu_hit
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
    jmp .fn_end_14_app_hl_settings_ui_context_menu_hit
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
    jmp .fn_end_14_app_hl_settings_ui_context_menu_hit
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
    jmp .fn_end_14_app_hl_settings_ui_context_menu_hit
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
    jmp .fn_end_14_app_hl_settings_ui_context_menu_hit
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
    jmp .fn_end_14_app_hl_settings_ui_context_menu_hit
    jmp .endif26
.else25:
.endif26:
    mov rax, [rbp-72]
    jmp .fn_end_14_app_hl_settings_ui_context_menu_hit
.fn_end_14_app_hl_settings_ui_context_menu_hit:
    FN_END app_hl_settings_ui_context_menu_hit
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_svg_desktop_background, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 64
    push rbx
    push r12
    FN_CALL app_hl_settings_desktop_bg, 0
    jmp .fn_end_26_app_hl_settings_svg_desktop_background
.fn_end_26_app_hl_settings_svg_desktop_background:
    FN_END app_hl_settings_svg_desktop_background
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_svg_set_desktop_background, 1, 0, FN_RET_SCALAR
FN_ARG 0, svg_id, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rdi, [rbp-8]
    FN_CALL app_hl_settings_desktop_set_bg, 1
    jmp .fn_end_26_app_hl_settings_svg_set_desktop_background
.fn_end_26_app_hl_settings_svg_set_desktop_background:
    FN_END app_hl_settings_svg_set_desktop_background
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_raster_line, 5, 0, FN_RET_SCALAR
FN_ARG 0, x0, FN_KIND_SCALAR
FN_ARG 1, y0, FN_KIND_SCALAR
FN_ARG 2, x1, FN_KIND_SCALAR
FN_ARG 3, y1, FN_KIND_SCALAR
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
    mov r10, [rbp-32]
    mov rdx, [rbp-24]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    mov rax, 40
    syscall
    jmp .fn_end_26_app_hl_settings_raster_line
.fn_end_26_app_hl_settings_raster_line:
    FN_END app_hl_settings_raster_line
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_raster_circle, 4, 0, FN_RET_SCALAR
FN_ARG 0, cx, FN_KIND_SCALAR
FN_ARG 1, cy, FN_KIND_SCALAR
FN_ARG 2, r, FN_KIND_SCALAR
FN_ARG 3, color, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 96
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    push rbx
    push r12
    mov r10, [rbp-32]
    mov rdx, [rbp-24]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    mov rax, 41
    syscall
    jmp .fn_end_26_app_hl_settings_raster_circle
.fn_end_26_app_hl_settings_raster_circle:
    FN_END app_hl_settings_raster_circle
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_raster_triangle, 2, 0, FN_RET_SCALAR
FN_ARG 0, coords_ptr, FN_KIND_SCALAR
FN_ARG 1, color, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    mov rax, 42
    syscall
    jmp .fn_end_26_app_hl_settings_raster_triangle
.fn_end_26_app_hl_settings_raster_triangle:
    FN_END app_hl_settings_raster_triangle
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_raster_blend_pixel, 3, 0, FN_RET_SCALAR
FN_ARG 0, x, FN_KIND_SCALAR
FN_ARG 1, y, FN_KIND_SCALAR
FN_ARG 2, argb, FN_KIND_SCALAR
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
    mov rax, 45
    syscall
    jmp .fn_end_26_app_hl_settings_raster_blend_pixel
.fn_end_26_app_hl_settings_raster_blend_pixel:
    FN_END app_hl_settings_raster_blend_pixel
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_raster_blend_span, 4, 0, FN_RET_SCALAR
FN_ARG 0, x, FN_KIND_SCALAR
FN_ARG 1, y, FN_KIND_SCALAR
FN_ARG 2, len, FN_KIND_SCALAR
FN_ARG 3, argb, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 96
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    push rbx
    push r12
    mov r10, [rbp-32]
    mov rdx, [rbp-24]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    mov rax, 46
    syscall
    jmp .fn_end_26_app_hl_settings_raster_blend_span
.fn_end_26_app_hl_settings_raster_blend_span:
    FN_END app_hl_settings_raster_blend_span
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_raster_blend_buf, 4, 0, FN_RET_SCALAR
FN_ARG 0, x, FN_KIND_SCALAR
FN_ARG 1, y, FN_KIND_SCALAR
FN_ARG 2, len, FN_KIND_SCALAR
FN_ARG 3, buf, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 96
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    push rbx
    push r12
    mov r10, [rbp-32]
    mov rdx, [rbp-24]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    mov rax, 52
    syscall
    jmp .fn_end_26_app_hl_settings_raster_blend_buf
.fn_end_26_app_hl_settings_raster_blend_buf:
    FN_END app_hl_settings_raster_blend_buf
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_raster_blend_buf_screen, 4, 0, FN_RET_SCALAR
FN_ARG 0, x, FN_KIND_SCALAR
FN_ARG 1, y, FN_KIND_SCALAR
FN_ARG 2, len, FN_KIND_SCALAR
FN_ARG 3, buf, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 96
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    push rbx
    push r12
    mov r10, [rbp-32]
    mov rdx, [rbp-24]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    mov rax, 53
    syscall
    jmp .fn_end_26_app_hl_settings_raster_blend_buf_screen
.fn_end_26_app_hl_settings_raster_blend_buf_screen:
    FN_END app_hl_settings_raster_blend_buf_screen
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_raster_blend_buf_multiply, 4, 0, FN_RET_SCALAR
FN_ARG 0, x, FN_KIND_SCALAR
FN_ARG 1, y, FN_KIND_SCALAR
FN_ARG 2, len, FN_KIND_SCALAR
FN_ARG 3, buf, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 96
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    push rbx
    push r12
    mov r10, [rbp-32]
    mov rdx, [rbp-24]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    mov rax, 54
    syscall
    jmp .fn_end_26_app_hl_settings_raster_blend_buf_multiply
.fn_end_26_app_hl_settings_raster_blend_buf_multiply:
    FN_END app_hl_settings_raster_blend_buf_multiply
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_put_uint, 2, 0, FN_RET_SCALAR
FN_ARG 0, buf, FN_KIND_SCALAR
FN_ARG 1, n, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 128
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
    mov rax, [rbp-16]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else27
    mov rax, [rbp-8]
    push rax
    mov rcx, 48
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-8]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    jmp .fn_end_26_app_hl_settings_put_uint
    jmp .endif28
.else27:
.endif28:
    mov rax, [rbp-8]
    mov [rbp-32], rax
.wst29:
    mov rax, [rbp-16]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .wend30
    mov rax, [rbp-32]
    push rax
    mov rax, 48
    push rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 10
    pop rax
    cqo
    idiv rcx
    mov rax, rdx
    mov rcx, rax
    pop rax
    add rax, rcx
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
    mov rax, [rbp-16]
    push rax
    mov rcx, 10
    pop rax
    cqo
    idiv rcx
    mov [rbp-16], rax
    jmp .wst29
.wend30:
    mov rax, [rbp-8]
    mov [rbp-40], rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 1
    pop rax
    sub rax, rcx
    mov [rbp-48], rax
.wst31:
    mov rax, [rbp-40]
    push rax
    mov rcx, [rbp-48]
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend32
    mov rax, [rbp-40]
    movzx rax, byte [rax]
    mov [rbp-56], rax
    mov rax, [rbp-48]
    movzx rax, byte [rax]
    mov [rbp-64], rax
    mov rax, [rbp-40]
    push rax
    mov rcx, [rbp-64]
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-48]
    push rax
    mov rcx, [rbp-56]
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-40]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-40], rax
    mov rax, [rbp-48]
    push rax
    mov rcx, 1
    pop rax
    sub rax, rcx
    mov [rbp-48], rax
    jmp .wst31
.wend32:
    mov rax, [rbp-32]
    jmp .fn_end_26_app_hl_settings_put_uint
.fn_end_26_app_hl_settings_put_uint:
    FN_END app_hl_settings_put_uint
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_copy_cstr, 2, 0, FN_RET_SCALAR
FN_ARG 0, dst, FN_KIND_SCALAR
FN_ARG 1, src, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 112
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
    mov rax, [rbp-8]
    mov [rbp-32], rax
    mov rax, [rbp-16]
    mov [rbp-40], rax
    mov rax, [rbp-40]
    movzx rax, byte [rax]
    mov [rbp-48], rax
.wst33:
    mov rax, [rbp-48]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .wend34
    mov rax, [rbp-32]
    push rax
    mov rcx, [rbp-48]
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-32], rax
    mov rax, [rbp-40]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-40], rax
    mov rax, [rbp-40]
    movzx rax, byte [rax]
    mov [rbp-48], rax
    jmp .wst33
.wend34:
    mov rax, [rbp-32]
    jmp .fn_end_32_app_hl_settings_copy_cstr
.fn_end_32_app_hl_settings_copy_cstr:
    FN_END app_hl_settings_copy_cstr
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_fmt_res, 3, 0, FN_RET_SCALAR
FN_ARG 0, buf, FN_KIND_SCALAR
FN_ARG 1, w, FN_KIND_SCALAR
FN_ARG 2, h, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 96
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    push rbx
    push r12
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    FN_CALL app_hl_settings_put_uint, 2
    mov [rbp-40], rax
    mov rax, [rbp-40]
    push rax
    mov rcx, 120
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-40]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-40], rax
    mov rsi, [rbp-24]
    mov rdi, [rbp-40]
    FN_CALL app_hl_settings_put_uint, 2
    mov [rbp-40], rax
    mov rax, [rbp-40]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
.fn_end_34_app_hl_settings_fmt_res:
    FN_END app_hl_settings_fmt_res
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_fmt_labeled_res, 4, 0, FN_RET_SCALAR
FN_ARG 0, buf, FN_KIND_SCALAR
FN_ARG 1, prefix, FN_KIND_SCALAR
FN_ARG 2, w, FN_KIND_SCALAR
FN_ARG 3, h, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 112
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    push rbx
    push r12
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    FN_CALL app_hl_settings_copy_cstr, 2
    mov [rbp-48], rax
    mov rsi, [rbp-24]
    mov rdi, [rbp-48]
    FN_CALL app_hl_settings_put_uint, 2
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    mov rcx, 120
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-48]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    mov [rbp-48], rax
    mov rsi, [rbp-32]
    mov rdi, [rbp-48]
    FN_CALL app_hl_settings_put_uint, 2
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], cl
    xor rax, rax
.fn_end_34_app_hl_settings_fmt_labeled_res:
    FN_END app_hl_settings_fmt_labeled_res
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_set_mode, 2, 0, FN_RET_SCALAR
FN_ARG 0, width, FN_KIND_SCALAR
FN_ARG 1, height, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 96
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
    mov rdx, 32
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    FN_CALL app_hl_settings_display_set_mode, 3
    mov [rbp-32], rax
    lea rax, [rel app_hl_settings_settings_last_mode_result]
    push rax
    mov rcx, [rbp-32]
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else35
    FN_CALL app_hl_settings_cursor_init, 0
    jmp .endif36
.else35:
.endif36:
.fn_end_34_app_hl_settings_set_mode:
    FN_END app_hl_settings_set_mode
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_sync_flags, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    push rbx
    push r12
    FN_CALL app_hl_settings_display_flags, 0
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else37
    lea rax, [rel app_hl_settings_settings_flags]
    push rax
    mov rcx, [rbp-16]
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif38
.else37:
.endif38:
    lea rax, [rel app_hl_settings_settings_flags]
    movsxd rax, dword [rax]
    jmp .fn_end_36_app_hl_settings_sync_flags
.fn_end_36_app_hl_settings_sync_flags:
    FN_END app_hl_settings_sync_flags
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_sync_bg, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    push rbx
    push r12
    FN_CALL app_hl_settings_svg_desktop_background, 0
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else39
    lea rax, [rel app_hl_settings_settings_bg_cache]
    push rax
    mov rcx, [rbp-16]
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif40
.else39:
.endif40:
    lea rax, [rel app_hl_settings_settings_bg_cache]
    movsxd rax, dword [rax]
    jmp .fn_end_38_app_hl_settings_sync_bg
.fn_end_38_app_hl_settings_sync_bg:
    FN_END app_hl_settings_sync_bg
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_theme_button, 5, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
FN_ARG 1, x, FN_KIND_SCALAR
FN_ARG 2, y, FN_KIND_SCALAR
FN_ARG 3, id, FN_KIND_SCALAR
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
    mov rax, 14212579
    mov [rbp-56], rax
    FN_CALL app_hl_settings_sync_bg, 0
    push rax
    mov rcx, [rbp-32]
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else41
    mov rax, 2781183
    mov [rbp-56], rax
    jmp .endif42
.else41:
.endif42:
    mov r9, [rbp-56]
    mov r8, 16
    mov rcx, 96
    mov rdx, [rbp-24]
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    FN_CALL app_hl_settings_ui_rect_at, 6
    FN_CALL app_hl_settings_sync_bg, 0
    push rax
    mov rcx, [rbp-32]
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else43
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 5
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
    mov rax, 16777215
    push rax
    mov rax, [rbp-56]
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_settings_ui_text_at, 6
    jmp .endif44
.else43:
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 5
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
    mov rax, 2764602
    push rax
    mov rax, [rbp-56]
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_settings_ui_text_at, 6
.endif44:
.fn_end_40_app_hl_settings_theme_button:
    FN_END app_hl_settings_theme_button
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_draw, 1, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 128
    mov [rbp-8], rdi
    push rbx
    push r12
    FN_CALL app_hl_settings_sync_flags, 0
    mov [rbp-24], rax
    FN_CALL app_hl_settings_display_current_width, 0
    mov [rbp-32], rax
    FN_CALL app_hl_settings_display_current_height, 0
    mov [rbp-40], rax
    FN_CALL app_hl_settings_display_native_width, 0
    mov [rbp-48], rax
    FN_CALL app_hl_settings_display_native_height, 0
    mov [rbp-56], rax
    lea rax, [rel app_hl_settings_current_label_buf]
    push rax
    lea rax, [rel app_hl_settings_prefix_current]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-40]
    mov rcx, rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_settings_fmt_labeled_res, 4
    lea rax, [rel app_hl_settings_native_label_buf]
    push rax
    lea rax, [rel app_hl_settings_prefix_native]
    push rax
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-56]
    mov rcx, rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_settings_fmt_labeled_res, 4
    mov rdx, 16119546
    mov rsi, 0
    mov rdi, [rbp-8]
    FN_CALL app_hl_settings_ui_fill_client_below, 3
    mov rax, [rbp-8]
    push rax
    mov rax, 12
    push rax
    lea rax, [rel app_hl_settings_title_display]
    mov rdx, rax
    pop rsi
    pop rdi
    FN_CALL app_hl_settings_ui_section_title, 3
    mov rax, [rbp-8]
    push rax
    mov rax, 12
    push rax
    mov rax, 34
    push rax
    lea rax, [rel app_hl_settings_current_label_buf]
    push rax
    mov rax, 2764602
    push rax
    mov rax, 16119546
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_settings_ui_text_at, 6
    mov rax, [rbp-8]
    push rax
    mov rax, 12
    push rax
    mov rcx, 96
    pop rax
    add rax, rcx
    push rax
    mov rax, 34
    push rax
    lea rax, [rel app_hl_settings_native_label_buf]
    push rax
    mov rax, 6055539
    push rax
    mov rax, 16119546
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_settings_ui_text_at, 6
    mov rax, 14212579
    mov [rbp-64], rax
    mov rax, [rbp-32]
    push rax
    mov rcx, [rbp-48]
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else45
    mov rax, [rbp-40]
    push rax
    mov rcx, [rbp-56]
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else47
    mov rax, 2781183
    mov [rbp-64], rax
    jmp .endif48
.else47:
.endif48:
    jmp .endif46
.else45:
.endif46:
    mov r9, [rbp-64]
    mov r8, 16
    mov rcx, 110
    mov rdx, 52
    mov rsi, 12
    mov rdi, [rbp-8]
    FN_CALL app_hl_settings_ui_rect_at, 6
    mov rax, [rbp-64]
    push rax
    mov rcx, 2781183
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else49
    mov rax, [rbp-8]
    push rax
    mov rax, 12
    push rax
    mov rcx, 6
    pop rax
    add rax, rcx
    push rax
    mov rax, 52
    push rax
    mov rcx, 2
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel app_hl_settings_btn_native]
    push rax
    mov rax, 16777215
    push rax
    mov rax, [rbp-64]
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_settings_ui_text_at, 6
    jmp .endif50
.else49:
    mov rax, [rbp-8]
    push rax
    mov rax, 12
    push rax
    mov rcx, 6
    pop rax
    add rax, rcx
    push rax
    mov rax, 52
    push rax
    mov rcx, 2
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel app_hl_settings_btn_native]
    push rax
    mov rax, 2764602
    push rax
    mov rax, [rbp-64]
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_settings_ui_text_at, 6
.endif50:
    mov rax, [rbp-8]
    push rax
    mov rax, 12
    push rax
    mov rax, 78
    push rax
    lea rax, [rel app_hl_settings_label_res]
    mov rcx, rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_settings_ui_caption, 4
    mov rax, [rbp-8]
    push rax
    mov rdx, 0
    mov rsi, 88
    mov rdi, 12
    FN_CALL app_hl_settings_ui_row_x, 3
    push rax
    mov rax, 96
    push rax
    mov rax, 88
    push rax
    lea rax, [rel app_hl_settings_res_800]
    push rax
    mov rax, 14212579
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_settings_ui_button, 6
    mov rax, [rbp-8]
    push rax
    mov rdx, 1
    mov rsi, 88
    mov rdi, 12
    FN_CALL app_hl_settings_ui_row_x, 3
    push rax
    mov rax, 96
    push rax
    mov rax, 88
    push rax
    lea rax, [rel app_hl_settings_res_1024]
    push rax
    mov rax, 14212579
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_settings_ui_button, 6
    mov rax, [rbp-8]
    push rax
    mov rdx, 2
    mov rsi, 88
    mov rdi, 12
    FN_CALL app_hl_settings_ui_row_x, 3
    push rax
    mov rax, 96
    push rax
    mov rax, 88
    push rax
    lea rax, [rel app_hl_settings_res_1280]
    push rax
    mov rax, 14212579
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_settings_ui_button, 6
    mov rax, [rbp-8]
    push rax
    mov rax, 12
    push rax
    mov rax, 118
    push rax
    mov rax, [rbp-24]
    push rax
    mov rcx, 1
    pop rax
    and rax, rcx
    push rax
    lea rax, [rel app_hl_settings_label_vsync]
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_settings_ui_checkbox, 5
    mov rax, [rbp-8]
    push rax
    mov rax, 12
    push rax
    mov rcx, 130
    pop rax
    add rax, rcx
    push rax
    mov rax, 118
    push rax
    mov rax, [rbp-24]
    push rax
    mov rcx, 2
    pop rax
    and rax, rcx
    push rax
    lea rax, [rel app_hl_settings_label_fps]
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_settings_ui_checkbox, 5
    mov rax, [rbp-8]
    push rax
    mov rax, 12
    push rax
    mov rax, 130
    push rax
    mov rcx, 2
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 118
    push rax
    mov rax, [rbp-24]
    push rax
    mov rcx, 4
    pop rax
    and rax, rcx
    push rax
    lea rax, [rel app_hl_settings_label_stretch]
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_settings_ui_checkbox, 5
    mov rax, [rbp-8]
    push rax
    mov rax, 144
    push rax
    lea rax, [rel app_hl_settings_title_memory]
    mov rdx, rax
    pop rsi
    pop rdi
    FN_CALL app_hl_settings_ui_section_title, 3
    mov rax, [rbp-8]
    push rax
    mov rax, 12
    push rax
    mov rax, 164
    push rax
    lea rax, [rel app_hl_settings_label_ram]
    push rax
    mov rax, 2764602
    push rax
    mov rax, 16119546
    mov r9, rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_settings_ui_text_at, 6
    mov rax, [rbp-8]
    push rax
    mov rax, 188
    push rax
    lea rax, [rel app_hl_settings_title_bg_sec]
    mov rdx, rax
    pop rsi
    pop rdi
    FN_CALL app_hl_settings_ui_section_title, 3
    mov rax, [rbp-8]
    push rax
    mov rax, 12
    push rax
    mov rax, 204
    push rax
    lea rax, [rel app_hl_settings_label_bg]
    mov rcx, rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_settings_ui_caption, 4
    mov rax, [rbp-8]
    push rax
    mov rdx, 0
    mov rsi, 96
    mov rdi, 12
    FN_CALL app_hl_settings_ui_row_x, 3
    push rax
    mov rax, 220
    push rax
    mov rax, 0
    push rax
    lea rax, [rel app_hl_settings_bg_metal]
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_settings_theme_button, 5
    mov rax, [rbp-8]
    push rax
    mov rdx, 1
    mov rsi, 96
    mov rdi, 12
    FN_CALL app_hl_settings_ui_row_x, 3
    push rax
    mov rax, 220
    push rax
    mov rax, 1
    push rax
    lea rax, [rel app_hl_settings_bg_ribbons]
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_settings_theme_button, 5
    mov rax, [rbp-8]
    push rax
    mov rdx, 2
    mov rsi, 96
    mov rdi, 12
    FN_CALL app_hl_settings_ui_row_x, 3
    push rax
    mov rax, 220
    push rax
    mov rax, 2
    push rax
    lea rax, [rel app_hl_settings_bg_bloom]
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_settings_theme_button, 5
    lea rax, [rel app_hl_settings_settings_last_mode_result]
    movsxd rax, dword [rax]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else51
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_settings_mode_failed]
    push rax
    mov rax, 15025997
    mov rdx, rax
    pop rsi
    pop rdi
    FN_CALL app_hl_settings_ui_status_bar, 3
    jmp .endif52
.else51:
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_settings_mode_ok]
    push rax
    mov rax, 15527924
    mov rdx, rax
    pop rsi
    pop rdi
    FN_CALL app_hl_settings_ui_status_bar, 3
.endif52:
.fn_end_44_app_hl_settings_draw:
    FN_END app_hl_settings_draw
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_click, 3, 0, FN_RET_SCALAR
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
    mov rax, [rbp-24]
    push rax
    mov rcx, 52
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else53
    mov rax, [rbp-24]
    push rax
    mov rax, 52
    push rax
    mov rcx, 16
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else55
    mov r8, 110
    mov rcx, 52
    mov rdx, 12
    mov rsi, [rbp-24]
    mov rdi, [rbp-16]
    FN_CALL app_hl_settings_ui_button_hit, 5
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else57
    FN_CALL app_hl_settings_display_native_width, 0
    push rax
    FN_CALL app_hl_settings_display_native_height, 0
    mov rsi, rax
    pop rdi
    FN_CALL app_hl_settings_set_mode, 2
    jmp .fn_end_52_app_hl_settings_click
    jmp .endif58
.else57:
.endif58:
    jmp .endif56
.else55:
.endif56:
    jmp .endif54
.else53:
.endif54:
    mov rax, [rbp-24]
    push rax
    mov rcx, 96
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else59
    mov rax, [rbp-24]
    push rax
    mov rax, 96
    push rax
    mov rcx, 16
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else61
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rdx, 0
    mov rsi, 88
    mov rdi, 12
    FN_CALL app_hl_settings_ui_row_x, 3
    push rax
    mov rax, 96
    push rax
    mov rax, 88
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_settings_ui_button_hit, 5
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else63
    mov rsi, 600
    mov rdi, 800
    FN_CALL app_hl_settings_set_mode, 2
    jmp .fn_end_52_app_hl_settings_click
    jmp .endif64
.else63:
.endif64:
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rdx, 1
    mov rsi, 88
    mov rdi, 12
    FN_CALL app_hl_settings_ui_row_x, 3
    push rax
    mov rax, 96
    push rax
    mov rax, 88
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_settings_ui_button_hit, 5
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else65
    mov rsi, 768
    mov rdi, 1024
    FN_CALL app_hl_settings_set_mode, 2
    jmp .fn_end_52_app_hl_settings_click
    jmp .endif66
.else65:
.endif66:
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rdx, 2
    mov rsi, 88
    mov rdi, 12
    FN_CALL app_hl_settings_ui_row_x, 3
    push rax
    mov rax, 96
    push rax
    mov rax, 88
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_settings_ui_button_hit, 5
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else67
    mov rsi, 720
    mov rdi, 1280
    FN_CALL app_hl_settings_set_mode, 2
    jmp .fn_end_52_app_hl_settings_click
    jmp .endif68
.else67:
.endif68:
    jmp .endif62
.else61:
.endif62:
    jmp .endif60
.else59:
.endif60:
    mov rax, [rbp-24]
    push rax
    mov rcx, 118
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else69
    mov rax, [rbp-24]
    push rax
    mov rax, 118
    push rax
    mov rcx, 16
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else71
    FN_CALL app_hl_settings_sync_flags, 0
    mov [rbp-40], rax
    mov rax, [rbp-16]
    push rax
    mov rcx, 12
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else73
    mov rax, [rbp-16]
    push rax
    mov rax, 12
    push rax
    mov rcx, 16
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else75
    mov rax, [rbp-40]
    push rax
    mov rcx, 1
    pop rax
    xor rax, rcx
    mov [rbp-40], rax
    mov rdi, [rbp-40]
    FN_CALL app_hl_settings_display_set_flags, 1
    lea rax, [rel app_hl_settings_settings_flags]
    push rax
    mov rcx, [rbp-40]
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .fn_end_52_app_hl_settings_click
    jmp .endif76
.else75:
.endif76:
    jmp .endif74
.else73:
.endif74:
    mov rax, [rbp-16]
    push rax
    mov rax, 12
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
    jz .else77
    mov rax, [rbp-16]
    push rax
    mov rax, 12
    push rax
    mov rcx, 130
    pop rax
    add rax, rcx
    push rax
    mov rcx, 16
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else79
    mov rax, [rbp-40]
    push rax
    mov rcx, 2
    pop rax
    xor rax, rcx
    mov [rbp-40], rax
    mov rdi, [rbp-40]
    FN_CALL app_hl_settings_display_set_flags, 1
    lea rax, [rel app_hl_settings_settings_flags]
    push rax
    mov rcx, [rbp-40]
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .fn_end_52_app_hl_settings_click
    jmp .endif80
.else79:
.endif80:
    jmp .endif78
.else77:
.endif78:
    mov rax, [rbp-16]
    push rax
    mov rax, 12
    push rax
    mov rax, 130
    push rax
    mov rcx, 2
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else81
    mov rax, [rbp-16]
    push rax
    mov rax, 12
    push rax
    mov rax, 130
    push rax
    mov rcx, 2
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rcx, 16
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else83
    mov rax, [rbp-40]
    push rax
    mov rcx, 4
    pop rax
    xor rax, rcx
    mov [rbp-40], rax
    mov rdi, [rbp-40]
    FN_CALL app_hl_settings_display_set_flags, 1
    lea rax, [rel app_hl_settings_settings_flags]
    push rax
    mov rcx, [rbp-40]
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .fn_end_52_app_hl_settings_click
    jmp .endif84
.else83:
.endif84:
    jmp .endif82
.else81:
.endif82:
    jmp .endif72
.else71:
.endif72:
    jmp .endif70
.else69:
.endif70:
    mov rax, [rbp-24]
    push rax
    mov rcx, 220
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else85
    mov rax, [rbp-24]
    push rax
    mov rax, 220
    push rax
    mov rcx, 16
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else87
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rdx, 0
    mov rsi, 96
    mov rdi, 12
    FN_CALL app_hl_settings_ui_row_x, 3
    push rax
    mov rax, 220
    push rax
    mov rax, 96
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_settings_ui_button_hit, 5
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else89
    mov rdi, 0
    FN_CALL app_hl_settings_svg_set_desktop_background, 1
    lea rax, [rel app_hl_settings_settings_bg_cache]
    push rax
    mov rcx, 0
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .fn_end_52_app_hl_settings_click
    jmp .endif90
.else89:
.endif90:
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rdx, 1
    mov rsi, 96
    mov rdi, 12
    FN_CALL app_hl_settings_ui_row_x, 3
    push rax
    mov rax, 220
    push rax
    mov rax, 96
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_settings_ui_button_hit, 5
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else91
    mov rdi, 1
    FN_CALL app_hl_settings_svg_set_desktop_background, 1
    lea rax, [rel app_hl_settings_settings_bg_cache]
    push rax
    mov rcx, 1
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .fn_end_52_app_hl_settings_click
    jmp .endif92
.else91:
.endif92:
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rdx, 2
    mov rsi, 96
    mov rdi, 12
    FN_CALL app_hl_settings_ui_row_x, 3
    push rax
    mov rax, 220
    push rax
    mov rax, 96
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_settings_ui_button_hit, 5
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else93
    mov rdi, 2
    FN_CALL app_hl_settings_svg_set_desktop_background, 1
    lea rax, [rel app_hl_settings_settings_bg_cache]
    push rax
    mov rcx, 2
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .fn_end_52_app_hl_settings_click
    jmp .endif94
.else93:
.endif94:
    jmp .endif88
.else87:
.endif88:
    jmp .endif86
.else85:
.endif86:
.fn_end_52_app_hl_settings_click:
    FN_END app_hl_settings_click
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_settings_key, 2, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
FN_ARG 1, k, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
    jmp .fn_end_94_app_hl_settings_key
.fn_end_94_app_hl_settings_key:
    FN_END app_hl_settings_key
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
app_hl_settings_title_display: db 68, 105, 115, 112, 108, 97, 121, 0
app_hl_settings_title_memory: db 77, 101, 109, 111, 114, 121, 0
app_hl_settings_title_bg_sec: db 65, 112, 112, 101, 97, 114, 97, 110, 99, 101, 0
app_hl_settings_label_res: db 80, 114, 101, 115, 101, 116, 32, 114, 101, 115, 111, 108, 117, 116, 105, 111, 110, 115, 0
app_hl_settings_label_vsync: db 86, 83, 121, 110, 99, 0
app_hl_settings_label_fps: db 83, 104, 111, 119, 32, 70, 80, 83, 0
app_hl_settings_label_stretch: db 83, 116, 114, 101, 116, 99, 104, 32, 116, 111, 32, 102, 105, 108, 108, 0
app_hl_settings_label_ram: db 84, 111, 116, 97, 108, 32, 82, 65, 77, 58, 32, 53, 49, 50, 32, 77, 66, 0
app_hl_settings_label_bg: db 68, 101, 115, 107, 116, 111, 112, 32, 98, 97, 99, 107, 103, 114, 111, 117, 110, 100, 0
app_hl_settings_btn_native: db 85, 115, 101, 32, 78, 97, 116, 105, 118, 101, 0
app_hl_settings_res_800: db 56, 48, 48, 120, 54, 48, 48, 0
app_hl_settings_res_1024: db 49, 48, 50, 52, 120, 55, 54, 56, 0
app_hl_settings_res_1280: db 49, 50, 56, 48, 120, 55, 50, 48, 0
app_hl_settings_bg_metal: db 77, 101, 116, 97, 108, 0
app_hl_settings_bg_ribbons: db 82, 105, 98, 98, 111, 110, 115, 0
app_hl_settings_bg_bloom: db 66, 108, 111, 111, 109, 0
app_hl_settings_mode_ok: db 77, 111, 100, 101, 32, 115, 119, 105, 116, 99, 104, 32, 114, 101, 97, 100, 121, 0
app_hl_settings_mode_failed: db 77, 111, 100, 101, 32, 115, 119, 105, 116, 99, 104, 32, 102, 97, 105, 108, 101, 100, 0
app_hl_settings_prefix_current: db 67, 117, 114, 114, 101, 110, 116, 58, 32, 0
app_hl_settings_prefix_native: db 32, 32, 78, 97, 116, 105, 118, 101, 58, 32, 0
app_hl_settings_settings_flags: times 4 db 0
app_hl_settings_settings_last_mode_result: times 4 db 0
app_hl_settings_settings_bg_cache: times 4 db 0
app_hl_settings_current_res_buf: times 24 db 0
app_hl_settings_native_res_buf: times 24 db 0
app_hl_settings_current_label_buf: times 24 db 0
app_hl_settings_native_label_buf: times 24 db 0
