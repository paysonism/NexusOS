; NexusHL generated — do not edit by hand
; app="HelloHL" stack=4096
FN_BEGIN app_hl_hello_display_flags, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 64
    push rbx
    push r12
    mov rax, 24
    syscall
    jmp .fn_end_0_app_hl_hello_display_flags
.fn_end_0_app_hl_hello_display_flags:
    FN_END app_hl_hello_display_flags
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_hello_display_set_flags, 1, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_hello_display_set_flags
.fn_end_0_app_hl_hello_display_set_flags:
    FN_END app_hl_hello_display_set_flags
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_hello_display_set_mode, 3, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_hello_display_set_mode
.fn_end_0_app_hl_hello_display_set_mode:
    FN_END app_hl_hello_display_set_mode
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_hello_cursor_init, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 64
    push rbx
    push r12
    mov rax, 17
    syscall
    jmp .fn_end_0_app_hl_hello_cursor_init
.fn_end_0_app_hl_hello_cursor_init:
    FN_END app_hl_hello_cursor_init
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_hello_desktop_bg, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 64
    push rbx
    push r12
    mov rax, 26
    syscall
    jmp .fn_end_0_app_hl_hello_desktop_bg
.fn_end_0_app_hl_hello_desktop_bg:
    FN_END app_hl_hello_desktop_bg
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_hello_desktop_set_bg, 1, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_hello_desktop_set_bg
.fn_end_0_app_hl_hello_desktop_set_bg:
    FN_END app_hl_hello_desktop_set_bg
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_hello_display_native_width, 0, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_hello_display_native_width
.fn_end_0_app_hl_hello_display_native_width:
    FN_END app_hl_hello_display_native_width
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_hello_display_native_height, 0, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_hello_display_native_height
.fn_end_0_app_hl_hello_display_native_height:
    FN_END app_hl_hello_display_native_height
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_hello_display_current_width, 0, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_hello_display_current_width
.fn_end_0_app_hl_hello_display_current_width:
    FN_END app_hl_hello_display_current_width
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_hello_display_current_height, 0, 0, FN_RET_SCALAR
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
    jmp .fn_end_0_app_hl_hello_display_current_height
.fn_end_0_app_hl_hello_display_current_height:
    FN_END app_hl_hello_display_current_height
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_hello_hello_draw, 1, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    mov [rbp-8], rdi
    push rbx
    push r12
    lea rax, [rel app_hl_hello_s_draw]
    mov rdi, rax
    mov rax, 0
    syscall
    mov rax, 24
    push rax
    mov rax, 24
    push rax
    lea rax, [rel app_hl_hello_s_title]
    push rax
    mov rax, 16777215
    push rax
    mov rax, 0
    mov r8, rax
    pop r10
    pop rdx
    pop rsi
    pop rdi
    mov rax, 3
    syscall
.fn_end_0_app_hl_hello_hello_draw:
    FN_END app_hl_hello_hello_draw
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_hello_hello_click, 3, 0, FN_RET_SCALAR
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
    lea rax, [rel app_hl_hello_s_click]
    mov rdi, rax
    mov rax, 0
    syscall
.fn_end_0_app_hl_hello_hello_click:
    FN_END app_hl_hello_hello_click
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_hello_hello_key, 2, 0, FN_RET_SCALAR
FN_ARG 0, win, FN_KIND_SCALAR
FN_ARG 1, k, FN_KIND_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 80
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
    mov rax, [rbp-16]
    push rax
    mov rcx, 27
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else1
    lea rax, [rel app_hl_hello_s_key_esc]
    mov rdi, rax
    mov rax, 0
    syscall
    jmp .endif2
.else1:
.endif2:
.fn_end_0_app_hl_hello_hello_key:
    FN_END app_hl_hello_hello_key
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
FN_BEGIN app_hl_hello_hello_boot, 0, 0, FN_RET_SCALAR
    push rbp
    mov rbp, rsp
    sub rsp, 64
    push rbx
    push r12
    lea rax, [rel app_hl_hello_s_boot]
    mov rdi, rax
    mov rax, 0
    syscall
.fn_end_2_app_hl_hello_hello_boot:
    FN_END app_hl_hello_hello_boot
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
app_hl_hello_s_boot: db 91, 110, 120, 104, 108, 93, 32, 104, 101, 108, 108, 111, 32, 98, 111, 111, 116, 0
app_hl_hello_s_draw: db 91, 110, 120, 104, 108, 93, 32, 104, 101, 108, 108, 111, 32, 100, 114, 97, 119, 0
app_hl_hello_s_click: db 91, 110, 120, 104, 108, 93, 32, 104, 101, 108, 108, 111, 32, 99, 108, 105, 99, 107, 0
app_hl_hello_s_key_esc: db 91, 110, 120, 104, 108, 93, 32, 104, 101, 108, 108, 111, 32, 101, 115, 99, 0
app_hl_hello_s_title: db 78, 101, 120, 117, 115, 72, 76, 32, 72, 101, 108, 108, 111, 0
