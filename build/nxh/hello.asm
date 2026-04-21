; NexusHL generated — do not edit by hand
; app="HelloHL" stack=4096
bits 64
section .text
global app_hl_hello_hello_draw
app_hl_hello_hello_draw:
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    push rbx
    push r12
    lea rax, [rel app_hl_hello_s_draw]
    push rax
    pop rdi
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
    push rax
    pop r8
    pop r10
    pop rdx
    pop rsi
    pop rdi
    mov rax, 3
    syscall
.fn_end_0_app_hl_hello_hello_draw:
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
global app_hl_hello_hello_click
app_hl_hello_hello_click:
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    push rbx
    push r12
    lea rax, [rel app_hl_hello_s_click]
    push rax
    pop rdi
    mov rax, 0
    syscall
.fn_end_0_app_hl_hello_hello_click:
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
global app_hl_hello_hello_key
app_hl_hello_hello_key:
    push rbp
    mov rbp, rsp
    sub rsp, 512
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    push rbx
    push r12
    mov rax, [rbp-16]
    push rax
    mov rax, 27
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    test rax, rax
    jz .else1
    lea rax, [rel app_hl_hello_s_key_esc]
    push rax
    pop rdi
    mov rax, 0
    syscall
    jmp .endif2
.else1:
.endif2:
.fn_end_0_app_hl_hello_hello_key:
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
global app_hl_hello_hello_boot
app_hl_hello_hello_boot:
    push rbp
    mov rbp, rsp
    sub rsp, 512
    push rbx
    push r12
    lea rax, [rel app_hl_hello_s_boot]
    push rax
    pop rdi
    mov rax, 0
    syscall
.fn_end_2_app_hl_hello_hello_boot:
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
section .rodata
app_hl_hello_s_boot: db "[nxhl] hello boot", 0
app_hl_hello_s_draw: db "[nxhl] hello draw", 0
app_hl_hello_s_click: db "[nxhl] hello click", 0
app_hl_hello_s_key_esc: db "[nxhl] hello esc", 0
app_hl_hello_s_title: db "NexusHL Hello", 0
