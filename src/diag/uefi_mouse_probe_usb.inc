probe_usb_io:
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 80
    ; locals (5 pushes = 0 mod 16, +80 still 0 mod 16; calls land aligned)
    ;   [rsp+48] num_handles
    ;   [rsp+56] handle_buffer ptr (filled by LocateHandleBuffer)

    mov qword [rsp+48], 0
    mov qword [rsp+56], 0

    mov rcx, [v_bs]
    mov rax, [rcx + BS_LOCHNDL]
    mov ecx, 2                                ; ByProtocol
    lea rdx, [guid_usbio]
    xor r8d, r8d
    lea r9, [rsp+48]
    lea r10, [rsp+56]
    mov [rsp+32], r10
    call rax
    test rax, rax
    jnz .pu_fail

    mov r12, [rsp+48]
    test r12, r12
    jz .pu_fail
    mov r13, [rsp+56]

    SDBG "usb_io: scanning handles"
    lea rsi, [s_r_usb_n]
    call ucs_print
    mov edi, r12d
    call ucs_print_uint
    call ucs_newline

.pu_try:
    test r12, r12
    jz .pu_fail

    ; OpenProtocol(handle, guid_usbio, &iface, imghandle, NULL, GET=2)
    ; NOTE: We deliberately do NOT call DisconnectController here. On Acer
    ; AMD firmware that hangs the xHCI host driver and the whole loop dies.
    ; We accept shared access and read whatever the firmware HID driver
    ; leaves available.
    mov rcx, [r13]
    mov rdx, [v_bs]
    mov rax, [rdx + BS_OPENPROT]
    lea rdx, [guid_usbio]
    lea r8, [v_usb_io]
    mov r9, [v_handle]
    mov qword [rsp+32], 0
    mov qword [rsp+40], 2
    call rax
    test rax, rax
    jnz .pu_next

    ; UsbGetInterfaceDescriptor(this, &usb_if_desc)  vtbl[64]
    mov rbx, [v_usb_io]
    mov rcx, rbx
    lea rdx, [usb_if_desc]
    mov rax, [rbx + 64]
    call rax
    test rax, rax
    jnz .pu_next

    ; Class==3 (HID)?  Accept ANY protocol except 1 (keyboard) -- we may have
    ; matched the wrong device before, so arm every HID pointer interface.
    movzx eax, byte [usb_if_desc + 5]
    cmp al, 3
    jne .pu_next
    movzx eax, byte [usb_if_desc + 7]
    cmp al, 1                                  ; protocol 1 = keyboard, skip
    je .pu_next

    ; iterate endpoints to find IN interrupt
    movzx r14d, byte [usb_if_desc + 4]        ; BNumEndpoints
    xor r15d, r15d
.pu_ep_loop:
    cmp r15d, r14d
    jge .pu_next
    mov rcx, rbx
    mov edx, r15d
    lea r8, [usb_ep_desc]
    mov rax, [rbx + 72]
    call rax
    test rax, rax
    jnz .pu_ep_next
    movzx eax, byte [usb_ep_desc + 3]         ; BmAttributes
    and al, 3
    cmp al, 3                                  ; INTERRUPT
    jne .pu_ep_next
    movzx eax, byte [usb_ep_desc + 2]         ; BEndpointAddress
    test al, 0x80                              ; IN
    jz .pu_ep_next

    ; Capture
    mov [v_usb_ep], al
    movzx eax, byte [usb_ep_desc + 6]
    mov [v_usb_interval], al
    movzx eax, word [usb_ep_desc + 4]         ; wMaxPacketSize
    mov [v_usb_maxpkt], ax
    movzx eax, byte [usb_ep_desc + 3]         ; bmAttributes
    mov [v_usb_epattr], al
    movzx eax, byte [usb_if_desc + 2]
    mov [v_usb_iface_num], al
    movzx eax, byte [usb_if_desc + 4]
    mov [v_usb_numep], al
    mov byte [v_usb_ok], 1

    ; Dump exactly what device/endpoint we matched
    lea rsi, [s_d_iface]
    call ucs_print
    movzx edi, byte [v_usb_iface_num]
    call ucs_print_uint
    lea rsi, [s_d_ep]
    call ucs_print
    movzx edi, byte [v_usb_ep]
    call ucs_print_uint
    lea rsi, [s_d_attr]
    call ucs_print
    movzx edi, byte [v_usb_epattr]
    call ucs_print_uint
    lea rsi, [s_d_mps]
    call ucs_print
    movzx edi, word [v_usb_maxpkt]
    call ucs_print_uint
    lea rsi, [s_d_ivl]
    call ucs_print
    movzx edi, byte [v_usb_interval]
    call ucs_print_uint
    call ucs_newline

    ; --- Detach the firmware's own HID driver from this interface so WE own
    ; the interrupt endpoint. Without this the firmware accepts our async
    ; transfer but never services it (callback box stayed grey).
    ; DisconnectController(ControllerHandle, DriverImageHandle=NULL, Child=NULL)
    TRACE "T-disc: calling DisconnectController on HID iface..."
    mov rcx, [r13]
    xor edx, edx
    xor r8d, r8d
    mov rax, [v_bs]
    mov rax, [rax + BS_DISCONN]
    call rax
    mov [v_usb_disc_ret], rax
    lea rsi, [s_r_usb_disc]
    call ucs_print
    mov rdi, [v_usb_disc_ret]
    call ucs_print_hex64
    call ucs_newline
    TRACE "T-disc: DisconnectController returned OK"

    ; Send SET_PROTOCOL(0=boot) via UsbControlTransfer
    ; bmRequestType=0x21, bRequest=0x0B, wValue=0, wIndex=iface, wLength=0
    mov byte  [usb_setup_pkt + 0], 0x21
    mov byte  [usb_setup_pkt + 1], 0x0B
    mov word  [usb_setup_pkt + 2], 0
    mov al, [v_usb_iface_num]
    mov [usb_setup_pkt + 4], al
    mov byte  [usb_setup_pkt + 5], 0
    mov word  [usb_setup_pkt + 6], 0

    mov rbx, [v_usb_io]
    mov rcx, rbx
    lea rdx, [usb_setup_pkt]
    mov r8d, 2                                 ; EfiUsbNoData = 2 (0=DataIn,1=DataOut,2=NoData)
    mov r9d, 100                               ; Timeout 100 ms
    mov qword [rsp+32], 0                      ; Data = NULL
    mov qword [rsp+40], 0                      ; DataLength = 0
    lea rax, [usb_xfer_status]
    mov [rsp+48], rax                          ; *Status
    mov rax, [rbx + 0]                         ; UsbControlTransfer
    call rax

    lea rsi, [s_r_usb_setproto]
    call ucs_print
    mov rdi, rax
    call ucs_print_hex64
    call ucs_newline

    ; Send SET_IDLE(duration=0). The kernel USB driver does this too -- some
    ; mice will not send reports until idle throttling is cleared.
    ; bmRequestType=0x21, bRequest=0x0A, wValue=0, wIndex=iface, wLength=0
    mov byte  [usb_setup_pkt + 0], 0x21
    mov byte  [usb_setup_pkt + 1], 0x0A
    mov word  [usb_setup_pkt + 2], 0
    mov al, [v_usb_iface_num]
    mov [usb_setup_pkt + 4], al
    mov byte  [usb_setup_pkt + 5], 0
    mov word  [usb_setup_pkt + 6], 0
    mov rbx, [v_usb_io]
    mov rcx, rbx
    lea rdx, [usb_setup_pkt]
    mov r8d, 2
    mov r9d, 100
    mov qword [rsp+32], 0
    mov qword [rsp+40], 0
    lea rax, [usb_xfer_status]
    mov [rsp+48], rax
    mov rax, [rbx + 0]
    call rax

    SDBG "usb_io: found HID mouse"
    lea rsi, [s_r_usb_ok]
    call ucs_print
    movzx edi, byte [v_usb_ep]
    call ucs_print_hex64
    call ucs_newline

    ; --- Register an ASYNC interrupt transfer.  This is the documented HID
    ; input path: the firmware polls the endpoint and invokes usb_cb for each
    ; report.  It uses a different firmware code path than Sync transfer, so
    ; if Sync returns EFI_INVALID_PARAMETER this may still deliver data.
    mov rbx, [v_usb_io]
    mov rcx, rbx
    movzx rdx, byte [v_usb_ep]
    mov r8d, 1                                ; IsNewTransfer = TRUE
    mov r9d, 8                                ; PollingInterval = 8 ms
    movzx rax, word [v_usb_maxpkt]
    test rax, rax
    jnz .pu_mp
    mov eax, 8
.pu_mp:
    cmp rax, 16
    jbe .pu_mp2
    mov eax, 16
.pu_mp2:
    mov [rsp+32], rax                         ; DataLength
    lea rax, [usb_cb]
    mov [rsp+40], rax                         ; InterruptCallBack
    mov qword [rsp+48], 0                     ; Context = NULL
    mov rax, [rbx + 16]                       ; UsbAsyncInterruptTransfer
    call rax
    mov [v_usb_async_ret], rax

    lea rsi, [s_r_usb_async]
    call ucs_print
    mov rdi, rax
    call ucs_print_hex64
    call ucs_newline

    ; Armed this interface. Keep scanning -- arm EVERY HID pointer interface
    ; so we cannot miss the real mouse by picking the wrong handle.
    inc dword [v_usb_found]
    jmp .pu_next

.pu_ep_next:
    inc r15d
    jmp .pu_ep_loop

.pu_next:
    add r13, 8
    dec r12
    jmp .pu_try

.pu_fail:
    cmp dword [v_usb_found], 0
    jne .pu_done
    SDBG "usb_io: no HID mouse"
    lea rsi, [s_r_usb_fail]
    call ucs_print
    call ucs_newline
.pu_done:
    add rsp, 80
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

; ============================================================================
; USB_CB - EFIAPI callback for UsbAsyncInterruptTransfer.
;   RCX=Data  RDX=DataLength  R8=Context  R9=Status
; Runs at TPL_NOTIFY during BS->Stall. Just copies the report and bumps a
; counter -- no firmware calls, so it cannot block or recurse.
; ============================================================================
usb_cb:
    push rsi
    push rdi
    test rcx, rcx
    jz .cb_done
    mov rsi, rcx
    lea rdi, [usb_async_buf]
    mov rcx, rdx
    cmp rcx, 16
    jbe .cb_len
    mov ecx, 16
.cb_len:
    test rcx, rcx
    jz .cb_done
    rep movsb
    mov eax, [usb_async_buf]
    mov [usb_async_report], eax
    inc dword [usb_async_hits]
.cb_done:
    pop rdi
    pop rsi
    xor eax, eax
    ret

; ============================================================================
; USB_POLL_MOUSE  - process async-delivered reports, then do one
; UsbSyncInterruptTransfer. Either path moves the cursor.
; ============================================================================
usb_poll_mouse:
    cmp byte [v_usb_ok], 0
    je .uq_ret

    ; --- ASYNC path: did usb_cb deliver a new report since last frame? ---
    mov eax, [usb_async_hits]
    cmp eax, [v_async_seen]
    je .uq_sync
    mov [v_async_seen], eax
    mov byte [v_state + 4], 1
    inc dword [v_hits + 4*4]
    mov eax, [usb_async_report]
    test eax, eax
    jz .uq_sync
    mov [v_last_report], eax
    movsx ecx, byte [usb_async_report + 1]     ; boot mouse dx
    movsx edx, byte [usb_async_report + 2]     ; boot mouse dy
    add [v_mx], ecx
    add [v_my], edx
    call clamp_cursor
.uq_sync:

    push rbx
    sub rsp, 64                                ; (1 push) entry 8mod16, +8+64=72 → 0mod16
    ; [rsp+0..31] shadow ; [rsp+32]=Timeout ; [rsp+40]=*Status ; [rsp+48]=DataLength

    ; DataLength MUST match the endpoint's wMaxPacketSize for an interrupt
    ; transfer -- sending 8 when maxpkt=5 is what made the firmware return
    ; EFI_INVALID_PARAMETER. Use the captured maxpkt.
    movzx rax, word [v_usb_maxpkt]
    test rax, rax
    jnz .mp_ok
    mov eax, 8
.mp_ok:
    cmp rax, 16
    jbe .mp_ok2
    mov eax, 16
.mp_ok2:
    mov [rsp+48], rax
    mov qword [usb_report_buf], 0
    mov dword [usb_xfer_status], 0

    mov rbx, [v_usb_io]
    mov rcx, rbx
    movzx rdx, byte [v_usb_ep]
    lea r8, [usb_report_buf]
    lea r9, [rsp+48]
    mov qword [rsp+32], 20                     ; 20 ms timeout (catch one report)
    lea rax, [usb_xfer_status]
    mov [rsp+40], rax
    mov rax, [rbx + 24]                        ; UsbSyncInterruptTransfer
    call rax

    mov [v_lastret + 4*8], rax
    test rax, rax
    jnz .uq_no
    cmp qword [rsp+48], 0
    je .uq_no

    mov byte [v_state + 4], 1
    inc dword [v_hits + 4*4]

    ; Snapshot first 4 bytes for the on-screen byte-bars (set v_last_report
    ; only when nonzero so we keep the *last motion* visible after a stop)
    mov eax, [usb_report_buf]
    test eax, eax
    jz .uq_apply
    mov [v_last_report], eax

.uq_apply:
    ; Try boot layout first: byte1=dx, byte2=dy.  If both are zero AND
    ; byte0 itself isn't a typical button mask (high bits set), shift over
    ; by one to handle report-ID-prefixed devices (byte0=ID, b2=dx, b3=dy).
    movsx ecx, byte [usb_report_buf + 1]
    movsx edx, byte [usb_report_buf + 2]
    mov eax, ecx
    or eax, edx
    jnz .uq_use_boot
    movsx ecx, byte [usb_report_buf + 2]
    movsx edx, byte [usb_report_buf + 3]
.uq_use_boot:
    add [v_mx], ecx
    add [v_my], edx
    call clamp_cursor

.uq_no:
    add rsp, 64
    pop rbx
.uq_ret:
    ret

; ============================================================================
; TEXT OUTPUT HELPERS - UEFI ConOut wrappers (UCS-2)
; ============================================================================
; ucs_print: RSI = UCS-2 null-terminated string
ucs_print:
    push rax
    push rcx
    push rdx
    push r8
    push r9
    push r10
    push r11
    mov rcx, [v_conout]
    mov rax, [rcx + CO_OUTPUT]
    mov rcx, [v_conout]
    mov rdx, rsi
    call rax
    pop r11
    pop r10
    pop r9
    pop r8
    pop rdx
    pop rcx
    pop rax
    ret

; ucs_newline
ucs_newline:
    push rsi
    lea rsi, [s_crlf_real]
    call ucs_print
    pop rsi
    ret

; trace_step: RSI = UCS-2 string. Print it + newline, then stall so the user
; can read each step. Used by the TRACE macro.
trace_step:
    push rdi
    push rsi
    call ucs_print
    call ucs_newline
    mov rcx, [v_bs]
    mov rax, [rcx + BS_STALL]
    mov ecx, [g_trace_stall_us]
    sub rsp, 40
    call rax
    add rsp, 40
    pop rsi
    pop rdi
    ret

; ucs_print_uint: EDI = uint32 to print as decimal
ucs_print_uint:
    push rax
    push rcx
    push rdx
    push rdi
    push rsi
    push rbx
    push r10
    lea r10, [num_buf]                        ; UCS-2 buffer
    mov eax, edi
    xor ecx, ecx                              ; digit count
    mov ebx, 10
.upu_div:
    xor edx, edx
    div ebx
    add dl, '0'
    mov [num_scratch + rcx], dl
    inc ecx
    test eax, eax
    jnz .upu_div
    ; reverse into UCS-2 buffer
    xor edx, edx                              ; out idx
.upu_emit:
    test ecx, ecx
    jz .upu_done
    dec ecx
    movzx eax, byte [num_scratch + rcx]
    mov [r10 + rdx*2], ax
    inc edx
    jmp .upu_emit
.upu_done:
    mov word [r10 + rdx*2], 0
    mov rsi, r10
    call ucs_print
    pop r10
    pop rbx
    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rax
    ret

; ucs_print_hex64: RDI = uint64 to print as 16 hex digits (no prefix)
ucs_print_hex64:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push r10
    lea r10, [num_buf]
    mov rax, rdi
    mov ecx, 16
    xor edx, edx
.uph_loop:
    rol rax, 4                                ; bring top nibble to bottom
    mov ebx, eax
    and ebx, 0xF
    add bl, '0'
    cmp bl, '9'
    jbe .uph_store
    add bl, 7                                 ; 'A'..'F'
.uph_store:
    movzx ebx, bl
    mov [r10 + rdx*2], bx
    inc edx
    dec ecx
    jnz .uph_loop
    mov word [r10 + rdx*2], 0
    mov rsi, r10
    call ucs_print
    pop r10
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; ============================================================================
; PRINT_STATUS_LINE - reset cursor to row 8, print live diagnostic
; Pattern (fixed width so each refresh overwrites cleanly):
;   ret0=XXXXXXXXXXXXXXXX ret1=... ret2=... ret3=...
;   hits0=NNNNN hits1=... hits2=... hits3=... mx=NNNN my=NNNN
; ============================================================================
print_status_line:
    push rax
    push rcx
    push rdx
    push rdi
    push rsi

    ; hits per slot
    lea rsi, [s_line_hit]
    call ucs_print
    mov edi, [v_hits + 0*4]
    call ucs_print_uint
    lea rsi, [s_space]
    call ucs_print
    mov edi, [v_hits + 1*4]
    call ucs_print_uint
    lea rsi, [s_space]
    call ucs_print
    mov edi, [v_hits + 2*4]
    call ucs_print_uint
    lea rsi, [s_space]
    call ucs_print
    mov edi, [v_hits + 3*4]
    call ucs_print_uint
    lea rsi, [s_space]
    call ucs_print
    mov edi, [v_hits + 4*4]
    call ucs_print_uint

    lea rsi, [s_arrow]
    call ucs_print
    mov edi, [v_mx]
    call ucs_print_uint
    lea rsi, [s_comma]
    call ucs_print
    mov edi, [v_my]
    call ucs_print_uint
    lea rsi, [s_space]
    call ucs_print
    mov rdi, [v_lastret + 4*8]                ; show USB transfer rc for triage
    call ucs_print_hex64
    call ucs_newline

    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rax
    ret

; ============================================================================
; DATA
; ============================================================================