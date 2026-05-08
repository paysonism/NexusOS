; NexusHL generated — do not edit by hand
; app="Explorer" stack=8192
extern app_format_bytes_size
extern app_open_file
extern exp_newfolder_active
extern exp_newfolder_buf
extern exp_newfolder_cursor
extern exp_newfolder_done_msg
extern exp_rename_active
extern exp_rename_buf
extern exp_rename_cursor
extern explorer_sel
extern fat16_format_name
extern fat16_name_buf
extern fat16_size_buf
extern filename_to_83
extern render_rect
extern render_text
extern szBackBtn
extern szColName
extern szColSize
extern szDirLabel
extern szNewFolderDone
extern szNewFolderLabel
extern szPathRoot
extern szPathSub
extern szRenameLabel
extern szStatusReady
FN_BEGIN app_hl_explorer_ui_win_x, 1, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    mov rax, 8
    mov rcx, rax
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
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    mov rax, 16
    mov rcx, rax
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
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    mov rax, 24
    mov rcx, rax
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
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    mov rax, 32
    mov rcx, rax
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
    sub rsp, 512
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
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
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
    sub rsp, 512
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
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
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
    sub rsp, 512
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
    pop rdi
    FN_CALL app_hl_explorer_ui_win_x, 1
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-16]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_explorer_ui_win_y, 1
    push rax
    mov rax, 24
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-24]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
    push rax
    pop r8
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
    sub rsp, 512
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
    pop rdi
    FN_CALL app_hl_explorer_ui_win_x, 1
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-16]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_explorer_ui_win_y, 1
    push rax
    mov rax, 24
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-24]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
    push rax
    pop r8
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
    sub rsp, 512
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_explorer_ui_win_w, 1
    push rax
    mov rax, 2
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov [rbp-40], rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_explorer_ui_win_h, 1
    push rax
    mov rax, 24
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, [rbp-16]
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    mov rax, 0
    mov rcx, rax
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
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-24]
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
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
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    push rax
    mov rax, 0
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_explorer_ui_win_w, 1
    push rax
    mov rax, 2
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, 22
    push rax
    mov rax, 15263976
    push rax
    pop r9
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
    sub rsp, 512
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 5
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    push rax
    mov rax, 15263976
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
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
    sub rsp, 512
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
    mov rax, 20
    mov rcx, rax
    pop rax
    imul rax, rcx
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 15790320
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_rect_at, 6
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, 1
    push rax
    mov rax, 10066329
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
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
    sub rsp, 512
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
    mov rax, 8
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, 20
    mov rcx, rax
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, 0
    push rax
    mov rax, 15790320
    push rax
    pop r9
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
    sub rsp, 512
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, 2
    push rax
    mov rax, 14
    push rax
    mov rax, 0
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
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
    sub rsp, 512
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
    sub rsp, 512
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    push rbx
    push r12
    FN_CALL app_hl_explorer_ui_ticks, 0
    push rax
    mov rax, 30
    mov rcx, rax
    pop rax
    cqo
    idiv rcx
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cqo
    idiv rcx
    mov rax, rdx
    mov [rbp-40], rax
    mov rax, [rbp-40]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else3
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    push rax
    pop rdx
    pop rsi
    pop rdi
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
    sub rsp, 512
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
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, 18
    push rax
    mov rax, 16777215
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_rect_at, 6
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, 3
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, 0
    push rax
    mov rax, 16777215
    push rax
    pop r9
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
    mov rax, 4
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-48]
    push rax
    mov rax, 8
    mov rcx, rax
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    pop rdx
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
FN_BEGIN app_hl_explorer_selected_entry, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    lea rax, [rel explorer_sel]
    mov eax, [rax]
    push rax
    pop rdi
    mov rax, 5
    syscall
    jmp .fn_end_4_app_hl_explorer_selected_entry
.fn_end_4_app_hl_explorer_selected_entry:
    FN_END app_hl_explorer_selected_entry
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_file_count, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    mov rax, 4
    syscall
    jmp .fn_end_4_app_hl_explorer_file_count
.fn_end_4_app_hl_explorer_file_count:
    FN_END app_hl_explorer_file_count
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_current_is_root, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    mov rax, 0
    push rax
    pop rdi
    mov rax, 5
    syscall
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else5
    mov rax, 1
    jmp .fn_end_4_app_hl_explorer_current_is_root
    jmp .endif6
.else5:
.endif6:
    mov rax, [rbp-16]
    movzx rax, byte [rax]
    push rax
    mov rax, 46
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else7
    mov rax, [rbp-16]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 32
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else9
    mov rax, 0
    jmp .fn_end_4_app_hl_explorer_current_is_root
    jmp .endif10
.else9:
.endif10:
    jmp .endif8
.else7:
.endif8:
    mov rax, 1
    jmp .fn_end_4_app_hl_explorer_current_is_root
.fn_end_4_app_hl_explorer_current_is_root:
    FN_END app_hl_explorer_current_is_root
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_clamp_selection, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    FN_CALL app_hl_explorer_file_count, 0
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx rax, al
    test rax, rax
    jz .else11
    lea rax, [rel explorer_sel]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .fn_end_10_app_hl_explorer_clamp_selection
    jmp .endif12
.else11:
.endif12:
    lea rax, [rel explorer_sel]
    mov eax, [rax]
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else13
    lea rax, [rel explorer_sel]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .fn_end_10_app_hl_explorer_clamp_selection
    jmp .endif14
.else13:
.endif14:
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else15
    lea rax, [rel explorer_sel]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif16
.else15:
.endif16:
.fn_end_10_app_hl_explorer_clamp_selection:
    FN_END app_hl_explorer_clamp_selection
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_clear_text, 2, 0, FN_RET_SCALAR
FN_ARG 0, buf, FN_KIND_SCALAR
FN_ARG 1, cap, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
    mov rax, 0
    mov [rbp-32], rax
.wst17:
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-16]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend18
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-32]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-32], rax
    jmp .wst17
.wend18:
.fn_end_16_app_hl_explorer_clear_text:
    FN_END app_hl_explorer_clear_text
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_start_rename, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    FN_CALL app_hl_explorer_selected_entry, 0
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else19
    jmp .fn_end_18_app_hl_explorer_start_rename
    jmp .endif20
.else19:
.endif20:
    lea rax, [rel exp_rename_active]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel exp_rename_cursor]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel exp_rename_buf]
    push rax
    mov rax, 24
    push rax
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_clear_text, 2
    lea rax, [rel exp_rename_buf]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rsi
    pop rdi
    FN_CALL fat16_format_name, 2
    mov rax, 0
    mov [rbp-24], rax
.wst21:
    mov rax, [rbp-24]
    push rax
    mov rax, 23
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend22
    lea rax, [rel exp_rename_buf]
    push rax
    mov rax, [rbp-24]
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else23
    lea rax, [rel exp_rename_cursor]
    push rax
    mov rax, [rbp-24]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .fn_end_18_app_hl_explorer_start_rename
    jmp .endif24
.else23:
.endif24:
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-24], rax
    jmp .wst21
.wend22:
    lea rax, [rel exp_rename_cursor]
    push rax
    mov rax, 22
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
.fn_end_18_app_hl_explorer_start_rename:
    FN_END app_hl_explorer_start_rename
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_start_new_folder, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    lea rax, [rel exp_newfolder_active]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel exp_newfolder_cursor]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel exp_newfolder_buf]
    push rax
    mov rax, 24
    push rax
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_clear_text, 2
.fn_end_24_app_hl_explorer_start_new_folder:
    FN_END app_hl_explorer_start_new_folder
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_enter_selected, 1, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    FN_CALL app_hl_explorer_selected_entry, 0
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else25
    jmp .fn_end_24_app_hl_explorer_enter_selected
    jmp .endif26
.else25:
.endif26:
    mov rax, [rbp-24]
    push rax
    mov rax, 11
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 16
    mov rcx, rax
    pop rax
    and rax, rcx
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else27
    mov rax, [rbp-24]
    push rax
    mov rax, 26
    mov rcx, rax
    pop rax
    add rax, rcx
    mov eax, [rax]
    push rax
    pop rdi
    mov rax, 6
    syscall
    lea rax, [rel explorer_sel]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .fn_end_24_app_hl_explorer_enter_selected
    jmp .endif28
.else27:
.endif28:
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rsi
    pop rdi
    FN_CALL app_open_file, 2
.fn_end_24_app_hl_explorer_enter_selected:
    FN_END app_hl_explorer_enter_selected
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_draw_overlay, 6, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
FN_ARG 1, label, FN_KIND_SCALAR
FN_ARG 2, buf, FN_KIND_SCALAR
FN_ARG 3, cursor, FN_KIND_SCALAR
FN_ARG 4, color, FN_KIND_SCALAR
FN_ARG 5, xoff, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
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
    pop rdi
    FN_CALL app_hl_explorer_ui_win_x, 1
    mov [rbp-64], rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_explorer_ui_win_y, 1
    mov [rbp-72], rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_explorer_ui_win_w, 1
    mov [rbp-80], rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_explorer_ui_win_h, 1
    mov [rbp-88], rax
    mov rax, [rbp-64]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-72]
    push rax
    mov rax, [rbp-88]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, 40
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, [rbp-80]
    push rax
    mov rax, 2
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, 22
    push rax
    mov rax, [rbp-40]
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_rect, 5
    mov rax, [rbp-64]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-72]
    push rax
    mov rax, [rbp-88]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, 38
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 16777215
    push rax
    mov rax, [rbp-40]
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_text, 5
    mov rax, [rbp-64]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-72]
    push rax
    mov rax, [rbp-88]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, 38
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, 16777215
    push rax
    mov rax, [rbp-40]
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_text, 5
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, 8
    mov rcx, rax
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-88]
    push rax
    mov rax, 24
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, 38
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_caret_blink, 3
.fn_end_28_app_hl_explorer_draw_overlay:
    FN_END app_hl_explorer_draw_overlay
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_explorer_draw, 1, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_explorer_ui_win_x, 1
    mov [rbp-24], rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_explorer_ui_win_y, 1
    mov [rbp-32], rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_explorer_ui_win_w, 1
    mov [rbp-40], rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_explorer_ui_win_h, 1
    mov [rbp-48], rax
    FN_CALL app_hl_explorer_clamp_selection, 0
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    push rax
    mov rax, 0
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, 2
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, 22
    push rax
    mov rax, 14737632
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_rect_at, 6
    FN_CALL app_hl_explorer_current_is_root, 0
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else29
    mov rax, [rbp-8]
    push rax
    mov rax, 4
    push rax
    mov rax, 3
    push rax
    lea rax, [rel szPathRoot]
    push rax
    mov rax, 3355443
    push rax
    mov rax, 14737632
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_text_at, 6
    jmp .endif30
.else29:
    mov rax, [rbp-8]
    push rax
    mov rax, 4
    push rax
    mov rax, 3
    push rax
    lea rax, [rel szPathSub]
    push rax
    mov rax, 3355443
    push rax
    mov rax, 14737632
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_text_at, 6
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, 64
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, 2
    push rax
    mov rax, 52
    push rax
    mov rax, 16
    push rax
    mov rax, 10526880
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_rect_at, 6
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, 59
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, 4
    push rax
    lea rax, [rel szBackBtn]
    push rax
    mov rax, 0
    push rax
    mov rax, 10526880
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_text_at, 6
.endif30:
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    push rax
    mov rax, 22
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, 2
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, 18
    push rax
    mov rax, 13684960
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_rect_at, 6
    mov rax, [rbp-8]
    push rax
    mov rax, 4
    push rax
    mov rax, 22
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel szColName]
    push rax
    mov rax, 3355443
    push rax
    mov rax, 13684960
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_text_at, 6
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, 100
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, 22
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel szColSize]
    push rax
    mov rax, 3355443
    push rax
    mov rax, 13684960
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_text_at, 6
    FN_CALL app_hl_explorer_file_count, 0
    mov [rbp-56], rax
    mov rax, 0
    mov [rbp-64], rax
.wst31:
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-56]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend32
    mov rax, [rbp-64]
    push rax
    mov rax, 20
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else33
    mov rax, [rbp-56]
    mov [rbp-64], rax
    jmp .endif34
.else33:
.endif34:
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-56]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else35
    mov rax, [rbp-64]
    push rax
    pop rdi
    mov rax, 5
    syscall
    mov [rbp-72], rax
    mov rax, [rbp-72]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else37
    mov rax, 42
    push rax
    mov rax, [rbp-64]
    push rax
    mov rax, 18
    mov rcx, rax
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-80], rax
    mov rax, 16777215
    mov [rbp-88], rax
    mov rax, 3355443
    mov [rbp-96], rax
    mov rax, [rbp-64]
    push rax
    lea rax, [rel explorer_sel]
    mov eax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else39
    mov rax, 168
    mov [rbp-88], rax
    mov rax, 16777215
    mov [rbp-96], rax
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    push rax
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, 2
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, 18
    push rax
    mov rax, 168
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_rect_at, 6
    jmp .endif40
.else39:
.endif40:
    lea rax, [rel fat16_name_buf]
    push rax
    mov rax, [rbp-72]
    push rax
    pop rsi
    pop rdi
    FN_CALL fat16_format_name, 2
    mov rax, [rbp-72]
    push rax
    mov rax, 11
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 16
    mov rcx, rax
    pop rax
    and rax, rcx
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else41
    mov rax, 13404160
    mov [rbp-96], rax
    mov rax, [rbp-64]
    push rax
    lea rax, [rel explorer_sel]
    mov eax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else43
    mov rax, 16777215
    mov [rbp-96], rax
    jmp .endif44
.else43:
.endif44:
    mov rax, [rbp-8]
    push rax
    mov rax, 8
    push rax
    mov rax, [rbp-80]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel fat16_name_buf]
    push rax
    mov rax, [rbp-96]
    push rax
    mov rax, [rbp-88]
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_text_at, 6
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, 80
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, [rbp-80]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel szDirLabel]
    push rax
    mov rax, 6710886
    push rax
    mov rax, [rbp-88]
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_text_at, 6
    jmp .endif42
.else41:
    mov rax, [rbp-8]
    push rax
    mov rax, 8
    push rax
    mov rax, [rbp-80]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel fat16_name_buf]
    push rax
    mov rax, [rbp-96]
    push rax
    mov rax, [rbp-88]
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_text_at, 6
    mov rax, [rbp-72]
    push rax
    mov rax, 28
    mov rcx, rax
    pop rax
    add rax, rcx
    mov eax, [rax]
    push rax
    lea rax, [rel fat16_size_buf]
    push rax
    pop rsi
    pop rdi
    FN_CALL app_format_bytes_size, 2
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, 80
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, [rbp-80]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel fat16_size_buf]
    push rax
    mov rax, 6710886
    push rax
    mov rax, [rbp-88]
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_text_at, 6
.endif42:
    jmp .endif38
.else37:
.endif38:
    mov rax, [rbp-64]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-64], rax
    jmp .endif36
.else35:
.endif36:
    jmp .wst31
.wend32:
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    push rax
    mov rax, [rbp-48]
    push rax
    mov rax, 24
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, 18
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, 2
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, 18
    push rax
    mov rax, 15263976
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_rect_at, 6
    mov rax, [rbp-8]
    push rax
    mov rax, 4
    push rax
    mov rax, [rbp-48]
    push rax
    mov rax, 24
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, 18
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel szStatusReady]
    push rax
    mov rax, 6710886
    push rax
    mov rax, 15263976
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_text_at, 6
    lea rax, [rel exp_rename_active]
    movzx rax, byte [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else45
    mov rax, [rbp-8]
    push rax
    lea rax, [rel szRenameLabel]
    push rax
    lea rax, [rel exp_rename_buf]
    push rax
    lea rax, [rel exp_rename_cursor]
    mov eax, [rax]
    push rax
    mov rax, 3359829
    push rax
    mov rax, 64
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_draw_overlay, 6
    jmp .endif46
.else45:
.endif46:
    lea rax, [rel exp_newfolder_active]
    movzx rax, byte [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else47
    mov rax, [rbp-8]
    push rax
    lea rax, [rel szNewFolderLabel]
    push rax
    lea rax, [rel exp_newfolder_buf]
    push rax
    lea rax, [rel exp_newfolder_cursor]
    mov eax, [rax]
    push rax
    mov rax, 4469589
    push rax
    mov rax, 96
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_draw_overlay, 6
    jmp .endif48
.else47:
.endif48:
    lea rax, [rel exp_newfolder_done_msg]
    movzx rax, byte [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else49
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, 140
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cqo
    idiv rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-104], rax
    mov rax, [rbp-104]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, 24
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 60
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 140
    push rax
    mov rax, 30
    push rax
    mov rax, 2263842
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_rect, 5
    mov rax, [rbp-104]
    push rax
    mov rax, 15
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, 24
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 68
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel szNewFolderDone]
    push rax
    mov rax, 16777215
    push rax
    mov rax, 2263842
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_ui_text, 5
    jmp .endif50
.else49:
.endif50:
.fn_end_28_app_hl_explorer_draw:
    FN_END app_hl_explorer_draw
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
    sub rsp, 512
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    push rbx
    push r12
    lea rax, [rel exp_newfolder_done_msg]
    movzx rax, byte [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else51
    lea rax, [rel exp_newfolder_done_msg]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_50_app_hl_explorer_click
    jmp .endif52
.else51:
.endif52:
    lea rax, [rel exp_rename_active]
    movzx rax, byte [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else53
    lea rax, [rel exp_rename_active]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_50_app_hl_explorer_click
    jmp .endif54
.else53:
.endif54:
    lea rax, [rel exp_newfolder_active]
    movzx rax, byte [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else55
    lea rax, [rel exp_newfolder_active]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_50_app_hl_explorer_click
    jmp .endif56
.else55:
.endif56:
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_explorer_ui_win_w, 1
    mov [rbp-40], rax
    FN_CALL app_hl_explorer_current_is_root, 0
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else57
    mov rax, [rbp-24]
    push rax
    mov rax, 22
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else59
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, 64
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else61
    mov rax, 0
    push rax
    pop rdi
    mov rax, 6
    syscall
    lea rax, [rel explorer_sel]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .fn_end_50_app_hl_explorer_click
    jmp .endif62
.else61:
.endif62:
    jmp .endif60
.else59:
.endif60:
    jmp .endif58
.else57:
.endif58:
    mov rax, [rbp-24]
    push rax
    mov rax, 42
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else63
    jmp .fn_end_50_app_hl_explorer_click
    jmp .endif64
.else63:
.endif64:
    mov rax, [rbp-24]
    push rax
    mov rax, 42
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, 18
    mov rcx, rax
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
    jz .else65
    jmp .fn_end_50_app_hl_explorer_click
    jmp .endif66
.else65:
.endif66:
    mov rax, [rbp-48]
    push rax
    lea rax, [rel explorer_sel]
    mov eax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else67
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_explorer_enter_selected, 1
    jmp .fn_end_50_app_hl_explorer_click
    jmp .endif68
.else67:
.endif68:
    lea rax, [rel explorer_sel]
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
.fn_end_50_app_hl_explorer_click:
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
    sub rsp, 512
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    push rbx
    push r12
    mov rax, [rbp-32]
    push rax
    mov rax, 255
    mov rcx, rax
    pop rax
    and rax, rcx
    mov [rbp-48], rax
    mov rax, [rbp-32]
    push rax
    mov rax, 8
    mov rcx, rax
    pop rax
    shr rax, cl
    push rax
    mov rax, 255
    mov rcx, rax
    pop rax
    and rax, rcx
    mov [rbp-56], rax
    mov rax, [rbp-48]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else69
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, 1
    jmp .fn_end_68_app_hl_explorer_edit_key
    jmp .endif70
.else69:
.endif70:
    mov rax, [rbp-56]
    push rax
    mov rax, 8
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else71
    mov rax, [rbp-16]
    mov eax, [rax]
    mov [rbp-64], rax
    mov rax, [rbp-64]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else73
    mov rax, 1
    jmp .fn_end_68_app_hl_explorer_edit_key
    jmp .endif74
.else73:
.endif74:
    mov rax, [rbp-64]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov [rbp-64], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-64]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-64]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, 1
    jmp .fn_end_68_app_hl_explorer_edit_key
    jmp .endif72
.else71:
.endif72:
    mov rax, [rbp-56]
    push rax
    mov rax, 32
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else75
    mov rax, 0
    jmp .fn_end_68_app_hl_explorer_edit_key
    jmp .endif76
.else75:
.endif76:
    mov rax, [rbp-56]
    push rax
    mov rax, 126
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else77
    mov rax, 1
    jmp .fn_end_68_app_hl_explorer_edit_key
    jmp .endif78
.else77:
.endif78:
    mov rax, [rbp-16]
    mov eax, [rax]
    mov [rbp-72], rax
    mov rax, [rbp-72]
    push rax
    mov rax, 22
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else79
    mov rax, 1
    jmp .fn_end_68_app_hl_explorer_edit_key
    jmp .endif80
.else79:
.endif80:
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-72]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-56]
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-72]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-72]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, 1
    jmp .fn_end_68_app_hl_explorer_edit_key
.fn_end_68_app_hl_explorer_edit_key:
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
    sub rsp, 512
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
    mov rax, [rbp-16]
    push rax
    mov rax, 255
    mov rcx, rax
    pop rax
    and rax, rcx
    mov [rbp-32], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 8
    mov rcx, rax
    pop rax
    shr rax, cl
    push rax
    mov rax, 255
    mov rcx, rax
    pop rax
    and rax, rcx
    mov [rbp-40], rax
    lea rax, [rel exp_rename_active]
    movzx rax, byte [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else81
    mov rax, [rbp-40]
    push rax
    mov rax, 13
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else83
    FN_CALL app_hl_explorer_selected_entry, 0
    mov [rbp-48], rax
    lea rax, [rel exp_rename_active]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-48]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else85
    jmp .fn_end_80_app_hl_explorer_key
    jmp .endif86
.else85:
.endif86:
    lea rax, [rel exp_rename_buf]
    push rax
    lea rax, [rel fat16_name_buf]
    push rax
    pop rsi
    pop rdi
    FN_CALL filename_to_83, 2
    mov rax, [rbp-48]
    push rax
    lea rax, [rel fat16_name_buf]
    push rax
    pop rsi
    pop rdi
    mov rax, 20
    syscall
    jmp .fn_end_80_app_hl_explorer_key
    jmp .endif84
.else83:
.endif84:
    lea rax, [rel exp_rename_active]
    push rax
    lea rax, [rel exp_rename_cursor]
    push rax
    lea rax, [rel exp_rename_buf]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_edit_key, 4
    jmp .fn_end_80_app_hl_explorer_key
    jmp .endif82
.else81:
.endif82:
    lea rax, [rel exp_newfolder_active]
    movzx rax, byte [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else87
    mov rax, [rbp-40]
    push rax
    mov rax, 13
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else89
    lea rax, [rel exp_newfolder_active]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel exp_newfolder_buf]
    movzx rax, byte [rax]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else91
    jmp .fn_end_80_app_hl_explorer_key
    jmp .endif92
.else91:
.endif92:
    lea rax, [rel exp_newfolder_buf]
    push rax
    lea rax, [rel fat16_name_buf]
    push rax
    pop rsi
    pop rdi
    FN_CALL filename_to_83, 2
    lea rax, [rel fat16_name_buf]
    push rax
    pop rdi
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
    jz .else93
    lea rax, [rel exp_newfolder_done_msg]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .endif94
.else93:
.endif94:
    jmp .fn_end_80_app_hl_explorer_key
    jmp .endif90
.else89:
.endif90:
    lea rax, [rel exp_newfolder_active]
    push rax
    lea rax, [rel exp_newfolder_cursor]
    push rax
    lea rax, [rel exp_newfolder_buf]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_explorer_edit_key, 4
    jmp .fn_end_80_app_hl_explorer_key
    jmp .endif88
.else87:
.endif88:
    mov rax, [rbp-32]
    push rax
    mov rax, 200
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else95
    lea rax, [rel explorer_sel]
    mov eax, [rax]
    mov [rbp-56], rax
    mov rax, [rbp-56]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else97
    lea rax, [rel explorer_sel]
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif98
.else97:
.endif98:
    jmp .fn_end_80_app_hl_explorer_key
    jmp .endif96
.else95:
.endif96:
    mov rax, [rbp-32]
    push rax
    mov rax, 208
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else99
    lea rax, [rel explorer_sel]
    mov eax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
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
    jz .else101
    lea rax, [rel explorer_sel]
    push rax
    mov rax, [rbp-64]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif102
.else101:
.endif102:
    jmp .fn_end_80_app_hl_explorer_key
    jmp .endif100
.else99:
.endif100:
    mov rax, [rbp-32]
    push rax
    mov rax, 28
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else103
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_explorer_enter_selected, 1
    jmp .fn_end_80_app_hl_explorer_key
    jmp .endif104
.else103:
.endif104:
    mov rax, [rbp-40]
    push rax
    mov rax, 13
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else105
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_explorer_enter_selected, 1
    jmp .fn_end_80_app_hl_explorer_key
    jmp .endif106
.else105:
.endif106:
    mov rax, [rbp-40]
    push rax
    mov rax, 114
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else107
    FN_CALL app_hl_explorer_start_rename, 0
    jmp .fn_end_80_app_hl_explorer_key
    jmp .endif108
.else107:
.endif108:
    mov rax, [rbp-40]
    push rax
    mov rax, 110
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else109
    FN_CALL app_hl_explorer_start_new_folder, 0
    jmp .fn_end_80_app_hl_explorer_key
    jmp .endif110
.else109:
.endif110:
.fn_end_80_app_hl_explorer_key:
    FN_END app_hl_explorer_key
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
