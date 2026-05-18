; ============================================================================
; NexusOS v3.0 - System Call Handler (64-bit Long Mode)
; Clean L3 syscall path. Saves user state before any helper calls.
; ============================================================================
bits 64

%include "constants.inc"
%include "macros.inc"
%include "l3_runtime.inc"
%include "trace.inc"

; MSR Addresses for Syscall
IA32_EFER           equ 0xC0000080
IA32_STAR           equ 0xC0000081
IA32_LSTAR          equ 0xC0000082
IA32_FMASK          equ 0xC0000084

WIN_OFF_FLAGS       equ 40
WIN_OFF_KEYFN       equ 120
WIN_OFF_CLICKFN     equ 128
WIN_OFF_APPDATA     equ 136
WIN_OFF_DRAGFN      equ 144
DIR_ENTRY_SIZE      equ 32
%ifdef NEXUS_CACHE32_MAX
FAT16_ROOT_CACHE    equ 0x1A11000
%else
FAT16_ROOT_CACHE    equ 0xD11000
%endif
FAT16_ROOT_CACHE_SZ equ 16384
L3_DIR_ENTRY_CACHE_OFF equ 0xFA000
L3_DIR_ENTRY_CACHE_SZ  equ FAT16_ROOT_CACHE_SZ
SYSCALL_MAX_STR_LEN equ 256
APP_MIN_ID          equ 2
APP_MAX_ID          equ 8
APP_OPEN_CMD_MAX    equ 256
SYSCALL_ENTRY_SIZE  equ 16
SYSCALL_HANDLER_OFF equ 0
SYSCALL_ARGC_OFF    equ 8
SYSCALL_KIND_OFF    equ 9


; Variables moved to the end of file to avoid segment clobbering in monolithic build.

extern debug_print
extern fat16_file_count
extern fat16_get_entry
extern fat16_change_dir
extern fat16_read_file
extern fat16_format_name
extern fat16_write_file
extern fat16_delete_entry
extern fat16_rename_entry
extern fat16_mkdir
extern fat16_sync_root
extern wm_create_window_ex
extern wm_close_window
extern app_launch
extern kernel_open_file_in_notepad
extern kernel_open_app_command
extern display_set_mode
extern cursor_init
extern vsync_enabled
extern fps_show
extern display_stretch
extern fb_native_width
extern fb_native_height
extern desktop_bg_theme
extern wallpaper_selected
extern wallpaper_cache_valid
extern render_rect
extern render_text
extern scr_width
extern scr_height
extern l3_current_slot
extern l3_runtime
extern l3_syscall_stacks
extern call_app_l3_return
extern ser_print_hex64
extern app_blob_base_v
extern app_blob_end_v
extern l3_app_arena_base_v
extern l3_app_arena_size_v
extern trace_syscall
extern last_fps
extern free_page_count
extern boot_free_pages
extern cpu_tsc_per_tick
extern cpuid_logical_count
extern bsp_util
extern xml_parse
extern xml_root
extern xml_tag
extern xml_tag_name
extern xml_first_child
extern xml_next_sibling
extern xml_parent
extern xml_attr
extern xml_text
extern xml_free
extern xml_last_error
extern xml_node_count
extern xml_text_runs
extern xml_text_run
extern xml_namespace
extern xml_node_namespace
extern xml_entity_value
extern draw_line
extern fill_circle
extern fill_triangle
extern blend_pixel
extern blend_span

L3_RT_ENTRY          equ 0
L3_RT_ARG0           equ 8
L3_RT_ARG1           equ 16
L3_RT_ARG2           equ 24
L3_RT_KERNEL_RSP     equ 32

section .text

FN_BEGIN syscall_init, 0, 0, FN_RET_VOID
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
    mov eax, 0x00057700
    xor edx, edx
    wrmsr

    pop rdx
    pop rcx
    pop rax
    FN_END syscall_init
    ret

; auto-wrapped (FN_BEGIN emits global): global syscall_entry
%include "src/kernel/proc/syscall_validation.inc"

FN_DECL syscall_entry, 0, 0, FN_RET_SCALAR
    ; Save critical SYSCALL state into the active slot runtime before any
    ; helper calls.
    push rbx
    push rdx
    push r10
    mov rdx, rcx
    sub rdx, [rel l3_app_arena_base_v]
    jc .slot_from_global
    cmp rdx, [rel l3_app_arena_size_v]
    jae .slot_from_global
    shr rdx, 20
    mov ebx, edx
    jmp .slot_ok_entry
.slot_from_global:
    xor ebx, ebx
    jmp .slot_ok_entry
.slot_ok_entry:
    mov r10d, ebx
    imul rbx, L3_RT_SIZE
    lea rdx, [rel l3_runtime]
    add rbx, rdx
    mov [rbx + L3_RT_SLOT], r10d
    mov [rbx + L3_RT_USER_RIP], rcx
    mov [rbx + L3_RT_USER_RFLAGS], r11
    mov rdx, rsp
    add rdx, 24
    mov [rbx + L3_RT_USER_RSP], rdx
    mov [rbx + L3_RT_SYSCALL_NUM], rax
    mov [rbx + L3_RT_ARG0], rdi
    mov [rbx + L3_RT_ARG1], rsi
    mov rdx, [rsp + 8]
    mov [rbx + L3_RT_USER_RDX], rdx
    mov [rbx + L3_RT_USER_R8], r8
    mov [rbx + L3_RT_USER_R9], r9
    mov rdx, [rsp]
    mov [rbx + L3_RT_USER_R10], rdx
    pop r10
    pop rdx
    pop rbx
    mov ax, GDT64_DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; Switch to syscall stack without calling out while we're still on the
    ; user stack. A normal CALL would push a return address to user memory.
    mov rax, rcx
    sub rax, [rel l3_app_arena_base_v]
    jc .slot_zero_stack
    cmp rax, [rel l3_app_arena_size_v]
    jae .slot_zero_stack
    shr rax, 20
    jmp .slot_ok_stack
.slot_zero_stack:
    xor eax, eax
.slot_ok_stack:
    mov r8d, eax
    imul rax, L3_SYSCALL_STACK_SIZE
    lea rdx, [rel l3_syscall_stacks]
    add rax, rdx
    add rax, L3_SYSCALL_STACK_SIZE
    and rax, -16
    
    mov rsp, rax             ; Now on Kernel Syscall Stack
    push r8                  ; Slot for validation and return.
    
    ; Push usermode context manually so PUSH_ALL has it
    push rbx
    mov ebx, [rsp + 8]
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
    mov r15d, [rsp]
    
    cld
    PUSH_ALL

%ifdef ENABLE_TRACE
    mov rdi, [rsp + ALL_RAX]
    mov esi, r15d
    mov rdx, [rsp + ALL_RDI]
    mov ecx, TRACE_FLAG_SYSCALL_ENTER
    call trace_syscall
    mov rdi, [rsp + ALL_RDI]
    mov rsi, [rsp + ALL_RSI]
%endif

    inc qword [syscall_count]
%ifdef ENABLE_USER_DEBUG_SYSCALL
    push rax
    SER 's'
    mov rdi, rax
    and edi, 0x3F
    add edi, '0'
    mov dx, 0x3F8
    mov ax, di
    out dx, al
    pop rax
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
%endif

.dispatch:
    cmp rax, syscall_table_count
    jae .sc_invalid
    mov rbx, rax
    shl rbx, 4
    lea r12, [rel syscall_table]
    add r12, rbx
    call sc_validate_from_table
    test eax, eax
    jz .sc_validate_reject
    mov rdi, [rsp + ALL_RDI]
    mov rsi, [rsp + ALL_RSI]
    mov rdx, [rsp + ALL_RDX]
    mov r10, [rsp + ALL_R10]
    mov r8,  [rsp + ALL_R8]
    mov r9,  [rsp + ALL_R9]
    jmp qword [r12 + SYSCALL_HANDLER_OFF]

.sc_validate_reject:
%ifdef ENABLE_TRACE
    mov rdi, [rsp + ALL_RAX]
    mov esi, r15d
    mov rdx, [rsp + ALL_RDI]
    mov ecx, TRACE_FLAG_VALIDATE_FAIL
    call trace_syscall
%endif
    mov qword [rsp + ALL_RAX], -1
    jmp .done

.sc_invalid:
    mov qword [rsp + ALL_RAX], -1
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
%ifdef ENABLE_TRACE
    mov rdi, [rsp + ALL_RAX]
    mov esi, r15d
    mov rdx, [rsp + ALL_RDI]
    mov ecx, TRACE_FLAG_VALIDATE_FAIL
    call trace_syscall
%endif
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
    ; rdi=x, rsi=y, rdx=w, r10=h, r8=color.  User syscalls must not feed
    ; out-of-range low 32-bit values into the renderer's clipping arithmetic.
    ; NexusHL callers sometimes leave stale high halves in argument registers;
    ; the renderer consumes edi/esi/edx/ecx, so validate those exact values.
    cmp edi, [scr_width]
    ja .sc_gui_rect_reject
    cmp esi, [scr_height]
    ja .sc_gui_rect_reject
    cmp edx, [scr_width]
    ja .sc_gui_rect_reject
    cmp r10d, [scr_height]
    ja .sc_gui_rect_reject
    mov rcx, r10
    call render_rect
    xor eax, eax
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_gui_rect_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done

.sc_gui_text:
    ; rdi=x, rsi=y, rdx=cstring, r10=fg_color, r8=bg_color
    cmp edi, [scr_width]
    ja .sc_gui_text_reject
    cmp esi, [scr_height]
    ja .sc_gui_text_reject
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
    mov r8,  [rsp + ALL_R8]
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
    xor eax, eax
    cmp rdi, L3_DIR_ENTRY_CACHE_SZ / DIR_ENTRY_SIZE
    jae .sc_fs_entry_done
    push rdi
    call fat16_get_entry
    pop rdi
    test rax, rax
    jz .sc_fs_entry_done
    push rdi
    push rsi
    push rcx
    mov esi, r15d
    imul rsi, APP_SLOT_SIZE
    add rsi, [rel l3_app_arena_base_v]
    add rsi, L3_DIR_ENTRY_CACHE_OFF
    shl rdi, 5
    add rsi, rdi
    mov rdi, rsi
    mov rsi, rax
    mov ecx, DIR_ENTRY_SIZE
    cld
    rep movsb
    mov rax, rdi
    sub rax, DIR_ENTRY_SIZE
    pop rcx
    pop rsi
    pop rdi
.sc_fs_entry_done:
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_fs_chdir:
    mov rax, rdi
    shr rax, 16
    jnz .sc_fs_chdir_reject
    test edi, edi
    jz .sc_fs_chdir_call
    cmp edi, 2
    jb .sc_fs_chdir_reject
    cmp edi, 0xFFF8
    jae .sc_fs_chdir_reject
.sc_fs_chdir_call:
    mov eax, edi
    call fat16_change_dir
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_fs_chdir_reject:
    mov qword [rsp + ALL_RAX], -1
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
    mov rax, [rsp + ALL_RDI]
    or  rax, [rsp + ALL_RSI]
    or  rax, [rsp + ALL_RDX]
    or  rax, [rsp + ALL_R10]
    shr rax, 32
    jnz .sc_wm_create_reject
    mov eax, [rsp + ALL_RDX]
    cmp eax, MIN_WINDOW_W
    jb .sc_wm_create_reject
    mov eax, [rsp + ALL_R10]
    cmp eax, MIN_WINDOW_H
    jb .sc_wm_create_reject
    mov eax, [rsp + ALL_RDI]
    add eax, [rsp + ALL_RDX]
    jc .sc_wm_create_reject
    cmp eax, SCREEN_WIDTH
    ja .sc_wm_create_reject
    mov eax, [rsp + ALL_RSI]
    add eax, [rsp + ALL_R10]
    jc .sc_wm_create_reject
    cmp eax, SCREEN_HEIGHT
    ja .sc_wm_create_reject
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
    mov rax, rdi
    shr rax, 32
    jnz .sc_app_launch_reject
    cmp edi, APP_MIN_ID
    jb .sc_app_launch_reject
    cmp edi, APP_MAX_ID
    ja .sc_app_launch_reject
    mov edi, edi
    xor esi, esi
    xor edx, edx
    xor r8d, r8d
    xor r9d, r9d
    xor r10d, r10d
    call app_launch
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_app_launch_reject:
    mov qword [rsp + ALL_RAX], -1
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
    test r15d, r15d
    jnz .sc_fs_sync_root_reject
    call fat16_sync_root
    xor eax, eax
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_fs_sync_root_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done

.sc_wm_close:
    cmp rdi, MAX_WINDOWS
    jae .sc_wm_close_reject
    cmp edi, r15d
    jne .sc_wm_close_reject
    mov rax, rdi
    imul rax, WINDOW_STRUCT_SIZE
    add rax, WINDOW_POOL_ADDR
    test qword [rax + WIN_OFF_FLAGS], WF_ACTIVE
    jz .sc_wm_close_reject
    mov rdx, r15
    imul rdx, APP_SLOT_SIZE
    add rdx, [rel l3_app_arena_base_v]
    cmp [rax + WIN_OFF_APPDATA], rdx
    jne .sc_wm_close_reject
    call wm_close_window
    xor eax, eax
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_wm_close_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done

.sc_display_set_mode:
    ; rdi=width, rsi=height, rdx=bpp. Keep ring-3 geometry inside the
    ; fixed boot back-buffer before the display driver touches global state.
    mov rax, rdi
    or  rax, rsi
    or  rax, rdx
    shr rax, 32
    jnz .sc_display_set_mode_reject
    test edi, edi
    jz .sc_display_set_mode_reject
    test esi, esi
    jz .sc_display_set_mode_reject
    cmp edx, 32
    jne .sc_display_set_mode_reject
    mov eax, edi
    mul esi
    jo .sc_display_set_mode_reject
    cmp eax, BOOT_BACK_BUFFER_SIZE / 4
    ja .sc_display_set_mode_reject
    mov edx, 32
    call display_set_mode
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_display_set_mode_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done

.sc_cursor_init:
    call cursor_init
    xor eax, eax
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_ticks:
    mov rax, [tick_count]
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_display_flags:
    ; Pack display state into a bit field:
    ;   bit 0 = vsync, bit 1 = fps overlay, bit 2 = stretch.
    ; New bits go in the high range; bit 0/1 are stable for old callers.
    xor eax, eax
    cmp byte [vsync_enabled], 0
    je .sc_display_flags_fps
    or eax, 1
.sc_display_flags_fps:
    cmp byte [fps_show], 0
    je .sc_display_flags_stretch
    or eax, 2
.sc_display_flags_stretch:
    cmp byte [display_stretch], 0
    je .sc_display_flags_done
    or eax, 4
.sc_display_flags_done:
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_display_set_flags:
    mov rax, rdi
    shr rax, 32
    jnz .sc_display_set_flags_reject
    mov eax, edi
    and eax, 1
    mov [vsync_enabled], al
    mov eax, edi
    shr eax, 1
    and eax, 1
    mov [fps_show], al
    mov eax, edi
    shr eax, 2
    and eax, 1
    mov [display_stretch], al
    xor eax, eax
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_display_set_flags_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done

; SYS_DISPLAY_NATIVE — return the monitor's native (boot-time) framebuffer
; size as a packed qword: width in bits [31:0], height in bits [63:32].
; Apps use this to surface a "Use native resolution" choice that survives
; mode changes (scr_width/scr_height can drift away from the native size
; once display_set_mode runs).
.sc_display_native:
    mov eax, [fb_native_width]
    mov ecx, [fb_native_height]
    shl rcx, 32
    or rax, rcx
    mov [rsp + ALL_RAX], rax
    jmp .done

; SYS_DISPLAY_SIZE — return the *current* logical desktop size packed the
; same way as SYS_DISPLAY_NATIVE. This drifts whenever display_set_mode
; succeeds, so apps that want to show "current resolution" read this on
; every draw rather than caching it.
.sc_display_size:
    mov eax, [scr_width]
    mov ecx, [scr_height]
    shl rcx, 32
    or rax, rcx
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_sysinfo:
    ; rdi = selector, rsi = arg (e.g. core index). Returns a scalar in rax.
    xor eax, eax
    cmp rdi, 0
    je .si_fps
    cmp rdi, 1
    je .si_ram_free
    cmp rdi, 2
    je .si_ram_max
    cmp rdi, 3
    je .si_cpu_mhz
    cmp rdi, 4
    je .si_cores
    cmp rdi, 5
    je .si_core_util
    cmp rdi, 6
    je .si_cpu_mhz          ; per-core speed: uniform clock, reuse MHz path
    jmp .si_store
.si_fps:
    mov eax, [last_fps]
    jmp .si_store
.si_ram_free:
    mov rax, [free_page_count]
    shl rax, 2              ; 4 KB pages -> KB
    jmp .si_store
.si_ram_max:
    mov rax, [boot_free_pages]
    shl rax, 2
    jmp .si_store
.si_cpu_mhz:
    mov rax, [cpu_tsc_per_tick]
    xor rdx, rdx
    mov rcx, 10000          ; tsc/tick -> MHz (Hz = val*100)
    test rcx, rcx
    div rcx
    jmp .si_store
.si_cores:
    mov eax, [cpuid_logical_count]
    jmp .si_store
.si_core_util:
    ; Core 0 (BSP) runs the GUI; report its measured utilization. The work
    ; queue APs are parked when idle, so they report 0.
    test rsi, rsi
    jnz .si_store
    mov eax, [bsp_util]
.si_store:
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_desktop_bg:
    movzx eax, byte [desktop_bg_theme]
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_desktop_set_bg:
    mov rax, rdi
    shr rax, 32
    jnz .sc_desktop_set_bg_reject
    cmp edi, 2
    ja .sc_desktop_set_bg_reject
    mov [desktop_bg_theme], dil
    ; The user has now picked a wallpaper in Settings: enable wallpaper drawing
    ; and drop the cache so wm_draw_desktop_background rasterizes this theme on
    ; the next frame. This is the only path that triggers the SVG renderer.
    mov byte [wallpaper_selected], 1
    mov byte [wallpaper_cache_valid], 0
    xor eax, eax
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_desktop_set_bg_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done

.sc_fs_delete:
    call sc_validate_dir_entry_handle
    test eax, eax
    jz .sc_fs_delete_reject
    mov rdi, [rsp + ALL_RDI]
    call sc_dir_entry_handle_to_kernel
    call fat16_delete_entry
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_fs_delete_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done

.sc_fs_rename:
    push rdi
    call sc_validate_dir_entry_handle
    pop rdi
    test eax, eax
    jz .sc_fs_rename_reject
    push rdi
    mov rdi, rsi
    mov rsi, 11
    call sc_validate_user_range
    pop rdi
    test eax, eax
    jz .sc_fs_rename_reject
    mov rdi, [rsp + ALL_RDI]
    call sc_dir_entry_handle_to_kernel
    mov rsi, [rsp + ALL_RSI]
    call fat16_rename_entry
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_fs_rename_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done

.sc_fs_mkdir:
    mov rsi, 11
    call sc_validate_user_range
    test eax, eax
    jz .sc_fs_mkdir_reject
    mov rdi, [rsp + ALL_RDI]
    call fat16_mkdir
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_fs_mkdir_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done

.sc_open_file_np:
    call sc_validate_dir_entry_handle
    test eax, eax
    jz .sc_open_file_np_reject
    mov rdi, [rsp + ALL_RDI]
    call sc_dir_entry_handle_to_kernel
    call kernel_open_file_in_notepad
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_open_file_np_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done

.sc_app_open:
    mov rsi, APP_OPEN_CMD_MAX
    call sc_validate_user_cstring
    test eax, eax
    jz .sc_app_open_reject
    mov rdi, [rsp + ALL_RDI]
    call kernel_open_app_command
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_app_open_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done

.sc_xml_parse:
    ; rdi=buf, rsi=len. sc_validate_user_io_range takes (rdi=ptr, rsi=len).
    call sc_validate_user_io_range
    test eax, eax
    jz .sc_xml_reject
    mov rdi, [rsp + ALL_RDI]
    mov rsi, [rsp + ALL_RSI]
    call xml_parse
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_xml_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done

.sc_xml_root:
    call xml_root
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_xml_tag:
    call xml_tag
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_xml_tag_name:
    ; rdi=node, rsi=out, rdx=max
    push rdi
    push rdx
    mov rdi, rsi
    mov rsi, rdx
    call sc_validate_user_io_range
    pop rdx
    pop rdi
    test eax, eax
    jz .sc_xml_reject
    mov rsi, [rsp + ALL_RSI]
    mov rdx, [rsp + ALL_RDX]
    call xml_tag_name
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_xml_first_child:
    call xml_first_child
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_xml_next_sibling:
    call xml_next_sibling
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_xml_parent:
    call xml_parent
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_xml_attr:
    ; rdi=node, rsi=name, rdx=nlen, r10=out, r8=omax
    ; validate name range
    mov rdi, rsi
    mov rsi, rdx
    call sc_validate_user_io_range
    test eax, eax
    jz .sc_xml_reject
    ; validate out range
    mov rdi, [rsp + ALL_R10]
    mov rsi, [rsp + ALL_R8]
    call sc_validate_user_io_range
    test eax, eax
    jz .sc_xml_reject
    ; reload original args and call xml_attr(node, name, nlen, out, omax)
    mov rdi, [rsp + ALL_RDI]
    mov rsi, [rsp + ALL_RSI]
    mov rdx, [rsp + ALL_RDX]
    mov rcx, [rsp + ALL_R10]
    mov r8,  [rsp + ALL_R8]
    call xml_attr
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_xml_text:
    ; rdi=node, rsi=out, rdx=max
    push rdi
    push rdx
    mov rdi, rsi
    mov rsi, rdx
    call sc_validate_user_io_range
    pop rdx
    pop rdi
    test eax, eax
    jz .sc_xml_reject
    mov rsi, [rsp + ALL_RSI]
    mov rdx, [rsp + ALL_RDX]
    call xml_text
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_xml_free:
    call xml_free
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_xml_last_error:
    ; Return packed diagnostic: bits[31:0] = error code,
    ; bits[63:32] = byte offset truncated to 32 bits.
    call xml_last_error
    shl rdx, 32
    mov eax, eax
    or rax, rdx
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_xml_node_count:
    call xml_node_count
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_xml_text_runs:
    ; rdi = node
    mov rdi, [rsp + ALL_RDI]
    call xml_text_runs
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_xml_text_run:
    ; rdi = node, rsi = run index, rdx = out, r10 = max
    mov rdi, [rsp + ALL_RDX]
    mov rsi, [rsp + ALL_R10]
    call sc_validate_user_io_range
    test eax, eax
    jz .sc_xml_reject
    mov rdi, [rsp + ALL_RDI]
    mov esi, [rsp + ALL_RSI]
    mov rcx, [rsp + ALL_RDX]
    mov r8,  [rsp + ALL_R10]
    call xml_text_run
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_xml_namespace:
    ; rdi = node, rsi = prefix, rdx = prefix len, r10 = out, r8 = max
    cmp qword [rsp + ALL_RDX], 0
    je .sc_xml_namespace_out
    mov rdi, [rsp + ALL_RSI]
    mov rsi, [rsp + ALL_RDX]
    call sc_validate_user_io_range
    test eax, eax
    jz .sc_xml_reject
.sc_xml_namespace_out:
    mov rdi, [rsp + ALL_R10]
    mov rsi, [rsp + ALL_R8]
    call sc_validate_user_io_range
    test eax, eax
    jz .sc_xml_reject
    mov rdi, [rsp + ALL_RDI]
    mov rsi, [rsp + ALL_RSI]
    mov rdx, [rsp + ALL_RDX]
    mov rcx, [rsp + ALL_R10]
    mov r8,  [rsp + ALL_R8]
    call xml_namespace
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_xml_node_namespace:
    ; rdi = node, rsi = out, rdx = max
    mov rdi, [rsp + ALL_RSI]
    mov rsi, [rsp + ALL_RDX]
    call sc_validate_user_io_range
    test eax, eax
    jz .sc_xml_reject
    mov rdi, [rsp + ALL_RDI]
    mov rcx, [rsp + ALL_RSI]
    mov r8,  [rsp + ALL_RDX]
    call xml_node_namespace
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_xml_entity_value:
    ; rdi = name, rsi = name len, rdx = out, r10 = max
    mov rdi, [rsp + ALL_RDI]
    mov rsi, [rsp + ALL_RSI]
    call sc_validate_user_io_range
    test eax, eax
    jz .sc_xml_reject
    mov rdi, [rsp + ALL_RDX]
    mov rsi, [rsp + ALL_R10]
    call sc_validate_user_io_range
    test eax, eax
    jz .sc_xml_reject
    mov rsi, [rsp + ALL_RDI]
    mov rdx, [rsp + ALL_RSI]
    mov rcx, [rsp + ALL_RDX]
    mov r8,  [rsp + ALL_R10]
    call xml_entity_value
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_draw_line:
    ; rdi=x0, rsi=y0, rdx=x1, r10=y1, r8=color
    mov edi, [rsp + ALL_RDI]
    mov esi, [rsp + ALL_RSI]
    mov edx, [rsp + ALL_RDX]
    mov ecx, [rsp + ALL_R10]
    mov r8d, [rsp + ALL_R8]
    call draw_line
    mov qword [rsp + ALL_RAX], 0
    jmp .done

.sc_fill_circle:
    ; rdi=cx, rsi=cy, rdx=r, r10=color
    mov edi, [rsp + ALL_RDI]
    mov esi, [rsp + ALL_RSI]
    mov edx, [rsp + ALL_RDX]
    mov ecx, [rsp + ALL_R10]
    call fill_circle
    mov qword [rsp + ALL_RAX], 0
    jmp .done

.sc_fill_triangle:
    ; rdi = coords ptr (24 bytes: 6 int32), rsi = color
    mov rdi, [rsp + ALL_RDI]
    mov rsi, 24
    call sc_validate_user_io_range
    test eax, eax
    jz .sc_fill_triangle_reject
    mov rdi, [rsp + ALL_RDI]
    mov esi, [rsp + ALL_RSI]
    call fill_triangle
    mov qword [rsp + ALL_RAX], 0
    jmp .done
.sc_fill_triangle_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done

.sc_blend_pixel:
    ; rdi = x, rsi = y, rdx = color
    mov edi, [rsp + ALL_RDI]
    mov esi, [rsp + ALL_RSI]
    mov edx, [rsp + ALL_RDX]
    call blend_pixel
    mov qword [rsp + ALL_RAX], 0
    jmp .done

.sc_blend_span:
    ; rdi = x, rsi = y, rdx = len, r10 = color
    mov edi, [rsp + ALL_RDI]
    mov esi, [rsp + ALL_RSI]
    mov edx, [rsp + ALL_RDX]
    mov ecx, [rsp + ALL_R10]
    call blend_span
    mov qword [rsp + ALL_RAX], 0
    jmp .done

.sc_blend_span_argb:
    ; rdi = x, rsi = y, rdx = len (pixels), r10 = ARGB src buffer.
    ; Batches one scanline run: replaces `len` per-pixel blend syscalls.
    mov edx, [rsp + ALL_RDX]
    test edx, edx
    jle .sc_blend_span_argb_done
    mov rdi, [rsp + ALL_R10]          ; src buffer ptr
    mov esi, edx
    shl esi, 2                        ; byte length = len * 4
    call sc_validate_user_range
    test eax, eax
    jz .sc_blend_span_argb_done
    mov edi, [rsp + ALL_RDI]
    mov esi, [rsp + ALL_RSI]
    mov edx, [rsp + ALL_RDX]
    mov rcx, [rsp + ALL_R10]
    call blend_span_argb
.sc_blend_span_argb_done:
    mov qword [rsp + ALL_RAX], 0
    jmp .done

.sc_blend_span_argb_screen:
    ; rdi = x, rsi = y, rdx = len (pixels), r10 = ARGB src buffer.
    ; mix-blend-mode: screen variant of sc_blend_span_argb.
    mov edx, [rsp + ALL_RDX]
    test edx, edx
    jle .sc_blend_span_argb_screen_done
    mov rdi, [rsp + ALL_R10]
    mov esi, edx
    shl esi, 2
    call sc_validate_user_range
    test eax, eax
    jz .sc_blend_span_argb_screen_done
    mov edi, [rsp + ALL_RDI]
    mov esi, [rsp + ALL_RSI]
    mov edx, [rsp + ALL_RDX]
    mov rcx, [rsp + ALL_R10]
    call blend_span_argb_screen
.sc_blend_span_argb_screen_done:
    mov qword [rsp + ALL_RAX], 0
    jmp .done

.sc_blend_span_argb_multiply:
    ; rdi = x, rsi = y, rdx = len (pixels), r10 = ARGB src buffer.
    ; mix-blend-mode: multiply variant of sc_blend_span_argb.
    mov edx, [rsp + ALL_RDX]
    test edx, edx
    jle .sc_blend_span_argb_multiply_done
    mov rdi, [rsp + ALL_R10]
    mov esi, edx
    shl esi, 2
    call sc_validate_user_range
    test eax, eax
    jz .sc_blend_span_argb_multiply_done
    mov edi, [rsp + ALL_RDI]
    mov esi, [rsp + ALL_RSI]
    mov edx, [rsp + ALL_RDX]
    mov rcx, [rsp + ALL_R10]
    call blend_span_argb_multiply
.sc_blend_span_argb_multiply_done:
    mov qword [rsp + ALL_RAX], 0
    jmp .done

.sc_app_done:
%ifdef ENABLE_TRACE
    mov rdi, [rsp + ALL_RAX]
    mov esi, r15d
    xor edx, edx
    mov ecx, TRACE_FLAG_SYSCALL_EXIT
    call trace_syscall
%endif
    POP_ALL
    jmp call_app_l3_return

.done:
%ifdef ENABLE_TRACE
    mov eax, r15d
    cmp eax, MAX_WINDOWS
    jb .trace_slot_ok_done
    xor eax, eax
.trace_slot_ok_done:
    imul rax, L3_RT_SIZE
    lea rdi, [rel l3_runtime]
    add rdi, rax
    mov rdi, [rdi + L3_RT_SYSCALL_NUM]
    mov esi, r15d
    mov rdx, [rsp + ALL_RAX]
    mov ecx, TRACE_FLAG_SYSCALL_EXIT
    call trace_syscall
%endif
    POP_ALL
    mov edx, [rsp]
    cmp edx, MAX_WINDOWS
    jb .slot_ok_return
    xor edx, edx
.slot_ok_return:
    imul rdx, L3_RT_SIZE
    lea rcx, [rel l3_runtime]
    add rdx, rcx
    mov rsp, [rdx + L3_RT_USER_RSP]
    mov rcx, [rdx + L3_RT_USER_RIP]
    mov r11, [rdx + L3_RT_USER_RFLAGS]
    ; Encode SYSRETQ directly to avoid NASM's spurious label-orphan warning.
    db 0x48, 0x0F, 0x07

; R12=syscall table entry, PUSH_ALL frame on RSP. EAX=1 ok, 0 reject.
sc_validate_from_table:
    push rbx
    push rcx
    push rdx
    push rdi
    push rsi
    push r8
    movzx ecx, byte [r12 + SYSCALL_ARGC_OFF]
    mov ebx, [r12 + SYSCALL_KIND_OFF]
    xor r8d, r8d
.validate_loop:
    cmp r8d, ecx
    jae .validate_ok
    mov edx, ebx
    and edx, 3
    cmp edx, FN_KIND_SCALAR
    je .next_arg
    cmp edx, FN_KIND_PTR
    je .check_ptr
    cmp edx, FN_KIND_CSTRING
    je .check_cstring
    cmp edx, FN_KIND_HANDLE
    je .check_handle
    jmp .validate_fail
.check_ptr:
    call sc_load_arg_for_validation
    mov rsi, 1
    call sc_validate_user_range
    test eax, eax
    jz .validate_fail
    jmp .next_arg
.check_cstring:
    call sc_load_arg_for_validation
    mov rsi, SYSCALL_MAX_STR_LEN
    call sc_validate_user_cstring
    test eax, eax
    jz .validate_fail
    jmp .next_arg
.check_handle:
    call sc_load_arg_for_validation
    call sc_validate_dir_entry_handle
    test eax, eax
    jz .validate_fail
.next_arg:
    shr ebx, 2
    inc r8d
    jmp .validate_loop
.validate_ok:
    mov eax, 1
    jmp .validate_done
.validate_fail:
    xor eax, eax
.validate_done:
    pop r8
    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    ret

; R8D=arg index, returns selected argument in RDI.
SC_VALIDATE_FRAME_OFF equ 64
sc_load_arg_for_validation:
    cmp r8d, 0
    je .arg0
    cmp r8d, 1
    je .arg1
    cmp r8d, 2
    je .arg2
    cmp r8d, 3
    je .arg3
    cmp r8d, 4
    je .arg4
    mov rdi, [rsp + SC_VALIDATE_FRAME_OFF + ALL_R9]
    ret

.arg0:
    mov rdi, [rsp + SC_VALIDATE_FRAME_OFF + ALL_RDI]
    ret
.arg1:
    mov rdi, [rsp + SC_VALIDATE_FRAME_OFF + ALL_RSI]
    ret
.arg2:
    mov rdi, [rsp + SC_VALIDATE_FRAME_OFF + ALL_RDX]
    ret
.arg3:
    mov rdi, [rsp + SC_VALIDATE_FRAME_OFF + ALL_R10]
    ret
.arg4:
    mov rdi, [rsp + SC_VALIDATE_FRAME_OFF + ALL_R8]
    ret

; RDI=validated FAT16 handle. Returns the matching kernel current-directory
; cache pointer in RDI, so mutating operations update the real cache rather
; than the per-slot opaque copy returned to ring 3 by SYS_FS_ENTRY.
sc_dir_entry_handle_to_kernel:
    mov rax, rdi
    sub rax, FAT16_ROOT_CACHE
    jc .deht_from_slot
    cmp rax, FAT16_ROOT_CACHE_SZ - DIR_ENTRY_SIZE
    ja .deht_from_slot
    ret
.deht_from_slot:
    ; The per-slot handle encodes the *valid-entry* index (the same index that
    ; SYS_FS_ENTRY took), not a raw byte offset into the root cache. Volume-
    ; label, LFN and deleted entries are skipped by fat16_get_entry, so raw
    ; offset != index*32 whenever any are present (data.img begins with a
    ; volume-label entry). Re-resolve through fat16_get_entry so the skip
    ; logic matches and we land on the real directory entry.
    mov rax, rdi
    sub rax, [rel l3_app_arena_base_v]
    and eax, APP_SLOT_SIZE - 1
    sub eax, L3_DIR_ENTRY_CACHE_OFF
    shr eax, 5                          ; eax = valid-entry index
    mov edi, eax
    call fat16_get_entry                ; rax = real root-cache entry ptr
    mov rdi, rax
    ret

%define SC_KIND1(a) (a)
%define SC_KIND2(a,b) ((a) | ((b) << 2))
%define SC_KIND3(a,b,c) ((a) | ((b) << 2) | ((c) << 4))
%define SC_KIND4(a,b,c,d) ((a) | ((b) << 2) | ((c) << 4) | ((d) << 6))
%define SC_KIND5(a,b,c,d,e) ((a) | ((b) << 2) | ((c) << 4) | ((d) << 6) | ((e) << 8))
%define SC_KIND6(a,b,c,d,e,f) ((a) | ((b) << 2) | ((c) << 4) | ((d) << 6) | ((e) << 8) | ((f) << 10))

%macro SYSCALL_ENTRY 3
    dq %1
    db %2
    dd %3
    db 0, 0, 0
%endmacro

section .text
align 8
syscall_table:
    SYSCALL_ENTRY syscall_entry.sc_print,            1, SC_KIND1(FN_KIND_CSTRING)
    SYSCALL_ENTRY syscall_entry.sc_exit,             0, 0
    SYSCALL_ENTRY syscall_entry.sc_gui_rect,         5, SC_KIND5(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR)
    SYSCALL_ENTRY syscall_entry.sc_gui_text,         5, SC_KIND5(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_CSTRING, FN_KIND_SCALAR, FN_KIND_SCALAR)
    SYSCALL_ENTRY syscall_entry.sc_fs_count,         0, 0
    SYSCALL_ENTRY syscall_entry.sc_fs_entry,         1, SC_KIND1(FN_KIND_SCALAR)
    SYSCALL_ENTRY syscall_entry.sc_fs_chdir,         1, SC_KIND1(FN_KIND_SCALAR)
    SYSCALL_ENTRY syscall_entry.sc_wm_create,        6, SC_KIND6(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_CSTRING, FN_KIND_SCALAR)
    SYSCALL_ENTRY syscall_entry.sc_fs_read,          3, SC_KIND3(FN_KIND_HANDLE, FN_KIND_PTR, FN_KIND_SCALAR)
    SYSCALL_ENTRY syscall_entry.sc_wm_handlers,      3, SC_KIND3(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR)
    SYSCALL_ENTRY syscall_entry.sc_app_done,         0, 0
    SYSCALL_ENTRY syscall_entry.sc_fs_format_name,   2, SC_KIND2(FN_KIND_HANDLE, FN_KIND_PTR)
    SYSCALL_ENTRY syscall_entry.sc_app_launch,       1, SC_KIND1(FN_KIND_SCALAR)
    SYSCALL_ENTRY syscall_entry.sc_fs_write,         3, SC_KIND3(FN_KIND_PTR, FN_KIND_PTR, FN_KIND_SCALAR)
    SYSCALL_ENTRY syscall_entry.sc_fs_sync_root,     0, 0
    SYSCALL_ENTRY syscall_entry.sc_wm_close,         1, SC_KIND1(FN_KIND_SCALAR)
    SYSCALL_ENTRY syscall_entry.sc_display_set_mode, 3, SC_KIND3(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR)
    SYSCALL_ENTRY syscall_entry.sc_cursor_init,      0, 0
    SYSCALL_ENTRY syscall_entry.sc_ticks,            0, 0
    SYSCALL_ENTRY syscall_entry.sc_fs_delete,        1, SC_KIND1(FN_KIND_HANDLE)
    SYSCALL_ENTRY syscall_entry.sc_fs_rename,        2, SC_KIND2(FN_KIND_HANDLE, FN_KIND_PTR)
    SYSCALL_ENTRY syscall_entry.sc_fs_mkdir,         1, SC_KIND1(FN_KIND_PTR)
    SYSCALL_ENTRY syscall_entry.sc_open_file_np,     1, SC_KIND1(FN_KIND_HANDLE)
    SYSCALL_ENTRY syscall_entry.sc_app_open,         1, SC_KIND1(FN_KIND_CSTRING)
    SYSCALL_ENTRY syscall_entry.sc_display_flags,    0, 0
    SYSCALL_ENTRY syscall_entry.sc_display_set_flags, 1, SC_KIND1(FN_KIND_SCALAR)
    SYSCALL_ENTRY syscall_entry.sc_desktop_bg,       0, 0
    SYSCALL_ENTRY syscall_entry.sc_desktop_set_bg,   1, SC_KIND1(FN_KIND_SCALAR)
    SYSCALL_ENTRY syscall_entry.sc_display_native,   0, 0
    SYSCALL_ENTRY syscall_entry.sc_display_size,     0, 0
    SYSCALL_ENTRY syscall_entry.sc_xml_parse,        2, SC_KIND2(FN_KIND_PTR, FN_KIND_SCALAR)
    SYSCALL_ENTRY syscall_entry.sc_xml_root,         0, 0
    SYSCALL_ENTRY syscall_entry.sc_xml_tag,          1, SC_KIND1(FN_KIND_SCALAR)
    SYSCALL_ENTRY syscall_entry.sc_xml_tag_name,     3, SC_KIND3(FN_KIND_SCALAR, FN_KIND_PTR, FN_KIND_SCALAR)
    SYSCALL_ENTRY syscall_entry.sc_xml_first_child,  1, SC_KIND1(FN_KIND_SCALAR)
    SYSCALL_ENTRY syscall_entry.sc_xml_next_sibling, 1, SC_KIND1(FN_KIND_SCALAR)
    SYSCALL_ENTRY syscall_entry.sc_xml_parent,       1, SC_KIND1(FN_KIND_SCALAR)
    SYSCALL_ENTRY syscall_entry.sc_xml_attr,         5, SC_KIND5(FN_KIND_SCALAR, FN_KIND_PTR, FN_KIND_SCALAR, FN_KIND_PTR, FN_KIND_SCALAR)
    SYSCALL_ENTRY syscall_entry.sc_xml_text,         3, SC_KIND3(FN_KIND_SCALAR, FN_KIND_PTR, FN_KIND_SCALAR)
    SYSCALL_ENTRY syscall_entry.sc_xml_free,         0, 0
    SYSCALL_ENTRY syscall_entry.sc_draw_line,        5, SC_KIND5(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR)
    SYSCALL_ENTRY syscall_entry.sc_fill_circle,      4, SC_KIND4(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR)
    SYSCALL_ENTRY syscall_entry.sc_fill_triangle,    2, SC_KIND2(FN_KIND_PTR, FN_KIND_SCALAR)
    SYSCALL_ENTRY syscall_entry.sc_xml_last_error,   0, 0
    SYSCALL_ENTRY syscall_entry.sc_xml_node_count,   0, 0
    SYSCALL_ENTRY syscall_entry.sc_blend_pixel,      3, SC_KIND3(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR)
    SYSCALL_ENTRY syscall_entry.sc_blend_span,       4, SC_KIND4(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR)
    SYSCALL_ENTRY syscall_entry.sc_xml_text_runs,    1, SC_KIND1(FN_KIND_SCALAR)
    SYSCALL_ENTRY syscall_entry.sc_xml_text_run,     4, SC_KIND4(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_PTR, FN_KIND_SCALAR)
    SYSCALL_ENTRY syscall_entry.sc_xml_namespace,    5, SC_KIND5(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_PTR, FN_KIND_SCALAR)
    SYSCALL_ENTRY syscall_entry.sc_xml_node_namespace, 3, SC_KIND3(FN_KIND_SCALAR, FN_KIND_PTR, FN_KIND_SCALAR)
    SYSCALL_ENTRY syscall_entry.sc_xml_entity_value, 4, SC_KIND4(FN_KIND_PTR, FN_KIND_SCALAR, FN_KIND_PTR, FN_KIND_SCALAR)
    SYSCALL_ENTRY syscall_entry.sc_blend_span_argb,  4, SC_KIND4(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_PTR)
    SYSCALL_ENTRY syscall_entry.sc_blend_span_argb_screen, 4, SC_KIND4(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_PTR)
    SYSCALL_ENTRY syscall_entry.sc_blend_span_argb_multiply, 4, SC_KIND4(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_PTR)
    SYSCALL_ENTRY syscall_entry.sc_sysinfo,          2, SC_KIND2(FN_KIND_SCALAR, FN_KIND_SCALAR)
syscall_table_end:
syscall_table_count equ (syscall_table_end - syscall_table) / SYSCALL_ENTRY_SIZE

FN_BEGIN test_syscall_proc, 0, 0, FN_RET_VOID
.loop:
    hlt
    jmp .loop

; --- Data/BSS Sections moved here ---
section .data
global syscall_count
syscall_count: dq 0
szHelloUser: db "-> Hello from RING 3 (via SYSCALL)!", 0

section .text
