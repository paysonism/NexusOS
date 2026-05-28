; ============================================================================
; NexusOS v3.0 - System Call Handler (64-bit Long Mode)
; Clean L3 syscall path. Saves user state before any helper calls.
; ============================================================================
bits 64

%include "constants.inc"
%include "macros.inc"
%include "l3_runtime.inc"
%include "trace.inc"
%include "syscall_caps.inc"
%include "shadow_stack.inc"

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
WIN_OFF_RCLICKFN    equ 152
DIR_ENTRY_SIZE      equ 32
%ifdef NEXUS_CACHE32_MAX
FAT16_ROOT_CACHE    equ 0x1A11000
%else
FAT16_ROOT_CACHE    equ 0xD11000
%endif
FAT16_ROOT_CACHE_SZ equ 16384
; Upper bound on the valid-entry index ring 3 may request from SYS_FS_ENTRY.
; Matches the root-cache slot count (volume label / LFN / deleted entries are
; skipped by fat16_get_entry so the true count is lower; we just need a
; sanity ceiling before calling out).
FAT16_MAX_ENTRIES   equ FAT16_ROOT_CACHE_SZ / DIR_ENTRY_SIZE
; Size of the user-visible SYS_FS_ENTRY_INFO struct. Keep in sync with the
; layout documented in syscall_user.inc.
FS_ENTRY_INFO_SIZE  equ 20
SYSCALL_MAX_STR_LEN equ 256
APP_MIN_ID          equ 2
APP_MAX_ID          equ 11
APP_OPEN_CMD_MAX    equ 256
SYSCALL_ENTRY_SIZE  equ 24
SYSCALL_HANDLER_OFF equ 0
SYSCALL_ARGC_OFF    equ 8
SYSCALL_KIND_OFF    equ 9
; Single-byte cap mask packed into what used to be a padding byte.
SYSCALL_CAP_OFF     equ 13
; Optional per-arg descriptor qword. 4 bits per arg (6 args = 24 bits used);
; nibble N != 0 means "byte length of this PTR arg lives in scalar arg
; (nibble - 1)". The validator pulls that sibling and uses it as the real
; range length, instead of the 1-byte probe. The "one missed handler is a
; bug" pattern goes away — the dispatcher always range-validates, even when
; the handler forgets. Reserved bits stay zero for future alignment/NUL-cap
; descriptors. Encode with SC_DESC_LEN / SC_DESC macros below.
SYSCALL_ARG_DESC_OFF equ 16

; Slot-internal layout — duplicate of usermode.asm's locals; see
; boot_memory.inc for the canonical definition. NASM `equ` cannot be
; %ifndef-guarded, so syscall.asm declares them locally instead of
; including a shared header.
L3_APP_CODE_OFF     equ 512
L3_SHADOW_WIN_OFF   equ (APP_SLOT_SIZE - 512)
L3_SYSCALL_FRAME_SLOT_OFF equ 120
L3_APP_CODE_OFF     equ 512
L3_SHADOW_WIN_OFF   equ (APP_SLOT_SIZE - 512)
L3_SLOT_MAGIC_OFF   equ 0
L3_SLOT_MAGIC       equ 0x30544F4C5358414E


; Variables moved to the end of file to avoid segment clobbering in monolithic build.

extern debug_print
extern scene_dirty
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
extern kernel_open_file_in_media
extern nx_media_blit_scaled

; Bounds for the SYS_MEDIA_BLIT_SCALED syscall (sc_media_blit_scaled).
; Documented at the syscall's call site; centralised here so a future
; tuning pass (e.g. raising the limit for 8K still images) edits one place.
MEDIA_MAX_DIM   equ 4096
MEDIA_MAX_BYTES equ 64 * 1024 * 1024
extern kernel_open_app_command
extern display_set_mode
extern cursor_init
extern vsync_enabled
extern fps_show
extern display_stretch
extern fb_native_width
extern fb_native_height
extern amd_display_active
extern amd_display_status
extern amd_display_bdf
extern amd_display_id
extern amd_display_class
extern amd_display_bar0
extern amd_display_cmd
extern desktop_bg_theme
extern wallpaper_selected
extern wallpaper_cache_valid
extern wallpaper_cache_presented
extern wallpaper_render_active
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
extern l3_apply_wx_policy
extern l3_slot_live
extern l3_wx_manifest_ver
extern l3_wx_code_start
extern l3_wx_code_end
extern l3_slot_code_slide
extern trace_syscall
extern last_fps
extern free_page_count
extern boot_free_pages
extern total_usable_pages
extern cpu_tsc_per_tick
extern cpuid_logical_count
extern bsp_util
extern smp_core_states
extern madt_enabled_cpu_count
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
extern blend_span_argb
extern blend_span_argb_screen
extern blend_span_argb_multiply
extern raster_select_syscall_target
extern raster_select_default_target
extern raster_sc_release_target
extern net_ping_ipv4
extern net_info
extern net_dhcp_configure
extern net_dhcp_start
extern net_tcp_connect_ipv4
extern rtl8156_dhcp_state

L3_RT_ENTRY          equ 0
L3_RT_ARG0           equ 8
L3_RT_ARG1           equ 16
L3_RT_ARG2           equ 24
L3_RT_KERNEL_RSP     equ 32

section .text

FN_BEGIN syscall_init, 0, 0, FN_RET_VOID
    ; BSP path: do the per-CPU MSR setup, then print the LSTAR target so the
    ; serial log records where syscall_entry actually lives.
    call syscall_init_this_cpu
    push rdi
    push rax
    lea rax, [rel syscall_entry]
    SER 'L'
    mov rdi, rax
    call ser_print_hex64
    SER 13
    SER 10
    pop rax
    pop rdi
    FN_END syscall_init
    ret

; ----------------------------------------------------------------------------
; syscall_init_this_cpu - program the SYSCALL/SYSRET MSRs on the calling CPU.
; EFER, STAR, LSTAR, and FMASK are all per-CPU MSRs, so every core that will
; ever take a SYSCALL must run this once. The BSP calls it via syscall_init;
; each AP calls it from ap_long_mode_init (apic.asm) so an app callback
; dispatched to an AP in Stage 2c lands in syscall_entry just like on the BSP.
;
; Preserves every caller-visible register (rax/rcx/rdx clobbered internally
; for wrmsr; we save and restore them).
; ----------------------------------------------------------------------------
FN_BEGIN syscall_init_this_cpu, 0, 0, FN_RET_VOID
    push rax
    push rcx
    push rdx

    mov ecx, IA32_EFER
    rdmsr
    or eax, 1                      ; SCE: enable SYSCALL/SYSRET
    wrmsr

    mov ecx, IA32_STAR
    xor eax, eax
    mov edx, 0x001B0008            ; kernel CS=0x08, user CS base=0x1B
    wrmsr

    mov ecx, IA32_LSTAR
    lea rax, [rel syscall_entry]
    mov rdx, rax
    shr rdx, 32
    wrmsr

    mov ecx, IA32_FMASK
    mov eax, 0x00057700            ; mask IF, DF, AC etc on entry
    xor edx, edx
    wrmsr

    pop rdx
    pop rcx
    pop rax
    FN_END syscall_init_this_cpu
    ret

; auto-wrapped (FN_BEGIN emits global): global syscall_entry
%include "src/kernel/proc/syscall_validation.inc"
%include "src/kernel/proc/handle_table.inc"

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
    shr rdx, 21
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
    shr rax, 21
    jmp .slot_ok_stack
.slot_zero_stack:
    xor eax, eax
.slot_ok_stack:
    mov r8d, eax
    imul rax, L3_SYSCALL_STACK_STRIDE
    mov rdx, L3_SYSCALL_STACK_ADDR
    add rax, rdx
    add rax, L3_SYSCALL_STACK_STRIDE        ; top of slot i = base + (i+1)*STRIDE
    and rax, -16
    
    mov rsp, rax             ; Now on Kernel Syscall Stack
    ; Stack canary: push a 16-byte canary frame (canary + 8-byte alignment
    ; pad) before the slot id so the slot stays at [rsp] for all existing
    ; readers, while keeping PUSH_ALL's frame 16-byte aligned for callee ABI.
    ; The canary is checked at every syscall exit path before SYSRET / app
    ; return; a mismatch traps to kernel_panic_canary.
    sub rsp, 8                                  ; alignment pad
    push qword [rel kernel_canary]              ; canary at [rsp + 8] (after slot push)
    push r8                                     ; Slot for validation and return.
    
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
    ; SYSCALL_ENTRY_SIZE == 24, so rbx *= 24 via (rbx + rbx*2) << 3.
    lea rbx, [rbx + rbx*2]
    shl rbx, 3
    lea r12, [rel syscall_table]
    add r12, rbx
    ; Capability gate: reject before argument validation so a sandboxed app
    ; can't even probe pointer behaviour of a forbidden syscall. R15 is the
    ; current slot id; slot_cap_mask[] defaults to CAP_ALL for every slot
    ; until the app declares its manifest.
    movzx eax, byte [r12 + SYSCALL_CAP_OFF]
    test al, al
    jz .sc_cap_reject               ; untagged entry = misconfiguration; deny
    lea rcx, [rel slot_cap_mask]
    movzx edx, r15b
    mov dl, [rcx + rdx]
    and dl, al
    cmp dl, al
    jne .sc_cap_reject
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

.sc_cap_reject:
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
    push rdi
    SER 'F'
    SER 'E'
    pop rdi
    push rdi
    call ser_print_hex64
    SER 13
    SER 10
    pop rdi
    ; rdi = valid-entry index. Returns rax = packed opaque handle, or 0.
    ;
    ; Phase 2 of the handle-table refactor: instead of copying the FAT16
    ; entry into a per-slot snapshot region and returning that kernel
    ; pointer to ring 3, we allocate a HANDLE_KIND_DIR_ENTRY entry whose
    ; payload is the valid-entry index. Every downstream FS syscall
    ; (read / format_name / delete / rename / open_file_np /
    ; open_file_media) resolves through handle_resolve + fat16_get_entry,
    ; so ring 3 never observes a kernel VA. The legacy snapshot cache and
    ; sc_validate_dir_entry_handle / sc_dir_entry_handle_to_kernel pair
    ; have been removed.
    xor eax, eax
    cmp rdi, FAT16_MAX_ENTRIES
    jae .sc_fs_entry_done
    push rdi                              ; preserve index
    call fat16_get_entry                  ; confirms the index resolves; we
    test rax, rax                         ; don't keep the pointer — handlers
    pop rdi                               ; re-resolve fresh each call.
    jz .sc_fs_entry_fail
    ; rdi still = valid-entry index (the handle payload).
    mov r8, rdi
    mov rax, r15
    imul rax, APP_SLOT_SIZE
    add rax, [rel l3_app_arena_base_v]
    mov rdi, rax                          ; rdi = slot base
    mov al, HANDLE_KIND_DIR_ENTRY
    call handle_alloc                     ; eax = handle or 0 (table full)
    jmp .sc_fs_entry_done
.sc_fs_entry_fail:
    xor eax, eax
.sc_fs_entry_done:
    push rax
    SER 'F'
    SER 'H'
    mov rdi, rax
    call ser_print_hex64
    SER 13
    SER 10
    pop rax
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
    ; Remap user args (x, y, w, h, title, drawfn) to wm_create_window_ex's
    ; signature (rdi=title, rsi=x, rdx=y, rcx=w, r8=h, r9=drawfn). The
    ; validation above reads ALL_RDX as width / ALL_R10 as height, so the
    ; user-facing order must keep dimensions in slots 2-3; title sits at
    ; slot 4 (FN_KIND_CSTRING in the syscall table). Before this remap, w
    ; was being passed as title and h as width — every call failed the
    ; min-width check inside wm_create_window_ex.
    mov rdi, [rsp + ALL_R8]      ; title
    mov rsi, [rsp + ALL_RDI]     ; x
    mov rdx, [rsp + ALL_RSI]     ; y
    mov rcx, [rsp + ALL_RDX]     ; w
    mov r8,  [rsp + ALL_R10]     ; h
    mov r9,  [rsp + ALL_R9]      ; drawfn
    call wm_create_window_ex
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_wm_create_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done

.sc_fs_read:
    ; rdi = dir-entry handle, rsi = user buffer, rdx = length.
    ; sc_resolve_dir_entry_arg rewrites rdi to the real FAT16 root-cache
    ; entry pointer (kernel-internal); after this point rdi is a kernel
    ; VA and must not flow back to ring 3.
    call sc_resolve_dir_entry_arg
    test eax, eax
    jz .sc_fs_read_reject
    push rdi                              ; save kernel entry pointer
    mov rdi, rsi
    mov rsi, rdx
    call sc_validate_user_io_range
    pop rdi
    test eax, eax
    jz .sc_fs_read_reject
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
    ; sc_validate_callback_target uses RSI as the range length, so reload the
    ; original handler pointers from the saved syscall frame before storing.
    mov rsi, [rsp + ALL_RSI]
    mov rdx, [rsp + ALL_RDX]
    mov rax, rdi
    imul rax, WINDOW_STRUCT_SIZE
    add rax, WINDOW_POOL_ADDR
    ; Only active windows may have handlers installed. This prevents a
    ; ring-3 app from hijacking a stale slot.
    test qword [rax + WIN_OFF_FLAGS], WF_ACTIVE
    jz .sc_wm_handlers_reject
    ; Ownership check: caller's slot must own the target window. Without
    ; this, any app can install callbacks into any other app's window, which
    ; — combined with l3_translate_target's blob-region remapping — turns
    ; into cross-slot code execution at attacker-chosen offsets.
    mov rcx, r15
    imul rcx, APP_SLOT_SIZE
    add rcx, [rel l3_app_arena_base_v]
    cmp [rax + WIN_OFF_APPDATA], rcx
    jne .sc_wm_handlers_reject
    ; CPI-lite: stamp the per-window tag onto both callback fields before
    ; commit. Sign each handler against (&window, field_offset) so a tag
    ; valid for CLICKFN can't be replayed in KEYFN or another window.
    ; Stash the raw key_fn and the window ptr first — both helper calls
    ; below clobber rdx/rsi/rdi.
    push rax                          ; [rsp+8] = &window
    push rdx                          ; [rsp+0] = raw key_fn
    mov rdi, rsi                      ; raw click_fn
    mov rsi, rax                      ; &window
    mov rdx, WIN_OFF_CLICKFN
    call cpi_sign_callback
    mov r10, rax                      ; signed click_fn
    pop rdi                           ; raw key_fn
    mov rsi, [rsp]                    ; &window (still on stack)
    mov rdx, WIN_OFF_KEYFN
    call cpi_sign_callback
    mov r11, rax                      ; signed key_fn
    pop rax                           ; &window
    mov [rax + WIN_OFF_CLICKFN], r10
    mov [rax + WIN_OFF_KEYFN], r11
    xor eax, eax
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_wm_handlers_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done

.sc_wm_set_user_arg:
    ; rdi = win_id, rsi = up-to-48-bit opaque value to stash at
    ; WIN_OFF_USER_ARG. Bounds check win_id and require ACTIVE. Allowed iff:
    ;   (a) caller's slot owns the target window (same-slot writer), OR
    ;   (b) the field is still zero — first-write by the window's creator,
    ;       which lives in a different slot than the freshly-allocated one.
    ; Without (a)/(b) any app can clobber any active window's user_arg.
    ;
    ; Tagged poisoning: the stored qword is (value | (tag << 48)), where tag
    ; is a per-window secret = low16(kernel_canary ^ &window). On read via
    ; SYS_WM_GET_USER_ARG the kernel recomputes the tag and rejects any
    ; value whose top 16 bits do not match. That removes a type-confusion
    ; primitive where a malicious app could feed a freshly-fabricated qword
    ; (e.g. a kernel pointer pattern) into a peer window's draw fn before
    ; the legitimate creator's tag has been stamped. Callers must therefore
    ; keep the top 16 bits clear; a non-zero top half is rejected outright.
    cmp rdi, MAX_WINDOWS
    jae .sc_wm_set_user_arg_reject
    mov rax, rdi
    imul rax, WINDOW_STRUCT_SIZE
    add rax, WINDOW_POOL_ADDR
    test qword [rax + WIN_OFF_FLAGS], WF_ACTIVE
    jz .sc_wm_set_user_arg_reject
    mov rdx, 0xFFFF000000000000
    test rsi, rdx
    jnz .sc_wm_set_user_arg_reject
    mov rcx, r15
    imul rcx, APP_SLOT_SIZE
    add rcx, [rel l3_app_arena_base_v]
    cmp [rax + WIN_OFF_APPDATA], rcx
    je .sc_wm_set_user_arg_ok
    cmp qword [rax + 160], 0          ; WIN_OFF_USER_ARG
    jne .sc_wm_set_user_arg_reject
.sc_wm_set_user_arg_ok:
    ; Preserve the "zero == no selection" sentinel: don't stamp a tag onto
    ; a zero value, otherwise readers couldn't distinguish "never set" from
    ; "explicitly set to zero" — and the tag verifier would reject 0 too.
    test rsi, rsi
    jz .sc_wm_set_user_arg_store
    mov rdx, [rel kernel_canary]
    xor rdx, rax                      ; mix per-window struct address
    movzx edx, dx                     ; low 16 bits = tag
    shl rdx, 48
    or rsi, rdx
.sc_wm_set_user_arg_store:
    mov [rax + 160], rsi              ; WIN_OFF_USER_ARG
    xor eax, eax
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_wm_set_user_arg_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done

.sc_wm_get_user_arg:
    ; rdi = win_id. Returns the low-48-bit value (zero-extended), or -1 if
    ; the stored qword's top-16 tag doesn't match the per-window tag computed
    ; from kernel_canary ^ &window. A stored qword of exactly 0 returns 0
    ; (the "never set" sentinel; see sc_wm_set_user_arg above).
    cmp rdi, MAX_WINDOWS
    jae .sc_wm_get_user_arg_reject
    mov rax, rdi
    imul rax, WINDOW_STRUCT_SIZE
    add rax, WINDOW_POOL_ADDR
    test qword [rax + WIN_OFF_FLAGS], WF_ACTIVE
    jz .sc_wm_get_user_arg_reject
    mov rcx, [rax + 160]              ; stored qword
    test rcx, rcx
    jz .sc_wm_get_user_arg_zero
    mov rdx, [rel kernel_canary]
    xor rdx, rax
    movzx edx, dx
    shl rdx, 48                       ; expected tag bits
    mov rsi, rcx
    mov r8, 0xFFFF000000000000
    and rsi, r8
    cmp rsi, rdx
    jne .sc_wm_get_user_arg_reject
    mov rdx, 0x0000FFFFFFFFFFFF
    and rcx, rdx
    mov [rsp + ALL_RAX], rcx
    jmp .done
.sc_wm_get_user_arg_zero:
    xor eax, eax
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_wm_get_user_arg_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done

.sc_fs_format_name:
    ; rdi = handle, rsi = user 16-byte output buffer.
    call sc_resolve_dir_entry_arg
    test eax, eax
    jz .sc_fs_format_name_reject
    push rdi                              ; kernel entry pointer
    mov rdi, rsi
    mov rsi, 16
    call sc_validate_user_io_range
    pop rdi
    test eax, eax
    jz .sc_fs_format_name_reject
    mov rsi, [rsp + ALL_RSI]
    ; fat16_format_name takes (rdi = out buf, rsi = entry pointer).
    xchg rdi, rsi
    call fat16_format_name
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
    ; Slot is being recycled — restore an unsandboxed cap mask so the next
    ; app that lands here isn't accidentally constrained by the prior
    ; tenant's manifest. The new tenant re-narrows via its own declare call.
    lea rax, [rel slot_cap_mask]
    movzx ecx, r15b
    mov byte [rax + rcx], CAP_ALL
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
    ; Selectors 100..199 are reserved for fbperf (framebuffer perf/debug).
    xor eax, eax
    cmp rdi, 100
    jb  .si_legacy
    cmp rdi, 199
    ja  .si_legacy
    extern fbperf_get
    call fbperf_get
    jmp .si_store
.si_legacy:
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
    je .si_core_mhz
    cmp rdi, 16
    je .si_gpu_provider
    cmp rdi, 17
    je .si_gpu_bdf
    cmp rdi, 18
    je .si_gpu_id
    cmp rdi, 19
    je .si_gpu_class
    cmp rdi, 20
    je .si_gpu_bar0_lo
    cmp rdi, 21
    je .si_gpu_bar0_hi
    cmp rdi, 22
    je .si_gpu_cmd
    cmp rdi, 23
    je .si_gpu_active
    jmp .si_store
.si_fps:
    mov eax, [last_fps]
    jmp .si_store
.si_ram_free:
    mov rax, [free_page_count]
    shl rax, 2              ; 4 KB pages -> KB
    jmp .si_store
.si_ram_max:
    ; total_usable_pages includes fixed kernel/GUI/app arenas reserved before
    ; the allocator starts, so apps can report actual used RAM instead of 0
    ; until the first dynamic page allocation.
    mov rax, [total_usable_pages]
    test rax, rax
    jnz .si_ram_max_have
    mov rax, [boot_free_pages]
.si_ram_max_have:
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
    mov eax, [madt_enabled_cpu_count]
    test eax, eax
    jnz .si_store
    mov eax, [cpuid_logical_count]
    jmp .si_store
.si_core_util:
    cmp rsi, SMP_MAX_CORES
    jae .si_store
    mov rax, rsi
    imul rax, SMP_CORE_STATE_SIZE
    mov eax, [smp_core_states + rax + 24]
    jmp .si_store
.si_core_mhz:
    cmp rsi, SMP_MAX_CORES
    jae .si_cpu_mhz
    mov rax, rsi
    imul rax, SMP_CORE_STATE_SIZE
    mov eax, [smp_core_states + rax + 28]
    test eax, eax
    jnz .si_store
    jmp .si_cpu_mhz
.si_gpu_provider:
    mov eax, [amd_display_status]
    jmp .si_store
.si_gpu_bdf:
    mov eax, [amd_display_bdf]
    jmp .si_store
.si_gpu_id:
    mov eax, [amd_display_id]
    jmp .si_store
.si_gpu_class:
    mov eax, [amd_display_class]
    jmp .si_store
.si_gpu_bar0_lo:
    mov eax, [amd_display_bar0]
    jmp .si_store
.si_gpu_bar0_hi:
    mov rax, [amd_display_bar0]
    shr rax, 32
    jmp .si_store
.si_gpu_cmd:
    mov eax, [amd_display_cmd]
    jmp .si_store
.si_gpu_active:
    movzx eax, byte [amd_display_active]
    jmp .si_store
.si_store:
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_desktop_bg:
    movzx eax, byte [desktop_bg_theme]
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_desktop_set_bg:
    cmp byte [wallpaper_render_active], 0
    jne .sc_desktop_set_bg_busy
    cmp byte [wallpaper_selected], 0
    je .sc_desktop_set_bg_accept
    cmp byte [wallpaper_cache_valid], 1
    jne .sc_desktop_set_bg_busy
    cmp byte [wallpaper_cache_presented], 1
    jne .sc_desktop_set_bg_busy
.sc_desktop_set_bg_accept:
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
    mov byte [wallpaper_cache_presented], 0
    mov byte [scene_dirty], 1
    xor eax, eax
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_desktop_set_bg_busy:
    mov qword [rsp + ALL_RAX], -2
    jmp .done
.sc_desktop_set_bg_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done

.sc_desktop_bg_busy:
    xor eax, eax
    cmp byte [wallpaper_render_active], 0
    jne .sc_desktop_bg_busy_yes
    cmp byte [wallpaper_selected], 0
    je .sc_desktop_bg_busy_store
    cmp byte [wallpaper_cache_valid], 1
    jne .sc_desktop_bg_busy_yes
    cmp byte [wallpaper_cache_presented], 1
    je .sc_desktop_bg_busy_store
.sc_desktop_bg_busy_yes:
    mov eax, 1
.sc_desktop_bg_busy_store:
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_fs_delete:
    ; rdi = handle. Resolver leaves rdi as the kernel root-cache entry
    ; pointer so fat16_delete_entry mutates the real cache (the snapshot
    ; cache that used to back this call no longer exists).
    call sc_resolve_dir_entry_arg
    test eax, eax
    jz .sc_fs_delete_reject
    call fat16_delete_entry
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_fs_delete_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done

.sc_fs_rename:
    ; rdi = handle, rsi = 11-byte raw FAT16 short name in user memory.
    call sc_resolve_dir_entry_arg
    test eax, eax
    jz .sc_fs_rename_reject
    push rdi                              ; kernel entry pointer
    mov rdi, rsi
    mov rsi, 11
    call sc_validate_user_range
    pop rdi
    test eax, eax
    jz .sc_fs_rename_reject
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
    call sc_resolve_dir_entry_arg
    test eax, eax
    jz .sc_open_file_np_reject
    ; Notepad is only for text-like files. If a stale UI path asks Notepad to
    ; open known media, route to Media Player at the syscall boundary.
    cmp byte [rdi + 8], 'B'
    jne .sc_open_file_np_not_bmp
    cmp byte [rdi + 9], 'M'
    jne .sc_open_file_np_not_bmp
    cmp byte [rdi + 10], 'P'
    je .sc_open_file_np_media
.sc_open_file_np_not_bmp:
    cmp byte [rdi + 8], 'N'
    jne .sc_open_file_np_check_svg
    cmp byte [rdi + 9], 'I'
    jne .sc_open_file_np_check_nba
    cmp byte [rdi + 10], 'C'
    je .sc_open_file_np_media
    jmp .sc_open_file_np_text
.sc_open_file_np_check_nba:
    cmp byte [rdi + 9], 'B'
    jne .sc_open_file_np_text
    cmp byte [rdi + 10], 'A'
    je .sc_open_file_np_media
    jmp .sc_open_file_np_text
.sc_open_file_np_check_svg:
    cmp byte [rdi + 8], 'S'
    jne .sc_open_file_np_check_xml
    cmp byte [rdi + 9], 'V'
    jne .sc_open_file_np_text
    cmp byte [rdi + 10], 'G'
    je .sc_open_file_np_media
    jmp .sc_open_file_np_text
.sc_open_file_np_check_xml:
    cmp byte [rdi + 8], 'X'
    jne .sc_open_file_np_text
    cmp byte [rdi + 9], 'M'
    jne .sc_open_file_np_text
    cmp byte [rdi + 10], 'L'
    je .sc_open_file_np_media
.sc_open_file_np_text:
    call kernel_open_file_in_notepad
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_open_file_np_media:
    call kernel_open_file_in_media
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_open_file_np_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done

.sc_open_file_media:
    call sc_resolve_dir_entry_arg
    test eax, eax
    jz .sc_open_file_media_reject
    call kernel_open_file_in_media
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_open_file_media_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done

; SYS_HANDLE_CLOSE — release an opaque handle. rdi = handle.
;
; Generic close; today only HANDLE_KIND_DIR_ENTRY exists. handle_close
; verifies the handle (magic + kind + index + generation) before zeroing
; the entry's kind byte. A stale handle from before this close still
; fails to resolve because the allocator bumps the generation on the next
; reuse of the same index.
.sc_handle_close:
    mov edx, edi                          ; edx = untrusted handle
    mov rax, r15
    imul rax, APP_SLOT_SIZE
    add rax, [rel l3_app_arena_base_v]
    mov rdi, rax                          ; rdi = slot base
    mov al, HANDLE_KIND_DIR_ENTRY
    call handle_close                     ; eax = 1 ok, 0 mismatch
    test eax, eax
    jz .sc_handle_close_reject
    xor eax, eax
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_handle_close_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done

; SYS_FS_ENTRY_INFO — read a fixed-layout snapshot of a FAT16 entry into
; a user buffer. rdi = handle, rsi = user out buf, rdx = buf size.
;
; This is the replacement for the legacy "SYS_FS_ENTRY returned a
; dereferenceable snapshot pointer" contract. The kernel decides what
; fields are exposed (name/ext/attr, first cluster, size — no internal
; FAT16 metadata) and copies them out by value, so ring 3 never observes
; a kernel address.
.sc_fs_entry_info:
    push rdi
    push rdx
    SER 'F'
    SER 'I'
    call ser_print_hex64
    SER 13
    SER 10
    pop rdx
    pop rdi
    cmp rdx, FS_ENTRY_INFO_SIZE
    jb .sc_fs_entry_info_reject
    push rdi                              ; save handle
    push rsi                              ; save user buf
    mov rdi, rsi
    mov rsi, FS_ENTRY_INFO_SIZE
    call sc_validate_user_io_range
    pop rsi
    pop rdi
    test eax, eax
    jz .sc_fs_entry_info_reject
    push rsi                              ; user buf survives the resolver
    call sc_resolve_dir_entry_arg         ; rdi -> kernel entry pointer
    pop rsi
    test eax, eax
    jz .sc_fs_entry_info_reject
    ; Layout:
    ;   [0..7]   name              (bytes 0..7 of FAT entry)
    ;   [8..10]  ext               (bytes 8..10)
    ;   [11]     attr              (byte 11)
    ;   [12..13] first_cluster_lo  (u16 at offset 26)
    ;   [14..15] reserved          (0)
    ;   [16..19] size              (u32 at offset 28)
    mov rax, [rdi + 0]
    mov [rsi + 0], rax
    mov eax, [rdi + 8]
    mov [rsi + 8], eax
    movzx eax, word [rdi + 26]
    mov [rsi + 12], ax
    mov word [rsi + 14], 0
    mov eax, [rdi + 28]
    mov [rsi + 16], eax
    xor eax, eax
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_fs_entry_info_reject:
    SER 'F'
    SER 'X'
    SER 13
    SER 10
    mov qword [rsp + ALL_RAX], -1
    jmp .done

; SYS_APP_DECLARE_MANIFEST(app_id):
;   AND-narrows slot_cap_mask[r15] by app_manifest_table[app_id - APP_MIN_ID].
;   Returns the resulting effective mask (or -1 on bad app_id). AND-only
;   ensures the manifest call can never *grant* a capability — it can only
;   take them away — so an attacker who hijacks an already-narrowed slot
;   can't re-declare into a more powerful manifest.
.sc_app_declare_manifest:
    cmp edi, APP_MIN_ID
    jb .sc_app_declare_manifest_reject
    cmp edi, APP_MAX_ID
    ja .sc_app_declare_manifest_reject
    sub edi, APP_MIN_ID
    lea rcx, [rel app_manifest_table]
    movzx eax, byte [rcx + rdi]
    lea rcx, [rel slot_cap_mask]
    movzx edx, r15b
    and [rcx + rdx], al
    movzx eax, byte [rcx + rdx]
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_app_declare_manifest_reject:
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
    mov edi, r15d
    call raster_select_syscall_target
    mov edi, [rsp + ALL_RDI]
    mov esi, [rsp + ALL_RSI]
    mov edx, [rsp + ALL_RDX]
    mov ecx, [rsp + ALL_R10]
    mov r8d, [rsp + ALL_R8]
    call draw_line
    call raster_sc_release_target
    mov qword [rsp + ALL_RAX], 0
    jmp .done

.sc_fill_circle:
    ; rdi=cx, rsi=cy, rdx=r, r10=color
    mov edi, r15d
    call raster_select_syscall_target
    mov edi, [rsp + ALL_RDI]
    mov esi, [rsp + ALL_RSI]
    mov edx, [rsp + ALL_RDX]
    mov ecx, [rsp + ALL_R10]
    call fill_circle
    call raster_sc_release_target
    mov qword [rsp + ALL_RAX], 0
    jmp .done

.sc_fill_triangle:
    ; rdi = coords ptr (24 bytes: 6 int32), rsi = color
    mov rdi, [rsp + ALL_RDI]
    mov rsi, 24
    call sc_validate_user_io_range
    test eax, eax
    jz .sc_fill_triangle_reject
    mov edi, r15d
    call raster_select_syscall_target
    mov rdi, [rsp + ALL_RDI]
    mov esi, [rsp + ALL_RSI]
    call fill_triangle
    call raster_sc_release_target
    mov qword [rsp + ALL_RAX], 0
    jmp .done
.sc_fill_triangle_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done

.sc_blend_pixel:
    ; rdi = x, rsi = y, rdx = color
    mov edi, r15d
    call raster_select_syscall_target
    mov edi, [rsp + ALL_RDI]
    mov esi, [rsp + ALL_RSI]
    mov edx, [rsp + ALL_RDX]
    call blend_pixel
    call raster_sc_release_target
    mov qword [rsp + ALL_RAX], 0
    jmp .done

.sc_blend_span:
    ; rdi = x, rsi = y, rdx = len, r10 = color
    mov edi, r15d
    call raster_select_syscall_target
    mov edi, [rsp + ALL_RDI]
    mov esi, [rsp + ALL_RSI]
    mov edx, [rsp + ALL_RDX]
    mov ecx, [rsp + ALL_R10]
    call blend_span
    call raster_sc_release_target
    mov qword [rsp + ALL_RAX], 0
    jmp .done

.sc_blend_span_argb:
    ; rdi = x, rsi = y, rdx = len (pixels), r10 = ARGB src buffer.
    ; Batches one scanline run: replaces `len` per-pixel blend syscalls.
    ; 64-bit + unsigned length math so len*4 cannot wrap a 32-bit register
    ; and slip a huge range through with byte-len=0.
    mov edx, [rsp + ALL_RDX]          ; zero-extends into rdx
    test rdx, rdx
    jz .sc_blend_span_argb_done
    cmp rdx, 0x100000                 ; cap at 1M pixels — far above any real scanline
    ja .sc_blend_span_argb_done
    mov rdi, [rsp + ALL_R10]          ; src buffer ptr
    mov rsi, rdx
    shl rsi, 2                        ; byte length = len * 4 (64-bit, safe)
    call sc_validate_user_range
    test eax, eax
    jz .sc_blend_span_argb_done
    mov edi, r15d
    call raster_select_syscall_target
    mov edi, [rsp + ALL_RDI]
    mov esi, [rsp + ALL_RSI]
    mov edx, [rsp + ALL_RDX]
    mov rcx, [rsp + ALL_R10]
    call blend_span_argb
    call raster_sc_release_target
.sc_blend_span_argb_done:
    mov qword [rsp + ALL_RAX], 0
    jmp .done

.sc_blend_span_argb_screen:
    ; rdi = x, rsi = y, rdx = len (pixels), r10 = ARGB src buffer.
    ; mix-blend-mode: screen variant of sc_blend_span_argb. See _argb above
    ; for why the length math is 64-bit unsigned with an explicit cap.
    mov edx, [rsp + ALL_RDX]
    test rdx, rdx
    jz .sc_blend_span_argb_screen_done
    cmp rdx, 0x100000
    ja .sc_blend_span_argb_screen_done
    mov rdi, [rsp + ALL_R10]
    mov rsi, rdx
    shl rsi, 2
    call sc_validate_user_range
    test eax, eax
    jz .sc_blend_span_argb_screen_done
    mov edi, r15d
    call raster_select_syscall_target
    mov edi, [rsp + ALL_RDI]
    mov esi, [rsp + ALL_RSI]
    mov edx, [rsp + ALL_RDX]
    mov rcx, [rsp + ALL_R10]
    call blend_span_argb_screen
    call raster_sc_release_target
.sc_blend_span_argb_screen_done:
    mov qword [rsp + ALL_RAX], 0
    jmp .done

.sc_blend_span_argb_multiply:
    ; rdi = x, rsi = y, rdx = len (pixels), r10 = ARGB src buffer.
    ; mix-blend-mode: multiply variant of sc_blend_span_argb. See _argb above
    ; for why the length math is 64-bit unsigned with an explicit cap.
    mov edx, [rsp + ALL_RDX]
    test rdx, rdx
    jz .sc_blend_span_argb_multiply_done
    cmp rdx, 0x100000
    ja .sc_blend_span_argb_multiply_done
    mov rdi, [rsp + ALL_R10]
    mov rsi, rdx
    shl rsi, 2
    call sc_validate_user_range
    test eax, eax
    jz .sc_blend_span_argb_multiply_done
    mov edi, r15d
    call raster_select_syscall_target
    mov edi, [rsp + ALL_RDI]
    mov esi, [rsp + ALL_RSI]
    mov edx, [rsp + ALL_RDX]
    mov rcx, [rsp + ALL_R10]
    call blend_span_argb_multiply
    call raster_sc_release_target
.sc_blend_span_argb_multiply_done:
    mov qword [rsp + ALL_RAX], 0
    jmp .done

; ---------------------------------------------------------------------------
; sc_media_blit_scaled — aspect-preserving BGRA blit into a window's client
; area. Used by the Media Player (and any future timeline-bearing app) so
; the codec dispatch and control-bar drawing can live in user-mode NexusHL
; instead of being trapped in kernel asm.
;
; Args (already loaded from caller registers):
;   rdi = window_id (low 32 bits)
;   rsi = src_ptr (BGRA buffer in caller's slot)
;   rdx = packed dims: (src_w << 16) | src_h, each in [1, 4096]
;   r10 = reserve_bottom_px (0..scr_height, clamped)
;   r8  = alpha_key (any nonzero treated as 1)
; Returns: 0 on success, -1 if any input is rejected.
;
; Dims are packed so the syscall fits in NexusHL's 6-argument syscall()
; arity. Both halves are validated as if they had been separate args —
; bounding happens before any arithmetic on them.
;
; Security invariants
; -------------------
;  * src_w / src_h bounded to [1, MEDIA_MAX_DIM] (4096). Caps the divide
;    inputs in nx_media_blit_scaled and the byte-range computed below.
;  * src_w * src_h * 4 computed in 64-bit and bounded to MEDIA_MAX_BYTES
;    (64 MB) before being handed to sc_validate_user_range, so a hostile
;    caller cannot induce arithmetic overflow that would wrap the range
;    check.
;  * src_ptr range must lie entirely within the caller's app slot or the
;    built-in user blob (sc_validate_user_range — same predicate used by
;    sc_blend_span_argb).
;  * window_id < MAX_WINDOWS. The window struct address is computed from
;    a bounded index so a forged id cannot redirect the scaler's writes
;    elsewhere.
;  * reserve_bottom_px is clamped to scr_height, so an absurd value
;    cannot make the scaler's internal client_h go negative and walk
;    backwards through memory.
;  * alpha_key is reduced to {0,1} by `cmp/setnz` — any caller-supplied
;    bit pattern lands on one of the two intended paths.
; ---------------------------------------------------------------------------
.sc_media_blit_scaled:
    ; Unpack dims: rdx = (src_w << 16) | src_h.
    mov eax, edx
    shr eax, 16                              ; src_w
    mov ecx, edx
    and ecx, 0xFFFF                          ; src_h

    ; Bound each half.
    test eax, eax
    jz .sc_media_blit_reject
    cmp eax, MEDIA_MAX_DIM
    ja .sc_media_blit_reject
    test ecx, ecx
    jz .sc_media_blit_reject
    cmp ecx, MEDIA_MAX_DIM
    ja .sc_media_blit_reject

    ; byte_len = src_w * src_h * 4 in 64-bit; reject overflow or > cap.
    mov ebx, eax                             ; stash src_w
    mov r11d, ecx                            ; stash src_h
    imul rax, rcx                            ; rax = w*h (fits in 64 bits)
    shl rax, 2                               ; * 4 bpp
    cmp rax, MEDIA_MAX_BYTES
    ja .sc_media_blit_reject
    mov r14, rax                             ; stash byte_len

    ; Validate src range — sc_validate_user_range takes (rdi=ptr, rsi=len).
    mov rdi, rsi
    mov rsi, r14
    call sc_validate_user_range
    test eax, eax
    jz .sc_media_blit_reject

    ; Validate window id (rdi at entry, reloaded fresh).
    mov rdi, [rsp + ALL_RDI]
    mov rax, rdi
    shr rax, 32
    test rax, rax
    jnz .sc_media_blit_reject                ; high half must be zero
    mov eax, edi
    cmp eax, MAX_WINDOWS
    jae .sc_media_blit_reject

    ; Resolve window struct address.
    imul rax, WINDOW_STRUCT_SIZE
    add rax, WINDOW_POOL_ADDR
    mov r13, rax

    ; Clamp reserve_bottom to scr_height.
    mov r8, [rsp + ALL_R10]                  ; reserve_bottom_px
    mov ecx, [scr_height]
    cmp r8d, ecx
    jbe .sc_media_blit_reserve_ok
    mov r8d, ecx
.sc_media_blit_reserve_ok:

    ; Reduce alpha_key to {0,1}.
    mov r9, [rsp + ALL_R8]                   ; alpha_key
    xor eax, eax
    test r9, r9
    setnz al

    ; Load scaler register contract:
    ;   r12 = src, r13 = window, r14d = src_w, r15d = src_h,
    ;   dl = alpha_key, r9d = reserve_bottom
    mov r12, [rsp + ALL_RSI]
    mov r14d, ebx
    mov r15d, r11d
    mov edx, eax                             ; alpha_key in dl
    mov r9d, r8d                             ; reserve_bottom
    call nx_media_blit_scaled

    xor eax, eax
    mov [rsp + ALL_RAX], rax
    jmp .done
.sc_media_blit_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done

.sc_wx_install_manifest:
    ; rdi = code_start_off, rsi = code_end_off. Offsets are EXPRESSED RELATIVE
    ; TO THE BLOB START (i.e. (sym - app_blob_start)), not the slot base — the
    ; ring-3 app doesn't know its own per-slot code slide. We add the slide
    ; here so the stored bounds are absolute in-slot offsets, matching what
    ; l3_apply_wx_policy and sc_mprotect_wx / sc_wx_jit_alias compare against.
    test rdi, 0xFFF
    jnz .sc_wx_manifest_reject
    test rsi, 0xFFF
    jnz .sc_wx_manifest_reject
    cmp rdi, rsi
    jae .sc_wx_manifest_reject

    ; Apply per-slot code slide.
    mov eax, r15d
    mov rcx, [l3_slot_code_slide + rax*8]
    add rdi, rcx
    add rsi, rcx
    jc  .sc_wx_manifest_reject              ; overflow guard (defense-in-depth)

    cmp rdi, L3_APP_CODE_OFF
    jb .sc_wx_manifest_reject
    cmp rsi, L3_SHADOW_WIN_OFF
    ja .sc_wx_manifest_reject

    call sc_get_slot_bounds                 ; r8 = slot base, r9 = slot end
    mov rax, L3_SLOT_MAGIC
    mov ecx, r15d
    cmp [l3_slot_live + rcx*8], rax
    jne .sc_wx_manifest_reject

    mov eax, r15d
    mov qword [l3_wx_code_start + rax*8], rdi
    mov qword [l3_wx_code_end + rax*8], rsi
    mov qword [l3_wx_manifest_ver + rax*8], 1

    mov edi, r15d
    call l3_apply_wx_policy
    mov qword [rsp + ALL_RAX], 0
    jmp .done
.sc_wx_manifest_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done

.sc_mprotect_wx:
    ; rdi = page_addr, rsi = mode (0 = W+NX, 1 = X+!W).
    test rdi, 0xFFF
    jnz .sc_mprotect_reject
    cmp rsi, MPROT_WX_MODE_XRO
    ja .sc_mprotect_reject

    push rbx
    push rcx
    push rdx
    push r10
    push r11
    push r12
    push r13

    mov r10, rdi                         ; page address
    mov r11, rsi                         ; requested mode

    call sc_get_slot_bounds              ; r8 = slot base, r9 = slot end
    mov rdi, r10
    mov rsi, 0x1000
    call sc_range_in_bounds              ; slot-only, not app_blob fallback
    test eax, eax
    jz .sc_mprotect_fail_pop

    mov rax, L3_SLOT_MAGIC
    mov ecx, r15d
    cmp [l3_slot_live + rcx*8], rax
    jne .sc_mprotect_fail_pop
    mov eax, r15d
    cmp qword [l3_wx_manifest_ver + rax*8], 1
    jne .sc_mprotect_fail_pop

    mov r12, r10
    sub r12, r8                          ; slot-relative page offset
    mov eax, r15d
    cmp r12, [l3_wx_code_start + rax*8]
    jb .sc_mprotect_fail_pop
    cmp r12, [l3_wx_code_end + rax*8]
    jae .sc_mprotect_fail_pop

    mov eax, r15d
    cmp eax, MAX_WINDOWS
    jae .sc_mprotect_fail_pop
    imul rax, ARENA_SLOT_PAGES * 8
    mov rcx, r12
    shr rcx, 12
    lea r13, [APP_ARENA_PT_BASE + rax + rcx * 8]

    mov rax, [r13]
    test al, 1
    jz .sc_mprotect_fail_pop

    ; Neutral step: W=0, NX=1, then flush before granting the final mode.
    and rax, -3
    mov rdx, PAGE_NX
    or rax, rdx
    mov [r13], rax
    invlpg [r10]

    cmp r11, MPROT_WX_MODE_WNX
    je .sc_mprotect_final_wnx
    ; X+!W: W is already clear; clear NX.
    mov rdx, PAGE_NX
    not rdx
    and rax, rdx
    jmp .sc_mprotect_store_final
.sc_mprotect_final_wnx:
    ; W+NX: set W; NX is already set.
    or rax, 2
.sc_mprotect_store_final:
    mov [r13], rax
    invlpg [r10]

    pop r13
    pop r12
    pop r11
    pop r10
    pop rdx
    pop rcx
    pop rbx
    mov qword [rsp + ALL_RAX], 0
    jmp .done
.sc_mprotect_fail_pop:
    pop r13
    pop r12
    pop r11
    pop r10
    pop rdx
    pop rcx
    pop rbx
.sc_mprotect_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done

.sc_wx_jit_alias:
    ; rdi = x_va, rsi = w_alias_va, rdx = length (bytes, page-multiple).
    test rdx, rdx
    jz .sc_jit_alias_reject
    test rdx, 0xFFF
    jnz .sc_jit_alias_reject
    test rdi, 0xFFF
    jnz .sc_jit_alias_reject
    test rsi, 0xFFF
    jnz .sc_jit_alias_reject

    push rbx
    push rcx
    push r10
    push r11
    push r12
    push r13
    push r14

    mov r10, rdi                         ; x_va
    mov r11, rsi                         ; w_alias_va
    mov r12, rdx                         ; length

    ; Slot must be live and have a v1 manifest installed.
    mov rax, L3_SLOT_MAGIC
    mov ecx, r15d
    cmp [l3_slot_live + rcx*8], rax
    jne .sc_jit_alias_fail_pop
    mov eax, r15d
    cmp qword [l3_wx_manifest_ver + rax*8], 1
    jne .sc_jit_alias_fail_pop

    call sc_get_slot_bounds              ; r8 = slot base, r9 = slot end

    ; Both ranges must lie entirely inside the slot.
    mov rdi, r10
    mov rsi, r12
    call sc_range_in_bounds
    test eax, eax
    jz .sc_jit_alias_fail_pop
    mov rdi, r11
    mov rsi, r12
    call sc_range_in_bounds
    test eax, eax
    jz .sc_jit_alias_fail_pop

    ; Slot-relative offsets for both ranges.
    mov rax, r10
    sub rax, r8                          ; x_off  (start)
    mov rbx, r11
    sub rbx, r8                          ; w_off  (start)
    mov rcx, rax
    add rcx, r12                         ; x_off_end
    mov rdx, rbx
    add rdx, r12                         ; w_off_end

    ; X range must lie fully inside the installed code range.
    mov r13d, r15d
    cmp rax, [l3_wx_code_start + r13*8]
    jb .sc_jit_alias_fail_pop
    cmp rcx, [l3_wx_code_end + r13*8]
    ja .sc_jit_alias_fail_pop

    ; W alias must NOT overlap the code range. If alias was inside the code
    ; range, l3_apply_wx_policy would strip its W bit on the next activation.
    mov r14, [l3_wx_code_start + r13*8]  ; cs
    mov r13, [l3_wx_code_end   + r13*8]  ; ce  (clobbers r13d — slot reloaded below if needed)
    ; Overlap iff (w_off < ce) && (w_off_end > cs).
    cmp rbx, r13
    jae .sc_jit_alias_no_overlap
    cmp rdx, r14
    ja .sc_jit_alias_fail_pop
.sc_jit_alias_no_overlap:

    ; Walk the X range; for each page copy the physical frame into the
    ; corresponding W-alias PTE with PRESENT|USER|W|NX, preserving the X
    ; mapping unchanged.
    mov eax, r15d
    imul rax, ARENA_SLOT_PAGES * 8       ; rax = per-slot PT byte offset
    mov r13, rax
    add r13, APP_ARENA_PT_BASE           ; r13 = &PT[slot][0]

    mov rax, r10
    sub rax, r8
    shr rax, 12                          ; rax = x first page index
    lea rax, [r13 + rax * 8]             ; rax = &x_pte[0]

    mov rcx, r11
    sub rcx, r8
    shr rcx, 12                          ; rcx = w first page index
    lea rcx, [r13 + rcx * 8]             ; rcx = &w_pte[0]

    mov r14, r12
    shr r14, 12                          ; r14 = page count

.sc_jit_alias_loop:
    mov rdx, [rax]                       ; x PTE
    test dl, 1                           ; PRESENT?
    jz .sc_jit_alias_fail_pop
    mov rsi, [rcx]                       ; existing w PTE — must be present
    test sil, 1
    jz .sc_jit_alias_fail_pop

    ; Build the alias PTE: x's physical frame + flags PRESENT|RW|USER|NX,
    ; preserving the rest of x's low flags is unnecessary — we want a fresh
    ; W+NX user mapping of the same frame.
    mov rbx, rdx
    mov rdi, 0x000FFFFFFFFFF000          ; 4KB-aligned phys-frame mask
    and rbx, rdi                         ; rbx = phys frame from x PTE
    or rbx, 0x07                         ; PRESENT | RW | USER
    mov rdi, PAGE_NX
    or rbx, rdi                          ; + NX
    mov [rcx], rbx
    invlpg [r11]

    add rax, 8
    add rcx, 8
    add r11, 0x1000
    dec r14
    jnz .sc_jit_alias_loop

    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop rcx
    pop rbx
    mov qword [rsp + ALL_RAX], 0
    jmp .done
.sc_jit_alias_fail_pop:
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop rcx
    pop rbx
.sc_jit_alias_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done

.sc_net_ping4:
    ; Reject re-entrant calls — the kernel rtl8156 ping path is not safe
    ; to call concurrently. App that double-clicks while a previous ping is
    ; in flight gets -2 back, not a fresh syscall that races shared state.
    cmp byte [sc_net_ping_busy], 0
    jne .sc_net_ping4_busy
    mov byte [sc_net_ping_busy], 1
    mov rax, rdi
    shr rax, 32
    jnz .sc_net_ping4_reject
    mov edi, edi
    ; SYSCALL masks IF on entry. Blocking network paths use tick_count for
    ; RX/timeout waits, so let the timer run while the NIC dispatcher waits.
    sti
    call net_ping_ipv4
    push rax
    cli
    pop rax
    mov [rsp + ALL_RAX], rax
    mov byte [sc_net_ping_busy], 0
    call usb_hid_requeue_slot1_reads
    jmp .done
.sc_net_ping4_reject:
    mov byte [sc_net_ping_busy], 0
    mov qword [rsp + ALL_RAX], -1
    jmp .done
.sc_net_ping4_busy:
    mov qword [rsp + ALL_RAX], -2
    jmp .done

.sc_net_info:
    ; rdi = selector. Returns scalar in rax (zero for unknown selectors).
    xor eax, eax
    cmp rdi, 0
    je .ni_active
    cmp rdi, 1
    je .ni_bound
    cmp rdi, 2
    je .ni_ip
    cmp rdi, 3
    je .ni_router
    cmp rdi, 4
    je .ni_server
    cmp rdi, 5
    je .ni_guest
    cmp rdi, 6
    je .ni_nexthop
    cmp rdi, 7
    je .ni_dhcp_state
    cmp rdi, 8
    je .ni_last_ttl
    cmp rdi, 9
    je .ni_dns
    jmp .ni_store
.ni_active:
.ni_bound:
.ni_ip:
.ni_router:
.ni_server:
.ni_guest:
.ni_nexthop:
.ni_dhcp_state:
.ni_last_ttl:
.ni_dns:
    call net_info
.ni_store:
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_net_dhcp_renew:
    ; Force a fresh DHCP DISCOVER/REQUEST cycle. Returns 1 on bound, 0 on fail.
    ; Trace markers: [d1] enter, [d2] have nic, [d3] after configure, [d4] requeue
    push rax
    push rdx
    mov dx, 0x3F8
    mov al, '['
    out dx, al
    mov al, 'd'
    out dx, al
    mov al, '1'
    out dx, al
    mov al, ']'
    out dx, al
    pop rdx
    pop rax
    ; DHCP waits on xHCI completions and tick_count timeouts; IF is masked
    ; by syscall entry, so open a small interrupt window around the wait.
    sti
    call net_dhcp_configure
    push rax
    cli
    pop rax
    test eax, eax
    jz .dhcp_no_nic
    push rax
    push rdx
    mov dx, 0x3F8
    mov al, '['
    out dx, al
    mov al, 'd'
    out dx, al
    mov al, '2'
    out dx, al
    mov al, ']'
    out dx, al
    pop rdx
    pop rax
    push rax
    push rdx
    mov dx, 0x3F8
    mov al, '['
    out dx, al
    mov al, 'd'
    out dx, al
    mov al, '3'
    out dx, al
    mov al, ']'
    out dx, al
    pop rdx
    pop rax
    ; rtl8156_wait_completion drained any HID transfer events queued during
    ; the DHCP exchange. Re-prime the mouse interrupt ring so the cursor
    ; doesn't freeze after the user clicks the DHCP button.
    extern usb_hid_requeue_slot1_reads
    call usb_hid_requeue_slot1_reads
    push rax
    push rdx
    mov dx, 0x3F8
    mov al, '['
    out dx, al
    mov al, 'd'
    out dx, al
    mov al, '4'
    out dx, al
    mov al, ']'
    out dx, al
    pop rdx
    pop rax
    mov rdi, 2
    call net_info
    mov [rsp + ALL_RAX], rax
    jmp .done
.dhcp_no_nic:
    mov qword [rsp + ALL_RAX], 0
    jmp .done

.sc_net_dhcp_start:
    ; Kick off async DHCP. Returns 0 immediately. Caller polls
    ; NI_DHCP_STATE for progress.
    ; Backend selection is handled by net_dhcp_start. Keep this syscall as a
    ; stable app-facing shim while NIC-specific work stays behind net/nic.asm.
    ; The active backend may do synchronous fallback work before returning.
    ; Keep timer interrupts live for that bounded network wait.
    sti
    call net_dhcp_start
    push rax
    cli
    pop rax
    test eax, eax
    jz .dhcp_start_no_nic
    mov qword [rsp + ALL_RAX], 0
    jmp .done
.dhcp_start_no_nic:
    mov byte [rtl8156_dhcp_state], 4   ; FAILED
    mov qword [rsp + ALL_RAX], 0
    jmp .done

.sc_net_tcp_connect4:
    ; rdi = IPv4 A.B.C.D, rsi = destination port, rdx = source port.
    ; This currently performs the TCP open SYN path: resolve next-hop MAC via
    ; generic ARP, then queue one TCP SYN through generic IPv4/NIC dispatch.
    cmp byte [sc_net_tcp_busy], 0
    jne .sc_net_tcp_busy
    mov byte [sc_net_tcp_busy], 1
    mov rax, rdi
    shr rax, 32
    jnz .sc_net_tcp_reject
    mov rax, rsi
    shr rax, 16
    jnz .sc_net_tcp_reject
    mov rax, rdx
    shr rax, 16
    jnz .sc_net_tcp_reject
    mov edi, [rsp + ALL_RDI]
    mov si, [rsp + ALL_RSI]
    mov dx, [rsp + ALL_RDX]
    sti
    call net_tcp_connect_ipv4
    push rax
    cli
    pop rax
    mov [rsp + ALL_RAX], rax
    mov byte [sc_net_tcp_busy], 0
    jmp .done
.sc_net_tcp_reject:
    mov byte [sc_net_tcp_busy], 0
    mov qword [rsp + ALL_RAX], -1
    jmp .done
.sc_net_tcp_busy:
    mov qword [rsp + ALL_RAX], -2
    jmp .done

.sc_net_ping4_tick:
    ; Async ping. Returns RTT (us) on success, 0 if still pending, -1 on
    ; timeout/no-link, -2 if another ping is in flight. Caller polls per
    ; frame so the GUI never freezes during the wait.
    mov rax, rdi
    shr rax, 32
    jnz .sc_net_ping4_tick_bad
    mov edi, edi
    sti
    extern net_ping4_tick
    call net_ping4_tick
    push rax
    cli
    pop rax
    mov [rsp + ALL_RAX], rax
    ; While the ping is still in flight (0 = pending, -2 = busy), keep the
    ; scene marked dirty so the WM redraws and the app's draw() pumps the
    ; tick again next frame. Without this, scene_dirty clears after the
    ; first tick and the state machine stalls.
    cmp rax, 0
    je .sc_net_ping4_tick_mark
    cmp rax, -2
    jne .done
.sc_net_ping4_tick_mark:
    mov byte [scene_dirty], 1
    jmp .done
.sc_net_ping4_tick_bad:
    mov qword [rsp + ALL_RAX], -1
    jmp .done

.sc_net_dns_a:
    ; rdi = app-owned hostname C-string. Returns IPv4 A.B.C.D or 0 on failure.
    cmp byte [sc_net_dns_busy], 0
    jne .sc_net_dns_busy
    call sc_validate_user_cstring
    test eax, eax
    jz .sc_net_dns_reject
    mov byte [sc_net_dns_busy], 1
    mov rdi, [rsp + ALL_RDI]
    sti
    call net_dns_query_a
    push rax
    cli
    pop rax
    mov [rsp + ALL_RAX], rax
    mov byte [sc_net_dns_busy], 0
    jmp .done
.sc_net_dns_reject:
    mov qword [rsp + ALL_RAX], -1
    jmp .done
.sc_net_dns_busy:
    mov qword [rsp + ALL_RAX], -2
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
    ; Canary check before handing back to the L3 return path. Layout
    ; after POP_ALL: [rsp]=slot, [rsp+8]=canary. call_app_l3_return
    ; reads slot from [rsp].
    mov rax, [rsp + 8]
    cmp rax, [rel kernel_canary]
    jne .app_done_canary_bad
    jmp call_app_l3_return
.app_done_canary_bad:
    mov rdi, rax
    lea rsi, [rel .app_done_canary_bad]
    jmp kernel_panic_canary

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
    ; Stack canary check before SYSRET. Layout after POP_ALL:
    ;   [rsp+0]  = slot id, [rsp+8] = canary, [rsp+16] = alignment pad.
    mov r10, [rsp + 8]
    cmp r10, [rel kernel_canary]
    jne .done_canary_bad
    mov edx, [rsp]
    cmp edx, MAX_WINDOWS
    jb .slot_ok_return
    xor edx, edx
    jmp .slot_ok_return
.done_canary_bad:
    mov rdi, r10
    lea rsi, [rel .done_canary_bad]
    jmp kernel_panic_canary
.slot_ok_return:
    ; Per-syscall code-segment scrub. Walk the active slot's 512-entry PT and
    ; re-assert manifest-driven W^X on every page: X+!W inside
    ; [code_start, code_end), W+NX everywhere else. Catches any X-bit drift
    ; introduced mid-syscall (JIT alias misuse, transient mappings,
    ; speculative re-mark). l3_apply_wx_policy preserves rax (syscall return)
    ; and rdx (slot id), and flushes the TLB via a CR3 reload before
    ; returning, so the new permissions are in effect on the very first
    ; instruction after SYSRETQ.
    mov edi, edx
    call l3_apply_wx_policy
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
    KPROLOGUE                           ; shadow-stack guard (syscall-stack only)
    push rbx
    push rcx
    push rdx
    push rdi
    push rsi
    push r8
    push r13                                  ; arg-desc qword, live across loop
    movzx ecx, byte [r12 + SYSCALL_ARGC_OFF]
    mov ebx, [r12 + SYSCALL_KIND_OFF]
    mov r13, [r12 + SYSCALL_ARG_DESC_OFF]
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
    push rdi
    SER 'V'
    SER 'P'
    call ser_print_hex64
    SER 13
    SER 10
    pop rdi
    ; Default length probe is 1 byte. If the descriptor names a sibling
    ; SCALAR arg as the length source, load that scalar and use it as the
    ; full byte length instead — this is the single place where PTR args
    ; get range-validated, so a handler that forgets the explicit check is
    ; still safe.
    mov rsi, 1
    ; Compute the descriptor nibble for this arg without clobbering rcx
    ; (the outer argc loop counter). r9 is scratch.
    push rcx
    mov rdx, r13
    mov r9d, r8d
    shl r9d, 2                  ; bit shift = arg_index * 4
    mov ecx, r9d
    shr rdx, cl
    pop rcx
    and edx, 0x0F
    jz .check_ptr_do
    ; edx = 1-based sibling index; reload that scalar via the same helper.
    push rdi
    push r8                     ; save current arg index (loop state)
    mov r8d, edx
    dec r8d                     ; 0-based sibling index
    call sc_load_arg_for_validation
    mov rsi, rdi                ; rsi = sibling's value = byte length
    pop r8
    pop rdi
.check_ptr_do:
    call sc_validate_user_range
    test eax, eax
    jnz .check_ptr_ok
    SER 'V'
    SER 'Q'
    SER 13
    SER 10
    jmp .validate_fail
.check_ptr_ok:
    jmp .next_arg
.check_cstring:
    call sc_load_arg_for_validation
    mov rsi, SYSCALL_MAX_STR_LEN
    call sc_validate_user_cstring
    test eax, eax
    jz .validate_fail
    jmp .next_arg
.check_handle:
    call sc_load_arg_for_validation       ; rdi = untrusted handle
    push rdi
    SER 'V'
    SER 'H'
    call ser_print_hex64
    SER 13
    SER 10
    pop rdi
    mov edx, edi
    mov rax, r15
    imul rax, APP_SLOT_SIZE
    add rax, [rel l3_app_arena_base_v]
    mov rdi, rax
    mov al, HANDLE_KIND_DIR_ENTRY
    call handle_resolve
    test eax, eax
    jnz .check_handle_ok
    SER 'V'
    SER 'X'
    SER 13
    SER 10
    jmp .validate_fail
.check_handle_ok:
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
    pop r13
    pop r8
    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    KEPILOGUE

; R8D=arg index, returns selected argument in RDI.
; Frame: ret(8) + sc_validate_from_table pushes [rbx,rcx,rdx,rdi,rsi,r8,r13]
; (56) + outer call's ret(8) = 72 bytes between rsp and the PUSH_ALL frame.
SC_VALIDATE_FRAME_OFF equ 72
sc_load_arg_for_validation:
    KPROLOGUE                           ; shadow-stack guard (syscall-stack only)
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
    KEPILOGUE

.arg0:
    mov rdi, [rsp + SC_VALIDATE_FRAME_OFF + ALL_RDI]
    KEPILOGUE
.arg1:
    mov rdi, [rsp + SC_VALIDATE_FRAME_OFF + ALL_RSI]
    KEPILOGUE
.arg2:
    mov rdi, [rsp + SC_VALIDATE_FRAME_OFF + ALL_RDX]
    KEPILOGUE
.arg3:
    mov rdi, [rsp + SC_VALIDATE_FRAME_OFF + ALL_R10]
    KEPILOGUE
.arg4:
    mov rdi, [rsp + SC_VALIDATE_FRAME_OFF + ALL_R8]
    KEPILOGUE

; sc_resolve_dir_entry_arg — translate an untrusted user-supplied dir-entry
; handle into the matching real FAT16 root-cache entry pointer.
;
;   In:  RDI = user handle (as forwarded into the syscall handler)
;        R15 = current slot id (set by syscall_entry before dispatch)
;   Out: EAX = 1 and RDI = kernel entry pointer, on success
;        EAX = 0,                                on any failure
;
; The handle is verified through the per-slot handle table (magic, kind tag,
; index range, stored kind, generation). The payload — the valid-entry index
; — is then fed back through fat16_get_entry so the returned pointer reflects
; current FAT16 cache state (a directory change after SYS_FS_ENTRY does NOT
; produce a dangling kernel VA; the handle simply resolves to whatever is at
; that index now). Volume-label / LFN / deleted entries are skipped by
; fat16_get_entry, so the index is "valid-entry index", not a raw byte
; offset.
;
; Preserves: nothing beyond RDI (which is overwritten with the kernel
; pointer). Saves and restores RCX, RDX, RSI, R8, R9, R10 so handlers can
; chain straight into the FS worker without re-loading them.
sc_resolve_dir_entry_arg:
    KPROLOGUE                           ; shadow-stack guard (syscall-stack only)
    push rcx
    push rdx
    push rsi
    push r8
    push r9
    push r10
    mov edx, edi                        ; edx = handle to verify
    mov rax, r15
    imul rax, APP_SLOT_SIZE
    add rax, [rel l3_app_arena_base_v]
    mov rdi, rax                        ; rdi = slot base
    mov al, HANDLE_KIND_DIR_ENTRY
    call handle_resolve                 ; eax = 1/0; on success R8 = payload
    test eax, eax
    jz .rdea_fail
    mov edi, r8d                        ; edi = valid-entry index
    call fat16_get_entry                ; rax = kernel entry pointer or 0
    test rax, rax
    jz .rdea_fail
    mov rdi, rax
    pop r10
    pop r9
    pop r8
    pop rsi
    pop rdx
    pop rcx
    mov eax, 1
    KEPILOGUE
.rdea_fail:
    pop r10
    pop r9
    pop r8
    pop rsi
    pop rdx
    pop rcx
    xor eax, eax
    KEPILOGUE

%define SC_KIND1(a) (a)
%define SC_KIND2(a,b) ((a) | ((b) << 2))
%define SC_KIND3(a,b,c) ((a) | ((b) << 2) | ((c) << 4))
%define SC_KIND4(a,b,c,d) ((a) | ((b) << 2) | ((c) << 4) | ((d) << 6))
%define SC_KIND5(a,b,c,d,e) ((a) | ((b) << 2) | ((c) << 4) | ((d) << 6) | ((e) << 8))
%define SC_KIND6(a,b,c,d,e,f) ((a) | ((b) << 2) | ((c) << 4) | ((d) << 6) | ((e) << 8) | ((f) << 10))

; SYSCALL_ENTRY handler, argc, kind [, caps [, arg_desc]]
;
; The optional 4th argument is the capability mask required to invoke this
; syscall — see syscall_caps.inc. Defaulting to CAP_ALL preserves legacy
; behaviour for any row that hasn't been annotated yet (sandboxing only
; bites once an app calls SYS_APP_DECLARE_MANIFEST and its mask narrows).
;
; The optional 5th argument is the per-arg sanitization descriptor — see
; SYSCALL_ARG_DESC_OFF above and the SC_DESC_LEN macros below. Default 0
; keeps the legacy 1-byte probe for PTR args; non-zero opts a row into
; sibling-driven range validation done in one place at the dispatcher.
%macro SYSCALL_ENTRY 3-5 CAP_ALL, 0
    dq %1
    db %2
    dd %3
    db %4
    db 0, 0       ; pad bytes 14..15
    dq %5         ; arg_desc at offset 16
%endmacro

; Per-arg descriptor helpers. Nibble N (4 bits) encodes the 1-based index of
; the SCALAR sibling that holds the byte length of PTR arg N. 0 means "no
; sibling; fall back to the 1-byte probe". Chain with bitwise OR:
;   SC_DESC_LEN(1, 3) | SC_DESC_LEN(3, 4)
; says "PTR arg 1 takes its length from arg 3; PTR arg 3 from arg 4".
%define SC_DESC_LEN(arg_idx, len_sibling_1based) ((len_sibling_1based) << ((arg_idx)*4))

section .text
align 8
syscall_table:
    SYSCALL_ENTRY syscall_entry.sc_print,            1, SC_KIND1(FN_KIND_CSTRING), CAP_CORE
    SYSCALL_ENTRY syscall_entry.sc_exit,             0, 0,                          CAP_CORE
    SYSCALL_ENTRY syscall_entry.sc_gui_rect,         5, SC_KIND5(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR), CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_gui_text,         5, SC_KIND5(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_CSTRING, FN_KIND_SCALAR, FN_KIND_SCALAR), CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_fs_count,         0, 0,                          CAP_FS
    SYSCALL_ENTRY syscall_entry.sc_fs_entry,         1, SC_KIND1(FN_KIND_SCALAR),   CAP_FS
    SYSCALL_ENTRY syscall_entry.sc_fs_chdir,         1, SC_KIND1(FN_KIND_SCALAR),   CAP_FS
    SYSCALL_ENTRY syscall_entry.sc_wm_create,        6, SC_KIND6(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_CSTRING, FN_KIND_SCALAR), CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_fs_read,          3, SC_KIND3(FN_KIND_HANDLE, FN_KIND_PTR, FN_KIND_SCALAR), CAP_FS, SC_DESC_LEN(1, 3)
    SYSCALL_ENTRY syscall_entry.sc_wm_handlers,      3, SC_KIND3(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR), CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_app_done,         0, 0,                          CAP_CORE
    SYSCALL_ENTRY syscall_entry.sc_fs_format_name,   2, SC_KIND2(FN_KIND_HANDLE, FN_KIND_PTR), CAP_FS
    SYSCALL_ENTRY syscall_entry.sc_app_launch,       1, SC_KIND1(FN_KIND_SCALAR),   CAP_APP_CTRL
    SYSCALL_ENTRY syscall_entry.sc_fs_write,         3, SC_KIND3(FN_KIND_PTR, FN_KIND_PTR, FN_KIND_SCALAR), CAP_FS
    SYSCALL_ENTRY syscall_entry.sc_fs_sync_root,     0, 0,                          CAP_FS
    SYSCALL_ENTRY syscall_entry.sc_wm_close,         1, SC_KIND1(FN_KIND_SCALAR),   CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_display_set_mode, 3, SC_KIND3(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR), CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_cursor_init,      0, 0,                          CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_ticks,            0, 0,                          CAP_CORE
    SYSCALL_ENTRY syscall_entry.sc_fs_delete,        1, SC_KIND1(FN_KIND_HANDLE),   CAP_FS
    SYSCALL_ENTRY syscall_entry.sc_fs_rename,        2, SC_KIND2(FN_KIND_HANDLE, FN_KIND_PTR), CAP_FS
    SYSCALL_ENTRY syscall_entry.sc_fs_mkdir,         1, SC_KIND1(FN_KIND_PTR),      CAP_FS
    SYSCALL_ENTRY syscall_entry.sc_open_file_np,     1, SC_KIND1(FN_KIND_HANDLE),   CAP_APP_CTRL
    SYSCALL_ENTRY syscall_entry.sc_app_open,         1, SC_KIND1(FN_KIND_CSTRING),  CAP_APP_CTRL
    SYSCALL_ENTRY syscall_entry.sc_display_flags,    0, 0,                          CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_display_set_flags, 1, SC_KIND1(FN_KIND_SCALAR),  CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_desktop_bg,       0, 0,                          CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_desktop_set_bg,   1, SC_KIND1(FN_KIND_SCALAR),   CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_display_native,   0, 0,                          CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_display_size,     0, 0,                          CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_xml_parse,        2, SC_KIND2(FN_KIND_PTR, FN_KIND_SCALAR), CAP_GUI, SC_DESC_LEN(0, 2)
    SYSCALL_ENTRY syscall_entry.sc_xml_root,         0, 0,                          CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_xml_tag,          1, SC_KIND1(FN_KIND_SCALAR),   CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_xml_tag_name,     3, SC_KIND3(FN_KIND_SCALAR, FN_KIND_PTR, FN_KIND_SCALAR), CAP_GUI, SC_DESC_LEN(1, 3)
    SYSCALL_ENTRY syscall_entry.sc_xml_first_child,  1, SC_KIND1(FN_KIND_SCALAR),   CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_xml_next_sibling, 1, SC_KIND1(FN_KIND_SCALAR),   CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_xml_parent,       1, SC_KIND1(FN_KIND_SCALAR),   CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_xml_attr,         5, SC_KIND5(FN_KIND_SCALAR, FN_KIND_PTR, FN_KIND_SCALAR, FN_KIND_PTR, FN_KIND_SCALAR), CAP_GUI, (SC_DESC_LEN(1, 3) | SC_DESC_LEN(3, 5))
    SYSCALL_ENTRY syscall_entry.sc_xml_text,         3, SC_KIND3(FN_KIND_SCALAR, FN_KIND_PTR, FN_KIND_SCALAR), CAP_GUI, SC_DESC_LEN(1, 3)
    SYSCALL_ENTRY syscall_entry.sc_xml_free,         0, 0,                          CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_draw_line,        5, SC_KIND5(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR), CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_fill_circle,      4, SC_KIND4(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR), CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_fill_triangle,    2, SC_KIND2(FN_KIND_PTR, FN_KIND_SCALAR), CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_xml_last_error,   0, 0,                          CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_xml_node_count,   0, 0,                          CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_blend_pixel,      3, SC_KIND3(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR), CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_blend_span,       4, SC_KIND4(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR), CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_xml_text_runs,    1, SC_KIND1(FN_KIND_SCALAR),   CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_xml_text_run,     4, SC_KIND4(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_PTR, FN_KIND_SCALAR), CAP_GUI, SC_DESC_LEN(2, 4)
    SYSCALL_ENTRY syscall_entry.sc_xml_namespace,    5, SC_KIND5(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_PTR, FN_KIND_SCALAR), CAP_GUI, SC_DESC_LEN(3, 5)
    SYSCALL_ENTRY syscall_entry.sc_xml_node_namespace, 3, SC_KIND3(FN_KIND_SCALAR, FN_KIND_PTR, FN_KIND_SCALAR), CAP_GUI, SC_DESC_LEN(1, 3)
    SYSCALL_ENTRY syscall_entry.sc_xml_entity_value, 4, SC_KIND4(FN_KIND_PTR, FN_KIND_SCALAR, FN_KIND_PTR, FN_KIND_SCALAR), CAP_GUI, (SC_DESC_LEN(0, 2) | SC_DESC_LEN(2, 4))
    SYSCALL_ENTRY syscall_entry.sc_blend_span_argb,  4, SC_KIND4(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_PTR), CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_blend_span_argb_screen, 4, SC_KIND4(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_PTR), CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_blend_span_argb_multiply, 4, SC_KIND4(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_PTR), CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_sysinfo,          2, SC_KIND2(FN_KIND_SCALAR, FN_KIND_SCALAR), CAP_CORE
    SYSCALL_ENTRY syscall_entry.sc_net_ping4,        1, SC_KIND1(FN_KIND_SCALAR),   CAP_NET
    SYSCALL_ENTRY syscall_entry.sc_net_info,         1, SC_KIND1(FN_KIND_SCALAR),   CAP_NET
    SYSCALL_ENTRY syscall_entry.sc_net_dhcp_renew,   0, 0,                          CAP_NET
    SYSCALL_ENTRY syscall_entry.sc_net_dhcp_start,   0, 0,                          CAP_NET
    SYSCALL_ENTRY syscall_entry.sc_net_tcp_connect4,  3, SC_KIND3(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR), CAP_NET
    SYSCALL_ENTRY syscall_entry.sc_net_dns_a,        1, SC_KIND1(FN_KIND_PTR),      CAP_NET
    SYSCALL_ENTRY syscall_entry.sc_net_ping4_tick,   1, SC_KIND1(FN_KIND_SCALAR),   CAP_NET
    SYSCALL_ENTRY syscall_entry.sc_desktop_bg_busy,   0, 0,                         CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_open_file_media,   1, SC_KIND1(FN_KIND_HANDLE),  CAP_APP_CTRL
    SYSCALL_ENTRY syscall_entry.sc_wm_set_user_arg,   2, SC_KIND2(FN_KIND_SCALAR, FN_KIND_SCALAR), CAP_GUI
    ; sc_media_blit_scaled — secure aspect-preserving BGRA blit; src is
    ; PTR-validated to live inside the calling slot before the scaler runs.
    SYSCALL_ENTRY syscall_entry.sc_media_blit_scaled, 5, SC_KIND5(FN_KIND_SCALAR, FN_KIND_PTR, FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR), CAP_MEDIA
    SYSCALL_ENTRY syscall_entry.sc_wx_install_manifest, 2, SC_KIND2(FN_KIND_SCALAR, FN_KIND_SCALAR), CAP_WX
    SYSCALL_ENTRY syscall_entry.sc_mprotect_wx,      2, SC_KIND2(FN_KIND_SCALAR, FN_KIND_SCALAR), CAP_WX
    SYSCALL_ENTRY syscall_entry.sc_wx_jit_alias,     3, SC_KIND3(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR), CAP_WX
    ; SYS_HANDLE_CLOSE — handle is a scalar from the validator's POV
    ; (handle_close does the magic/kind/gen verification internally).
    SYSCALL_ENTRY syscall_entry.sc_handle_close,     1, SC_KIND1(FN_KIND_SCALAR),   CAP_CORE
    ; SYS_FS_ENTRY_INFO — (handle, out_buf, out_buf_len). The handle is
    ; FN_KIND_HANDLE so a bad handle is rejected before sc_fs_entry_info
    ; runs; out_buf is FN_KIND_PTR with a 1-byte probe (the handler does
    ; the full 20-byte range check against the user mapping).
    SYSCALL_ENTRY syscall_entry.sc_fs_entry_info,    3, SC_KIND3(FN_KIND_HANDLE, FN_KIND_PTR, FN_KIND_SCALAR), CAP_FS
    ; SYS_APP_DECLARE_MANIFEST(app_id) — narrow the calling slot's cap mask
    ; to the manifest declared for app_id in syscall_caps.inc. One-way: a
    ; sandboxed app can never widen its mask. Tagged CAP_CORE so even a
    ; deeply-sandboxed app can still call it (a no-op the second time).
    SYSCALL_ENTRY syscall_entry.sc_app_declare_manifest, 1, SC_KIND1(FN_KIND_SCALAR), CAP_CORE
    ; SYS_WM_GET_USER_ARG — tag-verified read of WIN_OFF_USER_ARG. Reader
    ; companion to SYS_WM_SET_USER_ARG; required so user-mode draw fns no
    ; longer dereference window-pool memory directly to fetch their arg.
    SYSCALL_ENTRY syscall_entry.sc_wm_get_user_arg,  1, SC_KIND1(FN_KIND_SCALAR), CAP_GUI
syscall_table_end:
syscall_table_count equ (syscall_table_end - syscall_table) / SYSCALL_ENTRY_SIZE

FN_BEGIN test_syscall_proc, 0, 0, FN_RET_VOID
.loop:
    hlt
    jmp .loop

; ----------------------------------------------------------------------------
; kernel_canary_init - seed the global stack canary from RDTSC ^ RDRAND (when
; available). Called once from kernel_main before syscall_init so every
; SYSCALL pushes a unique value. RDRAND failure (older CPUs, QEMU TCG) falls
; back to RDTSC alone; a final non-zero guard prevents an all-zero canary.
; ----------------------------------------------------------------------------
FN_BEGIN kernel_canary_init, 0, 0, FN_RET_VOID
    push rax
    push rbx
    push rcx
    push rdx
    rdtsc
    shl rdx, 32
    or rax, rdx
    mov rbx, rax
    mov eax, 1
    cpuid
    test ecx, 1 << 30                 ; CPUID.01H:ECX.RDRAND[bit 30]
    jz .kc_no_rdrand
    mov ecx, 8
.kc_try_rdrand:
    rdrand rax
    jc .kc_have_rdrand
    dec ecx
    jnz .kc_try_rdrand
    jmp .kc_no_rdrand
.kc_have_rdrand:
    xor rbx, rax
.kc_no_rdrand:
    test rbx, rbx
    jnz .kc_store
    mov rbx, 0xDEADC0DEDEADC0DE
.kc_store:
    mov [rel kernel_canary], rbx
    pop rdx
    pop rcx
    pop rbx
    pop rax
    FN_END kernel_canary_init
    ret

; ----------------------------------------------------------------------------
; CPI-lite — sign/verify the callback pointers stored in window structs at
; WIN_OFF_CLICKFN / WIN_OFF_KEYFN / WIN_OFF_DRAGFN / WIN_OFF_RCLICKFN. Same
; trick already used for WIN_OFF_USER_ARG (see .sc_wm_set_user_arg above),
; generalised so a forged callback pointer is rejected at dispatch time.
;
; Tag = low16(kernel_canary ^ &window ^ field_offset), stamped into the
; high 16 bits of the stored qword (callback pointers are kernel-image VAs
; whose top half is zero, so the room is free). Binding the offset means a
; value forged for CLICKFN can't be relocated to KEYFN, and binding &window
; means a tag captured from window A is useless in window B. An attacker
; must leak both kernel_canary and the window VA before they can forge a
; usable entry — significantly stronger than "raw write hits a code ptr".
;
; A stored qword of exactly 0 is the explicit "no handler / detach"
; sentinel: stamping a tag onto 0 would either force detach to use a magic
; token or force readers to special-case the tag-of-zero, so signing 0
; just yields 0. Real handlers should never be 0.
; ----------------------------------------------------------------------------

; cpi_sign_callback(rdi=raw_fn, rsi=&window, rdx=field_offset) -> rax=stamped.
; Clobbers only rax (rcx saved/restored internally).
global cpi_sign_callback
FN_BEGIN cpi_sign_callback, 3, SC_KIND3(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR), FN_RET_SCALAR
    test rdi, rdi
    jz .csc_zero
    push rcx
    mov rax, rdi
    mov rcx, 0x0000FFFFFFFFFFFF
    and rax, rcx                      ; mask the would-be tag bits
    mov rcx, [rel kernel_canary]
    xor rcx, rsi                      ; mix per-window struct address
    xor rcx, rdx                      ; mix field offset
    movzx ecx, cx
    shl rcx, 48
    or rax, rcx
    pop rcx
    FN_END cpi_sign_callback
    ret
.csc_zero:
    xor eax, eax
    FN_END cpi_sign_callback
    ret

; cpi_verify_callback(rdi=stored, rsi=&window, rdx=field_offset)
;   returns rax = raw_fn pointer (top 16 bits cleared) on success,
;   or rax = 0 if stored was 0 (handler detached / never installed).
; A non-zero stored value whose tag does NOT match is a CPI violation:
; we jump to kernel_panic_canary so corruption never reaches dispatch.
; Clobbers only rax (rcx, r8 saved/restored internally) on the success path.
global cpi_verify_callback
FN_BEGIN cpi_verify_callback, 3, SC_KIND3(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR), FN_RET_SCALAR
    test rdi, rdi
    jz .cvc_zero
    push rcx
    push r8
    mov rcx, [rel kernel_canary]
    xor rcx, rsi
    xor rcx, rdx
    movzx ecx, cx
    shl rcx, 48                       ; expected tag bits
    mov rax, rdi
    mov r8, 0xFFFF000000000000
    and rax, r8
    cmp rax, rcx
    jne .cvc_bad
    mov rax, rdi
    mov r8, 0x0000FFFFFFFFFFFF
    and rax, r8
    pop r8
    pop rcx
    FN_END cpi_verify_callback
    ret
.cvc_zero:
    xor eax, eax
    FN_END cpi_verify_callback
    ret
.cvc_bad:
    ; Pointer corruption detected. Hand the forged value to the existing
    ; canary panic path so the operator sees the same CANARY <bad> @<rip>
    ; serial trace. rdi already holds the observed bad stored qword.
    pop r8
    pop rcx
    lea rsi, [rel .cvc_bad]
    jmp kernel_panic_canary

; ----------------------------------------------------------------------------
; kernel_panic_canary - reached only from the syscall exit paths when the
; saved canary slot does not match kernel_canary. rdi = observed bad value,
; rsi = approximate kernel RIP at detection. Serial-logs and halts; never
; returns.
; ----------------------------------------------------------------------------
global kernel_panic_canary
kernel_panic_canary:
    cli
    SER 'C'
    SER 'A'
    SER 'N'
    SER 'A'
    SER 'R'
    SER 'Y'
    SER ' '
    call ser_print_hex64                ; rdi = bad canary
    SER ' '
    SER '@'
    mov rdi, rsi
    call ser_print_hex64                ; rsi = detection RIP
    SER 13
    SER 10
.kpc_halt:
    cli
    hlt
    jmp .kpc_halt

; kernel_panic_shadow - reached only from KEPILOGUE when a shadow-protected
; function's saved return address no longer matches its parallel-page mirror
; (see src/include/shadow_stack.inc). rdi = observed (corrupted) return
; address, rsi = expected return address from the shadow page. Serial-logs
; and halts; never returns.
; ----------------------------------------------------------------------------
global kernel_panic_shadow
kernel_panic_shadow:
    cli
    SER 'S'
    SER 'H'
    SER 'A'
    SER 'D'
    SER 'O'
    SER 'W'
    SER ' '
    call ser_print_hex64                ; rdi = observed (bad) return address
    SER ' '
    SER '!'
    mov rdi, rsi
    call ser_print_hex64                ; rsi = expected (shadow) return address
    SER 13
    SER 10
.kps_halt:
    cli
    hlt
    jmp .kps_halt

%ifdef ENABLE_SHADOW_STACK_POC
; ----------------------------------------------------------------------------
; shadow_stack_poc_run - build-gated proof harness for the kernel shadow stack.
; Called once from kmain after l3_install_syscall_stack_pt (so the slot-0
; syscall stack and its parallel shadow page are mapped). It switches RSP onto
; slot 0's syscall stack, calls a shadow-protected stub that deliberately
; smashes its own saved return address, and confirms KEPILOGUE traps to
; kernel_panic_shadow. Serial output:
;   "POCS"            harness started
;   "SHADOW <bad> ! <expected>" + halt   -> guard working (expected outcome)
;   "POCF"            corruption NOT caught -> guard broken (regression)
; Never compiled into release builds (see build_uefi.ps1 -ShadowStackPoc).
; ----------------------------------------------------------------------------
extern l3_syscall_stack_top
global shadow_stack_poc_run
shadow_stack_poc_run:
    SER 'P'
    SER 'O'
    SER 'C'
    SER 'S'
    SER 13
    SER 10
    mov [rel shadow_poc_saved_rsp], rsp
    xor edi, edi
    call l3_syscall_stack_top           ; rax = slot 0 syscall stack top (mapped)
    mov rsp, rax
    call shadow_poc_trip                ; expected: never returns (panics)
    ; Reached only if the shadow check FAILED to fire.
    mov rsp, [rel shadow_poc_saved_rsp]
    SER 'P'
    SER 'O'
    SER 'C'
    SER 'F'
    SER 13
    SER 10
    ret

; Shadow-protected frame: KPROLOGUE mirrors the true return address into the
; parallel shadow page, we then overwrite the on-stack copy, and KEPILOGUE
; must detect the divergence before returning.
shadow_poc_trip:
    KPROLOGUE
    mov rax, 0xDEADBEEFCAFEBABE
    mov [rsp], rax                      ; smash the saved return address
    KEPILOGUE                           ; -> kernel_panic_shadow on mismatch
%endif

; --- Data/BSS Sections moved here ---
section .data
global syscall_count
syscall_count: dq 0
align 8
global kernel_canary
kernel_canary: dq 0
%ifdef ENABLE_SHADOW_STACK_POC
shadow_poc_saved_rsp: dq 0
%endif
sc_net_ping_busy: db 0
sc_net_tcp_busy: db 0
sc_net_dns_busy: db 0
szHelloUser: db "-> Hello from RING 3 (via SYSCALL)!", 0

; Per-slot effective capability mask. Initialised to CAP_ALL so unsandboxed
; apps see no behaviour change. SYS_APP_DECLARE_MANIFEST narrows entries
; with AND; nothing widens them. The dispatcher reads slot_cap_mask[r15]
; on every syscall before invoking the handler.
align 8
slot_cap_mask: times MAX_WINDOWS db CAP_ALL

section .text
; kernel_apply_app_manifest(rdi=slot, rsi=app_id)
;
; Kernel-only helper that sets slot_cap_mask[slot] = manifest(app_id).
; Called from the user-side app_launch (which runs in CPL0 — see the SER
; macros it uses) right after wm_create_window_ex returns a slot. This is
; the *required* enforcement point: every launch path the system supports
; ends up here, so apps can't run a single syscall outside their manifest.
;
; Out-of-range slot or app_id is a no-op so a launcher with a stale app_id
; doesn't accidentally widen CAP_ALL → 0. The current dispatcher leaves the
; default CAP_ALL in place; if you want strict deny-by-default, change the
; .kam_done fallback to clear slot_cap_mask[slot] instead.
;
; Clobbers: rax, rcx.
FN_BEGIN kernel_apply_app_manifest, 2, SC_KIND2(FN_KIND_SCALAR, FN_KIND_SCALAR), FN_RET_VOID
    cmp rsi, APP_MIN_ID
    jb .kam_done
    cmp rsi, APP_MAX_ID
    ja .kam_done
    cmp edi, MAX_WINDOWS
    jae .kam_done
    sub rsi, APP_MIN_ID
    lea rcx, [rel app_manifest_table]
    mov al, [rcx + rsi]
    lea rcx, [rel slot_cap_mask]
    mov [rcx + rdi], al
.kam_done:
    ret
section .data

; app_id -> capability mask. Indexed by (app_id - APP_MIN_ID). Keep in sync
; with the MANIFEST_* defines in syscall_caps.inc; the indirection here keeps
; the table dense and lets the dispatcher resolve a manifest in one load.
align 8
app_manifest_table:
    db MANIFEST_EXPLORER                ; APP_EXPLORER         (2)
    db MANIFEST_TERMINAL                ; APP_TERMINAL         (3)
    db MANIFEST_NOTEPAD                 ; APP_NOTEPAD          (4)
    db MANIFEST_SETTINGS                ; APP_SETTINGS         (5)
    db MANIFEST_PAINT                   ; APP_PAINT            (6)
    db MANIFEST_ABOUT                   ; APP_ABOUT            (7)
    db MANIFEST_SECURITY_PROBE          ; APP_SECURITY_PROBE   (8)
    db MANIFEST_TASKMGR                 ; APP_TASKMGR          (9)
    db MANIFEST_PING                    ; APP_PING            (10)
    db MANIFEST_MEDIA                   ; APP_MEDIA           (11)

section .text
