; ============================================================================
; NexusOS v3.0 - Usermode Transition
; ============================================================================
bits 64

%include "constants.inc"

section .bss
align 4096
user_stack: resb 16384       ; 16 KB user stack
user_stack_top:

section .text

global enter_usermode
enter_usermode:
    ; RDI contains the entry point address
    
    ; Print target RIP for debugging
    SER 'T'
    push rdi
    call ser_print_hex64
    pop rdi
    
    ; Create IRETQ stack frame
    push GDT64_USER_DATA    ; SS
    lea rax, [user_stack_top]
    push rax                ; RSP
    
    pushfq
    pop rax
    or rax, 0x200           ; Set IF
    push rax                ; RFLAGS
    
    push GDT64_USER_CODE    ; CS
    push rdi                ; RIP (Target address)

    ; Clear other segment registers
    mov ax, GDT64_USER_DATA
    mov ds, ax
    mov es, ax
    ; fs/gs usually set to 0 or handled by swapgs in a more complete OS
    

; --- Safe Call App in Ring 3 ---
; RDI = App function address
; RSI = Window pointer (passed as 1st arg to app fn)
; RDX = Client X (for click)
; RCX = Client Y (for click)
global call_app_l3
call_app_l3:
    SER 'A'
    push rbp
    mov rbp, rsp
    
    ; Save everything as we'll be switching stacks
    push rbx
    push r12
    push r13
    push r14
    push r15
    
    ; Save original kernel stack pointer for the syscall return
    mov [k_stack_save], rsp

    ; Print target RIP for debugging
    SER 'R'
    push rdi
    call ser_print_hex64
    pop rdi

    ; Prepare IRETQ frame to enter usermode at target address
    push GDT64_USER_DATA    ; SS
    lea rax, [user_stack_top]
    and rax, -16            ; Ensure 16-byte alignment
    push rax                ; User RSP
    
    pushfq
    pop rax
    or rax, 0x200           ; Set IF (Enable Interrupts in usermode)
    push rax                ; RFLAGS
    
    push GDT64_USER_CODE    ; CS
    push rdi                ; RIP (Target)
    
    ; Set arguments for the app function
    mov rdi, rsi            ; 1st arg: window ptr
    mov rsi, rdx            ; 2nd arg: client_x
    mov rdx, rcx            ; 3rd arg: client_y
    
    ; Data segments - Sanitize all to user data selector
    mov ax, GDT64_USER_DATA
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    
    iretq                   ; Transition to Ring 3

; This is where SYS_APP_DONE (10) returns
global call_app_l3_return
call_app_l3_return:
    ; Restore original kernel stack
    mov rsp, [k_stack_save]
    
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

section .data
k_stack_save: dq 0

; --- Dummy usermode code for testing ---
global test_usermode_proc
test_usermode_proc:
    ; Do not use HLT in Ring 3 - it is a privileged instruction
    jmp $
