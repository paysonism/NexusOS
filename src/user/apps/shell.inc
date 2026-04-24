app_show_context_menu:
    mov [ctx_menu_x], edi
    mov [ctx_menu_y], esi
    mov byte [ctx_menu_visible], 1
    ret

; ============================================================================
; PROPERTIES WINDOW
; Shows file name, type, and size
; ============================================================================
app_properties_draw:
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov rbx, rdi
    mov r12, [rbx + WIN_OFF_X]
    mov r13, [rbx + WIN_OFF_Y]
    mov r14, [rbx + WIN_OFF_W]
    mov r15, [rbx + WIN_OFF_H]

    mov rcx, [prop_entry_ptr]
    test rcx, rcx
    jz .prop_draw_done

    ; "Name:" label at y+4
    mov rdi, r12
    add rdi, BORDER_WIDTH + 8
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 8
    mov rdx, szPropName
    mov ecx, 0x00555555
    mov r8d, COLOR_WINDOW_BG
    call render_text

    ; File name value - format 8.3 name from FAT16 entry
    mov rcx, [prop_entry_ptr]
    push rcx
    mov rdi, fat16_name_buf
    mov rsi, rcx
    call fat16_format_name
    pop rcx

    mov rdi, r12
    add rdi, BORDER_WIDTH + 60
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 8
    mov rdx, fat16_name_buf
    mov ecx, 0x00000000
    mov r8d, COLOR_WINDOW_BG
    call render_text

    ; "Type:" label
    mov rdi, r12
    add rdi, BORDER_WIDTH + 8
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 30
    mov rdx, szPropType
    mov ecx, 0x00555555
    mov r8d, COLOR_WINDOW_BG
    call render_text

    ; Type value - FAT16: byte 11 bit 0x10 = directory
    mov rcx, [prop_entry_ptr]
    mov al, [rcx + 11]
    test al, 0x10
    jz .prop_is_file
    mov rdx, szPropTypeDir
    jmp .prop_draw_type
.prop_is_file:
    mov rdx, szPropTypeFile
.prop_draw_type:
    mov rdi, r12
    add rdi, BORDER_WIDTH + 60
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 30
    mov ecx, 0x00000000
    mov r8d, COLOR_WINDOW_BG
    call render_text

    ; "Size:" label
    mov rdi, r12
    add rdi, BORDER_WIDTH + 8
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 52
    mov rdx, szPropSize
    mov ecx, 0x00555555
    mov r8d, COLOR_WINDOW_BG
    call render_text

    ; Size value - FAT16: bytes 28-31 = uint32 file size
    mov rcx, [prop_entry_ptr]
    mov al, [rcx + 11]
    test al, 0x10
    jnz .prop_show_dir_size
    ; Convert size to string
    push rcx
    mov edi, [rcx + 28]
    mov rsi, fat16_size_buf
    call app_format_bytes_size
    pop rcx
    mov rdx, fat16_size_buf
    jmp .prop_show_size
.prop_show_dir_size:
    mov rdx, szPropSizeDir
.prop_show_size:
    mov rdi, r12
    add rdi, BORDER_WIDTH + 60
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 52
    mov ecx, 0x00000000
    mov r8d, COLOR_WINDOW_BG
    call render_text

    ; "Location:" label
    mov rdi, r12
    add rdi, BORDER_WIDTH + 8
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 74
    mov rdx, szPropLoc
    mov ecx, 0x00555555
    mov r8d, COLOR_WINDOW_BG
    call render_text

    ; Location value
    mov rdx, szPathRoot
    mov rdi, r12
    add rdi, BORDER_WIDTH + 60
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 74
    mov ecx, 0x00000000
    mov r8d, COLOR_WINDOW_BG
    call render_text

.prop_draw_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

global ctx_menu_visible

; ============================================================================
; BMP VIEWER
; Opens a BMP file and displays it in a window
; ============================================================================

app_open_file_in_bmpview:
    push rbx
    push r12
    push r13

    mov r12, rdi             ; dir entry ptr
    mov rbx, [rsi + WIN_OFF_APPDATA]
    lea r13, [rbx + APP_SLOT_BMP_FILE_OFF]

    ; Read BMP file into memory via syscall
    mov rdi, r12
    mov rsi, r13
    mov rdx, APP_SLOT_BMP_FILE_SZ
    SYS_FS_READ rdi, rsi, rdx
    cmp eax, -1
    je .bmp_open_fail

    ; Parse BMP header
    ; Check 'BM' signature
    cmp byte [r13], 'B'
    jne .bmp_open_fail
    cmp byte [r13 + 1], 'M'
    jne .bmp_open_fail

    ; Get width/height from DIB header (offset 18/22)
    mov eax, [r13 + 18]
    mov [bmp_width], eax
    mov eax, [r13 + 22]
    mov [bmp_height], eax
    ; Get pixel data offset (offset 10)
    mov eax, [r13 + 10]
    mov [bmp_data_offset], eax
    ; Get bits per pixel (offset 28)
    movzx eax, word [r13 + 28]
    mov [bmp_bpp], eax

    ; Create viewer window
    mov rdi, fat16_name_buf
    mov rsi, r12
    call fat16_format_name

    mov rdi, fat16_name_buf
    mov rsi, 150
    mov rdx, 100
    ; Window size = image size + borders + titlebar
    mov r10d, [bmp_width]
    add r10d, BORDER_WIDTH * 2
    cmp r10d, 200
    jge .bmp_w_ok
    mov r10d, 200
.bmp_w_ok:
    mov r8d, [bmp_height]
    add r8d, TITLEBAR_HEIGHT + BORDER_WIDTH
    cmp r8d, 100
    jge .bmp_h_ok
    mov r8d, 100
.bmp_h_ok:
    lea r9, [rel app_bmp_draw]
    SYS_WM_CREATE rdi, rsi, rdx, r10, r8, r9

.bmp_open_fail:
    pop r13
    pop r12
    pop rbx
    ret

; BMP viewer draw callback
app_bmp_draw:
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov rbx, rdi
    mov r12, [rbx + WIN_OFF_X]    ; window X
    mov r13, [rbx + WIN_OFF_Y]    ; window Y

    ; Get BMP parameters
    mov ecx, [bmp_width]
    mov edx, [bmp_height]
    test ecx, ecx
    jz .bmp_draw_done
    test edx, edx
    jz .bmp_draw_done

    ; Calculate BMP row size (padded to 4 bytes)
    mov eax, [bmp_bpp]
    cmp eax, 24
    jne .bmp_draw_done        ; only support 24bpp for now

    mov eax, ecx
    imul eax, 3               ; bytes per row (24bpp)
    add eax, 3
    and eax, ~3               ; pad to 4 bytes
    mov r14d, eax             ; row stride

    ; BMP is bottom-up, so row 0 is at bottom
    mov r15d, edx             ; height
    dec r15d                  ; start from last row

    ; Source = slot-local BMP buffer + data_offset
    mov rax, [rbx + WIN_OFF_APPDATA]
    add rax, APP_SLOT_BMP_FILE_OFF
    add rax, [bmp_data_offset]
    mov r8, rax

    ; Get framebuffer address
    mov rax, [bb_addr]         ; backbuffer logic

    ; Draw pixel by pixel
    xor edx, edx              ; dest Y counter (0 = top)
.bmp_row_loop:
    cmp edx, [bmp_height]
    jge .bmp_draw_done

    ; Source row = r15d (counts down from height-1)
    mov eax, r15d
    imul eax, r14d            ; row * stride
    lea rsi, [r8 + rax]      ; source pixel row

    ; Dest pixel Y = window_Y + titlebar + edx
    mov edi, r13d
    add edi, TITLEBAR_HEIGHT
    add edi, edx
    ; Check Y bounds
    cmp edi, SCREEN_HEIGHT
    jge .bmp_draw_done

    imul edi, [scr_pitch]    ; Y * pitch (use variable pitch)

    xor ecx, ecx              ; X counter
.bmp_col_loop:
    cmp ecx, [bmp_width]
    jge .bmp_row_done

    ; Dest pixel X = window_X + border + ecx
    mov ebx, r12d
    add ebx, BORDER_WIDTH
    add ebx, ecx
    cmp ebx, SCREEN_WIDTH
    jge .bmp_row_done

    ; Read BGR from source
    movzx r9d, byte [rsi]      ; B
    movzx r10d, byte [rsi + 1] ; G
    movzx r11d, byte [rsi + 2] ; R
    add rsi, 3

    ; Compose 32-bit pixel: 0x00RRGGBB
    shl r11d, 16
    shl r10d, 8
    or r11d, r10d
    or r11d, r9d

    ; Write to framebuffer
    push rdi
    mov rax, [bb_addr]        ; RELOAD bb_addr (eax clobbered by source calc)
    add rdi, rax
    mov [rdi + rbx * 4], r11d
    pop rdi

    inc ecx
    jmp .bmp_col_loop

.bmp_row_done:
    dec r15d
    inc edx
    jmp .bmp_row_loop

.bmp_draw_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

; ============================================================================
; HELPER FUNCTIONS
; ============================================================================

; fat16_format_name - Format FAT16 8.3 name to readable string
; rdi = output buffer (at least 13 bytes)
; rsi = pointer to FAT16 dir entry (32 bytes)
fat16_format_name:
    push rax
    push rcx
    push rdx
    push rdi
    push rsi

    ; Copy filename part (8 bytes), strip trailing spaces
    mov ecx, 8
.fn_copy:
    lodsb
    cmp al, ' '
    je .fn_space
    stosb
    dec ecx
    jnz .fn_copy
    jmp .fn_dot
.fn_space:
    dec ecx
    ; Skip remaining filename chars
.fn_skip:
    test ecx, ecx
    jz .fn_dot
    lodsb
    dec ecx
    jmp .fn_skip

.fn_dot:
    ; Check if extension is blank
    mov al, [rsi]
    cmp al, ' '
    je .fn_noext
    ; Add dot
    mov byte [rdi], '.'
    inc rdi
    ; Copy extension (3 bytes), strip trailing spaces
    mov ecx, 3
.ext_copy:
    lodsb
    cmp al, ' '
    je .ext_done
    stosb
    dec ecx
    jnz .ext_copy
.ext_done:
.fn_noext:
    mov byte [rdi], 0     ; null terminate

    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rax
    ret

; fat16_format_name_to - Same as fat16_format_name but rdi = destination
; rdi = destination buffer
; rsi = FAT16 dir entry pointer
fat16_format_name_to:
    jmp fat16_format_name   ; same function

; filename_to_83 - Convert user filename ("hello.txt") to FAT16 8.3 format ("HELLO   TXT")
; rdi = input null-terminated string (user typed)
; rsi = output buffer (at least 11 bytes)
; Uppercases, pads with spaces, splits on dot
filename_to_83:
    push rax
    push rcx
    push rdx
    push rdi
    push rsi

    mov rdx, rsi             ; rdx = output buffer

    ; Fill output with 11 spaces
    mov ecx, 11
    mov rsi, rdx
.fill_spaces:
    mov byte [rsi], ' '
    inc rsi
    dec ecx
    jnz .fill_spaces

    ; Copy name part (up to 8 chars before dot)
    mov rsi, rdi             ; rsi = input string
    xor ecx, ecx             ; char count
.name_copy:
    mov al, [rsi]
    test al, al
    jz .name_done
    cmp al, '.'
    je .found_dot
    cmp ecx, 8
    jge .name_skip
    ; Uppercase
    cmp al, 'a'
    jl .name_store
    cmp al, 'z'
    jg .name_store
    sub al, 32
.name_store:
    mov [rdx + rcx], al
    inc ecx
.name_skip:
    inc rsi
    jmp .name_copy

.found_dot:
    inc rsi                   ; skip the dot
    ; Copy extension (up to 3 chars)
    xor ecx, ecx
.ext_copy83:
    mov al, [rsi]
    test al, al
    jz .name_done
    cmp ecx, 3
    jge .name_done
    ; Uppercase
    cmp al, 'a'
    jl .ext_store
    cmp al, 'z'
    jg .ext_store
    sub al, 32
.ext_store:
    mov [rdx + 8 + rcx], al
    inc ecx
    inc rsi
    jmp .ext_copy83

.name_done:
    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rax
    ret

; app_format_bytes_size - Convert uint32 to decimal string with " B" suffix
; edi = value
; rsi = output buffer (at least 16 bytes)
app_format_bytes_size:
    push rax
    push rbx
    push rcx
    push rdx
    push rdi
    push rsi

    mov eax, edi
    mov rdi, rsi          ; output buffer

    ; Handle zero
    test eax, eax
    jnz .u2s_nonzero
    mov byte [rdi], '0'
    mov byte [rdi + 1], ' '
    mov byte [rdi + 2], 'B'
    mov byte [rdi + 3], 0
    jmp .u2s_done

.u2s_nonzero:
    ; Convert to digits on stack (reverse order)
    xor ecx, ecx          ; digit count
    mov ebx, 10
    test ebx, ebx
    jz .skip_u2s
.u2s_div:
    xor edx, edx
    div ebx
    add dl, '0'
    push rdx
    inc ecx
    test eax, eax
    jnz .u2s_div

    ; Pop digits into buffer
.u2s_pop:
    pop rax
    mov [rdi], al
    inc rdi
    dec ecx
    jnz .u2s_pop

    ; Add " B" suffix
    mov byte [rdi], ' '
    mov byte [rdi + 1], 'B'
    mov byte [rdi + 2], 0

.skip_u2s:
.u2s_done:
    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; ============================================================================
; PAINTER APP
; ============================================================================

global app_paint_draw
global app_paint_click

