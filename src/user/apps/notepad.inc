app_notepad_draw:
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

    ; Menu bar
    mov rdi, r12
    add rdi, BORDER_WIDTH
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT
    mov rdx, r14
    sub rdx, BORDER_WIDTH * 2
    mov ecx, NP_MENU_H
    mov r8d, 0x00E8E8E8
    call render_rect

    ; "File" menu label
    mov rdi, r12
    add rdi, BORDER_WIDTH + 4
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 2
    mov rdx, szNoteMenuFile
    mov ecx, 0x00333333
    mov r8d, 0x00E8E8E8
    call render_text

    ; "Edit" menu label
    mov rdi, r12
    add rdi, BORDER_WIDTH + 52
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 2
    mov rdx, szNoteMenuEdit
    mov ecx, 0x00333333
    mov r8d, 0x00E8E8E8
    call render_text

    ; White editing area
    mov rdi, r12
    add rdi, BORDER_WIDTH
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + NP_EDIT_TOP
    mov rdx, r14
    sub rdx, BORDER_WIDTH * 2
    mov rcx, r15
    sub rcx, TITLEBAR_HEIGHT + NP_EDIT_TOP + BORDER_WIDTH
    cmp rcx, 0
    jle .note_draw_done
    mov r8d, 0x00FFFFFF
    call render_rect

    ; Calculate visible lines
    mov eax, r15d
    sub eax, TITLEBAR_HEIGHT + NP_EDIT_TOP + BORDER_WIDTH
    xor edx, edx
    mov ecx, 14                  ; line height
    div ecx
    mov r8d, eax                 ; max visible lines
    test r8d, r8d
    jz .note_draw_done

    ; Draw text lines
    mov eax, [np_scroll_top]
    xor ecx, ecx                ; display line counter
.np_draw_lines:
    cmp ecx, r8d
    jge .np_lines_done
    cmp eax, [np_num_lines]
    jge .np_lines_done

    push rax
    push rcx
    push r8

    ; Get line pointer: notepad_buf + line_idx * NP_MAX_COLS
    mov edx, eax
    imul edx, NP_MAX_COLS
    lea rdx, [notepad_buf + rdx]

    ; Check if line is empty
    cmp byte [rdx], 0
    je .np_empty_line

    mov rdi, r12
    add rdi, BORDER_WIDTH + 4
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + NP_EDIT_TOP + 2
    imul r8d, ecx, 14
    add esi, r8d
    mov ecx, 0x00000000
    mov r8d, 0x00FFFFFF
    call render_text

.np_empty_line:
    pop r8
    pop rcx
    pop rax

    inc eax
    inc ecx
    jmp .np_draw_lines

.np_lines_done:
    ; Draw cursor
    mov eax, [np_cursor_row]
    sub eax, [np_scroll_top]
    cmp eax, 0
    jl .note_draw_done
    cmp eax, r8d
    jge .note_draw_done

    ; Cursor position
    mov edi, [np_cursor_col]
    imul edi, FONT_WIDTH
    add edi, BORDER_WIDTH + 4
    add edi, r12d
    mov esi, eax
    imul esi, 14
    add esi, TITLEBAR_HEIGHT + NP_EDIT_TOP + 2
    add esi, r13d
    mov rdx, szCursor
    mov ecx, 0x00000000
    mov r8d, 0x00FFFFFF
    call render_text

    ; --- Draw dropdown menu if open ---
    cmp byte [np_menu_open], 0
    je .note_draw_done

    cmp byte [np_menu_open], 1
    je .draw_file_menu
    cmp byte [np_menu_open], 2
    je .draw_edit_menu
    jmp .note_draw_done

.draw_file_menu:
    ; File dropdown (3 items: New, Save, Close)
    mov rdi, r12
    add rdi, BORDER_WIDTH
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + NP_MENU_H
    mov edx, 100
    mov ecx, CTX_ITEM_H * 3 + 4
    mov r8d, 0x00F0F0F0
    call render_rect
    ; Border
    mov rdi, r12
    add rdi, BORDER_WIDTH
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + NP_MENU_H
    mov edx, 100
    mov ecx, 1
    mov r8d, 0x00999999
    call render_rect
    ; Item 0: New
    mov rdi, r12
    add rdi, BORDER_WIDTH + 8
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + NP_MENU_H + 4
    mov rdx, szFileNew
    mov ecx, 0x00222222
    mov r8d, 0x00F0F0F0
    call render_text
    ; Item 1: Save
    mov rdi, r12
    add rdi, BORDER_WIDTH + 8
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + NP_MENU_H + 4 + CTX_ITEM_H
    mov rdx, szFileSave
    mov ecx, 0x00222222
    mov r8d, 0x00F0F0F0
    call render_text
    ; Item 2: Close
    mov rdi, r12
    add rdi, BORDER_WIDTH + 8
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + NP_MENU_H + 4 + CTX_ITEM_H * 2
    mov rdx, szFileClose
    mov ecx, 0x00222222
    mov r8d, 0x00F0F0F0
    call render_text
    jmp .note_draw_done

.draw_edit_menu:
    ; Edit dropdown
    mov rdi, r12
    add rdi, BORDER_WIDTH + 48
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + NP_MENU_H
    mov edx, 110
    mov ecx, CTX_ITEM_H * 2 + 4
    mov r8d, 0x00F0F0F0
    call render_rect
    ; Border
    mov rdi, r12
    add rdi, BORDER_WIDTH + 48
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + NP_MENU_H
    mov edx, 110
    mov ecx, 1
    mov r8d, 0x00999999
    call render_rect
    ; Items
    mov rdi, r12
    add rdi, BORDER_WIDTH + 56
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + NP_MENU_H + 4
    mov rdx, szEditSelAll
    mov ecx, 0x00222222
    mov r8d, 0x00F0F0F0
    call render_text
    mov rdi, r12
    add rdi, BORDER_WIDTH + 56
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + NP_MENU_H + 4 + CTX_ITEM_H
    mov rdx, szEditClear
    mov ecx, 0x00222222
    mov r8d, 0x00F0F0F0
    call render_text

.note_draw_done:
    ; Show save-as dialog overlay
    cmp byte [np_save_dialog], 1
    jne .np_no_save_dialog

    ; Semi-transparent dark overlay background
    mov rdi, r12
    add rdi, BORDER_WIDTH + 20
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 40
    mov edx, r14d
    sub edx, BORDER_WIDTH * 2 + 40
    mov ecx, 80
    mov r8d, 0x00223344
    call render_rect

    ; Border
    mov rdi, r12
    add rdi, BORDER_WIDTH + 20
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 40
    mov edx, r14d
    sub edx, BORDER_WIDTH * 2 + 40
    mov ecx, 1
    mov r8d, 0x004488AA
    call render_rect

    ; "Save As" title
    mov rdi, r12
    add rdi, BORDER_WIDTH + 30
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 46
    mov rdx, szSaveAsTitle
    mov ecx, 0x00AADDFF
    mov r8d, 0x00223344
    call render_text

    ; "Filename:" label
    mov rdi, r12
    add rdi, BORDER_WIDTH + 30
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 66
    mov rdx, szSaveAsFilename
    mov ecx, 0x00CCCCCC
    mov r8d, 0x00223344
    call render_text

    ; Input field background (white box)
    mov rdi, r12
    add rdi, BORDER_WIDTH + 104
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 62
    mov edx, r14d
    sub edx, BORDER_WIDTH * 2 + 140
    mov ecx, 18
    mov r8d, 0x00FFFFFF
    call render_rect

    ; Input text
    mov rdi, r12
    add rdi, BORDER_WIDTH + 108
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 65
    lea rdx, [np_saveas_buf]
    mov ecx, 0x00000000
    mov r8d, 0x00FFFFFF
    call render_text

    ; Cursor in input field
    mov eax, [np_saveas_cursor]
    imul eax, FONT_WIDTH
    add eax, BORDER_WIDTH + 108
    mov edi, eax
    add edi, r12d
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 65
    mov rdx, szCursor
    mov ecx, 0x00000000
    mov r8d, 0x00FFFFFF
    call render_text

    ; "Enter=Save  Esc=Cancel" hint
    mov rdi, r12
    add rdi, BORDER_WIDTH + 30
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 86
    mov rdx, szSaveAsHint
    mov ecx, 0x00888888
    mov r8d, 0x00223344
    call render_text

.np_no_save_dialog:

    ; Show "Saved!" overlay if active
    cmp byte [np_save_done_msg], 1
    jne .note_draw_exit
    ; Dark overlay box centered in window
    mov rdi, r12
    mov eax, r14d
    sub eax, 120
    shr eax, 1
    add edi, eax          ; x = win_x + (win_w - 120)/2
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 60
    mov edx, 120
    mov ecx, 30
    mov r8d, 0x00228B22   ; dark green
    call render_rect
    ; "Saved!" text
    mov rdi, r12
    mov eax, r14d
    sub eax, 48           ; approx text width
    shr eax, 1
    add edi, eax
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 68
    mov rdx, szSavedMsg
    mov ecx, 0x00FFFFFF
    mov r8d, 0x00228B22
    call render_text

.note_draw_exit:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

; Click handler for notepad
app_notepad_click:
    push rax
    push rbx
    push rcx
    push rdx

    ; RSI=client_x, RDX=client_y

    ; Check if save-done message is showing - dismiss on any click
    cmp byte [np_save_done_msg], 1
    jne .np_no_dismiss_saved
    mov byte [np_save_done_msg], 0
    jmp .np_click_done
.np_no_dismiss_saved:

    ; Check if dropdown menu is open
    cmp byte [np_menu_open], 0
    jne .np_menu_click

    ; Check if clicking on menu bar (client_y < NP_EDIT_TOP)
    cmp rdx, NP_EDIT_TOP
    jge .np_text_click

    ; Menu bar click - check which menu
    cmp rsi, 48
    jl .np_click_file
    cmp rsi, 96
    jl .np_click_edit
    jmp .np_click_done

.np_click_file:
    mov byte [np_menu_open], 1
    jmp .np_click_done

.np_click_edit:
    mov byte [np_menu_open], 2
    jmp .np_click_done

.np_menu_click:
    ; Handle click on dropdown menu item
    cmp byte [np_menu_open], 1
    je .np_file_menu_click
    cmp byte [np_menu_open], 2
    je .np_edit_menu_click
    mov byte [np_menu_open], 0
    jmp .np_click_done

.np_file_menu_click:
    ; Check Y position
    mov eax, edx
    sub eax, NP_MENU_H
    cmp eax, 4
    jl .np_dismiss_menu
    sub eax, 4
    xor edx, edx
    mov ecx, CTX_ITEM_H
    div ecx
    cmp eax, 0
    je .np_file_new
    cmp eax, 1
    je .np_file_save
    cmp eax, 2
    je .np_file_close
    jmp .np_dismiss_menu

.np_file_new:
    ; Clear buffer
    mov byte [np_menu_open], 0
    lea rdi, [notepad_buf]
    xor eax, eax
    mov ecx, NP_BUF_SIZE
    rep stosb
    lea rdi, [np_line_len]
    xor eax, eax
    mov ecx, NP_MAX_LINES
    rep stosd
    mov dword [np_cursor_row], 0
    mov dword [np_cursor_col], 0
    mov dword [np_num_lines], 1
    mov dword [np_scroll_top], 0
    jmp .np_click_done

.np_file_save:
    mov byte [np_menu_open], 0
    ; If no file is open, show save dialog for filename input
    mov rax, [np_open_entry]
    test rax, rax
    jnz .np_do_save
    ; Show save-as dialog
    mov byte [np_save_dialog], 1
    mov dword [np_saveas_cursor], 0
    mov byte [np_saveas_buf], 0
    jmp .np_click_done

.np_do_save:
    push rsi
    push rdi
    push rcx
    push rdx
    push r8
    push r9

    ; Build flat file content from notepad lines into np_saved_content
    lea rdi, [np_saved_content]
    xor ecx, ecx             ; line index
    xor r8d, r8d             ; total bytes written
.save_build_loop:
    cmp ecx, [np_num_lines]
    jge .save_build_done

    ; Copy line content
    mov eax, ecx
    imul eax, NP_MAX_COLS
    lea rsi, [notepad_buf + rax]
    mov edx, [np_line_len + rcx * 4]
    test edx, edx
    jz .save_newline
    ; Copy edx bytes
    push rcx
    mov ecx, edx
    rep movsb
    pop rcx
    add r8d, edx

.save_newline:
    ; Add CR LF (unless last line)
    mov eax, ecx
    inc eax
    cmp eax, [np_num_lines]
    jge .save_next_line
    mov byte [rdi], 13
    inc rdi
    mov byte [rdi], 10
    inc rdi
    add r8d, 2

.save_next_line:
    inc ecx
    jmp .save_build_loop

.save_build_done:
    ; r8d = total bytes
    mov [np_save_total_bytes], r8d

    ; Write to FAT16 if we have an open file entry
    mov rax, [np_open_entry]
    test rax, rax
    jz .save_mem_only

    ; Get the 11-byte filename from the dir entry
    mov rdi, rax             ; 8.3 filename at entry+0
    lea rsi, [np_saved_content]
    mov edx, r8d
    call fat16_write_file

.save_mem_only:
    mov byte [np_has_saved], 1
    mov byte [np_save_done_msg], 1

    pop r9
    pop r8
    pop rdx
    pop rcx
    pop rdi
    pop rsi
    jmp .np_click_done

.np_file_close:
    mov byte [np_menu_open], 0
    ; Close window - we'd need the window ID. For now just clear.
    jmp .np_click_done

.np_edit_menu_click:
    mov eax, edx
    sub eax, NP_MENU_H
    cmp eax, 4
    jl .np_dismiss_menu
    sub eax, 4
    xor edx, edx
    mov ecx, CTX_ITEM_H
    div ecx
    cmp eax, 0
    je .np_edit_sel_all
    cmp eax, 1
    je .np_edit_clear
    jmp .np_dismiss_menu

.np_edit_sel_all:
    ; Just dismiss for now (no selection support yet)
    mov byte [np_menu_open], 0
    jmp .np_click_done

.np_edit_clear:
    mov byte [np_menu_open], 0
    ; Same as File > New
    lea rdi, [notepad_buf]
    xor eax, eax
    mov ecx, NP_BUF_SIZE
    rep stosb
    lea rdi, [np_line_len]
    xor eax, eax
    mov ecx, NP_MAX_LINES
    rep stosd
    mov dword [np_cursor_row], 0
    mov dword [np_cursor_col], 0
    mov dword [np_num_lines], 1
    mov dword [np_scroll_top], 0
    jmp .np_click_done

.np_dismiss_menu:
    mov byte [np_menu_open], 0
    jmp .np_click_done

.np_text_click:
    ; Close any open menu
    mov byte [np_menu_open], 0

    ; Calculate which line/col was clicked
    mov eax, edx
    sub eax, NP_EDIT_TOP + 2
    cmp eax, 0
    jl .np_click_done
    xor edx, edx
    mov ecx, 14
    div ecx
    ; eax = display line
    add eax, [np_scroll_top]
    ; Clamp to valid range
    cmp eax, [np_num_lines]
    jl .np_row_ok
    mov eax, [np_num_lines]
    dec eax
.np_row_ok:
    mov [np_cursor_row], eax

    ; Column from X
    mov eax, esi
    sub eax, 4
    cmp eax, 0
    jge .np_col_ok
    xor eax, eax
.np_col_ok:
    xor edx, edx
    mov ecx, FONT_WIDTH
    div ecx
    ; Clamp to line length
    mov ecx, [np_cursor_row]
    mov edx, [np_line_len + rcx * 4]
    cmp eax, edx
    jle .np_col_set
    mov eax, edx
.np_col_set:
    mov [np_cursor_col], eax

.np_click_done:
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; Key handler for notepad: supports arrows, Enter, Backspace, printable chars
app_notepad_key:
    push rax
    push rbx
    push rcx
    push rdx

    ; Check if save dialog is active - route keys there
    cmp byte [np_save_dialog], 1
    je .np_saveas_key

    ; Close menu on any key
    mov byte [np_menu_open], 0

    ; Extract scancode and ASCII
    mov eax, esi
    movzx ecx, al           ; scancode
    shr eax, 8
    and eax, 0xFF            ; ASCII
    mov edx, eax             ; edx = ASCII

    ; Check arrow keys (extended scancodes stored as 0x80|raw)
    cmp cl, 0xC8             ; Up
    je .np_arrow_up
    cmp cl, 0xD0             ; Down
    je .np_arrow_down
    cmp cl, 0xCB             ; Left
    je .np_arrow_left
    cmp cl, 0xCD             ; Right
    je .np_arrow_right

    ; ASCII-based checks
    test edx, edx
    jz .np_key_done

    cmp dl, 8                ; Backspace
    je .np_backspace
    cmp dl, 13               ; Enter
    je .np_enter
    cmp dl, 9                ; Tab -> insert spaces
    je .np_tab

    ; Printable character
    cmp dl, 32
    jl .np_key_done
    cmp dl, 126
    jg .np_key_done

    ; Insert char at cursor position
    mov eax, [np_cursor_row]
    mov ecx, [np_line_len + rax * 4]
    cmp ecx, NP_MAX_COLS - 1
    jge .np_key_done

    ; Shift chars right from cursor_col to end
    imul ebx, eax, NP_MAX_COLS
    lea rbx, [notepad_buf + rbx]
    mov eax, ecx              ; line length
    mov ecx, [np_cursor_col]
.np_shift_right:
    cmp eax, ecx
    jle .np_insert_char
    mov r8b, [rbx + rax - 1]
    mov [rbx + rax], r8b
    dec eax
    jmp .np_shift_right
.np_insert_char:
    mov [rbx + rcx], dl
    mov eax, [np_cursor_row]
    inc dword [np_line_len + rax * 4]
    ; Null terminate
    mov ecx, [np_line_len + rax * 4]
    mov byte [rbx + rcx], 0
    inc dword [np_cursor_col]
    jmp .np_key_done

.np_backspace:
    mov eax, [np_cursor_col]
    test eax, eax
    jnz .np_bs_inline

    ; At column 0: merge with previous line
    mov eax, [np_cursor_row]
    test eax, eax
    jz .np_key_done

    ; Merge current line onto end of previous line
    dec eax
    mov ecx, [np_line_len + rax * 4]  ; prev line len
    mov edx, ecx                       ; new cursor col
    push rdx

    ; Get pointers
    imul ebx, eax, NP_MAX_COLS
    lea rbx, [notepad_buf + rbx]       ; prev line
    mov r8d, eax
    inc r8d
    imul r8d, NP_MAX_COLS
    lea r8, [notepad_buf + r8]          ; current line

    ; Append current line content to prev line
    mov ecx, [np_cursor_row]
    mov r9d, [np_line_len + rcx * 4]   ; current line len
    ; Check if combined length fits
    mov r10d, [np_line_len + rax * 4]
    add r10d, r9d
    cmp r10d, NP_MAX_COLS - 1
    jge .np_bs_no_merge

    ; Copy current line to end of prev line
    xor ecx, ecx
.np_merge_copy:
    cmp ecx, r9d
    jge .np_merge_done
    mov dl, [r8 + rcx]
    mov [rbx + r10], dl
    inc r10d
    inc ecx
    jmp .np_merge_copy
    ; Actually let me redo this properly
.np_merge_done:
    ; prev line new length
    mov [np_line_len + rax * 4], r10d
    mov byte [rbx + r10], 0

    ; Shift all subsequent lines up by 1
    mov ecx, [np_cursor_row]
    mov edx, [np_num_lines]
.np_shift_lines_up:
    mov r8d, ecx
    inc r8d
    cmp r8d, edx
    jge .np_shift_up_done
    ; Copy line r8d to ecx
    push rcx
    push rdx
    imul r9d, r8d, NP_MAX_COLS
    lea r9, [notepad_buf + r9]
    imul ecx, ecx, NP_MAX_COLS
    lea rcx, [notepad_buf + rcx]
    xor eax, eax
.copy_line_up:
    mov dl, [r9 + rax]
    mov [rcx + rax], dl
    inc eax
    cmp eax, NP_MAX_COLS
    jl .copy_line_up
    pop rdx
    pop rcx
    ; Copy line length
    mov eax, [np_line_len + r8 * 4]
    mov [np_line_len + rcx * 4], eax
    inc ecx
    jmp .np_shift_lines_up
.np_shift_up_done:
    dec dword [np_num_lines]
    pop rdx
    dec dword [np_cursor_row]
    mov [np_cursor_col], edx
    jmp .np_ensure_visible

.np_bs_no_merge:
    pop rdx
    jmp .np_key_done

.np_bs_inline:
    ; Delete char before cursor
    mov eax, [np_cursor_row]
    imul ebx, eax, NP_MAX_COLS
    lea rbx, [notepad_buf + rbx]
    mov ecx, [np_cursor_col]
    ; Shift left from cursor_col to end
.np_shift_left:
    mov r8d, [np_line_len + rax * 4]
    cmp ecx, r8d
    jge .np_bs_done
    mov dl, [rbx + rcx]
    mov [rbx + rcx - 1], dl
    inc ecx
    jmp .np_shift_left
.np_bs_done:
    mov eax, [np_cursor_row]
    dec dword [np_line_len + rax * 4]
    mov ecx, [np_line_len + rax * 4]
    mov byte [rbx + rcx], 0
    dec dword [np_cursor_col]
    jmp .np_key_done

.np_enter:
    ; Insert new line at cursor position
    mov eax, [np_num_lines]
    cmp eax, NP_MAX_LINES - 1
    jge .np_key_done

    ; Shift all lines from cursor_row+1 down by 1
    mov ecx, [np_num_lines]
    dec ecx
.np_shift_down:
    mov edx, [np_cursor_row]
    cmp ecx, edx
    jle .np_shift_down_done
    ; Copy line ecx to ecx+1
    push rcx
    imul eax, ecx, NP_MAX_COLS
    lea rbx, [notepad_buf + rax]
    add eax, NP_MAX_COLS
    lea r8, [notepad_buf + rax]
    xor edx, edx
.copy_line_down:
    mov al, [rbx + rdx]
    mov [r8 + rdx], al
    inc edx
    cmp edx, NP_MAX_COLS
    jl .copy_line_down
    pop rcx
    ; Copy line length
    mov eax, [np_line_len + rcx * 4]
    mov [np_line_len + rcx * 4 + 4], eax
    dec ecx
    jmp .np_shift_down
.np_shift_down_done:

    ; Now split current line at cursor position
    mov eax, [np_cursor_row]
    imul ebx, eax, NP_MAX_COLS
    lea rbx, [notepad_buf + rbx]
    mov ecx, [np_cursor_col]
    mov edx, [np_line_len + rax * 4]

    ; New line gets chars from cursor_col to end
    mov r8d, eax
    inc r8d
    imul r9d, r8d, NP_MAX_COLS
    lea r9, [notepad_buf + r9]
    xor r10d, r10d
    mov eax, ecx
.np_split_copy:
    cmp eax, edx
    jge .np_split_done
    mov r11b, [rbx + rax]
    mov [r9 + r10], r11b
    inc eax
    inc r10d
    jmp .np_split_copy
.np_split_done:
    mov byte [r9 + r10], 0
    mov [np_line_len + r8 * 4], r10d

    ; Truncate current line at cursor
    mov byte [rbx + rcx], 0
    mov eax, [np_cursor_row]
    mov [np_line_len + rax * 4], ecx

    ; Move cursor to start of next line
    inc dword [np_num_lines]
    inc dword [np_cursor_row]
    mov dword [np_cursor_col], 0
    jmp .np_ensure_visible

.np_tab:
    ; Insert 4 spaces
    mov ecx, 4
.np_tab_loop:
    test ecx, ecx
    jz .np_key_done
    push rcx
    mov eax, [np_cursor_row]
    mov ecx, [np_line_len + rax * 4]
    cmp ecx, NP_MAX_COLS - 1
    jge .np_tab_skip
    imul ebx, eax, NP_MAX_COLS
    lea rbx, [notepad_buf + rbx]
    mov eax, ecx
    mov ecx, [np_cursor_col]
.np_tab_shift:
    cmp eax, ecx
    jle .np_tab_insert
    mov dl, [rbx + rax - 1]
    mov [rbx + rax], dl
    dec eax
    jmp .np_tab_shift
.np_tab_insert:
    mov byte [rbx + rcx], ' '
    mov eax, [np_cursor_row]
    inc dword [np_line_len + rax * 4]
    mov ecx, [np_line_len + rax * 4]
    mov byte [rbx + rcx], 0
    inc dword [np_cursor_col]
.np_tab_skip:
    pop rcx
    dec ecx
    jmp .np_tab_loop

.np_arrow_up:
    mov eax, [np_cursor_row]
    test eax, eax
    jz .np_key_done
    dec eax
    mov [np_cursor_row], eax
    ; Clamp col to new line length
    mov ecx, [np_line_len + rax * 4]
    cmp [np_cursor_col], ecx
    jle .np_ensure_visible
    mov [np_cursor_col], ecx
    jmp .np_ensure_visible

.np_arrow_down:
    mov eax, [np_cursor_row]
    inc eax
    cmp eax, [np_num_lines]
    jge .np_key_done
    mov [np_cursor_row], eax
    mov ecx, [np_line_len + rax * 4]
    cmp [np_cursor_col], ecx
    jle .np_ensure_visible
    mov [np_cursor_col], ecx
    jmp .np_ensure_visible

.np_arrow_left:
    mov eax, [np_cursor_col]
    test eax, eax
    jz .np_left_prev_line
    dec eax
    mov [np_cursor_col], eax
    jmp .np_key_done
.np_left_prev_line:
    mov eax, [np_cursor_row]
    test eax, eax
    jz .np_key_done
    dec eax
    mov [np_cursor_row], eax
    mov ecx, [np_line_len + rax * 4]
    mov [np_cursor_col], ecx
    jmp .np_ensure_visible

.np_arrow_right:
    mov eax, [np_cursor_row]
    mov ecx, [np_cursor_col]
    cmp ecx, [np_line_len + rax * 4]
    jl .np_right_same
    ; At end of line - move to next line
    inc eax
    cmp eax, [np_num_lines]
    jge .np_key_done
    mov [np_cursor_row], eax
    mov dword [np_cursor_col], 0
    jmp .np_ensure_visible
.np_right_same:
    inc dword [np_cursor_col]
    jmp .np_key_done

.np_ensure_visible:
    ; Auto-scroll to keep cursor visible
    mov eax, [np_cursor_row]
    cmp eax, [np_scroll_top]
    jge .np_scroll_check_bot
    mov [np_scroll_top], eax
    jmp .np_key_done
.np_scroll_check_bot:
    ; Rough: assume ~15 visible lines
    mov ecx, [np_scroll_top]
    add ecx, 15
    cmp eax, ecx
    jl .np_key_done
    sub eax, 14
    mov [np_scroll_top], eax

    jmp .np_key_done

; --- Save As dialog key handler ---
.np_saveas_key:
    mov eax, esi
    movzx ecx, al           ; scancode
    shr eax, 8
    and eax, 0xFF
    mov edx, eax             ; ASCII

    ; Escape cancels
    cmp cl, 0x01
    je .np_saveas_cancel

    ; Enter confirms save
    cmp dl, 13
    je .np_saveas_confirm

    ; Backspace
    cmp dl, 8
    je .np_saveas_bs

    ; Printable chars
    cmp dl, 32
    jl .np_key_done
    cmp dl, 126
    jg .np_key_done

    ; Add char if room (max 22 chars for filename)
    mov ecx, [np_saveas_cursor]
    cmp ecx, 22
    jge .np_key_done
    lea rax, [np_saveas_buf]
    mov [rax + rcx], dl
    inc ecx
    mov byte [rax + rcx], 0
    mov [np_saveas_cursor], ecx
    jmp .np_key_done

.np_saveas_bs:
    mov ecx, [np_saveas_cursor]
    test ecx, ecx
    jz .np_key_done
    dec ecx
    lea rax, [np_saveas_buf]
    mov byte [rax + rcx], 0
    mov [np_saveas_cursor], ecx
    jmp .np_key_done

.np_saveas_cancel:
    mov byte [np_save_dialog], 0
    jmp .np_key_done

.np_saveas_confirm:
    ; Confirm: save content with given filename
    mov byte [np_save_dialog], 0
    ; Check filename not empty
    cmp byte [np_saveas_buf], 0
    je .np_key_done

    ; Build content from notepad lines into np_saved_content
    push rsi
    push rdi
    push rcx
    push rdx
    push r8
    push r9

    lea rdi, [np_saved_content]
    xor ecx, ecx
    xor r8d, r8d
.saveas_build_loop:
    cmp ecx, [np_num_lines]
    jge .saveas_build_done
    mov eax, ecx
    imul eax, NP_MAX_COLS
    lea rsi, [notepad_buf + rax]
    mov edx, [np_line_len + rcx * 4]
    test edx, edx
    jz .saveas_newline
    push rcx
    mov ecx, edx
    rep movsb
    pop rcx
    add r8d, edx
.saveas_newline:
    mov eax, ecx
    inc eax
    cmp eax, [np_num_lines]
    jge .saveas_next_line
    mov byte [rdi], 13
    inc rdi
    mov byte [rdi], 10
    inc rdi
    add r8d, 2
.saveas_next_line:
    inc ecx
    jmp .saveas_build_loop
.saveas_build_done:
    mov [np_save_total_bytes], r8d

    ; Convert user filename to FAT16 8.3 format
    lea rdi, [np_saveas_buf]
    lea rsi, [np_saveas_83]
    call filename_to_83

    ; Write using 8.3 filename
    lea rdi, [np_saveas_83]
    lea rsi, [np_saved_content]
    mov edx, r8d
    call fat16_write_file

    mov byte [np_has_saved], 1
    mov byte [np_save_done_msg], 1

    pop r9
    pop r8
    pop rdx
    pop rcx
    pop rdi
    pop rsi
    jmp .np_key_done

.np_key_done:
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; ============================================================================
; SETTINGS APP
; System information display
; ============================================================================

