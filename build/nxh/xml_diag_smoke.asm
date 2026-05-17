; NexusHL generated — do not edit by hand
; app="XmlDiagSmoke" stack=4096
FN_BEGIN app_hl_xml_diag_smoke_display_flags, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    mov rax, 24
    syscall
    jmp .fn_end_0_app_hl_xml_diag_smoke_display_flags
.fn_end_0_app_hl_xml_diag_smoke_display_flags:
    FN_END app_hl_xml_diag_smoke_display_flags
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_xml_diag_smoke_display_set_flags, 1, 0, FN_RET_SCALAR
FN_ARG 0, flags, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    pop rdi
    mov rax, 25
    syscall
    jmp .fn_end_0_app_hl_xml_diag_smoke_display_set_flags
.fn_end_0_app_hl_xml_diag_smoke_display_set_flags:
    FN_END app_hl_xml_diag_smoke_display_set_flags
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_xml_diag_smoke_display_set_mode, 3, 0, FN_RET_SCALAR
FN_ARG 0, width, FN_KIND_SCALAR
FN_ARG 1, height, FN_KIND_SCALAR
FN_ARG 2, bpp, FN_KIND_SCALAR
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
    pop rdx
    pop rsi
    pop rdi
    mov rax, 16
    syscall
    jmp .fn_end_0_app_hl_xml_diag_smoke_display_set_mode
.fn_end_0_app_hl_xml_diag_smoke_display_set_mode:
    FN_END app_hl_xml_diag_smoke_display_set_mode
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_xml_diag_smoke_cursor_init, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    mov rax, 17
    syscall
    jmp .fn_end_0_app_hl_xml_diag_smoke_cursor_init
.fn_end_0_app_hl_xml_diag_smoke_cursor_init:
    FN_END app_hl_xml_diag_smoke_cursor_init
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_xml_diag_smoke_desktop_bg, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    mov rax, 26
    syscall
    jmp .fn_end_0_app_hl_xml_diag_smoke_desktop_bg
.fn_end_0_app_hl_xml_diag_smoke_desktop_bg:
    FN_END app_hl_xml_diag_smoke_desktop_bg
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_xml_diag_smoke_desktop_set_bg, 1, 0, FN_RET_SCALAR
FN_ARG 0, theme, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    pop rdi
    mov rax, 27
    syscall
    jmp .fn_end_0_app_hl_xml_diag_smoke_desktop_set_bg
.fn_end_0_app_hl_xml_diag_smoke_desktop_set_bg:
    FN_END app_hl_xml_diag_smoke_desktop_set_bg
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_xml_diag_smoke_display_native_width, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    mov rax, 28
    syscall
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 4294967295
    mov rcx, rax
    pop rax
    and rax, rcx
    jmp .fn_end_0_app_hl_xml_diag_smoke_display_native_width
.fn_end_0_app_hl_xml_diag_smoke_display_native_width:
    FN_END app_hl_xml_diag_smoke_display_native_width
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_xml_diag_smoke_display_native_height, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    mov rax, 28
    syscall
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 32
    mov rcx, rax
    pop rax
    shr rax, cl
    push rax
    mov rax, 4294967295
    mov rcx, rax
    pop rax
    and rax, rcx
    jmp .fn_end_0_app_hl_xml_diag_smoke_display_native_height
.fn_end_0_app_hl_xml_diag_smoke_display_native_height:
    FN_END app_hl_xml_diag_smoke_display_native_height
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_xml_diag_smoke_display_current_width, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    mov rax, 29
    syscall
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 4294967295
    mov rcx, rax
    pop rax
    and rax, rcx
    jmp .fn_end_0_app_hl_xml_diag_smoke_display_current_width
.fn_end_0_app_hl_xml_diag_smoke_display_current_width:
    FN_END app_hl_xml_diag_smoke_display_current_width
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_xml_diag_smoke_display_current_height, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    mov rax, 29
    syscall
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 32
    mov rcx, rax
    pop rax
    shr rax, cl
    push rax
    mov rax, 4294967295
    mov rcx, rax
    pop rax
    and rax, rcx
    jmp .fn_end_0_app_hl_xml_diag_smoke_display_current_height
.fn_end_0_app_hl_xml_diag_smoke_display_current_height:
    FN_END app_hl_xml_diag_smoke_display_current_height
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_xml_diag_smoke_xml_parse, 2, 0, FN_RET_SCALAR
FN_ARG 0, buf, FN_KIND_SCALAR
FN_ARG 1, len, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rsi
    pop rdi
    mov rax, 30
    syscall
    jmp .fn_end_0_app_hl_xml_diag_smoke_xml_parse
.fn_end_0_app_hl_xml_diag_smoke_xml_parse:
    FN_END app_hl_xml_diag_smoke_xml_parse
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_xml_diag_smoke_xml_root, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    mov rax, 31
    syscall
    jmp .fn_end_0_app_hl_xml_diag_smoke_xml_root
.fn_end_0_app_hl_xml_diag_smoke_xml_root:
    FN_END app_hl_xml_diag_smoke_xml_root
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_xml_diag_smoke_xml_tag, 1, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    pop rdi
    mov rax, 32
    syscall
    jmp .fn_end_0_app_hl_xml_diag_smoke_xml_tag
.fn_end_0_app_hl_xml_diag_smoke_xml_tag:
    FN_END app_hl_xml_diag_smoke_xml_tag
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_xml_diag_smoke_xml_tag_name, 3, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
FN_ARG 1, out, FN_KIND_SCALAR
FN_ARG 2, max, FN_KIND_SCALAR
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
    pop rdx
    pop rsi
    pop rdi
    mov rax, 33
    syscall
    jmp .fn_end_0_app_hl_xml_diag_smoke_xml_tag_name
.fn_end_0_app_hl_xml_diag_smoke_xml_tag_name:
    FN_END app_hl_xml_diag_smoke_xml_tag_name
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_xml_diag_smoke_xml_first_child, 1, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    pop rdi
    mov rax, 34
    syscall
    jmp .fn_end_0_app_hl_xml_diag_smoke_xml_first_child
.fn_end_0_app_hl_xml_diag_smoke_xml_first_child:
    FN_END app_hl_xml_diag_smoke_xml_first_child
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_xml_diag_smoke_xml_next_sibling, 1, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    pop rdi
    mov rax, 35
    syscall
    jmp .fn_end_0_app_hl_xml_diag_smoke_xml_next_sibling
.fn_end_0_app_hl_xml_diag_smoke_xml_next_sibling:
    FN_END app_hl_xml_diag_smoke_xml_next_sibling
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_xml_diag_smoke_xml_parent, 1, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    pop rdi
    mov rax, 36
    syscall
    jmp .fn_end_0_app_hl_xml_diag_smoke_xml_parent
.fn_end_0_app_hl_xml_diag_smoke_xml_parent:
    FN_END app_hl_xml_diag_smoke_xml_parent
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_xml_diag_smoke_xml_attr, 5, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
FN_ARG 1, name, FN_KIND_SCALAR
FN_ARG 2, nlen, FN_KIND_SCALAR
FN_ARG 3, out, FN_KIND_SCALAR
FN_ARG 4, omax, FN_KIND_SCALAR
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
    pop r10
    pop rdx
    pop rsi
    pop rdi
    mov rax, 37
    syscall
    jmp .fn_end_0_app_hl_xml_diag_smoke_xml_attr
.fn_end_0_app_hl_xml_diag_smoke_xml_attr:
    FN_END app_hl_xml_diag_smoke_xml_attr
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_xml_diag_smoke_xml_text, 3, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
FN_ARG 1, out, FN_KIND_SCALAR
FN_ARG 2, max, FN_KIND_SCALAR
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
    pop rdx
    pop rsi
    pop rdi
    mov rax, 38
    syscall
    jmp .fn_end_0_app_hl_xml_diag_smoke_xml_text
.fn_end_0_app_hl_xml_diag_smoke_xml_text:
    FN_END app_hl_xml_diag_smoke_xml_text
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_xml_diag_smoke_xml_free, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    mov rax, 39
    syscall
    jmp .fn_end_0_app_hl_xml_diag_smoke_xml_free
.fn_end_0_app_hl_xml_diag_smoke_xml_free:
    FN_END app_hl_xml_diag_smoke_xml_free
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_xml_diag_smoke_xml_last_error, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    mov rax, 43
    syscall
    jmp .fn_end_0_app_hl_xml_diag_smoke_xml_last_error
.fn_end_0_app_hl_xml_diag_smoke_xml_last_error:
    FN_END app_hl_xml_diag_smoke_xml_last_error
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_xml_diag_smoke_xml_last_error_code, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    FN_CALL app_hl_xml_diag_smoke_xml_last_error, 0
    push rax
    mov rax, 4294967295
    mov rcx, rax
    pop rax
    and rax, rcx
    jmp .fn_end_0_app_hl_xml_diag_smoke_xml_last_error_code
.fn_end_0_app_hl_xml_diag_smoke_xml_last_error_code:
    FN_END app_hl_xml_diag_smoke_xml_last_error_code
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_xml_diag_smoke_xml_last_error_offset, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    FN_CALL app_hl_xml_diag_smoke_xml_last_error, 0
    push rax
    mov rax, 32
    mov rcx, rax
    pop rax
    shr rax, cl
    push rax
    mov rax, 4294967295
    mov rcx, rax
    pop rax
    and rax, rcx
    jmp .fn_end_0_app_hl_xml_diag_smoke_xml_last_error_offset
.fn_end_0_app_hl_xml_diag_smoke_xml_last_error_offset:
    FN_END app_hl_xml_diag_smoke_xml_last_error_offset
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_xml_diag_smoke_xml_node_count, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    mov rax, 44
    syscall
    jmp .fn_end_0_app_hl_xml_diag_smoke_xml_node_count
.fn_end_0_app_hl_xml_diag_smoke_xml_node_count:
    FN_END app_hl_xml_diag_smoke_xml_node_count
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_xml_diag_smoke_smoke_draw, 1, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    lea rax, [rel app_hl_xml_diag_smoke_good_xml]
    push rax
    mov rax, 42
    push rax
    pop rsi
    pop rdi
    FN_CALL app_hl_xml_diag_smoke_xml_parse, 2
    FN_CALL app_hl_xml_diag_smoke_xml_node_count, 0
    lea rax, [rel app_hl_xml_diag_smoke_bad_xml]
    push rax
    mov rax, 20
    push rax
    pop rsi
    pop rdi
    FN_CALL app_hl_xml_diag_smoke_xml_parse, 2
    FN_CALL app_hl_xml_diag_smoke_xml_last_error_code, 0
    FN_CALL app_hl_xml_diag_smoke_xml_last_error_offset, 0
    FN_CALL app_hl_xml_diag_smoke_xml_free, 0
.fn_end_0_app_hl_xml_diag_smoke_smoke_draw:
    FN_END app_hl_xml_diag_smoke_smoke_draw
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
app_hl_xml_diag_smoke_good_xml: db 60, 114, 111, 111, 116, 62, 60, 99, 104, 105, 108, 100, 32, 110, 97, 109, 101, 61, 34, 111, 107, 34, 62, 116, 101, 120, 116, 60, 47, 99, 104, 105, 108, 100, 62, 60, 47, 114, 111, 111, 116, 62, 0
app_hl_xml_diag_smoke_bad_xml: db 60, 114, 111, 111, 116, 62, 60, 99, 104, 105, 108, 100, 62, 60, 47, 114, 111, 111, 116, 62, 0
