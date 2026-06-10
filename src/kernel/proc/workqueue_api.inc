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
    call apic_wake_workers
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