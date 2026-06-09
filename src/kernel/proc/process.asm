; ============================================================================
; NexusOS v3.0 - Process Management & Scheduler
; ============================================================================
bits 64

%include "constants.inc"
%include "structs.inc"
%include "macros.inc"
%include "smap.inc"

; MAX_PROCESSES and PROCESS_POOL now live in constants.inc so workqueue.asm
; can bill cycles into the same PCB table without redefining them.

GDT64_CODE_SEG    equ 0x08
GDT64_DATA_SEG    equ 0x10
GDT64_USER_DATA   equ 0x23
GDT64_USER_CODE   equ 0x2B

section .text

; auto-wrapped (FN_BEGIN emits global): global scheduler_init
; auto-wrapped (FN_BEGIN emits global): global process_create
; auto-wrapped (FN_BEGIN emits global): global process_schedule
global current_process_id
; auto-wrapped (FN_BEGIN emits global): global proc_is_active
; auto-wrapped (FN_BEGIN emits global): global process_save_context
; auto-wrapped (FN_BEGIN emits global): global process_restore_context
; auto-wrapped (FN_BEGIN emits global): global process_kill_window
global process_find_by_window

extern l3_user_stack_top
extern l3_syscall_stack_top
extern tss64
extern tick_count

; --- scheduler_init ---
FN_BEGIN scheduler_init, 0, 0, FN_RET_SCALAR
    push rdi
    push rcx
    push rax
    push rbx
    
    ; Clear process pool
    mov rdi, PROCESS_POOL
    xor eax, eax
    mov ecx, (MAX_PROCESSES * 512) / 4
    rep stosd
    
    ; Initialize Kernel Process (PID 0)
    mov rbx, PROCESS_POOL
    mov dword [rbx + process_t.id], 0
    mov dword [rbx + process_t.state], 2 ; RUNNING
    mov qword [rbx + process_t.rflags], 0x202
    mov qword [rbx + process_t.cs], GDT64_CODE_SEG
    mov qword [rbx + process_t.ss], GDT64_DATA_SEG
    mov qword [rbx + process_t.kernel_rsp], 0x200000
    ; Kernel may run on any core; pinned to core 0 in practice (the BSP).
    mov dword [rbx + process_t.affinity_mask], 0xFFFFFFFF
    mov dword [rbx + process_t.home_core], 0
    mov qword [rbx + process_t.cpu_time_cycles], 0
    
    mov dword [current_process_id], 0
    mov dword [next_pid], 1
    
    pop rbx
    pop rax
    pop rcx
    pop rdi
    ret

; --- process_create ---
; RDI = Entry Point (RIP)
; RSI = Slot (App Arena / Stack index)
; RDX = Window ID
; Returns: RAX = Process ID or -1
FN_BEGIN process_create, 0, 0, FN_RET_SCALAR
    push rbx
    push rcx
    push rdx
    push rdi
    push rsi
    push r12
    push r13
    push r14
    
    mov r12, rdi        ; entry
    mov r13, rsi        ; slot
    mov r14, rdx        ; win_id

    cmp r13, MAX_WINDOWS
    jae .invalid_args
    cmp r14, MAX_WINDOWS
    jae .invalid_args
    
    ; Find free slot in process pool
    mov rbx, PROCESS_POOL
    xor ecx, ecx
.find_loop:
    cmp dword [rbx + process_t.state], 0 ; EMPTY = 0
    je .found
    add rbx, 512
    inc ecx
    cmp ecx, MAX_PROCESSES
    jl .find_loop
    mov rax, -1
    jmp .done
    
.found:
    ; Initialize PCB
    mov eax, [next_pid]
    inc dword [next_pid]
    mov [rbx + process_t.id], eax
    mov [rbx + process_t.state], dword 1 ; READY = 1
    mov [rbx + process_t.rip], r12
    mov [rbx + process_t.slot], r13d
    mov [rbx + process_t.win_id], r14d
    
    ; Setup Stacks
    mov edi, r13d
    call l3_user_stack_top
    sub rax, 8
    extern call_app_l3_app_done
    lea rdx, [rel call_app_l3_app_done]
    USER_ACCESS_BEGIN
    mov qword [rax], rdx          ; IRET trampoline onto the slot's user stack (PTE.U=1)
    USER_ACCESS_END
    mov [rbx + process_t.rsp], rax
    
    mov edi, r13d
    call l3_syscall_stack_top
    mov [rbx + process_t.kernel_rsp], rax
    
    ; Setup Selectors and RFLAGS
    mov qword [rbx + process_t.cs], GDT64_USER_CODE
    mov qword [rbx + process_t.ss], GDT64_USER_DATA
    mov qword [rbx + process_t.rflags], 0x202

    ; Default affinity: any non-system core. Stage 1 only records this;
    ; Stage 2 will honor it when dispatching to APs. Pick a home core now
    ; via the auto-placer so task manager has something stable to display.
    mov dword [rbx + process_t.affinity_mask], SMP_APP_CORE_MASK
    mov qword [rbx + process_t.cpu_time_cycles], 0
    push rdi
    mov edi, SMP_APP_CORE_MASK
    call process_auto_pick_core        ; RAX = chosen core index
    pop rdi
    mov [rbx + process_t.home_core], eax

    mov rax, [rbx + process_t.id]

.done:
    pop r14
    pop r13
    pop r12
    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    ret

.invalid_args:
    mov rax, -1
    jmp .done


; --- current_process_ptr ---
; Returns: RAX = pointer to current process PCB
current_process_ptr:
    mov eax, [current_process_id]
    cmp eax, -1
    je .no_proc
    imul rax, rax, 512
    add rax, PROCESS_POOL
    ret
.no_proc:
    xor rax, rax
    ret

; --- process_save_context ---
; RDI = pointer to PUSH_ALL frame (RSP after PUSH_ALL)
FN_BEGIN process_save_context, 0, 0, FN_RET_SCALAR
    push rax
    push rbx
    push rcx
    
    call current_process_ptr
    test rax, rax
    jz .done
    
    mov rbx, rax    ; rbx = PCB
    
    ; Save GP registers from stack frame
    mov rcx, [rdi + ALL_RAX]
    mov [rbx + process_t.rax], rcx
    mov rcx, [rdi + ALL_RBX]
    mov [rbx + process_t.rbx], rcx
    mov rcx, [rdi + ALL_RCX]
    mov [rbx + process_t.rcx], rcx
    mov rcx, [rdi + ALL_RDX]
    mov [rbx + process_t.rdx], rcx
    mov rcx, [rdi + ALL_RSI]
    mov [rbx + process_t.rsi], rcx
    mov rcx, [rdi + ALL_RDI]
    mov [rbx + process_t.rdi], rcx
    mov rcx, [rdi + ALL_RBP]
    mov [rbx + process_t.rbp], rcx
    mov rcx, [rdi + ALL_R8]
    mov [rbx + process_t.r8], rcx
    mov rcx, [rdi + ALL_R9]
    mov [rbx + process_t.r9], rcx
    mov rcx, [rdi + ALL_R10]
    mov [rbx + process_t.r10], rcx
    mov rcx, [rdi + ALL_R11]
    mov [rbx + process_t.r11], rcx
    mov rcx, [rdi + ALL_R12]
    mov [rbx + process_t.r12], rcx
    mov rcx, [rdi + ALL_R13]
    mov [rbx + process_t.r13], rcx
    mov rcx, [rdi + ALL_R14]
    mov [rbx + process_t.r14], rcx
    mov rcx, [rdi + ALL_R15]
    mov [rbx + process_t.r15], rcx
    
    ; Save RIP, CS, RFLAGS, RSP, SS from interrupt frame
    mov rcx, [rdi + 136] ; RIP
    mov [rbx + process_t.rip], rcx
    mov rcx, [rdi + 144] ; CS
    mov [rbx + process_t.cs], rcx
    mov rcx, [rdi + 152] ; RFLAGS
    mov [rbx + process_t.rflags], rcx
    mov rcx, [rdi + 160] ; RSP
    mov [rbx + process_t.rsp], rcx
    mov rcx, [rdi + 168] ; SS
    mov [rbx + process_t.ss], rcx
    
.done:
    pop rcx
    pop rbx
    pop rax
    ret

; --- process_restore_context ---
; RDI = pointer to PUSH_ALL frame to OVERWRITE
FN_BEGIN process_restore_context, 0, 0, FN_RET_SCALAR
    push rax
    push rbx
    push rcx
    
    call current_process_ptr
    test rax, rax
    jz .done
    
    mov rbx, rax ; PCB
    
    ; Restore GP registers to stack frame
    mov rcx, [rbx + process_t.rax]
    mov [rdi + ALL_RAX], rcx
    mov rcx, [rbx + process_t.rbx]
    mov [rdi + ALL_RBX], rcx
    mov rcx, [rbx + process_t.rcx]
    mov [rdi + ALL_RCX], rcx
    mov rcx, [rbx + process_t.rdx]
    mov [rdi + ALL_RDX], rcx
    mov rcx, [rbx + process_t.rsi]
    mov [rdi + ALL_RSI], rcx
    mov rcx, [rbx + process_t.rdi]
    mov [rdi + ALL_RDI], rcx
    mov rcx, [rbx + process_t.rbp]
    mov [rdi + ALL_RBP], rcx
    mov rcx, [rbx + process_t.r8]
    mov [rdi + ALL_R8], rcx
    mov rcx, [rbx + process_t.r9]
    mov [rdi + ALL_R9], rcx
    mov rcx, [rbx + process_t.r10]
    mov [rdi + ALL_R10], rcx
    mov rcx, [rbx + process_t.r11]
    mov [rdi + ALL_R11], rcx
    mov rcx, [rbx + process_t.r12]
    mov [rdi + ALL_R12], rcx
    mov rcx, [rbx + process_t.r13]
    mov [rdi + ALL_R13], rcx
    mov rcx, [rbx + process_t.r14]
    mov [rdi + ALL_R14], rcx
    mov rcx, [rbx + process_t.r15]
    mov [rdi + ALL_R15], rcx
    
    ; Restore interrupt frame
    mov rcx, [rbx + process_t.rip]
    mov [rdi + 136], rcx
    mov rcx, [rbx + process_t.cs]
    mov [rdi + 144], rcx
    mov rcx, [rbx + process_t.rflags]
    mov [rdi + 152], rcx
    mov rcx, [rbx + process_t.rsp]
    mov [rdi + 160], rcx
    mov rcx, [rbx + process_t.ss]
    mov [rdi + 168], rcx

    ; Update TSS.RSP0
    lea rcx, [tss64]
    mov rdx, [rbx + process_t.kernel_rsp]
    mov [rcx + 4], rdx
    mov rdx, [rbx + process_t.cr3]
    test rdx, rdx
    jz .skip_cr3
    mov cr3, rdx
.skip_cr3:
    
.done:
    pop rcx
    pop rbx
    pop rax
    ret

; --- process_schedule ---
; Round-Robin Scheduler
; Returns: RAX = next PID, or -1 if none
FN_BEGIN process_schedule, 0, 0, FN_RET_SCALAR
    push rbx
    push rcx
    
    mov eax, [current_process_id]
    mov ecx, eax
    
.search:
    inc ecx
    and ecx, (MAX_PROCESSES - 1)
    
    cmp ecx, [current_process_id] ; Full circle?
    je .not_found_other
    
    imul rbx, rcx, 512
    add rbx, PROCESS_POOL
    cmp dword [rbx + process_t.state], 1 ; READY
    je .found
    jmp .search

.not_found_other:
    ; Check if current is still running/ready
    mov ecx, [current_process_id]
    cmp ecx, -1
    je .no_procs
    imul rbx, rcx, 512
    add rbx, PROCESS_POOL
    cmp dword [rbx + process_t.state], 1 ; READY
    je .found
    cmp dword [rbx + process_t.state], 2 ; RUNNING
    je .found

.no_procs:
    mov rax, -1
    jmp .done

.found:
    ; Mark old as READY if it was RUNNING
    mov eax, [current_process_id]
    cmp eax, -1
    je .skip_old
    imul rax, rax, 512
    add rax, PROCESS_POOL
    cmp dword [rax + process_t.state], 2 ; RUNNING
    jne .skip_old
    mov dword [rax + process_t.state], 1 ; set READY
.skip_old:

    mov [current_process_id], ecx
    imul rax, rcx, 512
    add rax, PROCESS_POOL
    mov dword [rax + process_t.state], 2 ; set RUNNING
    
    mov rax, rcx

.done:
    pop rcx
    pop rbx
    ret

FN_BEGIN proc_is_active, 0, 0, FN_RET_SCALAR
    ; EDI = PID
    push rbx
    mov rax, rdi
    imul rax, 512
    add rax, PROCESS_POOL
    mov eax, [rax + process_t.state]
    cmp eax, 0 ; EMPTY
    setne al
    movzx eax, al
    pop rbx
    ret

FN_BEGIN process_kill_window, 0, 0, FN_RET_SCALAR
    push rax
    push rbx
    push rcx
    xor ecx, ecx
.pkw_loop:
    cmp ecx, MAX_PROCESSES
    jge .pkw_done
    imul rbx, rcx, 512
    add rbx, PROCESS_POOL
    cmp dword [rbx + process_t.state], 0
    je .pkw_next
    cmp dword [rbx + process_t.win_id], edi
    jne .pkw_next
    mov dword [rbx + process_t.state], 4
    cmp dword [current_process_id], ecx
    jne .pkw_done
    mov dword [current_process_id], 0
    mov dword [abs PROCESS_POOL + process_t.state], 2
    jmp .pkw_done
.pkw_next:
    inc ecx
    jmp .pkw_loop
.pkw_done:
    pop rcx
    pop rbx
    pop rax
    ret

; ============================================================================
; Stage 1 SMP placement helpers
; ============================================================================
; These manage *which core* a process is permitted to run on, and pick a good
; home core from a given mask. They do not (yet) move execution between cores;
; dispatching is added in Stage 2. Until then `home_core` is informational and
; surfaces in task manager so we can see the placer's intent.
;
; Mask convention: bit i set <=> core i permitted. System cores (mask
; SMP_SYSTEM_CORE_MASK) are stripped from any app mask before placement so a
; misbehaving app can never request core 0 or 1.
; ============================================================================

extern smp_alive_cores

; --- process_auto_pick_core ---------------------------------------------------
; Input:  EDI = requested affinity mask (bit i set => core i permitted)
; Output: RAX = chosen core index, or 0 if no core in mask is alive
;
; Strategy: among cores that are (a) alive, (b) permitted by the masked-down
; affinity, pick the one with the lowest currently-published utilization
; (smp_core_states + offset 24). Ties go to the lowest core index. The mask is
; pre-filtered against SMP_SYSTEM_CORE_MASK so cores 0/1 are never returned
; for app placement; if the request was system-only, fall back to core 0.
process_auto_pick_core:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    mov esi, edi                       ; esi = raw requested mask
    and esi, ~SMP_SYSTEM_CORE_MASK     ; strip system cores for app placement
    jnz .mask_ok
    ; Caller asked for only system cores (or empty mask): hand back core 0.
    xor eax, eax
    jmp .ret

.mask_ok:
    mov ecx, [smp_alive_cores]
    test ecx, ecx
    jnz .have_cores
    xor eax, eax                       ; SMP not up; fall back to BSP
    jmp .ret

.have_cores:
    cmp ecx, SMP_MAX_CORES
    jbe .cores_capped
    mov ecx, SMP_MAX_CORES
.cores_capped:
    xor edi, edi                       ; edi = scan index
    mov eax, -1                        ; eax = best core (-1 = none)
    mov edx, 0x7FFFFFFF                ; edx = best util seen

.scan:
    cmp edi, ecx
    jae .scan_done
    ; Permitted by mask? bit = 1 << edi
    push rcx
    mov ecx, edi
    mov ebx, 1
    shl ebx, cl
    pop rcx
    test ebx, esi
    jz .next
    ; Look up this core's utilization in smp_core_states.
    mov r9d, edi
    imul r9d, SMP_CORE_STATE_SIZE
    mov r10d, [smp_core_states + r9 + 24]
    cmp r10d, edx
    jae .next
    mov edx, r10d
    mov eax, edi
.next:
    inc edi
    jmp .scan

.scan_done:
    cmp eax, -1
    jne .ret
    ; No alive core in mask (e.g. only core 0 alive, app mask excluded it).
    ; Pick the lowest mask bit anyway; Stage 2 will redirect if impossible.
    bsf eax, esi
    jnc .ret
    xor eax, eax

.ret:
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

; --- process_set_affinity -----------------------------------------------------
; Input:  EDI = PID, ESI = requested mask
; Output: RAX = applied mask, or -1 if PID invalid / dead
;
; The applied mask is the request AND-ed with NOT(SMP_SYSTEM_CORE_MASK): apps
; can broaden across worker cores but can never request a system core. If
; this masks to zero, the call is rejected (-1) instead of silently leaving
; the process unrunnable.
global process_set_affinity
process_set_affinity:
    push rbx
    cmp edi, MAX_PROCESSES
    jae .bad
    mov eax, edi
    imul rax, 512
    add rax, PROCESS_POOL
    mov rbx, rax
    cmp dword [rbx + process_t.state], 0  ; EMPTY?
    je .bad
    mov eax, esi
    and eax, ~SMP_SYSTEM_CORE_MASK
    test eax, eax
    jz .bad
    mov [rbx + process_t.affinity_mask], eax
    ; Re-pick a home core inside the new mask.
    push rdi
    mov edi, eax
    call process_auto_pick_core
    pop rdi
    mov [rbx + process_t.home_core], eax
    mov eax, [rbx + process_t.affinity_mask]
    pop rbx
    ret
.bad:
    mov rax, -1
    pop rbx
    ret

; --- process_submit_job -------------------------------------------------------
; Input:  EDI = PID, RSI = func, RDX = arg, R8d = priority
; Output: RAX = WQ handle (or WQ_INVALID == -1)
;
; Pin a kernel job to a process. The job is queued with target_core =
; PCB.home_core and proc_id = PID, so when the matching AP picks it up the
; cycles it spends will be billed to PROCESS_POOL[PID].cpu_time_cycles. This
; is the path Stage 2c will use to route app-callback execution onto a
; specific AP without anything in this kernel having to know which core is
; "the app core" — that decision was already made when the process was
; created (or last did process_set_affinity).
;
; A PID of 0 (the kernel process) submits with WQ_TARGET_ANY and no billing —
; same semantics as the legacy workqueue_submit.
global process_submit_job
extern workqueue_submit_to
process_submit_job:
    push rbx
    cmp edi, MAX_PROCESSES
    jae .bad
    test edi, edi
    jnz .have_app
    ; PID 0: route as a generic any-core job.
    mov rdi, rsi                    ; func
    mov rsi, rdx                    ; arg
    mov edx, r8d                    ; priority
    mov r8d, -1                     ; WQ_TARGET_ANY
    xor r9d, r9d                    ; no billing
    call workqueue_submit_to
    pop rbx
    ret
.have_app:
    mov eax, edi
    imul rax, 512
    add rax, PROCESS_POOL
    mov rbx, rax
    cmp dword [rbx + process_t.state], 0
    je .bad
    mov r9d, edi                    ; proc_id to bill
    mov r10d, [rbx + process_t.home_core]
    mov rdi, rsi                    ; func
    mov rsi, rdx                    ; arg
    mov edx, r8d                    ; priority
    mov r8d, r10d                   ; target_core
    call workqueue_submit_to
    pop rbx
    ret
.bad:
    mov rax, -1
    pop rbx
    ret

; --- process_get_cpu_time -----------------------------------------------------
; Input:  EDI = PID
; Output: RAX = cpu_time_cycles, or 0 if PID invalid / empty
global process_get_cpu_time
process_get_cpu_time:
    cmp edi, MAX_PROCESSES
    jae .bad
    mov eax, edi
    imul rax, 512
    add rax, PROCESS_POOL
    cmp dword [rax + process_t.state], 0
    je .bad
    mov rax, [rax + process_t.cpu_time_cycles]
    ret
.bad:
    xor eax, eax
    ret

; --- process_find_by_window ---------------------------------------------------
; Input:  EDI = window id
; Output: EAX = PID (>=1) of the process owning that window, or 0 if none
;
; Scans the PCB pool for a non-empty entry with .win_id == edi. The global
; symbol has been declared since v3.0 but the body was previously empty; Stage 2c needs
; it to look up an app's PCB (and thus its home_core / cpu_time_cycles) from
; the window event being delivered.
process_find_by_window:
    push rbx
    push rcx
    mov ecx, 1                         ; PID 0 is the kernel; skip it
.scan:
    cmp ecx, MAX_PROCESSES
    jae .none
    mov eax, ecx
    imul rax, 512
    add rax, PROCESS_POOL
    mov rbx, rax
    cmp dword [rbx + process_t.state], 0
    je .next
    cmp dword [rbx + process_t.win_id], edi
    jne .next
    mov eax, ecx
    pop rcx
    pop rbx
    ret
.next:
    inc ecx
    jmp .scan
.none:
    xor eax, eax
    pop rcx
    pop rbx
    ret

; --- dispatch_app_callback ---------------------------------------------------
;
; Stage 2d is active whenever the build defines `NEXUS_ENABLE_RING3_AP`.
; Profiles that start AP workers define it so app callbacks run on each
; process home_core instead of tail-calling call_app_l3 on the BSP.
;
; The active path below looks up the PCB, takes the global
; app_callback_lock, submit the packed thunk to the PCB's home_core, wait
; with a 200 ms budget. On timeout the ring3_ap_enabled flag is cleared and
; every subsequent callback this boot goes straight to inline — at most one
; callback ever suffers the timeout penalty.
;
; The compile-time fallback remains for single-core/non-AP profiles.
; Input:  RDI = target function, RSI = window pointer (or 0 = no window),
;         RDX = arg1, RCX = arg2
; Output: RAX = callback return value
;
; Decision tree:
;   * no window, no PCB, home_core == 0 (BSP), or no APs alive
;       -> run call_app_l3 inline on the BSP (legacy behavior).
;   * else
;       -> acquire the global app_callback_lock,
;          pack args into app_callback_pack,
;          submit the packed thunk via process_submit_job(pid, ...),
;          workqueue_wait for it,
;          release the lock.
;
; The lock serialises ring-3 callbacks system-wide because call_app_l3 calls
; l3_apply_slot_isolation which rewrites the shared arena PTEs and flushes
; CR3. Two cores doing that concurrently for different slots would race the
; shared page table. With the lock there is at most one ring-3 callback in
; flight, so the AP can rewrite PTEs and self-flush its TLB safely. The
; throughput cost is real (no concurrent app code across cores) and will be
; recovered in a future stage by moving to per-CPU CR3 or static isolation.
;
; If workqueue_submit returns WQ_INVALID (queue full), we release the lock
; and fall back to the inline path so the callback still runs.
extern call_app_l3
extern call_app_l3_packed
extern ser_print_hex64
extern wq_lock

; ---------------------------------------------------------------------------
; cb_run_guarded(rdi=fn, rsi=win, rdx=arg1, rcx=arg2) -> rax = ret (or -1)
;
; The only place call_app_l3 is invoked from dispatch_app_callback's inline
; BSP path. Wraps it with:
;   (B) a reentrancy guard (cb_in_callback): if a callback is already in
;       flight for the BSP, refuse and return -1 instead of double-running
;       (which would clobber the shared cb_rt global + per-slot kernel RSP).
;   (A) a deadman: capture a longjmp landing pad + start tick, arm it, run
;       the callback, disarm on normal return. The PIT IRQ calls
;       cb_deadman_check; on budget overrun it restores rsp/rbx/rbp and jmps
;       to .deadman_land here, marks the slot TERMINATED, returns -1.
;
; BSP-only by construction: dispatch_app_callback only runs the inline path on
; the BSP (the AP-routing path goes through the work queue), so the single
; global landing pad is race-free.
global cb_run_guarded
cb_run_guarded:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15

    ; (B) reentrancy guard ---------------------------------------------------
    cmp dword [rel cb_in_callback], 0
    jne .reenter_refuse
    mov dword [rel cb_in_callback], 1

    mov r12, rdi                       ; fn
    mov r13, rsi                       ; win
    mov r14, rdx                       ; arg1
    mov r15, rcx                       ; arg2

    ; resolve pid for the slot (best-effort; 0 if none) so the deadman can
    ; mark it TERMINATED on a runaway. Reuses process_find_by_window.
    xor ebx, ebx
    test r13, r13
    jz .pid_done
    mov edi, [r13 + WIN_OFF_ID]
    call process_find_by_window
    mov ebx, eax                       ; pid (0 if not found)
.pid_done:
    mov [rel cb_deadman_pid], ebx

    ; (A) arm the deadman: save landing pad + start tick.
    lea rax, [rel .deadman_land]
    mov [rel cb_deadman_jmp_rip], rax
    mov [rel cb_deadman_jmp_rsp], rsp
    mov [rel cb_deadman_jmp_rbx], rbx
    mov [rel cb_deadman_jmp_rbp], rbp
    mov rax, [rel tick_count]
    mov [rel cb_deadman_start_tick], rax
    mov dword [rel cb_deadman_armed], 1

    ; run the callback inline on the BSP.
    mov rdi, r12
    mov rsi, r13
    mov rdx, r14
    mov rcx, r15
    call call_app_l3

    ; normal return: disarm + clear reentrancy lock.
    mov dword [rel cb_deadman_armed], 0
    mov dword [rel cb_in_callback], 0
    jmp .done

.deadman_land:
    ; Reached via cb_deadman_check's jmp after rsp/rbx/rbp were restored to the
    ; values saved above. The runaway callback's stack frame is abandoned.
    mov dword [rel cb_deadman_armed], 0
    ; mark the offending slot's process TERMINATED so it stops being scheduled.
    mov ebx, [rel cb_deadman_pid]
    test ebx, ebx
    jz .land_unlock
    mov eax, ebx
    imul rax, 512
    add rax, PROCESS_POOL
    mov dword [rax + process_t.state], 4   ; TERMINATED
.land_unlock:
    mov dword [rel cb_in_callback], 0
    mov rax, -1                         ; report failure to the main loop
    jmp .done

.reenter_refuse:
    mov rax, -1
.done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

; ---------------------------------------------------------------------------
; cb_deadman_check() -> eax = 1 if a runaway-callback abort is requested, else 0
;
; Called from the timer IRQ handler (isr.asm .irq_timer) AFTER the LAPIC/PIC
; EOI and ONLY when the interrupted CS shows the IRQ came from ring 3. This is
; pure, NON-destructive DETECTION: if a callback is armed and has exceeded its
; tick budget, it marks the slot's PCB TERMINATED, disarms, and returns eax=1 so
; the caller can perform the clean call_app_l3_return unwind on the IRQ frame.
; It must NOT longjmp from interrupt context (that would strand the IRQ stub
; before EOI/iretq). Returns eax=0 (no abort) otherwise. Clobbers rax/rbx.
; The longjmp pad below is kept for reference but is NOT taken here.
global cb_deadman_check
cb_deadman_check:
    xor eax, eax
    cmp dword [rel cb_deadman_armed], 0
    je .nofire
    mov rax, [rel tick_count]
    sub rax, [rel cb_deadman_start_tick]
    cmp eax, [rel cb_deadman_budget]
    jb .no_overrun
    ; over budget: disarm (so we fire once) and mark the runaway slot TERMINATED
    ; so it stops being scheduled. Mirrors .deadman_land's slot->PCB math.
    mov dword [rel cb_deadman_armed], 0
    mov ebx, [rel cb_deadman_pid]
    test ebx, ebx
    jz .request_abort
    mov eax, ebx
    imul rax, 512
    add rax, PROCESS_POOL
    mov dword [rax + process_t.state], 4   ; TERMINATED
.request_abort:
    mov eax, 1                              ; abort requested
    ret
.no_overrun:
    xor eax, eax
.nofire:
    ret

; --- reference-only longjmp path (NOT reachable from IRQ context) ------------
; The original raw `mov rsp; jmp pad` longjmp lived here. It is unsafe from the
; timer IRQ (abandons the stub before EOI+iretq), so the deadman now detects and
; the IRQ stub performs the clean call_app_l3_return unwind instead.
cb_deadman_longjmp_ref:
    mov rbx, [rel cb_deadman_jmp_rbx]
    mov rbp, [rel cb_deadman_jmp_rbp]
    mov rsp, [rel cb_deadman_jmp_rsp]
    jmp [rel cb_deadman_jmp_rip]

extern wq_unlock
extern smp_alive_cores

WIN_OFF_ID equ 0                       ; matches src/include/window_layout.inc

%ifndef NEXUS_ENABLE_RING3_AP
; --- NON-AP BUILD: pass-through to call_app_l3 ------------------------------
; Apps run inline on the BSP when AP routing is not compiled in.
global dispatch_app_callback
dispatch_app_callback:
    jmp cb_run_guarded                 ; deadman + reentrancy-guarded inline run
%else
; --- AP-ROUTING BUILD: route ring-3 callbacks to APs ------------------------
; The AP "presumed dead" wait budget is derived from the inline deadman budget so
; there is ONE timescale knob (cb_deadman_budget). Kept a large multiple, NOT 1x:
; legit synchronous callbacks (~12 s DHCP) must complete on the AP and not get
; misclassified as a dead AP + re-run inline. 60 * ~25 ticks ~= 1500 ticks ~= 15 s.
CB_AP_DEADMAN_MULT equ 60
extern workqueue_wait_timeout
global ring3_ap_enabled
section .data
ring3_ap_enabled: dd 1
section .text

global dispatch_app_callback
dispatch_app_callback:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    mov r12, rdi                       ; target function
    mov r13, rsi                       ; window ptr
    mov r14, rdx                       ; arg1
    mov r15, rcx                       ; arg2
    DBG_EVT EVT_CALLBACK_DISPATCH, 0, r12, r13, r14, r15, 0, 0

    cmp dword [ring3_ap_enabled], 0
    je .inline
    test r13, r13
    jz .inline

    mov edi, [r13 + WIN_OFF_ID]
    call process_find_by_window
    test eax, eax
    jz .inline
    mov ebx, eax                       ; pid

    mov eax, ebx
    imul rax, 512
    add rax, PROCESS_POOL
    mov ecx, [rax + process_t.home_core]
    test ecx, ecx
    jz .inline

    mov eax, [smp_alive_cores]
    cmp eax, 2
    jb .inline

    lea rdi, [rel app_callback_lock]
    call wq_lock

    lea rdi, [rel app_callback_pack]
    mov [rdi + 0],  r12
    mov [rdi + 8],  r13
    mov [rdi + 16], r14
    mov [rdi + 24], r15

    mov edi, ebx
    lea rsi, [rel call_app_l3_packed]
    lea rdx, [rel app_callback_pack]
    mov r8d, 1
    call process_submit_job
    cmp eax, -1
    je .submit_fail

    mov edi, eax
    ; Wait budget = "is the AP dead?", NOT "is the callback slow?". The old
    ; 200 ms budget misclassified legitimately-slow callbacks (a DHCP click runs
    ; the synchronous rtl8156_dhcp_configure, which blocks for SECONDS waiting on
    ; OFFER/ACK + tick timeouts) as a dead AP, then re-ran the SAME callback
    ; inline on the BSP via .timed_out while the AP was STILL executing it. Two
    ; concurrent call_app_l3 invocations for one slot clobber the shared cb_rt
    ; global + the per-slot saved kernel RSP, so the ring-3 return restored a
    ; smashed RSP and #PF'd at a stale RIP (the '!T' -> RIP=0x170 / RSP in the
    ; trampoline-stack region crash). Budget must stay large enough that any real
    ; callback (incl. worst-case ~12 s sync DHCP) completes on the AP and takes
    ; the safe normal return below; only a genuinely hung AP reaches the inline
    ; fallback, where double execution can't happen because the AP is gone.
    ;
    ; This budget is DELIBERATELY NOT the deadman budget: a 250 ms slam here would
    ; re-introduce the double-run/RSP-smash bug for slow-but-valid callbacks. So we
    ; derive it as a large multiple of cb_deadman_budget (CB_AP_DEADMAN_MULT) — the
    ; relationship is now explicit (one knob, cb_deadman_budget) instead of a magic
    ; 1500 — while still landing near ~15 s. The ACTUAL runaway protection comes
    ; from the deadman + reentrancy guard on the inline re-run at .inline (which
    ; goes through cb_run_guarded), so a hung AP callback is killed on the ~250 ms
    ; deadman timescale once it falls back, not after a bare 15 s.
    mov esi, [rel cb_deadman_budget]   ; ~25 ticks
    imul esi, esi, CB_AP_DEADMAN_MULT  ; 60x -> ~1500 ticks (~15 s) "AP dead" budget
    call workqueue_wait_timeout
    test edx, edx
    jnz .timed_out

    push rax
    lea rdi, [rel app_callback_lock]
    call wq_unlock
    pop rax
    jmp .ret

.timed_out:
    push rax
    push rdx
    mov dx, 0x3F8
    mov al, '!'
    out dx, al
    mov al, 'T'
    out dx, al
    pop rdx
    pop rax
    mov dword [ring3_ap_enabled], 0    ; auto-disable for the rest of the boot
    lea rdi, [rel app_callback_lock]
    call wq_unlock
    ; The AP that owns this job is presumed dead (a draw/click callback should
    ; never take >200 ms), so it will not double-run the stale job. Run the
    ; callback inline now instead of returning without drawing — otherwise the
    ; window paints only its blank background (a white window) for this frame.
    jmp .inline

.submit_fail:
    lea rdi, [rel app_callback_lock]
    call wq_unlock

.inline:
    mov rdi, r12
    mov rsi, r13
    mov rdx, r14
    mov rcx, r15
    call cb_run_guarded                ; deadman + reentrancy-guarded inline run
    DBG_EVT EVT_CALLBACK_RETURN, 0, rax, r12, r13, r14, r15, 0
%ifdef ENABLE_DEBUG_SERIAL
    push rax
    push rcx
    push rdx
    push rdi
    SER 'D'
    SER 'R'
    SER 'E'
    SER 'T'
    SER ' '
    SER 'a'
    mov rdi, [rsp + 24]                 ; callback return value
    call ser_print_hex64
    SER ' '
    SER 'p'
    lea rdi, [rsp + 32]                 ; dispatch_app_callback rsp before pushes
    call ser_print_hex64
    SER ' '
    SER 'b'
    mov rdi, rbp
    call ser_print_hex64
    SER ' '
    SER 'c'
    mov rdi, [rsp + 32]                 ; local pad / frame low qword
    call ser_print_hex64
    SER '/'
    mov rdi, [rsp + 40]                 ; saved r15
    call ser_print_hex64
    SER '/'
    mov rdi, [rsp + 48]                 ; saved r14
    call ser_print_hex64
    SER '/'
    mov rdi, [rsp + 56]                 ; saved r13
    call ser_print_hex64
    SER '/'
    mov rdi, [rsp + 64]                 ; saved r12
    call ser_print_hex64
    SER '/'
    mov rdi, [rsp + 72]                 ; saved rbx
    call ser_print_hex64
    SER ' '
    SER 'r'
    mov rdi, r12
    call ser_print_hex64
    SER '/'
    mov rdi, r13
    call ser_print_hex64
    SER '/'
    mov rdi, r14
    call ser_print_hex64
    SER '/'
    mov rdi, r15
    call ser_print_hex64
    SER 13
    SER 10
    pop rdi
    pop rdx
    pop rcx
    pop rax
%endif

.ret:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
%endif

; --- media_draw_dispatch ------------------------------------------------------
; Route the kernel-side Media Player draw fn (app_media_draw) onto the owning
; app's home_core AP instead of running it inline on the BSP. Without this the
; video blit always runs on core 0, and two playing videos saturate the BSP and
; freeze the GUI.
;
; app_media_draw is NOT a ring-3 callback (it runs in kernel context and writes
; the shared backbuffer directly), so it cannot go through dispatch_app_callback
; / call_app_l3. Instead we submit it as a kernel work-queue job pinned to the
; process's home_core and block until it completes. The BSP is idle during the
; wait, so only one core ever writes the backbuffer at a time and no fb lock is
; needed. A 200 ms timeout falls back to inline (and disables AP routing for the
; rest of the boot) so a wedged AP can never freeze the OS.
;
; Input:  RDI = window struct ptr
; Output: none (drop-in replacement for the inline `call app_media_draw`)
extern app_media_draw
%ifndef NEXUS_ENABLE_RING3_AP
global media_draw_dispatch
media_draw_dispatch:
    jmp app_media_draw
%else
global media_draw_dispatch
media_draw_dispatch:
    push rbp
    mov rbp, rsp
    push rbx
    push r12                           ; 3 pushes -> rsp 16-aligned at calls
    mov r12, rdi                       ; window ptr

    cmp dword [ring3_ap_enabled], 0
    je .inline
    mov eax, [smp_alive_cores]
    cmp eax, 2
    jb .inline

    mov edi, [r12 + WIN_OFF_ID]
    call process_find_by_window
    test eax, eax
    jz .inline
    mov ebx, eax                       ; pid

    mov eax, ebx
    imul rax, 512
    add rax, PROCESS_POOL
    mov ecx, [rax + process_t.home_core]
    test ecx, ecx
    jz .inline

    mov edi, ebx                       ; pid
    mov rsi, app_media_draw            ; func
    mov rdx, r12                       ; arg = window ptr
    mov r8d, 1                         ; WQ_PRIO_NORMAL
    call process_submit_job
    cmp eax, -1
    je .inline
    mov edi, eax
    ; Same "slow != dead" fix as the generic dispatch path above: a 200 ms budget
    ; misreads a legitimately-slow AP draw as a dead AP and re-runs it inline while
    ; the AP is still executing it (double call_app_l3 -> kernel-RSP smash). Wait
    ; long enough that only a genuinely hung AP trips the inline fallback.
    mov esi, 1500                      ; 1500 ticks = ~15 s "AP presumed dead" budget
    call workqueue_wait_timeout
    test edx, edx
    jnz .timed_out
    jmp .ret

.timed_out:
    mov dword [ring3_ap_enabled], 0    ; auto-disable AP routing this boot
    ; The AP owning this job is presumed dead (a draw should never take 200 ms),
    ; so it will not double-run; draw inline now so the frame still paints.
.inline:
    mov rdi, r12
    call app_media_draw
.ret:
    pop r12
    pop rbx
    pop rbp
    ret
%endif

; --- app_callback_lock --------------------------------------------------------
; Global spinlock that Stage 2d will hold around any cross-core ring-3 callback
; dispatch. Defined in .data below; declared global so usermode.asm and any
; future routing site can take it via wq_lock / wq_unlock.

; --- process_get_affinity -----------------------------------------------------
; Input:  EDI = PID
; Output: EAX = affinity mask (0 if PID invalid)
global process_get_affinity
process_get_affinity:
    cmp edi, MAX_PROCESSES
    jae .bad
    mov eax, edi
    imul rax, 512
    add rax, PROCESS_POOL
    cmp dword [rax + process_t.state], 0
    je .bad
    mov eax, [rax + process_t.affinity_mask]
    ret
.bad:
    xor eax, eax
    ret

section .data
global current_process_id
current_process_id: dd -1
next_pid:           dd 0

; ---------------------------------------------------------------------------
; Ring-3 callback deadman + reentrancy guard (BSP-only).
;
; dispatch_app_callback runs an app's click/draw handler inline on the BSP via
; call_app_l3. A `while(1){}` in that handler used to hang the whole OS. The
; deadman lets the PIT IRQ (which keeps firing on the BSP) longjmp back out of
; a runaway callback after a tick budget, mark the slot TERMINATED, and return
; -1 so the main loop survives.
;
; Globals exported for pit.asm / other code:
;   cb_deadman_armed       dd  0/1  - a callback is in flight & armed
;   cb_deadman_start_tick  dq       - tick_count when call_app_l3 was entered
;   cb_deadman_budget      dd       - tick budget (~250 ms @ ~100 Hz = 25)
;   cb_in_callback         dd  0/1  - reentrancy lock (refuse double-run)
;   cb_deadman_pid         dd       - pid of the slot being run (for fault mark)
;   cb_deadman_check       fn       - pit calls this; longjmps if over budget
align 64
global cb_deadman_armed
global cb_deadman_start_tick
global cb_deadman_budget
global cb_in_callback
global cb_deadman_pid
cb_deadman_armed:       dd 0
cb_in_callback:         dd 0
cb_deadman_pid:         dd 0
cb_deadman_budget:      dd 25            ; ~250 ms at the ~100 Hz PIT tick
cb_deadman_start_tick:  dq 0
; longjmp landing pad: kernel context captured just before call_app_l3.
cb_deadman_jmp_rsp:     dq 0
cb_deadman_jmp_rbx:     dq 0
cb_deadman_jmp_rbp:     dq 0
cb_deadman_jmp_rip:     dq 0

align 64
global app_callback_lock
; Lock word for Stage 2c/2d cross-core ring-3 callback dispatch. 0 = free,
; 1 = held. Acquired via wq_lock / wq_unlock. Sits on its own cache line so
; the holder doesn't false-share with neighbouring state.
app_callback_lock:  dd 0
times 60 db 0

align 64
global app_callback_pack
; 32-byte packed-args block for cross-core ring-3 callback dispatch.
; Protected by app_callback_lock (only one callback in flight at a time, so
; this buffer is never accessed concurrently). Layout matches what
; call_app_l3_packed expects:
;   [0]  = target function
;   [8]  = window ptr
;   [16] = arg1
;   [24] = arg2
app_callback_pack:  times 32 db 0
times 32 db 0                          ; pad to a full cache line
