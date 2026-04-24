app_about_draw:
    push rbx
    push r12
    push r13
    push r14

    mov rbx, rdi
    mov r12, [rbx + WIN_OFF_X]
    mov r13, [rbx + WIN_OFF_Y]
    mov r14, [rbx + WIN_OFF_W]

    ; OS Icon (blue square)
    mov rdi, r12
    add rdi, BORDER_WIDTH + 8
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 12
    mov edx, 48
    mov ecx, 48
    mov r8d, 0x002255AA
    call render_rect

    ; "N" in the icon
    mov rdi, r12
    add rdi, BORDER_WIDTH + 28
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 28
    mov rdx, szIconN
    mov ecx, COLOR_TEXT_WHITE
    mov r8d, 0x002255AA
    call render_text

    ; Title
    mov rdi, r12
    add rdi, BORDER_WIDTH + 68
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 16
    mov rdx, szAboutName
    mov ecx, 0x00222222
    mov r8d, COLOR_WINDOW_BG
    call render_text

    ; Version
    mov rdi, r12
    add rdi, BORDER_WIDTH + 68
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 36
    mov rdx, szAboutVer
    mov ecx, 0x00666666
    mov r8d, COLOR_WINDOW_BG
    call render_text

    ; Separator
    mov rdi, r12
    add rdi, BORDER_WIDTH + 4
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 68
    mov rdx, r14
    sub rdx, BORDER_WIDTH * 2 + 8
    mov ecx, 1
    mov r8d, 0x00CCCCCC
    call render_rect

    ; Info lines
    mov rdi, r12
    add rdi, BORDER_WIDTH + 8
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 78
    mov rdx, szAboutArch
    mov ecx, 0x00444444
    mov r8d, COLOR_WINDOW_BG
    call render_text

    mov rdi, r12
    add rdi, BORDER_WIDTH + 8
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 98
    mov rdx, szAboutDesc
    mov ecx, 0x00444444
    mov r8d, COLOR_WINDOW_BG
    call render_text

    mov rdi, r12
    add rdi, BORDER_WIDTH + 8
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 118
    mov rdx, szAboutCopy
    mov ecx, 0x00888888
    mov r8d, COLOR_WINDOW_BG
    call render_text

    pop r14
    pop r13
    pop r12
    pop rbx
    ret

; ============================================================================
; Right-click context menu for explorer (called from main event loop)
; RDI=mouseX, RSI=mouseY (screen coords)
; ============================================================================
global app_show_context_menu
