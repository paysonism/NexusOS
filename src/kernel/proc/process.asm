; ============================================================================
; NexusOS v3.0 - Process Management & Scheduler
; ============================================================================
bits 64

%include "constants.inc"
%include "structs.inc"
%include "macros.inc"

MAX_PROCESSES   equ 8
PROCESS_POOL    equ 0x220000     ; 8 * 512 bytes = 4KB

GDT64_CODE_SEG    equ 0x08
GDT64_DATA_SEG    equ 0x10
GDT64_USER_DATA   equ 0x23
GDT64_USER_CODE   equ 0x2B

section .text

global scheduler_init
global process_create
global process_schedule
global current_process_id
global proc_is_active
global process_save_context
global process_restore_context
global process_kill_window
global process_find_by_window

extern l3_user_stack_top
extern l3_syscall_stack_top
extern tss64

; --- scheduler_init ---
scheduler_init:
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
process_create:
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
process_save_context:
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
process_restore_context:
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
    
    ; Update Userland slot context
    extern l3_current_slot
    mov eax, [rbx + process_t.slot]
    mov [l3_current_slot], eax

.done:
    pop rcx
    pop rbx
    pop rax
    ret

; --- process_schedule ---
; Round-Robin Scheduler
; Returns: RAX = next PID, or -1 if none
process_schedule:
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

proc_is_active:
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

process_kill_window:
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

section .data
global current_process_id
current_process_id: dd -1
next_pid:           dd 0
