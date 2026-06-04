%ifndef DEBUG_EVENTS_INC
%define DEBUG_EVENTS_INC

; Structured kernel forensic events.
;
; Use these directly at the code site that owns the fact:
;   DBG_EVT EVT_CALLBACK_DISPATCH, r15, rdi, rsi, rdx, rcx, 0, 0
;   DBG_EVT_IMPORTANT EVT_PANIC, r15, rdi, rsi, rdx, r10, 0, 0
;
; DBG_EVT is debug-build only. DBG_EVT_IMPORTANT is kept in release builds too.
; Both are one-line declarations with typed event ids; there is no side manifest
; to keep in sync and no serial string to grep for later.

DBG_EVT_RECORDS       equ 256
DBG_EVT_MASK          equ (DBG_EVT_RECORDS - 1)
DBG_EVT_RECORD_SIZE   equ 80

DBG_EVT_SEQ           equ 0
DBG_EVT_TSC           equ 8
DBG_EVT_ID            equ 16
DBG_EVT_SLOT          equ 24
DBG_EVT_A0            equ 32
DBG_EVT_A1            equ 40
DBG_EVT_A2            equ 48
DBG_EVT_A3            equ 56
DBG_EVT_A4            equ 64
DBG_EVT_A5            equ 72

; Event ids. Keep these four-byte ASCII where practical so dumps are readable.
EVT_PANIC             equ 0x50414E43      ; PANC
EVT_CPI_SIGN          equ 0x43504947      ; CPIG
EVT_CPI_VERIFY_FAIL   equ 0x43504956      ; CPIV
EVT_CALLBACK_DISPATCH equ 0x43424B44      ; CBKD
EVT_CALLBACK_RETURN   equ 0x43424B52      ; CBKR
EVT_APP_DONE          equ 0x41444F4E      ; ADON
EVT_WX_HASH_FAIL      equ 0x57435848      ; WCXH
EVT_FOCUS_CHANGE      equ 0x464F4353      ; FOCS
EVT_INPUT_ROUTE       equ 0x494E5054      ; INPT
EVT_SYSCALL_ENTER     equ 0x53594345      ; SYCE
EVT_SYSCALL_EXIT      equ 0x53594358      ; SYCX

%ifndef RELEASE_BUILD
%define ENABLE_DBG_EVT_FULL
%endif

%macro DBG_EVT_STORE 8
    push r11
    mov r11, %8
    push r11
    mov r11, %7
    push r11
    mov r11, %6
    push r11
    mov r11, %5
    push r11
    mov r11, %4
    push r11
    mov r11, %3
    push r11
    mov r11, %2
    push r11
    mov r11, %1
    push r11
    push rax
    push rbx
    push rcx
    push rdx
    push r10
    mov eax, 1
    lock xadd qword [rel dbg_evt_head], rax
    mov rbx, rax
    mov r10, rax
    and r10, DBG_EVT_MASK
    imul r10, DBG_EVT_RECORD_SIZE
    lea r10, [rel dbg_evt_ring + r10]
    mov [r10 + DBG_EVT_SEQ], rbx
    rdtsc
    shl rdx, 32
    or rax, rdx
    mov [r10 + DBG_EVT_TSC], rax
    mov r11, [rsp + 40]
    mov [r10 + DBG_EVT_ID], r11
    mov r11, [rsp + 48]
    mov [r10 + DBG_EVT_SLOT], r11
    mov r11, [rsp + 56]
    mov [r10 + DBG_EVT_A0], r11
    mov r11, [rsp + 64]
    mov [r10 + DBG_EVT_A1], r11
    mov r11, [rsp + 72]
    mov [r10 + DBG_EVT_A2], r11
    mov r11, [rsp + 80]
    mov [r10 + DBG_EVT_A3], r11
    mov r11, [rsp + 88]
    mov [r10 + DBG_EVT_A4], r11
    mov r11, [rsp + 96]
    mov [r10 + DBG_EVT_A5], r11
    pop r10
    pop rdx
    pop rcx
    pop rbx
    pop rax
    add rsp, 64
    pop r11
%endmacro

%macro DBG_EVT 8
%ifdef ENABLE_DBG_EVT_FULL
    DBG_EVT_STORE %1, %2, %3, %4, %5, %6, %7, %8
%endif
%endmacro

%macro DBG_EVT_IMPORTANT 8
    DBG_EVT_STORE %1, %2, %3, %4, %5, %6, %7, %8
%endmacro

%endif ; DEBUG_EVENTS_INC
