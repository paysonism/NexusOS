; --- IRQ12 Mouse Handler (called from ISR) ---
global mouse_handler
mouse_handler:
    push rax
    push rbx
    push rcx
    push rdx

    ; Check status register bit 5 to confirm this is mouse data (not keyboard)
    in al, 0x64
    test al, 0x20            ; Bit 5 = aux output buffer full (mouse data)
    jz .not_mouse            ; If bit 5 clear, this is keyboard data, ignore

    ; Debug: increment IRQ12 counter
    inc byte [mouse_irq_count]

    ; Read byte from data port
    in al, 0x60
    movzx eax, al
    push rax
    mov dx, 0x3F8
    mov al, 'm'
    out dx, al
    pop rax

    ; Store last raw bytes for debug
    movzx ecx, byte [mouse_cycle]
    lea rbx, [mouse_dbg_raw]
    mov [rbx + rcx], al

    ; PS/2 mouse sends 3-byte packets:
    ; Byte 0: Y_overflow | X_overflow | Y_sign | X_sign | 1 | Middle | Right | Left
    ; Byte 1: X movement (unsigned, sign from byte 0 bit 4)
    ; Byte 2: Y movement (unsigned, sign from byte 0 bit 5)

    cmp cl, 0
    je .byte0
    cmp cl, 1
    je .byte1
    cmp cl, 2
    je .byte2
    cmp cl, 3
    je .byte3
    ; Invalid state, reset
    mov byte [mouse_cycle], 0
    jmp .done

.byte0:
    ; Validate: bit 3 should always be set in byte 0
    test al, 0x08
    jz .resync               ; Invalid packet, try to resync

    ; Check overflow bits - discard if overflow
    test al, 0xC0
    jnz .done                ; X or Y overflow, discard packet

    mov [mouse_packet], al
    mov byte [mouse_cycle], 1
    jmp .done

.resync:
    ; Bad byte0 - flush and reset cycle
    mov byte [mouse_cycle], 0
    jmp .done

.byte1:
    mov [mouse_packet + 1], al
    mov byte [mouse_cycle], 2
    jmp .done

.byte2:
    mov [mouse_packet + 2], al
    ; Intellimouse 0x03/0x04: need 4th byte for scroll wheel / extra buttons
    cmp byte [mouse_im_mode], 0
    je .do_process
    mov byte [mouse_cycle], 3   ; wait for Z byte
    jmp .done

.byte3:
    mov [mouse_packet + 3], al
    mov byte [mouse_cycle], 0
    jmp .do_process

.do_process:
    mov byte [mouse_cycle], 0

    ; Process complete packet
    ; Extract X delta with sign extension
    movzx eax, byte [mouse_packet + 1]   ; X movement (unsigned)
    movzx ebx, byte [mouse_packet]       ; Flags byte
    test bl, 0x10                         ; X sign bit
    jz .x_positive
    or eax, 0xFFFFFF00
.x_positive:
    mov ecx, eax
    add ecx, [mouse_x]
    cmp ecx, 0
    jge .x_min_ok
    xor ecx, ecx
.x_min_ok:
    mov eax, [scr_width]
    dec eax
    cmp ecx, eax
    jle .x_max_ok
    mov ecx, eax
.x_max_ok:
    mov [mouse_x], ecx

    ; Extract Y delta with sign extension
    movzx eax, byte [mouse_packet + 2]
    test bl, 0x20                         ; Y sign bit
    jz .y_positive
    or eax, 0xFFFFFF00
.y_positive:
    ; PS/2 Y: positive = UP, screen Y: positive = DOWN -> subtract
    mov ecx, eax
    mov edx, [mouse_y]
    sub edx, ecx
    cmp edx, 0
    jge .y_min_ok
    xor edx, edx
.y_min_ok:
    mov eax, [scr_height]
    dec eax
    cmp edx, eax
    jle .y_max_ok
    mov edx, eax
.y_max_ok:
    mov [mouse_y], edx

    ; Update button state
    mov al, bl
    and al, 0x07
    mov [mouse_buttons], al

    ; For 5-button Intellimouse (mode 2): extract buttons 4 & 5 from byte3
    cmp byte [mouse_im_mode], 2
    jne .no_im5_btns
    movzx ecx, byte [mouse_packet + 3]
    test ecx, 0x10              ; bit 4 = button 4
    jz .no_btn4
    or byte [mouse_buttons], 0x08
.no_btn4:
    test ecx, 0x20              ; bit 5 = button 5
    jz .no_im5_btns
    or byte [mouse_buttons], 0x10
.no_im5_btns:

    ; Update scroll wheel delta (Intellimouse byte 3, bits 3:0, 4-bit signed)
    cmp byte [mouse_im_mode], 0
    je .no_scroll
    movsx eax, byte [mouse_packet + 3]
    and eax, 0x0F               ; mask to 4 bits
    test eax, 0x08              ; sign bit set?
    jz .scroll_pos
    or eax, 0xFFFFFFF0          ; sign-extend to 32-bit
.scroll_pos:
    mov [mouse_scroll_y], eax
.no_scroll:

    ; Push mouse event to buffer
    mov ecx, [mouse_evt_tail]
    mov r8d, ecx
    shl r8d, 4
    lea rbx, [mouse_evt_buffer + r8]

    mov eax, [mouse_x]
    mov [rbx + 0], eax
    mov eax, [mouse_y]
    mov [rbx + 4], eax
    mov al, [mouse_buttons]
    mov [rbx + 8], al

    mov al, MEVT_MOVE
    test byte [mouse_buttons], 0x01
    jz .no_lclick
    mov al, MEVT_LCLICK
.no_lclick:
    mov [rbx + 9], al

    mov byte [mouse_moved], 1

    inc ecx
    and ecx, (MOUSE_BUFFER_SIZE - 1)
    mov [mouse_evt_tail], ecx
    jmp .done

.not_mouse:
    ; Not mouse data - read and discard to clear buffer
    in al, 0x60
.done:
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; --- Read one mouse event from buffer ---
global mouse_read
mouse_read:
    mov ecx, [mouse_evt_head]
    cmp ecx, [mouse_evt_tail]
    je .empty

    mov r8d, ecx
    shl r8d, 4
    lea rbx, [mouse_evt_buffer + r8]

    mov rax, [rbx]
    mov [rdi], rax
    mov rax, [rbx + 8]
    mov [rdi + 8], rax

    inc ecx
    and ecx, (MOUSE_BUFFER_SIZE - 1)
    mov [mouse_evt_head], ecx

    mov eax, 1
    ret

.empty:
    xor eax, eax
    ret

; --- Get current mouse position ---
global mouse_get_pos
mouse_get_pos:
    mov eax, [mouse_x]
    mov edx, [mouse_y]
    ret

; --- Get mouse buttons ---
global mouse_get_buttons
mouse_get_buttons:
    mov al, [mouse_buttons]
    ret

; --- Check and clear mouse moved flag ---
global mouse_check_moved
mouse_check_moved:
    xor eax, eax
    xchg al, [mouse_moved]
    ret

; --- Poll EFI_SIMPLE_POINTER_PROTOCOL saved by bootloader ---
; Reads relative X/Y movement and button state from the UEFI mouse driver.
; Non-destructive: if SPP pointer is 0, returns immediately.
; Clobbers: rax, rcx, rdx, r8, r9, r10, r11 (caller-saved)
global uefi_mouse_poll
uefi_mouse_poll:
    push rbx
    push r12
    push r13

    ; Load SPP interface pointer from VBE info block
    mov rbx, [abs VBE_INFO_ADDR + VBE_SPP_OFF]
    test rbx, rbx
    jz .done                        ; No UEFI pointer protocol available

    ; Build a 16-byte EFI_SIMPLE_POINTER_STATE on the stack
    ; Also allocate 32 bytes of shadow space required for the MS x64 ABI call
    sub rsp, 48
    xor eax, eax
    mov [rsp+32], eax
    mov [rsp+36], eax
    mov [rsp+40], eax
    mov [rsp+44], eax

    ; Call GetState(interface, &state)
    ; GetState is second vtable entry (+8)
    mov rax, [rbx + 8]
    mov rcx, rbx                    ; This = interface
    lea rdx, [rsp+32]               ; &state
    call rax
    ; EFI_NOT_READY (0x8000000000000006) means no new data
    test rax, rax
    jnz .pop_done                   ; Any non-zero = no data / error

    ; Apply relative X movement (scale >>1 to avoid excessive speed)
    mov r12d, [rsp+32]              ; RelativeMovementX (signed 32-bit)
    sar r12d, 1
    add r12d, [mouse_x]
    ; Clamp to [0, scr_width-1]
    test r12d, r12d
    jns .clamp_x_hi
    xor r12d, r12d
.clamp_x_hi:
    mov r13d, [scr_width]
    dec r13d
    cmp r12d, r13d
    jle .clamp_x_ok
    mov r12d, r13d
.clamp_x_ok:
    mov [mouse_x], r12d

    ; Apply relative Y movement
    mov r13d, [rsp+36]              ; RelativeMovementY (signed 32-bit)
    sar r13d, 1
    add r13d, [mouse_y]
    ; Clamp to [0, scr_height-1]
    test r13d, r13d
    jns .clamp_y_hi
    xor r13d, r13d
.clamp_y_hi:
    push rax
    mov eax, [scr_height]
    dec eax
    cmp r13d, eax
    pop rax
    jle .clamp_y_ok
    push rax
    mov eax, [scr_height]
    dec eax
    mov r13d, eax
    pop rax
.clamp_y_ok:
    mov [mouse_y], r13d

    ; Update buttons (bit0=left, bit1=right)
    xor al, al
    cmp byte [rsp+44], 0            ; LeftButton
    je .no_left
    or al, 0x01
.no_left:
    cmp byte [rsp+45], 0            ; RightButton
    je .no_right
    or al, 0x02
.no_right:
    mov [mouse_buttons], al

    ; Mark mouse as moved so the cursor redraws
    mov byte [mouse_moved], 1

.pop_done:
    add rsp, 48
.done:
    pop r13
    pop r12
    pop rbx
    ret
