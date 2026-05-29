; ============================================================================
; NexusOS v3.0 - Usermode Transition
; Clean L3 callback path for app draw/click/key handlers.
; ============================================================================
bits 64

%include "constants.inc"
%include "macros.inc"
%include "syscall_user.inc"
%include "l3_runtime.inc"
%include "smap.inc"

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
extern app_l3_done_trampoline
extern handle_table_clear
extern kernel_canary
; Variables moved to the end of file to avoid segment clobbering in monolithic build.

L3_APP_CODE_OFF      equ 512
L3_SHADOW_WIN_OFF    equ (APP_SLOT_SIZE - 512)
L3_APP_BLOB_COPY_CAP equ L3_SHADOW_WIN_OFF
; Ceiling for actual blob *placement* (base + slide + blob_size). Must stay at
; or below the non-present user-stack guard page so a slid blob never overlaps
; the guard page or the user stack/shadow-window tail above it. The slide range
; and the copy-length clamp both use this, NOT L3_APP_BLOB_COPY_CAP — that one
; only marks the shadow-window boundary.
L3_APP_BLOB_PLACE_CAP equ L3_SLOT_USER_STACK_GUARD_OFF
L3_SLOT_META_OFF     equ 0
L3_SLOT_MAGIC_OFF    equ 0
L3_SLOT_TERM_CTX_OFF equ 160
L3_SLOT_USER_STACK_TOP equ (L3_SHADOW_WIN_OFF - 16)
; Per-slot user-stack-top randomization bounds (in-slot offset).
; HIGH = legacy fixed top (just below shadow window, 16B-aligned).
; LOW  = guard-floor invariant: lowest reachable byte (top - L3_USER_STACK_SIZE)
;        must stay >= L3_SLOT_USER_STACK_GUARD_OFF + 0x1000, so the fixed guard
;        PTE at page 0x1FA always sits one page below the live stack. At
;        LOW = 0x1FF000 the lowest byte is exactly 0x1FB000, one page above
;        the guard — do not lower LOW without also moving the guard PTE.
L3_SLOT_USTACK_TOP_HIGH equ L3_SLOT_USER_STACK_TOP
L3_SLOT_USTACK_TOP_LOW  equ (L3_SLOT_USER_STACK_GUARD_OFF + 0x1000 + L3_USER_STACK_SIZE)
L3_SLOT_USTACK_TOP_RANGE equ (L3_SLOT_USTACK_TOP_HIGH - L3_SLOT_USTACK_TOP_LOW)
TERM_CTX_X           equ 160
TERM_CTX_Y           equ 168
TERM_CTX_W           equ 176
TERM_CTX_H           equ 184
L3_SLOT_MAGIC        equ 0x30544F4C5358414E
l3_syscall_stacks    equ L3_SYSCALL_STACK_ADDR

%if L3_APP_BLOB_COPY_CAP > L3_SHADOW_WIN_OFF
%error "L3 app blob copy cap must stay below the shadow/window/stack area"
%endif
%if L3_APP_BLOB_PLACE_CAP > L3_SLOT_USER_STACK_GUARD_OFF
%error "L3 app blob placement cap must stay at/below the user-stack guard page"
%endif

section .text

; auto-wrapped (FN_BEGIN emits global): global enter_usermode
; auto-wrapped (FN_BEGIN emits global): global call_app_l3
; auto-wrapped (FN_BEGIN emits global): global call_app_l3_return
; auto-wrapped (FN_BEGIN emits global): global call_app_l3_packed
; auto-wrapped (FN_BEGIN emits global): global l3_prepare_test_callback
; auto-wrapped (FN_BEGIN emits global): global l3_runtime_ptr
; auto-wrapped (FN_BEGIN emits global): global l3_slot_base
; auto-wrapped (FN_BEGIN emits global): global l3_user_stack_top
; auto-wrapped (FN_BEGIN emits global): global l3_syscall_stack_top
; auto-wrapped (FN_BEGIN emits global): global l3_install_app_done_trampoline
; auto-wrapped (FN_BEGIN emits global): global l3_translate_target
; auto-wrapped (FN_BEGIN emits global): global l3_copy_app_blob_to_slot
; auto-wrapped (FN_BEGIN emits global): global l3_slot_resolve_app_ptr
; auto-wrapped (FN_BEGIN emits global): global app_blob_init
global app_blob_base_v
global app_blob_end_v
global app_blob_size_v
global l3_app_arena_base_v
global l3_app_arena_size_v

; Populate app_blob_base_v / size_v from VBE_INFO+0x20/+0x28 (filled by the
; UEFI loader after reading APPS.BIN). Falls back to the (now-zeroed) embedded
; symbols if no blob was loaded — in that case the apps are effectively absent
; but the kernel still boots.
FN_BEGIN app_blob_init, 0, 0, FN_RET_SCALAR
    push rax
    push rcx
    mov rax, [abs VBE_INFO_ADDR + VBE_APPS_BASE_OFF]
    mov rcx, [abs VBE_INFO_ADDR + VBE_APPS_SIZE_OFF]
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
    mov rax, [abs VBE_INFO_ADDR + VBE_APP_ARENA_BASE_OFF]
    test rax, rax
    jnz .have_arena_base
    mov rax, APP_DATA_ADDR
.have_arena_base:
    mov [rel l3_app_arena_base_v], rax
    mov rcx, [abs VBE_INFO_ADDR + VBE_APP_ARENA_SIZE_OFF]
    test rcx, rcx
    jnz .have_arena_size
    mov rcx, MAX_WINDOWS * APP_SLOT_SIZE
.have_arena_size:
    mov [rel l3_app_arena_size_v], rcx
    pop rcx
    pop rax
    ret

; l3_prepare_test_callback - copy demo user code into slot app arena
; EDI = slot, RAX = entry pointer in APP_DATA space
FN_BEGIN l3_prepare_test_callback, 0, 0, FN_RET_SCALAR
    mov eax, edi
    imul rax, APP_SLOT_SIZE
    add rax, [rel l3_app_arena_base_v]
    mov rdi, rax
    mov r8, rax
    lea rsi, [rel l3_test_blob]
    mov ecx, l3_test_blob_end - l3_test_blob
    rep movsb
    mov rax, r8
    ret

; enter_usermode - generic helper
; RDI = user RIP, RSI = slot
FN_DECL enter_usermode, 0, 0, FN_RET_SCALAR
    mov r10, rdi
    mov r11d, esi
    cmp r11d, MAX_WINDOWS
    jb .slot_ok
    xor r11d, r11d
.slot_ok:
    mov edi, r11d
    call l3_apply_slot_isolation
    mov edi, r11d
    call l3_apply_wx_policy
    ; FS/GS sanitization (security_todo.md §3). IRETQ reloads CS/SS but NOT
    ; DS/ES/FS/GS, so without this the kernel data selector would stay in
    ; fs/gs across the entry into ring 3. Load ring-3 selectors first; clobbers
    ; ax only and nothing live here depends on it. (r10 = user RIP, r11d = slot
    ; are untouched.)
    SANITIZE_SEG_USER_EXIT
    push qword GDT64_USER_DATA
    mov edi, r11d
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
FN_BEGIN l3_runtime_ptr, 0, 0, FN_RET_SCALAR
    mov eax, edi
    imul rax, L3_RT_SIZE
    lea rdx, [rel l3_runtime]
    add rax, rdx
    ret

; l3_slot_base - EDI=slot -> RAX=APP_DATA slot base
FN_BEGIN l3_slot_base, 0, 0, FN_RET_SCALAR
    mov eax, edi
    imul rax, APP_SLOT_SIZE
    add rax, [rel l3_app_arena_base_v]
    ret

; l3_user_stack_top - EDI=slot -> RAX=top of user stack.
; Per-slot offset is sampled in l3_randomize_user_stack_top (called from
; l3_copy_app_blob_to_slot on every slot (re)init). A zero entry means the
; slot has not been initialized yet; fall back to the fixed legacy top so
; pre-slot-load callers (e.g. enter_usermode used by early tests) still work.
FN_BEGIN l3_user_stack_top, 0, 0, FN_RET_SCALAR
    mov ecx, edi
    mov rax, [rel l3_slot_ustack_off + rcx*8]
    test rax, rax
    jnz .l3_ust_have_off
    mov rax, L3_SLOT_USTACK_TOP_HIGH
.l3_ust_have_off:
    imul rdx, rdi, APP_SLOT_SIZE
    add rax, rdx
    add rax, [rel l3_app_arena_base_v]
    and rax, -16
    ret

; l3_randomize_user_stack_top - EDI=slot.
; Samples a fresh 16B-aligned in-slot stack-top offset in
; [L3_SLOT_USTACK_TOP_LOW, L3_SLOT_USTACK_TOP_HIGH] from RDTSC ^ RDRAND
; (RDRAND failure falls back to RDTSC, matching kernel_canary_init). Stores
; the offset in l3_slot_ustack_off[slot] for the slot's lifetime.
FN_BEGIN l3_randomize_user_stack_top, 0, 0, FN_RET_VOID
    push rax
    push rbx
    push rcx
    push rdx
    push rdi
    push r8
    mov r8d, edi
    rdtsc
    shl rdx, 32
    or rax, rdx
    mov rbx, rax
    mov eax, 1
    cpuid
    test ecx, 1 << 30
    jz .lrust_no_rdrand
    mov ecx, 8
.lrust_try_rdrand:
    rdrand rax
    jc .lrust_have_rdrand
    dec ecx
    jnz .lrust_try_rdrand
    jmp .lrust_no_rdrand
.lrust_have_rdrand:
    xor rbx, rax
.lrust_no_rdrand:
    ; Reduce rbx to [0, RANGE] then align down to 16B and add LOW.
    mov rax, rbx
    xor rdx, rdx
    mov rcx, L3_SLOT_USTACK_TOP_RANGE + 1
    div rcx                              ; rdx = rbx mod (RANGE+1)
    and rdx, -16
    add rdx, L3_SLOT_USTACK_TOP_LOW
    mov ecx, r8d
    mov [rel l3_slot_ustack_off + rcx*8], rdx
    pop r8
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    FN_END l3_randomize_user_stack_top
    ret

; l3_syscall_stack_top - EDI=slot -> RAX=top of syscall stack
FN_BEGIN l3_syscall_stack_top, 0, 0, FN_RET_SCALAR
    mov eax, edi
    imul rax, L3_SYSCALL_STACK_STRIDE
    mov rdx, L3_SYSCALL_STACK_ADDR
    add rax, rdx
    add rax, L3_SYSCALL_STACK_STRIDE       ; top = base + (i+1)*STRIDE; syscall stack is the top 4 KiB of the slot
    and rax, -16
    ret

; l3_install_syscall_stack_pt - split the PDE covering l3_syscall_stacks into
; 4 KiB pages so per-slot guard pages can be punched. Idempotent: safe to call
; multiple times. Must run after paging is active and before any syscall (so
; called from kmain before syscall_init).
;
; Algorithm:
;   1. pde_idx = l3_syscall_stacks >> 21
;   2. Walk CR3 -> PML4[0] -> PDPT[0] -> PD0 (BIOS PD0=0x72000, UEFI=0x73000,
;      so we follow the pointers rather than hardcoding).
;   3. Populate SYSCALL_STACK_PT_BASE with 512 PTEs identity-mapping the
;      2 MiB region at (pde_idx << 21), supervisor + writable + NX.
;   4. Clear PAGE_PRESENT on the two guard pages of each MAX_WINDOWS-sized
;      slot (slot stride = L3_SYSCALL_STACK_STRIDE; guards at +0x0000 and
;      +0x2000 bracket the shadow stack and the syscall stack respectively).
;   5. Replace PD0[pde_idx] with SYSCALL_STACK_PT_BASE | PRESENT|WRITABLE
;      (supervisor — kernel-only region).
;   6. Flush TLB (mov cr3, cr3).
FN_BEGIN l3_install_syscall_stack_pt, 0, 0, FN_RET_VOID
    push rbx
    push rcx
    push rdx
    push rdi
    push rsi
    push r8
    push r9

    mov rbx, L3_SYSCALL_STACK_ADDR
    mov rcx, rbx
    shr rcx, 21                          ; rcx = pde_idx
    cmp rcx, 512
    jae .ist_done                        ; outside PD0 — bail (>1 GiB kernel)

    ; Verify the whole 96 KiB array fits in one PDE (alignb 0x20000 guarantees this).
    mov rdx, rbx
    add rdx, MAX_WINDOWS * L3_SYSCALL_STACK_STRIDE - 1
    shr rdx, 21
    cmp rdx, rcx
    jne .ist_done

    ; Walk CR3 -> PML4[0] -> PDPT[0] -> PD0 base.
    mov rdi, PAGE_TABLE_ADDR             ; CR3 / PML4
    mov r8, [rdi]                        ; PML4[0]
    and r8, ~0xFFF
    mov r9, [r8]                         ; PDPT[0]
    and r9, ~0xFFF                       ; r9 = PD0 physical base

    ; Populate the syscall-stack PT: 512 PTEs over [pde<<21, (pde+1)<<21).
    mov rdi, SYSCALL_STACK_PT_BASE
    mov rdx, rcx
    shl rdx, 21                          ; physical base of this PDE
    mov rsi, 512
.ist_fill_pt:
    mov rax, rdx
    or rax, 0x03                         ; PRESENT | WRITABLE (supervisor — no USER)
    bts rax, 63                          ; NX (kernel data region)
    mov [rdi], rax
    add rdx, 0x1000
    add rdi, 8
    dec rsi
    jnz .ist_fill_pt

    ; Clear PAGE_PRESENT on the two guard pages of each 16 KiB slot: one at
    ; slot offset +0x0000 (below the shadow stack) and one at +0x2000 (below
    ; the syscall stack). The first slot's base PTE byte offset is
    ; ((l3_syscall_stacks - (pde<<21)) / 0x1000) * 8; the +0x2000 guard is two
    ; PTEs (= 16 bytes) further on; each subsequent slot is STRIDE/0x1000 PTEs
    ; (= 32 bytes) further on.
    mov rdx, rcx
    shl rdx, 21
    mov rax, rbx
    sub rax, rdx                         ; offset of l3_syscall_stacks within PDE
    shr rax, 12
    shl rax, 3                           ; byte offset of slot 0's base PTE
    add rax, SYSCALL_STACK_PT_BASE
    mov rsi, MAX_WINDOWS
.ist_clear_guard:
    mov rdx, [rax]
    and rdx, ~0x1                        ; clear PRESENT — guard at +0x0000
    mov [rax], rdx
    mov rdx, [rax + 16]
    and rdx, ~0x1                        ; clear PRESENT — guard at +0x2000
    mov [rax + 16], rdx
    add rax, (L3_SYSCALL_STACK_STRIDE / 0x1000) * 8
    dec rsi
    jnz .ist_clear_guard

    ; Swap PD0[pde_idx]: was 2 MiB large supervisor page; now points at the PT.
    lea rdi, [r9 + rcx*8]
    mov rax, SYSCALL_STACK_PT_BASE
    or rax, 0x03                         ; PRESENT | WRITABLE (supervisor)
    mov [rdi], rax

    ; Flush TLB so the new mapping takes effect.
    mov rax, cr3
    mov cr3, rax

%ifdef PROBE_SYSCALL_STACK_GUARD
    ; One-shot probe: touch the guard page of slot 0. Expected behavior:
    ; isr_common_stub catches the page fault, prints "SYSG=0000000000000000",
    ; and halts via isr_nested_halt ("!!!"). Only built when explicitly asked
    ; for via -dPROBE_SYSCALL_STACK_GUARD in build_uefi.ps1.
    SER 'P'
    SER 'R'
    SER 'B'
    SER 13
    SER 10
    lea rax, [rel l3_syscall_stacks]
    mov qword [rax], 0          ; first byte of array == slot 0 guard page
%endif

.ist_done:
    pop r9
    pop r8
    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    ret
    FN_END l3_install_syscall_stack_pt

; l3_apply_slot_isolation - EDI = active slot
; Walks the app-arena 4KB page tables and marks only the active slot's pages
; USER-accessible; every other slot's pages become supervisor-only. A ring-3
; app therefore faults if it dereferences another slot's memory. Flushes the
; TLB so the change takes effect before the iretq into ring 3.
FN_BEGIN l3_apply_slot_isolation, 0, 0, FN_RET_SCALAR
    push rax
    push rcx
    push rdx
    push r8
    push r9
    mov r8d, edi                    ; active slot
    mov r9, APP_ARENA_PT_BASE       ; PTE cursor
    xor edx, edx                    ; slot index
.slot_loop:
    xor ecx, ecx                    ; 4KB page index within slot
.page_loop:
    mov rax, [r9]
    and rax, ~4                     ; clear USER (bit 2)
    cmp edx, r8d
    jne .store
    or  rax, 4                      ; active slot: USER-accessible
.store:
    mov [r9], rax
    add r9, 8
    inc ecx
    cmp ecx, ARENA_SLOT_PAGES
    jb .page_loop
    inc edx
    cmp edx, MAX_WINDOWS
    jb .slot_loop
    mov rax, cr3
    mov cr3, rax                    ; flush TLB
    pop r9
    pop r8
    pop rdx
    pop rcx
    pop rax
    ret

; l3_apply_wx_policy - EDI = active slot
; Walks the active slot's 4KB PT and enforces strict W^X per page:
;
;   * Manifest version 0 (default, set by l3_copy_app_blob_to_slot):
;     no code range is committed yet. Every present page in the slot is
;     forced W+NX — an unmanifested slot literally cannot execute any
;     user code until it commits a manifest via SYS_WX_INSTALL_MANIFEST.
;
;   * Manifest version 1 (set by SYS_WX_INSTALL_MANIFEST after validation):
;     strict W+NX everywhere in the slot, except pages whose slot-offset
;     lies in [code_start_off, code_end_off) which become X+!W.
;
; Manifest versions other than 1, or installed bounds that fail the
; defense-in-depth revalidation, collapse back to the version-0 posture
; (whole slot W+NX). The function only touches the active slot's PT;
; other slots' PTEs are left as l3_apply_slot_isolation set them. TLB is
; flushed via CR3 reload before returning.
;
; Called from enter_usermode immediately after l3_apply_slot_isolation,
; and from SYS_WX_INSTALL_MANIFEST when the running slot updates its
; manifest. Preserves all caller registers.
global l3_apply_wx_policy
FN_BEGIN l3_apply_wx_policy, 0, 0, FN_RET_SCALAR
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push r8
    push r9
    push r10
    push r11
    push r12

    mov r8d, edi                    ; r8d = active slot index
    cmp r8d, MAX_WINDOWS
    jae .wx_done                    ; bogus slot — bail

    ; r9 = slot base virtual addr
    mov eax, r8d
    imul rax, APP_SLOT_SIZE
    add rax, [rel l3_app_arena_base_v]
    mov r9, rax

    ; Read manifest. Magic must match — slots that have never been used by
    ; l3_copy_app_blob_to_slot have undefined metadata, treat as legacy.
    xor r10d, r10d                  ; r10d = effective manifest version
    mov eax, r8d
    mov rax, [l3_wx_manifest_ver + rax*8]
    cmp rax, 1
    jne .wx_have_ver
    ; Validate manifest bounds (defense-in-depth — install syscall already
    ; checks these, but re-validating on every activation costs ~4 compares
    ; and protects against a future bug that bypasses the install path).
    mov eax, r8d
    mov rcx, [l3_wx_code_start + rax*8]
    mov rdx, [l3_wx_code_end + rax*8]
    test rcx, 0xFFF
    jnz .wx_have_ver
    test rdx, 0xFFF
    jnz .wx_have_ver
    cmp rcx, L3_APP_CODE_OFF
    jb  .wx_have_ver
    cmp rdx, L3_SHADOW_WIN_OFF
    ja  .wx_have_ver
    cmp rcx, rdx
    jae .wx_have_ver
    mov r10d, 1

.wx_have_ver:
    ; r10d == 0  -> no valid manifest: force whole slot W+NX (no code pages).
    ; r10d == 1  -> manifest v1: [code_start_off, code_end_off) becomes X+!W.
.wx_manifest_loop:
    ; PT cursor for this slot: APP_ARENA_PT_BASE + slot * ARENA_SLOT_PAGES * 8
    mov eax, r8d
    imul rax, ARENA_SLOT_PAGES * 8
    add rax, APP_ARENA_PT_BASE
    mov r11, rax

    ; Pre-load page-offset bounds for the legacy stack-W+NX region.
    ; Stack lives in [L3_SLOT_USER_STACK_TOP - L3_USER_STACK_SIZE, APP_SLOT_SIZE);
    ; force W+NX across those pages in BOTH manifest paths.
    mov rbx, L3_SLOT_USER_STACK_TOP - L3_USER_STACK_SIZE
    and rbx, ~0xFFF                 ; page-aligned

    xor r12d, r12d                  ; page index within slot
.wx_page_loop:
    mov rax, [r11]
    test al, 1                      ; PAGE_PRESENT?
    jz .wx_next                     ; absent (guard page) — leave alone

    ; rsi = byte offset of this page within slot
    mov rsi, r12
    shl rsi, 12

    ; Stack region always W+NX.
    cmp rsi, rbx
    jae .wx_set_wnx

    ; Per-slot handle table is kernel-owned data living inside the legal code
    ; window. It must stay writable (handle_table_clear/alloc/close update it)
    ; and non-executable, so force W+NX regardless of the manifest. Without
    ; this carve-out an app whose declared code range covers
    ; L3_HANDLE_TABLE_OFF marks the page X+!W and the next kernel handle write
    ; takes a ring-0 #PF that iretqs back into itself forever.
    mov rdx, rsi
    sub rdx, L3_HANDLE_TABLE_OFF
    cmp rdx, (L3_HANDLE_TABLE_SZ + 0xFFF) & ~0xFFF
    jb .wx_set_wnx

    ; No manifest -> legacy permissive: blob pages keep their existing W+X
    ; permissions. NexusHL apps interleave .text and .data in one section,
    ; so forcing W+NX here breaks string scratches / .bss-style buffers.
    ; Apps that want strict W^X opt in via SYS_WX_INSTALL_MANIFEST.
    test r10d, r10d
    jz .wx_next

    mov ecx, r8d
    cmp rsi, [l3_wx_code_start + rcx*8]
    jb .wx_set_wnx
    cmp rsi, [l3_wx_code_end + rcx*8]
    jae .wx_set_wnx
    ; Code page: clear W (bit 1) AND clear NX (bit 63) → X+!W.
    and rax, -3                     ; ~2 sign-extended: clears bit 1
    mov rdx, PAGE_NX
    not rdx
    and rax, rdx                    ; clears bit 63
    mov [r11], rax
    jmp .wx_next

.wx_set_wnx:
    ; Data/stack page: set W (bit 1) AND set NX (bit 63) → W+NX.
    or rax, 2
    mov rdx, PAGE_NX
    or rax, rdx
    mov [r11], rax

.wx_next:
    add r11, 8
    inc r12d
    cmp r12d, ARENA_SLOT_PAGES
    jb .wx_page_loop

    ; Flush TLB so the new permissions take effect before iretq / return.
    mov rax, cr3
    mov cr3, rax

    ; Code-range hash-on-install (security_todo.md §12). The first time a slot
    ; presents a valid v1 manifest (r10d==1), capture the FNV-1a hash of its
    ; X-page bytes as the integrity baseline. Subsequent activations skip this
    ; (valid flag set); pit_handler re-verifies the baseline periodically. We
    ; baseline here rather than in the install syscall so the hook stays
    ; self-contained in usermode.asm and covers every path that commits a code
    ; range (enter_usermode + SYS_WX_INSTALL_MANIFEST both reach this walk).
    test r10d, r10d
    jz .wx_done
    cmp byte [l3_code_hash_valid + r8], 0
    jne .wx_done
    mov edi, r8d
    call l3_code_hash_install

.wx_done:
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; ============================================================================
; Code-range integrity hashing (security_todo.md §12).
;
; THREAT: an unintended W mapping landing on a code (X) page — e.g. a future
; JIT-alias bug or any kernel-write primitive — could mutate executable bytes
; after they were validated, without ever flipping a permission bit we scrub.
; l3_apply_wx_policy guards the *permissions*; this guards the *contents*.
;
; APPROACH: when a slot first commits a valid v1 manifest, hash every byte of
; its executable code range (FNV-1a; same constants as measured_boot.asm, but a
; local stateless fold so we carry no cross-file dependency) and stash it in
; l3_code_hash[slot]. pit_handler periodically re-hashes and compares; a
; mismatch means executable bytes changed under us -> kernel_panic_canary.
;
; The per-slot kernel-owned handle table lives inside the legal code window and
; is legitimately mutable (handle_alloc/close write it). l3_apply_wx_policy
; already forces those pages W+NX (a carve-out); the hash MUST skip the same
; region or every handle write would trip a false integrity panic.
; ============================================================================
L3_CODE_HASH_FNV_OFFSET equ 0xCBF29CE484222325
L3_CODE_HASH_FNV_PRIME  equ 0x00000100000001B3

; l3_code_hash_compute - EDI = slot. Returns RAX = FNV-1a hash of the slot's
; executable code-range bytes (skipping the handle-table carve-out), or 0 if
; the slot has no valid v1 manifest / an empty range. Preserves rbx,rcx,rdx,
; rsi,rdi,r8..r12 (clobbers only rax + the saved/restored temporaries).
FN_DECL l3_code_hash_compute, 0, 0, FN_RET_SCALAR
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    push r9
    push r10
    push r11
    push r12

    mov r8d, edi                         ; r8d = slot
    cmp r8d, MAX_WINDOWS
    jae .ch_zero

    ; Require a committed v1 manifest with sane bounds (same gate as the policy
    ; walk). Anything else means "no code range to hash".
    mov eax, r8d
    cmp qword [l3_wx_manifest_ver + rax*8], 1
    jne .ch_zero
    mov rsi, [l3_wx_code_start + rax*8]   ; rsi = code_start offset
    mov rdx, [l3_wx_code_end + rax*8]     ; rdx = code_end offset (exclusive)
    cmp rsi, rdx
    jae .ch_zero

    ; r9 = slot base virtual address.
    mov edi, r8d
    call l3_slot_base
    mov r9, rax

    ; r10 = handle-table carve-out start offset, r11 = carve-out end offset
    ; (page-rounded, matching l3_apply_wx_policy's skip window).
    mov r10, L3_HANDLE_TABLE_OFF
    mov r11, (L3_HANDLE_TABLE_SZ + 0xFFF) & ~0xFFF
    add r11, r10

    mov r12, L3_CODE_HASH_FNV_OFFSET      ; r12 = running hash accumulator
    mov rcx, rsi                          ; rcx = current offset cursor

    ; SMAP: the slot is user (PTE.U=1) memory; bracket the byte reads.
    USER_ACCESS_BEGIN
.ch_loop:
    cmp rcx, rdx
    jae .ch_loop_done
    ; Skip the handle-table carve-out [r10, r11): mutable kernel data, not code.
    cmp rcx, r10
    jb .ch_present_check
    cmp rcx, r11
    jb .ch_skip
.ch_present_check:
    ; Only fold bytes from PRESENT pages. A non-present page in the range
    ; (e.g. a guard or never-populated page) would #PF in ring 0 here — and it
    ; holds no executable bytes anyway — so skip the whole page. PT entry for
    ; this offset = APP_ARENA_PT_BASE + slot*ARENA_SLOT_PAGES*8 + (off>>12)*8.
    mov rbx, rcx
    shr rbx, 12                           ; page index within slot
    mov eax, r8d
    imul rax, ARENA_SLOT_PAGES * 8
    lea rbx, [rax + rbx*8 + APP_ARENA_PT_BASE]
    mov rax, [rbx]
    test al, 1                            ; PAGE_PRESENT?
    jz .ch_skip_page
    ; rax held the PTE (scratch); the running hash lives in r12 across the loop.
    movzx ebx, byte [r9 + rcx]            ; slot byte
    xor r12, rbx                          ; FNV-1a: hash ^= byte
    mov rbx, L3_CODE_HASH_FNV_PRIME
    imul r12, rbx                         ; hash *= prime
    inc rcx
    jmp .ch_loop
.ch_skip_page:
    ; Advance rcx to the next page boundary (skip the whole absent page).
    or rcx, 0xFFF
    inc rcx
    jmp .ch_loop
.ch_skip:
    inc rcx
    jmp .ch_loop
.ch_loop_done:
    USER_ACCESS_END
    mov rax, r12                          ; final running hash
    jmp .ch_ret

.ch_zero:
    xor eax, eax                          ; no valid range -> hash 0
.ch_ret:
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

; l3_code_hash_install - EDI = slot. Capture the slot's code-range hash as the
; integrity baseline and mark it live. Idempotent re-baseline; preserves all
; caller registers.
FN_DECL l3_code_hash_install, 0, 0, FN_RET_SCALAR
    push rax
    push rcx
    push rdi
    mov ecx, edi                          ; ecx = slot (preserved across call)
    call l3_code_hash_compute             ; rax = hash
    mov [l3_code_hash + rcx*8], rax
    mov byte [l3_code_hash_valid + rcx], 1
    pop rdi
    pop rcx
    pop rax
    ret

; l3_code_hash_verify_all - re-hash every slot with a live baseline and panic
; on the first mismatch (an unintended W landed on a code page). Called from
; pit_handler on a tick cadence. Preserves all caller registers. Reached from
; IRQ context, hence FN_DECL (no trace push/call before we are sure of state).
extern kernel_panic_canary
FN_DECL l3_code_hash_verify_all, 0, 0, FN_RET_SCALAR
    push rax
    push rcx
    push rdx
    push rdi
    xor ecx, ecx                          ; slot index
.va_loop:
    cmp ecx, MAX_WINDOWS
    jae .va_done
    cmp byte [l3_code_hash_valid + rcx], 0
    je .va_next
    mov edx, ecx                          ; save slot across the call
    mov edi, ecx
    call l3_code_hash_compute             ; rax = recomputed hash
    mov ecx, edx
    cmp rax, [l3_code_hash + rcx*8]
    jne .va_mismatch
.va_next:
    inc ecx
    jmp .va_loop
.va_done:
    pop rdi
    pop rdx
    pop rcx
    pop rax
    ret
.va_mismatch:
    ; Executable bytes diverged from the install-time baseline. Treat as a W^X
    ; integrity violation and take the same fail-closed path as a corrupted
    ; canary / forged callback. Never returns.
    jmp kernel_panic_canary

FN_DECL l3_install_app_done_trampoline, 0, 0, FN_RET_SCALAR
    push rcx
    mov ecx, edi
    call l3_slot_base
    add rax, [rel l3_slot_code_slide + rcx*8]
    add rax, app_l3_done_trampoline - app_blob_start
    pop rcx
    ret

; l3_randomize_code_slide - EDI=slot.
; Samples a fresh page-aligned in-slot code slide in
; [0, L3_APP_BLOB_PLACE_CAP - blob_size] from RDTSC ^ RDRAND (RDRAND failure
; falls back to RDTSC, matching l3_randomize_user_stack_top). Stores the slide
; in l3_slot_code_slide[slot] for the slot's lifetime. The slide is added to
; the slot base when the blob is copied in, so the same code/gadget addresses
; differ across slots — an info leak in one slot reveals only that slot's
; layout, not every slot's layout.
FN_BEGIN l3_randomize_code_slide, 0, 0, FN_RET_VOID
    push rax
    push rbx
    push rcx
    push rdx
    push rdi
    push r8
    mov r8d, edi
    ; max_slide_bytes = (L3_APP_BLOB_PLACE_CAP - blob_size), floor-aligned to page.
    ; PLACE_CAP (the user-stack guard floor), not COPY_CAP (the shadow-window
    ; boundary), bounds placement so a slid blob never reaches the guard page or
    ; the user stack above it. If the blob is larger than the cap (shouldn't
    ; happen — l3_copy_app_blob_to_slot truncates anyway), pin slide to 0.
    mov rcx, L3_APP_BLOB_PLACE_CAP
    sub rcx, [rel app_blob_size_v]
    jbe .lrcs_zero
    shr rcx, 12                          ; rcx = number of page-positions - 1
    inc rcx                              ; rcx = number of page-positions (>= 1)
    ; Sample entropy.
    rdtsc
    shl rdx, 32
    or rax, rdx
    mov rbx, rax
    mov eax, 1
    cpuid
    test ecx, 1 << 30
    jz .lrcs_no_rdrand
    mov ecx, 8
.lrcs_try_rdrand:
    rdrand rax
    jc .lrcs_have_rdrand
    dec ecx
    jnz .lrcs_try_rdrand
    jmp .lrcs_no_rdrand
.lrcs_have_rdrand:
    xor rbx, rax
.lrcs_no_rdrand:
    ; rdx:rax = rbx; divide by rcx (page-position count) -> remainder in rdx.
    mov rax, L3_APP_BLOB_PLACE_CAP
    sub rax, [rel app_blob_size_v]
    shr rax, 12
    inc rax                              ; recompute (rcx was clobbered by cpuid)
    mov rcx, rax
    mov rax, rbx
    xor rdx, rdx
    div rcx                              ; rdx = rbx mod page-position-count
    shl rdx, 12                          ; rdx = slide in bytes, page-aligned
    mov ecx, r8d
    mov [rel l3_slot_code_slide + rcx*8], rdx
    jmp .lrcs_done
.lrcs_zero:
    mov ecx, r8d
    mov qword [rel l3_slot_code_slide + rcx*8], 0
.lrcs_done:
    pop r8
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    FN_END l3_randomize_code_slide
    ret

; ============================================================================
; Per-slot cryptographic identity key (security_todo.md §10).
;
; Each slot gets a kernel-only secret key derived at slot init from
;     slot_key = FNV-1a( kernel_canary || slot_id || boot_nonce )
; using the SAME FNV-1a family already relied on across the tree
; (measured_boot.asm, the code-range hash above). The key is a per-install
; secret an app can later prove knowledge of via a HMAC-this-data syscall
; (explicit FOLLOW-UP — not landed here). The key NEVER touches the slot's
; ring-3 memory: it lives only in kernel BSS (l3_slot_key[]), outside the
; app arena, exactly like l3_code_hash[] / l3_slot_code_slide[].
;
; The boot nonce is a one-shot RDTSC ^ RDRAND draw (same source as
; kernel_canary_init / l3_randomize_*), captured once via l3_boot_nonce_ensure
; and stable for the boot. Mixing it in means the per-slot key differs across
; boots even for the same canary+slot, so a leaked key from a prior boot is
; useless against the next one.
;
; Storage uses the same non-cryptographic FNV stopgap documented in
; measured_boot.asm: collision-resistant enough to act as a per-slot secret
; identifier, swap-able for a real KDF later without touching the call sites.
; ============================================================================
L3_SLOT_KEY_FNV_OFFSET equ 0xCBF29CE484222325
L3_SLOT_KEY_FNV_PRIME  equ 0x00000100000001B3

; l3_boot_nonce_ensure - lazily seed the kernel-only boot nonce from
; RDTSC ^ RDRAND on first call; later calls are a no-op. A final non-zero
; guard avoids an all-zero nonce (matches kernel_canary_init). Plain-label
; internal helper. Preserves all caller registers.
l3_boot_nonce_ensure:
    cmp byte [rel l3_boot_nonce_done], 0
    jne .bne_ret
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
    test ecx, 1 << 30
    jz .bne_no_rdrand
    mov ecx, 8
.bne_try_rdrand:
    rdrand rax
    jc .bne_have_rdrand
    dec ecx
    jnz .bne_try_rdrand
    jmp .bne_no_rdrand
.bne_have_rdrand:
    xor rbx, rax
.bne_no_rdrand:
    test rbx, rbx
    jnz .bne_store
    mov rbx, 0xB007A11CE5EED5EE
.bne_store:
    mov [rel l3_boot_nonce], rbx
    mov byte [rel l3_boot_nonce_done], 1
    pop rdx
    pop rcx
    pop rbx
    pop rax
.bne_ret:
    ret

; l3_derive_slot_key - EDI = slot. Derive this slot's kernel-only key as
; FNV-1a over (kernel_canary || slot_id || boot_nonce), 8 bytes each LE, and
; store it in l3_slot_key[slot]. The key is never written into ring-3 memory.
; Plain-label internal helper (no global) so it carries no coverage gate.
; Preserves all caller registers.
l3_derive_slot_key:
    push rax
    push rbx
    push rcx
    push rdx
    push rdi
    mov ecx, edi                          ; ecx = slot
    cmp ecx, MAX_WINDOWS
    jae .dsk_ret                          ; bogus slot — never index past array
    call l3_boot_nonce_ensure             ; make sure the nonce is live

    mov rax, L3_SLOT_KEY_FNV_OFFSET       ; rax = running hash
    mov rbx, L3_SLOT_KEY_FNV_PRIME        ; rbx = FNV prime (constant across folds)

    ; Fold the three 8-byte inputs in order: kernel_canary, slot_id, boot_nonce.
    mov rdx, [rel kernel_canary]
    call .dsk_fold8
    mov edx, ecx                          ; slot id (zero-extended to 64)
    call .dsk_fold8
    mov rdx, [rel l3_boot_nonce]
    call .dsk_fold8

    mov [rel l3_slot_key + rcx*8], rax
.dsk_ret:
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret
; .dsk_fold8 - fold the 8 bytes of rdx (LE) into the running FNV hash in rax,
; with the prime preloaded in rbx. Clobbers rdx (consumed) + a scratch byte in
; the low bits; rcx (slot) and rbx (prime) are preserved.
.dsk_fold8:
    push rdi                              ; byte counter scratch
    push r8                               ; byte scratch (caller's r8 preserved)
    mov edi, 8
.dsk_fold_byte:
    movzx r8, dl                          ; next low byte of the input word
    xor rax, r8                           ; FNV-1a: hash ^= byte
    imul rax, rbx                         ; hash *= prime
    shr rdx, 8
    dec edi
    jnz .dsk_fold_byte
    pop r8
    pop rdi
    ret

; l3_copy_app_blob_to_slot - copy the built-in user blob into a slot arena
; EDI = slot
FN_BEGIN l3_copy_app_blob_to_slot, 0, 0, FN_RET_SCALAR
    push rcx
    push rdi
    push rsi
    push r8
    push r9
    mov r9d, edi
    ; Re-randomize this slot's per-slot code slide first; the copy destination
    ; below depends on it. Sliding the blob within the slot means a leak from
    ; one slot doesn't reveal gadget addresses for any other slot.
    mov edi, r9d
    call l3_randomize_code_slide
    mov edi, r9d
    call l3_slot_base
    mov r8, rax                          ; r8 = unmodified slot base (return value)
    ; Wipe the slot arena before anything is re-initialized so no stale secrets
    ; from the prior tenant (callback ptrs, canary derivatives, handle-table
    ; contents) survive into the new app. Must precede the blob copy and the
    ; manifest/stack/handle re-init below — they re-populate this range. The
    ; user-stack guard page (L3_SLOT_USER_STACK_GUARD_OFF) is non-present, so
    ; wipe the ranges below and above it separately — touching it would #PF.
    push rdi
    push rcx
    push rax
    xor eax, eax
    cld
    mov rdi, r8
    mov rcx, L3_SLOT_USER_STACK_GUARD_OFF / 8
    USER_ACCESS_BEGIN
    rep stosq
    USER_ACCESS_END
    lea rdi, [r8 + L3_SLOT_USER_STACK_GUARD_OFF + 0x1000]
    mov rcx, (APP_SLOT_SIZE - L3_SLOT_USER_STACK_GUARD_OFF - 0x1000) / 8
    USER_ACCESS_BEGIN
    rep stosq
    USER_ACCESS_END
    pop rax
    pop rcx
    pop rdi
    mov rdi, rax
    mov eax, r9d
    add rdi, [rel l3_slot_code_slide + rax*8]   ; copy destination = slot_base + slide
    mov rsi, [rel app_blob_base_v]
    mov rcx, [rel app_blob_size_v]
    ; Available copy window shrinks by the slide. Clamp against PLACE_CAP (the
    ; user-stack guard floor) so the copy can never write through the
    ; non-present guard page or into the user stack, even at the maximum slide.
    mov rdx, L3_APP_BLOB_PLACE_CAP
    mov eax, r9d
    sub rdx, [rel l3_slot_code_slide + rax*8]
    cmp rcx, rdx
    jbe .copy_len_ok
    mov rcx, rdx
.copy_len_ok:
    cld
    USER_ACCESS_BEGIN
    rep movsb
    USER_ACCESS_END
    mov rax, L3_SLOT_MAGIC
    mov ecx, r9d
    mov [l3_slot_live + rcx*8], rax
    ; Install a default v1 W^X manifest spanning the legitimate code window
    ; [L3_APP_CODE_OFF, L3_SHADOW_WIN_OFF). Without this, l3_apply_wx_policy
    ; would force the whole slot W+NX and *no* user code could execute —
    ; legacy NexusHL apps (which never call SYS_WX_INSTALL_MANIFEST) would
    ; page-fault on the first instruction of their drawfn. Apps that want a
    ; tighter range (e.g. excluding their .data tail) can still override via
    ; SYS_WX_INSTALL_MANIFEST at runtime.
    ; Zero this slot's W^X manifest. Per the spec in boot_memory.inc, manifest
    ; version 0 means "legacy permissive" — blob pages stay W+X, only the
    ; stack region is forced W+NX. Apps that want strict W^X opt in via
    ; SYS_WX_INSTALL_MANIFEST. The actual permissive vs strict semantics
    ; live in l3_apply_wx_policy below.
    xor eax, eax
    mov ecx, r9d
    mov [l3_wx_manifest_ver + rcx*8], rax
    mov [l3_wx_code_start + rcx*8], rax
    mov [l3_wx_code_end + rcx*8], rax
    ; Invalidate the code-range integrity baseline (security_todo.md §12): the
    ; new tenant's code differs from the recycled slot's, so l3_apply_wx_policy
    ; must re-capture the hash on the next valid-manifest activation. Clearing
    ; the byte is enough; l3_code_hash[] is recomputed before it is trusted.
    mov byte [l3_code_hash_valid + rcx], 0
    ; Re-randomize this slot's user stack top so a leak from a sibling slot
    ; does not predict our RSP layout for the new app's lifetime.
    mov edi, r9d
    call l3_randomize_user_stack_top
    ; Derive this slot's kernel-only identity key (security_todo.md §10):
    ; FNV-1a(kernel_canary || slot_id || boot_nonce). Stored in l3_slot_key[]
    ; (kernel BSS), never copied into the slot's ring-3 memory. Re-derived on
    ; every slot recycle so a new tenant gets a fresh secret. A HMAC-this-data
    ; syscall is the explicit follow-up; only derivation + storage land here.
    mov edi, r9d
    call l3_derive_slot_key
    ; Phase 1 handle-table refactor: clear this slot's handle table so the
    ; new app starts with no inherited handles from the previous occupant.
    ; Phase 2 will wire syscalls (FAT16 dir-entry handles first) onto it.
    mov rdi, r8
    call handle_table_clear
    mov rax, r8
    pop r9
    pop r8
    pop rsi
    pop rdi
    pop rcx
    ret

; l3_slot_resolve_app_ptr
; EDI = slot, RSI = kernel pointer inside the built-in user blob
; Returns: RAX = slot-local pointer, or RSI unchanged if outside blob
FN_BEGIN l3_slot_resolve_app_ptr, 0, 0, FN_RET_SCALAR
    lea r8, [rel app_blob_start]
    lea r9, [rel app_blob_end]
    mov rax, rsi
    cmp rax, r8
    jb .slot_resolve_done
    cmp rax, r9
    jae .slot_resolve_done
    push rdx
    push rcx
    sub rax, r8
    mov edx, edi
    imul rdx, APP_SLOT_SIZE
    add rdx, [rel l3_app_arena_base_v]
    add rax, rdx
    ; Apply this slot's per-slot code slide.
    mov ecx, edi
    add rax, [rel l3_slot_code_slide + rcx*8]
    pop rcx
    pop rdx
.slot_resolve_done:
    ret

; l3_translate_target
; RDI = callback target. This may be either a canonical pointer inside the
; built-in app blob or a slot-local pointer handed to the kernel by ring-3
; code through SYS_WM_CREATE / SYS_WM_HANDLERS.
; RSI = slot app base
; Returns: RAX = translated user target (or original target if no mapping applies)
FN_BEGIN l3_translate_target, 0, 0, FN_RET_SCALAR
    lea r8, [rel app_blob_start]
    lea r9, [rel app_blob_end]
    mov rax, rdi
    cmp rax, r8
    jb .try_slot_local
    cmp rax, r9
    jae .try_slot_local

    sub rax, r8                         ; rax = blob-relative offset
    add rax, rsi                        ; + active slot base
    ; Add this (active) slot's per-slot code slide. The slot index is
    ; (rsi - arena_base) / APP_SLOT_SIZE.
    mov r10, rsi
    sub r10, [rel l3_app_arena_base_v]
    shr r10, 21
    add rax, [rel l3_slot_code_slide + r10*8]
    jmp .translate_done

.try_slot_local:
    mov r8, [rel l3_app_arena_base_v]
    mov r9, r8
    add r9, [rel l3_app_arena_size_v]
    mov rax, rdi
    cmp rax, r8
    jb .translate_original
    cmp rax, r9
    jae .translate_original
    sub rax, r8
    and rax, APP_SLOT_SIZE - 1          ; in-slot offset
    ; With per-slot code slide, the valid live-blob window is
    ; [slide, slide + blob_size). Reject anything outside it.
    mov r10, rsi
    sub r10, [rel l3_app_arena_base_v]
    shr r10, 21
    mov r11, [rel l3_slot_code_slide + r10*8]
    cmp rax, r11
    jb .translate_original
    sub rax, r11
    cmp rax, [rel app_blob_size_v]
    jae .translate_original
    add rax, r11                        ; restore in-slot offset (incl. slide)
    add rax, rsi
    jmp .translate_done

.translate_original:
    mov rax, rdi
.translate_done:
    ret

; call_app_l3_packed -- Stage 2c thunk for cross-core dispatch.
; RDI = pointer to a 32-byte packed-args block:
;       [0] = target function
;       [8] = arg0 (window ptr)
;       [16] = arg1
;       [24] = arg2
; Unpacks into the regs call_app_l3 expects and tail-calls it.
;
; This is the function Stage 2d will hand to process_submit_job so an AP can
; run the ring-3 transition on behalf of the owning PCB. Lives in usermode.asm
; so it's adjacent to call_app_l3 and shares its label scope.
FN_BEGIN call_app_l3_packed, 1, 0, FN_RET_SCALAR
    mov rsi, [rdi + 8]
    mov rdx, [rdi + 16]
    mov rcx, [rdi + 24]
    mov rdi, [rdi + 0]
    call call_app_l3
    FN_END call_app_l3_packed
    ret

; call_app_l3
; RDI = target function
; RSI = arg0 (window ptr)
; RDX = arg1
; RCX = arg2
;
; Note: Stage 2c added the dispatch_app_callback scaffold in process.asm as
; the future chokepoint for ring-3-on-AP routing. Existing call sites still
; invoke call_app_l3 directly (inline path); Stage 2d will replace them with
; dispatch_app_callback once the slot-isolation refactor lands.
FN_DECL call_app_l3, 0, 0, FN_RET_SCALAR
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
    sub rax, [rel l3_app_arena_base_v]
    js .slot_zero
    shr rax, 21
    cmp eax, MAX_WINDOWS
    jb .slot_ready
.slot_zero:
    xor eax, eax
.slot_ready:
    mov r11d, eax
    mov edi, r11d
    call l3_runtime_ptr
    mov r12, rax

    mov [r12 + L3_RT_ENTRY], r13
    mov [r12 + L3_RT_ARG0], r14
    mov [r12 + L3_RT_ARG1], r15
    mov [r12 + L3_RT_ARG2], rbx
    mov [r12 + L3_RT_KERNEL_RSP], rsp
    pushfq
    pop qword [r12 + L3_RT_KERNEL_RFLAGS]
    mov edi, r11d
    call l3_slot_base
    mov [r12 + L3_RT_APP_BASE], rax
    mov rdx, L3_SLOT_MAGIC
    mov ecx, r11d
    cmp [l3_slot_live + rcx*8], rdx
    je .translate_generic
    mov edi, r11d
    call l3_copy_app_blob_to_slot
.translate_generic:
    mov rdi, r13
    mov rsi, rax
    call l3_translate_target
    mov r13, rax
.target_ready:
    mov [r12 + L3_RT_ENTRY], r13

    ; Ring-3 code cannot dereference the kernel window struct directly.
    ; Build the slot-local shadow once; later callbacks reuse it.
    test r14, r14
    jz .args_ready
    mov rax, [r12 + L3_RT_APP_BASE]
    ; Re-sync the shadow window from the live kernel struct on every call.
    ; Caching it on first use leaves the app reading stale x/y/w/h after the
    ; WM moves or resizes the window (e.g. during drag).
    mov rsi, r14
    mov rdi, rax
    add rdi, L3_SHADOW_WIN_OFF
    mov rcx, WINDOW_STRUCT_SIZE / 8
    cld
    USER_ACCESS_BEGIN
    rep movsq
    mov rax, [r12 + L3_RT_APP_BASE]
    mov [rdi - WINDOW_STRUCT_SIZE + WIN_OFF_APPDATA], rax
    USER_ACCESS_END
.shadow_ready:
    mov rax, [r12 + L3_RT_APP_BASE]
    lea r14, [rax + L3_SHADOW_WIN_OFF]
    mov [r12 + L3_RT_ARG0], r14
.args_ready:
%ifdef ENABLE_L3_CALL_TRACE
    ; Per-call entry trace. Off by default: at one call per window message it
    ; floods COM1 and the busy-wait OUT-0x3F8 stalls the render loop enough to
    ; freeze the cursor. Re-enable with -dENABLE_L3_CALL_TRACE when needed.
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
%endif

    ; Restrict the arena so only this slot's pages are ring-3 accessible.
    mov edi, r11d
    call l3_apply_slot_isolation
    mov edi, r11d
    call l3_apply_wx_policy

    mov edi, r11d
    call l3_user_stack_top
    sub rax, 8
    push rax
    mov edi, r11d
    call l3_install_app_done_trampoline
    mov rdx, rax
    pop rax
    USER_ACCESS_BEGIN
    mov [rax], rdx                ; IRET trampoline onto the slot's user stack (PTE.U=1)
    USER_ACCESS_END
    mov [r12 + L3_RT_USER_RSP], rax

    ; FS/GS sanitization (security_todo.md §3). As in enter_usermode: IRETQ
    ; does not reload DS/ES/FS/GS, so install ring-3 selectors before the iret
    ; frame is built and the callback arg registers (rdi/rsi/rdx) are loaded.
    ; Clobbers ax (and, under the optional MSR scrub, rcx/rdx) — done BEFORE the
    ; rdi/rsi/rdx arg loads below so none of them are corrupted. r12/r13/r14/r15
    ; and rbx (callback ptr/args) survive.
    SANITIZE_SEG_USER_EXIT
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

FN_DECL call_app_l3_return, 0, 0, FN_RET_SCALAR
    mov eax, [rsp]
    cmp eax, MAX_WINDOWS
    jb .ret_slot_ready
    xor eax, eax
.ret_slot_ready:
    mov edi, eax
    call l3_runtime_ptr
    mov r12, rax
    mov r10, [r12 + L3_RT_KERNEL_RSP]
%ifdef ENABLE_L3_CALL_TRACE
    ; Paired with the entry trace above; same rationale for being opt-in.
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
%endif
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
; auto-wrapped (FN_BEGIN emits global): global test_usermode_proc
FN_BEGIN test_usermode_proc, 0, 0, FN_RET_SCALAR
    jmp $

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
l3_app_blob_copy_cap_guard: dq L3_APP_BLOB_COPY_CAP
app_blob_base_v:     dq 0
app_blob_end_v:      dq 0
app_blob_size_v:     dq 0
l3_app_arena_base_v: dq APP_DATA_ADDR
l3_app_arena_size_v: dq (MAX_WINDOWS * APP_SLOT_SIZE)

; --- BSS Section (Always last) ---
section .bss
; 128 KiB alignment guarantees the MAX_WINDOWS * 8 KiB = 96 KiB array fits
; inside a single 2 MiB PDE, which lets l3_install_syscall_stack_pt swap
; that PDE for a single 4 KiB page table.
alignb 16
global l3_wx_manifest_ver
global l3_wx_code_start
global l3_wx_code_end
global l3_slot_live
global l3_slot_ustack_off
global l3_slot_code_slide
l3_slot_live:        resq MAX_WINDOWS
l3_wx_manifest_ver: resq MAX_WINDOWS
l3_wx_code_start:   resq MAX_WINDOWS
l3_wx_code_end:     resq MAX_WINDOWS
; Per-slot user-stack-top in-slot offset (set by l3_randomize_user_stack_top
; on every slot (re)load). Zero = uninitialized, falls back to legacy fixed top.
l3_slot_ustack_off: resq MAX_WINDOWS
; Per-slot code slide (set by l3_randomize_code_slide on every slot (re)load).
; Page-aligned, in [0, L3_APP_BLOB_PLACE_CAP - blob_size]. The blob is copied
; to slot_base + slide, so a code-pointer leak in one slot only reveals that
; slot's gadget addresses — sibling slots have independent slides.
l3_slot_code_slide: resq MAX_WINDOWS
; Code-range integrity hashing (security_todo.md §12). l3_code_hash[slot] holds
; the FNV-1a hash of the slot's executable (X) code-range bytes, captured the
; first time l3_apply_wx_policy commits a valid v1 manifest for the slot
; (hash-on-install). l3_code_hash_valid[slot] != 0 marks the baseline as live.
; pit_handler periodically calls l3_code_hash_verify_all; any mismatch means an
; unintended W landed on a code page (e.g. an undiscovered JIT-alias bug
; mutated executable bytes) -> kernel_panic_canary. Both are cleared on slot
; recycle in l3_copy_app_blob_to_slot so the next tenant re-baselines.
global l3_code_hash
global l3_code_hash_valid
l3_code_hash:       resq MAX_WINDOWS
l3_code_hash_valid: resb MAX_WINDOWS
alignb 8
; Per-slot kernel-only identity key (security_todo.md §10). l3_slot_key[slot]
; holds FNV-1a(kernel_canary || slot_id || boot_nonce), derived by
; l3_derive_slot_key on every slot (re)init from l3_copy_app_blob_to_slot. This
; lives in kernel BSS — OUTSIDE the ring-3 app arena — so an app can never read
; or forge its own key; a future HMAC-this-data syscall is the only intended
; egress, and even then only the MAC leaves the kernel, never the key.
global l3_slot_key
l3_slot_key:        resq MAX_WINDOWS
; One-shot boot nonce mixed into every slot key, seeded once from RDTSC^RDRAND
; by l3_boot_nonce_ensure. Kernel-only; never exposed to ring 3.
l3_boot_nonce:      resq 1
l3_boot_nonce_done: resb 1
alignb 16
global l3_runtime
; Keep this in sync with L3_RT_SIZE above. A smaller allocation corrupts
; adjacent state as soon as multiple ring-3 callbacks run.
l3_runtime:          resb (MAX_WINDOWS * L3_RT_SIZE)

section .text
