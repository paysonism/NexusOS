section .data
global current_process_id
current_process_id: dd -1
next_pid:           dd 0

; ---------------------------------------------------------------------------
; Ring-3 callback deadman + reentrancy guard (BSP-only).
;
; dispatch_app_callback runs an app's click/draw handler inline on the BSP via
; call_app_l3. A `while(1){}` in that handler used to hang the whole OS. The
; deadman lets the PIT IRQ (which keeps firing on the BSP) longjmp back out of
; a runaway callback after a tick budget, mark the slot TERMINATED, and return
; -1 so the main loop survives.
;
; Globals exported for pit.asm / other code:
;   cb_deadman_armed       dd  0/1  - a callback is in flight & armed
;   cb_deadman_start_tick  dq       - tick_count when call_app_l3 was entered
;   cb_deadman_budget      dd       - tick budget (~250 ms @ ~100 Hz = 25)
;   cb_in_callback         dd  0/1  - reentrancy lock (refuse double-run)
;   cb_deadman_pid         dd       - pid of the slot being run (for fault mark)
;   cb_deadman_check       fn       - pit calls this; longjmps if over budget
align 64
global cb_deadman_armed
global cb_deadman_start_tick
global cb_deadman_budget
global cb_in_callback
global cb_deadman_pid
cb_deadman_armed:       dd 0
cb_in_callback:         dd 0
cb_deadman_pid:         dd 0
cb_deadman_budget:      dd 25            ; ~250 ms at the ~100 Hz PIT tick
cb_deadman_start_tick:  dq 0
; longjmp landing pad: kernel context captured just before call_app_l3.
cb_deadman_jmp_rsp:     dq 0
cb_deadman_jmp_rbx:     dq 0
cb_deadman_jmp_rbp:     dq 0
cb_deadman_jmp_rip:     dq 0

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
