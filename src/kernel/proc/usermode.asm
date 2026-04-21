; ============================================================================
; NexusOS v3.0 - Usermode Transition
; Clean L3 callback path for app draw/click/key handlers.
; ============================================================================
bits 64

%include "constants.inc"
%include "macros.inc"
%include "syscall_user.inc"

extern ser_print_hex64
extern app_terminal_blob_end
extern app_terminal_draw
extern app_terminal_click
extern app_terminal_key
extern app_terminal_kernel_draw
extern app_terminal_kernel_key
; NOTE: app_blob_start/app_blob_end symbols still exist in kernel.bin (labels
; left after post-build byte-strip), but their contents are zeros. All kernel
; code now resolves the live blob through the loaded pointer at VBE_INFO+0x20.
extern app_blob_start
extern app_blob_end
; Variables moved to the end of file to avoid segment clobbering in monolithic build.

L3_RT_ENTRY          equ 0
L3_RT_ARG0           equ 8
L3_RT_ARG1           equ 16
L3_RT_ARG2           equ 24
L3_RT_KERNEL_RSP     equ 32
L3_RT_KERNEL_RFLAGS  equ 40
L3_RT_USER_RSP       equ 48
L3_RT_USER_RIP       equ 56
L3_RT_USER_RFLAGS    equ 64
L3_RT_APP_BASE       equ 72
L3_RT_SYSCALL_NUM    equ 80
L3_RT_USER_RDX       equ 88
L3_RT_USER_R8        equ 96
L3_RT_USER_R9        equ 104
L3_RT_USER_R10       equ 112
L3_RT_SIZE           equ 120
L3_APP_CODE_OFF      equ 512
L3_SHADOW_WIN_OFF    equ (APP_SLOT_SIZE - 512)
L3_SLOT_META_OFF     equ 0
L3_SLOT_MAGIC_OFF    equ 0
L3_SLOT_TERM_CTX_OFF equ 160
L3_SLOT_USER_STACK_TOP equ (APP_SLOT_SIZE - 256)
TERM_CTX_X           equ 160
TERM_CTX_Y           equ 168
TERM_CTX_W           equ 176
TERM_CTX_H           equ 184
L3_SLOT_MAGIC        equ 0x30544F4C5358414E

section .text

global enter_usermode
global call_app_l3
global call_app_l3_return
global l3_prepare_test_callback
global l3_runtime_ptr
global l3_user_stack_top
global l3_syscall_stack_top
global l3_install_app_done_trampoline
global l3_translate_target
global l3_copy_app_blob_to_slot
global l3_slot_resolve_app_ptr
global app_blob_init
global app_blob_base_v
global app_blob_end_v
global app_blob_size_v

; Populate app_blob_base_v / size_v from VBE_INFO+0x20/+0x28 (filled by the
; UEFI loader after reading APPS.BIN). Falls back to the (now-zeroed) embedded
; symbols if no blob was loaded — in that case the apps are effectively absent
; but the kernel still boots.
app_blob_init:
    push rax
    push rcx
    mov rax, [abs 0x9000 + 0x20]        ; VBE_INFO + 0x20 = apps base
    mov rcx, [abs 0x9000 + 0x28]        ; VBE_INFO + 0x28 = apps size
    test rax, rax
    jnz .have_loaded
    ; Fallback: embedded symbols (bytes zeroed post-build, but size still valid)
    lea rax, [rel app_blob_start]
    lea rcx, [rel app_blob_end]
    sub rcx, rax
.have_loaded:
    mov [rel app_blob_base_v], rax
    mov [rel app_blob_size_v], rcx
    add rax, rcx
    mov [rel app_blob_end_v], rax
    pop rcx
    pop rax
    ret

; l3_prepare_test_callback - copy demo user code into slot app arena
; EDI = slot, RAX = entry pointer in APP_DATA space
l3_prepare_test_callback:
    mov eax, edi
    imul rax, APP_SLOT_SIZE
    add rax, APP_DATA_ADDR
    mov rdi, rax
    mov r8, rax
    lea rsi, [rel l3_test_blob]
    mov ecx, l3_test_blob_end - l3_test_blob
    rep movsb
    mov rax, r8
    ret

; enter_usermode - generic helper, currently uses slot 0 stack
; RDI = user RIP
enter_usermode:
    mov r10, rdi
    push qword GDT64_USER_DATA
    mov edi, 0
    call l3_user_stack_top
    push rax
    pushfq
    pop rax
    and rax, ~0x100
    or  rax, 0x200
    push rax
    push qword GDT64_USER_CODE
    push r10
    iretq

; l3_runtime_ptr - EDI=slot -> RAX=runtime ptr
l3_runtime_ptr:
    mov eax, edi
    imul rax, L3_RT_SIZE
    lea rdx, [rel l3_runtime]
    add rax, rdx
    ret

; l3_user_stack_top - EDI=slot -> RAX=top of user stack
l3_user_stack_top:
    mov eax, edi
    imul rax, L3_USER_STACK_SIZE
    mov rdx, APP_DATA_ADDR
    imul rcx, rdi, APP_SLOT_SIZE
    add rdx, rcx
    add rdx, L3_SLOT_USER_STACK_TOP
    sub rdx, L3_USER_STACK_SIZE
    mov rax, rdx
    add rax, L3_USER_STACK_SIZE
    and rax, -16
    ret

; l3_syscall_stack_top - EDI=slot -> RAX=top of syscall stack
l3_syscall_stack_top:
    mov eax, edi
    imul rax, L3_SYSCALL_STACK_SIZE
    lea rdx, [rel l3_syscall_stacks]
    add rax, rdx
    add rax, L3_SYSCALL_STACK_SIZE
    and rax, -16
    ret

l3_install_app_done_trampoline:
    push rcx
    push rdi
    push rsi
    mov eax, edi
    imul rax, APP_SLOT_SIZE
    add rax, APP_DATA_ADDR
    ; Place trampoline inside the first-page meta region so it stays in the
    ; slot's executable half (W^X: upper 512KB of each slot is NX).
    ; Meta region 0xC0..0x1FF is unused (magic at 0x00, term_ctx at 0xA0..0xC0,
    ; app code blob starts at 0x200).
    add rax, 0x1C0
    mov rdi, rax
    lea rsi, [rel l3_app_done_blob]
    mov ecx, l3_app_done_blob_end - l3_app_done_blob
    rep movsb
    mov rax, rdi
    sub rax, l3_app_done_blob_end - l3_app_done_blob
    pop rsi
    pop rdi
    pop rcx
    ret

; l3_copy_app_blob_to_slot - copy the built-in user blob into a slot arena
; EDI = slot
l3_copy_app_blob_to_slot:
    push rcx
    push rdi
    push rsi
    push r8
    mov eax, edi
    imul rax, APP_SLOT_SIZE
    add rax, APP_DATA_ADDR
    mov r8, rax
    mov rdi, rax
    mov rsi, [rel app_blob_base_v]
    mov rcx, [rel app_blob_size_v]
    cld
    rep movsb
    mov rax, L3_SLOT_MAGIC
    mov [r8 + L3_SLOT_MAGIC_OFF], rax
    mov rax, r8
    pop r8
    pop rsi
    pop rdi
    pop rcx
    ret

; l3_slot_resolve_app_ptr
; EDI = slot, RSI = kernel pointer inside the built-in user blob
; Returns: RAX = slot-local pointer, or RSI unchanged if outside blob
l3_slot_resolve_app_ptr:
    lea r8, [rel app_blob_start]
    lea r9, [rel app_blob_end]
    mov rax, rsi
    cmp rax, r8
    jb .slot_resolve_done
    cmp rax, r9
    jae .slot_resolve_done
    push rdx
    sub rax, r8
    mov edx, edi
    imul rdx, APP_SLOT_SIZE
    add rdx, APP_DATA_ADDR
    add rax, rdx
    pop rdx
.slot_resolve_done:
    ret

; l3_translate_target
; RDI = kernel callback target
; RSI = slot app base
; Returns: RAX = translated user target (or original target if no mapping applies)
l3_translate_target:
    lea r8, [rel app_blob_start]
    lea r9, [rel app_blob_end]
    mov rax, rdi
    cmp rax, r8
    jb .translate_done
    cmp rax, r9
    jae .translate_done

    sub rax, r8
    add rax, rsi
.translate_done:
    ret

; call_app_l3
; RDI = target function
; RSI = arg0 (window ptr)
; RDX = arg1
; RCX = arg2
call_app_l3:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r13, rdi            ; preserve target
    mov r14, rsi            ; preserve arg0
    mov r15, rdx            ; preserve arg1
    mov rbx, rcx            ; preserve arg2
    xor r11d, r11d

.pick_slot:
    ; Pick slot from per-window app_data arena, not window ID.
    xor eax, eax
    test r14, r14
    jz .slot_ready
    mov rax, [r14 + WIN_OFF_APPDATA]
    sub rax, APP_DATA_ADDR
    js .slot_zero
    shr rax, 20
    cmp eax, MAX_WINDOWS
    jb .slot_ready
.slot_zero:
    xor eax, eax
.slot_ready:
    mov [l3_current_slot], eax
    mov edi, eax
    call l3_runtime_ptr
    mov r12, rax

    mov [r12 + L3_RT_ENTRY], r13
    mov [r12 + L3_RT_ARG0], r14
    mov [r12 + L3_RT_ARG1], r15
    mov [r12 + L3_RT_ARG2], rbx
    mov [r12 + L3_RT_KERNEL_RSP], rsp
    pushfq
    pop qword [r12 + L3_RT_KERNEL_RFLAGS]
    mov eax, [l3_current_slot]
    imul rax, APP_SLOT_SIZE
    add rax, APP_DATA_ADDR
    mov [r12 + L3_RT_APP_BASE], rax
    mov rdx, L3_SLOT_MAGIC
    cmp [rax + L3_SLOT_MAGIC_OFF], rdx
    je .translate_generic
    mov edi, [l3_current_slot]
    call l3_copy_app_blob_to_slot
.translate_generic:
    mov rdi, r13
    mov rsi, rax
    call l3_translate_target
    mov r13, rax
.target_ready:
    mov [r12 + L3_RT_ENTRY], r13

    ; Ring-3 code cannot dereference the kernel window struct directly.
    ; Mirror the current window into the slot arena and repoint arg0 there.
    test r14, r14
    jz .args_ready
    mov rsi, r14
    mov rdi, [r12 + L3_RT_APP_BASE]
    add rdi, L3_SHADOW_WIN_OFF
    mov rcx, WINDOW_STRUCT_SIZE / 8
    cld
    rep movsq
    mov rax, [r12 + L3_RT_APP_BASE]
    mov [rdi - WINDOW_STRUCT_SIZE + WIN_OFF_APPDATA], rax
    lea r14, [rax + L3_SHADOW_WIN_OFF]
    mov [r12 + L3_RT_ARG0], r14
.args_ready:
    SER 'U'
    mov rdi, r13
    call ser_print_hex64
    SER '@'
    mov rdi, r14
    call ser_print_hex64
    SER ':'
    mov rdi, r15
    call ser_print_hex64
    SER ':'
    mov rdi, rbx
    call ser_print_hex64
    SER 13
    SER 10

    mov edi, [l3_current_slot]
    call l3_user_stack_top
    sub rax, 8
    push rax
    mov edi, [l3_current_slot]
    call l3_install_app_done_trampoline
    mov rdx, rax
    pop rax
    mov [rax], rdx
    mov [r12 + L3_RT_USER_RSP], rax

    push qword GDT64_USER_DATA
    push qword [r12 + L3_RT_USER_RSP]
    pushfq
    pop rax
    and rax, ~0x300
    push rax
    push qword GDT64_USER_CODE
    push r13
    mov rdi, r14
    mov rsi, r15
    mov rdx, rbx
    iretq

call_app_l3_app_done:
    mov ax, GDT64_USER_DATA
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    SYS_APP_DONE
    ud2

call_app_l3_return:
    mov eax, [l3_current_slot]
    cmp eax, MAX_WINDOWS
    jb .ret_slot_ready
    xor eax, eax
.ret_slot_ready:
    mov [l3_current_slot], eax
    mov edi, eax
    call l3_runtime_ptr
    mov r12, rax
    mov r10, [r12 + L3_RT_KERNEL_RSP]
    SER 'R'
    mov rdi, [r12 + L3_RT_KERNEL_RSP]
    call ser_print_hex64
    SER ':'
    mov rdi, rbp
    call ser_print_hex64
    SER ':'
    mov rdi, rbx
    call ser_print_hex64
    SER ':'
    mov rdi, r14
    call ser_print_hex64
    SER ':'
    mov rdi, r15
    call ser_print_hex64
    SER 13
    SER 10
    mov rsp, [r12 + L3_RT_KERNEL_RSP]
    push qword [r12 + L3_RT_KERNEL_RFLAGS]
    popfq

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

; --- Dummy usermode code for testing ---
global test_usermode_proc
test_usermode_proc:
    jmp $

l3_app_done_blob:
    mov eax, 10
    syscall
    ud2
l3_app_done_blob_end:

l3_test_blob:
    lea rdi, [rel .msg]
    SYS_PRINT rdi
    ret
.msg:
    db "L3 test callback ok", 0
l3_test_blob_end:

; --- Data Sections ---
section .data
align 8
app_blob_base_v:     dq 0
app_blob_end_v:      dq 0
app_blob_size_v:     dq 0
global l3_current_slot
l3_current_slot:     dd -1
align 8
global l3_tmp_user_rip
l3_tmp_user_rip:     dq 0
global l3_tmp_user_rflags
l3_tmp_user_rflags:  dq 0
global l3_tmp_user_rsp
l3_tmp_user_rsp:     dq 0
global l3_tmp_syscall_num
l3_tmp_syscall_num:  dq 0
global l3_tmp_user_rdi
l3_tmp_user_rdi:     dq 0
global l3_tmp_user_rsi
l3_tmp_user_rsi:     dq 0
global l3_tmp_user_rdx
l3_tmp_user_rdx:     dq 0
global l3_tmp_user_r8
l3_tmp_user_r8:      dq 0
global l3_tmp_user_r9
l3_tmp_user_r9:      dq 0
global l3_tmp_user_r10
l3_tmp_user_r10:     dq 0

; --- BSS Section (Always last) ---
section .bss
alignb 4096
global l3_syscall_stacks
l3_syscall_stacks:   resb (MAX_WINDOWS * L3_SYSCALL_STACK_SIZE)
alignb 16
global l3_runtime
; Keep this in sync with L3_RT_SIZE above. A smaller allocation corrupts
; adjacent state as soon as multiple ring-3 callbacks run.
l3_runtime:          resb (MAX_WINDOWS * L3_RT_SIZE)

section .text
