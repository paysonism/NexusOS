; ============================================================================
; NexusOS v3.0 - Usermode Transition
; Clean L3 callback path for app draw/click/key handlers.
; ============================================================================
bits 64

%include "constants.inc"
%include "macros.inc"
%include "syscall_user.inc"
%include "l3_runtime.inc"

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
; Variables moved to the end of file to avoid segment clobbering in monolithic build.

L3_APP_CODE_OFF      equ 512
L3_SHADOW_WIN_OFF    equ (APP_SLOT_SIZE - 512)
L3_APP_BLOB_COPY_CAP equ L3_SHADOW_WIN_OFF
L3_SLOT_META_OFF     equ 0
L3_SLOT_MAGIC_OFF    equ 0
L3_SLOT_TERM_CTX_OFF equ 160
L3_SLOT_USER_STACK_TOP equ (L3_SHADOW_WIN_OFF - 16)
TERM_CTX_X           equ 160
TERM_CTX_Y           equ 168
TERM_CTX_W           equ 176
TERM_CTX_H           equ 184
L3_SLOT_MAGIC        equ 0x30544F4C5358414E

%if L3_APP_BLOB_COPY_CAP > L3_SHADOW_WIN_OFF
%error "L3 app blob copy cap must stay below the shadow/window/stack area"
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

; l3_user_stack_top - EDI=slot -> RAX=top of user stack
FN_BEGIN l3_user_stack_top, 0, 0, FN_RET_SCALAR
    mov eax, edi
    imul rax, L3_USER_STACK_SIZE
    mov rdx, [rel l3_app_arena_base_v]
    imul rcx, rdi, APP_SLOT_SIZE
    add rdx, rcx
    add rdx, L3_SLOT_USER_STACK_TOP
    sub rdx, L3_USER_STACK_SIZE
    mov rax, rdx
    add rax, L3_USER_STACK_SIZE
    and rax, -16
    ret

; l3_syscall_stack_top - EDI=slot -> RAX=top of syscall stack
FN_BEGIN l3_syscall_stack_top, 0, 0, FN_RET_SCALAR
    mov eax, edi
    imul rax, L3_SYSCALL_STACK_SIZE
    lea rdx, [rel l3_syscall_stacks]
    add rax, rdx
    add rax, L3_SYSCALL_STACK_SIZE
    and rax, -16
    ret

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

FN_DECL l3_install_app_done_trampoline, 0, 0, FN_RET_SCALAR
    call l3_slot_base
    add rax, app_l3_done_trampoline - app_blob_start
    ret

; l3_copy_app_blob_to_slot - copy the built-in user blob into a slot arena
; EDI = slot
FN_BEGIN l3_copy_app_blob_to_slot, 0, 0, FN_RET_SCALAR
    push rcx
    push rdi
    push rsi
    push r8
    call l3_slot_base
    mov r8, rax
    mov rdi, rax
    mov rsi, [rel app_blob_base_v]
    mov rcx, [rel app_blob_size_v]
    cmp rcx, L3_APP_BLOB_COPY_CAP
    jbe .copy_len_ok
    mov rcx, L3_APP_BLOB_COPY_CAP
.copy_len_ok:
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
FN_BEGIN l3_slot_resolve_app_ptr, 0, 0, FN_RET_SCALAR
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
    add rdx, [rel l3_app_arena_base_v]
    add rax, rdx
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

    sub rax, r8
    add rax, rsi
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
    and rax, APP_SLOT_SIZE - 1
    cmp rax, [rel app_blob_size_v]
    jae .translate_original
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
    cmp [rax + L3_SLOT_MAGIC_OFF], rdx
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
    rep movsq
    mov rax, [r12 + L3_RT_APP_BASE]
    mov [rdi - WINDOW_STRUCT_SIZE + WIN_OFF_APPDATA], rax
.shadow_ready:
    mov rax, [r12 + L3_RT_APP_BASE]
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

    ; Restrict the arena so only this slot's pages are ring-3 accessible.
    mov edi, r11d
    call l3_apply_slot_isolation

    mov edi, r11d
    call l3_user_stack_top
    sub rax, 8
    push rax
    mov edi, r11d
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
alignb 4096
global l3_syscall_stacks
l3_syscall_stacks:   resb (MAX_WINDOWS * L3_SYSCALL_STACK_SIZE)
alignb 16
global l3_runtime
; Keep this in sync with L3_RT_SIZE above. A smaller allocation corrupts
; adjacent state as soon as multiple ring-3 callbacks run.
l3_runtime:          resb (MAX_WINDOWS * L3_RT_SIZE)

section .text
