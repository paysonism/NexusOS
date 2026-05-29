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
%include "kdomain_hmac.inc"       ; one domain-separated HMAC primitive (§13)
%include "shadow_stack.inc"
%include "syscall_trace.inc"
%include "qrng_seed.inc"          ; quantum entropy blob folded into the canary

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
; Single-byte per-entry flags packed into a former padding byte (offset 14).
; SC_FLAG_STRICT (security_todo.md §2, "Mandatory non-zero arg_desc for every
; PTR arg") opts a row into deny-on-unmigrated: any FN_KIND_PTR arg whose
; arg_desc nibble is still 0 (never migrated to a sibling-length descriptor)
; is rejected by the validator instead of falling back to the legacy 1-byte
; probe. Lets rows be flipped to strict one at a time as their descriptors
; land; un-flagged rows keep the legacy probe.
SYSCALL_FLAGS_OFF   equ 14
SC_FLAG_STRICT      equ 0x01
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
extern serial_puts
extern serial_putc
extern serial_crlf
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
    ; Kernel-entry FS/GS sanitization (security_todo.md §3). Load kernel data
    ; selectors into ds/es/fs/gs so no user-controlled selector is in force
    ; while in ring 0; under -dENABLE_FSGS_MSR_SCRUB also zeroes the FS/GS base
    ; MSRs (no-op in the flat model, deterministic if FSGSBASE is ever enabled).
    ; Clobbers ax only — rcx (user RIP) and the rest of the live state survive.
    SANITIZE_SEG_KERNEL_ENTRY

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

    ; Always-on per-syscall trace ring + per-slot histogram (security_todo.md
    ; §11). Promotes the old compile-gated ENABLE_TRACE serial logger to a cheap
    ; in-memory, slot-isolated record of the last SC_TRACE_RING_ENTRIES calls
    ; per slot, plus a per-slot syscall-number histogram. The ring gives a
    ; crash/panic the faulting slot's recent call sequence; the histogram is the
    ; data source the §11 anomaly detector (sc_anomaly_scan_all, run on the pit
    ; cadence) scans for a syscall mix that deviates from the app's profile.
    ; Inline (no CALL), a handful of instructions; clobbers only rax/rbx/rcx/
    ; rdx/r8, all reloaded from the saved PUSH_ALL frame before the handler runs.
    SC_TRACE_APPEND

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
%ifdef ENABLE_DEBUG_SERIAL
    ; Validator post-condition (§2, debug build only): clear this slot's
    ; snapshot-valid flag at the start of every dispatch so only a fully
    ; validated syscall (which re-sets it after sc_validate_from_table passes)
    ; is rechecked at return. Reject and non-validated paths leave it cleared,
    ; so .done skips them. rax holds the syscall number here — preserve it.
    push rax
    push rcx
    lea rcx, [rel sc_postcond_valid]
    movzx eax, r15b
    mov byte [rcx + rax], 0
    pop rcx
    pop rax
%endif
    cmp rax, syscall_table_count
    jae .sc_invalid
%ifdef ENABLE_SYSCALL_PERM
    ; Heterogeneous syscall numbering per slot (security_todo.md §12). rax holds
    ; the APP-VISIBLE syscall number (bounds-checked < syscall_table_count just
    ; above). Translate it to the REAL syscall_table row through this slot's
    ; inverse permutation, so a static exploit blob baked against one layout
    ; lands on the wrong handler in another launch. The forward permutation is
    ; what a (future) loader-side rewrite would apply to the app's SYS_*
    ; constants; sc_slot_perm_inv[] is the kernel's inverse, recovering the row.
    ;
    ; CONSTANT-TIME: a single indexed load, no data-dependent branch on the
    ; syscall number (consistent with the constant-time arg-loader, §2). The
    ; lfence-before-indirect-jmp Spectre-v2 barrier downstream is untouched.
    ;
    ; sc_slot_perm_generate lazily builds this slot's permutation on first use
    ; (BSS-zero "not generated" sentinel); until generated the table is identity,
    ; so a slot that has never dispatched still maps every number to itself.
    ; OFF by default -> this whole block is absent and rax is the row directly,
    ; so the default image is functionally identical to today's identity map.
    push rax
    push rcx
    push rdx
    push rdi
    movzx edi, r15b
    call sc_slot_perm_ensure            ; generate this slot's perm once
    pop rdi
    pop rdx
    pop rcx
    pop rax
    movzx ecx, r15b
    imul ecx, ecx, syscall_table_count  ; slot's inverse-table base
    add rcx, rax                        ; + app-visible number = flat index
    lea rdx, [rel sc_slot_perm_inv]
    movzx eax, byte [rdx + rcx]         ; eax = real syscall_table row
    ; Re-publish the REAL number into the saved frame so every downstream gate
    ; (cap/allowlist bitmap, rate, strike, post-condition) keys off the real row,
    ; not the app-visible one. The trace ring (appended pre-dispatch) keeps the
    ; app-visible value, which is the number the app actually issued.
    mov [rsp + ALL_RAX], rax
%endif
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
    ; Time-of-check authentication of the cap mask. slot_cap_mask[] is plain
    ; kernel data; any kernel-write bug that flips a bit there would silently
    ; widen this slot's capabilities. Before trusting dl we recompute the
    ; per-slot HMAC (low8(kernel_canary ^ slot ^ mask ^ KDOM_CAP_MASK)) and
    ; compare it against the authenticator stamped alongside the mask. A
    ; mismatch means the mask was tampered with after the last legitimate
    ; write, so we panic on the same CANARY path as CPI corruption rather than
    ; dispatch on a forged mask. Done before the cap AND so a widened mask is
    ; never even consulted. Clobbers r8/r9 only (rax=cap bit, rcx/rdx live).
    movzx r8d, r15b                 ; slot id
    movzx eax, dl                   ; claimed mask byte (rax scratch, reloaded below)
    ; low8(kernel_canary ^ slot ^ mask ^ KDOM_CAP_MASK); same primitive and same
    ; domain (0x5C) as cap_mask_sign, so the comparison stays value-identical (§13).
    KHMAC_TAG r9, r9d, r9b, r8, rax, KDOM_CAP_MASK
    lea r8, [rel slot_cap_hmac]
    movzx eax, r15b                 ; reload slot into a scratch index reg
    add r8, rax
    movzx eax, byte [r8]            ; stored authenticator for this slot
    cmp r9b, al
    jne .sc_cap_tamper
    movzx eax, byte [r12 + SYSCALL_CAP_OFF]   ; restore cap bit (al was scratch)
    and dl, al
    cmp dl, al
    jne .sc_cap_reject
    ; Per-syscall allowlist gate (security_todo.md §2, "Manifest declares
    ; syscall set, not just cap bits"). The coarse cap mask above only proves
    ; this syscall's *domain* is granted; slot_syscall_allow[] is a finer
    ; per-slot bitmap (one bit per syscall number) so an app is confined to the
    ; exact call set its manifest implies — e.g. Notepad keeps CAP_FS but its
    ; bitmap clears SYS_FS_DELETE. Undeclared/legacy slots have an all-ones
    ; bitmap (BSS 0xFF fill), so this gate is a no-op until a manifest narrows
    ; it. Checked after the cap gate so a forbidden-domain call still rejects
    ; for the cap reason, but before rate/arg validation so a denied syscall
    ; can't probe pointer behaviour. r8/r9/rcx scratch here (rcx reloaded by
    ; the rate gate below); rax=cap bit and rdx=mask are dead past this point.
    mov r9, [rsp + ALL_RAX]             ; syscall number (validated < count above)
    mov r8, r9
    shr r8, 3                           ; byte index within the bitmap
    movzx ecx, r15b
    imul ecx, ecx, SC_ALLOW_BYTES       ; slot's bitmap base offset
    add r8, rcx
    lea rcx, [rel slot_syscall_allow]
    movzx r8d, byte [rcx + r8]          ; the bitmap byte holding this syscall's bit
    and r9d, 7                          ; bit position 0..7
    bt r8d, r9d
    jnc .sc_cap_reject                  ; bit clear == syscall not in slot's set
    ; Rate-limit gate: spend one token from this slot's per-tick bucket. The
    ; bucket is refilled to SC_BUDGET_PER_TICK by pit_handler each timer tick;
    ; a slot that has drained it this tick is throttled (deny -1) so a fuzzer
    ; can't issue millions of calls between ticks. Checked after the cap gate
    ; so a forbidden syscall is still rejected for the right reason, but before
    ; argument validation so a throttled slot can't probe pointer behaviour.
    ;
    ; GUI rendering syscalls are exempt from the budget. A single desktop/window
    ; redraw issues thousands of draw calls, and continuous content (video
    ; playback) redraws every frame, so charging them drains the bucket and the
    ; rejected draw calls leave the window painted as a blank/white frame. GUI
    ; calls are not the fuzzing/side-channel oracle the budget defends against
    ; (those are the FS/probe/WX surfaces) — their worst-case abuse is spamming
    ; the screen, which is visible and vsync-bounded, not a hidden oracle. See
    ; security_todo.md §2.
    test byte [r12 + SYSCALL_CAP_OFF], CAP_GUI
    jnz .sc_rate_ok
    movzx ecx, r15b
    lea rdx, [rel slot_sc_budget]
    movzx eax, word [rdx + rcx*2]
    test eax, eax
    jz .sc_rate_reject
    dec eax
    mov [rdx + rcx*2], ax
.sc_rate_ok:
    call sc_validate_from_table
    test eax, eax
    jz .sc_validate_reject
%ifdef ENABLE_DEBUG_SERIAL
    ; Validator post-condition snapshot (§2, debug build only). The arg
    ; registers were validated above; copy the 6 saved arg qwords from the
    ; PUSH_ALL frame into this slot's snapshot buffer so the return path can
    ; detect a handler that scribbles its own saved-frame args (handler-side
    ; TOCTOU on the validated values). Done before the handler runs and before
    ; the arg-register reloads below, so it captures exactly what was validated.
    ; rax/rcx clobbered here are reloaded from the frame by the reloads below.
    movzx eax, r15b
    imul eax, eax, 48                    ; 6 qwords * 8 = 48 bytes per slot
    lea rcx, [rel sc_postcond_args]
    add rcx, rax
    mov rax, [rsp + ALL_RDI]
    mov [rcx + 0], rax
    mov rax, [rsp + ALL_RSI]
    mov [rcx + 8], rax
    mov rax, [rsp + ALL_RDX]
    mov [rcx + 16], rax
    mov rax, [rsp + ALL_R10]
    mov [rcx + 24], rax
    mov rax, [rsp + ALL_R8]
    mov [rcx + 32], rax
    mov rax, [rsp + ALL_R9]
    mov [rcx + 40], rax
    lea rcx, [rel sc_postcond_valid]
    movzx eax, r15b
    mov byte [rcx + rax], 1              ; arm the return-path recheck for this slot
%endif
    mov rdi, [rsp + ALL_RDI]
    mov rsi, [rsp + ALL_RSI]
    mov rdx, [rsp + ALL_RDX]
    mov r10, [rsp + ALL_R10]
    mov r8,  [rsp + ALL_R8]
    mov r9,  [rsp + ALL_R9]
    lfence                                  ; Spectre-v2 barrier: serialize speculation before the dispatcher's indirect branch
    jmp qword [r12 + SYSCALL_HANDLER_OFF]

.sc_validate_reject:
    call sc_record_strike                   ; §12: count this security reject; may kill the slot
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
    call sc_record_strike                   ; §12: count this security reject; may kill the slot
%ifdef ENABLE_TRACE
    mov rdi, [rsp + ALL_RAX]
    mov esi, r15d
    mov rdx, [rsp + ALL_RDI]
    mov ecx, TRACE_FLAG_VALIDATE_FAIL
    call trace_syscall
%endif
    mov qword [rsp + ALL_RAX], -1
    jmp .done

; Cap-mask authenticator mismatch: slot_cap_mask[r15] no longer matches its
; HMAC, so the mask was corrupted after the last legitimate (re-stamped)
; write. This is a security-fatal condition (a deny is not enough — the mask
; the kernel can see is untrustworthy), so route it to the existing CANARY
; panic path. rdi = observed (unauthenticated) mask byte, rsi = detection RIP.
.sc_cap_tamper:
    movzx edi, dl
    lea rsi, [rel .sc_cap_tamper]
    jmp kernel_panic_canary

.sc_rate_reject:
    push rax
    push rdx
    mov dx, 0x3F8
    mov al, '#'
    out dx, al
    mov al, '0'
    add al, r15b
    out dx, al
    pop rdx
    pop rax
    call sc_record_strike                   ; §12: count this security reject; may kill the slot
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
    ; DEBUG: log every SYS_WM_CREATE with the calling slot (r15) and the drawfn
    ; so the serial log shows which app is spawning windows and how often.
    call dbg_wmcreate_log
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
    ; tag = low16(kernel_canary ^ &window); KDOM_USER_ARG is 0 so this is
    ; byte-identical to the former hand-written sequence (see §13).
    KHMAC_TAG rdx, edx, dx, rax, 0, KDOM_USER_ARG
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
    KHMAC_TAG rdx, edx, dx, rax, 0, KDOM_USER_ARG
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
    ; Re-stamp the authenticator alongside the mask (cap_mask_store) so the
    ; reset mask is recognised as legitimate, not as tampering, at the next
    ; dispatch for this slot. Default-deny (security_todo.md §4): a recycled
    ; slot drops to CAP_CORE, not CAP_ALL — the next tenant re-narrows to its
    ; own manifest via kernel_apply_app_manifest at launch (APPLY_MANIFEST).
    ; Audit the transition first (cap_audit_log preserves all caller regs).
    lea rcx, [rel slot_cap_mask]
    movzx edx, r15b
    movzx ebx, byte [rcx + rdx]       ; old mask before the reset
    movzx edi, r15b
    mov esi, ebx                      ; old_mask
    mov edx, CAP_CORE                 ; new_mask
    mov ecx, CAP_AUDIT_RECYCLE
    xor r8d, r8d                      ; no app_id for a recycle
    call cap_audit_log
    movzx edi, r15b
    mov esi, CAP_CORE
    call cap_mask_store               ; (rdi=slot, rsi=CAP_CORE)
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
    ; rdi = kernel FAT16 entry (supervisor); rsi = user out buffer (PTE.U=1).
    ; Bracket the whole copy so the [rsi+...] stores don't SMAP-#PF; stac does
    ; not affect the supervisor [rdi+...] loads.
    USER_ACCESS_BEGIN
    mov rax, [rdi + 0]
    mov [rsi + 0], rax
    mov eax, [rdi + 8]
    mov [rsi + 8], eax
    movzx eax, word [rdi + 26]
    mov [rsi + 12], ax
    mov word [rsi + 14], 0
    mov eax, [rdi + 28]
    mov [rsi + 16], eax
    USER_ACCESS_END
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
    push rdi                          ; stash original app_id for the audit record
    sub edi, APP_MIN_ID
    lea rcx, [rel app_manifest_table]
    movzx eax, byte [rcx + rdi]       ; manifest cap bits for this app
    lea rcx, [rel slot_cap_mask]
    movzx edx, r15b
    movzx ebx, byte [rcx + rdx]       ; old mask (for the audit record)
    and al, bl                        ; AND-narrow against the current mask
    ; Audit this capability transition before persisting it (security_todo.md
    ; §4). cap_audit_log(dil=slot, sil=old, dl=new, cl=reason, r8d=app_id);
    ; it preserves all caller regs.
    movzx edi, r15b
    mov esi, ebx                      ; old_mask
    movzx edx, al                     ; new_mask
    mov ecx, CAP_AUDIT_DECLARE
    mov r8, [rsp]                     ; original app_id (stashed above)
    push rax
    call cap_audit_log
    pop rax
    add rsp, 8                         ; discard stashed app_id
    ; Persist the narrowed mask together with a fresh authenticator so the
    ; dispatcher's HMAC check accepts it. cap_mask_store(rdi=slot, rsi=mask).
    movzx edi, r15b
    movzx esi, al
    call cap_mask_store
    movzx eax, sil                    ; resulting effective mask
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
    mov rdi, [rsp + ALL_RDI]                ; reload ptr (cstring scan clobbered it)
    mov rsi, APP_OPEN_CMD_MAX
    call sc_validate_path_canonical         ; reject .., abs/drive escapes, ctrl bytes
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
%ifdef ENABLE_DEBUG_SERIAL
    ; Validator post-condition recheck (§2, debug build only). If this slot was
    ; armed at dispatch (a fully validated syscall ran), re-read the 6 saved arg
    ; qwords from the still-present PUSH_ALL frame and compare them against the
    ; snapshot taken at validation entry. A handler that mutated its own saved
    ; arg frame mid-syscall (TOCTOU against a value the validator approved) is a
    ; kernel-integrity violation, so route it to the CANARY panic path. Runs
    ; before POP_ALL so [rsp + ALL_*] is the saved frame. rax/rcx/rdx are dead
    ; here (POP_ALL reloads them from the frame), so clobbering them is safe.
    lea rcx, [rel sc_postcond_valid]
    movzx eax, r15b
    cmp byte [rcx + rax], 0
    je .sc_postcond_skip
    mov byte [rcx + rax], 0             ; consume the snapshot
    movzx eax, r15b
    imul eax, eax, 48
    lea rcx, [rel sc_postcond_args]
    add rcx, rax
    mov rax, [rsp + ALL_RDI]
    cmp rax, [rcx + 0]
    jne .sc_postcond_fail
    mov rax, [rsp + ALL_RSI]
    cmp rax, [rcx + 8]
    jne .sc_postcond_fail
    mov rax, [rsp + ALL_RDX]
    cmp rax, [rcx + 16]
    jne .sc_postcond_fail
    mov rax, [rsp + ALL_R10]
    cmp rax, [rcx + 24]
    jne .sc_postcond_fail
    mov rax, [rsp + ALL_R8]
    cmp rax, [rcx + 32]
    jne .sc_postcond_fail
    mov rax, [rsp + ALL_R9]
    cmp rax, [rcx + 40]
    jne .sc_postcond_fail
    jmp .sc_postcond_skip
.sc_postcond_fail:
    mov rdi, rax                        ; observed (mutated) saved arg value
    lea rsi, [rel .sc_postcond_fail]
    jmp kernel_panic_canary
.sc_postcond_skip:
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
    ; FS/GS sanitization on the SYSRET exit (security_todo.md §3). SYSRETQ does
    ; NOT reload DS/ES/FS/GS, so the kernel GDT64_DATA_SEG selector loaded at
    ; entry would otherwise stay visible to ring 3. Load the ring-3
    ; GDT64_USER_DATA selector into all four before returning. The macro
    ; clobbers ax, which here is the low half of the rax syscall-return value,
    ; so bracket it with a save/restore — rax (return) and rdx (slot id, still
    ; needed for the runtime-ptr math below) are the only contract regs live,
    ; and rdx is untouched by the selector loads. (Under the optional MSR-scrub
    ; the macro also clobbers rcx/rdx, so save rdx too — rdx is reloaded into
    ; the runtime-ptr math right after.) Done before rcx/r11/rsp are loaded.
    push rax
    push rdx
    SANITIZE_SEG_USER_EXIT
    pop rdx
    pop rax
    imul rdx, L3_RT_SIZE
    lea rcx, [rel l3_runtime]
    add rdx, rcx
    mov rsp, [rdx + L3_RT_USER_RSP]
    mov rcx, [rdx + L3_RT_USER_RIP]
    mov r11, [rdx + L3_RT_USER_RFLAGS]
    ; Encode SYSRETQ directly to avoid NASM's spurious label-orphan warning.
    db 0x48, 0x0F, 0x07

; Diagnostic: log every SYS_WM_CREATE with calling slot (r15) and drawfn (r9).
; Self-contained, preserves all registers. Prints "[WCREATE] slot=.. dfn=..".
dbg_wmcreate_log:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    push r9
    push r10
    push r11
    push r15
    mov r10, r15                              ; save slot before clobber
    mov r11, r9                               ; save drawfn before clobber
    lea rdi, [rel dbg_wc_s1]
    call serial_puts
    mov rsi, r10
    call dbg_wc_hex64
    lea rdi, [rel dbg_wc_s2]
    call serial_puts
    mov rsi, r11
    call dbg_wc_hex64
    call serial_crlf
    pop r15
    pop r11
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; rsi=value -> 16 hex digits via serial_putc. Clobbers rax,rcx,rdx (saved here).
dbg_wc_hex64:
    push rax
    push rcx
    push rdx
    push rbx
    mov rcx, 16
.dwc_loop:
    rol rsi, 4
    mov rax, rsi
    and rax, 0x0F
    cmp rax, 10
    jb .dwc_dec
    add rax, 'a' - 10
    jmp .dwc_emit
.dwc_dec:
    add rax, '0'
.dwc_emit:
    mov dil, al
    push rsi
    push rcx
    mov al, dil
    movzx edi, al
    call serial_putc
    pop rcx
    pop rsi
    dec rcx
    jnz .dwc_loop
    pop rbx
    pop rdx
    pop rcx
    pop rax
    ret

section .data
dbg_wc_s1: db "[WCREATE] slot=", 0
dbg_wc_s2: db " dfn=", 0
section .text

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
    jnz .check_ptr_has_desc
    ; Nibble 0 = this PTR arg was never migrated to a sibling-length
    ; descriptor. STRICT rows (security_todo.md §2, "Mandatory non-zero
    ; arg_desc for every PTR arg") deny-on-unmigrated instead of falling back
    ; to the 1-byte probe — eliminates the "handler forgot the range check"
    ; class for opted-in rows. Non-STRICT rows keep the legacy 1-byte probe.
    test byte [r12 + SYSCALL_FLAGS_OFF], SC_FLAG_STRICT
    jnz .validate_fail
    jmp .check_ptr_do
.check_ptr_has_desc:
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
    ; Constant-time arg select (Spectre-v1): no data-dependent branch on the
    ; index. Clamp index>5 to 5 (ALL_R9, the old default) with cmova, then read
    ; the frame offset from a fixed table and load the saved register.
    mov eax, 5
    cmp r8d, 5
    cmova r8d, eax                      ; clamp any index > 5 to 5 (branchless)
    lea rax, [rel sc_arg_off_table]
    mov eax, [rax + r8*4]               ; eax = ALL_* frame offset for this index
    add eax, SC_VALIDATE_FRAME_OFF      ; eax = full displacement from rsp
    mov rdi, [rsp + rax]                ; load the selected saved register
    KEPILOGUE

align 4
sc_arg_off_table:
    dd ALL_RDI, ALL_RSI, ALL_RDX, ALL_R10, ALL_R8, ALL_R9

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
;
; The optional 6th argument is the per-entry flags byte (offset 14) — see
; SYSCALL_FLAGS_OFF above. SC_FLAG_STRICT makes the validator deny any PTR
; arg whose arg_desc nibble is still 0/unmigrated rather than 1-byte-probing.
%macro SYSCALL_ENTRY 3-6 CAP_ALL, 0, 0
    dq %1
    db %2
    dd %3
    db %4
    db %6         ; flags at offset 14 (SYSCALL_FLAGS_OFF)
    db 0          ; pad byte 15
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
    SYSCALL_ENTRY syscall_entry.sc_fs_read,          3, SC_KIND3(FN_KIND_HANDLE, FN_KIND_PTR, FN_KIND_SCALAR), CAP_FS, SC_DESC_LEN(1, 3), SC_FLAG_STRICT
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
    SYSCALL_ENTRY syscall_entry.sc_xml_parse,        2, SC_KIND2(FN_KIND_PTR, FN_KIND_SCALAR), CAP_GUI, SC_DESC_LEN(0, 2), SC_FLAG_STRICT
    SYSCALL_ENTRY syscall_entry.sc_xml_root,         0, 0,                          CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_xml_tag,          1, SC_KIND1(FN_KIND_SCALAR),   CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_xml_tag_name,     3, SC_KIND3(FN_KIND_SCALAR, FN_KIND_PTR, FN_KIND_SCALAR), CAP_GUI, SC_DESC_LEN(1, 3), SC_FLAG_STRICT
    SYSCALL_ENTRY syscall_entry.sc_xml_first_child,  1, SC_KIND1(FN_KIND_SCALAR),   CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_xml_next_sibling, 1, SC_KIND1(FN_KIND_SCALAR),   CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_xml_parent,       1, SC_KIND1(FN_KIND_SCALAR),   CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_xml_attr,         5, SC_KIND5(FN_KIND_SCALAR, FN_KIND_PTR, FN_KIND_SCALAR, FN_KIND_PTR, FN_KIND_SCALAR), CAP_GUI, (SC_DESC_LEN(1, 3) | SC_DESC_LEN(3, 5)), SC_FLAG_STRICT
    SYSCALL_ENTRY syscall_entry.sc_xml_text,         3, SC_KIND3(FN_KIND_SCALAR, FN_KIND_PTR, FN_KIND_SCALAR), CAP_GUI, SC_DESC_LEN(1, 3), SC_FLAG_STRICT
    SYSCALL_ENTRY syscall_entry.sc_xml_free,         0, 0,                          CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_draw_line,        5, SC_KIND5(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR), CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_fill_circle,      4, SC_KIND4(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR), CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_fill_triangle,    2, SC_KIND2(FN_KIND_PTR, FN_KIND_SCALAR), CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_xml_last_error,   0, 0,                          CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_xml_node_count,   0, 0,                          CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_blend_pixel,      3, SC_KIND3(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR), CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_blend_span,       4, SC_KIND4(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR), CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_xml_text_runs,    1, SC_KIND1(FN_KIND_SCALAR),   CAP_GUI
    SYSCALL_ENTRY syscall_entry.sc_xml_text_run,     4, SC_KIND4(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_PTR, FN_KIND_SCALAR), CAP_GUI, SC_DESC_LEN(2, 4), SC_FLAG_STRICT
    SYSCALL_ENTRY syscall_entry.sc_xml_namespace,    5, SC_KIND5(FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_SCALAR, FN_KIND_PTR, FN_KIND_SCALAR), CAP_GUI, SC_DESC_LEN(3, 5), SC_FLAG_STRICT
    SYSCALL_ENTRY syscall_entry.sc_xml_node_namespace, 3, SC_KIND3(FN_KIND_SCALAR, FN_KIND_PTR, FN_KIND_SCALAR), CAP_GUI, SC_DESC_LEN(1, 3), SC_FLAG_STRICT
    SYSCALL_ENTRY syscall_entry.sc_xml_entity_value, 4, SC_KIND4(FN_KIND_PTR, FN_KIND_SCALAR, FN_KIND_PTR, FN_KIND_SCALAR), CAP_GUI, (SC_DESC_LEN(0, 2) | SC_DESC_LEN(2, 4)), SC_FLAG_STRICT
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
    ; Fold the quantum entropy blob (IBM ibm_marrakesh, job d8cved7d0j8c73f3fjq0)
    ; into the canary: XOR-compress all qrng_seed_len bytes so the canary depends
    ; on every byte of certified-irreproducible randomness. Critically this makes
    ; the RDRAND-absent fallback (QEMU TCG / old CPUs) unguessable instead of
    ; RDTSC-only. Provenance: tools/quantum/qrng_manifest.txt.
    push rsi
    push rcx
    lea rsi, [rel qrng_seed_blob]
    mov ecx, qrng_seed_len / 8
.kc_qrng_fold:
    xor rbx, [rsi]
    add rsi, 8
    rol rbx, 17                       ; cheap avalanche: every byte touches every bit
    dec ecx
    jnz .kc_qrng_fold
    pop rcx
    pop rsi
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
    ; tag = low16(kernel_canary ^ &window ^ field_offset) — KDOM_CPI is 0 so
    ; this is byte-identical to the former hand-written sequence (see §13).
    KHMAC_TAG rcx, ecx, cx, rsi, rdx, KDOM_CPI
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
    KHMAC_TAG rcx, ecx, cx, rsi, rdx, KDOM_CPI
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
; Cap-mask authenticator — the data-side counterpart to CPI-lite. The same
; kernel_canary key authenticates each slot's capability mask so a stray
; kernel write that widens slot_cap_mask[slot] is caught at the next dispatch
; instead of silently granting privileges. Tag = low8(kernel_canary ^ slot ^
; mask ^ KDOM_CAP_MASK); 8 bits is all the room a 1-byte mask alongside a
; 1-byte authenticator affords, but it still forces an attacker to leak the
; canary before they can forge a matching pair. The dispatcher verifies inline
; (hot path); these helpers are the single source of truth for the write side.
; ----------------------------------------------------------------------------

; cap_mask_sign(rdi=slot, rsi=mask) -> rax = authenticator byte (0..255).
; Pure function of the inputs and kernel_canary; clobbers only rax (rcx saved).
global cap_mask_sign
FN_BEGIN cap_mask_sign, 2, SC_KIND2(FN_KIND_SCALAR, FN_KIND_SCALAR), FN_RET_SCALAR
    push rcx
    push r8
    movzx eax, dil                    ; slot id (low byte)
    movzx r8d, sil                    ; mask byte
    ; tag = low8(kernel_canary ^ slot ^ mask ^ KDOM_CAP_MASK). KDOM_CAP_MASK is
    ; the former CAP_HMAC_DOMAIN (0x5C) so the byte is unchanged (see §13).
    KHMAC_TAG rcx, ecx, cl, rax, r8, KDOM_CAP_MASK
    mov eax, ecx                      ; authenticator byte -> result reg
    pop r8
    pop rcx
    FN_END cap_mask_sign
    ret

; cap_mask_store(rdi=slot, rsi=mask): write slot_cap_mask[slot]=mask AND its
; authenticator slot_cap_hmac[slot] together, so the pair is always consistent.
; The single place mask writes should go through. Clobbers rax, rcx, r8.
; Caller must have already range-checked slot < MAX_WINDOWS.
global cap_mask_store
FN_BEGIN cap_mask_store, 2, SC_KIND2(FN_KIND_SCALAR, FN_KIND_SCALAR), FN_RET_VOID
    call cap_mask_sign                ; rax = authenticator for (slot, mask)
    movzx r8d, dil                    ; slot index
    lea rcx, [rel slot_cap_mask]
    mov [rcx + r8], sil               ; mask byte
    lea rcx, [rel slot_cap_hmac]
    mov [rcx + r8], al                ; matching authenticator
    FN_END cap_mask_store
    ret

; ----------------------------------------------------------------------------
; cap_audit_log(dil=slot, sil=old_mask, dl=new_mask, cl=reason, r8d=app_id)
;
; Append one capability-transition record to the kernel-only audit ring
; (security_todo.md §4, "Capability transitions logged + auditable"). Called
; from every legitimate cap-mask write site (declare_manifest narrowing,
; kernel_apply_app_manifest, slot recycle) so a failure to narrow — or any
; unexpected widening — leaves a forensic trail instead of being silent.
;
; The ring is fixed-size (CAP_AUDIT_ENTRIES records of CAP_AUDIT_ENT_SIZE
; bytes); cap_audit_head is the running event count and (head & IDX_MASK) is
; the next write slot, so the ring overwrites oldest-first. Kernel-only: no
; ring-3 reader yet. Self-contained — preserves every register a caller could
; rely on so it can be dropped into any write site without clobber surprises.
FN_BEGIN cap_audit_log, 5, 0, FN_RET_VOID
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    push r9
    ; rbx = byte offset of this record = (head & IDX_MASK) * CAP_AUDIT_ENT_SIZE
    mov eax, [rel cap_audit_head]
    mov r9d, eax                      ; r9d = seq for this record
    and eax, CAP_AUDIT_IDX_MASK
    imul ebx, eax, CAP_AUDIT_ENT_SIZE
    lea r9, [rel cap_audit_ring]
    add rbx, r9                       ; rbx -> record base
    ; reload the (clobbered) seq for the +0 field
    mov eax, [rel cap_audit_head]
    mov [rbx + 0], eax                ; +0 seq
    mov [rbx + 4], dil                ; +4 slot
    mov [rbx + 5], sil                ; +5 old_mask
    mov [rbx + 6], dl                 ; +6 new_mask
    mov [rbx + 7], cl                 ; +7 reason
    mov [rbx + 8], r8d                ; +8 app_id
    mov dword [rbx + 12], 0           ; +12 reserved
    inc dword [rel cap_audit_head]    ; advance event counter (wraps at 2^32)
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    FN_END cap_audit_log
    ret

; slot_cap_hmac_init(): stamp every slot's authenticator to match the current
; (static CAP_ALL) mask, using the now-final kernel_canary. Called once from
; kernel_main right after kernel_canary_init, before any syscall can dispatch.
; Clobbers rax, rcx, rdx, rsi, rdi, r8.
global slot_cap_hmac_init
FN_BEGIN slot_cap_hmac_init, 0, 0, FN_RET_VOID
    xor edx, edx                      ; slot index
.schi_loop:
    cmp edx, MAX_WINDOWS
    jae .schi_done
    lea rcx, [rel slot_cap_mask]
    movzx esi, byte [rcx + rdx]       ; current mask for this slot
    mov rdi, rdx                      ; slot id
    push rdx
    call cap_mask_sign                ; rax = authenticator (saves/restores rcx)
    pop rdx
    lea rcx, [rel slot_cap_hmac]
    mov [rcx + rdx], al
    inc edx
    jmp .schi_loop
.schi_done:
    FN_END slot_cap_hmac_init
    ret

; ----------------------------------------------------------------------------
; sc_record_strike - slot teardown on suspect syscall return (security_todo.md
; §12). Called from each dispatcher security-reject label (.sc_cap_reject,
; .sc_validate_reject, .sc_rate_reject) when a syscall is denied for a security
; reason. Increments this slot's strike counter; once it reaches
; SC_STRIKE_LIMIT the slot is auto-killed (the existing window/slot teardown
; path) and a CAP_AUDIT_STRIKE record is appended to the cap-transition audit
; ring, so repeated probing/fuzzing is no longer silent and cost-free.
;
; In:  r15 = current slot id (set by syscall_entry before dispatch).
; Out: nothing. The caller still sets rax=-1 and falls through to .done; if the
;      slot was killed, .done's W^X scrub + SYSRET land back in (now-recycled)
;      slot state, which is exactly the close-window outcome.
; Clobbers rax, rcx, rdx, rsi, rdi, r8 (all dead at the reject labels — they
; reload from the saved frame or set constants afterward). r15 preserved.
; ----------------------------------------------------------------------------
sc_record_strike:
    movzx ecx, r15b
    cmp ecx, MAX_WINDOWS
    jae .srs_ret                        ; defensive: never index past the array
    lea rdx, [rel slot_sc_strikes]
    movzx eax, word [rdx + rcx*2]
    inc eax
    mov [rdx + rcx*2], ax
    cmp eax, SC_STRIKE_LIMIT
    jb .srs_ret
    ; Strike limit reached. Reset the counter first so a recycled slot starts
    ; clean, then audit and tear the slot down.
    mov word [rdx + rcx*2], 0
    ; Audit the kill: old_mask = this slot's current cap mask, new_mask = 0
    ; (caps gone), reason = CAP_AUDIT_STRIKE, app_id = 0. cap_audit_log
    ; preserves every register.
    movzx edi, r15b                     ; dil = slot
    lea rcx, [rel slot_cap_mask]
    movzx eax, r15b
    mov sil, [rcx + rax]                ; sil = old_mask
    xor edx, edx                        ; dl  = new_mask = 0
    mov cl, CAP_AUDIT_STRIKE            ; cl  = reason
    xor r8d, r8d                        ; r8d = app_id = 0
    call cap_audit_log
    ; Kill the slot via the existing teardown path. For app slots the window id
    ; equals the slot id (enforced by .sc_wm_close / .sc_wm_close ownership
    ; checks), so closing window r15 reclaims this slot. wm_close_window range-
    ; checks its argument and is a no-op for an already-closed window.
    movzx edi, r15b
    call wm_close_window
.srs_ret:
    ret

; ----------------------------------------------------------------------------
; sc_anomaly_scan_all - behavioral anomaly detector on the dispatcher
; (security_todo.md §11, "Anomaly detector on the dispatcher"). Pure-software
; behavioral sandbox: it never touches the hot dispatch path. pit_handler calls
; it once every ANOMALY_SCAN_PERIOD ticks (the same coarse-cadence pattern as
; l3_code_hash_verify_all), so the per-syscall cost of the §11 machinery stays
; in the cheap inline SC_TRACE_APPEND only.
;
; It consumes the per-slot syscall histogram (sc_trace_hist[], the data source
; built by the trace ring) — NOT the ring records — so the scan is just a few
; counter reads per slot. For every LIVE slot it sums that slot's accumulated
; count over the high-risk syscall set (the CAP_WX W^X/JIT trio + SYS_FS_DELETE)
; and compares it against a per-slot budget chosen by whether the slot's manifest
; actually grants the matching capability:
;   * slot lacks the cap  -> expected rate is ZERO, so budget = ANOMALY_HIRISK_
;     DENY_BUDGET (tiny). Because SC_TRACE_APPEND bumps the histogram at dispatch
;     entry *before* the cap gate, a sandboxed Notepad slot probing SYS_WX_JIT_
;     ALIAS is counted even though every call is cap-rejected — this is the
;     "Notepad slot suddenly hammering SYS_WX_JIT_ALIAS" signal from the doc.
;   * slot holds the cap  -> budget = ANOMALY_HIRISK_HOLD_BUDGET (a real JIT app
;     may legitimately use the surface, but a flood far above sane warm-up is
;     still throttled).
; A slot over budget is driven through the EXISTING §12 strike path
; (sc_record_strike) — so excessive high-risk behaviour throttles toward the
; same SC_STRIKE_LIMIT slot-kill, with no new teardown path invented. A
; CAP_AUDIT_ANOMALY record is appended at the flagging moment so the forensic
; trail shows what tripped it, then the slot's high-risk histogram buckets are
; reset so each scan window is judged on fresh behaviour (and a slow legitimate
; app never accretes a false positive across many windows).
;
; In:  none.  Out: none.  r15 must equal the scanned slot id for the duration of
; each sc_record_strike call (it keys off r15); we set it per slot and restore
; the caller's r15 at the end. Preserves all caller regs (called from the ISR
; landing pad). Internal helper — plain label, no FN_BEGIN (matches
; sc_build_allow_bitmap). Exported so pit.asm can drive it (FN_BEGIN, which
; emits the global, matching cap_audit_log — the coverage tool requires every
; global to carry a signature).
; ----------------------------------------------------------------------------
FN_BEGIN sc_anomaly_scan_all, 0, 0, FN_RET_VOID
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    push r9
    push r10
    push r11
    push r15                             ; preserve caller's slot id
    xor r10d, r10d                       ; r10d = slot index
.asa_slot:
    cmp r10d, MAX_WINDOWS
    jae .asa_done
    ; Only scan live slots — a recycled/empty slot has no tenant to judge and
    ; its histogram is stale until the next tenant repopulates it.
    lea rax, [rel l3_slot_live]
    cmp qword [rax + r10*8], 0
    je .asa_next
    ; r11 = this slot's histogram base = sc_trace_hist + slot*SC_TRACE_HIST_SLOTS*2
    imul eax, r10d, SC_TRACE_HIST_SLOTS * 2
    lea r11, [rel sc_trace_hist]
    add r11, rax
    ; Sum the high-risk buckets. SC_HIRISK_TABLE is a NUL(0xFFFF)-terminated
    ; list of syscall numbers; r9d accumulates the total (u16s, can't overflow
    ; a dword across the short list).
    xor r9d, r9d
    lea rbx, [rel sc_hirisk_table]
.asa_sum:
    movzx ecx, word [rbx]
    cmp ecx, SC_TRACE_REC_INVALID        ; 0xFFFF terminator
    je .asa_sum_done
    movzx eax, word [r11 + rcx*2]        ; this slot's count for that syscall
    add r9d, eax
    add rbx, 2
    jmp .asa_sum
.asa_sum_done:
    ; Pick the budget by whether this slot's (authenticated) cap mask grants
    ; CAP_WX. Reading slot_cap_mask raw is fine here: a tampered mask is caught
    ; by the dispatcher's HMAC gate on the next syscall; the worst this scan can
    ; do with a forged-wide mask is apply the more generous HOLD budget, which
    ; only delays — never suppresses — a strike, and the dispatcher would panic
    ; on that mask anyway.
    lea rax, [rel slot_cap_mask]
    movzx eax, byte [rax + r10]
    test al, CAP_WX
    jnz .asa_hold_budget
    mov edx, ANOMALY_HIRISK_DENY_BUDGET
    jmp .asa_have_budget
.asa_hold_budget:
    mov edx, ANOMALY_HIRISK_HOLD_BUDGET
.asa_have_budget:
    cmp r9d, edx
    jbe .asa_reset_window                ; within profile — just roll the window
    ; --- Anomaly: this slot's high-risk mix is over budget for its class. -----
    ; Audit the flag (old_mask = current cap mask, new_mask = the over-budget
    ; count truncated to a byte for the record, reason = CAP_AUDIT_ANOMALY).
    ; cap_audit_log preserves all caller regs.
    lea rax, [rel slot_cap_mask]
    movzx esi, byte [rax + r10]          ; sil = old_mask (current caps)
    movzx edi, r10b                      ; dil = slot
    mov edx, r9d                         ; dl  = observed high-risk count (low8)
    mov ecx, CAP_AUDIT_ANOMALY           ; cl  = reason
    xor r8d, r8d                         ; r8d = app_id (unknown at scan time)
    call cap_audit_log
    ; Drive the slot through the existing §12 strike path. sc_record_strike
    ; keys off r15, so point r15 at the flagged slot for the call. It increments
    ; the strike counter and, at SC_STRIKE_LIMIT, kills the slot via the same
    ; wm_close_window teardown the §12 path uses. r10 (loop index) survives the
    ; call (sc_record_strike clobbers rax/rcx/rdx/rsi/rdi/r8 only).
    movzx r15d, r10b
    call sc_record_strike
.asa_reset_window:
    ; Reset this slot's high-risk buckets so each scan window judges fresh
    ; behaviour. Non-high-risk buckets are left to keep accreting (cheap, and
    ; the detector only reads the high-risk ones). r11 still = histogram base.
    lea rbx, [rel sc_hirisk_table]
.asa_reset:
    movzx ecx, word [rbx]
    cmp ecx, SC_TRACE_REC_INVALID
    je .asa_next
    mov word [r11 + rcx*2], 0
    add rbx, 2
    jmp .asa_reset
.asa_next:
    inc r10d
    jmp .asa_slot
.asa_done:
    pop r15
    pop r11
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    FN_END sc_anomaly_scan_all
    ret

; ----------------------------------------------------------------------------
; sc_trace_dump(rdi = slot) - ship a slot's per-syscall trace ring on serial
; (security_todo.md §11, "Crashes ship the last N syscalls"). Called from the
; syscall-path panic handlers with the faulting slot in rdi. Walks the slot's
; ring oldest-first and prints one line per record: "Tn <seq> <sysno> <arg0>
; <rip>". Best-effort forensic aid; preserves all caller regs (the panic banner
; reads its own rdi/rsi afterward).
; ----------------------------------------------------------------------------
sc_trace_dump:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    push r9
    movzx ecx, dil
    cmp ecx, MAX_WINDOWS
    jae .std_done                        ; bad slot id — nothing to dump
    SER 'T'
    SER 'R'
    SER 'C'
    SER ' '
    mov edi, ecx
    add edi, '0'
    cmp edi, '9'
    jbe .std_slot_digit
    add edi, ('A' - '9' - 1)             ; slots >9 print as A.. (MAX_WINDOWS small)
.std_slot_digit:
    mov dx, 0x3F8
    mov eax, edi
    out dx, al
    call serial_crlf
    ; r8 = ring base for this slot; ebx = head event counter (low16).
    imul eax, ecx, SC_TRACE_SLOT_BYTES
    lea r8, [rel sc_trace_ring]
    add r8, rax
    lea rax, [rel sc_trace_head]
    movzx ebx, word [rax + rcx*2]
    ; Walk the SC_TRACE_RING_ENTRIES records in chronological order. If the ring
    ; has wrapped (head >= ENTRIES) the oldest live record is (head - ENTRIES);
    ; otherwise records [0, head) are valid. Either way iterate index =
    ; (head - ENTRIES .. head-1) & IDX_MASK, skipping not-yet-written slots.
    mov r9d, SC_TRACE_RING_ENTRIES       ; remaining to consider
    mov ecx, ebx
    sub ecx, SC_TRACE_RING_ENTRIES       ; oldest candidate seq
.std_rec:
    test r9d, r9d
    jz .std_done
    cmp ebx, SC_TRACE_RING_ENTRIES
    jae .std_rec_live                    ; full ring: every slot is live
    cmp ecx, 0
    jl .std_rec_skip                     ; not-yet-written (seq < 0): skip
.std_rec_live:
    mov edx, ecx
    and edx, SC_TRACE_IDX_MASK
    imul edx, edx, SC_TRACE_ENT_SIZE
    push r8
    add r8, rdx                          ; r8 -> record
    movzx edi, word [r8 + 2]             ; sysno
    push rcx
    push r8
    mov dx, 0x3F8
    mov al, ' '
    out dx, al
    pop r8
    mov rdi, [r8 + 8]                    ; user_rip — the most useful field
    call ser_print_hex64
    pop rcx
    pop r8
    call serial_crlf
.std_rec_skip:
    inc ecx
    dec r9d
    jmp .std_rec
.std_done:
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; High-risk syscall set the §11 anomaly detector watches. NUL-terminated with
; SC_TRACE_REC_INVALID (0xFFFF). The CAP_WX W^X/JIT-alias trio (install_manifest
; / mprotect_wx / jit_alias) are the classic code-injection surface; SYS_FS_DELETE
; rounds out a destructive op a doc-style "Notepad" should essentially never
; touch in bulk. Numbers must track the syscall_table order (see SC_SYS_FS_DELETE
; in syscall_caps.inc and the SYS_WX_* macros in syscall_user.inc).
align 2
sc_hirisk_table:
    dw 67                                ; SYS_WX_INSTALL_MANIFEST
    dw 68                                ; SYS_MPROTECT_WX
    dw 69                                ; SYS_WX_JIT_ALIAS
    dw SC_SYS_FS_DELETE                  ; SYS_FS_DELETE (=19)
    dw SC_TRACE_REC_INVALID              ; terminator

; ----------------------------------------------------------------------------
; kernel_panic_canary - reached only from the syscall exit paths when the
; saved canary slot does not match kernel_canary. rdi = observed bad value,
; rsi = approximate kernel RIP at detection. Serial-logs and halts; never
; returns.
; ----------------------------------------------------------------------------
global kernel_panic_canary
kernel_panic_canary:
    cli
    ; §11: a kernel-integrity panic on the syscall path means *this* slot's last
    ; few syscalls are the prime forensic evidence. Ship them on serial before
    ; halting (r15 still holds the faulting slot id here). Save rdi/rsi — the
    ; dumper preserves them but the explicit push documents the contract that
    ; the panic banner below still reads the original args.
    push rdi
    push rsi
    movzx edi, r15b
    call sc_trace_dump
    pop rsi
    pop rdi
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

; Per-slot effective capability mask. Default-deny (security_todo.md §4): every
; slot boots at CAP_CORE only (print/exit/ticks/sysinfo/handles), NOT CAP_ALL —
; so a slot that runs a syscall before its manifest is applied can only touch
; the core surface, killing the old CAP_ALL race window. Each launch path
; re-stamps the slot's real, possibly-wider manifest via
; kernel_apply_app_manifest (APPLY_MANIFEST in launch.inc) right after
; wm_create_window_ex, so every legit app still gets the caps it declares.
; SYS_APP_DECLARE_MANIFEST narrows entries with AND; nothing widens them past
; the manifest. The dispatcher reads slot_cap_mask[r15] on every syscall.
;
; NOTE: because CAP_CORE is the floor, every launched app MUST have an
; APPLY_MANIFEST (kernel_apply_app_manifest) on its launch path or it will be
; restricted to CAP_CORE. All current launch paths in launch.inc do; a new
; launch path must add one or the app will lose GUI/FS/etc. access.
align 8
slot_cap_mask: times MAX_WINDOWS db CAP_CORE

; Per-slot authenticator paralleling slot_cap_mask[] (security_todo.md §4,
; "Time-of-check capability cache"). Each byte is
;   low8(kernel_canary ^ slot ^ mask ^ KDOM_CAP_MASK)
; recomputed by cap_mask_sign whenever the mask is legitimately written, and
; verified inline by the dispatcher's cap gate before the mask is trusted. The
; static CAP_ALL masks above can't have their HMAC assembled in (the canary key
; is runtime-only), so slot_cap_hmac_init seeds every entry at boot once
; kernel_canary holds its final value. The zeros here are just the pre-init
; placeholder; the dispatcher never runs before slot_cap_hmac_init.
align 8
slot_cap_hmac: times MAX_WINDOWS db 0

; Capability-transition audit ring (security_todo.md §4). Fixed-size,
; kernel-only forensic trail of every cap-mask write. cap_audit_head is the
; running event count; (head & CAP_AUDIT_IDX_MASK) is the next record index, so
; the ring overwrites oldest-first once it fills. See cap_audit_log (the single
; append point) and CAP_AUDIT_* layout/reason codes in syscall_caps.inc. No
; ring-3 read syscall yet — inspected from the kernel/debugger only.
align 8
cap_audit_head: dd 0                         ; monotonic event counter
align 16
cap_audit_ring: times (CAP_AUDIT_ENTRIES * CAP_AUDIT_ENT_SIZE) db 0

; Per-slot syscall rate-limiting token bucket (security_todo.md §2).
; One word budget per slot, decremented at dispatch entry and refilled to
; SC_BUDGET_PER_TICK by pit_handler on every timer tick. A slot that drains
; its budget within a single tick has further syscalls denied (-1) until the
; next refill. This caps the syscall rate to SC_BUDGET_PER_TICK * PIT rate,
; which is far below the millions-of-calls a fuzzer or side-channel oracle
; needs while leaving plenty of headroom for legitimate GUI apps.
; SC_BUDGET_PER_TICK lives in constants.inc so pit_handler shares the value.
; Exported so pit.asm's refill loop can reach it.
global slot_sc_budget
align 16
slot_sc_budget: times MAX_WINDOWS dw SC_BUDGET_PER_TICK

; Per-slot security-reject strike counter (security_todo.md §12, "Slot teardown
; on suspect syscall return"). One word per slot, incremented by sc_record_strike
; on every -1 return for a security reason (cap mismatch, validator reject, rate
; reject). When a slot reaches SC_STRIKE_LIMIT (constants.inc) the dispatcher
; auto-kills it (wm_close_window) and appends a CAP_AUDIT_STRIKE record to the
; cap audit ring, then resets the counter so a recycled slot starts clean.
; Turns previously-silent, cost-free rejections into a self-terminating probe.
align 16
slot_sc_strikes: times MAX_WINDOWS dw 0

; Per-slot syscall allowlist bitmap (security_todo.md §2, "Manifest declares
; syscall set, not just cap bits"). One bit per syscall number, SC_ALLOW_BYTES
; bytes per slot; bit i set == slot may invoke syscall i. The dispatcher tests
; this bit right after the coarse cap gate, so an app is confined to the exact
; syscall set its manifest implies — finer than the CAP_* mask alone (Notepad
; keeps CAP_FS but is denied SYS_FS_DELETE).
;
; Default is every bit set (0xFF fill): legacy/undeclared slots are
; unrestricted at the bitmap layer, exactly as before this gate existed, so the
; cap mask stays the only constraint until a manifest is applied.
; sc_build_allow_bitmap rewrites a slot's bitmap from {cap mask, app deny list}
; at every cap-mask transition (declare_manifest, kernel_apply_app_manifest,
; recycle). syscall_table_count is the assembly-time equ resolved at the table.
SC_ALLOW_BYTES equ ((syscall_table_count + 7) / 8)
align 16
slot_syscall_allow: times (MAX_WINDOWS * SC_ALLOW_BYTES) db 0xFF

; --- Always-on per-syscall trace ring + per-slot histogram (security_todo.md
; §11). Layout/sizing constants and the inline append live in
; syscall_trace.inc. All three arrays are kernel BSS, OUTSIDE the ring-3 slot
; arena, so an app can neither read its own forensic trail nor forge its
; histogram to dodge the anomaly detector.
;
; sc_trace_ring[]  — per slot, the last SC_TRACE_RING_ENTRIES syscall records
;                    (oldest-first). Shipped by sc_trace_dump for crash triage.
; sc_trace_head[]  — per slot, a running u16 event counter; low bits index the
;                    ring. BSS-zero starts each slot's ring empty.
; sc_trace_hist[]  — per slot, SC_TRACE_HIST_SLOTS saturating u16 counters keyed
;                    by syscall number. THE data source for sc_anomaly_scan_all.
align 16
sc_trace_ring:  times (MAX_WINDOWS * SC_TRACE_SLOT_BYTES) db 0
align 16
sc_trace_head:  times MAX_WINDOWS dw 0
align 16
sc_trace_hist:  times (MAX_WINDOWS * SC_TRACE_HIST_SLOTS) dw 0

%ifdef ENABLE_SYSCALL_PERM
; --- Heterogeneous syscall numbering per slot (security_todo.md §12) ---------
; Per-slot INVERSE permutation of the syscall table, in KERNEL BSS OUTSIDE the
; ring-3 arena (parallel to slot_cap_mask[]/slot_syscall_allow[]/l3_slot_key[]),
; so a slot's own memory-write bug can't rewrite its mapping. One byte per
; syscall number per slot:
;   sc_slot_perm_inv[slot*syscall_table_count + app_visible] = real_table_row
; The dispatcher applies this on entry to recover the real row from the number
; the app issued. The matching FORWARD permutation (real_row -> app_visible) is
; what a future loader-side rewrite stamps into the app's SYS_* constants; it is
; built transiently in sc_slot_perm_generate and discarded — only the inverse
; the kernel needs is persisted.
;
; sc_slot_perm_ready[slot] is the generation sentinel: BSS-zero (0) = "not
; generated yet" -> the lazy ensure path treats the slot as IDENTITY until it is
; generated. After generation it is 1. This makes a never-dispatched slot, and
; the whole default (non-ENABLE_SYSCALL_PERM) build, behave exactly as today.
align 16
sc_slot_perm_inv:   times (MAX_WINDOWS * syscall_table_count) db 0
align 16
sc_slot_perm_ready: times MAX_WINDOWS db 0
%endif

%ifdef ENABLE_DEBUG_SERIAL
; Validator post-condition snapshot storage (security_todo.md §2, debug build
; only). For each slot, sc_postcond_args holds the 6 saved arg qwords captured
; right after sc_validate_from_table passes; sc_postcond_valid[slot] is set then
; and cleared/consumed at the return-path recheck. Debug-only — release builds
; allocate none of this and pay nothing (see the ENABLE_DEBUG_SERIAL gates on
; the dispatch/snapshot/recheck sites).
align 8
sc_postcond_args:  times (MAX_WINDOWS * 6) dq 0
align 8
sc_postcond_valid: times MAX_WINDOWS db 0
%endif

section .text
; ----------------------------------------------------------------------------
; sc_build_allow_bitmap(rdi=slot, rsi=cap_mask, rdx=app_id)
;
; Rebuild slot_syscall_allow[slot] from the slot's effective cap mask and the
; per-app explicit deny list (security_todo.md §2, "Manifest declares syscall
; set, not just cap bits"). Two passes:
;   1. For each syscall table row i, set bit i iff the row's CAP tag is fully
;      covered by cap_mask (row.cap & mask == row.cap) — i.e. the cap gate
;      would let this slot reach syscall i. This makes the bitmap the exact
;      cap-implied call set, no hand-authoring.
;   2. Walk the app's deny list (app_syscall_deny_table[app_id - APP_MIN_ID],
;      a run of syscall numbers ended by SC_DENY_LIST_END) and CLEAR each named
;      bit — the finer-than-caps trim. Notepad denies SYS_FS_DELETE here.
; app_id out of [APP_MIN_ID, APP_MAX_ID] skips pass 2 (cap-derived set only).
;
; Internal helper (plain label, not global — so check_coverage.py doesn't
; require FN_BEGIN, matching sc_record_strike). Preserves all caller regs.
; ----------------------------------------------------------------------------
sc_build_allow_bitmap:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    push r9
    push r10
    push r11
    ; r11 = slot's bitmap base = slot_syscall_allow + slot*SC_ALLOW_BYTES
    movzx eax, dil
    imul eax, eax, SC_ALLOW_BYTES
    lea r11, [rel slot_syscall_allow]
    add r11, rax
    mov r10b, sil                       ; r10b = cap_mask (sil dies in pass 2 setup)
    ; Pass 0: clear the slot's bitmap bytes.
    xor ecx, ecx
.sba_zero:
    cmp ecx, SC_ALLOW_BYTES
    jae .sba_zero_done
    mov byte [r11 + rcx], 0
    inc ecx
    jmp .sba_zero
.sba_zero_done:
    ; Pass 1: set bit i for every row whose cap tag is covered by the mask.
    lea rbx, [rel syscall_table]
    xor ecx, ecx                        ; ecx = syscall index i
.sba_set:
    cmp ecx, syscall_table_count
    jae .sba_set_done
    movzx eax, byte [rbx + SYSCALL_CAP_OFF]   ; row.cap
    mov r8b, al
    and r8b, r10b                       ; row.cap & mask
    cmp r8b, al
    jne .sba_set_next                   ; not fully covered -> leave bit clear
    ; set bit ecx: byte = ecx>>3, bit = ecx&7
    mov eax, ecx
    mov r9d, ecx
    shr eax, 3                          ; byte index
    and r9d, 7                          ; bit position
    mov r8b, [r11 + rax]
    bts r8d, r9d
    mov [r11 + rax], r8b
.sba_set_next:
    add rbx, SYSCALL_ENTRY_SIZE
    inc ecx
    jmp .sba_set
.sba_set_done:
    ; Pass 2: apply the per-app explicit deny list. Skip if app_id is out of
    ; range (rdx still holds the original app_id from the caller).
    cmp rdx, APP_MIN_ID
    jb .sba_done
    cmp rdx, APP_MAX_ID
    ja .sba_done
    mov eax, edx
    sub eax, APP_MIN_ID
    lea rbx, [rel app_syscall_deny_table]
    mov rbx, [rbx + rax*8]              ; rbx -> this app's deny list
.sba_deny:
    movzx eax, byte [rbx]
    cmp al, SC_DENY_LIST_END
    je .sba_done
    ; clear bit al: byte = al>>3, bit = al&7
    movzx ecx, al
    mov r9d, ecx
    shr ecx, 3
    and r9d, 7
    mov r8b, [r11 + rcx]
    btr r8d, r9d
    mov [r11 + rcx], r8b
    inc rbx
    jmp .sba_deny
.sba_done:
    pop r11
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; ----------------------------------------------------------------------------
; sc_reset_allow_bitmap(rdi=slot) — set the slot's bitmap back to all-ones
; (unrestricted), the BSS default. Used on slot recycle so a recycled slot
; isn't stuck with the previous tenant's narrowed set before its manifest is
; re-applied. Preserves all caller regs.
; ----------------------------------------------------------------------------
sc_reset_allow_bitmap:
    push rax
    push rcx
    push r11
    movzx eax, dil
    imul eax, eax, SC_ALLOW_BYTES
    lea r11, [rel slot_syscall_allow]
    add r11, rax
    xor ecx, ecx
.sra_loop:
    cmp ecx, SC_ALLOW_BYTES
    jae .sra_done
    mov byte [r11 + rcx], 0xFF
    inc ecx
    jmp .sra_loop
.sra_done:
    pop r11
    pop rcx
    pop rax
    ret

%ifdef ENABLE_SYSCALL_PERM
; ----------------------------------------------------------------------------
; Heterogeneous syscall numbering per slot — generation (security_todo.md §12).
;
; sc_slot_perm_ensure(edi=slot): if this slot's permutation has not been
; generated yet (sentinel sc_slot_perm_ready[slot]==0), generate it once. The
; lazy first-use trigger lives on the dispatch path so the gated build is
; self-contained — it needs no edit to the contended usermode.asm slot-init
; path. THE LOADER HOOK (documented, scoped out) would instead call
; sc_slot_perm_generate from l3_copy_app_blob_to_slot, right after
; l3_derive_slot_key (usermode.asm), and ALSO rewrite the app's SYS_* constants
; with the FORWARD permutation; see the §12 _Done_ note. Preserves all caller
; regs.
;
; sc_slot_perm_generate(edi=slot): build a fresh per-launch random permutation
; for the slot. Forward perm fwd[] (real_row -> app_visible) via Fisher-Yates
; driven by a keyed RNG seeded from the SAME source as the per-slot key work
; (l3_slot_key[slot], itself RDTSC^RDRAND-derived via the boot nonce), mixed
; with kernel_canary and a fresh RDTSC so the layout differs per launch. The
; persisted artifact is the INVERSE: inv[app_visible]=real_row. Preserves all
; caller regs.
;
; Internal plain-label helpers (no FN_BEGIN — matches sc_build_allow_bitmap),
; so check_coverage.py doesn't require coverage and they carry no FN gate.
; ----------------------------------------------------------------------------
extern l3_slot_key

sc_slot_perm_ensure:
    push rax
    movzx eax, dil
    cmp eax, MAX_WINDOWS
    jae .spe_ret
    lea rax, [rel sc_slot_perm_ready]
    movzx ecx, dil
    cmp byte [rax + rcx], 0
    jne .spe_ret_pop_rcx
    push rcx
    call sc_slot_perm_generate          ; edi=slot still live
    pop rcx
.spe_ret_pop_rcx:
    pop rax
    ret
.spe_ret:
    pop rax
    ret

sc_slot_perm_generate:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    push r9
    push r10
    push r11
    movzx r10d, dil                     ; r10 = slot (validated by caller path)
    cmp r10d, MAX_WINDOWS
    jae .spg_done
    ; --- seed the keyed RNG (r11) -----------------------------------------
    ;   seed = l3_slot_key[slot] ^ kernel_canary ^ RDTSC, guarded non-zero.
    mov rax, [rel l3_slot_key + r10*8]
    xor rax, [rel kernel_canary]
    rdtsc
    shl rdx, 32
    or rax, rdx
    test rax, rax
    jnz .spg_seed_ok
    mov rax, 0x9E3779B97F4A7C15         ; non-zero fallback (golden ratio)
.spg_seed_ok:
    mov r11, rax                        ; r11 = SplitMix64 state
    ; --- fwd[] identity init: store it INTO the inverse array's row first,
    ; shuffle in place, then convert to the inverse (in-place) at the end.
    ; r9 = this slot's table base in sc_slot_perm_inv.
    mov eax, r10d
    imul eax, eax, syscall_table_count
    lea r9, [rel sc_slot_perm_inv]
    add r9, rax                          ; r9 -> fwd[]/inv[] row for this slot
    xor ecx, ecx
.spg_id:
    cmp ecx, syscall_table_count
    jae .spg_id_done
    mov byte [r9 + rcx], cl              ; fwd[i] = i   (count <= 256, fits a byte)
    inc ecx
    jmp .spg_id
.spg_id_done:
    ; --- Fisher-Yates over fwd[]: for i = count-1 down to 1, j = rand % (i+1),
    ;     swap fwd[i], fwd[j]. Constant work per element; the only branch is the
    ;     loop bound, not the syscall number, so no per-number timing leak.
    mov ecx, syscall_table_count
    dec ecx                              ; i = count-1
.spg_shuf:
    cmp ecx, 1
    jb .spg_shuf_done
    ; r8 = next random draw (SplitMix64 over r11)
    call .spg_rng                        ; -> rax random qword
    ; j = rax mod (i+1)
    mov r8d, ecx
    inc r8d                              ; i+1
    xor edx, edx
    div r8                               ; rax/r8 -> rdx = remainder = j
    ; swap fwd[i] <-> fwd[j]
    movzx eax, byte [r9 + rcx]           ; fwd[i]
    movzx ebx, byte [r9 + rdx]           ; fwd[j]
    mov [r9 + rcx], bl
    mov [r9 + rdx], al
    dec ecx
    jmp .spg_shuf
.spg_shuf_done:
    ; --- Convert fwd[] (real_row -> app_visible) to inv[] (app_visible ->
    ; real_row), in place, via a temp on the stack. inv[fwd[i]] = i.
    ; syscall_table_count bytes fit easily; reserve a 256-byte scratch.
    sub rsp, 256
    xor ecx, ecx
.spg_inv:
    cmp ecx, syscall_table_count
    jae .spg_inv_done
    movzx eax, byte [r9 + rcx]           ; app_visible = fwd[real_row=ecx]
    mov byte [rsp + rax], cl             ; tmp[app_visible] = real_row
    inc ecx
    jmp .spg_inv
.spg_inv_done:
    ; copy tmp[] back over the row -> now it holds the inverse
    xor ecx, ecx
.spg_copy:
    cmp ecx, syscall_table_count
    jae .spg_copy_done
    movzx eax, byte [rsp + rcx]
    mov [r9 + rcx], al
    inc ecx
    jmp .spg_copy
.spg_copy_done:
    add rsp, 256
    ; mark generated
    lea rax, [rel sc_slot_perm_ready]
    mov byte [rax + r10], 1
.spg_done:
    pop r11
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret
; .spg_rng - SplitMix64 step over state r11; returns next value in rax.
; Clobbers rax/rdx only (rcx=loop i and the rest are preserved by the caller).
.spg_rng:
    push rcx
    mov rax, 0x9E3779B97F4A7C15
    add r11, rax
    mov rax, r11
    mov rcx, rax
    shr rcx, 30
    xor rax, rcx
    mov rdx, 0xBF58476D1CE4E5B9
    imul rax, rdx
    mov rcx, rax
    shr rcx, 27
    xor rax, rcx
    mov rdx, 0x94D049BB133111EB
    imul rax, rdx
    mov rcx, rax
    shr rcx, 31
    xor rax, rcx
    pop rcx
    ret
%endif

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
; Clobbers: rax, rcx, rsi, r8.
FN_BEGIN kernel_apply_app_manifest, 2, SC_KIND2(FN_KIND_SCALAR, FN_KIND_SCALAR), FN_RET_VOID
    cmp rsi, APP_MIN_ID
    jb .kam_done
    cmp rsi, APP_MAX_ID
    ja .kam_done
    cmp edi, MAX_WINDOWS
    jae .kam_done
    push rsi                          ; stash original app_id for the audit record
    sub rsi, APP_MIN_ID
    lea rcx, [rel app_manifest_table]
    movzx esi, byte [rcx + rsi]       ; new mask = manifest(app_id)
    ; Audit this capability transition (security_todo.md §4) before persisting.
    ; cap_audit_log(dil=slot, sil=old, dl=new, cl=reason, r8d=app_id); it
    ; preserves all caller regs, so rdi (slot) and rsi (new mask) survive.
    lea rcx, [rel slot_cap_mask]
    movzx eax, dil
    movzx eax, byte [rcx + rax]       ; old mask before the apply
    push rdi
    push rsi
    movzx edi, dil                    ; slot
    mov edx, esi                      ; new_mask (dl)
    mov esi, eax                      ; old_mask (sil)
    mov ecx, CAP_AUDIT_APPLY
    mov r8, [rsp + 16]                ; original app_id (stashed first)
    call cap_audit_log
    pop rsi
    pop rdi
    add rsp, 8                         ; discard stashed app_id
    ; Write mask + authenticator together so the dispatcher's HMAC check trusts
    ; this (legitimate) narrowing instead of treating it as tampering.
    call cap_mask_store               ; (rdi=slot, rsi=mask)
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

; Per-app syscall deny lists (security_todo.md §2). Each list is a run of
; syscall numbers terminated by SC_DENY_LIST_END (0xFF); sc_build_allow_bitmap
; walks it and CLEARS each named bit after the cap-derived baseline is laid
; down. Apps with nothing to trim share sc_deny_none (just the terminator).
; The canonical trim: Notepad keeps CAP_FS (it reads/writes files) but must
; never DELETE one, so its list denies SYS_FS_DELETE.
sc_deny_none:           db SC_DENY_LIST_END
sc_deny_notepad:        db SC_SYS_FS_DELETE, SC_DENY_LIST_END

; app_id -> deny list pointer. Indexed by (app_id - APP_MIN_ID); parallels
; app_manifest_table row-for-row. Keep the two in sync.
align 8
app_syscall_deny_table:
    dq sc_deny_none                     ; APP_EXPLORER         (2)
    dq sc_deny_none                     ; APP_TERMINAL         (3)
    dq sc_deny_notepad                  ; APP_NOTEPAD          (4)
    dq sc_deny_none                     ; APP_SETTINGS         (5)
    dq sc_deny_none                     ; APP_PAINT            (6)
    dq sc_deny_none                     ; APP_ABOUT            (7)
    dq sc_deny_none                     ; APP_SECURITY_PROBE   (8)
    dq sc_deny_none                     ; APP_TASKMGR          (9)
    dq sc_deny_none                     ; APP_PING            (10)
    dq sc_deny_none                     ; APP_MEDIA           (11)

section .text
