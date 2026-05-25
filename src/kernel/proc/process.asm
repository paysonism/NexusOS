; ============================================================================
; NexusOS v3.0 - Process Management & Scheduler
; ============================================================================
bits 64

%include "constants.inc"
%include "structs.inc"
%include "macros.inc"

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
    mov qword [rax], rdx
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
; symbol has been declared since v3.0 but the body was a stub; Stage 2c needs
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
extern wq_lock
extern wq_unlock
extern smp_alive_cores

WIN_OFF_ID equ 0                       ; matches src/include/window_layout.inc

%ifndef NEXUS_ENABLE_RING3_AP
; --- NON-AP BUILD: pass-through to call_app_l3 ------------------------------
; Apps run inline on the BSP when AP routing is not compiled in.
global dispatch_app_callback
dispatch_app_callback:
    jmp call_app_l3
%else
; --- AP-ROUTING BUILD: route ring-3 callbacks to APs ------------------------
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
    mov esi, 20                        ; 20 ticks = ~200 ms timeout
    call workqueue_wait_timeout
    test edx, edx
    jnz .timed_out

    push rax
    lea rdi, [rel app_callback_lock]
    call wq_unlock
    pop rax
    jmp .ret

.timed_out:
    mov dword [ring3_ap_enabled], 0    ; auto-disable for the rest of the boot
    lea rdi, [rel app_callback_lock]
    call wq_unlock
    xor eax, eax
    jmp .ret

.submit_fail:
    lea rdi, [rel app_callback_lock]
    call wq_unlock

.inline:
    mov rdi, r12
    mov rsi, r13
    mov rdx, r14
    mov rcx, r15
    call call_app_l3

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
