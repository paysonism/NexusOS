section .data
; --- DEBUG: USB mouse diagnostic counters (read by usb_debug_overlay) ---
global usb_dbg_evt, usb_dbg_psc, usb_dbg_err, usb_dbg_rpt
global usb_dbg_report, usb_dbg_errcode, usb_dbg_stage
global usb_dbg_stall_recov
usb_dbg_evt:     dd 0      ; transfer events delivered to poll loop
usb_dbg_psc:     dd 0      ; port-status-change events seen (reserved)
usb_dbg_err:     dd 0      ; error completion codes
usb_dbg_rpt:     dd 0      ; slot1 reports processed
usb_dbg_stall_recov: dd 0  ; successful per-EP STALL recoveries (no full reinit)
usb_dbg_report:  dd 0      ; last 4 raw report bytes
usb_dbg_errcode: db 0      ; last error completion code
; enumeration stage reached: 1=xhciOK 2=portOK 3=slotEnabled 4=addressed
; 5=devDesc 6=cfgDesc 7=endpointFound 8=configSet 9=epConfigured 10=active
usb_dbg_stage:   db 0
; cross-pass high-water mark of usb_dbg_stage; never reset, so it shows the
; furthest the boot pass got even after later retries reset usb_dbg_stage.
global usb_dbg_stage_max
usb_dbg_stage_max: db 0

global usb_mouse_active
global usb_no_xhci
global usb_hid_protocol, usb_ep_addr, usb_ep_mps, init_retry_counter
global usb_hid_protocol2
global usb_slot1_id, usb_slot2_active
global usb_slot1_port, usb_slot2_port
global usb_hid_port_owned
usb_mouse_active: db 0
usb_no_xhci:      db 0           ; 1 = no XHCI hardware found, stop retrying
usb_hid_protocol: db 0
usb_device_vid:   dw 0
usb_device_pid:   dw 0
usb_ep_addr:      db 0
usb_ep_mps:       dw 0
usb_ep_interval:  db 0
usb_interface_num: db 0
init_retry_counter:  dd 0
spp_portsc_counter:  dd 0
usb_ctrl_attempts: db 0          ; Number of XHCI controllers tried this init cycle

; Slot 1 saved state (used when init-ing slot 2)
usb_slot1_id:     db 0
usb_int_ep1_dci:  db 0
usb_slot1_port:   db 0           ; 1-based xHCI port number for slot1 (0 = unused)
usb_slot2_port:   db 0           ; 1-based xHCI port number for slot2 (0 = unused)

usb_use_parsed:   db 0           ; 1 = HID report descriptor parsed
usb_accept_keyboard: db 0        ; 0 = primary probe wants pointer HID, 1 = allow keyboard
usb_primary_keyboard_fallback: db 0 ; retry primary probe accepting keyboard
usb_find_report_hid: db 0        ; 1 = second pass may claim report-protocol HID

; Slot 2 device info
usb_slot2_active: db 0
usb_slot2_id:     db 0
usb_int_ep2_dci:  db 0
usb_ep2_addr:     db 0
usb_ep2_mps:      dw 0
usb_ep2_interval: db 0
usb_interface2_num: db 0
usb_hid_protocol2: db 0

; USB keyboard state
usb_kb_prev_mods: db 0

; USB HID keycode -> PS/2 scancode translation table (256 bytes)
; Maps USB HID boot protocol keycodes to PS/2 scancode set 1 equivalents.
; Extended PS/2 scancodes (arrows, nav keys) stored with bit7 set (e.g. 0xC8=Up).
usb_hid_to_ps2:
    ; 0x00-0x03: no key, error, post fail
    db 0, 0, 0, 0
    ; 0x04-0x1D: a-z (USB alphabetical order -> PS/2 scancodes)
    db 0x1E, 0x30, 0x2E, 0x20, 0x12, 0x21, 0x22, 0x23  ; a b c d e f g h
    db 0x17, 0x24, 0x25, 0x26, 0x32, 0x31, 0x18, 0x19  ; i j k l m n o p
    db 0x10, 0x13, 0x1F, 0x14, 0x16, 0x2F, 0x11, 0x2D  ; q r s t u v w x
    db 0x15, 0x2C                                        ; y z
    ; 0x1E-0x27: 1-9, 0
    db 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B
    ; 0x28-0x2C: Enter, Esc, Backspace, Tab, Space
    db 0x1C, 0x01, 0x0E, 0x0F, 0x39
    ; 0x2D-0x38: - = [ ] \ (non-US) ; ' ` , . /
    db 0x0C, 0x0D, 0x1A, 0x1B, 0x2B, 0x00, 0x27, 0x28, 0x29, 0x33, 0x34, 0x35
    ; 0x39: CapsLock
    db 0x3A
    ; 0x3A-0x45: F1-F12
    db 0x3B, 0x3C, 0x3D, 0x3E, 0x3F, 0x40, 0x41, 0x42, 0x43, 0x44, 0x57, 0x58
    ; 0x46-0x48: PrintScreen, ScrollLock, Pause
    db 0, 0, 0
    ; 0x49-0x4E: Insert, Home, PageUp, Delete, End, PageDown
    db 0xD2, 0xC7, 0xC9, 0xD3, 0xCF, 0xD1
    ; 0x4F-0x52: Right, Left, Down, Up (extended PS/2)
    db 0xCD, 0xCB, 0xD0, 0xC8
    ; 0x53: NumLock, 0x54-0x63: numpad / * - + Enter 1-9 0 .
    db 0x45, 0xB5, 0x37, 0x4A, 0x9C, 0x4F, 0x50, 0x51, 0x4B, 0x4C, 0x4D, 0x47, 0x48, 0x49, 0x52, 0x53
    ; 0x64-0xFF: fill rest with 0
    times (256 - 0x64) db 0

section .bss
usb_kb_prev_keys: resb 6

section .text
; ============================================================================
; usb_hid_port_owned - returns EAX=1 if 1-based port in DIL is claimed by an
; active HID slot (slot1 or slot2), EAX=0 otherwise.
; ============================================================================
usb_hid_port_owned:
    xor eax, eax
    test dil, dil
    jz .no
    cmp byte [usb_mouse_active], 1
    jne .check2
    cmp dil, [usb_slot1_port]
    jne .check2
    mov eax, 1
    ret
.check2:
    cmp byte [usb_slot2_active], 1
    jne .no
    cmp dil, [usb_slot2_port]
    jne .no
    mov eax, 1
.no:
    ret

; ============================================================================
; usb_parse_keyboard_report - Parse USB HID boot keyboard report, push to kb_buffer
; RSI = 8-byte report: [modifier, reserved, key0..key5]
; ============================================================================
usb_parse_keyboard_report:
    push rbx
    push rcx
    push rdx
    push rdi
    push r8
    push r9
    push r10

    ; 1. Map USB HID modifier byte to KMOD_* and update kb_modifiers
    movzx r9d, byte [rsi]       ; r9 = current modifier byte
    mov bl, 0
    test r9b, 0x02              ; LShift
    jz .no_ls
    or bl, KMOD_SHIFT
.no_ls:
    test r9b, 0x20              ; RShift
    jz .no_rs
    or bl, KMOD_SHIFT
.no_rs:
    test r9b, 0x01              ; LCtrl
    jz .no_lc
    or bl, KMOD_CTRL
.no_lc:
    test r9b, 0x10              ; RCtrl
    jz .no_rc
    or bl, KMOD_CTRL
.no_rc:
    test r9b, 0x04              ; LAlt
    jz .no_la
    or bl, KMOD_ALT
.no_la:
    test r9b, 0x40              ; RAlt
    jz .no_ra
    or bl, KMOD_ALT
.no_ra:
    mov [kb_modifiers], bl
    mov [usb_kb_prev_mods], r9b

    ; 2. For each of the 6 keycode slots, push new presses to kb_buffer
    mov r10d, 0                 ; slot index 0..5
.key_loop:
    cmp r10d, 6
    jge .keys_done

    movzx eax, byte [rsi + r10 + 2]  ; current keycode
    inc r10d
    cmp al, 1
    jle .key_loop               ; skip 0 (no key) and 1 (error)

    ; Check if this keycode was in the previous report (held = skip)
    mov r8d, 0                  ; prev-key search index
.find_prev:
    cmp r8d, 6
    jge .is_new_press
    cmp al, [usb_kb_prev_keys + r8]
    je .key_loop                ; found in prev -> already held, skip
    inc r8d
    jmp .find_prev

.is_new_press:
    ; Translate USB HID keycode to PS/2 scancode
    movzx ecx, al               ; USB HID keycode
    movzx ecx, byte [usb_hid_to_ps2 + ecx]
    test ecx, ecx
    jz .key_loop                ; no mapping

    ; Get ASCII from PS/2 scancode tables
    cmp ecx, 128
    jge .push_ext_key           ; extended scancode (arrows etc.) -> ASCII=0

    test byte [kb_modifiers], KMOD_SHIFT
    jz .use_normal
    movzx edx, byte [scancode_shifted + ecx]
    jmp .push_event
.use_normal:
    movzx edx, byte [scancode_normal + ecx]

.push_event:
    ; Push [scancode, ascii, modifiers, pressed=1] to kb_buffer
    push rcx
    push rdx
    mov r8d, [kb_tail]
    mov r9d, r8d
    shl r9d, 2
    lea rdi, [kb_buffer + r9]
    mov [rdi], cl               ; PS/2 scancode
    mov [rdi + 1], dl           ; ASCII
    mov dl, [kb_modifiers]
    mov [rdi + 2], dl           ; modifiers
    mov byte [rdi + 3], 1       ; pressed
    inc r8d
    and r8d, (KB_BUFFER_SIZE - 1)
    mov [kb_tail], r8d
    pop rdx
    pop rcx
    jmp .key_loop

.push_ext_key:
    xor edx, edx                ; ASCII=0 for extended keys
    jmp .push_event

.keys_done:
    ; Copy current keycodes to prev_keys
    mov r8d, 0
.copy_loop:
    cmp r8d, 6
    jge .copy_done
    movzx eax, byte [rsi + r8 + 2]
    mov [usb_kb_prev_keys + r8], al
    inc r8d
    jmp .copy_loop
.copy_done:

    pop r10
    pop r9
    pop r8
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    ret

szUsbFindPort   db "USB: Finding Port...", 0
szUsbEnableSlot db "USB: Enabling Slot...", 0
szUsbAddress    db "USB: Addressing Device...", 0
szUsbGetDesc    db "USB: Getting Descriptor...", 0
szUsbConfig     db "USB: Getting Config...", 0

usb_log_name        db "USBLOG  TXT"
szUsbLogHeader     db "USB HID probe log", 0
szUsbExpectedMouse db "Windows OK mouse: VID_17EF PID_602E mouhid", 0
szUsbLogXhciOk     db "XHCI init OK", 0
szUsbLogNoXhci     db "No more XHCI controllers", 0
szUsbLogNoPort     db "No connected port on controller", 0
szUsbLogPort       db "Port=0x", 0
szUsbLogSpeed      db "Speed=0x", 0
szUsbLogSlot       db "Slot=0x", 0
szUsbLogVid        db "VID=0x", 0
szUsbLogPid        db "PID=0x", 0
szUsbLogProto      db "HID protocol=0x", 0
szUsbLogEp         db "Interrupt IN EP=0x", 0
szUsbLogMps        db "MPS=0x", 0
szUsbLogInterval   db "Interval=0x", 0
szUsbLogConfigured db "Set configuration OK", 0
szUsbLogActive     db "USB mouse active", 0
szUsbLogFail       db "USB HID init failed", 0

USB_LOG_BUF_SIZE   equ 4096
usb_log_len        dd 0
usb_log_buf        times USB_LOG_BUF_SIZE db 0
