; ============================================================================
; NexusOS v3.0 - Common Macros
; ============================================================================

%ifndef MACROS_INC
%define MACROS_INC

; Output character to COM1 for debugging
%macro SER 1
%ifdef ENABLE_DEBUG_SERIAL
    push rax
    push rdx
    mov dx, 0x3F8
    mov al, %1
    out dx, al
    pop rdx
    pop rax
%endif
%endmacro

; Save all general-purpose registers (64-bit)
%macro PUSH_ALL 0
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push rbp
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15
%endmacro

; Offset of registers in PUSH_ALL frame
ALL_R15 equ 0
ALL_R14 equ 8
ALL_R13 equ 16
ALL_R12 equ 24
ALL_R11 equ 32
ALL_R10 equ 40
ALL_R9  equ 48
ALL_R8  equ 56
ALL_RBP equ 64
ALL_RDI equ 72
ALL_RSI equ 80
ALL_RDX equ 88
ALL_RCX equ 96
ALL_RBX equ 104
ALL_RAX equ 112

; Restore all general-purpose registers (64-bit)
%macro POP_ALL 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rbp
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
%endmacro

; Output byte to port with I/O delay
%macro OUTB 2
    mov al, %2
    out %1, al
%endmacro

; Input byte from port
%macro INB 1
    in al, %1
%endmacro

; I/O wait (small delay for PIC/PIT programming)
%macro IO_WAIT 0
    out 0x80, al
%endmacro

; ISR stub that pushes a dummy error code (for exceptions without one)
%macro ISR_NOERRCODE 1
global isr_%1
isr_%1:
    push qword 0           ; Dummy error code
    push qword %1          ; Interrupt number
    jmp isr_common_stub
%endmacro

; ISR stub for exceptions that push their own error code
%macro ISR_ERRCODE 1
global isr_%1
isr_%1:
    push qword %1          ; Interrupt number (error code already on stack)
    jmp isr_common_stub
%endmacro

; IRQ stub macro
%macro IRQ_STUB 2
global irq_%1
irq_%1:
    push qword 0           ; Dummy error code
    push qword %2          ; Interrupt vector number
    jmp irq_common_stub
%endmacro

%endif
