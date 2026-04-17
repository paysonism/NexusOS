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
WIN_OFF_FLAGS       equ 40
WIN_OFF_KEYFN       equ 120
WIN_OFF_CLICKFN     equ 128
DIR_ENTRY_SIZE      equ 32
FAT16_ROOT_CACHE    equ 0xD11000
FAT16_ROOT_CACHE_SZ equ 16384
SYSCALL_MAX_STR_LEN equ 256


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
extern app_blob_base_v
extern app_blob_end_v

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
sc_get_slot_bounds:
    mov eax, [rel l3_current_slot]
    cmp eax, MAX_WINDOWS
    jb .slot_ok
    xor eax, eax
.slot_ok:
    imul rax, APP_SLOT_SIZE
    lea r8, [rax + APP_DATA_ADDR]
    lea r9, [r8 + APP_SLOT_SIZE]
    ret

; RDI=ptr, RSI=len, R8=start, R9=end -> EAX=1 if fully inside [start,end)
sc_range_in_bounds:
    mov rax, rdi
    cmp rax, r8
    jb .range_fail
    mov rdx, rdi
    add rdx, rsi
    jc .range_fail
    cmp rdx, r9
    ja .range_fail
    mov eax, 1
    ret
.range_fail:
    xor eax, eax
    ret

; RDI=ptr, RSI=len -> EAX=1 if range is inside the current app slot or the
; built-in user blob.
sc_validate_user_range:
    push rdi
    push rsi
    push r8
    push r9
    push r11
    call sc_get_slot_bounds
    call sc_range_in_bounds
    mov r11d, eax
    test r11d, r11d
    jnz .uvr_done
    mov r8, [rel app_blob_base_v]
    mov r9, [rel app_blob_end_v]
    call sc_range_in_bounds
    mov r11d, eax
.uvr_done:
    mov eax, r11d
    pop r11
    pop r9
    pop r8
    pop rsi
    pop rdi
    ret

; RDI=ptr, RSI=len -> EAX=1 if the range is inside user-owned memory.
sc_validate_user_io_range:
    call sc_validate_user_range
    ret

; RDI=ptr, RSI=max_len -> EAX=1 if a NUL-terminated string lives entirely in
; the current app slot or the built-in user blob.
sc_validate_user_cstring:
    push rdi
    push rsi
    push rcx
    push r11
    xor r11d, r11d
    xor rcx, rcx
.uvc_loop:
    cmp rcx, rsi
    jae .uvc_done
    lea rdi, [rdi + rcx]
    mov rsi, 1
    call sc_validate_user_range
    test eax, eax
    jz .uvc_done
    cmp byte [rdi], 0
    je .uvc_match
    mov rdi, [rsp + 24]
    inc rcx
    jmp .uvc_loop
.uvc_match:
    mov r11d, 1
.uvc_done:
    mov eax, r11d
    pop r11
    pop rcx
    pop rsi
    pop rdi
    ret

; RDI=opaque FAT16 entry handle -> EAX=1 if it points at an aligned entry in
; the current root/subdirectory cache.
sc_validate_dir_entry_handle:
    mov rax, rdi
    sub rax, FAT16_ROOT_CACHE
    jc .vdeh_fail
    cmp rax, FAT16_ROOT_CACHE_SZ - DIR_ENTRY_SIZE
    ja .vdeh_fail
    test eax, DIR_ENTRY_SIZE - 1
    jnz .vdeh_fail
    mov eax, 1
    ret
.vdeh_fail:
    xor eax, eax
    ret

; RDI=callback target -> EAX=1 if null or inside user-owned code/data.
sc_validate_callback_target:
    test rdi, rdi
    jz .vct_ok
    mov rsi, 1
    call sc_validate_user_range
    ret
.vct_ok:
    mov eax, 1
    ret

syscall_entry:
    ; Save critical SYSCALL state into the active slot runtime before any
    ; helper calls. Using shared globals here lets one ring-3 callback
    ; corrupt another callback's return path.
    mov [rel l3_tmp_user_rsp], rsp
    push rbx
    push rdx
    mov rdx, [rel l3_tmp_user_rsp]
    sub rdx, APP_DATA_ADDR
    jc .slot_from_global
    cmp rdx, MAX_WINDOWS * APP_SLOT_SIZE
    jae .slot_from_global
    shr rdx, 20
    mov ebx, edx
    jmp .slot_ok_entry
.slot_from_global:
    mov ebx, [rel l3_current_slot]
    cmp ebx, MAX_WINDOWS
    jb .slot_ok_entry
    xor ebx, ebx
.slot_ok_entry:
    mov [rel l3_current_slot], ebx
    imul rbx, L3_RT_SIZE
    lea rdx, [rel l3_runtime]
    add rbx, rdx
    mov [rbx + L3_RT_USER_RIP], rcx
    mov [rbx + L3_RT_USER_RFLAGS], r11
    mov rdx, [rel l3_tmp_user_rsp]
    mov [rbx + L3_RT_USER_RSP], rdx
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
    cmp qword [syscall_count], 8
    ja .dispatch
    push rax
    push rcx
    push rdi
    SER 'N'
    mov rdi, rax
    call ser_print_hex64
    SER '@'
    mov rdi, rcx
    call ser_print_hex64
    SER 13
    SER 10
    pop rdi
    pop rcx
    pop rax

.dispatch:
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
%ifdef ENABLE_USER_DEBUG_SYSCALL
    mov rsi, SYSCALL_MAX_STR_LEN
    call sc_validate_user_cstring
    test eax, eax
    jz .sc_print_reject
    mov rsi, rdi
    call debug_print
    xor eax, eax
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_print_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done
%else
    mov qword [rsp + ALL_RAX], -1
    jmp .done
%endif

.sc_exit:
    xor eax, eax
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_gui_rect:
    mov rcx, r10
    call render_rect
    xor eax, eax
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_gui_text:
    mov rdi, rdx
    mov rsi, SYSCALL_MAX_STR_LEN
    call sc_validate_user_cstring
    test eax, eax
    jz .sc_gui_text_reject
    mov rdi, [rsp + ALL_RDI]
    mov rsi, [rsp + ALL_RSI]
    mov rdx, [rsp + ALL_RDX]
    mov r10, [rsp + ALL_R10]
    mov rcx, r10
    call render_text
    xor eax, eax
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_gui_text_reject:
    mov qword [rsp + ALL_RAX], -1
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
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_wm_create:
    mov rdi, r8
    mov rsi, 64
    call sc_validate_user_cstring
    test eax, eax
    jz .sc_wm_create_reject
    mov rdi, r9
    call sc_validate_callback_target
    test eax, eax
    jz .sc_wm_create_reject
    mov rdi, [rsp + ALL_RDI]
    mov rsi, [rsp + ALL_RSI]
    mov rdx, [rsp + ALL_RDX]
    mov r10, [rsp + ALL_R10]
    mov r8,  [rsp + ALL_R8]
    mov r9,  [rsp + ALL_R9]
    mov rcx, r10
    call wm_create_window_ex
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_wm_create_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done

.sc_fs_read:
    call sc_validate_dir_entry_handle
    test eax, eax
    jz .sc_fs_read_reject
    mov rdi, rsi
    mov rsi, rdx
    call sc_validate_user_io_range
    test eax, eax
    jz .sc_fs_read_reject
    mov rdi, [rsp + ALL_RDI]
    mov rsi, [rsp + ALL_RSI]
    mov rdx, [rsp + ALL_RDX]
    call fat16_read_file
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_fs_read_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done

.sc_wm_handlers:
    ; Reject out-of-range window indices. Unsigned compare catches both
    ; negative (large unsigned) and >=MAX_WINDOWS values; without this
    ; ring-3 can turn RDI into an arbitrary kernel write primitive by
    ; choosing any RDI such that WINDOW_POOL_ADDR + RDI*256 wraps onto a
    ; chosen kernel address.
    cmp rdi, MAX_WINDOWS
    jae .sc_wm_handlers_reject
    push rdi
    mov rdi, rsi
    call sc_validate_callback_target
    pop rdi
    test eax, eax
    jz .sc_wm_handlers_reject
    push rdi
    mov rdi, rdx
    call sc_validate_callback_target
    pop rdi
    test eax, eax
    jz .sc_wm_handlers_reject
    mov rax, rdi
    imul rax, WINDOW_STRUCT_SIZE
    add rax, WINDOW_POOL_ADDR
    ; Only active windows may have handlers installed. This prevents a
    ; ring-3 app from hijacking a stale slot.
    test qword [rax + WIN_OFF_FLAGS], WF_ACTIVE
    jz .sc_wm_handlers_reject
    mov [rax + WIN_OFF_CLICKFN], rsi
    mov [rax + WIN_OFF_KEYFN], rdx
    xor eax, eax
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_wm_handlers_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done

.sc_fs_format_name:
    push rdi
    push rsi
    call sc_validate_dir_entry_handle
    pop rsi
    pop rdi
    test eax, eax
    jz .sc_fs_format_name_reject
    push rdi
    mov rdi, rsi
    mov rsi, 16
    call sc_validate_user_io_range
    pop rdi
    test eax, eax
    jz .sc_fs_format_name_reject
    mov rdi, [rsp + ALL_RDI]
    mov rsi, [rsp + ALL_RSI]
    push rdi
    push rsi
    mov r8, rsi
    mov rsi, rdi
    mov rdi, r8
    call fat16_format_name
    pop rsi
    pop rdi
    xor eax, eax
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_fs_format_name_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done

.sc_app_launch:
    call app_launch
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_fs_write:
    push rdi
    mov rsi, 11
    call sc_validate_user_range
    pop rdi
    test eax, eax
    jz .sc_fs_write_reject
    push rdi
    mov rdi, rsi
    mov rsi, rdx
    call sc_validate_user_io_range
    pop rdi
    test eax, eax
    jz .sc_fs_write_reject
    mov rdi, [rsp + ALL_RDI]
    mov rsi, [rsp + ALL_RSI]
    mov rdx, [rsp + ALL_RDX]
    call fat16_write_file
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_fs_write_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done

.sc_fs_sync_root:
    call fat16_sync_root
    xor eax, eax
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_wm_close:
    call wm_close_window
    xor eax, eax
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_display_set_mode:
    call display_set_mode
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_cursor_init:
    call cursor_init
    xor eax, eax
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_app_done:
    POP_ALL
    jmp call_app_l3_return

.done:
    POP_ALL
    mov edx, [rel l3_current_slot]
    cmp edx, MAX_WINDOWS
    jb .slot_ok_return
    xor edx, edx
    mov [rel l3_current_slot], edx
.slot_ok_return:
    push rax
    push rdi
    SER 'S'
    mov edi, edx
    call ser_print_hex64
    SER '@'
    imul rdx, L3_RT_SIZE
    lea rcx, [rel l3_runtime]
    add rdx, rcx
    mov rdi, [rdx + L3_RT_USER_RIP]
    call ser_print_hex64
    SER 13
    SER 10
    pop rdi
    pop rax
    mov edx, [rel l3_current_slot]
    imul rdx, L3_RT_SIZE
    lea rcx, [rel l3_runtime]
    add rdx, rcx
    mov rsp, [rdx + L3_RT_USER_RSP]
    mov rcx, [rdx + L3_RT_USER_RIP]
    mov r11, [rdx + L3_RT_USER_RFLAGS]
    ; Encode SYSRETQ directly to avoid NASM's spurious label-orphan warning.
    db 0x48, 0x0F, 0x07

global test_syscall_proc
test_syscall_proc:
.loop:
    hlt
    jmp .loop

; --- Data/BSS Sections moved here ---
section .data
global syscall_count
syscall_count: dq 0
szHelloUser: db "-> Hello from RING 3 (via SYSCALL)!", 0

section .text
