section .data
global mouse_x, mouse_y, mouse_buttons, mouse_moved
global mouse_sense_x, mouse_sense_y

; Per-axis pointer sensitivity, fixed-point in tenths (10 = 1.0x). The Settings
; Mouse tab adjusts these over [1, 50] = 0.1x .. 5.0x via SYS_SET_MOUSE_SENSE.
; Applied to every relative pointer delta (USB mouse + I2C touchpad):
;   out_delta = in_delta * sense / 10  (see mouse_apply_sense_* below).
; Default 15 (1.5x): real-HW I2C touchpad deltas are smaller than PS/2 counts.
mouse_sense_x:      dd 15
mouse_sense_y:      dd 15

global mouse_init_status
mouse_init_status:  db 0
mouse_x:            dd (SCREEN_WIDTH / 2)
mouse_y:            dd (SCREEN_HEIGHT / 2)
mouse_buttons:      db 0
mouse_moved:        db 0
mouse_cycle:        db 0
mouse_im_mode:      db 0        ; 1 = Intellimouse 4-byte packets (scroll wheel)
mouse_packet:       db 0, 0, 0, 0
mouse_evt_head:     dd 0
mouse_evt_tail:     dd 0
mouse_irq_count:    db 0

; Debug data saved during init
mouse_dbg_ccb:          db 0
mouse_dbg_ccb_final:    db 0
mouse_dbg_selftest:     db 0
mouse_dbg_port2test:    db 0
mouse_dbg_reset_ack:    db 0
mouse_dbg_reset_result: db 0
mouse_dbg_device_id:    db 0
mouse_dbg_raw:          db 0, 0, 0

section .bss
mouse_evt_buffer:   resb (MOUSE_BUFFER_SIZE * 16)
