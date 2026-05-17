; NexusHL generated — do not edit by hand
; app="SvgSmoke" stack=4096
FN_BEGIN app_hl_svg_smoke_display_flags, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    mov rax, 24
    syscall
    jmp .fn_end_0_app_hl_svg_smoke_display_flags
.fn_end_0_app_hl_svg_smoke_display_flags:
    FN_END app_hl_svg_smoke_display_flags
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_display_set_flags, 1, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_svg_smoke_display_set_flags
.fn_end_0_app_hl_svg_smoke_display_set_flags:
    FN_END app_hl_svg_smoke_display_set_flags
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_display_set_mode, 3, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_svg_smoke_display_set_mode
.fn_end_0_app_hl_svg_smoke_display_set_mode:
    FN_END app_hl_svg_smoke_display_set_mode
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_cursor_init, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    mov rax, 17
    syscall
    jmp .fn_end_0_app_hl_svg_smoke_cursor_init
.fn_end_0_app_hl_svg_smoke_cursor_init:
    FN_END app_hl_svg_smoke_cursor_init
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_desktop_bg, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    mov rax, 26
    syscall
    jmp .fn_end_0_app_hl_svg_smoke_desktop_bg
.fn_end_0_app_hl_svg_smoke_desktop_bg:
    FN_END app_hl_svg_smoke_desktop_bg
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_desktop_set_bg, 1, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_svg_smoke_desktop_set_bg
.fn_end_0_app_hl_svg_smoke_desktop_set_bg:
    FN_END app_hl_svg_smoke_desktop_set_bg
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_display_native_width, 0, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_svg_smoke_display_native_width
.fn_end_0_app_hl_svg_smoke_display_native_width:
    FN_END app_hl_svg_smoke_display_native_width
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_display_native_height, 0, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_svg_smoke_display_native_height
.fn_end_0_app_hl_svg_smoke_display_native_height:
    FN_END app_hl_svg_smoke_display_native_height
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_display_current_width, 0, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_svg_smoke_display_current_width
.fn_end_0_app_hl_svg_smoke_display_current_width:
    FN_END app_hl_svg_smoke_display_current_width
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_display_current_height, 0, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_svg_smoke_display_current_height
.fn_end_0_app_hl_svg_smoke_display_current_height:
    FN_END app_hl_svg_smoke_display_current_height
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_desktop_background, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    FN_CALL app_hl_svg_smoke_desktop_bg, 0
    jmp .fn_end_0_app_hl_svg_smoke_svg_desktop_background
.fn_end_0_app_hl_svg_smoke_svg_desktop_background:
    FN_END app_hl_svg_smoke_svg_desktop_background
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_set_desktop_background, 1, 0, FN_RET_SCALAR
FN_ARG 0, svg_id, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_desktop_set_bg, 1
    jmp .fn_end_0_app_hl_svg_smoke_svg_set_desktop_background
.fn_end_0_app_hl_svg_smoke_svg_set_desktop_background:
    FN_END app_hl_svg_smoke_svg_set_desktop_background
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_raster_line, 5, 0, FN_RET_SCALAR
FN_ARG 0, x0, FN_KIND_SCALAR
FN_ARG 1, y0, FN_KIND_SCALAR
FN_ARG 2, x1, FN_KIND_SCALAR
FN_ARG 3, y1, FN_KIND_SCALAR
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
    pop r10
    pop rdx
    pop rsi
    pop rdi
    mov rax, 40
    syscall
    jmp .fn_end_0_app_hl_svg_smoke_raster_line
.fn_end_0_app_hl_svg_smoke_raster_line:
    FN_END app_hl_svg_smoke_raster_line
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_raster_circle, 4, 0, FN_RET_SCALAR
FN_ARG 0, cx, FN_KIND_SCALAR
FN_ARG 1, cy, FN_KIND_SCALAR
FN_ARG 2, r, FN_KIND_SCALAR
FN_ARG 3, color, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
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
    pop r10
    pop rdx
    pop rsi
    pop rdi
    mov rax, 41
    syscall
    jmp .fn_end_0_app_hl_svg_smoke_raster_circle
.fn_end_0_app_hl_svg_smoke_raster_circle:
    FN_END app_hl_svg_smoke_raster_circle
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_raster_triangle, 2, 0, FN_RET_SCALAR
FN_ARG 0, coords_ptr, FN_KIND_SCALAR
FN_ARG 1, color, FN_KIND_SCALAR
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
    mov rax, 42
    syscall
    jmp .fn_end_0_app_hl_svg_smoke_raster_triangle
.fn_end_0_app_hl_svg_smoke_raster_triangle:
    FN_END app_hl_svg_smoke_raster_triangle
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_xml_parse, 2, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_svg_smoke_xml_parse
.fn_end_0_app_hl_svg_smoke_xml_parse:
    FN_END app_hl_svg_smoke_xml_parse
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_xml_root, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    mov rax, 31
    syscall
    jmp .fn_end_0_app_hl_svg_smoke_xml_root
.fn_end_0_app_hl_svg_smoke_xml_root:
    FN_END app_hl_svg_smoke_xml_root
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_xml_tag, 1, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_svg_smoke_xml_tag
.fn_end_0_app_hl_svg_smoke_xml_tag:
    FN_END app_hl_svg_smoke_xml_tag
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_xml_tag_name, 3, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_svg_smoke_xml_tag_name
.fn_end_0_app_hl_svg_smoke_xml_tag_name:
    FN_END app_hl_svg_smoke_xml_tag_name
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_xml_first_child, 1, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_svg_smoke_xml_first_child
.fn_end_0_app_hl_svg_smoke_xml_first_child:
    FN_END app_hl_svg_smoke_xml_first_child
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_xml_next_sibling, 1, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_svg_smoke_xml_next_sibling
.fn_end_0_app_hl_svg_smoke_xml_next_sibling:
    FN_END app_hl_svg_smoke_xml_next_sibling
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_xml_parent, 1, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_svg_smoke_xml_parent
.fn_end_0_app_hl_svg_smoke_xml_parent:
    FN_END app_hl_svg_smoke_xml_parent
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_xml_attr, 5, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_svg_smoke_xml_attr
.fn_end_0_app_hl_svg_smoke_xml_attr:
    FN_END app_hl_svg_smoke_xml_attr
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_xml_text, 3, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_svg_smoke_xml_text
.fn_end_0_app_hl_svg_smoke_xml_text:
    FN_END app_hl_svg_smoke_xml_text
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_xml_free, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    mov rax, 39
    syscall
    jmp .fn_end_0_app_hl_svg_smoke_xml_free
.fn_end_0_app_hl_svg_smoke_xml_free:
    FN_END app_hl_svg_smoke_xml_free
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_xml_last_error, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    mov rax, 43
    syscall
    jmp .fn_end_0_app_hl_svg_smoke_xml_last_error
.fn_end_0_app_hl_svg_smoke_xml_last_error:
    FN_END app_hl_svg_smoke_xml_last_error
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_xml_last_error_code, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    FN_CALL app_hl_svg_smoke_xml_last_error, 0
    push rax
    mov rax, 4294967295
    mov rcx, rax
    pop rax
    and rax, rcx
    jmp .fn_end_0_app_hl_svg_smoke_xml_last_error_code
.fn_end_0_app_hl_svg_smoke_xml_last_error_code:
    FN_END app_hl_svg_smoke_xml_last_error_code
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_xml_last_error_offset, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    FN_CALL app_hl_svg_smoke_xml_last_error, 0
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
    jmp .fn_end_0_app_hl_svg_smoke_xml_last_error_offset
.fn_end_0_app_hl_svg_smoke_xml_last_error_offset:
    FN_END app_hl_svg_smoke_xml_last_error_offset
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_xml_node_count, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    mov rax, 44
    syscall
    jmp .fn_end_0_app_hl_svg_smoke_xml_node_count
.fn_end_0_app_hl_svg_smoke_xml_node_count:
    FN_END app_hl_svg_smoke_xml_node_count
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_is_ws, 1, 0, FN_RET_SCALAR
FN_ARG 0, c, FN_KIND_SCALAR
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
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else1
    mov rax, 1
    jmp .fn_end_0_app_hl_svg_smoke_svg_is_ws
    jmp .endif2
.else1:
.endif2:
    mov rax, [rbp-8]
    push rax
    mov rax, 9
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else3
    mov rax, 1
    jmp .fn_end_0_app_hl_svg_smoke_svg_is_ws
    jmp .endif4
.else3:
.endif4:
    mov rax, [rbp-8]
    push rax
    mov rax, 10
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else5
    mov rax, 1
    jmp .fn_end_0_app_hl_svg_smoke_svg_is_ws
    jmp .endif6
.else5:
.endif6:
    mov rax, [rbp-8]
    push rax
    mov rax, 13
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else7
    mov rax, 1
    jmp .fn_end_0_app_hl_svg_smoke_svg_is_ws
    jmp .endif8
.else7:
.endif8:
    mov rax, [rbp-8]
    push rax
    mov rax, 44
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else9
    mov rax, 1
    jmp .fn_end_0_app_hl_svg_smoke_svg_is_ws
    jmp .endif10
.else9:
.endif10:
    mov rax, 0
    jmp .fn_end_0_app_hl_svg_smoke_svg_is_ws
.fn_end_0_app_hl_svg_smoke_svg_is_ws:
    FN_END app_hl_svg_smoke_svg_is_ws
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_is_num_start, 1, 0, FN_RET_SCALAR
FN_ARG 0, c, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    mov rax, 45
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else11
    mov rax, 1
    jmp .fn_end_10_app_hl_svg_smoke_svg_is_num_start
    jmp .endif12
.else11:
.endif12:
    mov rax, [rbp-8]
    push rax
    mov rax, 43
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else13
    mov rax, 1
    jmp .fn_end_10_app_hl_svg_smoke_svg_is_num_start
    jmp .endif14
.else13:
.endif14:
    mov rax, [rbp-8]
    push rax
    mov rax, 48
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else15
    mov rax, [rbp-8]
    push rax
    mov rax, 57
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx rax, al
    test rax, rax
    jz .else17
    mov rax, 1
    jmp .fn_end_10_app_hl_svg_smoke_svg_is_num_start
    jmp .endif18
.else17:
.endif18:
    jmp .endif16
.else15:
.endif16:
    mov rax, 0
    jmp .fn_end_10_app_hl_svg_smoke_svg_is_num_start
.fn_end_10_app_hl_svg_smoke_svg_is_num_start:
    FN_END app_hl_svg_smoke_svg_is_num_start
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_attr, 3, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
FN_ARG 1, name, FN_KIND_SCALAR
FN_ARG 2, nlen, FN_KIND_SCALAR
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
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, 256
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_xml_attr, 5
    jmp .fn_end_18_app_hl_svg_smoke_svg_attr
.fn_end_18_app_hl_svg_smoke_svg_attr:
    FN_END app_hl_svg_smoke_svg_attr
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_parse_int, 2, 0, FN_RET_SCALAR
FN_ARG 0, buf, FN_KIND_SCALAR
FN_ARG 1, len, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
    mov rax, 0
    mov [rbp-32], rax
    mov rax, 1
    mov [rbp-40], rax
    mov rax, 0
    mov [rbp-48], rax
.wst19:
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-16]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend20
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_is_ws, 1
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else21
    jmp .wend20
    jmp .endif22
.else21:
.endif22:
    mov rax, [rbp-32]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-32], rax
    jmp .wst19
.wend20:
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-16]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else23
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 45
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else25
    mov rax, 1
    neg rax
    mov [rbp-40], rax
    mov rax, [rbp-32]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-32], rax
    jmp .endif26
.else25:
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 43
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else27
    mov rax, [rbp-32]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-32], rax
    jmp .endif28
.else27:
.endif28:
.endif26:
    jmp .endif24
.else23:
.endif24:
.wst29:
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-16]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend30
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    mov [rbp-56], rax
    mov rax, [rbp-56]
    push rax
    mov rax, 48
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else31
    jmp .wend30
    jmp .endif32
.else31:
.endif32:
    mov rax, [rbp-56]
    push rax
    mov rax, 57
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else33
    jmp .wend30
    jmp .endif34
.else33:
.endif34:
    mov rax, [rbp-48]
    push rax
    mov rax, 10
    mov rcx, rax
    pop rax
    imul rax, rcx
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, 48
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-48], rax
    mov rax, [rbp-32]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-32], rax
    jmp .wst29
.wend30:
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-40]
    mov rcx, rax
    pop rax
    imul rax, rcx
    jmp .fn_end_18_app_hl_svg_smoke_svg_parse_int
.fn_end_18_app_hl_svg_smoke_svg_parse_int:
    FN_END app_hl_svg_smoke_svg_parse_int
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_attr_len, 3, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
FN_ARG 1, name, FN_KIND_SCALAR
FN_ARG 2, nlen, FN_KIND_SCALAR
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
    FN_CALL app_hl_svg_smoke_svg_attr, 3
    jmp .fn_end_34_app_hl_svg_smoke_svg_attr_len
.fn_end_34_app_hl_svg_smoke_svg_attr_len:
    FN_END app_hl_svg_smoke_svg_attr_len
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_attr_int, 4, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
FN_ARG 1, name, FN_KIND_SCALAR
FN_ARG 2, nlen, FN_KIND_SCALAR
FN_ARG 3, defv, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
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
    FN_CALL app_hl_svg_smoke_svg_attr, 3
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
    jz .else35
    mov rax, [rbp-32]
    jmp .fn_end_34_app_hl_svg_smoke_svg_attr_int
    jmp .endif36
.else35:
.endif36:
    mov rax, [rbp-48]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else37
    mov rax, [rbp-32]
    jmp .fn_end_34_app_hl_svg_smoke_svg_attr_int
    jmp .endif38
.else37:
.endif38:
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-48]
    push rax
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_parse_int, 2
    jmp .fn_end_34_app_hl_svg_smoke_svg_attr_int
.fn_end_34_app_hl_svg_smoke_svg_attr_int:
    FN_END app_hl_svg_smoke_svg_attr_int
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_hex, 1, 0, FN_RET_SCALAR
FN_ARG 0, c, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    mov rax, 48
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else39
    mov rax, [rbp-8]
    push rax
    mov rax, 57
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx rax, al
    test rax, rax
    jz .else41
    mov rax, [rbp-8]
    push rax
    mov rax, 48
    mov rcx, rax
    pop rax
    sub rax, rcx
    jmp .fn_end_38_app_hl_svg_smoke_svg_hex
    jmp .endif42
.else41:
.endif42:
    jmp .endif40
.else39:
.endif40:
    mov rax, [rbp-8]
    push rax
    mov rax, 65
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else43
    mov rax, [rbp-8]
    push rax
    mov rax, 70
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx rax, al
    test rax, rax
    jz .else45
    mov rax, [rbp-8]
    push rax
    mov rax, 55
    mov rcx, rax
    pop rax
    sub rax, rcx
    jmp .fn_end_38_app_hl_svg_smoke_svg_hex
    jmp .endif46
.else45:
.endif46:
    jmp .endif44
.else43:
.endif44:
    mov rax, [rbp-8]
    push rax
    mov rax, 97
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else47
    mov rax, [rbp-8]
    push rax
    mov rax, 102
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx rax, al
    test rax, rax
    jz .else49
    mov rax, [rbp-8]
    push rax
    mov rax, 87
    mov rcx, rax
    pop rax
    sub rax, rcx
    jmp .fn_end_38_app_hl_svg_smoke_svg_hex
    jmp .endif50
.else49:
.endif50:
    jmp .endif48
.else47:
.endif48:
    mov rax, 1
    neg rax
    jmp .fn_end_38_app_hl_svg_smoke_svg_hex
.fn_end_38_app_hl_svg_smoke_svg_hex:
    FN_END app_hl_svg_smoke_svg_hex
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_parse_color, 2, 0, FN_RET_SCALAR
FN_ARG 0, buf, FN_KIND_SCALAR
FN_ARG 1, len, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
    mov rax, [rbp-16]
    push rax
    mov rax, 3
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else51
    mov rax, [rbp-8]
    movzx rax, byte [rax]
    push rax
    mov rax, 114
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else53
    mov rax, [rbp-8]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 101
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else55
    mov rax, [rbp-8]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 100
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else57
    mov rax, 16711680
    jmp .fn_end_50_app_hl_svg_smoke_svg_parse_color
    jmp .endif58
.else57:
.endif58:
    jmp .endif56
.else55:
.endif56:
    jmp .endif54
.else53:
.endif54:
    jmp .endif52
.else51:
.endif52:
    mov rax, [rbp-16]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else59
    mov rax, [rbp-8]
    movzx rax, byte [rax]
    push rax
    mov rax, 110
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else61
    mov rax, [rbp-8]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 111
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else63
    mov rax, [rbp-8]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 110
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else65
    mov rax, [rbp-8]
    push rax
    mov rax, 3
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 101
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else67
    mov rax, 1
    neg rax
    jmp .fn_end_50_app_hl_svg_smoke_svg_parse_color
    jmp .endif68
.else67:
.endif68:
    jmp .endif66
.else65:
.endif66:
    jmp .endif64
.else63:
.endif64:
    jmp .endif62
.else61:
.endif62:
    mov rax, [rbp-8]
    movzx rax, byte [rax]
    push rax
    mov rax, 98
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else69
    mov rax, [rbp-8]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 108
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else71
    mov rax, [rbp-8]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 117
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else73
    mov rax, [rbp-8]
    push rax
    mov rax, 3
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 101
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else75
    mov rax, 255
    jmp .fn_end_50_app_hl_svg_smoke_svg_parse_color
    jmp .endif76
.else75:
.endif76:
    jmp .endif74
.else73:
.endif74:
    jmp .endif72
.else71:
.endif72:
    jmp .endif70
.else69:
.endif70:
    jmp .endif60
.else59:
.endif60:
    mov rax, [rbp-16]
    push rax
    mov rax, 5
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else77
    mov rax, [rbp-8]
    movzx rax, byte [rax]
    push rax
    mov rax, 98
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else79
    mov rax, [rbp-8]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 108
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else81
    mov rax, [rbp-8]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 97
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else83
    mov rax, [rbp-8]
    push rax
    mov rax, 3
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 99
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else85
    mov rax, [rbp-8]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 107
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else87
    mov rax, 0
    jmp .fn_end_50_app_hl_svg_smoke_svg_parse_color
    jmp .endif88
.else87:
.endif88:
    jmp .endif86
.else85:
.endif86:
    jmp .endif84
.else83:
.endif84:
    jmp .endif82
.else81:
.endif82:
    jmp .endif80
.else79:
.endif80:
    mov rax, [rbp-8]
    movzx rax, byte [rax]
    push rax
    mov rax, 119
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else89
    mov rax, [rbp-8]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 104
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else91
    mov rax, [rbp-8]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 105
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else93
    mov rax, [rbp-8]
    push rax
    mov rax, 3
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 116
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else95
    mov rax, [rbp-8]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 101
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else97
    mov rax, 16777215
    jmp .fn_end_50_app_hl_svg_smoke_svg_parse_color
    jmp .endif98
.else97:
.endif98:
    jmp .endif96
.else95:
.endif96:
    jmp .endif94
.else93:
.endif94:
    jmp .endif92
.else91:
.endif92:
    jmp .endif90
.else89:
.endif90:
    mov rax, [rbp-8]
    movzx rax, byte [rax]
    push rax
    mov rax, 103
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else99
    mov rax, [rbp-8]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 114
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else101
    mov rax, [rbp-8]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 101
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else103
    mov rax, [rbp-8]
    push rax
    mov rax, 3
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 101
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else105
    mov rax, [rbp-8]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 110
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else107
    mov rax, 32768
    jmp .fn_end_50_app_hl_svg_smoke_svg_parse_color
    jmp .endif108
.else107:
.endif108:
    jmp .endif106
.else105:
.endif106:
    jmp .endif104
.else103:
.endif104:
    jmp .endif102
.else101:
.endif102:
    jmp .endif100
.else99:
.endif100:
    jmp .endif78
.else77:
.endif78:
    mov rax, [rbp-16]
    push rax
    mov rax, 10
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else109
    mov rax, [rbp-8]
    movzx rax, byte [rax]
    push rax
    mov rax, 116
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else111
    mov rax, [rbp-8]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 114
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else113
    mov rax, [rbp-8]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 97
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else115
    mov rax, [rbp-8]
    push rax
    mov rax, 3
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 110
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else117
    mov rax, [rbp-8]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 115
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else119
    mov rax, [rbp-8]
    push rax
    mov rax, 5
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 112
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else121
    mov rax, [rbp-8]
    push rax
    mov rax, 6
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 97
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else123
    mov rax, [rbp-8]
    push rax
    mov rax, 7
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 114
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else125
    mov rax, [rbp-8]
    push rax
    mov rax, 8
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 101
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else127
    mov rax, [rbp-8]
    push rax
    mov rax, 9
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 110
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else129
    mov rax, 1
    neg rax
    jmp .fn_end_50_app_hl_svg_smoke_svg_parse_color
    jmp .endif130
.else129:
.endif130:
    jmp .endif128
.else127:
.endif128:
    jmp .endif126
.else125:
.endif126:
    jmp .endif124
.else123:
.endif124:
    jmp .endif122
.else121:
.endif122:
    jmp .endif120
.else119:
.endif120:
    jmp .endif118
.else117:
.endif118:
    jmp .endif116
.else115:
.endif116:
    jmp .endif114
.else113:
.endif114:
    jmp .endif112
.else111:
.endif112:
    jmp .endif110
.else109:
.endif110:
    mov rax, [rbp-16]
    push rax
    mov rax, 10
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else131
    mov rax, [rbp-8]
    movzx rax, byte [rax]
    push rax
    mov rax, 114
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else133
    mov rax, [rbp-8]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 103
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else135
    mov rax, [rbp-8]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 98
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else137
    mov rax, [rbp-8]
    push rax
    mov rax, 3
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 40
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else139
    mov rax, 4
    mov [rbp-32], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-40], rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-48], rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-56], rax
    mov rax, [rbp-40]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else141
    mov rax, 0
    mov [rbp-40], rax
    jmp .endif142
.else141:
.endif142:
    mov rax, [rbp-48]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else143
    mov rax, 0
    mov [rbp-48], rax
    jmp .endif144
.else143:
.endif144:
    mov rax, [rbp-56]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else145
    mov rax, 0
    mov [rbp-56], rax
    jmp .endif146
.else145:
.endif146:
    mov rax, [rbp-40]
    push rax
    mov rax, 255
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else147
    mov rax, 255
    mov [rbp-40], rax
    jmp .endif148
.else147:
.endif148:
    mov rax, [rbp-48]
    push rax
    mov rax, 255
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else149
    mov rax, 255
    mov [rbp-48], rax
    jmp .endif150
.else149:
.endif150:
    mov rax, [rbp-56]
    push rax
    mov rax, 255
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else151
    mov rax, 255
    mov [rbp-56], rax
    jmp .endif152
.else151:
.endif152:
    mov rax, [rbp-40]
    push rax
    mov rax, 16
    mov rcx, rax
    pop rax
    shl rax, cl
    push rax
    mov rax, [rbp-48]
    push rax
    mov rax, 8
    mov rcx, rax
    pop rax
    shl rax, cl
    mov rcx, rax
    pop rax
    or rax, rcx
    push rax
    mov rax, [rbp-56]
    mov rcx, rax
    pop rax
    or rax, rcx
    jmp .fn_end_50_app_hl_svg_smoke_svg_parse_color
    jmp .endif140
.else139:
.endif140:
    jmp .endif138
.else137:
.endif138:
    jmp .endif136
.else135:
.endif136:
    jmp .endif134
.else133:
.endif134:
    jmp .endif132
.else131:
.endif132:
    mov rax, [rbp-16]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else153
    mov rax, [rbp-8]
    movzx rax, byte [rax]
    push rax
    mov rax, 35
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else155
    mov rax, 1
    neg rax
    jmp .fn_end_50_app_hl_svg_smoke_svg_parse_color
    jmp .endif156
.else155:
.endif156:
    mov rax, [rbp-8]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_hex, 1
    mov [rbp-64], rax
    mov rax, [rbp-8]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_hex, 1
    mov [rbp-72], rax
    mov rax, [rbp-8]
    push rax
    mov rax, 3
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_hex, 1
    mov [rbp-80], rax
    mov rax, [rbp-64]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else157
    mov rax, 1
    neg rax
    jmp .fn_end_50_app_hl_svg_smoke_svg_parse_color
    jmp .endif158
.else157:
.endif158:
    mov rax, [rbp-72]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else159
    mov rax, 1
    neg rax
    jmp .fn_end_50_app_hl_svg_smoke_svg_parse_color
    jmp .endif160
.else159:
.endif160:
    mov rax, [rbp-80]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else161
    mov rax, 1
    neg rax
    jmp .fn_end_50_app_hl_svg_smoke_svg_parse_color
    jmp .endif162
.else161:
.endif162:
    mov rax, [rbp-64]
    push rax
    mov rax, 20
    mov rcx, rax
    pop rax
    shl rax, cl
    push rax
    mov rax, [rbp-64]
    push rax
    mov rax, 16
    mov rcx, rax
    pop rax
    shl rax, cl
    mov rcx, rax
    pop rax
    or rax, rcx
    push rax
    mov rax, [rbp-72]
    push rax
    mov rax, 12
    mov rcx, rax
    pop rax
    shl rax, cl
    mov rcx, rax
    pop rax
    or rax, rcx
    push rax
    mov rax, [rbp-72]
    push rax
    mov rax, 8
    mov rcx, rax
    pop rax
    shl rax, cl
    mov rcx, rax
    pop rax
    or rax, rcx
    push rax
    mov rax, [rbp-80]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    shl rax, cl
    mov rcx, rax
    pop rax
    or rax, rcx
    push rax
    mov rax, [rbp-80]
    mov rcx, rax
    pop rax
    or rax, rcx
    jmp .fn_end_50_app_hl_svg_smoke_svg_parse_color
    jmp .endif154
.else153:
.endif154:
    mov rax, [rbp-16]
    push rax
    mov rax, 7
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else163
    mov rax, 1
    neg rax
    jmp .fn_end_50_app_hl_svg_smoke_svg_parse_color
    jmp .endif164
.else163:
.endif164:
    mov rax, [rbp-8]
    movzx rax, byte [rax]
    push rax
    mov rax, 35
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else165
    mov rax, 1
    neg rax
    jmp .fn_end_50_app_hl_svg_smoke_svg_parse_color
    jmp .endif166
.else165:
.endif166:
    mov rax, [rbp-8]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_hex, 1
    mov [rbp-88], rax
    mov rax, [rbp-8]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_hex, 1
    mov [rbp-96], rax
    mov rax, [rbp-8]
    push rax
    mov rax, 3
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_hex, 1
    mov [rbp-104], rax
    mov rax, [rbp-8]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_hex, 1
    mov [rbp-112], rax
    mov rax, [rbp-8]
    push rax
    mov rax, 5
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_hex, 1
    mov [rbp-120], rax
    mov rax, [rbp-8]
    push rax
    mov rax, 6
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_hex, 1
    mov [rbp-128], rax
    mov rax, [rbp-88]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else167
    mov rax, 1
    neg rax
    jmp .fn_end_50_app_hl_svg_smoke_svg_parse_color
    jmp .endif168
.else167:
.endif168:
    mov rax, [rbp-96]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else169
    mov rax, 1
    neg rax
    jmp .fn_end_50_app_hl_svg_smoke_svg_parse_color
    jmp .endif170
.else169:
.endif170:
    mov rax, [rbp-104]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else171
    mov rax, 1
    neg rax
    jmp .fn_end_50_app_hl_svg_smoke_svg_parse_color
    jmp .endif172
.else171:
.endif172:
    mov rax, [rbp-112]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else173
    mov rax, 1
    neg rax
    jmp .fn_end_50_app_hl_svg_smoke_svg_parse_color
    jmp .endif174
.else173:
.endif174:
    mov rax, [rbp-120]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else175
    mov rax, 1
    neg rax
    jmp .fn_end_50_app_hl_svg_smoke_svg_parse_color
    jmp .endif176
.else175:
.endif176:
    mov rax, [rbp-128]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else177
    mov rax, 1
    neg rax
    jmp .fn_end_50_app_hl_svg_smoke_svg_parse_color
    jmp .endif178
.else177:
.endif178:
    mov rax, [rbp-88]
    push rax
    mov rax, 20
    mov rcx, rax
    pop rax
    shl rax, cl
    push rax
    mov rax, [rbp-96]
    push rax
    mov rax, 16
    mov rcx, rax
    pop rax
    shl rax, cl
    mov rcx, rax
    pop rax
    or rax, rcx
    push rax
    mov rax, [rbp-104]
    push rax
    mov rax, 12
    mov rcx, rax
    pop rax
    shl rax, cl
    mov rcx, rax
    pop rax
    or rax, rcx
    push rax
    mov rax, [rbp-112]
    push rax
    mov rax, 8
    mov rcx, rax
    pop rax
    shl rax, cl
    mov rcx, rax
    pop rax
    or rax, rcx
    push rax
    mov rax, [rbp-120]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    shl rax, cl
    mov rcx, rax
    pop rax
    or rax, rcx
    push rax
    mov rax, [rbp-128]
    mov rcx, rax
    pop rax
    or rax, rcx
    jmp .fn_end_50_app_hl_svg_smoke_svg_parse_color
.fn_end_50_app_hl_svg_smoke_svg_parse_color:
    FN_END app_hl_svg_smoke_svg_parse_color
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_attr_color, 4, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
FN_ARG 1, name, FN_KIND_SCALAR
FN_ARG 2, nlen, FN_KIND_SCALAR
FN_ARG 3, defv, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
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
    FN_CALL app_hl_svg_smoke_svg_attr, 3
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
    jz .else179
    mov rax, [rbp-32]
    jmp .fn_end_178_app_hl_svg_smoke_svg_attr_color
    jmp .endif180
.else179:
.endif180:
    mov rax, [rbp-48]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else181
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    movzx rax, byte [rax]
    push rax
    mov rax, 110
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else183
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 111
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else185
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 110
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else187
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, 3
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 101
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else189
    mov rax, 1
    neg rax
    jmp .fn_end_178_app_hl_svg_smoke_svg_attr_color
    jmp .endif190
.else189:
.endif190:
    jmp .endif188
.else187:
.endif188:
    jmp .endif186
.else185:
.endif186:
    jmp .endif184
.else183:
.endif184:
    jmp .endif182
.else181:
.endif182:
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-48]
    push rax
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_parse_color, 2
    mov [rbp-56], rax
    mov rax, [rbp-56]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else191
    mov rax, [rbp-32]
    jmp .fn_end_178_app_hl_svg_smoke_svg_attr_color
    jmp .endif192
.else191:
.endif192:
    mov rax, [rbp-56]
    jmp .fn_end_178_app_hl_svg_smoke_svg_attr_color
.fn_end_178_app_hl_svg_smoke_svg_attr_color:
    FN_END app_hl_svg_smoke_svg_attr_color
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_match_at, 5, 0, FN_RET_SCALAR
FN_ARG 0, buf, FN_KIND_SCALAR
FN_ARG 1, len, FN_KIND_SCALAR
FN_ARG 2, pos, FN_KIND_SCALAR
FN_ARG 3, word, FN_KIND_SCALAR
FN_ARG 4, wlen, FN_KIND_SCALAR
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
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-40]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-16]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else193
    mov rax, 0
    jmp .fn_end_192_app_hl_svg_smoke_svg_match_at
    jmp .endif194
.else193:
.endif194:
    mov rax, 0
    mov [rbp-56], rax
.wst195:
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-40]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend196
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-24]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-56]
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
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
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else197
    mov rax, 0
    jmp .fn_end_192_app_hl_svg_smoke_svg_match_at
    jmp .endif198
.else197:
.endif198:
    mov rax, [rbp-56]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-56], rax
    jmp .wst195
.wend196:
    mov rax, 1
    jmp .fn_end_192_app_hl_svg_smoke_svg_match_at
.fn_end_192_app_hl_svg_smoke_svg_match_at:
    FN_END app_hl_svg_smoke_svg_match_at
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_style_color, 4, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
FN_ARG 1, prop, FN_KIND_SCALAR
FN_ARG 2, plen, FN_KIND_SCALAR
FN_ARG 3, defv, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str1]
    push rax
    mov rax, 5
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_attr, 3
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
    jz .else199
    mov rax, [rbp-32]
    jmp .fn_end_198_app_hl_svg_smoke_svg_style_color
    jmp .endif200
.else199:
.endif200:
    mov rax, 0
    mov [rbp-56], rax
.wst201:
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend202
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_match_at, 5
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else203
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-24]
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-56], rax
.wst205:
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend206
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-56]
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    mov [rbp-64], rax
    mov rax, [rbp-64]
    push rax
    mov rax, 32
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else207
    mov rax, [rbp-56]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-56], rax
    jmp .endif208
.else207:
    mov rax, [rbp-64]
    push rax
    mov rax, 9
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else209
    mov rax, [rbp-56]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-56], rax
    jmp .endif210
.else209:
    jmp .wend206
.endif210:
.endif208:
    jmp .wst205
.wend206:
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else211
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-56]
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 58
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else213
    mov rax, [rbp-56]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-56], rax
    jmp .endif214
.else213:
.endif214:
    jmp .endif212
.else211:
.endif212:
.wst215:
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend216
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-56]
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    mov [rbp-72], rax
    mov rax, [rbp-72]
    push rax
    mov rax, 32
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else217
    mov rax, [rbp-56]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-56], rax
    jmp .endif218
.else217:
    mov rax, [rbp-72]
    push rax
    mov rax, 9
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else219
    mov rax, [rbp-56]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-56], rax
    jmp .endif220
.else219:
    jmp .wend216
.endif220:
.endif218:
    jmp .wst215
.wend216:
    mov rax, [rbp-56]
    mov [rbp-80], rax
.wst221:
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend222
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-56]
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    mov [rbp-88], rax
    mov rax, [rbp-88]
    push rax
    mov rax, 59
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else223
    jmp .wend222
    jmp .endif224
.else223:
.endif224:
    mov rax, [rbp-88]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_is_ws, 1
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else225
    jmp .wend222
    jmp .endif226
.else225:
.endif226:
    mov rax, [rbp-56]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-56], rax
    jmp .wst221
.wend222:
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-80]
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else227
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-80]
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 110
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else229
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-80]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 111
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else231
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-80]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 110
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else233
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-80]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 3
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 101
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else235
    mov rax, 1
    neg rax
    jmp .fn_end_198_app_hl_svg_smoke_svg_style_color
    jmp .endif236
.else235:
.endif236:
    jmp .endif234
.else233:
.endif234:
    jmp .endif232
.else231:
.endif232:
    jmp .endif230
.else229:
.endif230:
    jmp .endif228
.else227:
.endif228:
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-80]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-80]
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_parse_color, 2
    mov [rbp-96], rax
    mov rax, [rbp-96]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else237
    mov rax, [rbp-96]
    jmp .fn_end_198_app_hl_svg_smoke_svg_style_color
    jmp .endif238
.else237:
.endif238:
    mov rax, [rbp-32]
    jmp .fn_end_198_app_hl_svg_smoke_svg_style_color
    jmp .endif204
.else203:
.endif204:
    mov rax, [rbp-56]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-56], rax
    jmp .wst201
.wend202:
    mov rax, [rbp-32]
    jmp .fn_end_198_app_hl_svg_smoke_svg_style_color
.fn_end_198_app_hl_svg_smoke_svg_style_color:
    FN_END app_hl_svg_smoke_svg_style_color
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_style_int, 4, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
FN_ARG 1, prop, FN_KIND_SCALAR
FN_ARG 2, plen, FN_KIND_SCALAR
FN_ARG 3, defv, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str1]
    push rax
    mov rax, 5
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_attr, 3
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
    jz .else239
    mov rax, [rbp-32]
    jmp .fn_end_238_app_hl_svg_smoke_svg_style_int
    jmp .endif240
.else239:
.endif240:
    mov rax, 0
    mov [rbp-56], rax
.wst241:
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend242
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_match_at, 5
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else243
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-24]
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-56], rax
.wst245:
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend246
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-56]
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    mov [rbp-64], rax
    mov rax, [rbp-64]
    push rax
    mov rax, 32
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else247
    mov rax, [rbp-56]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-56], rax
    jmp .endif248
.else247:
    mov rax, [rbp-64]
    push rax
    mov rax, 9
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else249
    mov rax, [rbp-56]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-56], rax
    jmp .endif250
.else249:
    jmp .wend246
.endif250:
.endif248:
    jmp .wst245
.wend246:
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else251
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-56]
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 58
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else253
    mov rax, [rbp-56]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-56], rax
    jmp .endif254
.else253:
.endif254:
    jmp .endif252
.else251:
.endif252:
.wst255:
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend256
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-56]
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    mov [rbp-72], rax
    mov rax, [rbp-72]
    push rax
    mov rax, 32
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else257
    mov rax, [rbp-56]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-56], rax
    jmp .endif258
.else257:
    mov rax, [rbp-72]
    push rax
    mov rax, 9
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else259
    mov rax, [rbp-56]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-56], rax
    jmp .endif260
.else259:
    jmp .wend256
.endif260:
.endif258:
    jmp .wst255
.wend256:
    mov rax, [rbp-56]
    mov [rbp-80], rax
.wst261:
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend262
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-56]
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    mov [rbp-88], rax
    mov rax, [rbp-88]
    push rax
    mov rax, 59
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else263
    jmp .wend262
    jmp .endif264
.else263:
.endif264:
    mov rax, [rbp-88]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_is_ws, 1
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else265
    jmp .wend262
    jmp .endif266
.else265:
.endif266:
    mov rax, [rbp-56]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-56], rax
    jmp .wst261
.wend262:
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-80]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-80]
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_parse_int, 2
    jmp .fn_end_238_app_hl_svg_smoke_svg_style_int
    jmp .endif244
.else243:
.endif244:
    mov rax, [rbp-56]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-56], rax
    jmp .wst241
.wend242:
    mov rax, [rbp-32]
    jmp .fn_end_238_app_hl_svg_smoke_svg_style_int
.fn_end_238_app_hl_svg_smoke_svg_style_int:
    FN_END app_hl_svg_smoke_svg_style_int
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_fill_color, 2, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
FN_ARG 1, defv, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str2]
    push rax
    mov rax, 4
    push rax
    mov rax, 2
    neg rax
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_attr_color, 4
    mov [rbp-32], rax
    mov rax, [rbp-32]
    push rax
    mov rax, 2
    neg rax
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else267
    mov rax, [rbp-32]
    jmp .fn_end_266_app_hl_svg_smoke_svg_fill_color
    jmp .endif268
.else267:
.endif268:
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str2]
    push rax
    mov rax, 4
    push rax
    mov rax, [rbp-16]
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_style_color, 4
    jmp .fn_end_266_app_hl_svg_smoke_svg_fill_color
.fn_end_266_app_hl_svg_smoke_svg_fill_color:
    FN_END app_hl_svg_smoke_svg_fill_color
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_stroke_color, 2, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
FN_ARG 1, defv, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str3]
    push rax
    mov rax, 6
    push rax
    mov rax, 2
    neg rax
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_attr_color, 4
    mov [rbp-32], rax
    mov rax, [rbp-32]
    push rax
    mov rax, 2
    neg rax
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else269
    mov rax, [rbp-32]
    jmp .fn_end_268_app_hl_svg_smoke_svg_stroke_color
    jmp .endif270
.else269:
.endif270:
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str3]
    push rax
    mov rax, 6
    push rax
    mov rax, [rbp-16]
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_style_color, 4
    jmp .fn_end_268_app_hl_svg_smoke_svg_stroke_color
.fn_end_268_app_hl_svg_smoke_svg_stroke_color:
    FN_END app_hl_svg_smoke_svg_stroke_color
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_scan_int, 3, 0, FN_RET_SCALAR
FN_ARG 0, buf, FN_KIND_SCALAR
FN_ARG 1, len, FN_KIND_SCALAR
FN_ARG 2, pos_ptr, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    push rbx
    push r12
    mov rax, [rbp-24]
    mov eax, [rax]
    mov [rbp-40], rax
.wst271:
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-16]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend272
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-40]
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_is_ws, 1
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else273
    jmp .wend272
    jmp .endif274
.else273:
.endif274:
    mov rax, [rbp-40]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-40], rax
    jmp .wst271
.wend272:
    mov rax, [rbp-40]
    mov [rbp-48], rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-16]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else275
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-40]
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 45
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else277
    mov rax, [rbp-40]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-40], rax
    jmp .endif278
.else277:
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-40]
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, 43
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else279
    mov rax, [rbp-40]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-40], rax
    jmp .endif280
.else279:
.endif280:
.endif278:
    jmp .endif276
.else275:
.endif276:
.wst281:
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-16]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend282
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-40]
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    mov [rbp-56], rax
    mov rax, [rbp-56]
    push rax
    mov rax, 48
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else283
    jmp .wend282
    jmp .endif284
.else283:
.endif284:
    mov rax, [rbp-56]
    push rax
    mov rax, 57
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else285
    jmp .wend282
    jmp .endif286
.else285:
.endif286:
    mov rax, [rbp-40]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-40], rax
    jmp .wst281
.wend282:
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-40]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_parse_int, 2
    jmp .fn_end_270_app_hl_svg_smoke_svg_scan_int
.fn_end_270_app_hl_svg_smoke_svg_scan_int:
    FN_END app_hl_svg_smoke_svg_scan_int
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_scan_has_more, 3, 0, FN_RET_SCALAR
FN_ARG 0, buf, FN_KIND_SCALAR
FN_ARG 1, len, FN_KIND_SCALAR
FN_ARG 2, pos_ptr, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    push rbx
    push r12
    mov rax, [rbp-24]
    mov eax, [rax]
    mov [rbp-40], rax
.wst287:
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-16]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend288
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-40]
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_is_ws, 1
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else289
    jmp .wend288
    jmp .endif290
.else289:
.endif290:
    mov rax, [rbp-40]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-40], rax
    jmp .wst287
.wend288:
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-40]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-16]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else291
    mov rax, 0
    jmp .fn_end_286_app_hl_svg_smoke_svg_scan_has_more
    jmp .endif292
.else291:
.endif292:
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-40]
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_is_num_start, 1
    jmp .fn_end_286_app_hl_svg_smoke_svg_scan_has_more
.fn_end_286_app_hl_svg_smoke_svg_scan_has_more:
    FN_END app_hl_svg_smoke_svg_scan_has_more
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_setup_viewbox, 5, 0, FN_RET_SCALAR
FN_ARG 0, root, FN_KIND_SCALAR
FN_ARG 1, x, FN_KIND_SCALAR
FN_ARG 2, y, FN_KIND_SCALAR
FN_ARG 3, w, FN_KIND_SCALAR
FN_ARG 4, h, FN_KIND_SCALAR
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
    lea rax, [rel app_hl_svg_smoke_svg_dst_x]
    push rax
    mov rax, [rbp-16]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_dst_y]
    push rax
    mov rax, [rbp-24]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_dst_w]
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_dst_h]
    push rax
    mov rax, [rbp-40]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_vb_x]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_vb_y]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_vb_w]
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_vb_h]
    push rax
    mov rax, [rbp-40]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str4]
    push rax
    mov rax, 7
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_attr, 3
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
    jz .else293
    mov rax, 0
    mov [rbp-64], rax
    lea rax, [rel app_hl_svg_smoke_svg_sx]
    push rax
    mov rax, [rbp-64]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_vb_x]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-56]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_sx]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_vb_y]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-56]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_sx]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_vb_w]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-56]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_sx]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_vb_h]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-56]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_sx]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif294
.else293:
.endif294:
    lea rax, [rel app_hl_svg_smoke_svg_vb_w]
    mov eax, [rax]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx rax, al
    test rax, rax
    jz .else295
    lea rax, [rel app_hl_svg_smoke_svg_vb_w]
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif296
.else295:
.endif296:
    lea rax, [rel app_hl_svg_smoke_svg_vb_h]
    mov eax, [rax]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx rax, al
    test rax, rax
    jz .else297
    lea rax, [rel app_hl_svg_smoke_svg_vb_h]
    push rax
    mov rax, [rbp-40]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif298
.else297:
.endif298:
    lea rax, [rel app_hl_svg_smoke_svg_sx]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, 16
    mov rcx, rax
    pop rax
    shl rax, cl
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_vb_w]
    mov eax, [rax]
    mov rcx, rax
    pop rax
    cqo
    idiv rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_sy]
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, 16
    mov rcx, rax
    pop rax
    shl rax, cl
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_vb_h]
    mov eax, [rax]
    mov rcx, rax
    pop rax
    cqo
    idiv rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
.fn_end_292_app_hl_svg_smoke_svg_setup_viewbox:
    FN_END app_hl_svg_smoke_svg_setup_viewbox
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_tx, 1, 0, FN_RET_SCALAR
FN_ARG 0, x, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_vb_x]
    mov eax, [rax]
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_sx]
    mov eax, [rax]
    mov rcx, rax
    pop rax
    imul rax, rcx
    push rax
    mov rax, 16
    mov rcx, rax
    pop rax
    shr rax, cl
    mov [rbp-24], rax
    lea rax, [rel app_hl_svg_smoke_svg_dst_x]
    mov eax, [rax]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_tf_x]
    mov eax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-24]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_tf_sx]
    mov eax, [rax]
    mov rcx, rax
    pop rax
    imul rax, rcx
    push rax
    mov rax, 16
    mov rcx, rax
    pop rax
    shr rax, cl
    mov rcx, rax
    pop rax
    add rax, rcx
    jmp .fn_end_298_app_hl_svg_smoke_svg_tx
.fn_end_298_app_hl_svg_smoke_svg_tx:
    FN_END app_hl_svg_smoke_svg_tx
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_ty, 1, 0, FN_RET_SCALAR
FN_ARG 0, y, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_vb_y]
    mov eax, [rax]
    mov rcx, rax
    pop rax
    sub rax, rcx
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_sy]
    mov eax, [rax]
    mov rcx, rax
    pop rax
    imul rax, rcx
    push rax
    mov rax, 16
    mov rcx, rax
    pop rax
    shr rax, cl
    mov [rbp-24], rax
    lea rax, [rel app_hl_svg_smoke_svg_dst_y]
    mov eax, [rax]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_tf_y]
    mov eax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-24]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_tf_sy]
    mov eax, [rax]
    mov rcx, rax
    pop rax
    imul rax, rcx
    push rax
    mov rax, 16
    mov rcx, rax
    pop rax
    shr rax, cl
    mov rcx, rax
    pop rax
    add rax, rcx
    jmp .fn_end_298_app_hl_svg_smoke_svg_ty
.fn_end_298_app_hl_svg_smoke_svg_ty:
    FN_END app_hl_svg_smoke_svg_ty
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_tw, 1, 0, FN_RET_SCALAR
FN_ARG 0, w, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_sx]
    mov eax, [rax]
    mov rcx, rax
    pop rax
    imul rax, rcx
    push rax
    mov rax, 16
    mov rcx, rax
    pop rax
    shr rax, cl
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else299
    mov rax, 1
    jmp .fn_end_298_app_hl_svg_smoke_svg_tw
    jmp .endif300
.else299:
.endif300:
    mov rax, [rbp-24]
    jmp .fn_end_298_app_hl_svg_smoke_svg_tw
.fn_end_298_app_hl_svg_smoke_svg_tw:
    FN_END app_hl_svg_smoke_svg_tw
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_th, 1, 0, FN_RET_SCALAR
FN_ARG 0, h, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_sy]
    mov eax, [rax]
    mov rcx, rax
    pop rax
    imul rax, rcx
    push rax
    mov rax, 16
    mov rcx, rax
    pop rax
    shr rax, cl
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else301
    mov rax, 1
    jmp .fn_end_300_app_hl_svg_smoke_svg_th
    jmp .endif302
.else301:
.endif302:
    mov rax, [rbp-24]
    jmp .fn_end_300_app_hl_svg_smoke_svg_th
.fn_end_300_app_hl_svg_smoke_svg_th:
    FN_END app_hl_svg_smoke_svg_th
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_line_width, 1, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str5]
    push rax
    mov rax, 12
    push rax
    mov rax, 1
    neg rax
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_attr_int, 4
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
    jz .else303
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str5]
    push rax
    mov rax, 12
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_in_width]
    mov eax, [rax]
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_style_int, 4
    mov [rbp-24], rax
    jmp .endif304
.else303:
.endif304:
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else305
    mov rax, 1
    jmp .fn_end_302_app_hl_svg_smoke_svg_line_width
    jmp .endif306
.else305:
.endif306:
    lea rax, [rel app_hl_svg_smoke_svg_sx]
    mov eax, [rax]
    mov [rbp-32], rax
    lea rax, [rel app_hl_svg_smoke_svg_sy]
    mov eax, [rax]
    mov [rbp-40], rax
    mov rax, [rbp-32]
    mov [rbp-48], rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else307
    mov rax, [rbp-40]
    mov [rbp-48], rax
    jmp .endif308
.else307:
.endif308:
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rax
    imul rax, rcx
    push rax
    mov rax, 16
    mov rcx, rax
    pop rax
    shr rax, cl
    mov [rbp-56], rax
    mov rax, [rbp-56]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else309
    mov rax, 1
    jmp .fn_end_302_app_hl_svg_smoke_svg_line_width
    jmp .endif310
.else309:
.endif310:
    mov rax, [rbp-56]
    jmp .fn_end_302_app_hl_svg_smoke_svg_line_width
.fn_end_302_app_hl_svg_smoke_svg_line_width:
    FN_END app_hl_svg_smoke_svg_line_width
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_draw_stroked_line, 6, 0, FN_RET_SCALAR
FN_ARG 0, x1, FN_KIND_SCALAR
FN_ARG 1, y1, FN_KIND_SCALAR
FN_ARG 2, x2, FN_KIND_SCALAR
FN_ARG 3, y2, FN_KIND_SCALAR
FN_ARG 4, color, FN_KIND_SCALAR
FN_ARG 5, width, FN_KIND_SCALAR
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
    mov rax, [rbp-48]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx rax, al
    test rax, rax
    jz .else311
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
    FN_CALL app_hl_svg_smoke_raster_line, 5
    jmp .fn_end_310_app_hl_svg_smoke_svg_draw_stroked_line
    jmp .endif312
.else311:
.endif312:
    mov rax, [rbp-48]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cqo
    idiv rcx
    mov [rbp-64], rax
    mov rax, 0
    push rax
    mov rax, [rbp-64]
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov [rbp-72], rax
.wst313:
    mov rax, [rbp-72]
    push rax
    mov rax, [rbp-64]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx rax, al
    test rax, rax
    jz .wend314
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-72]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-72]
    mov rcx, rax
    pop rax
    add rax, rcx
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
    FN_CALL app_hl_svg_smoke_raster_line, 5
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-72]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-72]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-40]
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_raster_line, 5
    mov rax, [rbp-72]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-72], rax
    jmp .wst313
.wend314:
.fn_end_310_app_hl_svg_smoke_svg_draw_stroked_line:
    FN_END app_hl_svg_smoke_svg_draw_stroked_line
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_fill_tri, 6, 0, FN_RET_SCALAR
FN_ARG 0, x0, FN_KIND_SCALAR
FN_ARG 1, y0, FN_KIND_SCALAR
FN_ARG 2, x1, FN_KIND_SCALAR
FN_ARG 3, y1, FN_KIND_SCALAR
FN_ARG 4, x2, FN_KIND_SCALAR
FN_ARG 5, y2, FN_KIND_SCALAR
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
    lea rax, [rel app_hl_svg_smoke_svg_tri_buf]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-8]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_tri_buf]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-16]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_tri_buf]
    push rax
    mov rax, 8
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-24]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_tri_buf]
    push rax
    mov rax, 12
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_tri_buf]
    push rax
    mov rax, 16
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-40]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_tri_buf]
    push rax
    mov rax, 20
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_tri_buf]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_tmp_color]
    mov eax, [rax]
    push rax
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_raster_triangle, 2
.fn_end_314_app_hl_svg_smoke_svg_fill_tri:
    FN_END app_hl_svg_smoke_svg_fill_tri
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_tag_is, 3, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
FN_ARG 1, name, FN_KIND_SCALAR
FN_ARG 2, nlen, FN_KIND_SCALAR
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
    lea rax, [rel app_hl_svg_smoke_svg_tag_buf]
    push rax
    mov rax, 16
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_xml_tag_name, 3
    mov [rbp-40], rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-24]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    test rax, rax
    jz .else315
    mov rax, 0
    jmp .fn_end_314_app_hl_svg_smoke_svg_tag_is
    jmp .endif316
.else315:
.endif316:
    mov rax, 0
    mov [rbp-48], rax
.wst317:
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-24]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend318
    lea rax, [rel app_hl_svg_smoke_svg_tag_buf]
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-48]
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
    jz .else319
    mov rax, 0
    jmp .fn_end_314_app_hl_svg_smoke_svg_tag_is
    jmp .endif320
.else319:
.endif320:
    mov rax, [rbp-48]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-48], rax
    jmp .wst317
.wend318:
    mov rax, 1
    jmp .fn_end_314_app_hl_svg_smoke_svg_tag_is
.fn_end_314_app_hl_svg_smoke_svg_tag_is:
    FN_END app_hl_svg_smoke_svg_tag_is
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_apply_transform, 1, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str6]
    push rax
    mov rax, 9
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_attr, 3
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx rax, al
    test rax, rax
    jz .else321
    jmp .fn_end_320_app_hl_svg_smoke_svg_apply_transform
    jmp .endif322
.else321:
.endif322:
    mov rax, 0
    mov [rbp-32], rax
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    push rax
    lea rax, [rel app_hl_svg_smoke_str7]
    push rax
    mov rax, 9
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_match_at, 5
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else323
    mov rax, 10
    mov [rbp-32], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-24]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-40], rax
    mov rax, 0
    mov [rbp-48], rax
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-24]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_has_more, 3
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else325
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-24]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-48], rax
    jmp .endif326
.else325:
.endif326:
    lea rax, [rel app_hl_svg_smoke_svg_tf_x]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_tf_x]
    mov eax, [rax]
    push rax
    mov rax, [rbp-40]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tw, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_tf_y]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_tf_y]
    mov eax, [rax]
    push rax
    mov rax, [rbp-48]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_th, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif324
.else323:
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    push rax
    lea rax, [rel app_hl_svg_smoke_str8]
    push rax
    mov rax, 5
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_match_at, 5
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else327
    mov rax, 6
    mov [rbp-32], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-24]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-56], rax
    mov rax, [rbp-56]
    mov [rbp-64], rax
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-24]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_has_more, 3
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else329
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-24]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-64], rax
    jmp .endif330
.else329:
.endif330:
    mov rax, [rbp-56]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else331
    mov rax, 1
    mov [rbp-56], rax
    jmp .endif332
.else331:
.endif332:
    mov rax, [rbp-64]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else333
    mov rax, 1
    mov [rbp-64], rax
    jmp .endif334
.else333:
.endif334:
    lea rax, [rel app_hl_svg_smoke_svg_tf_sx]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_tf_sx]
    mov eax, [rax]
    push rax
    mov rax, [rbp-56]
    mov rcx, rax
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_tf_sy]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_tf_sy]
    mov eax, [rax]
    push rax
    mov rax, [rbp-64]
    mov rcx, rax
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif328
.else327:
.endif328:
.endif324:
.fn_end_320_app_hl_svg_smoke_svg_apply_transform:
    FN_END app_hl_svg_smoke_svg_apply_transform
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_draw_rect, 1, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_in_fill]
    mov eax, [rax]
    push rax
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_fill_color, 2
    mov [rbp-24], rax
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str9]
    push rax
    mov rax, 1
    push rax
    mov rax, 0
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_attr_int, 4
    mov [rbp-32], rax
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str10]
    push rax
    mov rax, 1
    push rax
    mov rax, 0
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_attr_int, 4
    mov [rbp-40], rax
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str11]
    push rax
    mov rax, 5
    push rax
    mov rax, 0
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_attr_int, 4
    mov [rbp-48], rax
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str12]
    push rax
    mov rax, 6
    push rax
    mov rax, 0
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_attr_int, 4
    mov [rbp-56], rax
    mov rax, [rbp-48]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx rax, al
    test rax, rax
    jz .else335
    jmp .fn_end_334_app_hl_svg_smoke_svg_draw_rect
    jmp .endif336
.else335:
.endif336:
    mov rax, [rbp-56]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx rax, al
    test rax, rax
    jz .else337
    jmp .fn_end_334_app_hl_svg_smoke_svg_draw_rect
    jmp .endif338
.else337:
.endif338:
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else339
    mov rax, [rbp-32]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    mov rax, [rbp-40]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-48]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tw, 1
    push rax
    mov rax, [rbp-56]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_th, 1
    push rax
    mov rax, [rbp-24]
    push rax
    pop r8
    pop r10
    pop rdx
    pop rsi
    pop rdi
    mov rax, 2
    syscall
    jmp .endif340
.else339:
.endif340:
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_in_stroke]
    mov eax, [rax]
    push rax
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_stroke_color, 2
    mov [rbp-64], rax
    mov rax, [rbp-64]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else341
    mov rax, [rbp-32]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    mov [rbp-72], rax
    mov rax, [rbp-40]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    mov [rbp-80], rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    mov [rbp-88], rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-56]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    mov [rbp-96], rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_line_width, 1
    mov [rbp-104], rax
    mov rax, [rbp-72]
    push rax
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-88]
    push rax
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-104]
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_draw_stroked_line, 6
    mov rax, [rbp-88]
    push rax
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-88]
    push rax
    mov rax, [rbp-96]
    push rax
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-104]
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_draw_stroked_line, 6
    mov rax, [rbp-88]
    push rax
    mov rax, [rbp-96]
    push rax
    mov rax, [rbp-72]
    push rax
    mov rax, [rbp-96]
    push rax
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-104]
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_draw_stroked_line, 6
    mov rax, [rbp-72]
    push rax
    mov rax, [rbp-96]
    push rax
    mov rax, [rbp-72]
    push rax
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-104]
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_draw_stroked_line, 6
    jmp .endif342
.else341:
.endif342:
.fn_end_334_app_hl_svg_smoke_svg_draw_rect:
    FN_END app_hl_svg_smoke_svg_draw_rect
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_draw_circle, 1, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_in_fill]
    mov eax, [rax]
    push rax
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_fill_color, 2
    mov [rbp-24], rax
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str13]
    push rax
    mov rax, 2
    push rax
    mov rax, 0
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_attr_int, 4
    mov [rbp-32], rax
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str14]
    push rax
    mov rax, 2
    push rax
    mov rax, 0
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_attr_int, 4
    mov [rbp-40], rax
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str15]
    push rax
    mov rax, 1
    push rax
    mov rax, 0
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_attr_int, 4
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
    jz .else343
    jmp .fn_end_342_app_hl_svg_smoke_svg_draw_circle
    jmp .endif344
.else343:
.endif344:
    lea rax, [rel app_hl_svg_smoke_svg_sx]
    mov eax, [rax]
    mov [rbp-56], rax
    lea rax, [rel app_hl_svg_smoke_svg_sy]
    mov eax, [rax]
    mov [rbp-64], rax
    mov rax, [rbp-56]
    mov [rbp-72], rax
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-56]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else345
    mov rax, [rbp-64]
    mov [rbp-72], rax
    jmp .endif346
.else345:
.endif346:
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-72]
    mov rcx, rax
    pop rax
    imul rax, rcx
    push rax
    mov rax, 16
    mov rcx, rax
    pop rax
    shr rax, cl
    mov [rbp-80], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else347
    mov rax, [rbp-32]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    mov rax, [rbp-40]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-24]
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_raster_circle, 4
    jmp .endif348
.else347:
.endif348:
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_in_stroke]
    mov eax, [rax]
    push rax
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_stroke_color, 2
    mov [rbp-88], rax
    mov rax, [rbp-88]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else349
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_line_width, 1
    mov [rbp-96], rax
    mov rax, [rbp-32]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    mov rax, [rbp-40]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-88]
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_raster_circle, 4
    mov rax, [rbp-96]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    test rax, rax
    jz .else351
    mov rax, [rbp-32]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    mov rax, [rbp-40]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-96]
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
    mov rax, [rbp-88]
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_raster_circle, 4
    jmp .endif352
.else351:
.endif352:
    jmp .endif350
.else349:
.endif350:
.fn_end_342_app_hl_svg_smoke_svg_draw_circle:
    FN_END app_hl_svg_smoke_svg_draw_circle
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_draw_ellipse, 1, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_in_fill]
    mov eax, [rax]
    push rax
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_fill_color, 2
    mov [rbp-24], rax
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str13]
    push rax
    mov rax, 2
    push rax
    mov rax, 0
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_attr_int, 4
    mov [rbp-32], rax
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str14]
    push rax
    mov rax, 2
    push rax
    mov rax, 0
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_attr_int, 4
    mov [rbp-40], rax
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str16]
    push rax
    mov rax, 2
    push rax
    mov rax, 0
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_attr_int, 4
    mov [rbp-48], rax
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str17]
    push rax
    mov rax, 2
    push rax
    mov rax, 0
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_attr_int, 4
    mov [rbp-56], rax
    mov rax, [rbp-48]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx rax, al
    test rax, rax
    jz .else353
    jmp .fn_end_352_app_hl_svg_smoke_svg_draw_ellipse
    jmp .endif354
.else353:
.endif354:
    mov rax, [rbp-56]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx rax, al
    test rax, rax
    jz .else355
    jmp .fn_end_352_app_hl_svg_smoke_svg_draw_ellipse
    jmp .endif356
.else355:
.endif356:
    lea rax, [rel app_hl_svg_smoke_svg_sx]
    mov eax, [rax]
    mov [rbp-64], rax
    lea rax, [rel app_hl_svg_smoke_svg_sy]
    mov eax, [rax]
    mov [rbp-72], rax
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-64]
    mov rcx, rax
    pop rax
    imul rax, rcx
    push rax
    mov rax, 16
    mov rcx, rax
    pop rax
    shr rax, cl
    mov [rbp-80], rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-72]
    mov rcx, rax
    pop rax
    imul rax, rcx
    push rax
    mov rax, 16
    mov rcx, rax
    pop rax
    shr rax, cl
    mov [rbp-88], rax
    mov rax, [rbp-88]
    push rax
    mov rax, [rbp-80]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else357
    mov rax, [rbp-88]
    mov [rbp-80], rax
    jmp .endif358
.else357:
.endif358:
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else359
    mov rax, [rbp-32]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    mov rax, [rbp-40]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-24]
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_raster_circle, 4
    jmp .endif360
.else359:
.endif360:
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_in_stroke]
    mov eax, [rax]
    push rax
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_stroke_color, 2
    mov [rbp-96], rax
    mov rax, [rbp-96]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else361
    mov rax, [rbp-32]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    mov rax, [rbp-40]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-96]
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_raster_circle, 4
    jmp .endif362
.else361:
.endif362:
.fn_end_352_app_hl_svg_smoke_svg_draw_ellipse:
    FN_END app_hl_svg_smoke_svg_draw_ellipse
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_draw_line, 1, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_in_stroke]
    mov eax, [rax]
    push rax
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_stroke_color, 2
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
    jz .else363
    jmp .fn_end_362_app_hl_svg_smoke_svg_draw_line
    jmp .endif364
.else363:
.endif364:
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str18]
    push rax
    mov rax, 2
    push rax
    mov rax, 0
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_attr_int, 4
    mov [rbp-32], rax
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str19]
    push rax
    mov rax, 2
    push rax
    mov rax, 0
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_attr_int, 4
    mov [rbp-40], rax
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str20]
    push rax
    mov rax, 2
    push rax
    mov rax, 0
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_attr_int, 4
    mov [rbp-48], rax
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str21]
    push rax
    mov rax, 2
    push rax
    mov rax, 0
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_attr_int, 4
    mov [rbp-56], rax
    mov rax, [rbp-32]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    mov rax, [rbp-40]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-48]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    mov rax, [rbp-56]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_line_width, 1
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_draw_stroked_line, 6
.fn_end_362_app_hl_svg_smoke_svg_draw_line:
    FN_END app_hl_svg_smoke_svg_draw_line
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_draw_poly, 2, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
FN_ARG 1, close_shape, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_in_fill]
    mov eax, [rax]
    push rax
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_fill_color, 2
    mov [rbp-32], rax
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_in_stroke]
    mov eax, [rax]
    push rax
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_stroke_color, 2
    mov [rbp-40], rax
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str22]
    push rax
    mov rax, 6
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_attr_len, 3
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
    jz .else365
    jmp .fn_end_364_app_hl_svg_smoke_svg_draw_poly
    jmp .endif366
.else365:
.endif366:
    mov rax, 0
    mov [rbp-56], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    mov rax, [rbp-56]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-48]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_has_more, 3
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else367
    jmp .fn_end_364_app_hl_svg_smoke_svg_draw_poly
    jmp .endif368
.else367:
.endif368:
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-48]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-64], rax
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-48]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-72], rax
    mov rax, [rbp-64]
    mov [rbp-80], rax
    mov rax, [rbp-72]
    mov [rbp-88], rax
    mov rax, 1
    mov [rbp-96], rax
.wst369:
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-48]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_has_more, 3
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .wend370
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-48]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-104], rax
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-48]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-112], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else371
    mov rax, [rbp-32]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else373
    mov rax, [rbp-96]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else375
    lea rax, [rel app_hl_svg_smoke_svg_tmp_color]
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, [rbp-64]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    mov rax, [rbp-72]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-80]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    mov rax, [rbp-88]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-104]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    mov rax, [rbp-112]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_fill_tri, 6
    jmp .endif376
.else375:
.endif376:
    jmp .endif374
.else373:
.endif374:
    jmp .endif372
.else371:
.endif372:
    mov rax, [rbp-40]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else377
    mov rax, [rbp-80]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    mov rax, [rbp-88]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-104]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    mov rax, [rbp-112]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_line_width, 1
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_draw_stroked_line, 6
    jmp .endif378
.else377:
.endif378:
    mov rax, [rbp-104]
    mov [rbp-80], rax
    mov rax, [rbp-112]
    mov [rbp-88], rax
    mov rax, 0
    mov [rbp-96], rax
    jmp .wst369
.wend370:
    mov rax, [rbp-16]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else379
    mov rax, [rbp-40]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else381
    mov rax, [rbp-80]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    mov rax, [rbp-88]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-64]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    mov rax, [rbp-72]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_line_width, 1
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_draw_stroked_line, 6
    jmp .endif382
.else381:
.endif382:
    jmp .endif380
.else379:
.endif380:
.fn_end_364_app_hl_svg_smoke_svg_draw_poly:
    FN_END app_hl_svg_smoke_svg_draw_poly
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_path_next_cmd, 4, 0, FN_RET_SCALAR
FN_ARG 0, buf, FN_KIND_SCALAR
FN_ARG 1, len, FN_KIND_SCALAR
FN_ARG 2, pos_ptr, FN_KIND_SCALAR
FN_ARG 3, current_cmd, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    push rbx
    push r12
    mov rax, [rbp-24]
    mov eax, [rax]
    mov [rbp-48], rax
.wst383:
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-16]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend384
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_is_ws, 1
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else385
    jmp .wend384
    jmp .endif386
.else385:
.endif386:
    mov rax, [rbp-48]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-48], rax
    jmp .wst383
.wend384:
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-16]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else387
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, 0
    jmp .fn_end_382_app_hl_svg_smoke_svg_path_next_cmd
    jmp .endif388
.else387:
.endif388:
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rax
    add rax, rcx
    movzx rax, byte [rax]
    mov [rbp-56], rax
    mov rax, [rbp-56]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_is_num_start, 1
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else389
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, [rbp-32]
    jmp .fn_end_382_app_hl_svg_smoke_svg_path_next_cmd
    jmp .endif390
.else389:
.endif390:
    mov rax, [rbp-24]
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
    jmp .fn_end_382_app_hl_svg_smoke_svg_path_next_cmd
.fn_end_382_app_hl_svg_smoke_svg_path_next_cmd:
    FN_END app_hl_svg_smoke_svg_path_next_cmd
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_draw_path, 1, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_in_stroke]
    mov eax, [rax]
    push rax
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_stroke_color, 2
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
    jz .else391
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_in_fill]
    mov eax, [rax]
    push rax
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_fill_color, 2
    mov [rbp-24], rax
    jmp .endif392
.else391:
.endif392:
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else393
    jmp .fn_end_390_app_hl_svg_smoke_svg_draw_path
    jmp .endif394
.else393:
.endif394:
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str23]
    push rax
    mov rax, 1
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_attr_len, 3
    mov [rbp-32], rax
    mov rax, [rbp-32]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx rax, al
    test rax, rax
    jz .else395
    jmp .fn_end_390_app_hl_svg_smoke_svg_draw_path
    jmp .endif396
.else395:
.endif396:
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_path_x0]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_path_y0]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_path_start_x]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_path_start_y]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, 0
    mov [rbp-40], rax
.wst397:
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    mov eax, [rax]
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .wend398
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    mov rax, [rbp-40]
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_path_next_cmd, 4
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
    jz .else399
    jmp .fn_end_390_app_hl_svg_smoke_svg_draw_path
    jmp .endif400
.else399:
.endif400:
    mov rax, [rbp-40]
    push rax
    mov rax, 77
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else401
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_has_more, 3
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else403
    jmp .fn_end_390_app_hl_svg_smoke_svg_draw_path
    jmp .endif404
.else403:
.endif404:
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_path_start_x]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    mov eax, [rax]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_path_start_y]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    mov eax, [rax]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_path_x0]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    mov eax, [rax]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_path_y0]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    mov eax, [rax]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, 76
    mov [rbp-40], rax
    jmp .endif402
.else401:
    mov rax, [rbp-40]
    push rax
    mov rax, 109
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else405
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_has_more, 3
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else407
    jmp .fn_end_390_app_hl_svg_smoke_svg_draw_path
    jmp .endif408
.else407:
.endif408:
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    mov eax, [rax]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov rcx, rax
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    mov eax, [rax]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov rcx, rax
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_path_start_x]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    mov eax, [rax]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_path_start_y]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    mov eax, [rax]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_path_x0]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    mov eax, [rax]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_path_y0]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    mov eax, [rax]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, 108
    mov [rbp-40], rax
    jmp .endif406
.else405:
    mov rax, [rbp-40]
    push rax
    mov rax, 76
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else409
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-48], rax
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-56], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-48]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    mov rax, [rbp-56]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_line_width, 1
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_draw_stroked_line, 6
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    push rax
    mov rax, [rbp-56]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif410
.else409:
    mov rax, [rbp-40]
    push rax
    mov rax, 108
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else411
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-64], rax
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-72], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    mov eax, [rax]
    push rax
    mov rax, [rbp-64]
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-80], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    mov eax, [rax]
    push rax
    mov rax, [rbp-72]
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-88], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-80]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    mov rax, [rbp-88]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_line_width, 1
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_draw_stroked_line, 6
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    push rax
    mov rax, [rbp-80]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    push rax
    mov rax, [rbp-88]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif412
.else411:
    mov rax, [rbp-40]
    push rax
    mov rax, 72
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else413
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-96], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-96]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_line_width, 1
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_draw_stroked_line, 6
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    push rax
    mov rax, [rbp-96]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif414
.else413:
    mov rax, [rbp-40]
    push rax
    mov rax, 104
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else415
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-104], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    mov eax, [rax]
    push rax
    mov rax, [rbp-104]
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-112], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-112]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_line_width, 1
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_draw_stroked_line, 6
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    push rax
    mov rax, [rbp-112]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif416
.else415:
    mov rax, [rbp-40]
    push rax
    mov rax, 86
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else417
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-120], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    mov rax, [rbp-120]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_line_width, 1
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_draw_stroked_line, 6
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    push rax
    mov rax, [rbp-120]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif418
.else417:
    mov rax, [rbp-40]
    push rax
    mov rax, 118
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else419
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-128], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    mov eax, [rax]
    push rax
    mov rax, [rbp-128]
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-136], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    mov rax, [rbp-136]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_line_width, 1
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_draw_stroked_line, 6
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    push rax
    mov rax, [rbp-136]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif420
.else419:
    mov rax, [rbp-40]
    push rax
    mov rax, 67
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else421
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-144], rax
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-152], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-144]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    mov rax, [rbp-152]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_line_width, 1
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_draw_stroked_line, 6
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    push rax
    mov rax, [rbp-144]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    push rax
    mov rax, [rbp-152]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif422
.else421:
    mov rax, [rbp-40]
    push rax
    mov rax, 99
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else423
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-160], rax
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-168], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    mov eax, [rax]
    push rax
    mov rax, [rbp-160]
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-176], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    mov eax, [rax]
    push rax
    mov rax, [rbp-168]
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-184], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-176]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    mov rax, [rbp-184]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_line_width, 1
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_draw_stroked_line, 6
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    push rax
    mov rax, [rbp-176]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    push rax
    mov rax, [rbp-184]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif424
.else423:
    mov rax, [rbp-40]
    push rax
    mov rax, 81
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else425
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-192], rax
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-200], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-192]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    mov rax, [rbp-200]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_line_width, 1
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_draw_stroked_line, 6
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    push rax
    mov rax, [rbp-192]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    push rax
    mov rax, [rbp-200]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif426
.else425:
    mov rax, [rbp-40]
    push rax
    mov rax, 113
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else427
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-208], rax
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-216], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    mov eax, [rax]
    push rax
    mov rax, [rbp-208]
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-224], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    mov eax, [rax]
    push rax
    mov rax, [rbp-216]
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-232], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-224]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    mov rax, [rbp-232]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_line_width, 1
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_draw_stroked_line, 6
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    push rax
    mov rax, [rbp-224]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    push rax
    mov rax, [rbp-232]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif428
.else427:
    mov rax, [rbp-40]
    push rax
    mov rax, 83
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else429
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-240], rax
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-248], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-240]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    mov rax, [rbp-248]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_line_width, 1
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_draw_stroked_line, 6
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    push rax
    mov rax, [rbp-240]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    push rax
    mov rax, [rbp-248]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif430
.else429:
    mov rax, [rbp-40]
    push rax
    mov rax, 115
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else431
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-256], rax
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-264], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    mov eax, [rax]
    push rax
    mov rax, [rbp-256]
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-272], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    mov eax, [rax]
    push rax
    mov rax, [rbp-264]
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-280], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-272]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    mov rax, [rbp-280]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_line_width, 1
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_draw_stroked_line, 6
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    push rax
    mov rax, [rbp-272]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    push rax
    mov rax, [rbp-280]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif432
.else431:
    mov rax, [rbp-40]
    push rax
    mov rax, 84
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else433
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-288], rax
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-296], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-288]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    mov rax, [rbp-296]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_line_width, 1
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_draw_stroked_line, 6
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    push rax
    mov rax, [rbp-288]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    push rax
    mov rax, [rbp-296]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif434
.else433:
    mov rax, [rbp-40]
    push rax
    mov rax, 116
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else435
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-304], rax
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-312], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    mov eax, [rax]
    push rax
    mov rax, [rbp-304]
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-320], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    mov eax, [rax]
    push rax
    mov rax, [rbp-312]
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-328], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-320]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    mov rax, [rbp-328]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_line_width, 1
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_draw_stroked_line, 6
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    push rax
    mov rax, [rbp-320]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    push rax
    mov rax, [rbp-328]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif436
.else435:
    mov rax, [rbp-40]
    push rax
    mov rax, 65
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else437
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-336], rax
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-344], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-336]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    mov rax, [rbp-344]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_line_width, 1
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_draw_stroked_line, 6
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    push rax
    mov rax, [rbp-336]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    push rax
    mov rax, [rbp-344]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif438
.else437:
    mov rax, [rbp-40]
    push rax
    mov rax, 97
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else439
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-352], rax
    lea rax, [rel app_hl_svg_smoke_svg_attr_buf]
    push rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_pos]
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_scan_int, 3
    mov [rbp-360], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    mov eax, [rax]
    push rax
    mov rax, [rbp-352]
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-368], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    mov eax, [rax]
    push rax
    mov rax, [rbp-360]
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-376], rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-368]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    mov rax, [rbp-376]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_line_width, 1
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_draw_stroked_line, 6
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    push rax
    mov rax, [rbp-368]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    push rax
    mov rax, [rbp-376]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif440
.else439:
    mov rax, [rbp-40]
    push rax
    mov rax, 90
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else441
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_start_x]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_start_y]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_line_width, 1
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_draw_stroked_line, 6
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_start_x]
    mov eax, [rax]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_start_y]
    mov eax, [rax]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif442
.else441:
    mov rax, [rbp-40]
    push rax
    mov rax, 122
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else443
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_start_x]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tx, 1
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_start_y]
    mov eax, [rax]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_ty, 1
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_line_width, 1
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_draw_stroked_line, 6
    lea rax, [rel app_hl_svg_smoke_svg_path_cx]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_start_x]
    mov eax, [rax]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_path_cy]
    push rax
    lea rax, [rel app_hl_svg_smoke_svg_path_start_y]
    mov eax, [rax]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    jmp .endif444
.else443:
    jmp .fn_end_390_app_hl_svg_smoke_svg_draw_path
.endif444:
.endif442:
.endif440:
.endif438:
.endif436:
.endif434:
.endif432:
.endif430:
.endif428:
.endif426:
.endif424:
.endif422:
.endif420:
.endif418:
.endif416:
.endif414:
.endif412:
.endif410:
.endif406:
.endif402:
    jmp .wst397
.wend398:
.fn_end_390_app_hl_svg_smoke_svg_draw_path:
    FN_END app_hl_svg_smoke_svg_draw_path
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_render_node, 1, 0, FN_RET_SCALAR
FN_ARG 0, node, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else445
    jmp .fn_end_444_app_hl_svg_smoke_svg_render_node
    jmp .endif446
.else445:
.endif446:
    lea rax, [rel app_hl_svg_smoke_svg_in_fill]
    mov eax, [rax]
    mov [rbp-24], rax
    lea rax, [rel app_hl_svg_smoke_svg_in_stroke]
    mov eax, [rax]
    mov [rbp-32], rax
    lea rax, [rel app_hl_svg_smoke_svg_in_width]
    mov eax, [rax]
    mov [rbp-40], rax
    lea rax, [rel app_hl_svg_smoke_svg_tf_x]
    mov eax, [rax]
    mov [rbp-48], rax
    lea rax, [rel app_hl_svg_smoke_svg_tf_y]
    mov eax, [rax]
    mov [rbp-56], rax
    lea rax, [rel app_hl_svg_smoke_svg_tf_sx]
    mov eax, [rax]
    mov [rbp-64], rax
    lea rax, [rel app_hl_svg_smoke_svg_tf_sy]
    mov eax, [rax]
    mov [rbp-72], rax
    lea rax, [rel app_hl_svg_smoke_svg_in_fill]
    push rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-24]
    push rax
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_fill_color, 2
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_in_stroke]
    push rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-32]
    push rax
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_stroke_color, 2
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_in_width]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_line_width, 1
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_apply_transform, 1
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str24]
    push rax
    mov rax, 4
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tag_is, 3
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else447
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_draw_rect, 1
    jmp .endif448
.else447:
.endif448:
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str25]
    push rax
    mov rax, 6
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tag_is, 3
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else449
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_draw_circle, 1
    jmp .endif450
.else449:
.endif450:
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str26]
    push rax
    mov rax, 7
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tag_is, 3
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else451
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_draw_ellipse, 1
    jmp .endif452
.else451:
.endif452:
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str27]
    push rax
    mov rax, 4
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tag_is, 3
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else453
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_draw_line, 1
    jmp .endif454
.else453:
.endif454:
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str28]
    push rax
    mov rax, 7
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tag_is, 3
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else455
    mov rax, [rbp-8]
    push rax
    mov rax, 1
    push rax
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_draw_poly, 2
    jmp .endif456
.else455:
.endif456:
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str29]
    push rax
    mov rax, 8
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tag_is, 3
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else457
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    push rax
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_draw_poly, 2
    jmp .endif458
.else457:
.endif458:
    mov rax, [rbp-8]
    push rax
    lea rax, [rel app_hl_svg_smoke_str30]
    push rax
    mov rax, 4
    push rax
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_tag_is, 3
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else459
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_draw_path, 1
    jmp .endif460
.else459:
.endif460:
    mov rax, [rbp-8]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_xml_first_child, 1
    mov [rbp-80], rax
.wst461:
    mov rax, [rbp-80]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .wend462
    mov rax, [rbp-80]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_render_node, 1
    mov rax, [rbp-80]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_xml_next_sibling, 1
    mov [rbp-80], rax
    jmp .wst461
.wend462:
    lea rax, [rel app_hl_svg_smoke_svg_in_fill]
    push rax
    mov rax, [rbp-24]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_in_stroke]
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_in_width]
    push rax
    mov rax, [rbp-40]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_tf_x]
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_tf_y]
    push rax
    mov rax, [rbp-56]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_tf_sx]
    push rax
    mov rax, [rbp-64]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_tf_sy]
    push rax
    mov rax, [rbp-72]
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
.fn_end_444_app_hl_svg_smoke_svg_render_node:
    FN_END app_hl_svg_smoke_svg_render_node
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_svg_render, 6, 0, FN_RET_SCALAR
FN_ARG 0, svg_buf, FN_KIND_SCALAR
FN_ARG 1, svg_len, FN_KIND_SCALAR
FN_ARG 2, x, FN_KIND_SCALAR
FN_ARG 3, y, FN_KIND_SCALAR
FN_ARG 4, w, FN_KIND_SCALAR
FN_ARG 5, h, FN_KIND_SCALAR
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
    mov rax, [rbp-40]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx rax, al
    test rax, rax
    jz .else463
    mov rax, 1
    neg rax
    jmp .fn_end_462_app_hl_svg_smoke_svg_render
    jmp .endif464
.else463:
.endif464:
    mov rax, [rbp-48]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx rax, al
    test rax, rax
    jz .else465
    mov rax, 1
    neg rax
    jmp .fn_end_462_app_hl_svg_smoke_svg_render
    jmp .endif466
.else465:
.endif466:
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_xml_parse, 2
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx rax, al
    test rax, rax
    jz .else467
    mov rax, 1
    neg rax
    jmp .fn_end_462_app_hl_svg_smoke_svg_render
    jmp .endif468
.else467:
.endif468:
    FN_CALL app_hl_svg_smoke_xml_root, 0
    mov [rbp-64], rax
    mov rax, [rbp-64]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    test rax, rax
    jz .else469
    mov rax, 1
    neg rax
    jmp .fn_end_462_app_hl_svg_smoke_svg_render
    jmp .endif470
.else469:
.endif470:
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-24]
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
    FN_CALL app_hl_svg_smoke_svg_setup_viewbox, 5
    lea rax, [rel app_hl_svg_smoke_svg_in_fill]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_in_stroke]
    push rax
    mov rax, 1
    neg rax
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_in_width]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_tf_x]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_tf_y]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_tf_sx]
    push rax
    mov rax, 65536
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    lea rax, [rel app_hl_svg_smoke_svg_tf_sy]
    push rax
    mov rax, 65536
    mov rcx, rax
    pop rax
    mov [rax], ecx
    xor rax, rax
    mov rax, [rbp-64]
    push rax
    lea rax, [rel app_hl_svg_smoke_str31]
    push rax
    mov rax, 10
    push rax
    mov rax, 1
    neg rax
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_style_color, 4
    mov [rbp-72], rax
    mov rax, [rbp-72]
    push rax
    mov rax, 0
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    test rax, rax
    jz .else471
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-72]
    push rax
    pop r8
    pop r10
    pop rdx
    pop rsi
    pop rdi
    mov rax, 2
    syscall
    jmp .endif472
.else471:
.endif472:
    mov rax, [rbp-64]
    push rax
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_render_node, 1
    mov rax, 0
    jmp .fn_end_462_app_hl_svg_smoke_svg_render
.fn_end_462_app_hl_svg_smoke_svg_render:
    FN_END app_hl_svg_smoke_svg_render
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_svg_smoke_smoke_draw, 1, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    lea rax, [rel app_hl_svg_smoke_smoke_svg]
    push rax
    mov rax, 634
    push rax
    mov rax, 0
    push rax
    mov rax, 0
    push rax
    mov rax, 200
    push rax
    mov rax, 200
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    FN_CALL app_hl_svg_smoke_svg_render, 6
.fn_end_472_app_hl_svg_smoke_smoke_draw:
    FN_END app_hl_svg_smoke_smoke_draw
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
app_hl_svg_smoke_smoke_svg: db 60, 115, 118, 103, 32, 118, 101, 114, 115, 105, 111, 110, 61, 34, 50, 34, 32, 118, 105, 101, 119, 66, 111, 120, 61, 34, 48, 32, 48, 32, 49, 48, 48, 32, 49, 48, 48, 34, 32, 115, 116, 121, 108, 101, 61, 34, 98, 97, 99, 107, 103, 114, 111, 117, 110, 100, 58, 114, 103, 98, 40, 49, 44, 50, 44, 51, 41, 34, 62, 60, 103, 32, 116, 114, 97, 110, 115, 102, 111, 114, 109, 61, 34, 116, 114, 97, 110, 115, 108, 97, 116, 101, 40, 50, 44, 51, 41, 34, 32, 115, 116, 121, 108, 101, 61, 34, 102, 105, 108, 108, 58, 35, 51, 51, 54, 54, 57, 57, 59, 115, 116, 114, 111, 107, 101, 58, 119, 104, 105, 116, 101, 59, 115, 116, 114, 111, 107, 101, 45, 119, 105, 100, 116, 104, 58, 49, 34, 62, 60, 114, 101, 99, 116, 32, 120, 61, 34, 52, 34, 32, 121, 61, 34, 52, 34, 32, 119, 105, 100, 116, 104, 61, 34, 50, 48, 34, 32, 104, 101, 105, 103, 104, 116, 61, 34, 49, 48, 34, 47, 62, 60, 99, 105, 114, 99, 108, 101, 32, 99, 120, 61, 34, 53, 48, 34, 32, 99, 121, 61, 34, 50, 48, 34, 32, 114, 61, 34, 56, 34, 32, 115, 116, 121, 108, 101, 61, 34, 102, 105, 108, 108, 58, 35, 102, 56, 48, 34, 47, 62, 60, 101, 108, 108, 105, 112, 115, 101, 32, 99, 120, 61, 34, 55, 54, 34, 32, 99, 121, 61, 34, 50, 50, 34, 32, 114, 120, 61, 34, 49, 48, 34, 32, 114, 121, 61, 34, 54, 34, 32, 102, 105, 108, 108, 61, 34, 103, 114, 101, 101, 110, 34, 47, 62, 60, 108, 105, 110, 101, 32, 120, 49, 61, 34, 48, 34, 32, 121, 49, 61, 34, 52, 48, 34, 32, 120, 50, 61, 34, 49, 48, 48, 34, 32, 121, 50, 61, 34, 52, 48, 34, 32, 115, 116, 114, 111, 107, 101, 61, 34, 114, 101, 100, 34, 32, 115, 116, 114, 111, 107, 101, 45, 119, 105, 100, 116, 104, 61, 34, 50, 34, 47, 62, 60, 112, 111, 108, 121, 103, 111, 110, 32, 112, 111, 105, 110, 116, 115, 61, 34, 49, 48, 44, 54, 48, 32, 51, 48, 44, 54, 48, 32, 50, 48, 44, 56, 48, 34, 32, 102, 105, 108, 108, 61, 34, 98, 108, 117, 101, 34, 47, 62, 60, 112, 111, 108, 121, 108, 105, 110, 101, 32, 112, 111, 105, 110, 116, 115, 61, 34, 52, 48, 44, 54, 48, 32, 53, 48, 44, 55, 48, 32, 54, 48, 44, 54, 48, 34, 32, 102, 105, 108, 108, 61, 34, 110, 111, 110, 101, 34, 32, 115, 116, 114, 111, 107, 101, 61, 34, 35, 48, 48, 102, 102, 102, 102, 34, 47, 62, 60, 112, 97, 116, 104, 32, 100, 61, 34, 77, 32, 55, 48, 32, 54, 48, 32, 81, 32, 56, 48, 32, 53, 48, 32, 57, 48, 32, 54, 48, 32, 65, 32, 53, 32, 53, 32, 48, 32, 48, 32, 49, 32, 57, 48, 32, 56, 48, 32, 90, 34, 32, 102, 105, 108, 108, 61, 34, 110, 111, 110, 101, 34, 32, 115, 116, 114, 111, 107, 101, 61, 34, 35, 102, 102, 48, 48, 102, 102, 34, 47, 62, 60, 47, 103, 62, 60, 47, 115, 118, 103, 62, 0
app_hl_svg_smoke_str1: db 115, 116, 121, 108, 101, 0
app_hl_svg_smoke_str2: db 102, 105, 108, 108, 0
app_hl_svg_smoke_str3: db 115, 116, 114, 111, 107, 101, 0
app_hl_svg_smoke_str4: db 118, 105, 101, 119, 66, 111, 120, 0
app_hl_svg_smoke_str5: db 115, 116, 114, 111, 107, 101, 45, 119, 105, 100, 116, 104, 0
app_hl_svg_smoke_str6: db 116, 114, 97, 110, 115, 102, 111, 114, 109, 0
app_hl_svg_smoke_str7: db 116, 114, 97, 110, 115, 108, 97, 116, 101, 0
app_hl_svg_smoke_str8: db 115, 99, 97, 108, 101, 0
app_hl_svg_smoke_str9: db 120, 0
app_hl_svg_smoke_str10: db 121, 0
app_hl_svg_smoke_str11: db 119, 105, 100, 116, 104, 0
app_hl_svg_smoke_str12: db 104, 101, 105, 103, 104, 116, 0
app_hl_svg_smoke_str13: db 99, 120, 0
app_hl_svg_smoke_str14: db 99, 121, 0
app_hl_svg_smoke_str15: db 114, 0
app_hl_svg_smoke_str16: db 114, 120, 0
app_hl_svg_smoke_str17: db 114, 121, 0
app_hl_svg_smoke_str18: db 120, 49, 0
app_hl_svg_smoke_str19: db 121, 49, 0
app_hl_svg_smoke_str20: db 120, 50, 0
app_hl_svg_smoke_str21: db 121, 50, 0
app_hl_svg_smoke_str22: db 112, 111, 105, 110, 116, 115, 0
app_hl_svg_smoke_str23: db 100, 0
app_hl_svg_smoke_str24: db 114, 101, 99, 116, 0
app_hl_svg_smoke_str25: db 99, 105, 114, 99, 108, 101, 0
app_hl_svg_smoke_str26: db 101, 108, 108, 105, 112, 115, 101, 0
app_hl_svg_smoke_str27: db 108, 105, 110, 101, 0
app_hl_svg_smoke_str28: db 112, 111, 108, 121, 103, 111, 110, 0
app_hl_svg_smoke_str29: db 112, 111, 108, 121, 108, 105, 110, 101, 0
app_hl_svg_smoke_str30: db 112, 97, 116, 104, 0
app_hl_svg_smoke_str31: db 98, 97, 99, 107, 103, 114, 111, 117, 110, 100, 0
app_hl_svg_smoke_svg_attr_buf: times 256 db 0
app_hl_svg_smoke_svg_tag_buf: times 16 db 0
app_hl_svg_smoke_svg_tri_buf: times 24 db 0
app_hl_svg_smoke_svg_vb_x: times 4 db 0
app_hl_svg_smoke_svg_vb_y: times 4 db 0
app_hl_svg_smoke_svg_vb_w: times 4 db 0
app_hl_svg_smoke_svg_vb_h: times 4 db 0
app_hl_svg_smoke_svg_dst_x: times 4 db 0
app_hl_svg_smoke_svg_dst_y: times 4 db 0
app_hl_svg_smoke_svg_dst_w: times 4 db 0
app_hl_svg_smoke_svg_dst_h: times 4 db 0
app_hl_svg_smoke_svg_sx: times 4 db 0
app_hl_svg_smoke_svg_sy: times 4 db 0
app_hl_svg_smoke_svg_path_pos: times 4 db 0
app_hl_svg_smoke_svg_path_x0: times 4 db 0
app_hl_svg_smoke_svg_path_y0: times 4 db 0
app_hl_svg_smoke_svg_path_cx: times 4 db 0
app_hl_svg_smoke_svg_path_cy: times 4 db 0
app_hl_svg_smoke_svg_path_start_x: times 4 db 0
app_hl_svg_smoke_svg_path_start_y: times 4 db 0
app_hl_svg_smoke_svg_tmp_color: times 4 db 0
app_hl_svg_smoke_svg_in_fill: times 4 db 0
app_hl_svg_smoke_svg_in_stroke: times 4 db 0
app_hl_svg_smoke_svg_in_width: times 4 db 0
app_hl_svg_smoke_svg_tf_x: times 4 db 0
app_hl_svg_smoke_svg_tf_y: times 4 db 0
app_hl_svg_smoke_svg_tf_sx: times 4 db 0
app_hl_svg_smoke_svg_tf_sy: times 4 db 0
