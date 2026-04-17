; ============================================================================
; NexusOS v3.0 - Local APIC Driver
; Used for handling hardware interrupts on modern systems
; ============================================================================
bits 64

%include "constants.inc"

section .data
lapic_base dq 0xFEE00000

section .text
global apic_init
global apic_eoi

; --- Initialize Local APIC ---
apic_init:
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

    ; Map the APIC base (mask out lower 12 bits)
    and eax, 0xFFFFF000
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
apic_eoi:
    mov rdi, [lapic_base]
    mov dword [rdi + 0x0B0], 0
    ret
