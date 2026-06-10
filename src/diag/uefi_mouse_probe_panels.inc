draw_status_row:
    ; slot 0
    xor edi, edi
    add edi, 8
    mov esi, 4
    cmp byte [v_spp_ok + 0], 0
    je .s0_off
    mov r8d, COLOR_DARK_RED                   ; dark red
    cmp byte [v_state + 0], 0
    je .s0_paint
    mov r8d, COLOR_BRIGHT_RED                 ; bright red
.s0_paint:
    jmp .s0_do
.s0_off:
    mov r8d, COLOR_DIM_GREY
.s0_do:
    mov edx, 14
    mov ecx, 14
    call fill_rect

    ; slot 1
    mov edi, 28
    mov esi, 4
    cmp byte [v_spp_ok + 1], 0
    je .s1_off
    mov r8d, COLOR_DARK_ORANGE
    cmp byte [v_state + 1], 0
    je .s1_paint
    mov r8d, COLOR_BRIGHT_ORANGE
.s1_paint:
    jmp .s1_do
.s1_off:
    mov r8d, COLOR_DIM_GREY
.s1_do:
    mov edx, 14
    mov ecx, 14
    call fill_rect

    ; slot 2
    mov edi, 48
    mov esi, 4
    cmp byte [v_app_ok + 0], 0
    je .s2_off
    mov r8d, COLOR_DARK_GREEN
    cmp byte [v_state + 2], 0
    je .s2_paint
    mov r8d, COLOR_BRIGHT_GREEN
.s2_paint:
    jmp .s2_do
.s2_off:
    mov r8d, COLOR_DIM_GREY
.s2_do:
    mov edx, 14
    mov ecx, 14
    call fill_rect

    ; slot 3
    mov edi, 68
    mov esi, 4
    cmp byte [v_app_ok + 1], 0
    je .s3_off
    mov r8d, COLOR_DARK_CYAN
    cmp byte [v_state + 3], 0
    je .s3_paint
    mov r8d, COLOR_BRIGHT_CYAN
.s3_paint:
    jmp .s3_do
.s3_off:
    mov r8d, COLOR_DIM_GREY
.s3_do:
    mov edx, 14
    mov ecx, 14
    call fill_rect

    ; slot 4 (USB IO) -- yellow
    mov edi, 88
    mov esi, 4
    cmp byte [v_usb_ok], 0
    je .s4_off
    mov r8d, COLOR_DARK_YELLOW
    cmp byte [v_state + 4], 0
    je .s4_paint
    mov r8d, COLOR_YELLOW
.s4_paint:
    jmp .s4_do
.s4_off:
    mov r8d, COLOR_DIM_GREY
.s4_do:
    mov edx, 14
    mov ecx, 14
    call fill_rect
    ret

; ============================================================================
; DRAW_USB_PANEL - big, unambiguous on-screen indicator of USB transfer state.
; Layout (top of screen, x=150..950, y=4..100):
;   y=4..28   : RC SQUARE.  Green = last UsbSyncInterruptTransfer returned 0.
;               Red = nonzero (failure or timeout). 24 px tall, 100 px wide.
;   y=4..28   : HITS BAR.  To the right of RC square. Width grows by ~1 px per
;               transfer success.  Wraps every 700 px.  Just confirms the call
;               is being made successfully when you wiggle.
;   y=34..58  : Four colored byte-bars (white,red,green,cyan) for first 4
;               bytes of the most recent non-empty report, length = byte*4.
;   y=64..88  : USB rc as 16 hex nibbles rendered as little colored squares
;               so we can read the exact failure code without ConOut.
; ============================================================================
draw_usb_panel:
    ; ---- clear strip ----
    mov edi, 150
    mov esi, 4
    mov edx, 800
    mov ecx, 96
    mov r8d, COLOR_PANEL_BG
    call fill_rect

    ; ---- RC square ----
    mov rax, [v_lastret + 4*8]
    test rax, rax
    jnz .rc_bad
    mov r8d, COLOR_RC_GREEN                    ; green
    jmp .rc_paint
.rc_bad:
    mov r8d, COLOR_RC_RED                      ; red
.rc_paint:
    mov edi, 150
    mov esi, 4
    mov edx, 100
    mov ecx, 24
    call fill_rect

    ; ---- HITS bar ----
    mov eax, [v_hits + 4*4]
    and eax, 0x3FF                            ; wrap at 1024
    test eax, eax
    jnz .hb_go
    mov eax, 2
.hb_go:
    mov edx, eax
    mov edi, 260
    mov esi, 4
    mov ecx, 24
    mov r8d, COLOR_YELLOW                      ; yellow
    call fill_rect

    ; ---- byte bars (4 stacked) ----
    mov eax, [v_last_report]
    mov [drb_tmp], eax

    ; b0 white
    movzx eax, byte [drb_tmp + 0]
    imul eax, 4
    test eax, eax
    jnz .b0g
    mov eax, 2
.b0g:
    mov edx, eax
    mov edi, 150
    mov esi, 34
    mov ecx, 5
    mov r8d, COLOR_WHITE
    call fill_rect

    ; b1 red (signed)
    movzx eax, byte [drb_tmp + 1]
    test al, 0x80
    jz .b1p
    neg al
.b1p:
    movzx eax, al
    imul eax, 6
    test eax, eax
    jnz .b1g
    mov eax, 2
.b1g:
    mov edx, eax
    mov edi, 150
    mov esi, 40
    mov ecx, 5
    mov r8d, COLOR_BAR_RED
    call fill_rect

    ; b2 green (signed)
    movzx eax, byte [drb_tmp + 2]
    test al, 0x80
    jz .b2p
    neg al
.b2p:
    movzx eax, al
    imul eax, 6
    test eax, eax
    jnz .b2g
    mov eax, 2
.b2g:
    mov edx, eax
    mov edi, 150
    mov esi, 46
    mov ecx, 5
    mov r8d, COLOR_BAR_GREEN
    call fill_rect

    ; b3 cyan (signed)
    movzx eax, byte [drb_tmp + 3]
    test al, 0x80
    jz .b3p
    neg al
.b3p:
    movzx eax, al
    imul eax, 6
    test eax, eax
    jnz .b3g
    mov eax, 2
.b3g:
    mov edx, eax
    mov edi, 150
    mov esi, 52
    mov ecx, 5
    mov r8d, COLOR_BAR_CYAN
    call fill_rect

    ; ---- rc as 16 hex nibbles ----
    ; each nibble = 24x24 box. brightness proportional to value 0..15.
    ; Nibbles are drawn MSB->LSB left to right.
    mov rax, [v_lastret + 4*8]
    mov rbx, rax
    mov ecx, 16
    mov r10d, 150                              ; x cursor
.nb_loop:
    rol rbx, 4
    mov edx, ebx
    and edx, 0xF
    mov eax, edx
    shl eax, 4                                 ; *16 → 0..240 brightness
    mov r11d, eax
    shl eax, 8
    or r11d, eax
    shl eax, 8
    or r11d, eax                               ; rgb gray ramp
    push rcx
    push r10
    mov edi, r10d
    mov esi, 64
    mov edx, 22
    mov ecx, 22
    mov r8d, r11d
    call fill_rect
    pop r10
    pop rcx
    add r10d, 26
    dec ecx
    jnz .nb_loop

    ; ---- RAW async-callback indicator: huge box low on screen ----
    ; BRIGHT CYAN  = usb_cb has fired at least once (firmware IS delivering
    ;                HID reports to us -> the async path works).
    ; DARK GREY    = usb_cb has NEVER fired (firmware accepted the transfer
    ;                but never calls our callback).
    mov eax, [usb_async_hits]
    test eax, eax
    jz .cbi_dark
    mov r8d, COLOR_BRIGHT_CYAN
    jmp .cbi_draw
.cbi_dark:
    mov r8d, COLOR_CB_DARK_GREY
.cbi_draw:
    mov edi, 1340                             ; far right, clear of the text
    mov esi, 130
    mov edx, 560
    mov ecx, 300
    call fill_rect

    ; magenta width-bar under it = raw callback count (1px each, wraps 1100)
    mov eax, [usb_async_hits]
    xor edx, edx
    mov ecx, 560
    div ecx
    test edx, edx
    jnz .cbi_bar
    mov edx, 4
.cbi_bar:
    mov edi, 1340
    mov esi, 450
    mov ecx, 40
    mov r8d, COLOR_CURSOR_MAGENTA
    call fill_rect
    ret

; ============================================================================
; OLD report bars (DEAD CODE - replaced by draw_usb_panel above)
; ============================================================================
old_draw_report_bars_dead:
    ; Background strip
    mov edi, 110
    mov esi, 4
    mov edx, 800
    mov ecx, 44
    mov r8d, COLOR_BLACK
    call fill_rect

    mov eax, [v_last_report]
    mov [drb_tmp], eax

    ; byte 0 - white
    movzx eax, byte [drb_tmp + 0]
    imul eax, 3
    mov edx, eax
    test edx, edx
    jnz .drb0_go
    mov edx, 2
.drb0_go:
    mov edi, 110
    mov esi, 6
    mov ecx, 8
    mov r8d, COLOR_WHITE
    call fill_rect

    ; byte 1 - red (this is dx in boot layout)
    movzx eax, byte [drb_tmp + 1]
    ; treat as signed magnitude for display
    test al, 0x80
    jz .drb1_pos
    neg al
.drb1_pos:
    movzx eax, al
    imul eax, 4
    mov edx, eax
    test edx, edx
    jnz .drb1_go
    mov edx, 2
.drb1_go:
    mov edi, 110
    mov esi, 16
    mov ecx, 8
    mov r8d, COLOR_BAR_RED
    call fill_rect

    ; byte 2 - green (this is dy in boot layout, OR dx if report ID present)
    movzx eax, byte [drb_tmp + 2]
    test al, 0x80
    jz .drb2_pos
    neg al
.drb2_pos:
    movzx eax, al
    imul eax, 4
    mov edx, eax
    test edx, edx
    jnz .drb2_go
    mov edx, 2
.drb2_go:
    mov edi, 110
    mov esi, 26
    mov ecx, 8
    mov r8d, COLOR_BAR_GREEN
    call fill_rect

    ; byte 3 - cyan (dy if report ID present, or wheel)
    movzx eax, byte [drb_tmp + 3]
    test al, 0x80
    jz .drb3_pos
    neg al
.drb3_pos:
    movzx eax, al
    imul eax, 4
    mov edx, eax
    test edx, edx
    jnz .drb3_go
    mov edx, 2
.drb3_go:
    mov edi, 110
    mov esi, 36
    mov ecx, 8
    mov r8d, COLOR_BAR_CYAN
    call fill_rect
    ret

; ============================================================================
; FILL_RECT  EDI=x  ESI=y  EDX=w  ECX=h  R8D=ARGB
; ============================================================================
fill_rect:
    push rax
    push rbx
    push rdi
    push rsi
    push r9
    push r10
    push r11

    mov r9d, [v_pitch_pixels]
    mov rbx, [v_fb]
    ; rdi = fb + (y * pitch + x) * 4
    mov eax, esi
    imul eax, r9d
    add eax, edi
    shl rax, 2
    add rbx, rax
    mov r10d, ecx                              ; row counter
.fr_row:
    test r10d, r10d
    jz .fr_done
    mov r11d, edx                              ; col counter
    mov rdi, rbx
.fr_col:
    test r11d, r11d
    jz .fr_next
    mov [rdi], r8d
    add rdi, 4
    dec r11d
    jmp .fr_col
.fr_next:
    mov eax, r9d
    shl eax, 2
    add rbx, rax
    dec r10d
    jmp .fr_row
.fr_done:
    pop r11
    pop r10
    pop r9
    pop rsi
    pop rdi
    pop rbx
    pop rax
    ret

; ============================================================================
; PROBE_USB_IO - enumerate USB_IO handles, find HID class=3 protocol=2 (mouse),
; pick its IN interrupt endpoint, send SET_PROTOCOL(boot=0).
; ============================================================================