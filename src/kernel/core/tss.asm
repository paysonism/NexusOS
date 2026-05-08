; ============================================================================
; NexusOS v3.0 - Task State Segment (64-bit)
; ============================================================================
bits 64

%include "constants.inc"

section .data
global tss64
align 16
tss64:
    dd 0            ; Reserved
tss64_rsp0:
    dq 0x200000     ; RSP0 fallback until tss_init installs the dedicated stack.
    dq 0            ; RSP1
    dq 0            ; RSP2
    dq 0            ; Reserved
    dq 0            ; IST1
    dq 0            ; IST2
    dq 0            ; IST3
    dq 0            ; IST4
    dq 0            ; IST5
    dq 0            ; IST6
    dq 0            ; IST7
    dq 0            ; Reserved
    dw 0            ; Reserved
    dw 104          ; I/O Map Base Address (points outside TSS = no I/O map)

section .text

; --- Initialize TSS in GDT and load it ---
global tss_init
tss_init:
    push rax
    push rbx
    push rdi

    lea rax, [rel tss_rsp0_stack_end]
    mov [rel tss64_rsp0], rax

    ; Get TSS address
    lea rax, [tss64]
    
    ; Find the TSS descriptor in GDT - read actual GDT base from GDTR
    sub rsp, 16
    sgdt [rsp]              ; store GDTR: [0-1]=limit, [2-9]=base
    mov rdi, [rsp + 2]      ; RDI = actual GDT base address
    add rsp, 16
    add rdi, 0x30           ; TSS descriptor at offset 0x30

    ; Fill TSS Descriptor (16 bytes)
    ; [0-1] Limit[15:0] = 103 (already set in gdt.asm)
    ; [2-3] Base[15:0]
    mov [rdi + 2], ax
    shr rax, 16
    ; [4] Base[23:16]
    mov [rdi + 4], al
    ; [5] Access: 0x89 (already set)
    ; [6] Flags + Limit High (already set)
    ; [7] Base[31:24]
    shr rax, 8
    mov [rdi + 7], al
    ; [8-11] Base[63:32]
    shr rax, 8
    mov [rdi + 8], eax
    ; [12-15] Reserved (0)

    ; Load TR register
    mov ax, 0x30            ; TSS Selector (Index 6 * 8)
    ltr ax

    pop rdi
    pop rbx
    pop rax
    ret

section .bss
alignb 16
tss_rsp0_stack:
    resb 16384
tss_rsp0_stack_end:
