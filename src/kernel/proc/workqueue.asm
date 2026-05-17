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
;   * NOT touch BSP-only mutable state without its own locking. SAFE inputs:
;     read-only data, a scratch buffer owned solely by this job, the job's own
;     output buffer. UNSAFE: the shared framebuffer, the kernel heap, driver
;     state - touching those concurrently corrupts the system.
;   * Do bounded work. APs receive no timer IRQs, so a job runs to completion.
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
;                    rsi=arg) -> rax   in RAX, or WQ_INVALID (-1) if full.
;                                     If no AP is available the job runs
;                                     inline so callers stay correct on
;                                     single-core builds.
;   workqueue_done(rdi=handle) -> rax - 1 if the job finished, else 0.
;   workqueue_reap(rdi=handle) -> rax - result of a finished job; frees slot.
;   workqueue_wait(rdi=handle) -> rax - spin until done, return result + free.
;   workqueue_selftest               - submit known jobs, verify, print "WQ:".
;
; TYPICAL ASYNC USE (keeps the render loop alive):
;       mov rdi, my_heavy_func
;       mov rsi, my_arg
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

; --- Job slot layout: 64 bytes, one cache line -----------------------------
WQ_OFF_STATUS  equ 0                ; dd  - lifecycle state (WQ_* below)
WQ_OFF_FUNC    equ 8                ; dq  - job entry point
WQ_OFF_ARG     equ 16               ; dq  - single argument, passed in RDI
WQ_OFF_RESULT  equ 24               ; dq  - RAX returned by the job
WQ_OFF_RUNS    equ 32               ; dd  - diagnostics: 1 once a worker ran it
WQ_JOB_SIZE    equ 64
WQ_MAX_JOBS    equ 32

; --- status word values ---
WQ_FREE        equ 0                ; slot unused
WQ_PENDING     equ 1                ; published, waiting for a worker
WQ_RUNNING     equ 2                ; a core is executing it
WQ_DONE        equ 3                ; finished, result is valid
WQ_BUILDING    equ 4                ; BSP is filling in func/arg (not yet visible)

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
; workqueue_submit(RDI = func, RSI = arg) -> RAX = handle, or WQ_INVALID.
; Finds a FREE slot, fills it in, and publishes it as PENDING. If no AP is
; alive the job is executed inline so the result is ready on return.
; ----------------------------------------------------------------------------
FN_BEGIN workqueue_submit, 2, 0, FN_RET_HANDLE
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    mov r8, rdi                     ; r8 = func pointer
    xor ecx, ecx                    ; ecx = candidate slot index
.scan:
    cmp ecx, WQ_MAX_JOBS
    jae .full
    mov eax, ecx
    imul eax, WQ_JOB_SIZE
    mov rbx, workqueue_jobs
    add rbx, rax                    ; rbx = &slot[ecx]
    ; Atomically claim a FREE slot: FREE -> BUILDING. While BUILDING the slot
    ; is invisible to workers (they only look for PENDING).
    mov eax, WQ_FREE                ; cmpxchg compares against EAX
    mov edx, WQ_BUILDING
    lock cmpxchg [rbx + WQ_OFF_STATUS], edx
    jne .next                       ; slot was not FREE, try the next one
    ; --- slot claimed ---
    mov [rbx + WQ_OFF_FUNC], r8
    mov [rbx + WQ_OFF_ARG], rsi
    mov qword [rbx + WQ_OFF_RESULT], 0
    mov dword [rbx + WQ_OFF_RUNS], 0
    ; smp_alive_cores counts the BSP, so a value >= 2 means at least one AP is
    ; available to run the job. Otherwise execute it inline right here.
    mov eax, [smp_alive_cores]
    cmp eax, 2
    jae .publish
    ; --- inline (single-core) path ---
    mov dword [rbx + WQ_OFF_STATUS], WQ_RUNNING
    mov rdi, rsi                    ; arg
    push rbx                        ; preserve slot ptr across the call
    call r8
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
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    FN_END workqueue_submit
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
; smp_worker_loop - the permanent home of every AP.
; Entry: RDI = pointer to this core's SMP_CORE_STATE record (offset 16 of that
; record is a liveness heartbeat). Reached from the AP trampoline in apic.asm
; via `mov rax, smp_worker_loop / jmp rax`. NEVER returns.
;
; Bookkeeping registers across the job call: R12 (slot index) and R14 (core
; state ptr) are callee-saved, so a well-behaved job preserves them; R13 (slot
; ptr) is recomputed after the call regardless.
; ----------------------------------------------------------------------------
global smp_worker_loop
smp_worker_loop:
    mov r14, rdi                    ; r14 = per-core state record
.wait_ready:
    ; Do not touch the queue until the BSP has run workqueue_init.
    mov rax, workqueue_ready
    cmp dword [rax], 1
    je .scan
    pause
    jmp .wait_ready
.scan:
    xor r12d, r12d                  ; r12 = slot index
.next:
    inc qword [r14 + 16]            ; liveness heartbeat
    mov eax, r12d
    imul eax, WQ_JOB_SIZE
    mov r13, workqueue_jobs
    add r13, rax                    ; r13 = &slot[r12]
    ; Atomically claim a PENDING job: PENDING -> RUNNING. If another core won
    ; it (or it is not pending) cmpxchg leaves ZF clear.
    mov eax, WQ_PENDING
    mov ecx, WQ_RUNNING
    lock cmpxchg [r13 + WQ_OFF_STATUS], ecx
    jne .advance
    ; --- this core owns slot r12 ---
    mov dword [r14 + 0], 2              ; SMP state: RUNNING/busy
    mov rax, [r13 + WQ_OFF_FUNC]
    mov rdi, [r13 + WQ_OFF_ARG]
    call rax                        ; run the job; result in RAX
    mov r15, rax                    ; preserve result across the recompute
    mov eax, r12d
    imul eax, WQ_JOB_SIZE
    mov r13, workqueue_jobs
    add r13, rax                    ; recompute slot ptr
    mov [r13 + WQ_OFF_RESULT], r15
    inc dword [r13 + WQ_OFF_RUNS]
    ; Status store LAST: the BSP must never see DONE before the result.
    mov dword [r13 + WQ_OFF_STATUS], WQ_DONE
    mov dword [r14 + 0], 3              ; SMP state: PARKED/available
.advance:
    inc r12d
    cmp r12d, WQ_MAX_JOBS
    jb .next
    pause                           ; idle hint - nothing claimable this sweep
    jmp .scan

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

; The job array. 64-byte aligned and 64 bytes per slot so each slot is its own
; cache line - cores working different slots never share a line.
align 64
workqueue_jobs:   times (WQ_MAX_JOBS * WQ_JOB_SIZE) db 0
