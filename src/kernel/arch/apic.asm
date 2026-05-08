; ============================================================================
; NexusOS v3.0 - Local APIC Driver
; Used for handling hardware interrupts on modern systems
; ============================================================================
bits 64

%include "constants.inc"

section .data
lapic_base dq 0xFEE00000

section .text
; auto-wrapped (FN_BEGIN emits global): global apic_init
; auto-wrapped (FN_BEGIN emits global): global apic_eoi
; auto-wrapped (FN_BEGIN emits global): global smp_ap_startup
global smp_started_cores
global smp_alive_cores
global smp_parked_cores
global smp_target_cores
global smp_core_states
extern madt_enabled_cpu_count
extern madt_lapic_ids

; --- Initialize Local APIC ---
FN_BEGIN apic_init, 0, 0, FN_RET_SCALAR
    ; Read APIC base from MSR 0x1B
    mov ecx, 0x1B
    rdmsr                   ; EAX = low 32 bits of APIC_BASE
    
    ; Debug: Print the MSR value bits 11:8 (bit 10 is x2apic)
    push rax
    push rdx
    SER 'M'
    SER 'S'
    SER 'R'
    mov edx, eax
    shr edx, 8
    and dl, 0x0F            ; Bits 11:8
    add dl, '0'
    mov al, dl
    mov edx, 0x3F8
    out dx, al           ; Output bit pattern (e.g. '8'=xAPIC, 'L'=x2APIC?)
    pop rdx
    pop rax

    ; Ensure APIC is enabled (bit 11) and x2APIC is disabled (bit 10) for now
    ; to keep the MMIO-based driver working.
    and ah, 11111011b       ; Clear bit 10 (x2APIC)
    bts eax, 11
    wrmsr

    ; Map the APIC base (combine EDX:EAX, mask out lower 12 bits).
    ; APIC_BASE MSR is 64-bit; on systems with APIC base above 4 GB the high
    ; bits live in EDX. Without combining, lapic_base would be wrong.
    shl rdx, 32
    or rax, rdx
    and rax, ~0xFFF
    mov [lapic_base], rax

    ; Spurious Interrupt Vector Register (SIVR)
    ; Enable APIC (bit 8) and set vector to 255
    mov rdi, [lapic_base]
    mov dword [rdi + 0x0F0], 0x1FF

    ; Set Task Priority Register (TPR) to 0 to enable all interrupts
    ; On many UEFI systems this is 0xFF by default, which blocks all IRQs.
    mov rdi, [lapic_base]
    mov dword [rdi + 0x080], 0
    
    ret

; --- Send End of Interrupt (EOI) ---
FN_BEGIN apic_eoi, 0, 0, FN_RET_SCALAR
    mov rdi, [lapic_base]
    mov dword [rdi + 0x0B0], 0
    ret

%ifdef NEXUS_CACHE32_MAX
%ifdef NEXUS_CACHE32_AP_STARTUP
FN_BEGIN smp_ap_startup, 0, 0, FN_RET_SCALAR
    push rbx
    push rcx
    push rsi
    push rdi
    call smp_init_states
    call smp_copy_trampoline
    mov eax, [madt_enabled_cpu_count]
    test eax, eax
    jnz .have_count
    mov eax, SMP_MAX_CORES
    jmp .have_count
    test eax, eax
    jnz .have_count
    mov eax, 1
.have_count:
    cmp eax, SMP_MAX_CORES
    jbe .target_ok
    mov eax, SMP_MAX_CORES
.target_ok:
    cmp eax, 2
    jae .store_target
    mov eax, SMP_MAX_CORES
.store_target:
    mov [smp_target_cores], eax
    cmp eax, 2
    jb .done
    mov ecx, 1
.loop:
    cmp ecx, [smp_target_cores]
    jae .done
    call smp_start_one
    inc ecx
    jmp .loop
.done:
    call smp_count_states
    pop rdi
    pop rsi
    pop rcx
    pop rbx
    ret

smp_init_states:
    mov rdi, smp_core_states
    mov rcx, SMP_MAX_CORES * SMP_CORE_STATE_SIZE / 8
    xor rax, rax
    rep stosq
    mov dword [abs smp_core_states], 3
    mov dword [abs smp_core_states + 4], 0
    mov rax, [abs lapic_base]
    mov eax, [rax + 0x20]
    shr eax, 24
    mov [abs smp_core_states + 8], eax
    mov qword [abs smp_core_states + 16], 1
    mov dword [abs smp_started_cores], 1
    mov dword [abs smp_alive_cores], 1
    mov dword [abs smp_parked_cores], 1
    ret

smp_copy_trampoline:
    mov rsi, ap_tramp_start
    mov rdi, SMP_TRAMPOLINE_ADDR
    mov rcx, ap_tramp_end - ap_tramp_start
    rep movsb
    wbinvd
    ret

smp_start_one:
    push rcx
    mov eax, ecx
    imul eax, SMP_CORE_STATE_SIZE
    lea rbx, [smp_core_states + rax]
    mov dword [rbx + 0], 1
    mov [rbx + 4], ecx
    cmp dword [madt_enabled_cpu_count], 2
    jb .fallback_id
    movzx eax, byte [madt_lapic_ids + rcx]
    jmp .got_id
.fallback_id:
    mov eax, ecx
.got_id:
    mov [rbx + 8], eax
    mov qword [rbx + 16], 0
    mov rax, SMP_CORE_STACK_BASE
    mov edx, ecx
    inc edx
    imul edx, SMP_CORE_STACK_SIZE
    add rax, rdx
    mov [abs SMP_TRAMPOLINE_ADDR + ap_boot_stack_ptr - ap_tramp_start], rax
    mov [abs SMP_TRAMPOLINE_ADDR + ap_boot_state_ptr - ap_tramp_start], rbx
    wbinvd
    mov rdi, [abs lapic_base]
    mov eax, [rbx + 8]
    shl eax, 24
    mov [rdi + 0x310], eax
    mov dword [rdi + 0x300], 0x00004500
    call smp_short_delay
    mov dword [rdi + 0x300], 0x00008500
    call smp_short_delay
    mov dword [rdi + 0x300], 0x00004608
    call smp_short_delay
    mov dword [rdi + 0x300], 0x00004608
    call smp_wait_alive
    pop rcx
    ret

smp_wait_alive:
    mov edx, 2000000
.wait:
    cmp qword [rbx + 16], 0
    jne .alive
    dec edx
    jnz .wait
    mov dword [rbx + 0], 4
    ret
.alive:
    inc dword [smp_started_cores]
    ret

smp_count_states:
    xor eax, eax
    mov [smp_alive_cores], eax
    mov [smp_parked_cores], eax
    mov ecx, 0
.count:
    cmp ecx, [smp_target_cores]
    jae .done
    mov eax, ecx
    imul eax, SMP_CORE_STATE_SIZE
    cmp dword [smp_core_states + rax], 3
    jne .next
    inc dword [smp_alive_cores]
    inc dword [smp_parked_cores]
.next:
    inc ecx
    jmp .count
.done:
    ret

smp_short_delay:
    push rcx
    mov ecx, 200000
.d:
    pause
    loop .d
    pop rcx
    ret

[bits 16]
ap_tramp_start:
    cli
    lgdt [dword SMP_TRAMPOLINE_ADDR + ap_gdt_ptr - ap_tramp_start]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp 0x08:(SMP_TRAMPOLINE_ADDR + ap_pm32 - ap_tramp_start)
[bits 32]
ap_pm32:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov eax, cr4
    or eax, 0x20
    mov cr4, eax
    mov eax, PAGE_TABLE_ADDR
    mov cr3, eax
    mov ecx, 0xC0000080
    rdmsr
    or eax, 0x100
    wrmsr
    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax
    jmp 0x18:(SMP_TRAMPOLINE_ADDR + ap_lm64 - ap_tramp_start)
[bits 64]
ap_lm64:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov rsp, [abs SMP_TRAMPOLINE_ADDR + ap_boot_stack_ptr - ap_tramp_start]
    mov rdi, [abs SMP_TRAMPOLINE_ADDR + ap_boot_state_ptr - ap_tramp_start]
    inc qword [rdi + 16]
    mov rax, smp_ap_started_count
    lock inc dword [rax]
    mov dword [rdi + 0], 2
    mov dword [rdi + 0], 3
.park:
    inc qword [rdi + 16]
    hlt
    jmp .park
align 8
ap_gdt:
    dq 0
    dq 0x00CF9A000000FFFF
    dq 0x00CF92000000FFFF
    dq 0x00AF9A000000FFFF
ap_gdt_ptr:
    dw ap_gdt_ptr - ap_gdt - 1
    dq SMP_TRAMPOLINE_ADDR + ap_gdt - ap_tramp_start
ap_boot_stack_ptr:
    dq 0
ap_boot_state_ptr:
    dq 0
ap_tramp_end:

%else
smp_ap_startup:
    ret
%endif

section .data
align 64
smp_core_states: equ SMP_CORE_STATE_ADDR
smp_target_cores: dd SMP_MAX_CORES
smp_started_cores: dd 1
smp_alive_cores: dd 1
smp_parked_cores: dd 1
smp_ap_started_count: dd 0
%else
smp_ap_startup:
    ret
section .data
align 64
smp_core_states: equ SMP_CORE_STATE_ADDR
smp_target_cores: dd 1
smp_started_cores: dd 1
smp_alive_cores: dd 1
smp_parked_cores: dd 1
%endif
