; ============================================================================
; NexusOS v3.0 - System Call Handler (64-bit Long Mode)
; Clean L3 syscall path. Saves user state before any helper calls.
; ============================================================================
bits 64

%include "constants.inc"
%include "macros.inc"

; MSR Addresses for Syscall
IA32_EFER           equ 0xC0000080
IA32_STAR           equ 0xC0000081
IA32_LSTAR          equ 0xC0000082
IA32_FMASK          equ 0xC0000084

L3_RT_KERNEL_RFLAGS equ 40
L3_RT_USER_RSP      equ 48
L3_RT_USER_RIP      equ 56
L3_RT_USER_RFLAGS   equ 64
L3_RT_SYSCALL_NUM   equ 80
L3_RT_USER_RDX      equ 88
L3_RT_USER_R8       equ 96
L3_RT_USER_R9       equ 104
L3_RT_USER_R10      equ 112
L3_RT_SIZE          equ 120


; Variables moved to the end of file to avoid segment clobbering in monolithic build.

extern debug_print
extern fat16_file_count
extern fat16_get_entry
extern fat16_change_dir
extern fat16_read_file
extern fat16_format_name
extern fat16_write_file
extern fat16_sync_root
extern wm_create_window_ex
extern wm_close_window
extern app_launch
extern display_set_mode
extern cursor_init
extern render_rect
extern render_text
extern l3_current_slot
extern l3_runtime
extern l3_syscall_stacks
extern call_app_l3_return
extern ser_print_hex64

L3_RT_ENTRY          equ 0
L3_RT_ARG0           equ 8
L3_RT_ARG1           equ 16
L3_RT_ARG2           equ 24
L3_RT_KERNEL_RSP     equ 32

section .text

global syscall_init
syscall_init:
    push rax
    push rcx
    push rdx

    mov ecx, IA32_EFER
    rdmsr
    or eax, 1
    wrmsr

    mov ecx, IA32_STAR
    xor eax, eax
    mov edx, 0x001B0008
    wrmsr

    mov ecx, IA32_LSTAR
    lea rax, [rel syscall_entry]
    push rax
    push rdi
    SER 'L'
    mov rdi, rax
    call ser_print_hex64
    SER 13
    SER 10
    pop rdi
    pop rax
    mov rdx, rax
    shr rdx, 32
    wrmsr

    mov ecx, IA32_FMASK
    mov eax, 0x00000700
    xor edx, edx
    wrmsr

    pop rdx
    pop rcx
    pop rax
    ret

global syscall_entry
syscall_entry:
    ; Save critical SYSCALL state into the active slot runtime before any
    ; helper calls. Using shared globals here lets one ring-3 callback
    ; corrupt another callback's return path.
    push rbx
    push rdx
    mov ebx, [rel l3_current_slot]
    cmp ebx, MAX_WINDOWS
    jb .slot_ok_entry
    xor ebx, ebx
    mov [rel l3_current_slot], ebx
.slot_ok_entry:
    imul rbx, L3_RT_SIZE
    lea rdx, [rel l3_runtime]
    add rbx, rdx
    mov [rbx + L3_RT_USER_RIP], rcx
    mov [rbx + L3_RT_USER_RFLAGS], r11
    mov [rbx + L3_RT_USER_RSP], rsp
    mov [rbx + L3_RT_SYSCALL_NUM], rax
    mov [rbx + L3_RT_ARG0], rdi
    mov [rbx + L3_RT_ARG1], rsi
    mov rdx, [rsp]
    mov [rbx + L3_RT_USER_RDX], rdx
    mov [rbx + L3_RT_USER_R8], r8
    mov [rbx + L3_RT_USER_R9], r9
    mov [rbx + L3_RT_USER_R10], r10
    pop rdx
    pop rbx
    mov ax, GDT64_DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; Switch to syscall stack without calling out while we're still on the
    ; user stack. A normal CALL would push a return address to user memory.
    mov eax, [rel l3_current_slot]
    cmp eax, MAX_WINDOWS
    jb .slot_ok_stack
    xor eax, eax
    mov [rel l3_current_slot], eax
.slot_ok_stack:
    imul rax, L3_SYSCALL_STACK_SIZE
    lea rdx, [rel l3_syscall_stacks]
    add rax, rdx
    add rax, L3_SYSCALL_STACK_SIZE
    and rax, -16
    
    mov rsp, rax             ; Now on Kernel Syscall Stack
    
    ; Push usermode context manually so PUSH_ALL has it
    push rbx
    mov ebx, [rel l3_current_slot]
    cmp ebx, MAX_WINDOWS
    jb .slot_ok_reload
    xor ebx, ebx
    mov [rel l3_current_slot], ebx
.slot_ok_reload:
    imul rbx, L3_RT_SIZE
    lea rdx, [rel l3_runtime]
    add rbx, rdx
    mov rcx, [rbx + L3_RT_USER_RIP]
    mov r11, [rbx + L3_RT_USER_RFLAGS]
    mov rax, [rbx + L3_RT_SYSCALL_NUM]
    mov rdi, [rbx + L3_RT_ARG0]
    mov rsi, [rbx + L3_RT_ARG1]
    mov rdx, [rbx + L3_RT_USER_RDX]
    mov r8,  [rbx + L3_RT_USER_R8]
    mov r9,  [rbx + L3_RT_USER_R9]
    mov r10, [rbx + L3_RT_USER_R10]
    pop rbx
    
    cld
    PUSH_ALL

    inc qword [syscall_count]

    cmp rax, 0
    je .sc_print
    cmp rax, 1
    je .sc_exit
    cmp rax, 2
    je .sc_gui_rect
    cmp rax, 3
    je .sc_gui_text
    cmp rax, 4
    je .sc_fs_count
    cmp rax, 5
    je .sc_fs_entry
    cmp rax, 6
    je .sc_fs_chdir
    cmp rax, 7
    je .sc_wm_create
    cmp rax, 8
    je .sc_fs_read
    cmp rax, 9
    je .sc_wm_handlers
    cmp rax, 10
    je .sc_app_done
    cmp rax, 11
    je .sc_fs_format_name
    cmp rax, 12
    je .sc_app_launch
    cmp rax, 13
    je .sc_fs_write
    cmp rax, 14
    je .sc_fs_sync_root
    cmp rax, 15
    je .sc_wm_close
    cmp rax, 16
    je .sc_display_set_mode
    cmp rax, 17
    je .sc_cursor_init
    jmp .done

.sc_print:
    mov rsi, rdi
    call debug_print
    jmp .done

.sc_exit:
    jmp .done

.sc_gui_rect:
    mov rcx, r10
    call render_rect
    jmp .done

.sc_gui_text:
    mov rcx, r10
    call render_text
    jmp .done

.sc_fs_count:
    call fat16_file_count
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_fs_entry:
    call fat16_get_entry
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_fs_chdir:
    mov rax, rdi
    call fat16_change_dir
    jmp .done

.sc_wm_create:
    mov rcx, r10
    call wm_create_window_ex
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_fs_read:
    call fat16_read_file
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_wm_handlers:
    mov rax, rdi
    imul rax, WINDOW_STRUCT_SIZE
    add rax, WINDOW_POOL_ADDR
    mov [rax + WIN_OFF_CLICKFN], rsi
    mov [rax + WIN_OFF_KEYFN], rdx
    jmp .done

.sc_fs_format_name:
    push rdi
    push rsi
    mov r8, rsi
    mov rsi, rdi
    mov rdi, r8
    call fat16_format_name
    pop rsi
    pop rdi
    jmp .done

.sc_app_launch:
    call app_launch
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_fs_write:
    call fat16_write_file
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_fs_sync_root:
    call fat16_sync_root
    jmp .done

.sc_wm_close:
    call wm_close_window
    jmp .done

.sc_display_set_mode:
    call display_set_mode
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_cursor_init:
    call cursor_init
    jmp .done

.sc_app_done:
    POP_ALL
    jmp call_app_l3_return

.done:
    mov r10, [rsp + ALL_RCX]
    mov r9,  [rsp + ALL_R11]
.no_ret_log:
    ; Safe return: POP_ALL restores everything.
    ; Then we must load the transition state WITHOUT clobbering the restored registers.
    ; We already have the user state in the l3_runtime, but we can't clobber R11/R10
    ; after popping them.
    ; SOLUTION: Load them into the stack frame before IRETQ.
    
    POP_ALL

    ; Now RSP points to the syscall stack top (empty).
    ; We need to get back to usermode.
    ; We use the values saved in the l3_tmp globals during entry.
    
    mov eax, [rel l3_current_slot]
    cmp eax, MAX_WINDOWS
    jb .slot_ok_return
    xor eax, eax
    mov [rel l3_current_slot], eax
.slot_ok_return:
    imul rax, L3_RT_SIZE
    lea rdx, [rel l3_runtime]
    add rdx, rax
    push qword GDT64_USER_DATA           ; SS
    push qword [rdx + L3_RT_USER_RSP]    ; RSP
    push qword [rdx + L3_RT_USER_RFLAGS] ; RFLAGS
    push qword GDT64_USER_CODE           ; CS
    push qword [rdx + L3_RT_USER_RIP]    ; RIP
    iretq

global test_syscall_proc
test_syscall_proc:
    mov rax, 0
    lea rdi, [rel szHelloUser]
    syscall
.loop:
    jmp .loop

; --- Data/BSS Sections moved here ---
section .data
global syscall_count
syscall_count: dq 0
szHelloUser: db "-> Hello from RING 3 (via SYSCALL)!", 0

section .text
