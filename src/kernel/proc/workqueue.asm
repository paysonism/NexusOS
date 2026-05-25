; ============================================================================
; NexusOS v3.0 - SMP Work Queue (worker-core offload)
; ----------------------------------------------------------------------------
; PURPOSE
;   Keeps the GUI responsive when an app does something expensive (SVG
;   rasterisation, image decode, layout). The boot CPU (BSP) hands such work
;   to the Application Processors (APs) as "jobs". The BSP keeps rendering at
;   full speed while an AP crunches the job on another core.
;
;   After bring-up an AP no longer parks in HLT (see apic.asm trampoline) - it
;   jumps into smp_worker_loop and pulls jobs from this queue forever.
;
; CONCURRENCY MODEL
;   * One producer  : the BSP - calls workqueue_submit / reap / wait.
;   * N consumers    : the APs - each runs smp_worker_loop.
;   * A job slot is claimed lock-free with `lock cmpxchg` on its status word,
;     so there is NO global lock: a slow or dead AP can never stall the BSP,
;     and two APs can never run the same job.
;   * Each slot is its own 64-byte cache line, so cores claiming different
;     slots do not ping-pong a shared line (no false sharing).
;
; JOB CONTRACT - a function submitted as a job MUST:
;   * Be trusted kernel code. Jobs are never submitted from usermode, so the
;     function pointer is always a kernel address - never make this a syscall.
;   * Take exactly one argument in RDI and return a scalar result in RAX.
;   * Follow the SysV ABI: preserve RBX, RBP, R12-R15 (the worker loop relies
;     on this to keep its bookkeeping registers across the call).
;   * Do bounded work. APs receive no timer IRQs, so a job runs to completion;
;     a job that loops forever permanently consumes one AP - but never the BSP,
;     so the GUI keeps running regardless. Job PRIORITY (WQ_PRIO_* below) exists
;     so a flood of cheap app jobs cannot starve system-critical jobs: workers
;     always claim the highest-priority PENDING job first.
;
; SHARED STATE - a job MAY touch state shared with the BSP, provided every
; accessor (the BSP side included) holds the matching lock. This replaces the
; old "jobs must be self-contained" rule, which was an un-enforceable honour
; system. Use wq_lock / wq_unlock with one of the named locks:
;     wq_alloc_lock   - the physical page allocator (page_alloc / page_free).
;     wq_fb_lock      - the shared framebuffer.
;     wq_driver_lock  - shared driver state.
; A lock only protects if BOTH sides take it; page_alloc / page_free already
; do. Lock-free, self-contained jobs remain the simplest option - a job that
; only reads read-only data and writes its own output buffer needs no lock.
;
; STATUS LIFECYCLE (status word at offset 0 of every slot):
;       FREE -> BUILDING -> PENDING -> RUNNING -> DONE -> FREE
;   BSP : FREE->BUILDING (atomic claim), BUILDING->PENDING (publish),
;         DONE->FREE (reap). Also BUILDING->RUNNING->DONE on the inline path.
;   AP  : PENDING->RUNNING (atomic claim), RUNNING->DONE (publish result).
;
; BSP API
;   workqueue_init                  - zero the queue, allow workers to run.
;   workqueue_submit(rdi=func,       - queue a job. Returns a handle (0..N-1)
;                    rsi=arg,          in RAX, or WQ_INVALID (-1) if full.
;                    rdx=priority)     priority is WQ_PRIO_LOW/NORMAL/HIGH.
;                          -> rax     If no AP is available the job runs
;                                     inline so callers stay correct on
;                                     single-core builds.
;   workqueue_done(rdi=handle) -> rax - 1 if the job finished, else 0.
;   workqueue_reap(rdi=handle) -> rax - result of a finished job; frees slot.
;   workqueue_wait(rdi=handle) -> rax - spin until done, return result + free.
;   workqueue_selftest               - submit known jobs, verify, print "WQ:".
;
; SHARED-STATE LOCK API
;   wq_lock(rdi=lock word ptr)        - spin until the lock is acquired.
;   wq_unlock(rdi=lock word ptr)      - release a lock held by this core.
;     Both preserve every register except RDI's pointee. Named locks live in
;     .data: wq_alloc_lock, wq_fb_lock, wq_driver_lock.
;
; TYPICAL ASYNC USE (keeps the render loop alive):
;       mov rdi, my_heavy_func
;       mov rsi, my_arg
;       mov rdx, WQ_PRIO_NORMAL
;       call workqueue_submit
;       mov [job], eax            ; stash handle, keep rendering frames...
;   ... later, once per frame ...
;       mov edi, [job]
;       call workqueue_done
;       test eax, eax
;       jz  .still_running
;       mov edi, [job]
;       call workqueue_reap       ; result in rax
; ============================================================================
bits 64

%include "constants.inc"
%include "macros.inc"

extern serial_puts
extern serial_crlf
extern ser_print_hex64
extern smp_alive_cores              ; defined in arch/apic.asm (.data)
extern tick_count
extern cpu_tsc_per_tick

; SMP_CORE_STATE offsets used by Task Manager:
;   +24 dd current utilization percent
;   +28 dd current MHz
;   +32 dq busy-cycle accumulator
;   +40 dq idle/scan-cycle accumulator
;   +48 dq last TSC mark
;   +56 dq last published tick
;   +64 dq previous APERF
;   +72 dq previous MPERF

; --- Job slot layout: 64 bytes, one cache line -----------------------------
WQ_OFF_STATUS  equ 0                ; dd  - lifecycle state (WQ_* below)
WQ_OFF_FUNC    equ 8                ; dq  - job entry point
WQ_OFF_ARG     equ 16               ; dq  - single argument, passed in RDI
WQ_OFF_RESULT  equ 24               ; dq  - RAX returned by the job
WQ_OFF_RUNS    equ 32               ; dd  - diagnostics: 1 once a worker ran it
WQ_OFF_PRIO    equ 36               ; dd  - job priority (WQ_PRIO_* below)
; Stage 2a: optional per-job placement + accounting fields.
;   target_core: -1 means "any AP can run it" (the legacy behaviour).
;                A non-negative value means only that core's worker may claim
;                the slot. Used so app-bound work lands on the app's home core.
;   proc_id    : 0 means "do not bill" (kernel-internal job). A non-zero value
;                names a process_t.id; the worker that runs the job lock-adds
;                its TSC delta into PROCESS_POOL[proc_id].cpu_time_cycles.
WQ_OFF_TARGET  equ 40               ; dd  - target core index, or -1 = any
WQ_OFF_PROC    equ 44               ; dd  - process id to bill, or 0 = none
WQ_JOB_SIZE    equ 64
WQ_MAX_JOBS    equ 32

WQ_TARGET_ANY  equ -1               ; submit_to "no preference"

; PCB layout we touch from the worker (must track process_t in structs.inc).
WQ_PCB_STRIDE    equ 512
WQ_PCB_TIME_OFF  equ 0xC8            ; process_t.cpu_time_cycles

; --- status word values ---
WQ_FREE        equ 0                ; slot unused
WQ_PENDING     equ 1                ; published, waiting for a worker
WQ_RUNNING     equ 2                ; a core is executing it
WQ_DONE        equ 3                ; finished, result is valid
WQ_BUILDING    equ 4                ; BSP is filling in func/arg (not yet visible)

; --- job priority values (higher number = claimed first by workers) ---
WQ_PRIO_LOW    equ 0                ; background app work; may be starved
WQ_PRIO_NORMAL equ 1                ; default
WQ_PRIO_HIGH   equ 2                ; system-critical; never starved by apps

WQ_INVALID     equ -1               ; workqueue_submit return value when full

WQ_SELFTEST_N  equ 8                ; number of jobs the self-test submits

section .text

; ----------------------------------------------------------------------------
; workqueue_init - reset every slot to FREE and release the workers.
; APs spinning in smp_worker_loop wait on workqueue_ready before touching the
; queue, so the BSP MUST call this before smp_ap_startup.
; ----------------------------------------------------------------------------
FN_BEGIN workqueue_init, 0, 0, FN_RET_VOID
    push rax
    push rcx
    push rdi
    mov rdi, workqueue_jobs
    mov rcx, WQ_MAX_JOBS * WQ_JOB_SIZE / 8
    xor rax, rax
    rep stosq
    ; Publish last: only now may a worker process jobs.
    mov rax, workqueue_ready
    mov dword [rax], 1
    pop rdi
    pop rcx
    pop rax
    FN_END workqueue_init
    ret

; ----------------------------------------------------------------------------
; workqueue_submit(RDI = func, RSI = arg, RDX = priority) -> RAX = handle,
; or WQ_INVALID. Finds a FREE slot, fills it in, and publishes it as PENDING.
; If no AP is alive the job is executed inline so the result is ready on return.
; ----------------------------------------------------------------------------
FN_BEGIN workqueue_submit, 3, 0, FN_RET_HANDLE
    ; Default placement: any AP, no billing. Forward to workqueue_submit_to.
    push r8
    push r9
    mov r8d, WQ_TARGET_ANY
    xor r9d, r9d
    call workqueue_submit_to
    pop r9
    pop r8
    FN_END workqueue_submit
    ret

; ----------------------------------------------------------------------------
; workqueue_submit_to(RDI = func, RSI = arg, RDX = priority,
;                     R8d = target_core (-1 = any),
;                     R9d = proc_id to bill (0 = none)) -> RAX = handle
;
; Like workqueue_submit but records a target core and an owning process. Used
; for app-bound work in Stage 2a: the BSP submits a job tied to an app's
; home_core and its PCB id, and only that core's worker will claim it. The
; runtime is billed to that process's cpu_time_cycles, so task manager can
; show per-app CPU usage as soon as any app work is routed through this
; entry point.
;
; If no AP is alive the job still executes inline (same as plain submit) and
; billing is skipped; the BSP is core 0 and we never bill it.
; ----------------------------------------------------------------------------
global workqueue_submit_to
workqueue_submit_to:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    push r9
    push r10
    push r11
    mov r10, rdi                    ; r10 = func pointer
    mov r11d, edx                   ; r11d = priority
    ; r8d = target_core, r9d = proc_id   (incoming, survive the cmpxchg)
    xor ecx, ecx                    ; ecx = candidate slot index
.scan:
    cmp ecx, WQ_MAX_JOBS
    jae .full
    mov eax, ecx
    imul eax, WQ_JOB_SIZE
    mov rbx, workqueue_jobs
    add rbx, rax                    ; rbx = &slot[ecx]
    ; Atomically claim a FREE slot: FREE -> BUILDING.
    mov eax, WQ_FREE
    mov edx, WQ_BUILDING
    lock cmpxchg [rbx + WQ_OFF_STATUS], edx
    jne .next
    ; --- slot claimed ---
    mov [rbx + WQ_OFF_FUNC], r10
    mov [rbx + WQ_OFF_ARG], rsi
    mov qword [rbx + WQ_OFF_RESULT], 0
    mov dword [rbx + WQ_OFF_RUNS], 0
    mov [rbx + WQ_OFF_PRIO], r11d
    mov [rbx + WQ_OFF_TARGET], r8d
    mov [rbx + WQ_OFF_PROC], r9d
    ; smp_alive_cores counts the BSP, so a value >= 2 means at least one AP is
    ; available to run the job. Otherwise execute it inline right here.
    mov eax, [smp_alive_cores]
    cmp eax, 2
    jae .publish
    ; --- inline (single-core) path ---
    mov dword [rbx + WQ_OFF_STATUS], WQ_RUNNING
    mov rdi, rsi                    ; arg
    push rbx                        ; preserve slot ptr across the call
    call r10
    pop rbx
    mov [rbx + WQ_OFF_RESULT], rax
    mov dword [rbx + WQ_OFF_RUNS], 1
    mov dword [rbx + WQ_OFF_STATUS], WQ_DONE
    mov eax, ecx                    ; handle = slot index
    jmp .ret
.publish:
    ; Store status LAST. x86's store ordering guarantees a worker that sees
    ; PENDING also sees the func/arg/result fields written above.
    mov dword [rbx + WQ_OFF_STATUS], WQ_PENDING
    mov eax, ecx                    ; handle = slot index
    jmp .ret
.next:
    inc ecx
    jmp .scan
.full:
    mov eax, WQ_INVALID
.ret:
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

; ----------------------------------------------------------------------------
; workqueue_done(RDI = handle) -> RAX = 1 if finished, 0 otherwise.
; A WQ_INVALID handle (or any out-of-range value) safely reports 0.
; ----------------------------------------------------------------------------
FN_BEGIN workqueue_done, 1, 0, FN_RET_SCALAR
    push rdx
    xor eax, eax
    cmp edi, WQ_MAX_JOBS            ; unsigned: also rejects WQ_INVALID
    jae .ret
    mov eax, edi
    imul eax, WQ_JOB_SIZE
    mov rdx, workqueue_jobs
    add rdx, rax
    xor eax, eax
    cmp dword [rdx + WQ_OFF_STATUS], WQ_DONE
    jne .ret
    mov eax, 1
.ret:
    pop rdx
    FN_END workqueue_done
    ret

; ----------------------------------------------------------------------------
; workqueue_reap(RDI = handle) -> RAX = result. Frees the slot back to FREE.
; Only call once a job is done (workqueue_done returned 1).
; ----------------------------------------------------------------------------
FN_BEGIN workqueue_reap, 1, 0, FN_RET_SCALAR
    push rdx
    xor eax, eax
    cmp edi, WQ_MAX_JOBS
    jae .ret
    mov eax, edi
    imul eax, WQ_JOB_SIZE
    mov rdx, workqueue_jobs
    add rdx, rax
    mov rax, [rdx + WQ_OFF_RESULT]
    mov dword [rdx + WQ_OFF_STATUS], WQ_FREE
.ret:
    pop rdx
    FN_END workqueue_reap
    ret

; ----------------------------------------------------------------------------
; workqueue_wait(RDI = handle) -> RAX = result. Blocks until the job is done,
; then reaps it. Convenience wrapper - prefer the async done/reap pattern in
; the render loop so the BSP keeps drawing frames.
; ----------------------------------------------------------------------------
FN_BEGIN workqueue_wait, 1, 0, FN_RET_SCALAR
.spin:
    call workqueue_done             ; reads EDI, leaves RDI untouched
    test eax, eax
    jnz .done
    pause
    jmp .spin
.done:
    call workqueue_reap
    FN_END workqueue_wait
    ret

; ----------------------------------------------------------------------------
; workqueue_wait_timeout(RDI = handle, RSI = tick budget)
;   -> RAX = result (or 0 if timed out), RDX = 0 normal / 1 timeout
;
; Like workqueue_wait but bails after `tick budget` PIT ticks. On timeout the
; slot is NOT reaped - it stays in RUNNING state owned by whichever AP picked
; it up. That AP is presumed dead, so the slot leaks; with WQ_MAX_JOBS=32 and
; a wedged routing path we lose 32 slots before submit starts failing, at
; which point dispatch_app_callback falls back to inline anyway. The leak is
; the price we pay for not freezing the whole OS on a broken AP.
; ----------------------------------------------------------------------------
extern tick_count
global workqueue_wait_timeout
workqueue_wait_timeout:
    push rbx
    push rcx
    mov rbx, [tick_count]
    add rbx, rsi                    ; rbx = deadline tick
.spin:
    call workqueue_done
    test eax, eax
    jnz .ok
    mov rcx, [tick_count]
    cmp rcx, rbx
    jae .timeout
    pause
    jmp .spin
.ok:
    call workqueue_reap
    xor edx, edx
    pop rcx
    pop rbx
    ret
.timeout:
    xor eax, eax
    mov edx, 1
    pop rcx
    pop rbx
    ret

; ----------------------------------------------------------------------------
; wq_lock(RDI = pointer to a lock word) - acquire a spinlock.
; Test-and-test-and-set: spin reading the word (cheap, cache-shared) and only
; attempt the bus-locked cmpxchg once it looks free. Preserves every register;
; the only side effect is the lock word becoming 1.
; ----------------------------------------------------------------------------
global wq_lock
wq_lock:
    push rax
    push rcx
.try:
    xor eax, eax                    ; expect the lock to be 0 (free)
    mov ecx, 1                      ; write 1 (held)
    lock cmpxchg [rdi], ecx
    je .acquired
.spin:
    pause                           ; another core holds it - back off
    cmp dword [rdi], 0
    jne .spin                       ; still held, do not hammer the bus lock
    jmp .try
.acquired:
    pop rcx
    pop rax
    ret

; ----------------------------------------------------------------------------
; wq_unlock(RDI = pointer to a lock word) - release a spinlock.
; A plain store is enough: x86 store ordering makes every write the holder did
; inside the critical section visible before the lock word reads back as 0.
; ----------------------------------------------------------------------------
global wq_unlock
wq_unlock:
    mov dword [rdi], 0
    ret

; ----------------------------------------------------------------------------
; smp_worker_loop - the permanent home of every AP.
; Entry: RDI = pointer to this core's SMP_CORE_STATE record (offset 16 of that
; record is a liveness heartbeat). Reached from the AP trampoline in apic.asm
; via `mov rax, smp_worker_loop / jmp rax`. NEVER returns.
;
; Bookkeeping registers across the job call: R12 (slot index) and R14 (core
; state ptr) are callee-saved, so a well-behaved job preserves them; R13 (slot
; ptr) is recomputed after the call regardless. EBX/R15 are only used during
; the pre-claim sweep, never across the job call.
; ----------------------------------------------------------------------------
global smp_worker_loop
smp_worker_loop:
    mov r14, rdi                    ; r14 = per-core state record
    rdtsc
    shl rdx, 32
    or rax, rdx
    mov [r14 + 48], rax
    mov rax, [tick_count]
    mov [r14 + 56], rax
    mov rax, [cpu_tsc_per_tick]
    xor rdx, rdx
    mov rcx, 10000
    div rcx
    mov [r14 + 28], eax
    call wq_core_init_aperf
.wait_ready:
    ; Do not touch the queue until the BSP has run workqueue_init.
    mov rax, workqueue_ready
    cmp dword [rax], 1
    je .scan
    pause
    jmp .wait_ready
.scan:
    inc qword [r14 + 16]            ; liveness heartbeat
    ; --- sweep every slot, remember the highest-priority PENDING one ---
    ; Priority is written while the slot is BUILDING (before its status store
    ; to PENDING), so x86 store ordering guarantees a worker that sees PENDING
    ; also sees the correct priority.
    xor r12d, r12d                  ; r12 = sweep index
    mov ebx, -1                     ; ebx = best slot index (-1 = none found)
    mov r15d, -1                    ; r15d = best priority seen so far
.find:
    mov eax, r12d
    imul eax, WQ_JOB_SIZE
    mov r13, workqueue_jobs
    add r13, rax                    ; r13 = &slot[r12]
    cmp dword [r13 + WQ_OFF_STATUS], WQ_PENDING
    jne .find_next
    ; Stage 2a: respect target_core. WQ_TARGET_ANY (-1) matches any core;
    ; otherwise the slot is only eligible for the core whose index in
    ; [r14 + 4] matches WQ_OFF_TARGET. This is what lets the BSP pin an
    ; app's work to the app's home_core.
    mov edx, [r13 + WQ_OFF_TARGET]
    cmp edx, WQ_TARGET_ANY
    je .target_ok
    cmp edx, [r14 + 4]
    jne .find_next
.target_ok:
    mov edx, [r13 + WQ_OFF_PRIO]
    cmp edx, r15d
    jle .find_next                  ; not strictly higher - keep current best
    mov r15d, edx
    mov ebx, r12d
.find_next:
    inc r12d
    cmp r12d, WQ_MAX_JOBS
    jb .find
    cmp ebx, -1
    je .idle                        ; nothing claimable this sweep
    ; --- try to claim the chosen slot: PENDING -> RUNNING ---
    mov r12d, ebx                   ; r12 = chosen slot index
    mov eax, r12d
    imul eax, WQ_JOB_SIZE
    mov r13, workqueue_jobs
    add r13, rax                    ; r13 = &slot[r12]
    mov eax, WQ_PENDING
    mov ecx, WQ_RUNNING
    lock cmpxchg [r13 + WQ_OFF_STATUS], ecx
    jne .scan                       ; another core won it - re-sweep
    ; --- this core owns slot r12 ---
    mov dword [r14 + 0], 2              ; SMP state: RUNNING/busy
    rdtsc
    shl rdx, 32
    or rax, rdx
    mov rcx, rax
    sub rax, [r14 + 48]
    add [r14 + 40], rax
    mov [r14 + 48], rcx
    mov rax, [r13 + WQ_OFF_FUNC]
    mov rdi, [r13 + WQ_OFF_ARG]
    call rax                        ; run the job; result in RAX
    mov r15, rax                    ; preserve result across the recompute
    rdtsc
    shl rdx, 32
    or rax, rdx
    mov rbx, rax
    sub rax, [r14 + 48]
    add [r14 + 32], rax
    mov [r14 + 48], rbx
    ; Stage 2a: bill these cycles to the owning process, if any. We re-load
    ; the slot's WQ_OFF_PROC here rather than caching it because R13 is still
    ; valid and a re-read is cheap. A proc_id of 0 (kernel-internal job) or
    ; out-of-range is silently skipped.
    mov edx, [r13 + WQ_OFF_PROC]
    test edx, edx
    jz .no_billing
    cmp edx, MAX_PROCESSES
    jae .no_billing
    mov rcx, rdx
    imul rcx, WQ_PCB_STRIDE
    add rcx, PROCESS_POOL
    lock add [rcx + WQ_PCB_TIME_OFF], rax
.no_billing:
    mov rax, [tick_count]
    sub rax, [r14 + 56]
    cmp rax, 50
    jb .publish_result
    mov r8, rax                     ; elapsed PIT ticks
    mov rax, [r14 + 32]
    mov rcx, [r14 + 40]
    add rcx, rax
    test rcx, rcx
    jz .publish_clock
    mov r9, 100
    xor rdx, rdx
    mul r9
    div rcx
    cmp rax, 100
    jbe .store_util
    mov rax, 100
.store_util:
    mov [r14 + 24], eax
.publish_clock:
    call wq_core_publish_mhz
.reset_acct:
    mov qword [r14 + 32], 0
    mov qword [r14 + 40], 0
    mov rax, [tick_count]
    mov [r14 + 56], rax
.publish_result:
    mov eax, r12d
    imul eax, WQ_JOB_SIZE
    mov r13, workqueue_jobs
    add r13, rax                    ; recompute slot ptr
    mov [r13 + WQ_OFF_RESULT], r15
    inc dword [r13 + WQ_OFF_RUNS]
    ; Status store LAST: the BSP must never see DONE before the result.
    mov dword [r13 + WQ_OFF_STATUS], WQ_DONE
    mov dword [r14 + 0], 3              ; SMP state: PARKED/available
    jmp .scan
.idle:
    rdtsc
    shl rdx, 32
    or rax, rdx
    mov rbx, rax
    sub rax, [r14 + 48]
    add [r14 + 40], rax
    mov [r14 + 48], rbx
    mov rax, [tick_count]
    sub rax, [r14 + 56]
    cmp rax, 50
    jb .idle_pause
    mov r8, rax
    mov rax, [r14 + 32]
    mov rcx, [r14 + 40]
    add rcx, rax
    test rcx, rcx
    jz .idle_clock
    mov r9, 100
    xor rdx, rdx
    mul r9
    div rcx
    cmp rax, 100
    jbe .idle_store_util
    mov rax, 100
.idle_store_util:
    mov [r14 + 24], eax
.idle_clock:
    call wq_core_publish_mhz
.idle_reset:
    mov qword [r14 + 32], 0
    mov qword [r14 + 40], 0
    mov rax, [tick_count]
    mov [r14 + 56], rax
.idle_pause:
    pause                           ; idle hint - nothing claimable this sweep
    jmp .scan

wq_core_init_aperf:
    push rax
    push rbx
    push rcx
    push rdx
    xor eax, eax
    cpuid
    cmp eax, 6
    jb .done
    mov eax, 6
    cpuid
    test ecx, 1
    jz .done
    mov ecx, 0xE8                  ; IA32_APERF
    rdmsr
    shl rdx, 32
    or rax, rdx
    mov [r14 + 64], rax
    mov ecx, 0xE7                  ; IA32_MPERF
    rdmsr
    shl rdx, 32
    or rax, rdx
    mov [r14 + 72], rax
.done:
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; R8 = elapsed PIT ticks for the accounting window.
wq_core_publish_mhz:
    push rax
    push rbx
    push rcx
    push rdx
    push r9
    xor eax, eax
    cpuid
    cmp eax, 6
    jb .tsc_fallback
    mov eax, 6
    cpuid
    test ecx, 1
    jz .tsc_fallback
    mov ecx, 0xE8                  ; IA32_APERF
    rdmsr
    shl rdx, 32
    or rax, rdx
    mov rbx, rax
    sub rax, [r14 + 64]            ; aperf delta
    mov [r14 + 64], rbx
    mov r9, rax
    mov ecx, 0xE7                  ; IA32_MPERF
    rdmsr
    shl rdx, 32
    or rax, rdx
    mov rbx, rax
    sub rax, [r14 + 72]            ; mperf delta
    mov [r14 + 72], rbx
    mov rcx, rax
    test rcx, rcx
    jz .tsc_fallback
    mov rax, [cpu_tsc_per_tick]
    xor rdx, rdx
    mov rbx, 10000
    div rbx                        ; base TSC MHz
    mul r9                         ; base MHz * aperf delta
    xor rdx, rdx
    div rcx                        ; scale by aperf/mperf
    mov [r14 + 28], eax
    jmp .done
.tsc_fallback:
    mov rax, [r14 + 32]
    add rax, [r14 + 40]
    mov r9, r8
    imul r9, 10000
    test r9, r9
    jz .done
    xor rdx, rdx
    div r9
    mov [r14 + 28], eax
.done:
    pop r9
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; ----------------------------------------------------------------------------
; wq_test_job(RDI = x) -> RAX = x*x + 1. A pure, ABI-clean job used only by the
; self-test: no shared state, bounded work.
; ----------------------------------------------------------------------------
wq_test_job:
    mov rax, rdi
    imul rax, rax
    add rax, 1
    ret

; ----------------------------------------------------------------------------
; workqueue_selftest - submit WQ_SELFTEST_N known jobs, wait for them, verify
; each result, and print "WQ:<submitted>/<passed>" to the serial log. With APs
; alive this exercises the real cross-core path; otherwise the inline path.
; ----------------------------------------------------------------------------
FN_BEGIN workqueue_selftest, 0, 0, FN_RET_VOID
    push rbx
    push r12
    push r13
    xor r12d, r12d                  ; r12 = x / loop index
.submit_loop:
    cmp r12d, WQ_SELFTEST_N
    jae .wait_loop
    mov rdi, wq_test_job
    mov esi, r12d                   ; arg = x
    mov edx, WQ_PRIO_NORMAL         ; priority
    call workqueue_submit
    mov [wq_test_handles + r12*4], eax
    inc r12d
    jmp .submit_loop
.wait_loop:
    xor r12d, r12d
    xor r13d, r13d                  ; r13 = passed count
.wait_one:
    cmp r12d, WQ_SELFTEST_N
    jae .report
    mov edi, [wq_test_handles + r12*4]
    cmp edi, WQ_INVALID             ; queue was full at submit time -> skip
    je .next_wait
    call workqueue_wait             ; rax = result
    mov ebx, r12d                   ; expected = x*x + 1
    imul ebx, ebx
    inc ebx
    cmp rax, rbx
    jne .next_wait
    inc r13d
.next_wait:
    inc r12d
    jmp .wait_one
.report:
    lea rdi, [rel wq_msg]
    call serial_puts
    mov edi, WQ_SELFTEST_N
    call ser_print_hex64
    SER '/'
    mov rdi, r13
    call ser_print_hex64
    call serial_crlf
    pop r13
    pop r12
    pop rbx
    FN_END workqueue_selftest
    ret

section .data
align 64
workqueue_ready:  dd 0              ; 0 until workqueue_init; gates the workers
wq_test_handles:  times WQ_SELFTEST_N dd 0
wq_msg:           db 'WQ:', 0

; Named shared-state locks. Each sits on its own 64-byte cache line so cores
; contending one lock do not ping-pong the line of an unrelated lock. 0 = free,
; 1 = held. See the SHARED STATE section of the header for the contract.
align 64
global wq_alloc_lock
wq_alloc_lock:    dd 0              ; guards page_alloc / page_free
align 64
global wq_fb_lock
wq_fb_lock:       dd 0              ; guards the shared framebuffer
align 64
global wq_driver_lock
wq_driver_lock:   dd 0              ; guards shared driver state

; The job array. 64-byte aligned and 64 bytes per slot so each slot is its own
; cache line - cores working different slots never share a line.
align 64
workqueue_jobs:   times (WQ_MAX_JOBS * WQ_JOB_SIZE) db 0
