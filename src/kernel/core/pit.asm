; ============================================================================
; NexusOS v3.0 - PIT Timer Driver
; ============================================================================
bits 64
%include "constants.inc"

extern fb_addr, main_loop_stage, main_loop_stage_done
extern scr_pitch_q, scr_width, scr_height

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
    push rdi
    push rcx

    inc qword [tick_count]

    ; --- HANG DEBUG: write main_loop_stage and stage_done to a known
    ; framebuffer location every PIT tick so we can SEE which call hung even
    ; when the main loop is stuck. Top-left of screen, 4 colored pixel groups:
    ;   group 0 (cyan/black)  : indicates "alive" - flashes each tick
    ;   group 1 (white)       : main_loop_stage value, 4 bits each
    ;   group 2 (yellow)      : main_loop_stage_done value, 4 bits each
    ; Each group is 32px wide (8px per nibble * 4 nibbles) = compact corner band.
    jmp .skip_dbg                ; debug pixel overlay disabled
    mov rdi, [fb_addr]
    test rdi, rdi
    jz .skip_dbg

    ; Group 0: alive flash (32 px). Color alternates per tick.
    mov eax, [tick_count]
    and eax, 1
    jz .blk
    mov eax, 0x0000FFFF              ; cyan
    jmp .fa
.blk:
    mov eax, 0x00000000              ; black
.fa:
    mov rcx, 32
.alive_lp:
    mov [rdi + rcx*4 - 4], eax
    dec rcx
    jnz .alive_lp

    ; Group 1: main_loop_stage as 8 colored pixels at fb+128..fb+156
    ; (each px = 1 bit, white=1 black=0)
    movzx eax, byte [main_loop_stage]
    mov rcx, 8
.stage_lp:
    mov edx, eax
    and edx, 1
    jz .stage_off
    mov dword [rdi + rcx*4 + 128 - 4], 0x00FFFFFF
    jmp .stage_next
.stage_off:
    mov dword [rdi + rcx*4 + 128 - 4], 0x00000000
.stage_next:
    shr eax, 1
    dec rcx
    jnz .stage_lp

    ; Group 2: main_loop_stage_done as 8 colored pixels at fb+192..fb+220
    movzx eax, byte [main_loop_stage_done]
    mov rcx, 8
.done_lp:
    mov edx, eax
    and edx, 1
    jz .done_off
    mov dword [rdi + rcx*4 + 192 - 4], 0x00FFFF00
    jmp .done_next
.done_off:
    mov dword [rdi + rcx*4 + 192 - 4], 0x00000000
.done_next:
    shr eax, 1
    dec rcx
    jnz .done_lp

    ; --- Big visible "last completed stage" block in top-right corner.
    ; 64x64 px solid color encodes main_loop_stage_done. Painted every PIT
    ; tick directly to the front framebuffer, so it persists even when the
    ; main loop has frozen and render_frame stops overpainting. If the loop
    ; is alive, you'll see this block flicker (render_frame keeps repainting
    ; over it between ticks); if it's frozen, the block stays solid and its
    ; color tells you which stage was the last to finish before the hang.
    push r8
    push r9
    push r10
    mov r9, [scr_pitch_q]
    test r9, r9
    jz .blk_done
    mov r10d, [scr_width]
    sub r10d, 72                      ; x = right - 72 (in pixels)
    js .blk_done
    shl r10d, 2                       ; -> bytes (4 bpp)
    movsxd r10, r10d
    ; row 8 from top (avoids overlap with row-0 nibble markers)
    mov r8, r9
    shl r8, 3                         ; pitch * 8
    add r8, r10
    add r8, rdi                       ; r8 = top-left of block in fb

    movzx eax, byte [main_loop_stage_done]
    ; Encode stage_done into a bright distinguishable color.
    ; stage 1 -> dark red, 2 -> red, 3 -> orange, 4 -> yellow, 5 -> green,
    ; 6 -> cyan, 7 -> blue, 8 -> magenta, 9 -> white, 10 -> bright green
    mov edx, eax
    shl edx, 5                        ; *32 = R component
    and edx, 0xE0
    mov ecx, eax
    shl ecx, 12                       ; *4096 = G component (bits 8..15)
    and ecx, 0xE000
    or edx, ecx
    or edx, 0x00303030                ; baseline so block is always visible

    mov r10d, 64                      ; row counter
.blk_row:
    mov rax, r8
    mov ecx, 64                       ; col counter
.blk_col:
    mov [rax], edx
    add rax, 4
    dec ecx
    jnz .blk_col
    add r8, r9
    dec r10d
    jnz .blk_row
.blk_done:
    pop r10
    pop r9
    pop r8
.skip_dbg:

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
    pop rcx
    pop rdi
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