; NexusHL generated — do not edit by hand
; app="Notepad" stack=8192
extern fat16_write_file
extern filename_to_83
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
FN_BEGIN app_hl_notepad_ui_win_x, 1, 0, FN_RET_SCALAR
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
    FN_CALL app_hl_notepad_ui_win_x, 1
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
    FN_CALL app_hl_notepad_ui_win_y, 1
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
    FN_CALL app_hl_notepad_ui_win_x, 1
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
    FN_CALL app_hl_notepad_ui_win_y, 1
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
    sub rsp, 512
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_notepad_ui_win_w, 1
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
    FN_CALL app_hl_notepad_ui_win_h, 1
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
    jmp .fn_end_0_app_hl_notepad_ui_fill_client_below
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
    FN_CALL app_hl_notepad_ui_win_w, 1
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
    FN_CALL app_hl_notepad_ui_rect_at, 6
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
    sub rsp, 512
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
    sub rsp, 512
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    push rbx
    push r12
    FN_CALL app_hl_notepad_ui_ticks, 0
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
    FN_CALL app_hl_notepad_ui_rect_at, 6
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
    FN_CALL app_hl_notepad_ui_text_at, 6
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
    FN_CALL app_hl_notepad_ui_caret_blink, 3
.fn_end_4_app_hl_notepad_ui_input:
    FN_END app_hl_notepad_ui_input
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_line_ptr, 1, 0, FN_RET_SCALAR
FN_ARG 0, row, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    lea rax, [rel notepad_buf]
    push rax
    mov rax, [rbp-8]
    push rax
    mov rax, 80
    mov rcx, rax
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    jmp .fn_end_4_app_hl_notepad_line_ptr
.fn_end_4_app_hl_notepad_line_ptr:
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
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    lea rax, [rel np_line_len]
    push rax
    mov rax, [rbp-8]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    jmp .fn_end_4_app_hl_notepad_len_ptr
.fn_end_4_app_hl_notepad_len_ptr:
    FN_END app_hl_notepad_len_ptr
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_clear_buffer, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    mov rax, 0
    mov [rbp-16], rax
.wst5:
    mov rax, [rbp-16]
    push rax
    mov rax, 32
    push rax
    mov rax, 80
    mov rcx, rax
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend6
    lea rax, [rel notepad_buf]
    push rax
    mov rax, [rbp-16]
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
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-16], rax
    jmp .wst5
.wend6:
    mov rax, 0
    mov [rbp-24], rax
.wst7:
    mov rax, [rbp-24]
    push rax
    mov rax, 32
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend8
    lea rax, [rel np_line_len]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-24], rax
    jmp .wst7
.wend8:
    lea rax, [rel np_cursor_row]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel np_cursor_col]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel np_num_lines]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel np_scroll_top]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
.fn_end_4_app_hl_notepad_clear_buffer:
    FN_END app_hl_notepad_clear_buffer
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_ensure_visible, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    lea rax, [rel np_cursor_row]
    mov eax, [rax]
    mov [rbp-16], rax
    lea rax, [rel np_scroll_top]
    mov eax, [rax]
    mov [rbp-24], rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else9
    lea rax, [rel np_scroll_top]
    push rax
    mov rax, [rbp-16]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .fn_end_8_app_hl_notepad_ensure_visible
    jmp .endif10
.else9:
.endif10:
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, 15
    mov rcx, rax
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else11
    lea rax, [rel np_scroll_top]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 14
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif12
.else11:
.endif12:
.fn_end_8_app_hl_notepad_ensure_visible:
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
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    lea rax, [rel np_num_lines]
    mov eax, [rax]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else13
    lea rax, [rel np_num_lines]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif14
.else13:
.endif14:
    lea rax, [rel np_cursor_row]
    mov eax, [rax]
    mov [rbp-24], rax
    lea rax, [rel np_cursor_col]
    mov eax, [rax]
    mov [rbp-32], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else15
    jmp .fn_end_12_app_hl_notepad_insert_char
    jmp .endif16
.else15:
.endif16:
    mov rax, [rbp-24]
    push rax
    mov rax, 32
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else17
    jmp .fn_end_12_app_hl_notepad_insert_char
    jmp .endif18
.else17:
.endif18:
    mov rax, [rbp-24]
    push rax
    lea rax, [rel np_num_lines]
    mov eax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else19
    jmp .fn_end_12_app_hl_notepad_insert_char
    jmp .endif20
.else19:
.endif20:
    mov rax, [rbp-32]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else21
    jmp .fn_end_12_app_hl_notepad_insert_char
    jmp .endif22
.else21:
.endif22:
    mov rax, [rbp-32]
    push rax
    mov rax, 80
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else23
    jmp .fn_end_12_app_hl_notepad_insert_char
    jmp .endif24
.else23:
.endif24:
    mov rax, [rbp-24]
    push rax
    pop rdi
    FN_CALL app_hl_notepad_len_ptr, 1
    mov [rbp-40], rax
    mov rax, [rbp-40]
    mov eax, [rax]
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else25
    jmp .fn_end_12_app_hl_notepad_insert_char
    jmp .endif26
.else25:
.endif26:
    mov rax, [rbp-48]
    push rax
    mov rax, 80
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else27
    jmp .fn_end_12_app_hl_notepad_insert_char
    jmp .endif28
.else27:
.endif28:
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else29
    jmp .fn_end_12_app_hl_notepad_insert_char
    jmp .endif30
.else29:
.endif30:
    mov rax, [rbp-48]
    push rax
    mov rax, 80
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else31
    jmp .fn_end_12_app_hl_notepad_insert_char
    jmp .endif32
.else31:
.endif32:
    mov rax, [rbp-24]
    push rax
    pop rdi
    FN_CALL app_hl_notepad_line_ptr, 1
    mov [rbp-56], rax
    mov rax, [rbp-48]
    mov [rbp-64], rax
.wst33:
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .wend34
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-64]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-64]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    sub rax, rcx
    movzx rax, byte [rax]
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-64]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov [rbp-64], rax
    jmp .wst33
.wend34:
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-8]
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-48]
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
    lea rax, [rel np_cursor_col]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
.fn_end_12_app_hl_notepad_insert_char:
    FN_END app_hl_notepad_insert_char
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_do_backspace, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    lea rax, [rel np_cursor_col]
    mov eax, [rax]
    mov [rbp-16], rax
    lea rax, [rel np_cursor_row]
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
    jz .else35
    jmp .fn_end_34_app_hl_notepad_do_backspace
    jmp .endif36
.else35:
.endif36:
    mov rax, [rbp-24]
    push rax
    mov rax, 32
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else37
    jmp .fn_end_34_app_hl_notepad_do_backspace
    jmp .endif38
.else37:
.endif38:
    mov rax, [rbp-24]
    push rax
    lea rax, [rel np_num_lines]
    mov eax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else39
    jmp .fn_end_34_app_hl_notepad_do_backspace
    jmp .endif40
.else39:
.endif40:
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else41
    jmp .fn_end_34_app_hl_notepad_do_backspace
    jmp .endif42
.else41:
.endif42:
    mov rax, [rbp-16]
    push rax
    mov rax, 80
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else43
    jmp .fn_end_34_app_hl_notepad_do_backspace
    jmp .endif44
.else43:
.endif44:
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else45
    mov rax, [rbp-24]
    push rax
    pop rdi
    FN_CALL app_hl_notepad_line_ptr, 1
    mov [rbp-32], rax
    mov rax, [rbp-24]
    push rax
    pop rdi
    FN_CALL app_hl_notepad_len_ptr, 1
    mov [rbp-40], rax
    mov rax, [rbp-40]
    mov eax, [rax]
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else47
    jmp .fn_end_34_app_hl_notepad_do_backspace
    jmp .endif48
.else47:
.endif48:
    mov rax, [rbp-48]
    push rax
    mov rax, 80
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else49
    jmp .fn_end_34_app_hl_notepad_do_backspace
    jmp .endif50
.else49:
.endif50:
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else51
    jmp .fn_end_34_app_hl_notepad_do_backspace
    jmp .endif52
.else51:
.endif52:
    mov rax, [rbp-16]
    mov [rbp-56], rax
.wst53:
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend54
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-56]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-56]
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-56]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-56], rax
    jmp .wst53
.wend54:
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel np_cursor_col]
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
    jmp .fn_end_34_app_hl_notepad_do_backspace
    jmp .endif46
.else45:
.endif46:
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else55
    jmp .fn_end_34_app_hl_notepad_do_backspace
    jmp .endif56
.else55:
.endif56:
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov [rbp-64], rax
    mov rax, [rbp-64]
    push rax
    pop rdi
    FN_CALL app_hl_notepad_line_ptr, 1
    mov [rbp-72], rax
    mov rax, [rbp-64]
    push rax
    pop rdi
    FN_CALL app_hl_notepad_len_ptr, 1
    mov eax, [rax]
    mov [rbp-80], rax
    mov rax, [rbp-24]
    push rax
    pop rdi
    FN_CALL app_hl_notepad_line_ptr, 1
    mov [rbp-88], rax
    mov rax, [rbp-24]
    push rax
    pop rdi
    FN_CALL app_hl_notepad_len_ptr, 1
    mov eax, [rax]
    mov [rbp-96], rax
    mov rax, [rbp-80]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else57
    jmp .fn_end_34_app_hl_notepad_do_backspace
    jmp .endif58
.else57:
.endif58:
    mov rax, [rbp-96]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else59
    jmp .fn_end_34_app_hl_notepad_do_backspace
    jmp .endif60
.else59:
.endif60:
    mov rax, [rbp-80]
    push rax
    mov rax, 80
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else61
    jmp .fn_end_34_app_hl_notepad_do_backspace
    jmp .endif62
.else61:
.endif62:
    mov rax, [rbp-96]
    push rax
    mov rax, 80
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else63
    jmp .fn_end_34_app_hl_notepad_do_backspace
    jmp .endif64
.else63:
.endif64:
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-96]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 80
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else65
    jmp .fn_end_34_app_hl_notepad_do_backspace
    jmp .endif66
.else65:
.endif66:
    mov rax, 0
    mov [rbp-104], rax
.wst67:
    mov rax, [rbp-104]
    push rax
    mov rax, [rbp-96]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend68
    mov rax, [rbp-72]
    push rax
    mov rax, [rbp-80]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-104]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-88]
    push rax
    mov rax, [rbp-104]
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-104]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-104], rax
    jmp .wst67
.wend68:
    mov rax, [rbp-64]
    push rax
    pop rdi
    FN_CALL app_hl_notepad_len_ptr, 1
    push rax
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-96]
    mov rcx, rax
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, [rbp-72]
    push rax
    mov rax, [rbp-80]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-96]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel np_num_lines]
    mov eax, [rax]
    mov [rbp-112], rax
    mov rax, [rbp-24]
    mov [rbp-120], rax
.wst69:
    mov rax, [rbp-120]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-112]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend70
    mov rax, [rbp-120]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    pop rdi
    FN_CALL app_hl_notepad_line_ptr, 1
    mov [rbp-128], rax
    mov rax, [rbp-120]
    push rax
    pop rdi
    FN_CALL app_hl_notepad_line_ptr, 1
    mov [rbp-136], rax
    mov rax, 0
    mov [rbp-144], rax
.wst71:
    mov rax, [rbp-144]
    push rax
    mov rax, 80
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend72
    mov rax, [rbp-136]
    push rax
    mov rax, [rbp-144]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-128]
    push rax
    mov rax, [rbp-144]
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-144]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-144], rax
    jmp .wst71
.wend72:
    mov rax, [rbp-120]
    push rax
    pop rdi
    FN_CALL app_hl_notepad_len_ptr, 1
    push rax
    mov rax, [rbp-120]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    pop rdi
    FN_CALL app_hl_notepad_len_ptr, 1
    mov eax, [rax]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, [rbp-120]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-120], rax
    jmp .wst69
.wend70:
    lea rax, [rel np_num_lines]
    push rax
    mov rax, [rbp-112]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel np_cursor_row]
    push rax
    mov rax, [rbp-64]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel np_cursor_col]
    push rax
    mov rax, [rbp-80]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    FN_CALL app_hl_notepad_ensure_visible, 0
.fn_end_34_app_hl_notepad_do_backspace:
    FN_END app_hl_notepad_do_backspace
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_do_enter, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    lea rax, [rel np_num_lines]
    mov eax, [rax]
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 32
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else73
    jmp .fn_end_72_app_hl_notepad_do_enter
    jmp .endif74
.else73:
.endif74:
    lea rax, [rel np_cursor_row]
    mov eax, [rax]
    mov [rbp-24], rax
    lea rax, [rel np_cursor_col]
    mov eax, [rax]
    mov [rbp-32], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov [rbp-40], rax
.wst75:
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-24]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .wend76
    mov rax, [rbp-40]
    push rax
    pop rdi
    FN_CALL app_hl_notepad_line_ptr, 1
    mov [rbp-48], rax
    mov rax, [rbp-40]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    pop rdi
    FN_CALL app_hl_notepad_line_ptr, 1
    mov [rbp-56], rax
    mov rax, 0
    mov [rbp-64], rax
.wst77:
    mov rax, [rbp-64]
    push rax
    mov rax, 80
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend78
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-64]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-64]
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-64]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-64], rax
    jmp .wst77
.wend78:
    mov rax, [rbp-40]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    pop rdi
    FN_CALL app_hl_notepad_len_ptr, 1
    push rax
    mov rax, [rbp-40]
    push rax
    pop rdi
    FN_CALL app_hl_notepad_len_ptr, 1
    mov eax, [rax]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, [rbp-40]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov [rbp-40], rax
    jmp .wst75
.wend76:
    mov rax, [rbp-24]
    push rax
    pop rdi
    FN_CALL app_hl_notepad_line_ptr, 1
    mov [rbp-72], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    pop rdi
    FN_CALL app_hl_notepad_line_ptr, 1
    mov [rbp-80], rax
    mov rax, [rbp-24]
    push rax
    pop rdi
    FN_CALL app_hl_notepad_len_ptr, 1
    mov [rbp-88], rax
    mov rax, [rbp-88]
    mov eax, [rax]
    mov [rbp-96], rax
    mov rax, [rbp-32]
    mov [rbp-104], rax
    mov rax, 0
    mov [rbp-112], rax
.wst79:
    mov rax, [rbp-104]
    push rax
    mov rax, [rbp-96]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend80
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-112]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-72]
    push rax
    mov rax, [rbp-104]
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-104]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-104], rax
    mov rax, [rbp-112]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-112], rax
    jmp .wst79
.wend80:
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-112]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    pop rdi
    FN_CALL app_hl_notepad_len_ptr, 1
    push rax
    mov rax, [rbp-96]
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, [rbp-72]
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
    mov rax, [rbp-88]
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel np_num_lines]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 1
    mov rcx, rax
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
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel np_cursor_col]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    FN_CALL app_hl_notepad_ensure_visible, 0
.fn_end_72_app_hl_notepad_do_enter:
    FN_END app_hl_notepad_do_enter
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_do_tab, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    mov rax, 0
    mov [rbp-16], rax
.wst81:
    mov rax, [rbp-16]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend82
    mov rax, 32
    push rax
    pop rdi
    FN_CALL app_hl_notepad_insert_char, 1
    mov rax, [rbp-16]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-16], rax
    jmp .wst81
.wend82:
.fn_end_80_app_hl_notepad_do_tab:
    FN_END app_hl_notepad_do_tab
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_arrow_up, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    lea rax, [rel np_cursor_row]
    mov eax, [rax]
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
    jz .else83
    jmp .fn_end_82_app_hl_notepad_arrow_up
    jmp .endif84
.else83:
.endif84:
    mov rax, [rbp-16]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov [rbp-16], rax
    lea rax, [rel np_cursor_row]
    push rax
    mov rax, [rbp-16]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    FN_CALL app_hl_notepad_len_ptr, 1
    mov eax, [rax]
    mov [rbp-24], rax
    lea rax, [rel np_cursor_col]
    mov eax, [rax]
    push rax
    mov rax, [rbp-24]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else85
    lea rax, [rel np_cursor_col]
    push rax
    mov rax, [rbp-24]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif86
.else85:
.endif86:
    FN_CALL app_hl_notepad_ensure_visible, 0
.fn_end_82_app_hl_notepad_arrow_up:
    FN_END app_hl_notepad_arrow_up
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_arrow_down, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    lea rax, [rel np_cursor_row]
    mov eax, [rax]
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    lea rax, [rel np_num_lines]
    mov eax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else87
    jmp .fn_end_86_app_hl_notepad_arrow_down
    jmp .endif88
.else87:
.endif88:
    lea rax, [rel np_cursor_row]
    push rax
    mov rax, [rbp-16]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    FN_CALL app_hl_notepad_len_ptr, 1
    mov eax, [rax]
    mov [rbp-24], rax
    lea rax, [rel np_cursor_col]
    mov eax, [rax]
    push rax
    mov rax, [rbp-24]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else89
    lea rax, [rel np_cursor_col]
    push rax
    mov rax, [rbp-24]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif90
.else89:
.endif90:
    FN_CALL app_hl_notepad_ensure_visible, 0
.fn_end_86_app_hl_notepad_arrow_down:
    FN_END app_hl_notepad_arrow_down
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_arrow_left, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    lea rax, [rel np_cursor_col]
    mov eax, [rax]
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else91
    lea rax, [rel np_cursor_col]
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
    jmp .fn_end_90_app_hl_notepad_arrow_left
    jmp .endif92
.else91:
.endif92:
    lea rax, [rel np_cursor_row]
    mov eax, [rax]
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
    jz .else93
    jmp .fn_end_90_app_hl_notepad_arrow_left
    jmp .endif94
.else93:
.endif94:
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov [rbp-24], rax
    lea rax, [rel np_cursor_row]
    push rax
    mov rax, [rbp-24]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel np_cursor_col]
    push rax
    mov rax, [rbp-24]
    push rax
    pop rdi
    FN_CALL app_hl_notepad_len_ptr, 1
    mov eax, [rax]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    FN_CALL app_hl_notepad_ensure_visible, 0
.fn_end_90_app_hl_notepad_arrow_left:
    FN_END app_hl_notepad_arrow_left
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_arrow_right, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    lea rax, [rel np_cursor_row]
    mov eax, [rax]
    mov [rbp-16], rax
    lea rax, [rel np_cursor_col]
    mov eax, [rax]
    mov [rbp-24], rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    FN_CALL app_hl_notepad_len_ptr, 1
    mov eax, [rax]
    mov [rbp-32], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else95
    lea rax, [rel np_cursor_col]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .fn_end_94_app_hl_notepad_arrow_right
    jmp .endif96
.else95:
.endif96:
    mov rax, [rbp-16]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    lea rax, [rel np_num_lines]
    mov eax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else97
    jmp .fn_end_94_app_hl_notepad_arrow_right
    jmp .endif98
.else97:
.endif98:
    lea rax, [rel np_cursor_row]
    push rax
    mov rax, [rbp-16]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel np_cursor_col]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    FN_CALL app_hl_notepad_ensure_visible, 0
.fn_end_94_app_hl_notepad_arrow_right:
    FN_END app_hl_notepad_arrow_right
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_build_save_content, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    lea rax, [rel np_num_lines]
    mov eax, [rax]
    mov [rbp-16], rax
    mov rax, 0
    mov [rbp-24], rax
    mov rax, 0
    mov [rbp-32], rax
.wst99:
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend100
    mov rax, [rbp-24]
    push rax
    pop rdi
    FN_CALL app_hl_notepad_line_ptr, 1
    mov [rbp-40], rax
    mov rax, [rbp-24]
    push rax
    pop rdi
    FN_CALL app_hl_notepad_len_ptr, 1
    mov eax, [rax]
    mov [rbp-48], rax
    mov rax, 0
    mov [rbp-56], rax
.wst101:
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend102
    lea rax, [rel np_saved_content]
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-56]
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
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
    mov rax, [rbp-56]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-56], rax
    jmp .wst101
.wend102:
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-16]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else103
    lea rax, [rel np_saved_content]
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 13
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
    lea rax, [rel np_saved_content]
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 10
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
    jmp .endif104
.else103:
.endif104:
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-24], rax
    jmp .wst99
.wend100:
    lea rax, [rel np_save_total_bytes]
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, [rbp-32]
    jmp .fn_end_98_app_hl_notepad_build_save_content
.fn_end_98_app_hl_notepad_build_save_content:
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
    sub rsp, 512
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
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL fat16_write_file, 3
    lea rax, [rel np_has_saved]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel np_save_done_msg]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
.fn_end_104_app_hl_notepad_do_save_to:
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
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    movzx rax, byte [rax]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else105
    mov rax, 1
    jmp .fn_end_104_app_hl_notepad_str_is_root_or_empty
    jmp .endif106
.else105:
.endif106:
    mov rax, [rbp-8]
    movzx rax, byte [rax]
    push rax
    mov rax, 47
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else107
    mov rax, [rbp-8]
    push rax
    mov rax, 1
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
    jz .else109
    mov rax, 1
    jmp .fn_end_104_app_hl_notepad_str_is_root_or_empty
    jmp .endif110
.else109:
.endif110:
    jmp .endif108
.else107:
.endif108:
    mov rax, 0
    jmp .fn_end_104_app_hl_notepad_str_is_root_or_empty
.fn_end_104_app_hl_notepad_str_is_root_or_empty:
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
    sub rsp, 512
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
    mov rax, 0
    mov [rbp-32], rax
.wst111:
    mov rax, [rbp-32]
    push rax
    mov rax, 11
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend112
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else113
    mov rax, 0
    jmp .fn_end_110_app_hl_notepad_entry_name_eq
    jmp .endif114
.else113:
.endif114:
    mov rax, [rbp-32]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-32], rax
    jmp .wst111
.wend112:
    mov rax, 1
    jmp .fn_end_110_app_hl_notepad_entry_name_eq
.fn_end_110_app_hl_notepad_entry_name_eq:
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
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, 0
    push rax
    pop rdi
    mov rax, 6
    syscall
    mov rax, 4
    syscall
    mov [rbp-24], rax
    mov rax, 0
    mov [rbp-32], rax
.wst115:
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-24]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend116
    mov rax, [rbp-32]
    push rax
    pop rdi
    mov rax, 5
    syscall
    mov [rbp-40], rax
    mov rax, [rbp-40]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else117
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_entry_name_eq, 2
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else119
    mov rax, [rbp-40]
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
    jz .else121
    mov rax, [rbp-40]
    push rax
    mov rax, 26
    mov rcx, rax
    pop rax
    add rax, rcx
    mov eax, [rax]
    jmp .fn_end_114_app_hl_notepad_find_root_dir_cluster
    jmp .endif122
.else121:
.endif122:
    jmp .endif120
.else119:
.endif120:
    jmp .endif118
.else117:
.endif118:
    mov rax, [rbp-32]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-32], rax
    jmp .wst115
.wend116:
    mov rax, 0
    jmp .fn_end_114_app_hl_notepad_find_root_dir_cluster
.fn_end_114_app_hl_notepad_find_root_dir_cluster:
    FN_END app_hl_notepad_find_root_dir_cluster
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_save_dialog_reset, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    lea rax, [rel np_save_dialog]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel np_save_field]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel np_saveas_cursor]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel np_saveloc_cursor]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel np_saveas_buf]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel np_saveloc_buf]
    push rax
    mov rax, 47
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel np_saveloc_buf]
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
.fn_end_122_app_hl_notepad_save_dialog_reset:
    FN_END app_hl_notepad_save_dialog_reset
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_notepad_save_dialog_commit, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    lea rax, [rel np_save_dialog]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel np_saveas_buf]
    movzx rax, byte [rax]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else123
    jmp .fn_end_122_app_hl_notepad_save_dialog_commit
    jmp .endif124
.else123:
.endif124:
    mov rax, 0
    mov [rbp-16], rax
    lea rax, [rel np_saveloc_buf]
    push rax
    pop rdi
    FN_CALL app_hl_notepad_str_is_root_or_empty, 1
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else125
    lea rax, [rel np_saveloc_buf]
    mov [rbp-24], rax
    mov rax, [rbp-24]
    movzx rax, byte [rax]
    push rax
    mov rax, 47
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else127
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-24], rax
    jmp .endif128
.else127:
.endif128:
    mov rax, [rbp-24]
    push rax
    lea rax, [rel np_saveloc_83]
    push rax
    pop rsi
    pop rdi
    FN_CALL filename_to_83, 2
    lea rax, [rel np_saveloc_83]
    push rax
    pop rdi
    FN_CALL app_hl_notepad_find_root_dir_cluster, 1
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
    jz .else129
    lea rax, [rel np_save_done_msg]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, 0
    push rax
    pop rdi
    mov rax, 6
    syscall
    jmp .fn_end_122_app_hl_notepad_save_dialog_commit
    jmp .endif130
.else129:
.endif130:
    jmp .endif126
.else125:
.endif126:
    mov rax, [rbp-16]
    push rax
    pop rdi
    mov rax, 6
    syscall
    lea rax, [rel np_saveas_buf]
    push rax
    lea rax, [rel np_saveas_83]
    push rax
    pop rsi
    pop rdi
    FN_CALL filename_to_83, 2
    lea rax, [rel np_saveas_83]
    push rax
    pop rdi
    FN_CALL app_hl_notepad_do_save_to, 1
    mov rax, 0
    push rax
    pop rdi
    mov rax, 6
    syscall
.fn_end_122_app_hl_notepad_save_dialog_commit:
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
    mov [rbp-24], rax
    mov rax, [rbp-8]
    push rax
    mov rax, 16
    mov rcx, rax
    pop rax
    add rax, rcx
    mov rax, [rax]
    mov [rbp-32], rax
    mov rax, [rbp-8]
    push rax
    mov rax, 24
    mov rcx, rax
    pop rax
    add rax, rcx
    mov rax, [rax]
    mov [rbp-40], rax
    mov rax, [rbp-8]
    push rax
    mov rax, 32
    mov rcx, rax
    pop rax
    add rax, rcx
    mov rax, [rax]
    mov [rbp-48], rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_notepad_ui_menu_bar, 1
    mov rax, [rbp-8]
    push rax
    mov rax, 6
    push rax
    lea rax, [rel app_hl_notepad_str0]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_menu_label, 3
    mov rax, [rbp-8]
    push rax
    mov rax, 54
    push rax
    lea rax, [rel app_hl_notepad_str1]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_menu_label, 3
    mov rax, [rbp-48]
    push rax
    mov rax, 24
    mov rcx, rax
    pop rax
    sub rax, rcx
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
    mov [rbp-56], rax
    mov rax, [rbp-56]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx rax, al
    test rax, rax
    jz .else131
    jmp .fn_end_130_app_hl_notepad_draw
    jmp .endif132
.else131:
.endif132:
    mov rax, [rbp-24]
    push rax
    mov rax, 2
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
    mov rax, 24
    mov rcx, rax
    pop rax
    add rax, rcx
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
    mov rax, [rbp-56]
    push rax
    mov rax, 16777215
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL render_rect, 5
    mov rax, [rbp-56]
    push rax
    mov rax, 14
    mov rcx, rax
    pop rax
    cqo
    idiv rcx
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
    jz .else133
    jmp .fn_end_130_app_hl_notepad_draw
    jmp .endif134
.else133:
.endif134:
    lea rax, [rel np_scroll_top]
    mov eax, [rax]
    mov [rbp-72], rax
    lea rax, [rel np_num_lines]
    mov eax, [rax]
    mov [rbp-80], rax
    mov rax, 0
    mov [rbp-88], rax
    mov rax, [rbp-72]
    mov [rbp-96], rax
.wst135:
    mov rax, [rbp-88]
    push rax
    mov rax, [rbp-64]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend136
    mov rax, [rbp-96]
    push rax
    mov rax, [rbp-80]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else137
    mov rax, [rbp-64]
    mov [rbp-88], rax
    jmp .endif138
.else137:
.endif138:
    mov rax, [rbp-88]
    push rax
    mov rax, [rbp-64]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else139
    mov rax, [rbp-96]
    push rax
    pop rdi
    FN_CALL app_hl_notepad_line_ptr, 1
    mov [rbp-104], rax
    mov rax, [rbp-104]
    movzx rax, byte [rax]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else141
    mov rax, [rbp-24]
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
    mov rax, [rbp-32]
    push rax
    mov rax, 24
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 24
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-88]
    push rax
    mov rax, 14
    mov rcx, rax
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
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL render_text, 5
    jmp .endif142
.else141:
.endif142:
    mov rax, [rbp-96]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-96], rax
    mov rax, [rbp-88]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-88], rax
    jmp .endif140
.else139:
.endif140:
    jmp .wst135
.wend136:
    lea rax, [rel np_cursor_row]
    mov eax, [rax]
    mov [rbp-112], rax
    lea rax, [rel np_cursor_col]
    mov eax, [rax]
    mov [rbp-120], rax
    mov rax, [rbp-112]
    push rax
    mov rax, [rbp-72]
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov [rbp-128], rax
    mov rax, [rbp-128]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else143
    mov rax, [rbp-128]
    push rax
    mov rax, [rbp-64]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else145
    mov rax, [rbp-8]
    push rax
    mov rax, 4
    push rax
    mov rax, [rbp-120]
    push rax
    mov rax, 8
    mov rcx, rax
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 24
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-128]
    push rax
    mov rax, 14
    mov rcx, rax
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_caret_blink, 3
    jmp .endif146
.else145:
.endif146:
    jmp .endif144
.else143:
.endif144:
    lea rax, [rel np_menu_open]
    movzx rax, byte [rax]
    mov [rbp-136], rax
    mov rax, [rbp-136]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else147
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    push rax
    mov rax, 22
    push rax
    mov rax, 100
    push rax
    mov rax, 3
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
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
    push rax
    pop r8
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
    push rax
    pop r8
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
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_dropdown_item, 5
    jmp .endif148
.else147:
.endif148:
    mov rax, [rbp-136]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else149
    mov rax, [rbp-8]
    push rax
    mov rax, 48
    push rax
    mov rax, 22
    push rax
    mov rax, 110
    push rax
    mov rax, 2
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
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
    push rax
    pop r8
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
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_dropdown_item, 5
    jmp .endif150
.else149:
.endif150:
    lea rax, [rel np_save_dialog]
    movzx rax, byte [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else151
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
    mov rax, 40
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov [rbp-144], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 20
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
    mov rax, 40
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-144]
    push rax
    mov rax, 112
    push rax
    mov rax, 2241348
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL render_rect, 5
    mov rax, [rbp-24]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 20
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
    mov rax, 40
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-144]
    push rax
    mov rax, 1
    push rax
    mov rax, 4491434
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL render_rect, 5
    mov rax, [rbp-24]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 30
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
    mov rax, 46
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel app_hl_notepad_str7]
    push rax
    mov rax, 11197951
    push rax
    mov rax, 2241348
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL render_text, 5
    mov rax, [rbp-24]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 30
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
    mov rax, 66
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel app_hl_notepad_str8]
    push rax
    mov rax, 13421772
    push rax
    mov rax, 2241348
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL render_text, 5
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
    mov rax, 140
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov [rbp-152], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 104
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
    mov rax, 62
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-152]
    push rax
    mov rax, 18
    push rax
    mov rax, 16777215
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL render_rect, 5
    mov rax, [rbp-24]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 108
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
    mov rax, 65
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel np_saveas_buf]
    push rax
    mov rax, 0
    push rax
    mov rax, 16777215
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL render_text, 5
    mov rax, [rbp-24]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 30
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
    mov rax, 88
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel app_hl_notepad_str9]
    push rax
    mov rax, 13421772
    push rax
    mov rax, 2241348
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL render_text, 5
    mov rax, [rbp-24]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 104
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
    mov rax, 84
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-152]
    push rax
    mov rax, 18
    push rax
    mov rax, 16777215
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL render_rect, 5
    mov rax, [rbp-24]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 108
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
    mov rax, 87
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel np_saveloc_buf]
    push rax
    mov rax, 0
    push rax
    mov rax, 16777215
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL render_text, 5
    lea rax, [rel np_save_field]
    movzx rax, byte [rax]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else153
    lea rax, [rel np_saveas_cursor]
    mov eax, [rax]
    mov [rbp-160], rax
    mov rax, [rbp-8]
    push rax
    mov rax, 108
    push rax
    mov rax, [rbp-160]
    push rax
    mov rax, 8
    mov rcx, rax
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 64
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_caret_blink, 3
    jmp .endif154
.else153:
.endif154:
    lea rax, [rel np_save_field]
    movzx rax, byte [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else155
    lea rax, [rel np_saveloc_cursor]
    mov eax, [rax]
    mov [rbp-168], rax
    mov rax, [rbp-8]
    push rax
    mov rax, 108
    push rax
    mov rax, [rbp-168]
    push rax
    mov rax, 8
    mov rcx, rax
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 86
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_notepad_ui_caret_blink, 3
    jmp .endif156
.else155:
.endif156:
    mov rax, [rbp-24]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 30
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
    mov rax, 112
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel app_hl_notepad_str10]
    push rax
    mov rax, 8947848
    push rax
    mov rax, 2241348
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL render_text, 5
    jmp .endif152
.else151:
.endif152:
    lea rax, [rel np_save_done_msg]
    movzx rax, byte [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else157
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, 120
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
    mov [rbp-176], rax
    mov rax, [rbp-176]
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
    mov rax, 120
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
    FN_CALL render_rect, 5
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, 48
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
    lea rax, [rel app_hl_notepad_str11]
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
    FN_CALL render_text, 5
    jmp .endif158
.else157:
.endif158:
    lea rax, [rel np_save_done_msg]
    movzx rax, byte [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else159
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, 176
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
    mov [rbp-184], rax
    mov rax, [rbp-184]
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
    mov rax, 176
    push rax
    mov rax, 30
    push rax
    mov rax, 9445408
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL render_rect, 5
    mov rax, [rbp-184]
    push rax
    mov rax, 8
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
    lea rax, [rel app_hl_notepad_str12]
    push rax
    mov rax, 16777215
    push rax
    mov rax, 9445408
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL render_text, 5
    jmp .endif160
.else159:
.endif160:
.fn_end_130_app_hl_notepad_draw:
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
    sub rsp, 512
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
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else161
    lea rax, [rel np_save_done_msg]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_160_app_hl_notepad_click
    jmp .endif162
.else161:
.endif162:
    lea rax, [rel np_save_dialog]
    movzx rax, byte [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else163
    mov rax, [rbp-24]
    push rax
    mov rax, 62
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else165
    mov rax, [rbp-24]
    push rax
    mov rax, 82
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else167
    lea rax, [rel np_save_field]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_160_app_hl_notepad_click
    jmp .endif168
.else167:
.endif168:
    jmp .endif166
.else165:
.endif166:
    mov rax, [rbp-24]
    push rax
    mov rax, 84
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else169
    mov rax, [rbp-24]
    push rax
    mov rax, 104
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else171
    lea rax, [rel np_save_field]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_160_app_hl_notepad_click
    jmp .endif172
.else171:
.endif172:
    jmp .endif170
.else169:
.endif170:
    jmp .fn_end_160_app_hl_notepad_click
    jmp .endif164
.else163:
.endif164:
    lea rax, [rel np_menu_open]
    movzx rax, byte [rax]
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else173
    mov rax, [rbp-48]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else175
    mov rax, [rbp-24]
    push rax
    mov rax, 22
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov [rbp-56], rax
    mov rax, [rbp-56]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else177
    lea rax, [rel np_menu_open]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_160_app_hl_notepad_click
    jmp .endif178
.else177:
.endif178:
    mov rax, [rbp-56]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, 20
    mov rcx, rax
    pop rax
    cqo
    idiv rcx
    mov [rbp-64], rax
    lea rax, [rel np_menu_open]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-64]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else179
    FN_CALL app_hl_notepad_clear_buffer, 0
    jmp .fn_end_160_app_hl_notepad_click
    jmp .endif180
.else179:
.endif180:
    mov rax, [rbp-64]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else181
    FN_CALL app_hl_notepad_save_dialog_reset, 0
    jmp .fn_end_160_app_hl_notepad_click
    jmp .endif182
.else181:
.endif182:
    mov rax, [rbp-64]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else183
    jmp .fn_end_160_app_hl_notepad_click
    jmp .endif184
.else183:
.endif184:
    jmp .fn_end_160_app_hl_notepad_click
    jmp .endif176
.else175:
.endif176:
    mov rax, [rbp-48]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else185
    mov rax, [rbp-24]
    push rax
    mov rax, 22
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov [rbp-72], rax
    mov rax, [rbp-72]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else187
    lea rax, [rel np_menu_open]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_160_app_hl_notepad_click
    jmp .endif188
.else187:
.endif188:
    mov rax, [rbp-72]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, 20
    mov rcx, rax
    pop rax
    cqo
    idiv rcx
    mov [rbp-80], rax
    lea rax, [rel np_menu_open]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-80]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else189
    FN_CALL app_hl_notepad_clear_buffer, 0
    jmp .endif190
.else189:
.endif190:
    jmp .fn_end_160_app_hl_notepad_click
    jmp .endif186
.else185:
.endif186:
    lea rax, [rel np_menu_open]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_160_app_hl_notepad_click
    jmp .endif174
.else173:
.endif174:
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-40]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else191
    mov rax, [rbp-16]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov [rbp-88], rax
    mov rax, [rbp-88]
    push rax
    mov rax, 48
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else193
    lea rax, [rel np_menu_open]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_160_app_hl_notepad_click
    jmp .endif194
.else193:
.endif194:
    mov rax, [rbp-88]
    push rax
    mov rax, 96
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else195
    lea rax, [rel np_menu_open]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_160_app_hl_notepad_click
    jmp .endif196
.else195:
.endif196:
    jmp .fn_end_160_app_hl_notepad_click
    jmp .endif192
.else191:
.endif192:
    lea rax, [rel np_menu_open]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-40]
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov [rbp-96], rax
    mov rax, [rbp-96]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else197
    jmp .fn_end_160_app_hl_notepad_click
    jmp .endif198
.else197:
.endif198:
    mov rax, [rbp-96]
    push rax
    mov rax, 14
    mov rcx, rax
    pop rax
    cqo
    idiv rcx
    mov [rbp-104], rax
    mov rax, [rbp-104]
    push rax
    lea rax, [rel np_scroll_top]
    mov eax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-112], rax
    lea rax, [rel np_num_lines]
    mov eax, [rax]
    mov [rbp-120], rax
    mov rax, [rbp-112]
    push rax
    mov rax, [rbp-120]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else199
    mov rax, [rbp-120]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov [rbp-112], rax
    jmp .endif200
.else199:
.endif200:
    lea rax, [rel np_cursor_row]
    push rax
    mov rax, [rbp-112]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, [rbp-16]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov [rbp-128], rax
    mov rax, [rbp-128]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else201
    mov rax, 0
    mov [rbp-128], rax
    jmp .endif202
.else201:
.endif202:
    mov rax, [rbp-128]
    push rax
    mov rax, 8
    mov rcx, rax
    pop rax
    cqo
    idiv rcx
    mov [rbp-136], rax
    mov rax, [rbp-112]
    push rax
    pop rdi
    FN_CALL app_hl_notepad_len_ptr, 1
    mov eax, [rax]
    mov [rbp-144], rax
    mov rax, [rbp-136]
    push rax
    mov rax, [rbp-144]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else203
    mov rax, [rbp-144]
    mov [rbp-136], rax
    jmp .endif204
.else203:
.endif204:
    lea rax, [rel np_cursor_col]
    push rax
    mov rax, [rbp-136]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
.fn_end_160_app_hl_notepad_click:
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
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    mov rax, 255
    mov rcx, rax
    pop rax
    and rax, rcx
    mov [rbp-24], rax
    mov rax, [rbp-8]
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
    mov [rbp-32], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else205
    lea rax, [rel np_save_dialog]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_204_app_hl_notepad_saveas_key
    jmp .endif206
.else205:
.endif206:
    mov rax, [rbp-32]
    push rax
    mov rax, 13
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else207
    FN_CALL app_hl_notepad_save_dialog_commit, 0
    jmp .fn_end_204_app_hl_notepad_saveas_key
    jmp .endif208
.else207:
.endif208:
    mov rax, [rbp-32]
    push rax
    mov rax, 9
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else209
    lea rax, [rel np_save_field]
    movzx rax, byte [rax]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else211
    lea rax, [rel np_save_field]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_204_app_hl_notepad_saveas_key
    jmp .endif212
.else211:
.endif212:
    lea rax, [rel np_save_field]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_204_app_hl_notepad_saveas_key
    jmp .endif210
.else209:
.endif210:
    mov rax, [rbp-32]
    push rax
    mov rax, 8
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else213
    lea rax, [rel np_save_field]
    movzx rax, byte [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else215
    lea rax, [rel np_saveloc_cursor]
    mov eax, [rax]
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
    jz .else217
    jmp .fn_end_204_app_hl_notepad_saveas_key
    jmp .endif218
.else217:
.endif218:
    mov rax, [rbp-40]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov [rbp-40], rax
    lea rax, [rel np_saveloc_buf]
    push rax
    mov rax, [rbp-40]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel np_saveloc_cursor]
    push rax
    mov rax, [rbp-40]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .fn_end_204_app_hl_notepad_saveas_key
    jmp .endif216
.else215:
.endif216:
    lea rax, [rel np_saveas_cursor]
    mov eax, [rax]
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else219
    jmp .fn_end_204_app_hl_notepad_saveas_key
    jmp .endif220
.else219:
.endif220:
    mov rax, [rbp-48]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov [rbp-48], rax
    lea rax, [rel np_saveas_buf]
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel np_saveas_cursor]
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .fn_end_204_app_hl_notepad_saveas_key
    jmp .endif214
.else213:
.endif214:
    mov rax, [rbp-32]
    push rax
    mov rax, 32
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else221
    jmp .fn_end_204_app_hl_notepad_saveas_key
    jmp .endif222
.else221:
.endif222:
    mov rax, [rbp-32]
    push rax
    mov rax, 126
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else223
    jmp .fn_end_204_app_hl_notepad_saveas_key
    jmp .endif224
.else223:
.endif224:
    lea rax, [rel np_save_field]
    movzx rax, byte [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else225
    lea rax, [rel np_saveloc_cursor]
    mov eax, [rax]
    mov [rbp-56], rax
    mov rax, [rbp-56]
    push rax
    mov rax, 22
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else227
    jmp .fn_end_204_app_hl_notepad_saveas_key
    jmp .endif228
.else227:
.endif228:
    lea rax, [rel np_saveloc_buf]
    push rax
    mov rax, [rbp-56]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel np_saveloc_buf]
    push rax
    mov rax, [rbp-56]
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
    lea rax, [rel np_saveloc_cursor]
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .fn_end_204_app_hl_notepad_saveas_key
    jmp .endif226
.else225:
.endif226:
    lea rax, [rel np_saveas_cursor]
    mov eax, [rax]
    mov [rbp-64], rax
    mov rax, [rbp-64]
    push rax
    mov rax, 22
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else229
    jmp .fn_end_204_app_hl_notepad_saveas_key
    jmp .endif230
.else229:
.endif230:
    lea rax, [rel np_saveas_buf]
    push rax
    mov rax, [rbp-64]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    lea rax, [rel np_saveas_buf]
    push rax
    mov rax, [rbp-64]
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
    lea rax, [rel np_saveas_cursor]
    push rax
    mov rax, [rbp-64]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
.fn_end_204_app_hl_notepad_saveas_key:
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
    sub rsp, 512
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
    lea rax, [rel np_save_dialog]
    movzx rax, byte [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else231
    mov rax, [rbp-16]
    push rax
    pop rdi
    FN_CALL app_hl_notepad_saveas_key, 1
    jmp .fn_end_230_app_hl_notepad_key
    jmp .endif232
.else231:
.endif232:
    lea rax, [rel np_menu_open]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
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
    mov rax, [rbp-32]
    push rax
    mov rax, 200
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else233
    FN_CALL app_hl_notepad_arrow_up, 0
    jmp .fn_end_230_app_hl_notepad_key
    jmp .endif234
.else233:
.endif234:
    mov rax, [rbp-32]
    push rax
    mov rax, 208
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else235
    FN_CALL app_hl_notepad_arrow_down, 0
    jmp .fn_end_230_app_hl_notepad_key
    jmp .endif236
.else235:
.endif236:
    mov rax, [rbp-32]
    push rax
    mov rax, 203
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else237
    FN_CALL app_hl_notepad_arrow_left, 0
    jmp .fn_end_230_app_hl_notepad_key
    jmp .endif238
.else237:
.endif238:
    mov rax, [rbp-32]
    push rax
    mov rax, 205
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else239
    FN_CALL app_hl_notepad_arrow_right, 0
    jmp .fn_end_230_app_hl_notepad_key
    jmp .endif240
.else239:
.endif240:
    mov rax, [rbp-40]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else241
    jmp .fn_end_230_app_hl_notepad_key
    jmp .endif242
.else241:
.endif242:
    mov rax, [rbp-40]
    push rax
    mov rax, 8
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else243
    FN_CALL app_hl_notepad_do_backspace, 0
    jmp .fn_end_230_app_hl_notepad_key
    jmp .endif244
.else243:
.endif244:
    mov rax, [rbp-40]
    push rax
    mov rax, 13
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else245
    FN_CALL app_hl_notepad_do_enter, 0
    jmp .fn_end_230_app_hl_notepad_key
    jmp .endif246
.else245:
.endif246:
    mov rax, [rbp-40]
    push rax
    mov rax, 9
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else247
    FN_CALL app_hl_notepad_do_tab, 0
    jmp .fn_end_230_app_hl_notepad_key
    jmp .endif248
.else247:
.endif248:
    mov rax, [rbp-40]
    push rax
    mov rax, 32
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else249
    jmp .fn_end_230_app_hl_notepad_key
    jmp .endif250
.else249:
.endif250:
    mov rax, [rbp-40]
    push rax
    mov rax, 126
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else251
    jmp .fn_end_230_app_hl_notepad_key
    jmp .endif252
.else251:
.endif252:
    mov rax, [rbp-40]
    push rax
    pop rdi
    FN_CALL app_hl_notepad_insert_char, 1
.fn_end_230_app_hl_notepad_key:
    FN_END app_hl_notepad_key
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
app_hl_notepad_str0: db "File", 0
app_hl_notepad_str1: db "Edit", 0
app_hl_notepad_str2: db "New", 0
app_hl_notepad_str3: db "Save", 0
app_hl_notepad_str4: db "Close", 0
app_hl_notepad_str5: db "Select All", 0
app_hl_notepad_str6: db "Clear All", 0
app_hl_notepad_str7: db "Save As", 0
app_hl_notepad_str8: db "Name:", 0
app_hl_notepad_str9: db "Location:", 0
app_hl_notepad_str10: db "Tab=Field  Enter=Save  Esc=Cancel", 0
app_hl_notepad_str11: db "Saved!", 0
app_hl_notepad_str12: db "Location not found", 0
