section .text start=0
    dw 0x5A4D
    times 29 dw 0
    dd pe_hdr

pe_hdr:
    dd PE_SIGNATURE
    dw 0x8664
    dw 2
    dd 0, 0, 0
    dw opt_end - opt_hdr
    dw 0x0206

opt_hdr:
    dw 0x020B
    db 1, 0
    dd TEXT_RAW, 0, 0, TEXT_VA, TEXT_VA
    dq IMAGE_BASE
    dd 0x1000, 0x200
    dw 0,0, 0,0, 0,0
    dd 0, IMAGE_SZ, HDR_SZ, 0
    dw 10, 0
    dq IMAGE_BASE, IMAGE_BASE, IMAGE_BASE, IMAGE_BASE
    dd 0, 6
    dd 0,0, 0,0, 0,0, 0,0, 0,0
    dd RELOC_VA, RELOC_VSZ
opt_end:

    db '.text',0,0,0
    dd TEXT_RAW, TEXT_VA, TEXT_RAW, HDR_SZ
    dd 0, 0
    dw 0, 0
    dd SECCHAR_TEXT

    db '.reloc',0,0
    dd RELOC_VSZ, RELOC_VA, RELOC_FSZ, RELOC_FOFF
    dd 0, 0
    dw 0, 0
    dd SECCHAR_RELOC

    times (HDR_SZ - ($ - $$)) db 0

; ============================================================================
; ENTRY  RCX=ImageHandle  RDX=SystemTable
; ============================================================================
_start:
    sub rsp, 40
    mov [v_handle], rcx
    mov [v_systab], rdx

    SER 'P'                                  ; P = probe start
    mov rax, [rdx + ST_BOOTSVC]
    mov [v_bs], rax
    mov rax, [rdx + ST_CONOUT]
    mov [v_conout], rax

    TRACE "T01: boot services + conout captured"

    ; Disable watchdog
    mov rcx, [v_bs]
    mov rax, [rcx + BS_WATCHDOG]
    xor ecx, ecx
    xor edx, edx
    xor r8d, r8d
    xor r9d, r9d
    call rax

    ; Reset console, disable hardware cursor (looks bad in graphics mode)
    mov rcx, [v_conout]
    mov rax, [rcx + CO_RESET]
    mov rcx, [v_conout]
    xor edx, edx
    call rax
    mov rcx, [v_conout]
    mov rax, [rcx + CO_ENABLECUR]
    mov rcx, [v_conout]
    xor edx, edx
    call rax

    TRACE "T02: watchdog off, console reset, cursor off"

    ; Print boot banner via UEFI text protocol
    lea rsi, [s_banner]
    call ucs_print
    call ucs_newline

    TRACE "T03: banner printed - about to locate GOP"

    SER 'G'
    call gop_init                             ; locate GOP, save framebuffer
    test rax, rax
    jnz no_gop_panic
    SER 'g'

    TRACE "T04: GOP located OK"

    ; Report GOP geometry
    lea rsi, [s_gop_res]
    call ucs_print
    mov edi, [v_scrw]
    call ucs_print_uint
    lea rsi, [s_x]
    call ucs_print
    mov edi, [v_scrh]
    call ucs_print_uint
    lea rsi, [s_pitch]
    call ucs_print
    mov edi, [v_pitch_pixels]
    call ucs_print_uint
    lea rsi, [s_fb]
    call ucs_print
    mov rdi, [v_fb]
    call ucs_print_hex64
    call ucs_newline

    lea rsi, [s_pixfmt]
    call ucs_print
    mov edi, [v_pixfmt]
    call ucs_print_uint
    lea rsi, [s_fbsize]
    call ucs_print
    mov rdi, [v_fbsize]
    call ucs_print_hex64
    call ucs_newline

    cmp dword [v_pixfmt], 3
    jne .pf_ok
    TRACE "T05: WARNING PixelFormat=3 (BltOnly) - NO linear framebuffer!"
.pf_ok:
    TRACE "T05: GOP geometry dumped (see pixfmt/fb above)"

    ; Use UEFI ConOut->ClearScreen instead of direct framebuffer wipe so the
    ; firmware's GraphicsConsole driver stays in sync. Set attribute to
    ; white-on-blue first for readability.
    mov rcx, [v_conout]
    mov rax, [rcx + CO_SETATTR]
    mov rcx, [v_conout]
    mov edx, 0x1F                             ; white on blue
    call rax
    mov rcx, [v_conout]
    mov rax, [rcx + CO_CLEAR]
    mov rcx, [v_conout]
    call rax

    ; Re-print banner after clear
    lea rsi, [s_banner]
    call ucs_print
    call ucs_newline
    lea rsi, [s_gop_res]
    call ucs_print
    mov edi, [v_scrw]
    call ucs_print_uint
    lea rsi, [s_x]
    call ucs_print
    mov edi, [v_scrh]
    call ucs_print_uint
    call ucs_newline

    TRACE "T06: screen cleared + reprinted - drawing TEST RECT now"

    ; --- TEST RECT: big green box at (300,300). If you see text below but
    ; NO green box, framebuffer writes are the problem (bad base/format). ---
    mov edi, 300
    mov esi, 300
    mov edx, 200
    mov ecx, 200
    mov r8d, COLOR_TEST_RECT_GREEN
    call fill_rect

    TRACE "T07: TEST RECT drawn - LOOK: is there a GREEN BOX on screen?"

    ; Initial cursor in middle of screen
    mov eax, [v_scrw]
    shr eax, 1
    mov [v_mx], eax
    mov eax, [v_scrh]
    shr eax, 1
    mov [v_my], eax

    TRACE "T08: probing SPP (LocateProtocol + handle enum)"
    SER 'S'
    lea rsi, [s_probing_spp]
    call ucs_print
    call ucs_newline
    call probe_spp_locate                     ; method 1
    SER 's'
    call probe_spp_enum                       ; method 2

    TRACE "T09: probing AbsolutePointer"
    SER 'A'
    lea rsi, [s_probing_app]
    call ucs_print
    call ucs_newline
    call probe_app_locate                     ; method 3
    SER 'a'
    call probe_app_enum                       ; method 4

    TRACE "T10: probing USB_IO"
    SER 'U'
    lea rsi, [s_probing_usb]
    call ucs_print
    call ucs_newline
    call probe_usb_io                         ; method 5: USB IO + sync interrupt
    SER 'u'

    TRACE "T11: probes done - drawing initial status row"

    lea rsi, [s_main_hdr]
    call ucs_print
    call ucs_newline

    ; Draw initial status row
    call draw_status_row

    TRACE "T12: ENTERING MAIN LOOP now"

    SDBG "probe: entering main loop"

; --- Main poll loop. Never exits. Never calls ExitBootServices. ---
; First 3 iterations are traced step-by-step so a hang inside the loop is
; pinpointed; after that it runs full speed so the mouse is responsive.
main_loop:
    cmp dword [v_frame], 3
    jae .t_a
    TRACE "L: top -> erase_cursor"
.t_a:
    call erase_cursor                         ; erase previous square
    cmp dword [v_frame], 3
    jae .t_b
    TRACE "L: -> poll_all_pointers"
.t_b:
    call poll_all_pointers                    ; updates v_mx/v_my and v_state
    cmp dword [v_frame], 3
    jae .t_c
    TRACE "L: -> usb_poll_mouse"
.t_c:
    call usb_poll_mouse                       ; slot 4: USB sync interrupt poll
    cmp dword [v_frame], 3
    jae .t_d
    TRACE "L: -> draw_cursor"
.t_d:
    call draw_cursor                          ; draw at new position
    cmp dword [v_frame], 3
    jae .t_e
    TRACE "L: -> draw_status_row"
.t_e:
    call draw_status_row                      ; refresh status dots
    cmp dword [v_frame], 3
    jae .t_f
    TRACE "L: -> draw_usb_panel"
.t_f:
    call draw_usb_panel                       ; big visible USB status block
    cmp dword [v_frame], 3
    jae .t_g
    TRACE "L: iteration complete - loop is alive"
.t_g:

    ; NO scrolling status text in the loop -- it pushed the probe results
    ; off-screen. Live state is shown graphically instead: the magenta cursor
    ; square moves, and draw_usb_panel shows the RC box (green=transfer OK,
    ; red=fail) + yellow HITS bar + report byte bars. Nothing scrolls.
    inc dword [v_frame]

    ; Stall ~10 ms
    mov rcx, [v_bs]
    mov rax, [rcx + BS_STALL]
    mov ecx, 10000                            ; microseconds
    call rax

    jmp main_loop

no_gop_panic:
    SDBG "FATAL: GOP unavailable"
.hang:
    hlt
    jmp .hang

; ============================================================================
; GOP_INIT - find GOP, take current mode, fill v_fb / v_scrw / v_scrh / v_pitch
; ============================================================================
gop_init:
    push rbx
    sub rsp, 32

    ; LocateProtocol(GOP_GUID, NULL, &v_gop)
    mov rax, [v_bs]
    mov rax, [rax + BS_LOCATE]
    lea rcx, [guid_gop]
    xor edx, edx
    lea r8, [v_gop]
    call rax
    test rax, rax
    jnz .gi_fail

    mov rbx, [v_gop]
    mov rax, [rbx + GOP_MODE]                 ; EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE*
    ; Mode->Info is at offset 8 (UINT32 MaxMode, UINT32 Mode, EFI_GRAPHICS_OUTPUT_MODE_INFORMATION *Info, ...)
    ; We use the *current* mode info, do not change resolution.
    mov rcx, [rax + 8]                        ; Info ptr
    mov edx, [rcx + GOPI_HRES]
    mov [v_scrw], edx
    mov edx, [rcx + GOPI_VRES]
    mov [v_scrh], edx
    mov edx, [rcx + GOPI_PPSL]
    mov [v_pitch_pixels], edx
    mov edx, [rcx + 12]                       ; PixelFormat (0=RGB,1=BGR,2=mask,3=BltOnly)
    mov [v_pixfmt], edx

    mov rdx, [rax + GOPM_FBBASE]
    mov [v_fb], rdx
    mov rdx, [rax + 32]                       ; FrameBufferSize
    mov [v_fbsize], rdx

    xor eax, eax
    jmp .gi_done
.gi_fail:
    mov eax, 1
.gi_done:
    add rsp, 32
    pop rbx
    ret

; ============================================================================
; CLEAR_SCREEN_BG - blast a dark background across the entire framebuffer
; ============================================================================
clear_screen_bg:
    push rdi
    push rcx
    mov rdi, [v_fb]
    mov ecx, [v_pitch_pixels]
    imul ecx, [v_scrh]
    mov eax, COLOR_BG_DARK_SLATE              ; very dark blue-grey
    rep stosd
    pop rcx
    pop rdi
    ret

; ============================================================================
; PROBE_SPP_LOCATE - try LocateProtocol(SPP_GUID)
; Stores interface ptr in v_spp[0], success flag in v_spp_ok[0]
; ============================================================================