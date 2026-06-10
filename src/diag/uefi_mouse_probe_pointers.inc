probe_spp_locate:
    push rbx
    sub rsp, 32
    mov rax, [v_bs]
    mov rax, [rax + BS_LOCATE]
    lea rcx, [guid_spp]
    xor edx, edx
    lea r8, [v_spp + 0]
    call rax
    mov [rsp+24], rax                         ; stash retcode
    test rax, rax
    jnz .pl_fail
    mov byte [v_spp_ok + 0], 1
    ; Reset device
    mov rbx, [v_spp + 0]
    mov rcx, rbx
    xor edx, edx                              ; ExtendedVerification = FALSE
    mov rax, [rbx + SPP_RESET]
    call rax
    SDBG "spp: LocateProtocol OK"
    lea rsi, [s_r_spp_loc_ok]
    call ucs_print
    mov rdi, [v_spp + 0]
    call ucs_print_hex64
    call ucs_newline
    jmp .pl_done
.pl_fail:
    SDBG "spp: LocateProtocol failed"
    lea rsi, [s_r_spp_loc_fail]
    call ucs_print
    mov rdi, [rsp+24]
    call ucs_print_hex64
    call ucs_newline
.pl_done:
    add rsp, 32
    pop rbx
    ret

; ============================================================================
; PROBE_SPP_ENUM - LocateHandleBuffer(SPP_GUID), then OpenProtocol on each
; until we find one that works. Stores in v_spp[1].
; ============================================================================
probe_spp_enum:
    push rbx
    push r12
    push r13
    sub rsp, 64
    ; [rsp+48] = num_handles
    ; [rsp+56] = handle_buffer

    mov qword [rsp+48], 0
    mov qword [rsp+56], 0

    mov rcx, [v_bs]
    mov rax, [rcx + BS_LOCHNDL]
    mov ecx, 2                                ; ByProtocol
    lea rdx, [guid_spp]
    xor r8d, r8d
    lea r9, [rsp+48]
    lea r10, [rsp+56]
    mov [rsp+32], r10
    call rax
    test rax, rax
    jnz .pe_fail
    mov r12, [rsp+48]
    test r12, r12
    jz .pe_fail
    mov r13, [rsp+56]                         ; handle array

    ; Print count
    lea rsi, [s_r_spp_enum_n]
    call ucs_print
    mov edi, r12d
    call ucs_print_uint
    call ucs_newline

.pe_try:
    test r12, r12
    jz .pe_fail

    ; OpenProtocol(handle, guid, &iface, imghandle, NULL, GET_PROTOCOL=2)
    mov rcx, [r13]
    mov rdx, [v_bs]
    mov rax, [rdx + BS_OPENPROT]
    lea rdx, [guid_spp]
    lea r8, [v_spp + 8]
    mov r9, [v_handle]
    mov qword [rsp+32], 0
    mov qword [rsp+40], 2
    call rax
    test rax, rax
    jnz .pe_next

    mov byte [v_spp_ok + 1], 1
    mov rbx, [v_spp + 8]
    mov rcx, rbx
    xor edx, edx
    mov rax, [rbx + SPP_RESET]
    call rax
    SDBG "spp: handle enum found one"
    lea rsi, [s_r_spp_enum_ok]
    call ucs_print
    mov rdi, [v_spp + 8]
    call ucs_print_hex64
    call ucs_newline
    jmp .pe_done

.pe_next:
    add r13, 8
    dec r12
    jmp .pe_try
.pe_fail:
    SDBG "spp: enum found none"
    lea rsi, [s_r_spp_enum_fail]
    call ucs_print
    call ucs_newline
.pe_done:
    add rsp, 64
    pop r13
    pop r12
    pop rbx
    ret

; ============================================================================
; PROBE_APP_LOCATE - try LocateProtocol(AbsolutePointer)
; ============================================================================
probe_app_locate:
    push rbx
    sub rsp, 32
    mov rax, [v_bs]
    mov rax, [rax + BS_LOCATE]
    lea rcx, [guid_app]
    xor edx, edx
    lea r8, [v_app + 0]
    call rax
    mov [rsp+24], rax
    test rax, rax
    jnz .al_fail
    mov byte [v_app_ok + 0], 1
    mov rbx, [v_app + 0]
    mov rcx, rbx
    xor edx, edx
    mov rax, [rbx + APP_RESET]
    call rax
    SDBG "app: LocateProtocol OK"
    lea rsi, [s_r_app_loc_ok]
    call ucs_print
    mov rdi, [v_app + 0]
    call ucs_print_hex64
    call ucs_newline
    jmp .al_done
.al_fail:
    SDBG "app: LocateProtocol failed"
    lea rsi, [s_r_app_loc_fail]
    call ucs_print
    mov rdi, [rsp+24]
    call ucs_print_hex64
    call ucs_newline
.al_done:
    add rsp, 32
    pop rbx
    ret

; ============================================================================
; PROBE_APP_ENUM - LocateHandleBuffer + OpenProtocol for AbsolutePointer
; ============================================================================
probe_app_enum:
    push rbx
    push r12
    push r13
    sub rsp, 64

    mov qword [rsp+48], 0
    mov qword [rsp+56], 0

    mov rcx, [v_bs]
    mov rax, [rcx + BS_LOCHNDL]
    mov ecx, 2
    lea rdx, [guid_app]
    xor r8d, r8d
    lea r9, [rsp+48]
    lea r10, [rsp+56]
    mov [rsp+32], r10
    call rax
    test rax, rax
    jnz .ae_fail
    mov r12, [rsp+48]
    test r12, r12
    jz .ae_fail
    mov r13, [rsp+56]

    lea rsi, [s_r_app_enum_n]
    call ucs_print
    mov edi, r12d
    call ucs_print_uint
    call ucs_newline

.ae_try:
    test r12, r12
    jz .ae_fail

    mov rcx, [r13]
    mov rdx, [v_bs]
    mov rax, [rdx + BS_OPENPROT]
    lea rdx, [guid_app]
    lea r8, [v_app + 8]
    mov r9, [v_handle]
    mov qword [rsp+32], 0
    mov qword [rsp+40], 2
    call rax
    test rax, rax
    jnz .ae_next

    mov byte [v_app_ok + 1], 1
    mov rbx, [v_app + 8]
    mov rcx, rbx
    xor edx, edx
    mov rax, [rbx + APP_RESET]
    call rax
    SDBG "app: handle enum found one"
    lea rsi, [s_r_app_enum_ok]
    call ucs_print
    mov rdi, [v_app + 8]
    call ucs_print_hex64
    call ucs_newline
    jmp .ae_done

.ae_next:
    add r13, 8
    dec r12
    jmp .ae_try
.ae_fail:
    SDBG "app: enum found none"
    lea rsi, [s_r_app_enum_fail]
    call ucs_print
    call ucs_newline
.ae_done:
    add rsp, 64
    pop r13
    pop r12
    pop rbx
    ret

; ============================================================================
; CHECK_INPUT_EVENT - RBX = SPP/APP iface. Reads WaitForInput EFI_EVENT at
; [RBX+16] and calls BS->CheckEvent (never blocks). Returns RAX=0 only when
; the event is signalled (GetState is then safe + fast). Returns RAX=1 when
; the event is NULL or not ready -> caller MUST skip GetState. This is what
; stops a blocking firmware GetState from freezing the probe.
; ============================================================================
check_input_event:
    push rcx
    push rdx
    push r8
    push r9
    push r10
    push r11
    mov rcx, [rbx + 16]                       ; WaitForInput event
    test rcx, rcx
    jz .cie_skip
    mov rax, [v_bs]
    mov rax, [rax + BS_CHECKEVT]
    sub rsp, 40
    call rax
    add rsp, 40
    test rax, rax
    jz .cie_done                              ; signalled -> RAX=0
.cie_skip:
    mov eax, 1
.cie_done:
    pop r11
    pop r10
    pop r9
    pop r8
    pop rdx
    pop rcx
    ret

; ============================================================================
; POLL_ALL_POINTERS - call GetState on each found protocol, accumulate motion
; into v_mx/v_my, set v_state bits for activity blink.
; ============================================================================
poll_all_pointers:
    push rbx
    push r12
    sub rsp, 64                               ; state struct lives at [rsp+32..47]

    mov byte [v_state + 0], 0
    mov byte [v_state + 1], 0
    mov byte [v_state + 2], 0
    mov byte [v_state + 3], 0
    mov byte [v_state + 4], 0

    ; SPP/APP GetState is confirmed to BLOCK FOREVER on this firmware (it hangs
    ; even when CheckEvent reports the WaitForInput event as signalled). There
    ; is no safe way to call it. Disabled. Only usb_poll_mouse runs in the loop
    ; -- UsbSyncInterruptTransfer has a hard timeout and cannot hang.
    cmp byte [v_enable_sppapp], 0
    je .done

    ; --- SPP slot 0 ---
    cmp byte [v_spp_ok + 0], 0
    je .sp1
    mov rbx, [v_spp + 0]
    TRACEF "P: slot0 SPP-locate CheckEvent..."
    call check_input_event
    test rax, rax
    jnz .sp1
    TRACEF "P: slot0 SPP-locate -> GetState..."
    call call_spp_getstate
    mov [v_lastret + 0*8], rax
    test rax, rax
    jnz .sp1
    mov byte [v_state + 0], 1
    inc dword [v_hits + 0*4]
    call apply_relative_motion

.sp1:
    cmp byte [v_spp_ok + 1], 0
    je .ap0
    mov rbx, [v_spp + 8]
    TRACEF "P: slot1 SPP-enum CheckEvent..."
    call check_input_event
    test rax, rax
    jnz .ap0
    TRACEF "P: slot1 SPP-enum -> GetState..."
    call call_spp_getstate
    mov [v_lastret + 1*8], rax
    test rax, rax
    jnz .ap0
    mov byte [v_state + 1], 1
    inc dword [v_hits + 1*4]
    call apply_relative_motion

.ap0:
    cmp byte [v_app_ok + 0], 0
    je .ap1
    mov rbx, [v_app + 0]
    TRACEF "P: slot2 APP-locate CheckEvent..."
    call check_input_event
    test rax, rax
    jnz .ap1
    TRACEF "P: slot2 APP-locate -> GetState..."
    call call_app_getstate
    mov [v_lastret + 2*8], rax
    test rax, rax
    jnz .ap1
    mov byte [v_state + 2], 1
    inc dword [v_hits + 2*4]
    call apply_absolute_motion

.ap1:
    cmp byte [v_app_ok + 1], 0
    je .done
    mov rbx, [v_app + 8]
    TRACEF "P: slot3 APP-enum CheckEvent..."
    call check_input_event
    test rax, rax
    jnz .done
    TRACEF "P: slot3 APP-enum -> GetState..."
    call call_app_getstate
    mov [v_lastret + 3*8], rax
    test rax, rax
    jnz .done
    mov byte [v_state + 3], 1
    inc dword [v_hits + 3*4]
    call apply_absolute_motion

.done:
    TRACEF "P: SPP/APP polling skipped - USB-only mode"
    add rsp, 64
    pop r12
    pop rbx
    ret

; ----- Helpers used by poll_all_pointers, with state on [rsp+32..47] -----
; EFI_SIMPLE_POINTER_STATE = { INT32 RelX, RelY, RelZ; BOOL LeftBtn; BOOL RightBtn }
call_spp_getstate:
    mov rcx, rbx                              ; this
    lea rdx, [rsp+32]
    ; Zero state buffer
    xor eax, eax
    mov [rsp+32], eax
    mov [rsp+36], eax
    mov [rsp+40], eax
    mov [rsp+44], eax
    mov rax, [rbx + SPP_GETSTATE]
    call rax
    ret

apply_relative_motion:
    mov eax, [rsp+32]                         ; RelativeMovementX
    sar eax, 1                                ; halve to avoid mach-speed cursor
    add [v_mx], eax
    mov eax, [rsp+36]
    sar eax, 1
    add [v_my], eax
    call clamp_cursor
    ret

; EFI_ABSOLUTE_POINTER_STATE = { UINT64 CurrentX, CurrentY, CurrentZ; UINT32 ActiveButtons }
call_app_getstate:
    mov rcx, rbx
    lea rdx, [rsp+32]
    xor eax, eax
    mov [rsp+32], eax
    mov [rsp+36], eax
    mov [rsp+40], eax
    mov [rsp+44], eax
    mov [rsp+48], eax
    mov [rsp+52], eax
    mov [rsp+56], eax
    mov [rsp+60], eax
    mov rax, [rbx + APP_GETSTATE]
    call rax
    ret

; Map absolute coords (0..AbsoluteMaxX) to screen. We do not know the max
; without reading Mode, so as a first cut just clip the low 32 bits and
; assume the firmware reports in screen pixels (true for many touchscreens
; that match GOP resolution). If not, the cursor will still move - just
; at the wrong scale, which is enough to confirm the path works.
apply_absolute_motion:
    ; UEFI AbsolutePointer returns EFI_SUCCESS with X=Y=Buttons=0 when the
    ; touchpad has no contact. Treat all-zeros as "no event" so the cursor
    ; doesn't get yanked to (0,0) and hidden behind the status row.
    mov eax, [rsp+32]
    or eax, [rsp+40]
    or eax, [rsp+56]                          ; ActiveButtons
    jz .am_skip
    mov eax, [rsp+32]                         ; CurrentX low 32
    mov [v_mx], eax
    mov eax, [rsp+40]                         ; CurrentY low 32
    mov [v_my], eax
    call clamp_cursor
.am_skip:
    ret

clamp_cursor:
    mov eax, [v_mx]
    test eax, eax
    jns .cx_ok
    xor eax, eax
.cx_ok:
    mov edx, [v_scrw]
    sub edx, 20
    cmp eax, edx
    jle .cx_store
    mov eax, edx
.cx_store:
    mov [v_mx], eax
    mov eax, [v_my]
    test eax, eax
    jns .cy_ok
    xor eax, eax
.cy_ok:
    mov edx, [v_scrh]
    sub edx, 20
    cmp eax, edx
    jle .cy_store
    mov eax, edx
.cy_store:
    mov [v_my], eax
    ret

; ============================================================================
; DRAW_CURSOR / ERASE_CURSOR  - 16x16 square at (v_mx, v_my). Erase records
; previous position so we can write black over it next frame.
; ============================================================================
draw_cursor:
    mov eax, [v_mx]
    mov [v_prev_mx], eax
    mov eax, [v_my]
    mov [v_prev_my], eax
    mov edi, [v_mx]
    mov esi, [v_my]
    mov edx, 20
    mov ecx, 20
    mov r8d, COLOR_CURSOR_MAGENTA             ; bright magenta
    call fill_rect
    ret

erase_cursor:
    mov edi, [v_prev_mx]
    mov esi, [v_prev_my]
    mov edx, 20
    mov ecx, 20
    mov r8d, COLOR_BG_UEFI_BLUE               ; UEFI EFI_BACKGROUND_BLUE (BGRA)
    call fill_rect
    ret

; ============================================================================
; DRAW_STATUS_ROW - four 12x12 squares along the top edge:
; slot 0 (spp locate), 1 (spp enum), 2 (app locate), 3 (app enum)
;   not found  -> dim grey
;   found, idle-> medium colour
;   found, active GetState this frame -> bright + 16px wide
; ============================================================================