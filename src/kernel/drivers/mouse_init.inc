
mouse_init:
    push rax
    push rbx
    push rcx
    push rdx

    ; Initialize state
    mov dword [mouse_x], (SCREEN_WIDTH / 2)
    mov dword [mouse_y], (SCREEN_HEIGHT / 2)
    mov byte [mouse_buttons], 0
    mov byte [mouse_cycle], 0
    mov dword [mouse_evt_head], 0
    mov dword [mouse_evt_tail], 0
    mov byte [mouse_irq_count], 0

%ifdef RELEASE_BUILD
    ; USB HID / UEFI pointer polling cover release input. The legacy PS/2 init
    ; below can spend tens of milliseconds in 8042 waits on machines without a
    ; responsive AUX port, so defer it out of the boot-critical path.
    mov dx, 0x3F8
    mov al, 'M'
    out dx, al
    mov al, '1'
    out dx, al
    mov al, '2'
    out dx, al
    mov al, 'F'
    out dx, al
    mov al, '!'
    out dx, al
    mov byte [abs 0x500], 0xAA
    mov byte [mouse_init_status], 0x01
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret
%endif

    ; Serial: 'M' = mouse init start
    mov dx, 0x3F8
    mov al, 'M'
    out dx, al

    ; ---- Step 1: Disable both PS/2 ports ----
    call mouse_wait_input
    jc .init_fail
    mov al, 0xAD               ; Disable first port (keyboard)
    out 0x64, al
    call mouse_wait_input
    jc .init_fail
    mov al, 0xA7               ; Disable second port (mouse)
    out 0x64, al

    ; ---- Step 2: Flush the output buffer ----
    mov ecx, 32                ; Read up to 32 stale bytes
.flush:
    in al, 0x64
    test al, 0x01
    jz .flush_done
    in al, 0x60                ; Discard byte
    dec ecx
    jnz .flush
.flush_done:

    ; Serial: '1'
    mov dx, 0x3F8
    mov al, '1'
    out dx, al

    ; ---- Step 3: Set controller config byte ----
    ; Read current config
    call mouse_wait_input
    jc .init_fail
    mov al, 0x20               ; Read config byte
    out 0x64, al
    call mouse_wait_output
    jc .init_fail
    in al, 0x60
    mov bl, al                 ; Save config in BL
    mov [mouse_dbg_ccb], al    ; Save for debug

    ; Modify: enable IRQ1 (bit0), IRQ12 (bit1), clear disable-clocks (bits 4,5)
    or bl, 0x03                ; Set bits 0,1 (IRQ1 + IRQ12)
    and bl, ~0x30              ; Clear bits 4,5 (enable both clocks)

    ; Write config back
    call mouse_wait_input
    jc .init_fail
    mov al, 0x60               ; Write config byte
    out 0x64, al
    call mouse_wait_input
    jc .init_fail
    mov al, bl
    out 0x60, al

    ; Serial: '2'
    mov dx, 0x3F8
    mov al, '2'
    out dx, al

    ; ---- Step 4: Controller self-test ----
    call mouse_wait_input
    jc .init_fail
    mov al, 0xAA               ; Self-test command
    out 0x64, al
    call mouse_wait_output
    jc .init_fail
    in al, 0x60
    mov [mouse_dbg_selftest], al
    cmp al, 0x55               ; Expected: 0x55 = pass
    jne .init_fail             ; Self-test failed

    ; Serial: '3'
    mov dx, 0x3F8
    mov al, '3'
    out dx, al

    ; ---- Step 5: Test second port (mouse) ----
    call mouse_wait_input
    jc .init_fail
    mov al, 0xA9               ; Test second port
    out 0x64, al
    call mouse_wait_output
    jc .init_fail
    in al, 0x60
    mov [mouse_dbg_port2test], al
    cmp al, 0x00               ; 0x00 = pass
    jne .init_fail

    ; Serial: '4'
    mov dx, 0x3F8
    mov al, '4'
    out dx, al

    ; ---- Step 6: Enable both ports ----
    call mouse_wait_input
    jc .init_fail
    mov al, 0xAE               ; Enable first port (keyboard)
    out 0x64, al
    call mouse_wait_input
    jc .init_fail
    mov al, 0xA8               ; Enable second port (mouse)
    out 0x64, al

    ; ---- Step 6b: Re-write config byte (self-test reset it) ----
    call mouse_wait_input
    jc .init_fail
    mov al, 0x20               ; Read config
    out 0x64, al
    call mouse_wait_output
    jc .init_fail
    in al, 0x60
    or al, 0x03                ; Enable IRQ1 (bit0) + IRQ12 (bit1)
    and al, ~0x30              ; Enable both clocks (clear bits 4,5)
    mov bl, al
    call mouse_wait_input
    jc .init_fail
    mov al, 0x60               ; Write config
    out 0x64, al
    call mouse_wait_input
    jc .init_fail
    mov al, bl
    out 0x60, al

    ; ---- Step 7: Reset mouse device (0xFF) ----
    call mouse_write           ; Send 0xD4 prefix (write-to-mouse)
    mov al, 0xFF               ; Reset command
    call mouse_write_data
    ; Read ACK (0xFA)
    call mouse_wait_output
    jc .skip_reset_resp
    in al, 0x60
    mov [mouse_dbg_reset_ack], al
    ; Read self-test result (0xAA)
    call mouse_wait_output
    jc .skip_reset_resp
    in al, 0x60
    mov [mouse_dbg_reset_result], al
    ; Read device ID (usually 0x00)
    call mouse_wait_output
    jc .skip_reset_resp
    in al, 0x60
    mov [mouse_dbg_device_id], al
.skip_reset_resp:

    ; Serial: '5'
    mov dx, 0x3F8
    mov al, '5'
    out dx, al

    ; ---- Step 8: Set defaults ----
    call mouse_write
    mov al, 0xF6               ; Set defaults
    call mouse_write_data
    call mouse_read_ack

    ; ---- Step 9: Negotiate Intellimouse (scroll wheel) via magic sample-rate sequence ----
    ; Magic: set sample rate 200, 100, 80 in sequence -> device ID becomes 0x03
    call mouse_write
    mov al, 0xF3
    call mouse_write_data
    call mouse_read_ack
    call mouse_write
    mov al, 200
    call mouse_write_data
    call mouse_read_ack

    call mouse_write
    mov al, 0xF3
    call mouse_write_data
    call mouse_read_ack
    call mouse_write
    mov al, 100
    call mouse_write_data
    call mouse_read_ack

    call mouse_write
    mov al, 0xF3
    call mouse_write_data
    call mouse_read_ack
    call mouse_write
    mov al, 80
    call mouse_write_data
    call mouse_read_ack

    ; Query device ID (0xF2) - if 0x03, mouse has scroll wheel
    call mouse_write
    mov al, 0xF2
    call mouse_write_data
    call mouse_read_ack         ; ACK to query command
    call mouse_wait_output
    jc .skip_im_check
    in al, 0x60
    cmp al, 0x03                ; 0x03 = Intellimouse with scroll wheel
    jne .skip_im_check
    mov byte [mouse_im_mode], 1

    ; Try to upgrade to 5-button Intellimouse: magic sequence 200, 200, 80
    call mouse_write
    mov al, 0xF3
    call mouse_write_data
    call mouse_read_ack
    call mouse_write
    mov al, 200
    call mouse_write_data
    call mouse_read_ack
    call mouse_write
    mov al, 0xF3
    call mouse_write_data
    call mouse_read_ack
    call mouse_write
    mov al, 200
    call mouse_write_data
    call mouse_read_ack
    call mouse_write
    mov al, 0xF3
    call mouse_write_data
    call mouse_read_ack
    call mouse_write
    mov al, 80
    call mouse_write_data
    call mouse_read_ack
    ; Query device ID again
    call mouse_write
    mov al, 0xF2
    call mouse_write_data
    call mouse_read_ack
    call mouse_wait_output
    jc .skip_im_check
    in al, 0x60
    cmp al, 0x04                ; 0x04 = 5-button Intellimouse
    jne .skip_im_check
    mov byte [mouse_im_mode], 2
.skip_im_check:

    ; ---- Step 9b: Set final sample rate 100 ----
    call mouse_write
    mov al, 0xF3
    call mouse_write_data
    call mouse_read_ack
    call mouse_write
    mov al, 100
    call mouse_write_data
    call mouse_read_ack

    ; ---- Step 10: Enable data reporting ----
    call mouse_write
    mov al, 0xF4               ; Enable data reporting
    call mouse_write_data
    call mouse_read_ack

    ; Serial: '6'
    mov dx, 0x3F8
    mov al, '6'
    out dx, al

    ; ---- Step 11: Re-read and store final config byte for debug ----
    call mouse_wait_input
    jc .init_ok
    mov al, 0x20
    out 0x64, al
    call mouse_wait_output
    jc .init_ok
    in al, 0x60
    mov [mouse_dbg_ccb_final], al

.init_ok:
    mov byte [abs 0x500], 0xAA
    mov byte [mouse_init_status], 0xAA

    ; Serial: 'OK'
    mov dx, 0x3F8
    mov al, 'O'
    out dx, al
    mov al, 'K'
    out dx, al

    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

.init_fail:
    mov byte [abs 0x500], 0xFF
    mov byte [mouse_init_status], 0xFF

    ; Serial: 'F!'
    mov dx, 0x3F8
    mov al, 'F'
    out dx, al
    mov al, '!'
    out dx, al

    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; Helper: signal we're writing to mouse
mouse_write:
    call mouse_wait_input
    mov al, 0xD4             ; Write to mouse port
    out 0x64, al
    ret

; Helper: write data byte to mouse
mouse_write_data:
    call mouse_wait_input
    out 0x60, al
    ret

; Helper: read ACK from mouse
mouse_read_ack:
    call mouse_wait_output
    in al, 0x60              ; Should be 0xFA (ACK)
    ret

; Wait until input buffer is empty (bit 1 of status = 0)
; Returns CF=0 on success, CF=1 on timeout
global mouse_wait_input
mouse_wait_input:
    push rcx
    mov ecx, 100000          ; Timeout counter
.loop:
    in al, 0x64
    test al, 0x02
    jz .done
    dec ecx
    jnz .loop
    pop rcx
    stc
    ret
.done:
    pop rcx
    clc
    ret

; Wait until output buffer is full (bit 0 of status = 1)
; Returns CF=0 on success, CF=1 on timeout
mouse_wait_output:
    push rcx
    mov ecx, 100000          ; Timeout counter
.loop:
    in al, 0x64
    test al, 0x01
    jnz .done
    dec ecx
    jnz .loop
    pop rcx
    stc
    ret
.done:
    pop rcx
    clc
    ret
