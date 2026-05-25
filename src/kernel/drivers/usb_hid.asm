; ============================================================================
; NexusOS v3.0 - USB HID Mouse Driver
; Implements USB HID protocol over XHCI
; ============================================================================
bits 64

%include "constants.inc"

; DEBUG: set current enumeration stage and bump the cross-pass high-water mark.
; usb_dbg_stage is reset to 0 each usb_hid_init pass; usb_dbg_stage_max is NOT,
; so it records the furthest any pass ever reached (boot pass included).
%macro STAGE 1
    mov byte [usb_dbg_stage], %1
    cmp byte [usb_dbg_stage_max], %1
    jae %%no_bump
    mov byte [usb_dbg_stage_max], %1
%%no_bump:
%endmacro

extern xhci_init
extern xhci_submit_cmd
extern xhci_queue_ctrl_trb
extern xhci_queue_int_trb
extern xhci_queue_int_trb2
extern xhci_ring_doorbell
extern xhci_poll_event
extern xhci_find_port
extern xhci_find_port_next
extern xhci_enable_slot
extern xhci_address_device
extern xhci_disable_slot
extern xhci_flush_events
extern xhci_pci_search_start
extern xhci_pci_this_start
extern xhci_probe
extern xhci_slot_id
extern xhci_slot2_mode
extern xhci_int_ep_dci
extern xhci_slot2_id
extern xhci_int_ep2_dci
extern xhci_int_enqueue2
extern xhci_int_cycle2
extern xhci_port_num
extern xhci_port_speed
extern xhci_op_base
extern xhci_max_ports
extern xhci_port1_num
extern debug_print
extern fat16_write_file
extern hid_parse_report_desc
extern hid_process_touchpad_report
extern hid_parsed_report_bytes
extern hid_parsed_has_report_id

extern mouse_x
extern mouse_y
extern mouse_buttons
extern mouse_moved
extern mouse_scroll_y
extern scr_width, scr_height
extern tick_count

section .text
; auto-wrapped (FN_BEGIN emits global): global usb_hid_init
; auto-wrapped (FN_BEGIN emits global): global usb_hid_init_same_ctrl
; auto-wrapped (FN_BEGIN emits global): global usb_hid_init_slot2
; auto-wrapped (FN_BEGIN emits global): global usb_poll_mouse
; auto-wrapped (FN_BEGIN emits global): global usb_hid_flush_log

; ============================================================================
; USB probe log helpers. This is intentionally narrow: it persists the HID/xHCI
; probe path to USBLOG.TXT on the Nexus FAT data volume for real-hardware boots.
; ============================================================================
usb_log_ch:
    push rbx
    push rcx
    mov ebx, [usb_log_len]
    cmp ebx, USB_LOG_BUF_SIZE - 2
    jae .done
    mov [usb_log_buf + rbx], al
    inc ebx
    mov [usb_log_len], ebx
.done:
    pop rcx
    pop rbx
    ret

usb_log_str:
    push rax
    push rsi
.loop:
    lodsb
    test al, al
    jz .done
    call usb_log_ch
    jmp .loop
.done:
    pop rsi
    pop rax
    ret

usb_log_crlf:
    push rax
    mov al, 13
    call usb_log_ch
    mov al, 10
    call usb_log_ch
    pop rax
    ret

usb_log_hex_nib:
    and al, 0x0F
    cmp al, 10
    jb .digit
    add al, 'A' - 10
    jmp usb_log_ch
.digit:
    add al, '0'
    jmp usb_log_ch

usb_log_hex8:
    push rax
    shr al, 4
    call usb_log_hex_nib
    pop rax
    push rax
    call usb_log_hex_nib
    pop rax
    ret

usb_log_hex16:
    push rax
    shr ax, 8
    call usb_log_hex8
    pop rax
    push rax
    call usb_log_hex8
    pop rax
    ret

usb_log_hex32:
    push rax
    shr eax, 16
    call usb_log_hex16
    pop rax
    push rax
    call usb_log_hex16
    pop rax
    ret

usb_log_kv8:
    call usb_log_str
    mov al, bl
    call usb_log_hex8
    call usb_log_crlf
    ret

usb_log_kv16:
    call usb_log_str
    mov ax, bx
    call usb_log_hex16
    call usb_log_crlf
    ret

usb_hid_flush_log:
    push rbx
    push rdx
    push rdi
    push rsi
    cmp dword [usb_log_len], 0
    je .ret
    mov ebx, [usb_log_len]
    cmp ebx, USB_LOG_BUF_SIZE
    jae .cap
    mov byte [usb_log_buf + rbx], 0
.cap:
    lea rdi, [rel usb_log_name]
    lea rsi, [rel usb_log_buf]
    mov edx, [usb_log_len]
    call fat16_write_file
.ret:
    pop rsi
    pop rdi
    pop rdx
    pop rbx
    ret

; ============================================================================
; usb_hid_init_same_ctrl - Re-enumerate on the currently active XHCI controller
; Used for hot-plug: device was unplugged and re-plugged on the same port/controller
; ============================================================================
FN_BEGIN usb_hid_init_same_ctrl, 0, 0, FN_RET_SCALAR
    ; Restore xhci_pci_search_start to the position of the current controller
    ; so xhci_pci_find will re-find the same one
    mov eax, [xhci_pci_this_start]
    mov [xhci_pci_search_start], eax
    jmp usb_hid_init_body

; ============================================================================
; usb_hid_init - Initialize USB HID Mouse (full scan from controller 0)
; ============================================================================
FN_BEGIN usb_hid_init, 0, 0, FN_RET_SCALAR
    ; Reset PCI search to beginning so we scan all controllers fresh
    mov dword [xhci_pci_search_start], 0

usb_hid_init_body:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push rbp

    ; Reset active flag
    mov byte [usb_mouse_active], 0
    mov byte [usb_dbg_stage], 0
    mov byte [usb_use_parsed], 0
    mov byte [usb_interface_num], 0
    mov byte [usb_accept_keyboard], 0
    mov byte [usb_primary_keyboard_fallback], 0
    mov word [usb_device_vid], 0
    mov word [usb_device_pid], 0
    mov dword [usb_log_len], 0
    lea rsi, [rel szUsbLogHeader]
    call usb_log_str
    call usb_log_crlf
    lea rsi, [rel szUsbExpectedMouse]
    call usb_log_str
    call usb_log_crlf

    ; 1. Try XHCI controllers until one succeeds with a HID endpoint
    ;    xhci_pci_find continues from where it left off each call
    mov byte [usb_ctrl_attempts], 0
    mov byte [usb_no_xhci], 0   ; Assume XHCI might exist until proven otherwise
    jmp .try_next_controller

.try_next_port:
    ; Not HID on current port. Scan remaining ports on same controller
    ; before giving up and calling xhci_init for the next controller.
    ; This handles the case where a boot USB drive is on port 0 and
    ; the mouse is on a subsequent port of the same xHCI controller.
    mov rsi, [xhci_op_base]
    add rsi, 0x400                      ; Port register base
    movzx ecx, byte [xhci_max_ports]
    movzx edx, byte [xhci_port_num]     ; 1-based last tried → 0-based next to check
.tport_scan:
    cmp edx, ecx
    jge .try_next_controller            ; No more ports on this controller
    mov eax, edx
    shl eax, 4
    mov ebx, [rsi + rax + XHCI_PORTSC]
    test ebx, XHCI_PORTSC_CCS
    jz .tport_next
    ; Skip the rtl8156 NIC's port if it's bound.
    extern rtl8156_active, rtl8156_port
    cmp byte [rtl8156_active], 1
    jne .tport_not_nic
    movzx r10d, byte [rtl8156_port]
    lea r11d, [edx + 1]
    cmp r10d, r11d
    je .tport_next
.tport_not_nic:
    ; Found a port with a connected device
    lea ecx, [edx + 1]
    mov [xhci_port_num], cl             ; Save 1-based port number
    ; Save speed
    shr ebx, XHCI_PORTSC_SPEED_SHIFT
    and ebx, 0x0F
    mov [xhci_port_speed], bl
    ; Reset the port so device can be enumerated
    push rax                            ; save port byte offset across reload
    mov rsi, [xhci_op_base]
    add rsi, 0x400
    pop rax
    mov ebx, [rsi + rax + XHCI_PORTSC]
    and ebx, ~XHCI_PORTSC_CHANGE_BITS
    and ebx, ~XHCI_PORTSC_PED
    or  ebx, XHCI_PORTSC_PR
    mov [rsi + rax + XHCI_PORTSC], ebx
    ; Wait for PRC (Port Reset Change) with 50-tick timeout
    ; Recompute port offset each iteration from xhci_port_num
    mov rbx, [tick_count]
    add rbx, 50
    mov r9d, 10000000
.tport_wait_prc:
    movzx eax, byte [xhci_port_num]
    dec eax
    shl eax, 4
    mov rsi, [xhci_op_base]
    add rsi, 0x400
    mov edx, [rsi + rax + XHCI_PORTSC]
    test edx, XHCI_PORTSC_PRC
    jnz .tport_reset_done
    
    dec r9d
    jz .tport_reset_done
    
    mov rax, [tick_count]
    cmp rax, rbx
    jge .tport_reset_done               ; timeout - proceed anyway
    pause
    jmp .tport_wait_prc
.tport_reset_done:
    ; Clear PRC. PED is RW1C on xHCI PORTSC, so writing back PED=1 disables
    ; the port on real hardware. Mask it out and only write the change bit.
    movzx eax, byte [xhci_port_num]
    dec eax
    shl eax, 4
    mov rsi, [xhci_op_base]
    add rsi, 0x400
    mov ebx, [rsi + rax + XHCI_PORTSC]
    and ebx, ~XHCI_PORTSC_CHANGE_BITS
    and ebx, ~XHCI_PORTSC_PED
    or  ebx, XHCI_PORTSC_PRC
    mov [rsi + rax + XHCI_PORTSC], ebx
    ; Read updated speed after reset
    mov ebx, [rsi + rax + XHCI_PORTSC]
    shr ebx, XHCI_PORTSC_SPEED_SHIFT
    and ebx, 0x0F
    mov [xhci_port_speed], bl
    jmp .do_enable_slot
.tport_next:
    inc edx
    jmp .tport_scan

.try_next_controller:
    inc byte [usb_ctrl_attempts]
    cmp byte [usb_ctrl_attempts], 4    ; Max 4 XHCI controllers to try
    jg .fail

    ; On the FIRST attempt only, reuse an already-active controller (e.g. one
    ; brought up by rtl8156 before us) instead of resetting it. On subsequent
    ; attempts we have already exhausted that controller's ports without
    ; finding a HID device, so force a fresh xhci_init — this advances the
    ; PCI scan (xhci_pci_search_start) to the NEXT controller. AMD Strix
    ; Point and similar platforms expose multiple xHCI PCI functions; the
    ; mouse may live on the second or third one.
    cmp byte [usb_ctrl_attempts], 1
    jne .force_init
    cmp byte [xhci_active], 1
    je .xhci_ok
.force_init:
    mov byte [xhci_active], 0          ; allow xhci_init to take fresh ctrl
    call xhci_init
    test eax, eax
    jnz .xhci_ok
    lea rsi, [rel szUsbLogNoXhci]
    call usb_log_str
    call usb_log_crlf
    jmp .no_hw                  ; No more XHCI controllers found (PCI scan exhausted)
.xhci_ok:
    STAGE 1
    lea rsi, [rel szUsbLogXhciOk]
    call usb_log_str
    call usb_log_crlf

    ; Wait for device to settle after port reset.
    ; USB spec: 100ms, but 50ms is enough for QEMU/most real devices.
    mov ecx, 50
    call usb_delay

    mov rsi, szUsbFindPort
    call usb_log_str
    call usb_log_crlf
    call debug_print

    ; --- 1. Find Port with Device ---
    call xhci_find_port
    test eax, eax
    jnz .port_ok
    lea rsi, [rel szUsbLogNoPort]
    call usb_log_str
    call usb_log_crlf
    jmp .try_next_controller
.port_ok:
    STAGE 2
    lea rsi, [rel szUsbLogPort]
    movzx ebx, byte [xhci_port_num]
    call usb_log_kv8
    lea rsi, [rel szUsbLogSpeed]
    movzx ebx, byte [xhci_port_speed]
    call usb_log_kv8

.do_enable_slot:
    mov rsi, szUsbEnableSlot
    call usb_log_str
    call usb_log_crlf
    call debug_print

    ; --- 2. Enable Slot ---
    call xhci_enable_slot
    test eax, eax
    jz .try_next_port
    STAGE 3
    lea rsi, [rel szUsbLogSlot]
    movzx ebx, byte [xhci_slot_id]
    call usb_log_kv8

    mov rsi, szUsbAddress
    call usb_log_str
    call usb_log_crlf
    call debug_print

    ; --- 3. Address Device ---
    call xhci_address_device
    test eax, eax
    jz .release_slot_try_next_port
    STAGE 4

    mov rsi, szUsbGetDesc
    call usb_log_str
    call usb_log_crlf
    call debug_print

    ; Serial: 'H' (HID Init)
    mov dx, 0x3F8
    mov al, 'H'
    out dx, al

    ; 4. Get Device Descriptor (to verify it's a mouse? or just to debug)
    ; Request: 80 06 00 01 00 00 12 00 (Get Descriptor Device, len 18)
    mov rdi, XHCI_CTRL_BUF_ADDR
    mov rcx, 18
    mov r8d, 0x01000680      ; Low dword of setup packet (GetDesc Device)
    mov r9d, 0x00120000      ; High dword (Len 18)
    call usb_control_transfer_in
    test eax, eax
    jz .release_slot_try_next_port  ; Failed to get descriptor - try next port
    STAGE 5
    movzx ebx, word [abs XHCI_CTRL_BUF_ADDR + 8]
    mov [usb_device_vid], bx
    lea rsi, [rel szUsbLogVid]
    movzx ebx, word [usb_device_vid]
    call usb_log_kv16
    movzx ebx, word [abs XHCI_CTRL_BUF_ADDR + 10]
    mov [usb_device_pid], bx
    lea rsi, [rel szUsbLogPid]
    movzx ebx, word [usb_device_pid]
    call usb_log_kv16

    ; Serial: 'D' (Descriptor)
    mov dx, 0x3F8
    mov al, 'D'
    out dx, al
    
    mov rsi, szUsbConfig
    call usb_log_str
    call usb_log_crlf
    call debug_print

    ; 5. Get Configuration Descriptor (first 9 bytes to get total length)
    ; Request: 80 06 00 02 00 00 09 00
    mov rdi, XHCI_CTRL_BUF_ADDR
    mov rcx, 9
    mov r8d, 0x02000680
    mov r9d, 0x00090000
    call usb_control_transfer_in
    test eax, eax
    jz .release_slot_try_next_port
    
    ; Read TotalLength from offset 2
    movzx ecx, word [abs XHCI_CTRL_BUF_ADDR + 2]
    
    ; 6. Get Full Configuration Descriptor
    mov rdi, XHCI_CTRL_BUF_ADDR
    ; rcx is already len
    mov r8d, 0x02000680
    mov r9d, ecx
    shl r9d, 16              ; Len in upper word
    call usb_control_transfer_in
    test eax, eax
    jz .release_slot_try_next_port
    STAGE 6

    ; 7. Parse Configuration Descriptor to find Interrupt Endpoint.
    ; Prefer boot-mouse protocol first; generic report-HID is a fallback so
    ; composite vendor/control interfaces do not mask the real mouse.
    mov byte [usb_find_report_hid], 0
    call usb_find_endpoint
    test eax, eax
    jnz .endpoint_ok
    mov byte [usb_find_report_hid], 1
    call usb_find_endpoint
    test eax, eax
    jnz .endpoint_ok
    call usb_try_known_mouse_endpoint
    test eax, eax
    jnz .endpoint_ok
    ; Not a HID device on this port. The slot is still enabled+addressed and
    ; the port is bound to it. Release the slot so a later driver (rtl8156)
    ; can address the same port without TRB Error.
    mov al, [xhci_slot_id]
    call xhci_disable_slot
    jmp .try_next_port

.release_slot_try_next_port:
    mov al, [xhci_slot_id]
    call xhci_disable_slot
    jmp .try_next_port
.endpoint_ok:
    STAGE 7
    lea rsi, [rel szUsbLogProto]
    movzx ebx, byte [usb_hid_protocol]
    call usb_log_kv8
    lea rsi, [rel szUsbLogEp]
    movzx ebx, byte [usb_ep_addr]
    call usb_log_kv8
    lea rsi, [rel szUsbLogMps]
    movzx ebx, word [usb_ep_mps]
    call usb_log_kv16
    lea rsi, [rel szUsbLogInterval]
    movzx ebx, byte [usb_ep_interval]
    call usb_log_kv8

    ; Serial: 'E' (Endpoint Found)
    mov dx, 0x3F8
    mov al, 'E'
    out dx, al

    ; 6. Set Configuration (Value = 1)
    ; Request: 00 09 01 00 00 00 00 00
    mov r8d, 0x00010900
    mov r9d, 0x00000000
    call usb_control_transfer_nodata
    test eax, eax
    jz .fail
    STAGE 8
    lea rsi, [rel szUsbLogConfigured]
    call usb_log_str
    call usb_log_crlf

    ; Serial: 'C' (Config Set)
    mov dx, 0x3F8
    mov al, 'C'
    out dx, al

    ; Set boot protocol for keyboard (1) and mouse (2); skip for report protocol (0)
    cmp byte [usb_hid_protocol], 0
    je .skip_set_protocol

    ; 7. Set Protocol (Value = 0 for Boot Protocol)
    ; Request: 21 0B 00 00 00 00 00 00 (SET_PROTOCOL)
    mov r8d, 0x00000B21
    movzx r9d, byte [usb_interface_num]
    call usb_control_transfer_nodata
    
    ; 8. Set Idle (Value = 0 for infinite duration)
    ; Request: 21 0A 00 00 00 00 00 00 (SET_IDLE)
    mov r8d, 0x00000A21
    movzx r9d, byte [usb_interface_num]
    call usb_control_transfer_nodata

.skip_set_protocol:

    ; 8b. Fetch HID Report Descriptor (type 0x22) for precise field layout
    ; GET_DESCRIPTOR: bmRequestType=0x81, bRequest=0x06, wValue=0x2200
    ; wIndex=matched interface, wLength=512
    mov rdi, XHCI_CTRL_BUF_ADDR
    mov rcx, 512
    mov r8d, 0x22000681         ; bmRequestType=0x81, GET_DESCRIPTOR, wValue=0x2200
    movzx r9d, byte [usb_interface_num]
    or r9d, 0x02000000          ; wIndex=matched interface, wLength=512
    call usb_control_transfer_in
    test eax, eax
    jz .skip_hid_parse          ; If it fails, fall through to boot protocol

    ; Parse the HID report descriptor
    mov rsi, XHCI_CTRL_BUF_ADDR
    mov ecx, 512
    call hid_parse_report_desc
    test eax, eax
    jz .skip_hid_parse
    ; Only use touchpad path for absolute digitizer (touchpad) devices.
    ; Simple mice, tablets, and keyboards use fixed-format paths.
    cmp byte [hid_parsed_is_absolute], 1
    jne .skip_hid_parse
    mov byte [usb_use_parsed], 1

.skip_hid_parse:

    ; 9. Configure Endpoint in XHCI
    ; EDI = EP num, ESI = MPS, EDX = Interval
    movzx edi, byte [usb_ep_addr]
    and edi, 0x7F            ; Clear direction bit (0x81 -> 1)
    movzx esi, word [usb_ep_mps]
    movzx edx, byte [usb_ep_interval]
    
    ; Debug: log EP, MPS, Interval
    ; ...
    
    call xhci_configure_endpoint
    test eax, eax
    jz .fail
    STAGE 9

    ; Serial: 'O' (OK)
    mov dx, 0x3F8
    mov al, 'O'
    out dx, al

    ; 10. Flush any pending events (like Port Status Changes from init)
    ; Do this BEFORE queuing mouse transfers so we don't flush their completion events!
    call xhci_flush_events

    mov byte [usb_mouse_active], 1
    STAGE 10
    lea rsi, [rel szUsbLogActive]
    call usb_log_str
    call usb_log_crlf

    ; Save slot1 info before possibly init-ing slot2
    mov al, [xhci_slot_id]
    mov [usb_slot1_id], al
    mov al, [xhci_int_ep_dci]
    mov [usb_int_ep1_dci], al
    mov al, [xhci_port_num]
    mov [usb_slot1_port], al

    ; Try to find and init a second USB HID device on a different port.
    ; IMPORTANT: do this BEFORE queuing slot1 reads so that slot2 control
    ; transfers don't race with slot1 Transfer Events in usb_wait_completion.
    call usb_hid_init_slot2     ; non-fatal - ignore return value

    ; 11. Queue initial interrupt transfers for slot1 (fill pipeline)
    ; Done after slot2 init so slot2 control transfers see a clean event ring.
    call usb_queue_mouse_read
    call usb_queue_mouse_read
    call usb_queue_mouse_read
    call usb_queue_mouse_read

    pop rbp
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    mov eax, 1
    ret

    ret

.no_hw:
    ; xhci_init returned 0 = no XHCI controller found in PCI scan.
    ; Mark as no hardware so usb_poll_mouse stops retrying.
    mov byte [usb_no_xhci], 1

.fail:
    ; Primary probing prefers pointer HID so a keyboard on an earlier port does
    ; not hide the mouse. If no pointer was usable, retry once accepting a boot
    ; keyboard as slot1; keyboard-only and keyboard-first hardware still needs
    ; an interrupt ring so usb_poll_mouse can feed the keyboard parser.
    cmp byte [usb_no_xhci], 1
    je .fail_final
    cmp byte [usb_primary_keyboard_fallback], 0
    jne .fail_final
    mov byte [usb_primary_keyboard_fallback], 1
    mov byte [usb_accept_keyboard], 1
    mov byte [usb_ctrl_attempts], 0
    mov dword [xhci_pci_search_start], 0
    jmp .try_next_controller

.fail_final:
    ; Serial: 'X' (Fail)
    lea rsi, [rel szUsbLogFail]
    call usb_log_str
    call usb_log_crlf
    mov dx, 0x3F8
    mov al, 'X'
    out dx, al

    pop rbp
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    xor eax, eax
    ret

; ============================================================================
; usb_delay - Hybrid PIT/Spin delay (safe against PIT timer freezes)
; Input: ECX = milliseconds
; ============================================================================
usb_delay:
    push rax
    push rbx
    push rcx
    push rdx

    ; Calculate PIT target (1 tick = 10ms)
    mov eax, ecx
    add eax, 9
    xor edx, edx
    mov ebx, 10
    div ebx
    test eax, eax
    jnz .start
    mov eax, 1

.start:
    mov rbx, rax
    mov rax, [tick_count]
    add rbx, rax         ; Target tick_count

    ; Calculate spin timeout (fallback)
    ; Keep this bounded so pre-STI delays do not look like a hard lock
    ; when tick_count is not advancing yet.
    mov rdx, 50000
    imul rdx, rcx        ; RDX = max spin iterations

.wait:
    mov rax, [tick_count]
    cmp rax, rbx
    jge .done

    dec rdx
    jz .done

    pause
    jmp .wait

.done:
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; ============================================================================
; usb_poll_mouse - Check for mouse updates
; Called from kernel main loop
; ============================================================================
FN_BEGIN usb_poll_mouse, 0, 0, FN_RET_SCALAR
    cmp byte [usb_mouse_active], 1
    je .loop

.normal_inactive:
    ; First: check if the XHCI controller is running and has a PSC event
    ; (handles hot-plug: mouse plugged in after boot)
    cmp byte [xhci_active], 1
    jne .inactive_counter         ; Controller not even init'd - fall through to counter

    ; Controller is running but no mouse. Poll event ring for PSC (hot-plug).
.inactive_poll:
    call xhci_poll_event
    test eax, eax
    jz .inactive_counter          ; No events - fall through to counter

    ; Got an event - check if PSC (Type 34)
    mov edx, ebx
    shr edx, 10
    and edx, 0x3F
    cmp edx, 34
    jne .inactive_poll            ; Not PSC - drain and keep polling

    ; PSC event = device connected/disconnected on a port
    ; Immediately try to enumerate (don't wait for counter)
    mov dword [init_retry_counter], 0
    ; Don't reset xhci_pci_search_start - stay on this controller
    ; Call xhci_init directly (skips PCI rescan, reuses current controller)
    call usb_hid_init_same_ctrl
    ret

.inactive_counter:
    ; No hot-plug event - counter-based retry only if a controller was found before.
    ; If no XHCI hardware exists at all, don't retry (saves CPU).
    cmp byte [usb_no_xhci], 1
    je .ret                           ; No XHCI hardware - don't waste time

    inc dword [init_retry_counter]
    cmp dword [init_retry_counter], 30000  ; ~3 seconds at typical loop rates
    jl .ret

    ; Reset counter and try full init (scans all controllers)
    mov dword [init_retry_counter], 0
    call usb_hid_init
    ret

.loop:
    ; Check if transfer completed
    call xhci_poll_event
    test eax, eax
    jz .ret        ; No more events

    ; Event found! EAX=Code, EBX=Type/Slot, ECX=TRB Pointer (or DW0)
    ; Check if it's a Transfer Event (Type 32)
    mov edx, ebx
    shr edx, 10
    and edx, 0x3F
    cmp edx, 32    ; TRB_TRANSFER_EVT
    jne .check_psc ; Check Port Status Change
    inc dword [usb_dbg_evt]   ; DEBUG: count transfer events delivered

    ; It's a transfer event. Check completion code
    ; We already have EAX = Completion Code from xhci_poll_event
    
    cmp eax, 1     ; Success
    je .process_data
    cmp eax, 13    ; Short Packet (Success with less data)
    je .process_data
    
    ; If not Success or Short Packet, it's an error
    ; This likely means the endpoint is halted or there's a transaction error.
    ; We must recover aggressively.
    
    ; Debug: Print error code
    push rax
    mov dx, 0x3F8
    add al, '0' ; Convert low nibble to char (rough)
    out dx, al
    pop rax
    inc dword [usb_dbg_err]   ; DEBUG: count error completion codes
    mov [usb_dbg_errcode], al

    jmp .critical_error

.process_data:
    ; Route to correct slot based on event's slot ID (EBX bits 31:24).
    mov edx, ebx
    shr edx, 24
    and edx, 0xFF

    ; NIC slot? Hand the event to rtl8156_consume_event, which runs
    ; handle_frame + requeues the bulk-IN. This is the single consumer of NIC
    ; RX events — DHCP / ARP / ICMP all derive their state from frames the
    ; consume_event path delivers, no per-syscall xHCI polling.
    extern rtl8156_active, rtl8156_slot_id, rtl8156_consume_event
    cmp byte [rtl8156_active], 1
    jne .not_nic_event
    movzx r8d, byte [rtl8156_slot_id]
    cmp edx, r8d
    jne .not_nic_event
    ; EAX/EBX/ECX still hold the popped event from xhci_poll_event.
    call rtl8156_consume_event
    jmp .loop
.not_nic_event:

    cmp byte [usb_slot2_active], 1
    jne .is_slot1_data
    movzx ecx, byte [usb_slot2_id]
    cmp edx, ecx
    je .process_slot2_loop

.is_slot1_data:
    ; Process Mouse Data at XHCI_MOUSE_BUF_ADDR (slot1)
    mov rsi, XHCI_MOUSE_BUF_ADDR

    ; DEBUG: snapshot first 4 report bytes + bump report counter
    push rax
    mov eax, [rsi]
    mov [usb_dbg_report], eax
    inc dword [usb_dbg_rpt]
    pop rax

    ; If HID report descriptor was parsed, use it for accurate field extraction
    cmp byte [usb_use_parsed], 1
    jne .process_fixed_format

    ; Skip report ID if present
    cmp byte [hid_parsed_has_report_id], 1
    jne .parsed_no_skip
    mov al, [rsi]
    cmp al, [hid_parsed_report_id]
    jne .parsed_report_id_mismatch
    inc rsi
.parsed_no_skip:
    movzx ecx, word [usb_ep_mps]
    call hid_process_touchpad_report
    mov byte [mouse_moved], 1
    call usb_queue_mouse_read
    jmp .loop

.parsed_report_id_mismatch:
    call usb_queue_mouse_read
    jmp .loop

.process_fixed_format:
    ; Keyboard boot protocol: pass entire 8-byte report to parser, no mouse update
    cmp byte [usb_hid_protocol], 1
    je .process_keyboard_report

    ; Update Buttons (mouse/touchpad)
    mov al, [rsi]
    mov [mouse_buttons], al

    ; Protocol 2 = mouse boot protocol = relative
    ; Protocol 0 = report protocol; if we are here, usb_use_parsed was not set
    ;   (hid_parsed_is_absolute=0), so treat as relative (boot-compat format).
    cmp byte [usb_hid_protocol], 2
    je .process_relative
    cmp byte [usb_hid_protocol], 0
    je .process_relative

.process_absolute:
    ; Tablet format:
    ; Byte 1-2: X, 3-4: Y (0 to 0x7FFF)
    movzx eax, word [rsi + 1]
    mov ecx, [scr_width]
    mul ecx
    mov ecx, 0x7FFF
    test ecx, ecx
    jz .done_movement
    div ecx
    mov [mouse_x], eax
    
    movzx eax, word [rsi + 3]
    mov ecx, [scr_height]
    mul ecx
    mov ecx, 0x7FFF
    test ecx, ecx
    jz .done_movement
    div ecx
    mov [mouse_y], eax
    jmp .done_movement

.process_relative:
    ; Update X
    movsx eax, byte [rsi + 1]
    add [mouse_x], eax

    ; Clamp X
    cmp dword [mouse_x], 0
    jge .x_ge_0
    mov dword [mouse_x], 0
.x_ge_0:
    mov eax, [scr_width]
    dec eax
    cmp [mouse_x], eax
    jle .x_le_max
    mov [mouse_x], eax
.x_le_max:

    ; Update Y
    movsx eax, byte [rsi + 2]
    add [mouse_y], eax

    ; Scroll wheel: byte 3 present when MPS >= 4
    movzx ecx, word [usb_ep_mps]
    cmp ecx, 4
    jl .no_usb_scroll
    movsx eax, byte [rsi + 3]
    test eax, eax
    jz .no_usb_scroll
    mov [mouse_scroll_y], eax
.no_usb_scroll:

    ; Clamp Y
    cmp dword [mouse_y], 0
    jge .y_ge_0
    mov dword [mouse_y], 0
.y_ge_0:
    mov eax, [scr_height]
    dec eax
    cmp [mouse_y], eax
    jle .y_le_max
    mov [mouse_y], eax
.y_le_max:

.done_movement:
    ; Set moved flag
    mov byte [mouse_moved], 1

    ; Re-queue transfer
    call usb_queue_mouse_read
    jmp .loop

.process_keyboard_report:
    ; RSI = 8-byte USB HID boot keyboard report
    call usb_parse_keyboard_report
    call usb_queue_mouse_read
    jmp .loop

.process_slot2_loop:
    ; Slot2 transfer event inline handler (routes back to .loop)
    cmp byte [usb_hid_protocol2], 1
    je .s2l_keyboard
    ; Relative mouse: buf = XHCI_MOUSE_BUF2_ADDR
    mov rsi, XHCI_MOUSE_BUF2_ADDR
    mov al, [rsi]
    mov [mouse_buttons], al
    movsx eax, byte [rsi + 1]
    add [mouse_x], eax
    movsx eax, byte [rsi + 2]
    add [mouse_y], eax
    ; Clamp X
    cmp dword [mouse_x], 0
    jge .s2l_x_ok
    mov dword [mouse_x], 0
.s2l_x_ok:
    mov eax, [scr_width]
    dec eax
    cmp [mouse_x], eax
    jle .s2l_y_check
    mov [mouse_x], eax
.s2l_y_check:
    ; Clamp Y
    cmp dword [mouse_y], 0
    jge .s2l_y_ok
    mov dword [mouse_y], 0
.s2l_y_ok:
    mov eax, [scr_height]
    dec eax
    cmp [mouse_y], eax
    jle .s2l_moved
    mov [mouse_y], eax
.s2l_moved:
    mov byte [mouse_moved], 1
    call usb_queue_mouse_read2
    jmp .loop
.s2l_keyboard:
    mov rsi, XHCI_MOUSE_BUF2_ADDR
    call usb_parse_keyboard_report
    call usb_queue_mouse_read2
    jmp .loop

.check_psc:
    ; Port Status Change Event (Type 34)
    cmp edx, 34
    jne .loop

    ; Ack the PORTSC change bits for the affected port so the controller
    ; stops re-firing the same PSCE on every poll. Per xHCI spec, PSCE
    ; event TRB DW0 bits 31:24 carry the 1-based port number; ecx holds DW0.
    push rax
    push rbx
    push rsi
    mov eax, ecx
    shr eax, 24
    and eax, 0xFF
    test eax, eax
    jz .psc_no_ack
    cmp al, [xhci_max_ports]
    ja .psc_no_ack
    dec eax                              ; 0-based index
    shl eax, 4                           ; * 16 bytes per port
    mov rsi, [xhci_op_base]
    add rsi, 0x400
    mov ebx, [rsi + rax + XHCI_PORTSC]
    and ebx, ~XHCI_PORTSC_PED            ; PED is RW1C — don't disable port
    ; Change bits are RW1C: reading them as 1 and writing back 1 clears them.
    mov [rsi + rax + XHCI_PORTSC], ebx
.psc_no_ack:
    pop rsi
    pop rbx
    pop rax

    ; Device connected or disconnected on this controller's port.
    ; Re-enumerate on the SAME controller (don't PCI-rescan).
.retry_init:
    call usb_hid_init_same_ctrl
    test eax, eax
    jz .retry_delay
    jmp .ret

.retry_delay:
    mov dword [init_retry_counter], 0
    ret

.ret:
    ; ---- Poll slot 2 (second USB device) ----
    cmp byte [usb_slot2_active], 1
    jne .ret2

    ; Swap in slot2 context for xhci_poll_event to match
    ; (xhci_poll_event checks event ring which is shared - filter by slot2_id)
    call xhci_poll_event
    test eax, eax
    jz .ret2

    ; Check event type
    mov edx, ebx
    shr edx, 10
    and edx, 0x3F
    cmp edx, 32                 ; Transfer event?
    jne .ret2

    ; Filter: verify slot ID matches slot2 (not a stray slot1 event)
    push rax
    mov edx, ebx
    shr edx, 24
    and edx, 0xFF
    movzx ecx, byte [usb_slot2_id]
    cmp edx, ecx
    pop rax
    jne .ret2

    cmp eax, 1
    je .slot2_data
    cmp eax, 13
    jne .ret2                   ; Error - ignore for now

.slot2_data:
    mov rsi, XHCI_MOUSE_BUF2_ADDR
    ; If slot2 is a keyboard, parse keyboard report
    cmp byte [usb_hid_protocol2], 1
    je .slot2_keyboard_parse
    ; Process slot2 mouse data
    mov al, [rsi]
    mov [mouse_buttons], al

    movsx eax, byte [rsi + 1]
    add [mouse_x], eax
    movsx eax, byte [rsi + 2]
    add [mouse_y], eax

    ; Clamp X
    cmp dword [mouse_x], 0
    jge .s2_x_ok
    mov dword [mouse_x], 0
.s2_x_ok:
    mov eax, [scr_width]
    dec eax
    cmp [mouse_x], eax
    jle .s2_y_check
    mov [mouse_x], eax
.s2_y_check:
    cmp dword [mouse_y], 0
    jge .s2_y_ok
    mov dword [mouse_y], 0
.s2_y_ok:
    mov eax, [scr_height]
    dec eax
    cmp [mouse_y], eax
    jle .s2_moved
    mov [mouse_y], eax
.s2_moved:
    mov byte [mouse_moved], 1
    call usb_queue_mouse_read2
    jmp .ret2

.slot2_keyboard_parse:
    call usb_parse_keyboard_report
    call usb_queue_mouse_read2

.ret2:
    ret

.critical_error:
    ; XHCI completion error on a Transfer Event.
    ; Code 6 = STALL (endpoint halted) is the common case. Per xHCI spec
    ; 4.6.8 it can be cleared with a Reset Endpoint command + Set TR Dequeue
    ; Pointer; no need to nuke the whole controller. Linux usbhid does the
    ; same dance. Slot1 only — slot2 falls through to full re-init.
    cmp byte [usb_dbg_errcode], 6
    jne .full_reinit
    ; Only attempt lightweight recovery if slot1 is active and the failing
    ; event was on slot1 (avoid stepping on slot2 / NIC slot during recovery).
    cmp byte [usb_mouse_active], 1
    jne .full_reinit
    call usb_recover_stall_slot1
    test eax, eax
    jz .full_reinit
    jmp .loop                ; recovery succeeded — drain more events
.full_reinit:
    jmp .retry_init  ; Use the retry logic from above

.transfer_fail:
    jmp .critical_error

; ============================================================================
; usb_hid_requeue_slot1_reads - Re-prime the mouse interrupt ring after some
; other driver (rtl8156 NIC init) clobbered xhci_slot_id / xhci_int_ep_dci
; AND drained pending Transfer Events with xhci_flush_events. Without this
; the 4 reads queued in usb_hid_init complete, get flushed before
; usb_poll_mouse sees them, and no new reads ever get queued → mouse dies.
; Safe to call when usb_mouse_active==0 (no-op).
; ============================================================================
global usb_hid_requeue_slot1_reads
usb_hid_requeue_slot1_reads:
    cmp byte [usb_mouse_active], 1
    jne .done
    mov al, [usb_slot1_id]
    mov [xhci_slot_id], al
    mov al, [usb_int_ep1_dci]
    mov [xhci_int_ep_dci], al
    call usb_queue_mouse_read
    call usb_queue_mouse_read
    call usb_queue_mouse_read
    call usb_queue_mouse_read
.done:
    ret

; ============================================================================
; usb_hid_requeue_slot1_one - Queue a SINGLE mouse interrupt read. Called from
; rtl8156_wait_completion every time it drops a HID Transfer Event so the
; mouse ring stays primed during long DHCP/ping waits without flooding.
; ============================================================================
global usb_hid_requeue_slot1_one
usb_hid_requeue_slot1_one:
    cmp byte [usb_mouse_active], 1
    jne .done1
    mov al, [usb_slot1_id]
    mov [xhci_slot_id], al
    mov al, [usb_int_ep1_dci]
    mov [xhci_int_ep_dci], al
    call usb_queue_mouse_read
.done1:
    ret

; ============================================================================
; usb_recover_stall_slot1 - Lightweight STALL recovery for slot1's interrupt
; endpoint, per xHCI spec 4.6.8 + USB 2.0 9.4.5:
;   1. Reset Endpoint command (xHCI side: EP halt → Stopped)
;   2. CLEAR_FEATURE(ENDPOINT_HALT) on default pipe (device side: data toggle
;      reset & un-halt; required by USB spec even if xHCI half already cleared)
;   3. Zero the interrupt transfer ring and reset enqueue/cycle
;   4. Set TR Dequeue Pointer command (xHCI side: arm ring at our new start)
;   5. Requeue interrupt reads & doorbell — endpoint resumes Running
; Returns EAX=1 on success, 0 on failure (caller should fall back to full
; re-init). Slot1 must be active before calling.
; ============================================================================
global usb_recover_stall_slot1
usb_recover_stall_slot1:
    push rbx
    push rcx
    push rdx
    push rdi
    push r8
    push r9
    push r10
    push r11

    cmp byte [usb_mouse_active], 1
    jne .rs_fail

    ; Restore slot1 ctx so shared xHCI helpers operate on the right slot/EP.
    mov al, [usb_slot1_id]
    mov [xhci_slot_id], al
    mov al, [usb_int_ep1_dci]
    mov [xhci_int_ep_dci], al

    ; --- 1. xHCI Reset Endpoint command ---
    ; DW0=0, DW1=0, DW2=0
    ; DW3 = TRB_RESET_ENDPOINT | (SlotID << 24) | (EpID << 16)
    xor r8d, r8d
    xor r9d, r9d
    xor r10d, r10d
    movzx eax, byte [xhci_slot_id]
    shl eax, 24
    movzx edx, byte [xhci_int_ep_dci]
    shl edx, 16
    or eax, edx
    or eax, TRB_RESET_ENDPOINT
    mov r11d, eax
    call xhci_submit_cmd
    cmp eax, 1
    jne .rs_fail

    ; --- 2. CLEAR_FEATURE(ENDPOINT_HALT) on device ---
    ; Setup packet (low dword) : bmRequestType=0x02, bRequest=0x01 (CLEAR_FEATURE),
    ;                            wValue=0 (ENDPOINT_HALT) → 0x00000102
    ; Setup packet (high dword): wIndex=ep_addr (e.g. 0x81), wLength=0
    mov r8d, 0x00000102
    movzx r9d, byte [usb_ep_addr]
    call usb_control_transfer_nodata
    ; Non-fatal: device may have already recovered; the xHCI Reset Endpoint
    ; above is what un-halts the controller-side state machine.

    ; --- 3. Reset the slot1 interrupt transfer ring ---
    mov rdi, XHCI_INT_RING_ADDR
    mov ecx, XHCI_RING_SIZE * XHCI_TRB_SIZE / 8
    xor rax, rax
    rep stosq
    mov dword [xhci_int_enqueue], 0
    mov byte [xhci_int_cycle], 1

    ; --- 4. Set TR Dequeue Pointer command ---
    ; DW0 = ring_addr_lo | DCS=1 (next TRB has cycle 1 → matches xhci_int_cycle)
    ; DW1 = ring_addr_hi (0 — ring lives below 4G)
    ; DW2 = StreamID:0 / SCT:0 (mouse EP isn't streaming)
    ; DW3 = TRB_SET_TR_DEQUEUE | (SlotID << 24) | (EpID << 16)
    mov r8d, XHCI_INT_RING_ADDR
    or r8d, 1                              ; DCS = 1
    xor r9d, r9d
    xor r10d, r10d
    movzx eax, byte [xhci_slot_id]
    shl eax, 24
    movzx edx, byte [xhci_int_ep_dci]
    shl edx, 16
    or eax, edx
    or eax, TRB_SET_TR_DEQUEUE
    mov r11d, eax
    call xhci_submit_cmd
    cmp eax, 1
    jne .rs_fail

    ; --- 5. Re-prime the interrupt ring ---
    call usb_queue_mouse_read
    call usb_queue_mouse_read

    inc dword [usb_dbg_stall_recov]
    mov eax, 1
    jmp .rs_ret
.rs_fail:
    xor eax, eax
.rs_ret:
    pop r11
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    ret

; ============================================================================
; usb_queue_mouse_read - Queue an interrupt transfer
; ============================================================================
usb_queue_mouse_read:
    ; Slot1 can be polled after slot2/NIC code has changed the shared xHCI
    ; globals. Always restore the saved slot1 context before queueing/ringing.
    cmp byte [usb_slot1_id], 0
    je .slot1_context_ready
    mov al, [usb_slot1_id]
    mov [xhci_slot_id], al
    mov al, [usb_int_ep1_dci]
    mov [xhci_int_ep_dci], al
.slot1_context_ready:
    ; Normal TRB for data transfer
    ; DWord 0, 1: Buffer Address
    mov r8d, XHCI_MOUSE_BUF_ADDR
    xor r9d, r9d
    
    ; DWord 2: Length (Transfer Length)
    movzx r10d, word [usb_ep_mps]
    ; TD Size = 0, Interrupter = 0
    
    ; DWord 3: Flags
    ; IOC (Interrupt On Completion) | ISP (Interrupt on Short Packet) | Setup? No, Normal TRB (1)
    mov r11d, TRB_NORMAL | TRB_IOC | (1 << 2) ; ISP
    
    call xhci_queue_int_trb

    ; Ring Doorbell for endpoint
    movzx edi, byte [xhci_slot_id]
    movzx esi, byte [xhci_int_ep_dci]
    call xhci_ring_doorbell
    ret

; ============================================================================
; usb_queue_mouse_read2 - Queue interrupt transfer for slot 2
; ============================================================================
usb_queue_mouse_read2:
    mov r8d, XHCI_MOUSE_BUF2_ADDR
    xor r9d, r9d
    movzx r10d, word [usb_ep2_mps]
    mov r11d, TRB_NORMAL | TRB_IOC | (1 << 2)
    call xhci_queue_int_trb2
    movzx edi, byte [usb_slot2_id]
    movzx esi, byte [usb_int_ep2_dci]
    call xhci_ring_doorbell
    ret

; ============================================================================
; usb_hid_init_slot2 - Enumerate second USB HID device on next available port
; Non-fatal: returns 0 if no second device found
; ============================================================================
FN_BEGIN usb_hid_init_slot2, 0, 0, FN_RET_SCALAR
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push rbp

    mov byte [usb_slot2_active], 0
    mov byte [usb_accept_keyboard], 1

    ; Switch xhci_address_device and xhci_configure_endpoint to slot2 buffers
    mov byte [xhci_slot2_mode], 1

    ; Serial: '[' = slot2 init starting
    mov dx, 0x3F8
    mov al, '['
    out dx, al

    ; Look for another port with a device (past the current port)
    call xhci_find_port_next
    test eax, eax
    jz .slot2_fail

    ; Serial: 'p' = port found for slot2
    mov dx, 0x3F8
    mov al, 'p'
    out dx, al

    ; Enable slot for second device
    call xhci_enable_slot
    test eax, eax
    jz .slot2_fail

    ; Serial: 's' = slot enabled for slot2
    mov dx, 0x3F8
    mov al, 's'
    out dx, al

    ; Address device (uses xhci_slot_id which now = slot2)
    call xhci_address_device
    test eax, eax
    jz .slot2_fail

    ; Serial: 'a' = address device ok for slot2
    mov dx, 0x3F8
    mov al, 'a'
    out dx, al

    ; Get device descriptor
    mov rdi, XHCI_CTRL_BUF_ADDR
    mov rcx, 18
    mov r8d, 0x01000680
    mov r9d, 0x00120000
    call usb_control_transfer_in
    test eax, eax
    jz .slot2_fail

    ; Get config descriptor (9 bytes)
    mov rdi, XHCI_CTRL_BUF_ADDR
    mov rcx, 9
    mov r8d, 0x02000680
    mov r9d, 0x00090000
    call usb_control_transfer_in
    test eax, eax
    jz .slot2_fail

    movzx ecx, word [abs XHCI_CTRL_BUF_ADDR + 2]
    mov rdi, XHCI_CTRL_BUF_ADDR
    mov r8d, 0x02000680
    mov r9d, ecx
    shl r9d, 16
    call usb_control_transfer_in
    test eax, eax
    jz .slot2_fail

    ; Parse endpoints - save current ep vars, parse, store slot2 ep vars
    ; Save slot1 endpoint info on stack
    movzx eax, byte [usb_ep_addr]
    push rax
    movzx eax, word [usb_ep_mps]
    push rax
    movzx eax, byte [usb_ep_interval]
    push rax
    movzx eax, byte [usb_hid_protocol]
    push rax
    movzx eax, byte [usb_interface_num]
    push rax

    mov byte [usb_find_report_hid], 0
    call usb_find_endpoint
    test eax, eax
    jnz .slot2_endpoint_ok
    mov byte [usb_find_report_hid], 1
    call usb_find_endpoint
.slot2_endpoint_ok:
    test eax, eax
    je .slot2_restore_fail

    ; Serial: 'e' = endpoint found for slot2
    mov dx, 0x3F8
    mov al, 'e'
    out dx, al

    ; Save slot2 endpoint info
    mov al, [usb_ep_addr]
    mov [usb_ep2_addr], al
    mov ax, [usb_ep_mps]
    mov [usb_ep2_mps], ax
    mov al, [usb_ep_interval]
    mov [usb_ep2_interval], al
    mov al, [usb_hid_protocol]
    mov [usb_hid_protocol2], al
    mov al, [usb_interface_num]
    mov [usb_interface2_num], al

    ; Restore slot1 ep vars
    pop rax
    mov [usb_interface_num], al
    pop rax
    mov [usb_hid_protocol], al
    pop rax
    mov [usb_ep_interval], al
    pop rax
    mov [usb_ep_mps], ax
    pop rax
    mov [usb_ep_addr], al

    ; Set configuration for slot2
    mov r8d, 0x00010900
    mov r9d, 0x00000000
    call usb_control_transfer_nodata

    ; Mirror slot1 init: force boot protocol on keyboards/mice that advertise
    ; a boot HID protocol, then disable idle repeat throttling.
    cmp byte [usb_hid_protocol2], 0
    je .slot2_skip_set_protocol

    ; SET_PROTOCOL(Value=0 => Boot Protocol)
    mov r8d, 0x00000B21
    movzx r9d, byte [usb_interface2_num]
    call usb_control_transfer_nodata

    ; SET_IDLE(Value=0 => infinite duration)
    mov r8d, 0x00000A21
    movzx r9d, byte [usb_interface2_num]
    call usb_control_transfer_nodata

.slot2_skip_set_protocol:

    ; Configure endpoint for slot2
    movzx edi, byte [usb_ep2_addr]
    and edi, 0x7F
    movzx esi, word [usb_ep2_mps]
    movzx edx, byte [usb_ep2_interval]
    call xhci_configure_endpoint
    test eax, eax
    jz .slot2_ep_restore_fail2

    ; Save slot2 slot/ep info (xhci_configure_endpoint updated xhci_int_ep_dci)
    mov al, [xhci_slot_id]
    mov [usb_slot2_id], al
    mov al, [xhci_int_ep_dci]
    mov [usb_int_ep2_dci], al
    mov al, [xhci_port_num]
    mov [usb_slot2_port], al

    ; Restore slot1 XHCI state
    mov al, [usb_slot1_id]
    mov [xhci_slot_id], al
    mov al, [usb_int_ep1_dci]
    mov [xhci_int_ep_dci], al

    ; Restore port1
    mov al, [xhci_port1_num]
    mov [xhci_port_num], al

    mov byte [usb_slot2_active], 1

    ; Queue initial transfers for slot2
    call usb_queue_mouse_read2
    call usb_queue_mouse_read2

    jmp .slot2_ok

.slot2_restore_fail:
    pop rax
    mov [usb_interface_num], al
    pop rax
    mov [usb_hid_protocol], al
    pop rax
    mov [usb_ep_interval], al
    pop rax
    mov [usb_ep_mps], ax
    pop rax
    mov [usb_ep_addr], al
    jmp .slot2_fail

.slot2_ep_restore_fail2:
    ; Restore slot1 state even on failure
    mov al, [usb_slot1_id]
    mov [xhci_slot_id], al
    mov al, [usb_int_ep1_dci]
    mov [xhci_int_ep_dci], al
    mov al, [xhci_port1_num]
    mov [xhci_port_num], al
    jmp .slot2_fail

.slot2_fail:
    ; Slot2 probing is non-fatal, but it reuses shared xHCI globals while
    ; enumerating.  Always restore slot1 state before returning to polling.
    mov al, [usb_slot1_id]
    mov [xhci_slot_id], al
    mov al, [usb_int_ep1_dci]
    mov [xhci_int_ep_dci], al
    mov al, [xhci_port1_num]
    mov [xhci_port_num], al
    mov byte [usb_slot2_active], 0

    ; Serial: ']' = slot2 init failed
    mov dx, 0x3F8
    mov al, ']'
    out dx, al
    mov byte [usb_accept_keyboard], 0
    xor eax, eax
    jmp .slot2_ret

.slot2_ok:
    ; Serial: ')' = slot2 init OK
    mov dx, 0x3F8
    mov al, ')'
    out dx, al
    mov byte [usb_accept_keyboard], 0
    mov eax, 1
.slot2_ret:
    ; Restore slot1 mode for xhci functions
    mov byte [xhci_slot2_mode], 0
    pop rbp
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

; ============================================================================
; usb_control_transfer_in - Perform Control Transfer (Data IN)
; R8 = Setup DWord 0, R9 = Setup DWord 1, RCX = Length, RDI = Buffer
; Returns: EAX = 1 on success
; ============================================================================
usb_control_transfer_in:
    ; 1. Setup Stage
    push rcx
    push rdi
    
    ; Setup TRB:
    ; DW0, DW1: Setup Data (R8, R9) -> TRB has IDT (Immediate Data)
    ; But XHCI spec says Setup TRB uses Immediate Data for the 8 setup bytes.
    ; DW0: RequestType | Request | Value
    ; DW1: Index | Length
    
    ; Note: R8/R9 passed by caller are the content of the 8 bytes.
    ; TRB fields:
    ; DW0 = R8
    ; DW1 = R9
    ; DW2 = 8 (Length of immediate data always 8)
    ; DW3 = TRB_SETUP | TRB_IDT | TRB_TRT_IN
    
    mov r10d, 8
    mov r11d, TRB_SETUP | TRB_IDT | TRB_TRT_IN
    call xhci_queue_ctrl_trb
    
    ; 2. Data Stage
    pop rdi
    pop rcx
    
    cmp rcx, 0
    je .no_data
    
    ; Data TRB
    mov r8d, edi             ; Buffer low
    xor r9d, r9d             ; Buffer high
    mov r10d, ecx            ; Length
    mov r11d, TRB_DATA | TRB_DIR_IN
    call xhci_queue_ctrl_trb
    
.no_data:
    ; 3. Status Stage (OUT)
    xor r8d, r8d
    xor r9d, r9d
    xor r10d, r10d
    mov r11d, TRB_STATUS | TRB_DIR_OUT | TRB_IOC
    call xhci_queue_ctrl_trb
    
    ; 4. Ring Doorbell (Slot 1, EP1=Control)
    movzx edi, byte [xhci_slot_id]
    mov esi, 1               ; EP 1 = Control
    call xhci_ring_doorbell
    
    ; 5. Wait for completion
    call usb_wait_completion
    ret

; ============================================================================
; usb_control_transfer_nodata - Perform Control Transfer (No Data)
; R8 = Setup DWord 0, R9 = Setup DWord 1
; ============================================================================
usb_control_transfer_nodata:
    ; 1. Setup Stage
    mov r10d, 8
    mov r11d, TRB_SETUP | TRB_IDT | TRB_TRT_NO_DATA
    call xhci_queue_ctrl_trb
    
    ; 2. Status Stage (IN)
    xor r8d, r8d
    xor r9d, r9d
    xor r10d, r10d
    mov r11d, TRB_STATUS | TRB_DIR_IN | TRB_IOC
    call xhci_queue_ctrl_trb
    
    ; 3. Ring Doorbell
    movzx edi, byte [xhci_slot_id]
    mov esi, 1
    call xhci_ring_doorbell
    
    ; 4. Wait
    call usb_wait_completion
    ret

; ============================================================================
; usb_wait_completion - Wait for status stage completion
; ============================================================================
usb_wait_completion:
    ; PIT-based 1-second timeout (tick-only: CPU-spin fallbacks fire far too
    ; early on fast real silicon and cause false control-transfer timeouts)
    ; Use rsi for deadline - xhci_poll_event saves/restores rsi internally
    push rbx
    push rcx
    push rsi
    mov rsi, [tick_count]
    add rsi, 100                 ; 100 ticks = 1 second at 100Hz
.poll:
    call xhci_poll_event         ; rsi preserved by xhci_poll_event (push/pop rsi inside)
    test eax, eax
    jnz .done

    mov rax, [tick_count]
    cmp rax, rsi                 ; rsi = deadline (not corrupted by xhci_poll_event)
    jl .poll

.fail_timeout:
    xor eax, eax
    pop rsi
    pop rcx
    pop rbx
    ret

.done:
    pop rsi
    pop rcx
    pop rbx
    ; Check if it was success
    cmp eax, 1
    jne .fail
    mov eax, 1
    ret
.fail:
    xor eax, eax
    ret

; ============================================================================
; usb_find_endpoint - Parse Config Descriptor at XHCI_CTRL_BUF_ADDR
; Returns: EAX=1 found, updates usb_ep_addr, usb_ep_mps
; ============================================================================
usb_find_endpoint:
    mov rsi, XHCI_CTRL_BUF_ADDR
    ; Config descriptor header must include bLength, bDescriptorType, and
    ; wTotalLength before any descriptor-specific field reads.
    cmp byte [rsi], 4
    jb .not_found
    movzx ecx, word [rsi + 2]  ; wTotalLength
    cmp ecx, 4
    jb .not_found
    cmp ecx, 512
    ja .not_found
    
    ; Parse loop state
    xor edx, edx             ; Offset in buffer
    xor ebx, ebx             ; Flag: found mouse interface (0=no, 1=yes)
    
.parse:
    cmp edx, ecx
    jge .not_found
    
    ; Read bLength (offset + 0)
    movzx eax, byte [rsi + rdx]
    cmp eax, 2
    jb .not_found            ; Zero/short descriptor? Abort to avoid infinite loop
    mov r8d, edx
    add r8d, eax
    jc .not_found
    cmp r8d, ecx
    ja .not_found            ; Descriptor must fit inside wTotalLength
    
    ; Read bDescriptorType (offset + 1)
    mov al, [rsi + rdx + 1]
    
    cmp al, USB_DESC_INTERFACE
    je .check_interface
    
    cmp al, USB_DESC_ENDPOINT
    je .check_endpoint
    
    jmp .next_desc

.check_interface:
    ; Found an interface descriptor.
    ; The primary probe should prefer pointer-class HID devices.
    ; A secondary probe may also accept a keyboard.
    cmp byte [rsi + rdx], 8
    jb .not_found

    cmp byte [rsi + rdx + 5], 3  ; bInterfaceClass = HID?
    jne .not_hid_interface

    mov al, [rsi + rdx + 7]
    cmp al, 2                   ; boot mouse
    je .accept_hid_interface
    cmp al, 1                   ; boot keyboard, allowed only for slot2
    jne .check_report_hid
    cmp byte [usb_accept_keyboard], 1
    jne .not_hid_interface
    jmp .accept_hid_interface

.check_report_hid:
    test al, al                  ; report protocol / vendor-specific HID
    jne .not_hid_interface
    cmp byte [usb_find_report_hid], 1
    jne .not_hid_interface

.accept_hid_interface:
    mov [usb_hid_protocol], al
    mov al, [rsi + rdx + 2]       ; bInterfaceNumber for class requests
    mov [usb_interface_num], al
    mov ebx, 1                   ; Set "found HID" flag - look for interrupt IN next
    jmp .next_desc

.not_hid_interface:
    mov ebx, 0                   ; Not a usable HID interface
    jmp .next_desc

.check_endpoint:
    ; Found an endpoint descriptor
    ; Only care if we are currently inside a valid Mouse Interface
    cmp byte [rsi + rdx], 7
    jb .not_found
    test ebx, ebx
    jz .next_desc
    
    ; Check Attributes (offset + 3) -> bits 1:0 = Transfer Type
    mov al, [rsi + rdx + 3]
    and al, 0x03
    cmp al, USB_EP_INTERRUPT
    jne .next_desc
    
    ; Check Direction (offset + 2) -> bit 7 (1=IN)
    mov al, [rsi + rdx + 2]
    test al, 0x80
    jz .next_desc
    
    ; Found Interrupt IN endpoint for a HID device (mouse or touchpad)!

    ; Save Endpoint Address (bEndpointAddress, offset +2)
    mov al, [rsi + rdx + 2]
    mov [usb_ep_addr], al

    ; Save Max Packet Size (wMaxPacketSize, offset +4, LE word)
    mov ax, [rsi + rdx + 4]
    and ax, 0x07FF               ; Bits 10:0 only (USB 2.0 HS can have bigger in high bits)
    test ax, ax
    jnz .mps_ok
    mov ax, 8                    ; Fallback: 8 bytes (minimum HID boot-mouse packet)
.mps_ok:
    mov [usb_ep_mps], ax

    ; Save Interval (bInterval, offset +6)
    mov al, [rsi + rdx + 6]
    mov [usb_ep_interval], al

    ; Success!
    mov eax, 1
    ret

.next_desc:
    ; Advance by bLength
    movzx eax, byte [rsi + rdx]
    add edx, eax
    jmp .parse

.not_found:
    xor eax, eax
    ret

; ============================================================================
; usb_try_known_mouse_endpoint - Fallback for simple boot mice whose Windows
; descriptor binding is known but whose real-hardware config walk failed.
; VID_17EF/PID_602E is "USB Optical Mouse": HID boot mouse, EP1 IN, 4-byte
; interrupt report. QEMU passthrough confirms the same packet size.
; Returns EAX=1 if endpoint globals were filled.
; ============================================================================
usb_try_known_mouse_endpoint:
    cmp word [usb_device_vid], 0x17EF
    jne .no
    cmp word [usb_device_pid], 0x602E
    jne .no
    cmp byte [usb_accept_keyboard], 1
    je .no
    mov byte [usb_hid_protocol], 2
    mov byte [usb_interface_num], 0
    mov byte [usb_ep_addr], 0x81
    mov word [usb_ep_mps], 4
    mov byte [usb_ep_interval], 10
    mov eax, 1
    ret
.no:
    xor eax, eax
    ret

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
