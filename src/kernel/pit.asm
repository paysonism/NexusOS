; ============================================================================
; NexusOS v3.0 - PIT Timer Driver
; ============================================================================
bits 64
%include "constants.inc"

section .text
global pit_init
pit_init:
    mov al, 0x36
    out 0x43, al
    mov ax, PIT_DIVISOR
    out 0x40, al
    mov al, ah
    out 0x40, al

    mov qword [tick_count], 0
    mov dword [sub_ticks], 0
    mov dword [time_seconds], 0
    mov dword [time_minutes], 0
    mov dword [time_hours], 12
    ret

global pit_handler
pit_handler:
    push rax
    push rdx

    inc qword [tick_count]

    inc dword [sub_ticks]
    cmp dword [sub_ticks], PIT_FREQUENCY
    jl .done

    mov dword [sub_ticks], 0
    inc dword [time_seconds]
    cmp dword [time_seconds], 60
    jl .done

    mov dword [time_seconds], 0
    inc dword [time_minutes]
    cmp dword [time_minutes], 60
    jl .done

    mov dword [time_minutes], 0
    inc dword [time_hours]
    cmp dword [time_hours], 24
    jl .done
    mov dword [time_hours], 0

.done:
    pop rdx
    pop rax
    ret

; --- src/kernel/pit.asm (BOTTOM SECTION) ---
section .data
align 16
global tick_count, last_fps, frame_count, start_tick, time_hours, time_minutes

tick_count:     dq 0
sub_ticks:      dd 0
time_seconds:   dd 0
time_minutes:   dd 0
time_hours:     dd 12
fps_count:      dd 0
last_fps:       dd 0
frame_count:    dd 0
start_tick:     dq 0