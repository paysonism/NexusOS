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
    sti
    hlt
    cli
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
    cmp rax, 100000
    ja .tsc_fallback               ; bogus APERF/MPERF sample on this CPU
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
