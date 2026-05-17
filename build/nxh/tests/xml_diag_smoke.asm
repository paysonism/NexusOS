; NexusHL generated — do not edit by hand
; app="XmlDiagSmoke" stack=4096
FN_BEGIN app_hl_test_xml_diag_smoke_display_flags, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 64
    push rbx
    push r12
    mov rax, 24
    syscall
    jmp .fn_end_0_app_hl_test_xml_diag_smoke_display_flags
.fn_end_0_app_hl_test_xml_diag_smoke_display_flags:
    FN_END app_hl_test_xml_diag_smoke_display_flags
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_display_set_flags, 1, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_test_xml_diag_smoke_display_set_flags
.fn_end_0_app_hl_test_xml_diag_smoke_display_set_flags:
    FN_END app_hl_test_xml_diag_smoke_display_set_flags
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_display_set_mode, 3, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_test_xml_diag_smoke_display_set_mode
.fn_end_0_app_hl_test_xml_diag_smoke_display_set_mode:
    FN_END app_hl_test_xml_diag_smoke_display_set_mode
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_cursor_init, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 64
    push rbx
    push r12
    mov rax, 17
    syscall
    jmp .fn_end_0_app_hl_test_xml_diag_smoke_cursor_init
.fn_end_0_app_hl_test_xml_diag_smoke_cursor_init:
    FN_END app_hl_test_xml_diag_smoke_cursor_init
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_desktop_bg, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 64
    push rbx
    push r12
    mov rax, 26
    syscall
    jmp .fn_end_0_app_hl_test_xml_diag_smoke_desktop_bg
.fn_end_0_app_hl_test_xml_diag_smoke_desktop_bg:
    FN_END app_hl_test_xml_diag_smoke_desktop_bg
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_desktop_set_bg, 1, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_test_xml_diag_smoke_desktop_set_bg
.fn_end_0_app_hl_test_xml_diag_smoke_desktop_set_bg:
    FN_END app_hl_test_xml_diag_smoke_desktop_set_bg
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_display_native_width, 0, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_test_xml_diag_smoke_display_native_width
.fn_end_0_app_hl_test_xml_diag_smoke_display_native_width:
    FN_END app_hl_test_xml_diag_smoke_display_native_width
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_display_native_height, 0, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_test_xml_diag_smoke_display_native_height
.fn_end_0_app_hl_test_xml_diag_smoke_display_native_height:
    FN_END app_hl_test_xml_diag_smoke_display_native_height
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_display_current_width, 0, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_test_xml_diag_smoke_display_current_width
.fn_end_0_app_hl_test_xml_diag_smoke_display_current_width:
    FN_END app_hl_test_xml_diag_smoke_display_current_width
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_display_current_height, 0, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_test_xml_diag_smoke_display_current_height
.fn_end_0_app_hl_test_xml_diag_smoke_display_current_height:
    FN_END app_hl_test_xml_diag_smoke_display_current_height
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_xml_parse, 2, 0, FN_RET_SCALAR
FN_ARG 0, buf, FN_KIND_SCALAR
FN_ARG 1, len, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
    mov rsi, [rbp-16]
    mov rdi, [rbp-8]
    mov rax, 30
    syscall
    jmp .fn_end_0_app_hl_test_xml_diag_smoke_xml_parse
.fn_end_0_app_hl_test_xml_diag_smoke_xml_parse:
    FN_END app_hl_test_xml_diag_smoke_xml_parse
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_xml_root, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 64
    push rbx
    push r12
    mov rax, 31
    syscall
    jmp .fn_end_0_app_hl_test_xml_diag_smoke_xml_root
.fn_end_0_app_hl_test_xml_diag_smoke_xml_root:
    FN_END app_hl_test_xml_diag_smoke_xml_root
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_xml_tag, 1, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rdi, [rbp-8]
    mov rax, 32
    syscall
    jmp .fn_end_0_app_hl_test_xml_diag_smoke_xml_tag
.fn_end_0_app_hl_test_xml_diag_smoke_xml_tag:
    FN_END app_hl_test_xml_diag_smoke_xml_tag
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_xml_tag_name, 3, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
FN_ARG 1, out, FN_KIND_SCALAR
FN_ARG 2, max, FN_KIND_SCALAR
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
    mov rax, 33
    syscall
    jmp .fn_end_0_app_hl_test_xml_diag_smoke_xml_tag_name
.fn_end_0_app_hl_test_xml_diag_smoke_xml_tag_name:
    FN_END app_hl_test_xml_diag_smoke_xml_tag_name
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_xml_first_child, 1, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rdi, [rbp-8]
    mov rax, 34
    syscall
    jmp .fn_end_0_app_hl_test_xml_diag_smoke_xml_first_child
.fn_end_0_app_hl_test_xml_diag_smoke_xml_first_child:
    FN_END app_hl_test_xml_diag_smoke_xml_first_child
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_xml_next_sibling, 1, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rdi, [rbp-8]
    mov rax, 35
    syscall
    jmp .fn_end_0_app_hl_test_xml_diag_smoke_xml_next_sibling
.fn_end_0_app_hl_test_xml_diag_smoke_xml_next_sibling:
    FN_END app_hl_test_xml_diag_smoke_xml_next_sibling
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_xml_parent, 1, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rdi, [rbp-8]
    mov rax, 36
    syscall
    jmp .fn_end_0_app_hl_test_xml_diag_smoke_xml_parent
.fn_end_0_app_hl_test_xml_diag_smoke_xml_parent:
    FN_END app_hl_test_xml_diag_smoke_xml_parent
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_xml_attr, 5, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
FN_ARG 1, name, FN_KIND_SCALAR
FN_ARG 2, nlen, FN_KIND_SCALAR
FN_ARG 3, out, FN_KIND_SCALAR
FN_ARG 4, omax, FN_KIND_SCALAR
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
    mov rax, 37
    syscall
    jmp .fn_end_0_app_hl_test_xml_diag_smoke_xml_attr
.fn_end_0_app_hl_test_xml_diag_smoke_xml_attr:
    FN_END app_hl_test_xml_diag_smoke_xml_attr
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_xml_text, 3, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
FN_ARG 1, out, FN_KIND_SCALAR
FN_ARG 2, max, FN_KIND_SCALAR
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
    mov rax, 38
    syscall
    jmp .fn_end_0_app_hl_test_xml_diag_smoke_xml_text
.fn_end_0_app_hl_test_xml_diag_smoke_xml_text:
    FN_END app_hl_test_xml_diag_smoke_xml_text
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_xml_free, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 64
    push rbx
    push r12
    mov rax, 39
    syscall
    jmp .fn_end_0_app_hl_test_xml_diag_smoke_xml_free
.fn_end_0_app_hl_test_xml_diag_smoke_xml_free:
    FN_END app_hl_test_xml_diag_smoke_xml_free
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_xml_last_error, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 64
    push rbx
    push r12
    mov rax, 43
    syscall
    jmp .fn_end_0_app_hl_test_xml_diag_smoke_xml_last_error
.fn_end_0_app_hl_test_xml_diag_smoke_xml_last_error:
    FN_END app_hl_test_xml_diag_smoke_xml_last_error
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_xml_last_error_code, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 64
    push rbx
    push r12
    FN_CALL app_hl_test_xml_diag_smoke_xml_last_error, 0
    push rax
    mov rcx, 4294967295
    pop rax
    and rax, rcx
    jmp .fn_end_0_app_hl_test_xml_diag_smoke_xml_last_error_code
.fn_end_0_app_hl_test_xml_diag_smoke_xml_last_error_code:
    FN_END app_hl_test_xml_diag_smoke_xml_last_error_code
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_xml_last_error_offset, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 64
    push rbx
    push r12
    FN_CALL app_hl_test_xml_diag_smoke_xml_last_error, 0
    push rax
    mov rcx, 32
    pop rax
    shr rax, cl
    push rax
    mov rcx, 4294967295
    pop rax
    and rax, rcx
    jmp .fn_end_0_app_hl_test_xml_diag_smoke_xml_last_error_offset
.fn_end_0_app_hl_test_xml_diag_smoke_xml_last_error_offset:
    FN_END app_hl_test_xml_diag_smoke_xml_last_error_offset
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_xml_node_count, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 64
    push rbx
    push r12
    mov rax, 44
    syscall
    jmp .fn_end_0_app_hl_test_xml_diag_smoke_xml_node_count
.fn_end_0_app_hl_test_xml_diag_smoke_xml_node_count:
    FN_END app_hl_test_xml_diag_smoke_xml_node_count
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_xml_text_runs, 1, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rdi, [rbp-8]
    mov rax, 47
    syscall
    jmp .fn_end_0_app_hl_test_xml_diag_smoke_xml_text_runs
.fn_end_0_app_hl_test_xml_diag_smoke_xml_text_runs:
    FN_END app_hl_test_xml_diag_smoke_xml_text_runs
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_xml_text_run, 4, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
FN_ARG 1, index, FN_KIND_SCALAR
FN_ARG 2, out, FN_KIND_SCALAR
FN_ARG 3, max, FN_KIND_SCALAR
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
    mov rax, 48
    syscall
    jmp .fn_end_0_app_hl_test_xml_diag_smoke_xml_text_run
.fn_end_0_app_hl_test_xml_diag_smoke_xml_text_run:
    FN_END app_hl_test_xml_diag_smoke_xml_text_run
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_xml_namespace, 5, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
FN_ARG 1, prefix, FN_KIND_SCALAR
FN_ARG 2, prefix_len, FN_KIND_SCALAR
FN_ARG 3, out, FN_KIND_SCALAR
FN_ARG 4, max, FN_KIND_SCALAR
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
    mov rax, 49
    syscall
    jmp .fn_end_0_app_hl_test_xml_diag_smoke_xml_namespace
.fn_end_0_app_hl_test_xml_diag_smoke_xml_namespace:
    FN_END app_hl_test_xml_diag_smoke_xml_namespace
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_xml_node_namespace, 3, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
FN_ARG 1, out, FN_KIND_SCALAR
FN_ARG 2, max, FN_KIND_SCALAR
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
    mov rax, 50
    syscall
    jmp .fn_end_0_app_hl_test_xml_diag_smoke_xml_node_namespace
.fn_end_0_app_hl_test_xml_diag_smoke_xml_node_namespace:
    FN_END app_hl_test_xml_diag_smoke_xml_node_namespace
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_xml_entity_value, 4, 0, FN_RET_SCALAR
FN_ARG 0, name, FN_KIND_SCALAR
FN_ARG 1, name_len, FN_KIND_SCALAR
FN_ARG 2, out, FN_KIND_SCALAR
FN_ARG 3, max, FN_KIND_SCALAR
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
    mov rax, 51
    syscall
    jmp .fn_end_0_app_hl_test_xml_diag_smoke_xml_entity_value
.fn_end_0_app_hl_test_xml_diag_smoke_xml_entity_value:
    FN_END app_hl_test_xml_diag_smoke_xml_entity_value
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_xml_tag_is, 2, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
FN_ARG 1, tag_id, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else1
    mov rax, 0
    jmp .fn_end_0_app_hl_test_xml_diag_smoke_xml_tag_is
    jmp .endif2
.else1:
.endif2:
    mov rdi, [rbp-8]
    FN_CALL app_hl_test_xml_diag_smoke_xml_tag, 1
    push rax
    mov rcx, [rbp-16]
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else3
    mov rax, 1
    jmp .fn_end_0_app_hl_test_xml_diag_smoke_xml_tag_is
    jmp .endif4
.else3:
.endif4:
    mov rax, 0
    jmp .fn_end_0_app_hl_test_xml_diag_smoke_xml_tag_is
.fn_end_0_app_hl_test_xml_diag_smoke_xml_tag_is:
    FN_END app_hl_test_xml_diag_smoke_xml_tag_is
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_xml_same_tag, 2, 0, FN_RET_SCALAR
FN_ARG 0, a, FN_KIND_SCALAR
FN_ARG 1, b, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else5
    mov rax, 0
    jmp .fn_end_4_app_hl_test_xml_diag_smoke_xml_same_tag
    jmp .endif6
.else5:
.endif6:
    mov rax, [rbp-16]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else7
    mov rax, 0
    jmp .fn_end_4_app_hl_test_xml_diag_smoke_xml_same_tag
    jmp .endif8
.else7:
.endif8:
    mov rdi, [rbp-8]
    FN_CALL app_hl_test_xml_diag_smoke_xml_tag, 1
    push rax
    mov rdi, [rbp-16]
    FN_CALL app_hl_test_xml_diag_smoke_xml_tag, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else9
    mov rax, 1
    jmp .fn_end_4_app_hl_test_xml_diag_smoke_xml_same_tag
    jmp .endif10
.else9:
.endif10:
    mov rax, 0
    jmp .fn_end_4_app_hl_test_xml_diag_smoke_xml_same_tag
.fn_end_4_app_hl_test_xml_diag_smoke_xml_same_tag:
    FN_END app_hl_test_xml_diag_smoke_xml_same_tag
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_xml_first_child_safe, 1, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else11
    mov rax, -1
    jmp .fn_end_10_app_hl_test_xml_diag_smoke_xml_first_child_safe
    jmp .endif12
.else11:
.endif12:
    mov rdi, [rbp-8]
    FN_CALL app_hl_test_xml_diag_smoke_xml_first_child, 1
    jmp .fn_end_10_app_hl_test_xml_diag_smoke_xml_first_child_safe
.fn_end_10_app_hl_test_xml_diag_smoke_xml_first_child_safe:
    FN_END app_hl_test_xml_diag_smoke_xml_first_child_safe
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_xml_next_sibling_safe, 1, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else13
    mov rax, -1
    jmp .fn_end_12_app_hl_test_xml_diag_smoke_xml_next_sibling_safe
    jmp .endif14
.else13:
.endif14:
    mov rdi, [rbp-8]
    FN_CALL app_hl_test_xml_diag_smoke_xml_next_sibling, 1
    jmp .fn_end_12_app_hl_test_xml_diag_smoke_xml_next_sibling_safe
.fn_end_12_app_hl_test_xml_diag_smoke_xml_next_sibling_safe:
    FN_END app_hl_test_xml_diag_smoke_xml_next_sibling_safe
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_xml_next_child, 2, 0, FN_RET_SCALAR
FN_ARG 0, parent, FN_KIND_SCALAR
FN_ARG 1, child, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 96
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else15
    mov rax, -1
    jmp .fn_end_14_app_hl_test_xml_diag_smoke_xml_next_child
    jmp .endif16
.else15:
.endif16:
    mov rax, [rbp-16]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else17
    mov rax, -1
    jmp .fn_end_14_app_hl_test_xml_diag_smoke_xml_next_child
    jmp .endif18
.else17:
.endif18:
    mov rdi, [rbp-16]
    FN_CALL app_hl_test_xml_diag_smoke_xml_next_sibling, 1
    mov [rbp-32], rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else19
    mov rax, -1
    jmp .fn_end_14_app_hl_test_xml_diag_smoke_xml_next_child
    jmp .endif20
.else19:
.endif20:
    mov rdi, [rbp-32]
    FN_CALL app_hl_test_xml_diag_smoke_xml_parent, 1
    push rax
    mov rcx, [rbp-8]
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else21
    mov rax, -1
    jmp .fn_end_14_app_hl_test_xml_diag_smoke_xml_next_child
    jmp .endif22
.else21:
.endif22:
    mov rax, [rbp-32]
    jmp .fn_end_14_app_hl_test_xml_diag_smoke_xml_next_child
.fn_end_14_app_hl_test_xml_diag_smoke_xml_next_child:
    FN_END app_hl_test_xml_diag_smoke_xml_next_child
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_fail, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 64
    push rbx
    push r12
    lea rax, [rel app_hl_test_xml_diag_smoke_fail_msg]
    mov rdi, rax
    mov rax, 0
    syscall
.fn_end_22_app_hl_test_xml_diag_smoke_fail:
    FN_END app_hl_test_xml_diag_smoke_fail
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_test_xml_diag_smoke_smoke_draw, 1, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 144
    mov [rbp-8], rdi
    push rbx
    push r12
    lea rax, [rel app_hl_test_xml_diag_smoke_good_xml]
    push rax
    mov rax, 42
    mov rsi, rax
    pop rdi
    FN_CALL app_hl_test_xml_diag_smoke_xml_parse, 2
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else23
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif24
.else23:
.endif24:
    FN_CALL app_hl_test_xml_diag_smoke_xml_root, 0
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else25
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif26
.else25:
.endif26:
    FN_CALL app_hl_test_xml_diag_smoke_xml_node_count, 0
    push rax
    mov rcx, 2
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else27
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif28
.else27:
.endif28:
    mov rdi, [rbp-24]
    FN_CALL app_hl_test_xml_diag_smoke_xml_first_child_safe, 1
    mov [rbp-32], rax
    mov rax, [rbp-32]
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else29
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif30
.else29:
.endif30:
    mov rdi, [rbp-32]
    FN_CALL app_hl_test_xml_diag_smoke_xml_parent, 1
    push rax
    mov rcx, [rbp-24]
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else31
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif32
.else31:
.endif32:
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_test_xml_diag_smoke_xml_test_buf]
    push rax
    mov rax, 32
    mov rdx, rax
    pop rsi
    pop rdi
    FN_CALL app_hl_test_xml_diag_smoke_xml_text, 3
    push rax
    mov rcx, 4
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else33
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif34
.else33:
.endif34:
    lea rax, [rel app_hl_test_xml_diag_smoke_xml_test_buf]
    movzx rax, byte [rax]
    push rax
    mov rcx, 116
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else35
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif36
.else35:
.endif36:
    lea rax, [rel app_hl_test_xml_diag_smoke_xml_test_buf]
    push rax
    mov rcx, 3
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rcx, 116
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else37
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif38
.else37:
.endif38:
    lea rax, [rel app_hl_test_xml_diag_smoke_cdata_xml]
    push rax
    mov rax, 43
    mov rsi, rax
    pop rdi
    FN_CALL app_hl_test_xml_diag_smoke_xml_parse, 2
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else39
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif40
.else39:
.endif40:
    FN_CALL app_hl_test_xml_diag_smoke_xml_root, 0
    mov [rbp-40], rax
    mov rdi, [rbp-40]
    FN_CALL app_hl_test_xml_diag_smoke_xml_first_child_safe, 1
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    lea rax, [rel app_hl_test_xml_diag_smoke_xml_test_buf]
    push rax
    mov rax, 32
    mov rdx, rax
    pop rsi
    pop rdi
    FN_CALL app_hl_test_xml_diag_smoke_xml_text, 3
    push rax
    mov rcx, 5
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else41
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif42
.else41:
.endif42:
    lea rax, [rel app_hl_test_xml_diag_smoke_xml_test_buf]
    push rax
    mov rcx, 2
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rcx, 60
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else43
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif44
.else43:
.endif44:
    lea rax, [rel app_hl_test_xml_diag_smoke_bad_xml]
    push rax
    mov rax, 20
    mov rsi, rax
    pop rdi
    FN_CALL app_hl_test_xml_diag_smoke_xml_parse, 2
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else45
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif46
.else45:
.endif46:
    FN_CALL app_hl_test_xml_diag_smoke_xml_last_error_code, 0
    push rax
    mov rcx, 4
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else47
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif48
.else47:
.endif48:
    FN_CALL app_hl_test_xml_diag_smoke_xml_last_error_offset, 0
    push rax
    mov rcx, 0
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else49
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif50
.else49:
.endif50:
    lea rax, [rel app_hl_test_xml_diag_smoke_single_a]
    push rax
    mov rax, 4
    mov rsi, rax
    pop rdi
    FN_CALL app_hl_test_xml_diag_smoke_xml_parse, 2
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else51
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif52
.else51:
.endif52:
    FN_CALL app_hl_test_xml_diag_smoke_xml_root, 0
    mov [rbp-56], rax
    lea rax, [rel app_hl_test_xml_diag_smoke_single_b]
    push rax
    mov rax, 11
    mov rsi, rax
    pop rdi
    FN_CALL app_hl_test_xml_diag_smoke_xml_parse, 2
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else53
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif54
.else53:
.endif54:
    FN_CALL app_hl_test_xml_diag_smoke_xml_root, 0
    mov [rbp-64], rax
    mov rax, [rbp-64]
    push rax
    mov rcx, [rbp-56]
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else55
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif56
.else55:
.endif56:
    mov rax, [rbp-64]
    push rax
    lea rax, [rel app_hl_test_xml_diag_smoke_xml_test_buf]
    push rax
    mov rax, 32
    mov rdx, rax
    pop rsi
    pop rdi
    FN_CALL app_hl_test_xml_diag_smoke_xml_tag_name, 3
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else57
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif58
.else57:
.endif58:
    lea rax, [rel app_hl_test_xml_diag_smoke_xml_test_buf]
    movzx rax, byte [rax]
    push rax
    mov rcx, 98
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else59
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif60
.else59:
.endif60:
    lea rax, [rel app_hl_test_xml_diag_smoke_mixed_xml]
    push rax
    mov rax, 26
    mov rsi, rax
    pop rdi
    FN_CALL app_hl_test_xml_diag_smoke_xml_parse, 2
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else61
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif62
.else61:
.endif62:
    FN_CALL app_hl_test_xml_diag_smoke_xml_root, 0
    mov [rbp-72], rax
    mov rdi, [rbp-72]
    FN_CALL app_hl_test_xml_diag_smoke_xml_text_runs, 1
    push rax
    mov rcx, 3
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else63
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif64
.else63:
.endif64:
    mov rax, [rbp-72]
    push rax
    mov rax, 1
    push rax
    lea rax, [rel app_hl_test_xml_diag_smoke_xml_test_buf]
    push rax
    mov rax, 32
    mov rcx, rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_test_xml_diag_smoke_xml_text_run, 4
    push rax
    mov rcx, 3
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else65
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif66
.else65:
.endif66:
    lea rax, [rel app_hl_test_xml_diag_smoke_xml_test_buf]
    movzx rax, byte [rax]
    push rax
    mov rcx, 116
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else67
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif68
.else67:
.endif68:
    lea rax, [rel app_hl_test_xml_diag_smoke_xml_test_buf]
    push rax
    mov rcx, 1
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rcx, 119
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else69
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif70
.else69:
.endif70:
    lea rax, [rel app_hl_test_xml_diag_smoke_xml_test_buf]
    push rax
    mov rcx, 2
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rcx, 111
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else71
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif72
.else71:
.endif72:
    lea rax, [rel app_hl_test_xml_diag_smoke_ns_xml]
    push rax
    mov rax, 31
    mov rsi, rax
    pop rdi
    FN_CALL app_hl_test_xml_diag_smoke_xml_parse, 2
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else73
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif74
.else73:
.endif74:
    FN_CALL app_hl_test_xml_diag_smoke_xml_root, 0
    mov [rbp-80], rax
    mov rax, [rbp-80]
    push rax
    lea rax, [rel app_hl_test_xml_diag_smoke_xml_test_buf]
    push rax
    mov rax, 32
    mov rdx, rax
    pop rsi
    pop rdi
    FN_CALL app_hl_test_xml_diag_smoke_xml_tag_name, 3
    push rax
    mov rcx, 8
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else75
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif76
.else75:
.endif76:
    lea rax, [rel app_hl_test_xml_diag_smoke_xml_test_buf]
    push rax
    mov rcx, 3
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rcx, 58
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else77
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif78
.else77:
.endif78:
    mov rax, [rbp-80]
    push rax
    lea rax, [rel app_hl_test_xml_diag_smoke_xml_test_buf]
    push rax
    mov rax, 32
    mov rdx, rax
    pop rsi
    pop rdi
    FN_CALL app_hl_test_xml_diag_smoke_xml_node_namespace, 3
    push rax
    mov rcx, 7
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else79
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif80
.else79:
.endif80:
    lea rax, [rel app_hl_test_xml_diag_smoke_xml_test_buf]
    movzx rax, byte [rax]
    push rax
    mov rcx, 117
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else81
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif82
.else81:
.endif82:
    lea rax, [rel app_hl_test_xml_diag_smoke_xml_test_buf]
    push rax
    mov rcx, 6
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rcx, 103
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else83
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif84
.else83:
.endif84:
    mov rax, [rbp-80]
    push rax
    lea rax, [rel app_hl_test_xml_diag_smoke_prefix_svg]
    push rax
    mov rax, 3
    push rax
    lea rax, [rel app_hl_test_xml_diag_smoke_xml_test_buf]
    push rax
    mov rax, 32
    mov r8, rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_test_xml_diag_smoke_xml_namespace, 5
    push rax
    mov rcx, 7
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else85
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif86
.else85:
.endif86:
    lea rax, [rel app_hl_test_xml_diag_smoke_entity_xml]
    push rax
    mov rax, 60
    mov rsi, rax
    pop rdi
    FN_CALL app_hl_test_xml_diag_smoke_xml_parse, 2
    push rax
    mov rcx, 1
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else87
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif88
.else87:
.endif88:
    FN_CALL app_hl_test_xml_diag_smoke_xml_root, 0
    mov [rbp-88], rax
    mov rax, [rbp-88]
    push rax
    lea rax, [rel app_hl_test_xml_diag_smoke_xml_test_buf]
    push rax
    mov rax, 32
    mov rdx, rax
    pop rsi
    pop rdi
    FN_CALL app_hl_test_xml_diag_smoke_xml_text, 3
    push rax
    mov rcx, 7
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else89
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif90
.else89:
.endif90:
    lea rax, [rel app_hl_test_xml_diag_smoke_xml_test_buf]
    movzx rax, byte [rax]
    push rax
    mov rcx, 78
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else91
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif92
.else91:
.endif92:
    lea rax, [rel app_hl_test_xml_diag_smoke_entity_brand]
    push rax
    mov rax, 5
    push rax
    lea rax, [rel app_hl_test_xml_diag_smoke_xml_test_buf]
    push rax
    mov rax, 32
    mov rcx, rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_test_xml_diag_smoke_xml_entity_value, 4
    push rax
    mov rcx, 7
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else93
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif94
.else93:
.endif94:
    lea rax, [rel app_hl_test_xml_diag_smoke_xml_test_buf]
    push rax
    mov rcx, 6
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rcx, 83
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else95
    FN_CALL app_hl_test_xml_diag_smoke_fail, 0
    jmp .fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw
    jmp .endif96
.else95:
.endif96:
    lea rax, [rel app_hl_test_xml_diag_smoke_pass_msg]
    mov rdi, rax
    mov rax, 0
    syscall
    FN_CALL app_hl_test_xml_diag_smoke_xml_free, 0
.fn_end_22_app_hl_test_xml_diag_smoke_smoke_draw:
    FN_END app_hl_test_xml_diag_smoke_smoke_draw
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
app_hl_test_xml_diag_smoke_good_xml: db 60, 114, 111, 111, 116, 62, 60, 99, 104, 105, 108, 100, 32, 110, 97, 109, 101, 61, 34, 111, 107, 34, 62, 116, 101, 120, 116, 60, 47, 99, 104, 105, 108, 100, 62, 60, 47, 114, 111, 111, 116, 62, 0
app_hl_test_xml_diag_smoke_cdata_xml: db 60, 114, 111, 111, 116, 62, 60, 99, 111, 100, 101, 62, 60, 33, 91, 67, 68, 65, 84, 65, 91, 97, 32, 60, 32, 98, 93, 93, 62, 60, 47, 99, 111, 100, 101, 62, 60, 47, 114, 111, 111, 116, 62, 0
app_hl_test_xml_diag_smoke_bad_xml: db 60, 114, 111, 111, 116, 62, 60, 99, 104, 105, 108, 100, 62, 60, 47, 114, 111, 111, 116, 62, 0
app_hl_test_xml_diag_smoke_single_a: db 60, 97, 47, 62, 0
app_hl_test_xml_diag_smoke_single_b: db 60, 98, 62, 60, 99, 47, 62, 60, 47, 98, 62, 0
app_hl_test_xml_diag_smoke_mixed_xml: db 60, 112, 62, 111, 110, 101, 60, 98, 47, 62, 116, 119, 111, 60, 105, 47, 62, 116, 104, 114, 101, 101, 60, 47, 112, 62, 0
app_hl_test_xml_diag_smoke_ns_xml: db 60, 115, 118, 103, 58, 112, 97, 116, 104, 32, 120, 109, 108, 110, 115, 58, 115, 118, 103, 61, 34, 117, 114, 110, 58, 115, 118, 103, 34, 47, 62, 0
app_hl_test_xml_diag_smoke_entity_xml: db 60, 33, 68, 79, 67, 84, 89, 80, 69, 32, 100, 111, 99, 32, 91, 60, 33, 69, 78, 84, 73, 84, 89, 32, 98, 114, 97, 110, 100, 32, 34, 78, 101, 120, 117, 115, 79, 83, 34, 62, 93, 62, 60, 100, 111, 99, 62, 38, 98, 114, 97, 110, 100, 59, 60, 47, 100, 111, 99, 62, 0
app_hl_test_xml_diag_smoke_prefix_svg: db 115, 118, 103, 0
app_hl_test_xml_diag_smoke_entity_brand: db 98, 114, 97, 110, 100, 0
app_hl_test_xml_diag_smoke_pass_msg: db 91, 110, 120, 104, 108, 93, 32, 120, 109, 108, 32, 100, 105, 97, 103, 32, 112, 97, 115, 115, 0
app_hl_test_xml_diag_smoke_fail_msg: db 91, 110, 120, 104, 108, 93, 32, 120, 109, 108, 32, 100, 105, 97, 103, 32, 102, 97, 105, 108, 0
app_hl_test_xml_diag_smoke_xml_test_buf: times 32 db 0
