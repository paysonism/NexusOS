app_paint_draw:
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov rbx, rdi
    mov r15, [rbx + WIN_OFF_APPDATA]
    mov r12, [rbx + WIN_OFF_X]
    mov r13, [rbx + WIN_OFF_Y]
    mov r14, [rbx + WIN_OFF_W]

    ; 1. Draw Toolbar background (top 44px)
    mov rdi, r12
    add rdi, BORDER_WIDTH
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT
    mov rdx, r14
    sub rdx, BORDER_WIDTH * 2
    mov rcx, 44
    mov r8d, 0x00D0D0D0
    call render_rect

    ; --- Color Palette ---
    ; X: 10 to 202 (8 * 24 = 192px width)
    xor r10d, r10d  ; index
.palette_loop:
    cmp r10d, 8
    jge .palette_done
    
    mov rdi, r12
    add rdi, BORDER_WIDTH + 10
    imul eax, r10d, 24
    add edi, eax
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 10
    mov rdx, 20
    mov rcx, 20
    
    lea rax, [paint_palette_colors]
    mov r8d, [rax + r10*4]
    call render_rect
    
    ; Selection Indicator
    cmp r8d, [paint_color]
    jne .pal_next
    mov rdi, r12
    add rdi, BORDER_WIDTH + 10 + 8
    imul eax, r10d, 24
    add edi, eax
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 34
    mov rdx, 4
    mov rcx, 4
    mov r8d, 0x00000000
    call render_rect
    
.pal_next:
    inc r10d
    jmp .palette_loop
.palette_done:

    ; --- Buttons (Right aligned) ---
    ; Clear Button: X = Width - 110, Y = 10
    mov rdi, r12
    add rdi, r14
    sub rdi, 110
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 10
    mov rdx, 45
    mov rcx, 24
    mov r8d, 0x00A0A0A0
    call render_rect
    
    mov rdi, r12
    add rdi, r14
    sub rdi, 105
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 15
    mov rdx, szEditClear
    mov ecx, 0x00000000
    mov r8d, 0x00A0A0A0
    call render_text

    ; Save Button: X = Width - 60, Y = 10
    mov rdi, r12
    add rdi, r14
    sub rdi, 55
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 10
    mov rdx, 45
    mov rcx, 24
    mov r8d, 0x00A0A0A0
    call render_rect
    
    mov rdi, r12
    add rdi, r14
    sub rdi, 50
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 15
    mov rdx, szFileSave
    mov ecx, 0x00000000
    mov r8d, 0x00A0A0A0
    call render_text

    ; --- Canvas Border (Dark Gray) ---
    ; Canvas centered at X = (W - 200)/2 = (340-200)/2 = 70
    ; Y = 50
    mov rdi, r12
    add rdi, BORDER_WIDTH + 69
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 49
    mov rdx, 202
    mov rcx, 152
    mov r8d, 0x00555555
    call render_rect

    ; --- Draw Canvas from Buffer (Clipped) ---
    mov r10d, r12d
    add r10d, BORDER_WIDTH + 70  ; Canvas Screen X
    mov r11d, r13d
    add r11d, TITLEBAR_HEIGHT + 50 ; Canvas Screen Y
    
    xor ecx, ecx ; y line counter (0 to 149)
.canvas_loop_y:
    cmp ecx, 150
    jge .canvas_done
    
    push rcx
    
    ; Calculate Screen Y for this line
    mov eax, r11d
    add eax, ecx
    
    ; Clip Y
    cmp eax, 0
    jl .skip_row_pop
    cmp eax, SCREEN_HEIGHT
    jge .skip_row_pop
    
    ; Prepare X clipping
    mov r8d, r10d         ; Screen X
    mov r9d, 200          ; Width
    xor ebx, ebx          ; Source X offset (pixels)
    
    ; Clip Left
    cmp r8d, 0
    jge .chk_right
    ; X < 0
    mov ebx, r8d
    neg ebx               ; ebx = -X (positive) = pixels to skip
    sub r9d, ebx          ; Width -= skip
    mov r8d, 0            ; Clip Screen X to 0
.chk_right:
    ; Clip Right
    mov eax, r8d
    add eax, r9d
    sub eax, SCREEN_WIDTH
    jle .calc_ptrs
    ; Over > 0
    sub r9d, eax          ; Width -= Over
.calc_ptrs:
    cmp r9d, 0
    jle .skip_row_pop

    ; Valid row, copy r9d pixels
    
    ; Source: slot-local paint canvas + (y * 200 + SrcOffset) * 4
    mov eax, [rsp]        ; y
    imul eax, 200
    add eax, ebx          ; + SrcOffset
    shl eax, 2            ; * 4
    lea rsi, [r15 + APP_SLOT_PAINT_CANVAS_OFF + rax]
    
    ; Dest: bb_addr + (ScreenY * Pitch) + (ScreenX * 4)
    ; ScreenY is (r11d + [rsp])
    mov eax, r11d
    add eax, [rsp]
    imul eax, SCREEN_PITCH
    
    mov edx, r8d          ; Screen X
    shl edx, 2
    add eax, edx
    add rax, [bb_addr]
    mov rdi, rax
    
    ; Copy
    mov ecx, r9d
    rep movsd
    
.skip_row_pop:
    pop rcx
    inc ecx
    jmp .canvas_loop_y
.canvas_done:

    ; --- Save As Dialog Overlay ---
    cmp byte [paint_save_active], 1
    jne .paint_no_save
    
    ; Draw dialog background (centered)
    ; Window is 340x240. Dialog 220x80.
    ; X = 60, Y = 80
    mov rdi, r12
    add rdi, 60
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 80
    mov rdx, 220
    mov rcx, 80
    mov r8d, 0x00E0E0E0
    call render_rect
    
    call render_rect
    
    ; Border (using 4 rects)
    ; Top
    mov rdi, r12
    add rdi, 60
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 80
    mov rdx, 220
    mov rcx, 1
    mov r8d, 0x00404040
    call render_rect
    ; Bottom
    mov rdi, r12
    add rdi, 60
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 159
    mov rdx, 220
    mov rcx, 1
    mov r8d, 0x00404040
    call render_rect
    ; Left
    mov rdi, r12
    add rdi, 60
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 80
    mov rdx, 1
    mov rcx, 80
    mov r8d, 0x00404040
    call render_rect
    ; Right
    mov rdi, r12
    add rdi, 279
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 80
    mov rdx, 1
    mov rcx, 80
    mov r8d, 0x00404040
    call render_rect
    
    ; Text "Save As:"
    mov rdi, r12
    add rdi, 70
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 90
    mov rdx, szSaveAsTitle ; Reuse Notepad string "Save As"
    mov ecx, 0x00000000
    mov r8d, 0x00E0E0E0
    call render_text
    
    ; Filename input box
    mov rdi, r12
    add rdi, 70
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 110
    mov rdx, 140
    mov rcx, 18
    mov r8d, 0x00FFFFFF
    call render_rect
    
    ; Typed filename
    mov rdi, r12
    add rdi, 74
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 112
    lea rdx, [paint_save_buf]
    mov ecx, 0x00000000
    mov r8d, 0x00FFFFFF
    call render_text
    
    ; Cursor "_"
    mov eax, [paint_save_len]
    imul eax, 8 ; font width
    add edi, eax
    mov rdx, szCursor
    call render_text
    
    ; Ext ".BMP"
    mov rdi, r12
    add rdi, 215
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 112
    mov rdx, szExtBmp
    mov ecx, 0x00000000
    mov r8d, 0x00E0E0E0
    call render_text
    
    ; Hint "Enter=Save"
    mov rdi, r12
    add rdi, 70
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 135
    mov rdx, szSaveAsHint
    mov ecx, 0x00555555
    mov r8d, 0x00E0E0E0
    call render_text

.paint_no_save:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

; Click Handler
; RSI = Client X, RDX = Client Y
app_paint_click:
    push rbx
    push r12
    push r13
    
    mov rbx, rdi
    mov r13, [rbx + WIN_OFF_APPDATA]
    mov r12, [rbx + WIN_OFF_W] ; Window width
    
    ; Check Canvas Click
    ; Canvas is at X=70, Y=50, W=200, H=150
    ; Client Y coords (relative to titlebar bottom)
    
    cmp rdx, 50
    jl .check_toolbar
    
    ; Canvas Area
    sub rsi, 70
    sub rdx, 50
    
    cmp rsi, 0
    jl .done_click
    cmp rsi, 200
    jge .done_click
    cmp rdx, 0
    jl .done_click
    cmp rdx, 150
    jge .done_click
    
    ; Draw Point
    mov eax, edx
    imul eax, 200
    add eax, esi
    shl eax, 2
    lea rax, [r13 + APP_SLOT_PAINT_CANVAS_OFF + rax]
    
    mov ecx, [paint_color]
    mov [rax], ecx
    
    ; 2x2 Brush (simple bounds check)
    cmp rsi, 199
    jge .done_click
    cmp rdx, 149
    jge .done_click
    mov [rax + 4], ecx
    mov [rax + 800], ecx
    mov [rax + 804], ecx
    jmp .done_click

.check_toolbar:
    ; Palette: X=10..202, Y=10..30
    cmp rdx, 10
    jl .done_click
    cmp rdx, 30
    jg .done_click
    
    cmp rsi, 10
    jl .done_click
    cmp rsi, 202
    jg .check_tb_buttons
    
    ; Palette click
    sub rsi, 10
    mov rax, rsi
    xor rdx, rdx
    mov rcx, 24
    div rcx
    ; RAX = index (0..7)
    cmp rax, 8
    jge .done_click
    
    lea rcx, [paint_palette_colors]
    mov edx, [rcx + rax*4]
    mov [paint_color], edx
    jmp .done_click

.check_tb_buttons:
    ; Clear: Width-110 to Width-65
    ; Save: Width-55 to Width-10
    
    ; Calc offsets from right
    mov rax, r12
    sub rax, rsi   ; rax = distance from right edge
    
    ; Save button is 10..55 px from right (padding 10 + width 45)
    ; Clear button is 65..110 px from right
    
    cmp rax, 10
    jl .done_click
    
    cmp rax, 55
    jle .click_save
    
    cmp rax, 65
    jl .done_click
    
    cmp rax, 110
    jle .click_clear
    
    jmp .done_click

.click_save:
    ; Toggle save mode
    mov byte [paint_save_active], 1
    mov byte [paint_save_buf], 0
    mov dword [paint_save_len], 0
    jmp .done_click

.click_clear:
    mov rdi, r13
    add rdi, APP_SLOT_PAINT_CANVAS_OFF
    mov ecx, 30000
    mov eax, 0xFFFFFFFF
    rep stosd
    
.done_click:
    pop r13
    pop r12
    pop rbx
    ret

; Key handler for Paint (Save As)
app_paint_key:
    cmp byte [paint_save_active], 1
    jne .pk_ret
    
    push rbx
    push rcx
    push rdx
    
    ; Extract ASCII
    mov eax, esi
    shr eax, 8
    and eax, 0xFF
    test eax, eax
    jz .pk_done
    
    ; Esc = Cancel
    cmp al, 27
    je .pk_cancel
    
    ; Enter = Save
    cmp al, 13
    je .pk_save
    
    ; Backspace
    cmp al, 8
    je .pk_backspace
    
    ; Printable: A-Z, 0-9
    ; ToUpper
    cmp al, 'a'
    jl .pk_chk_num
    cmp al, 'z'
    jg .pk_chk_num
    sub al, 32
.pk_chk_num:
    ; Valid chars?
    cmp al, ' '
    jl .pk_done
    cmp al, '~'
    jg .pk_done
    
    ; Append to buffer (max 8 chars)
    mov ecx, [paint_save_len]
    cmp ecx, 8
    jge .pk_done
    lea rbx, [paint_save_buf]
    mov [rbx + rcx], al
    inc ecx
    mov byte [rbx + rcx], 0
    mov [paint_save_len], ecx
    jmp .pk_done

.pk_backspace:
    mov ecx, [paint_save_len]
    test ecx, ecx
    jz .pk_done
    dec ecx
    lea rbx, [paint_save_buf]
    mov byte [rbx + rcx], 0
    mov [paint_save_len], ecx
    jmp .pk_done

.pk_cancel:
    mov byte [paint_save_active], 0
    jmp .pk_done

.pk_save:
    ; Format 8.3 filename
    ; Filename is in paint_save_buf (up to 8 chars)
    ; Extension is BMP
    lea rdi, [paint_filename_83]
    lea rsi, [paint_save_buf]
    ; Fill with spaces first
    push rdi
    mov ecx, 11
    mov al, ' '
    rep stosb
    pop rdi
    
    ; Copy name
    mov ecx, [paint_save_len]
    rep movsb
    
    ; Set extension at offset 8
    lea rdi, [paint_filename_83 + 8]
    mov byte [rdi], 'B'
    mov byte [rdi+1], 'M'
    mov byte [rdi+2], 'P'
    
    mov rdi, rbx
    call app_paint_save
    mov byte [paint_save_active], 0
    jmp .pk_done

.pk_done:
    pop rdx
    pop rcx
    pop rbx
    ret
.pk_ret:
    ret

app_paint_save:
    mov rbx, [rdi + WIN_OFF_APPDATA]
    mov r10, rbx
    lea rdi, [rbx + APP_SLOT_SAVE_BMP_OFF]
    mov byte [rdi], 'B'
    mov byte [rdi+1], 'M'
    mov dword [rdi+2], 90054
    mov dword [rdi+6], 0
    mov dword [rdi+10], 54
    mov dword [rdi+14], 40
    mov dword [rdi+18], 200
    mov dword [rdi+22], 150
    mov word [rdi+26], 1
    mov word [rdi+28], 24
    mov dword [rdi+30], 0
    mov dword [rdi+34], 90000
    mov dword [rdi+38], 0
    mov dword [rdi+42], 0
    mov dword [rdi+46], 0
    mov dword [rdi+50], 0
    
    lea rsi, [rbx + APP_SLOT_PAINT_CANVAS_OFF]
    lea rbx, [rbx + APP_SLOT_SAVE_BMP_OFF + 54]
    mov r8d, 149
.save_row_loop:
    cmp r8d, 0
    jl .save_done
    mov eax, r8d
    imul eax, 200 * 4
    lea r9, [rsi + rax]
    xor ecx, ecx
.save_col_loop:
    cmp ecx, 200
    jge .save_row_next
    mov eax, [r9 + rcx*4]
    mov byte [rbx], al
    shr eax, 8
    mov byte [rbx+1], al
    shr eax, 8
    mov byte [rbx+2], al
    add rbx, 3
    inc ecx
    jmp .save_col_loop
.save_row_next:
    dec r8d
    jmp .save_row_loop
.save_done:
    lea rdi, [paint_filename_83]
    mov rsi, r10
    add rsi, APP_SLOT_SAVE_BMP_OFF
    mov edx, 90054
    call fat16_write_file
    ret

; ============================================================================
; DATA SECTION
; ============================================================================
