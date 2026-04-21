; NexusHL generated — do not edit by hand
; app="Notepad" stack=8192
bits 64
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
extern np_save_total_bytes
extern np_saveas_83
extern np_saveas_buf
extern np_saveas_cursor
extern np_saved_content
extern np_scroll_top
extern render_rect
extern render_text
extern szCursor
extern szEditClear
extern szEditSelAll
extern szFileClose
extern szFileNew
extern szFileSave
extern szNoteMenuEdit
extern szNoteMenuFile
extern szSaveAsFilename
extern szSaveAsHint
extern szSaveAsTitle
extern szSavedMsg
section .text
global app_hl_notepad_line_ptr
app_hl_notepad_line_ptr:
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
    jmp .fn_end_0_app_hl_notepad_line_ptr
.fn_end_0_app_hl_notepad_line_ptr:
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
global app_hl_notepad_len_ptr
app_hl_notepad_len_ptr:
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
    jmp .fn_end_0_app_hl_notepad_len_ptr
.fn_end_0_app_hl_notepad_len_ptr:
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
global app_hl_notepad_clear_buffer
app_hl_notepad_clear_buffer:
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    mov rax, 0
    mov [rbp-16], rax
.wst1:
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
    jz .wend2
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
    jmp .wst1
.wend2:
    mov rax, 0
    mov [rbp-24], rax
.wst3:
    mov rax, [rbp-24]
    push rax
    mov rax, 32
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend4
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
    jmp .wst3
.wend4:
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
.fn_end_0_app_hl_notepad_clear_buffer:
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
global app_hl_notepad_ensure_visible
app_hl_notepad_ensure_visible:
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
    jz .else5
    lea rax, [rel np_scroll_top]
    push rax
    mov rax, [rbp-16]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .fn_end_4_app_hl_notepad_ensure_visible
    jmp .endif6
.else5:
.endif6:
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
    jz .else7
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
    jmp .endif8
.else7:
.endif8:
.fn_end_4_app_hl_notepad_ensure_visible:
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
global app_hl_notepad_insert_char
app_hl_notepad_insert_char:
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    lea rax, [rel np_cursor_row]
    mov eax, [rax]
    mov [rbp-24], rax
    lea rax, [rel np_cursor_col]
    mov eax, [rax]
    mov [rbp-32], rax
    mov rax, [rbp-24]
    push rax
    pop rdi
    call app_hl_notepad_len_ptr
    mov [rbp-40], rax
    mov rax, [rbp-40]
    mov eax, [rax]
    mov [rbp-48], rax
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
    jz .else9
    jmp .fn_end_8_app_hl_notepad_insert_char
    jmp .endif10
.else9:
.endif10:
    mov rax, [rbp-24]
    push rax
    pop rdi
    call app_hl_notepad_line_ptr
    mov [rbp-56], rax
    mov rax, [rbp-48]
    mov [rbp-64], rax
.wst11:
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .wend12
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
    jmp .wst11
.wend12:
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
.fn_end_8_app_hl_notepad_insert_char:
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
global app_hl_notepad_do_backspace
app_hl_notepad_do_backspace:
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
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else13
    mov rax, [rbp-24]
    push rax
    pop rdi
    call app_hl_notepad_line_ptr
    mov [rbp-32], rax
    mov rax, [rbp-24]
    push rax
    pop rdi
    call app_hl_notepad_len_ptr
    mov [rbp-40], rax
    mov rax, [rbp-40]
    mov eax, [rax]
    mov [rbp-48], rax
    mov rax, [rbp-16]
    mov [rbp-56], rax
.wst15:
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend16
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
    jmp .wst15
.wend16:
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
    jmp .fn_end_12_app_hl_notepad_do_backspace
    jmp .endif14
.else13:
.endif14:
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else17
    jmp .fn_end_12_app_hl_notepad_do_backspace
    jmp .endif18
.else17:
.endif18:
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
    call app_hl_notepad_line_ptr
    mov [rbp-72], rax
    mov rax, [rbp-64]
    push rax
    pop rdi
    call app_hl_notepad_len_ptr
    mov eax, [rax]
    mov [rbp-80], rax
    mov rax, [rbp-24]
    push rax
    pop rdi
    call app_hl_notepad_line_ptr
    mov [rbp-88], rax
    mov rax, [rbp-24]
    push rax
    pop rdi
    call app_hl_notepad_len_ptr
    mov eax, [rax]
    mov [rbp-96], rax
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
    jz .else19
    jmp .fn_end_12_app_hl_notepad_do_backspace
    jmp .endif20
.else19:
.endif20:
    mov rax, 0
    mov [rbp-104], rax
.wst21:
    mov rax, [rbp-104]
    push rax
    mov rax, [rbp-96]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend22
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
    jmp .wst21
.wend22:
    mov rax, [rbp-64]
    push rax
    pop rdi
    call app_hl_notepad_len_ptr
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
.wst23:
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
    jz .wend24
    mov rax, [rbp-120]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    pop rdi
    call app_hl_notepad_line_ptr
    mov [rbp-128], rax
    mov rax, [rbp-120]
    push rax
    pop rdi
    call app_hl_notepad_line_ptr
    mov [rbp-136], rax
    mov rax, 0
    mov [rbp-144], rax
.wst25:
    mov rax, [rbp-144]
    push rax
    mov rax, 80
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend26
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
    jmp .wst25
.wend26:
    mov rax, [rbp-120]
    push rax
    pop rdi
    call app_hl_notepad_len_ptr
    push rax
    mov rax, [rbp-120]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    pop rdi
    call app_hl_notepad_len_ptr
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
    jmp .wst23
.wend24:
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
    call app_hl_notepad_ensure_visible
.fn_end_12_app_hl_notepad_do_backspace:
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
global app_hl_notepad_do_enter
app_hl_notepad_do_enter:
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
    jz .else27
    jmp .fn_end_26_app_hl_notepad_do_enter
    jmp .endif28
.else27:
.endif28:
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
.wst29:
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-24]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .wend30
    mov rax, [rbp-40]
    push rax
    pop rdi
    call app_hl_notepad_line_ptr
    mov [rbp-48], rax
    mov rax, [rbp-40]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    pop rdi
    call app_hl_notepad_line_ptr
    mov [rbp-56], rax
    mov rax, 0
    mov [rbp-64], rax
.wst31:
    mov rax, [rbp-64]
    push rax
    mov rax, 80
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend32
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
    jmp .wst31
.wend32:
    mov rax, [rbp-40]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    pop rdi
    call app_hl_notepad_len_ptr
    push rax
    mov rax, [rbp-40]
    push rax
    pop rdi
    call app_hl_notepad_len_ptr
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
    jmp .wst29
.wend30:
    mov rax, [rbp-24]
    push rax
    pop rdi
    call app_hl_notepad_line_ptr
    mov [rbp-72], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    pop rdi
    call app_hl_notepad_line_ptr
    mov [rbp-80], rax
    mov rax, [rbp-24]
    push rax
    pop rdi
    call app_hl_notepad_len_ptr
    mov [rbp-88], rax
    mov rax, [rbp-88]
    mov eax, [rax]
    mov [rbp-96], rax
    mov rax, [rbp-32]
    mov [rbp-104], rax
    mov rax, 0
    mov [rbp-112], rax
.wst33:
    mov rax, [rbp-104]
    push rax
    mov rax, [rbp-96]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend34
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
    jmp .wst33
.wend34:
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
    call app_hl_notepad_len_ptr
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
    call app_hl_notepad_ensure_visible
.fn_end_26_app_hl_notepad_do_enter:
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
global app_hl_notepad_do_tab
app_hl_notepad_do_tab:
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    mov rax, 0
    mov [rbp-16], rax
.wst35:
    mov rax, [rbp-16]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend36
    mov rax, 32
    push rax
    pop rdi
    call app_hl_notepad_insert_char
    mov rax, [rbp-16]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-16], rax
    jmp .wst35
.wend36:
.fn_end_34_app_hl_notepad_do_tab:
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
global app_hl_notepad_arrow_up
app_hl_notepad_arrow_up:
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
    jz .else37
    jmp .fn_end_36_app_hl_notepad_arrow_up
    jmp .endif38
.else37:
.endif38:
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
    call app_hl_notepad_len_ptr
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
    jz .else39
    lea rax, [rel np_cursor_col]
    push rax
    mov rax, [rbp-24]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif40
.else39:
.endif40:
    call app_hl_notepad_ensure_visible
.fn_end_36_app_hl_notepad_arrow_up:
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
global app_hl_notepad_arrow_down
app_hl_notepad_arrow_down:
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
    jz .else41
    jmp .fn_end_40_app_hl_notepad_arrow_down
    jmp .endif42
.else41:
.endif42:
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
    call app_hl_notepad_len_ptr
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
    jz .else43
    lea rax, [rel np_cursor_col]
    push rax
    mov rax, [rbp-24]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif44
.else43:
.endif44:
    call app_hl_notepad_ensure_visible
.fn_end_40_app_hl_notepad_arrow_down:
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
global app_hl_notepad_arrow_left
app_hl_notepad_arrow_left:
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
    jz .else45
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
    jmp .fn_end_44_app_hl_notepad_arrow_left
    jmp .endif46
.else45:
.endif46:
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
    jz .else47
    jmp .fn_end_44_app_hl_notepad_arrow_left
    jmp .endif48
.else47:
.endif48:
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
    call app_hl_notepad_len_ptr
    mov eax, [rax]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    call app_hl_notepad_ensure_visible
.fn_end_44_app_hl_notepad_arrow_left:
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
global app_hl_notepad_arrow_right
app_hl_notepad_arrow_right:
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
    call app_hl_notepad_len_ptr
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
    jz .else49
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
    jmp .fn_end_48_app_hl_notepad_arrow_right
    jmp .endif50
.else49:
.endif50:
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
    jz .else51
    jmp .fn_end_48_app_hl_notepad_arrow_right
    jmp .endif52
.else51:
.endif52:
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
    call app_hl_notepad_ensure_visible
.fn_end_48_app_hl_notepad_arrow_right:
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
global app_hl_notepad_build_save_content
app_hl_notepad_build_save_content:
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
.wst53:
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend54
    mov rax, [rbp-24]
    push rax
    pop rdi
    call app_hl_notepad_line_ptr
    mov [rbp-40], rax
    mov rax, [rbp-24]
    push rax
    pop rdi
    call app_hl_notepad_len_ptr
    mov eax, [rax]
    mov [rbp-48], rax
    mov rax, 0
    mov [rbp-56], rax
.wst55:
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend56
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
    jmp .wst55
.wend56:
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
    jz .else57
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
    jmp .endif58
.else57:
.endif58:
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-24], rax
    jmp .wst53
.wend54:
    lea rax, [rel np_save_total_bytes]
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, [rbp-32]
    jmp .fn_end_52_app_hl_notepad_build_save_content
.fn_end_52_app_hl_notepad_build_save_content:
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
global app_hl_notepad_do_save_to
app_hl_notepad_do_save_to:
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    call app_hl_notepad_build_save_content
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
    call fat16_write_file
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
.fn_end_58_app_hl_notepad_do_save_to:
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
global app_hl_notepad_draw
app_hl_notepad_draw:
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
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call render_rect
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
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel szNoteMenuFile]
    push rax
    mov rax, 3355443
    push rax
    mov rax, 15263976
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call render_text
    mov rax, [rbp-24]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 52
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
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel szNoteMenuEdit]
    push rax
    mov rax, 3355443
    push rax
    mov rax, 15263976
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call render_text
    mov rax, [rbp-48]
    push rax
    mov rax, 24
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, 20
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
    jz .else59
    jmp .fn_end_58_app_hl_notepad_draw
    jmp .endif60
.else59:
.endif60:
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
    mov rax, 20
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
    call render_rect
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
    jz .else61
    jmp .fn_end_58_app_hl_notepad_draw
    jmp .endif62
.else61:
.endif62:
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
.wst63:
    mov rax, [rbp-88]
    push rax
    mov rax, [rbp-64]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend64
    mov rax, [rbp-96]
    push rax
    mov rax, [rbp-80]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else65
    mov rax, [rbp-64]
    mov [rbp-88], rax
    jmp .endif66
.else65:
.endif66:
    mov rax, [rbp-88]
    push rax
    mov rax, [rbp-64]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else67
    mov rax, [rbp-96]
    push rax
    pop rdi
    call app_hl_notepad_line_ptr
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
    jz .else69
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
    mov rax, 20
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
    call render_text
    jmp .endif70
.else69:
.endif70:
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
    jmp .endif68
.else67:
.endif68:
    jmp .wst63
.wend64:
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
    jz .else71
    mov rax, [rbp-128]
    push rax
    mov rax, [rbp-64]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else73
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
    mov rax, [rbp-32]
    push rax
    mov rax, 24
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 20
    mov rcx, rax
    pop rax
    add rax, rcx
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
    lea rax, [rel szCursor]
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
    call render_text
    jmp .endif74
.else73:
.endif74:
    jmp .endif72
.else71:
.endif72:
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
    jz .else75
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
    mov rax, 18
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 100
    push rax
    mov rax, 20
    push rax
    mov rax, 3
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
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call render_rect
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
    mov rax, 18
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 100
    push rax
    mov rax, 1
    push rax
    mov rax, 10066329
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call render_rect
    mov rax, [rbp-24]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
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
    mov rax, 18
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel szFileNew]
    push rax
    mov rax, 2236962
    push rax
    mov rax, 15790320
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call render_text
    mov rax, [rbp-24]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
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
    mov rax, 18
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 20
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel szFileSave]
    push rax
    mov rax, 2236962
    push rax
    mov rax, 15790320
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call render_text
    mov rax, [rbp-24]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
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
    mov rax, 18
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 20
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel szFileClose]
    push rax
    mov rax, 2236962
    push rax
    mov rax, 15790320
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call render_text
    jmp .endif76
.else75:
.endif76:
    mov rax, [rbp-136]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else77
    mov rax, [rbp-24]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 48
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
    mov rax, 18
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 110
    push rax
    mov rax, 20
    push rax
    mov rax, 2
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
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call render_rect
    mov rax, [rbp-24]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 48
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
    mov rax, 18
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 110
    push rax
    mov rax, 1
    push rax
    mov rax, 10066329
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call render_rect
    mov rax, [rbp-24]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 56
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
    mov rax, 18
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel szEditSelAll]
    push rax
    mov rax, 2236962
    push rax
    mov rax, 15790320
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call render_text
    mov rax, [rbp-24]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 56
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
    mov rax, 18
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 20
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel szEditClear]
    push rax
    mov rax, 2236962
    push rax
    mov rax, 15790320
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call render_text
    jmp .endif78
.else77:
.endif78:
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
    jz .else79
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
    mov rax, 80
    push rax
    mov rax, 2241348
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call render_rect
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
    call render_rect
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
    lea rax, [rel szSaveAsTitle]
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
    call render_text
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
    lea rax, [rel szSaveAsFilename]
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
    call render_text
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
    call render_rect
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
    call render_text
    lea rax, [rel np_saveas_cursor]
    mov eax, [rax]
    mov [rbp-160], rax
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
    lea rax, [rel szCursor]
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
    call render_text
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
    mov rax, 86
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rel szSaveAsHint]
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
    call render_text
    jmp .endif80
.else79:
.endif80:
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
    jz .else81
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
    mov [rbp-168], rax
    mov rax, [rbp-168]
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
    call render_rect
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
    lea rax, [rel szSavedMsg]
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
    call render_text
    jmp .endif82
.else81:
.endif82:
.fn_end_58_app_hl_notepad_draw:
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
global app_hl_notepad_click
app_hl_notepad_click:
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    push rbx
    push r12
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
    jz .else83
    lea rax, [rel np_save_done_msg]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_82_app_hl_notepad_click
    jmp .endif84
.else83:
.endif84:
    lea rax, [rel np_menu_open]
    movzx rax, byte [rax]
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
    jz .else85
    mov rax, [rbp-40]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else87
    mov rax, [rbp-24]
    push rax
    mov rax, 18
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else89
    lea rax, [rel np_menu_open]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_82_app_hl_notepad_click
    jmp .endif90
.else89:
.endif90:
    mov rax, [rbp-48]
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
    mov [rbp-56], rax
    lea rax, [rel np_menu_open]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-56]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else91
    call app_hl_notepad_clear_buffer
    jmp .fn_end_82_app_hl_notepad_click
    jmp .endif92
.else91:
.endif92:
    mov rax, [rbp-56]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else93
    lea rax, [rel np_open_entry]
    mov rax, [rax]
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
    jz .else95
    lea rax, [rel np_save_dialog]
    push rax
    mov rax, 1
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
    lea rax, [rel np_saveas_buf]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_82_app_hl_notepad_click
    jmp .endif96
.else95:
.endif96:
    call app_hl_notepad_build_save_content
    mov [rbp-72], rax
    mov rax, [rbp-64]
    push rax
    lea rax, [rel np_saved_content]
    push rax
    mov rax, [rbp-72]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call fat16_write_file
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
    jmp .fn_end_82_app_hl_notepad_click
    jmp .endif94
.else93:
.endif94:
    mov rax, [rbp-56]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else97
    jmp .fn_end_82_app_hl_notepad_click
    jmp .endif98
.else97:
.endif98:
    jmp .fn_end_82_app_hl_notepad_click
    jmp .endif88
.else87:
.endif88:
    mov rax, [rbp-40]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else99
    mov rax, [rbp-24]
    push rax
    mov rax, 18
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov [rbp-80], rax
    mov rax, [rbp-80]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else101
    lea rax, [rel np_menu_open]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_82_app_hl_notepad_click
    jmp .endif102
.else101:
.endif102:
    mov rax, [rbp-80]
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
    mov [rbp-88], rax
    lea rax, [rel np_menu_open]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-88]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else103
    call app_hl_notepad_clear_buffer
    jmp .endif104
.else103:
.endif104:
    jmp .fn_end_82_app_hl_notepad_click
    jmp .endif100
.else99:
.endif100:
    lea rax, [rel np_menu_open]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_82_app_hl_notepad_click
    jmp .endif86
.else85:
.endif86:
    mov rax, [rbp-24]
    push rax
    mov rax, 20
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else105
    mov rax, [rbp-16]
    push rax
    mov rax, 48
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else107
    lea rax, [rel np_menu_open]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_82_app_hl_notepad_click
    jmp .endif108
.else107:
.endif108:
    mov rax, [rbp-16]
    push rax
    mov rax, 96
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else109
    lea rax, [rel np_menu_open]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_82_app_hl_notepad_click
    jmp .endif110
.else109:
.endif110:
    jmp .fn_end_82_app_hl_notepad_click
    jmp .endif106
.else105:
.endif106:
    lea rax, [rel np_menu_open]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    mov rax, [rbp-24]
    push rax
    mov rax, 20
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
    jz .else111
    jmp .fn_end_82_app_hl_notepad_click
    jmp .endif112
.else111:
.endif112:
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
    jz .else113
    mov rax, [rbp-120]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov [rbp-112], rax
    jmp .endif114
.else113:
.endif114:
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
    jz .else115
    mov rax, 0
    mov [rbp-128], rax
    jmp .endif116
.else115:
.endif116:
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
    call app_hl_notepad_len_ptr
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
    jz .else117
    mov rax, [rbp-144]
    mov [rbp-136], rax
    jmp .endif118
.else117:
.endif118:
    lea rax, [rel np_cursor_col]
    push rax
    mov rax, [rbp-136]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
.fn_end_82_app_hl_notepad_click:
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
global app_hl_notepad_saveas_key
app_hl_notepad_saveas_key:
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
    jz .else119
    lea rax, [rel np_save_dialog]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], cl
    xor rax, rax
    jmp .fn_end_118_app_hl_notepad_saveas_key
    jmp .endif120
.else119:
.endif120:
    mov rax, [rbp-32]
    push rax
    mov rax, 13
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else121
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
    jmp .fn_end_118_app_hl_notepad_saveas_key
    jmp .endif124
.else123:
.endif124:
    lea rax, [rel np_saveas_buf]
    push rax
    lea rax, [rel np_saveas_83]
    push rax
    pop rsi
    pop rdi
    call filename_to_83
    lea rax, [rel np_saveas_83]
    push rax
    pop rdi
    call app_hl_notepad_do_save_to
    jmp .fn_end_118_app_hl_notepad_saveas_key
    jmp .endif122
.else121:
.endif122:
    mov rax, [rbp-32]
    push rax
    mov rax, 8
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else125
    lea rax, [rel np_saveas_cursor]
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
    jz .else127
    jmp .fn_end_118_app_hl_notepad_saveas_key
    jmp .endif128
.else127:
.endif128:
    mov rax, [rbp-40]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov [rbp-40], rax
    lea rax, [rel np_saveas_buf]
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
    lea rax, [rel np_saveas_cursor]
    push rax
    mov rax, [rbp-40]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .fn_end_118_app_hl_notepad_saveas_key
    jmp .endif126
.else125:
.endif126:
    mov rax, [rbp-32]
    push rax
    mov rax, 32
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else129
    jmp .fn_end_118_app_hl_notepad_saveas_key
    jmp .endif130
.else129:
.endif130:
    mov rax, [rbp-32]
    push rax
    mov rax, 126
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else131
    jmp .fn_end_118_app_hl_notepad_saveas_key
    jmp .endif132
.else131:
.endif132:
    lea rax, [rel np_saveas_cursor]
    mov eax, [rax]
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    mov rax, 22
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else133
    jmp .fn_end_118_app_hl_notepad_saveas_key
    jmp .endif134
.else133:
.endif134:
    lea rax, [rel np_saveas_buf]
    push rax
    mov rax, [rbp-48]
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
    lea rax, [rel np_saveas_cursor]
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
.fn_end_118_app_hl_notepad_saveas_key:
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
global app_hl_notepad_key
app_hl_notepad_key:
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
    jz .else135
    mov rax, [rbp-16]
    push rax
    pop rdi
    call app_hl_notepad_saveas_key
    jmp .fn_end_134_app_hl_notepad_key
    jmp .endif136
.else135:
.endif136:
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
    jz .else137
    call app_hl_notepad_arrow_up
    jmp .fn_end_134_app_hl_notepad_key
    jmp .endif138
.else137:
.endif138:
    mov rax, [rbp-32]
    push rax
    mov rax, 208
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else139
    call app_hl_notepad_arrow_down
    jmp .fn_end_134_app_hl_notepad_key
    jmp .endif140
.else139:
.endif140:
    mov rax, [rbp-32]
    push rax
    mov rax, 203
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else141
    call app_hl_notepad_arrow_left
    jmp .fn_end_134_app_hl_notepad_key
    jmp .endif142
.else141:
.endif142:
    mov rax, [rbp-32]
    push rax
    mov rax, 205
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else143
    call app_hl_notepad_arrow_right
    jmp .fn_end_134_app_hl_notepad_key
    jmp .endif144
.else143:
.endif144:
    mov rax, [rbp-40]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else145
    jmp .fn_end_134_app_hl_notepad_key
    jmp .endif146
.else145:
.endif146:
    mov rax, [rbp-40]
    push rax
    mov rax, 8
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else147
    call app_hl_notepad_do_backspace
    jmp .fn_end_134_app_hl_notepad_key
    jmp .endif148
.else147:
.endif148:
    mov rax, [rbp-40]
    push rax
    mov rax, 13
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else149
    call app_hl_notepad_do_enter
    jmp .fn_end_134_app_hl_notepad_key
    jmp .endif150
.else149:
.endif150:
    mov rax, [rbp-40]
    push rax
    mov rax, 9
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else151
    call app_hl_notepad_do_tab
    jmp .fn_end_134_app_hl_notepad_key
    jmp .endif152
.else151:
.endif152:
    mov rax, [rbp-40]
    push rax
    mov rax, 32
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else153
    jmp .fn_end_134_app_hl_notepad_key
    jmp .endif154
.else153:
.endif154:
    mov rax, [rbp-40]
    push rax
    mov rax, 126
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else155
    jmp .fn_end_134_app_hl_notepad_key
    jmp .endif156
.else155:
.endif156:
    mov rax, [rbp-40]
    push rax
    pop rdi
    call app_hl_notepad_insert_char
.fn_end_134_app_hl_notepad_key:
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
