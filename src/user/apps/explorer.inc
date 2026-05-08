app_explorer_draw:
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

    ; --- Path bar ---
    mov rdi, r12
    add rdi, BORDER_WIDTH
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT
    mov rdx, r14
    sub rdx, BORDER_WIDTH * 2
    mov ecx, 20
    mov r8d, 0x00E0E0E0
    SYS_GUI_RECT rdi, rsi, rdx, rcx, r8

    ; Path text
    mov rdi, r12
    add rdi, BORDER_WIDTH + 4
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 3
    mov rdx, szPathRoot
    cmp word [fat16_cur_dir_cluster], 0
    jne .draw_subdir
    call .draw_path
    jmp .path_done
    
    ; If not root, also show " [Back]" button
.draw_subdir:
    mov rdx, szPathSub
    call .draw_path
    
    ; Draw [Back] button
    mov rdi, r12
    add rdi, r14
    sub rdi, 60
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 2
    mov rdx, 50
    mov rcx, 16
    mov r8d, 0x00A0A0A0
    SYS_GUI_RECT rdi, rsi, rdx, rcx, r8
    
    mov rdi, r12
    add rdi, r14
    sub rdi, 55
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 4
    mov rdx, szBackBtn
    mov ecx, 0x00000000
    mov r8d, 0x00A0A0A0
    SYS_GUI_TEXT rdi, rsi, rdx, rcx, r8
    jmp .path_done

.draw_path:
    mov ecx, 0x00333333
    mov r8d, 0x00E0E0E0
    SYS_GUI_TEXT rdi, rsi, rdx, rcx, r8
    ret

.path_done:

    ; --- Column headers ---
    mov rdi, r12
    add rdi, BORDER_WIDTH
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 22
    mov rdx, r14
    sub rdx, BORDER_WIDTH * 2
    mov ecx, 18
    mov r8, 0x00D0D0E0
    SYS_GUI_RECT rdi, rsi, rdx, rcx, r8

    mov rdi, r12
    add rdi, BORDER_WIDTH + 4
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 23
    mov rdx, szColName
    mov ecx, 0x00333333
    mov r8, 0x00D0D0E0
    SYS_GUI_TEXT rdi, rsi, rdx, rcx, r8

    mov rdi, r12
    add rdi, r14
    sub rdi, 100
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 23
    mov rdx, szColSize
    mov ecx, 0x00333333
    mov r8d, 0x00D0D0E0
    SYS_GUI_TEXT rdi, rsi, rdx, rcx, r8

    SYS_FS_COUNT
    mov r8, rax            ; total files
    xor edx, edx            ; current file index

.entry_loop:
    cmp edx, r8d
    jae .entries_done            ; unsigned: indices/counts are non-negative
    ; Max 20 entries visible
    cmp edx, 20
    jae .entries_done

    push rdx
    push r8

    ; Highlight selected row
    mov eax, [explorer_sel]
    cmp eax, edx
    jne .no_highlight

    push rdx
    mov rdi, r12
    add rdi, BORDER_WIDTH
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 42
    movzx eax, dl
    imul eax, 18
    add rsi, rax
    mov rdx, r14
    sub rdx, BORDER_WIDTH * 2
    mov ecx, 18
    mov r8, COLOR_HIGHLIGHT
    SYS_GUI_RECT rdi, rsi, rdx, rcx, r8
    pop rdx

.no_highlight:
    push rdx
    mov rdi, rdx
    SYS_FS_ENTRY rdi
    mov r9, rax              ; r9 = dir entry pointer
    pop rdx
    test r9, r9
    jz .entry_size_done

    ; Convert 8.3 name to display name in fat16_name_buf
    push rdx
    mov rdi, fat16_name_buf
    mov rsi, r9
    call fat16_format_name
    pop rdx

    ; Entry name text - edx = file index here
    ; Save r9 (dir entry ptr) for later
    mov [explorer_cur_entry], r9
    mov [explorer_cur_idx], edx

    mov rdi, r12
    add rdi, BORDER_WIDTH + 8
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 43
    imul eax, edx, 18
    add rsi, rax
    mov rdx, fat16_name_buf

    ; Color: directories=gold, files=black
    mov cl, [r9 + 11]
    test cl, 0x10
    jz .file_icon
    mov ecx, 0x00CC8800
    jmp .draw_entry_name
.file_icon:
    mov ecx, 0x00333333
.draw_entry_name:
    mov r8d, COLOR_WINDOW_BG
    mov eax, [explorer_cur_idx]
    cmp eax, [explorer_sel]
    jne .entry_no_hl_text
    mov r8d, COLOR_HIGHLIGHT
    mov ecx, COLOR_TEXT_WHITE
.entry_no_hl_text:
    SYS_GUI_TEXT rdi, rsi, rdx, rcx, r8
    mov edx, [explorer_cur_idx]
    mov r9, [explorer_cur_entry]

    ; Entry size text
    mov cl, [r9 + 11]
    test cl, 0x10
    jnz .dir_size

    ; Convert file size to string
    push rdx
    mov edi, [r9 + 28]      ; file size (32-bit)
    mov rsi, fat16_size_buf
    call app_format_bytes_size
    pop rdx

    mov rdi, r12
    add rdi, r14
    sub rdi, 80
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 43
    movzx eax, dl
    imul eax, 18
    add rsi, rax
    mov rdx, fat16_size_buf
    mov ecx, 0x00666666
    mov r8d, COLOR_WINDOW_BG
    SYS_GUI_TEXT rdi, rsi, rdx, rcx, r8
    jmp .entry_size_done

.dir_size:
    mov rdi, r12
    add rdi, r14
    sub rdi, 80
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 43
    movzx eax, dl
    imul eax, 18
    add rsi, rax
    mov rdx, szDirLabel
    mov ecx, 0x00999999
    mov r8d, COLOR_WINDOW_BG
    SYS_GUI_TEXT rdi, rsi, rdx, rcx, r8

.entry_size_done:
    pop r8
    pop rdx
    inc rdx
    jmp .entry_loop

.entries_done:
    ; (Registers will be popped at the very end of app_explorer_draw)

    ; Status bar at bottom
    mov rdi, r12
    add rdi, BORDER_WIDTH
    mov rsi, r13
    add rsi, r15
    sub rsi, BORDER_WIDTH + 18
    mov rdx, r14
    sub rdx, BORDER_WIDTH * 2
    mov ecx, 18
    mov r8d, 0x00E8E8E8
    SYS_GUI_RECT rdi, rsi, rdx, rcx, r8

    mov rdi, r12
    add rdi, BORDER_WIDTH + 4
    mov rsi, r13
    add rsi, r15
    sub rsi, BORDER_WIDTH + 17
    mov rdx, szStatusReady
    mov ecx, 0x00666666
    mov r8d, 0x00E8E8E8
    SYS_GUI_TEXT rdi, rsi, rdx, rcx, r8

    ; --- Rename overlay (inline input at bottom) ---
    cmp byte [exp_rename_active], 0
    je .no_rename_overlay

    ; Dark overlay bar at bottom of file list
    mov rdi, r12
    add rdi, BORDER_WIDTH
    mov rsi, r13
    add rsi, r15
    sub rsi, BORDER_WIDTH + 40
    mov rdx, r14
    sub rdx, BORDER_WIDTH * 2
    mov ecx, 22
    mov r8d, 0x00334455
    SYS_GUI_RECT rdi, rsi, rdx, rcx, r8

    ; "Rename:" label
    mov rdi, r12
    add rdi, BORDER_WIDTH + 4
    mov rsi, r13
    add rsi, r15
    sub rsi, BORDER_WIDTH + 38
    mov rdx, szRenameLabel
    mov ecx, 0x00AACCFF
    mov r8d, 0x00334455
    SYS_GUI_TEXT rdi, rsi, rdx, rcx, r8

    ; Rename text input value
    mov rdi, r12
    add rdi, BORDER_WIDTH + 64
    mov rsi, r13
    add rsi, r15
    sub rsi, BORDER_WIDTH + 38
    lea rdx, [exp_rename_buf]
    mov ecx, COLOR_TEXT_WHITE
    mov r8d, 0x00334455
    SYS_GUI_TEXT rdi, rsi, rdx, rcx, r8

    ; Blinking cursor after text
    mov eax, [exp_rename_cursor]
    imul eax, FONT_WIDTH
    add eax, BORDER_WIDTH + 64
    mov edi, eax
    add edi, r12d
    mov rsi, r13
    add rsi, r15
    sub rsi, BORDER_WIDTH + 38
    mov rdx, szCursor
    mov ecx, COLOR_TEXT_WHITE
    mov r8d, 0x00334455
    SYS_GUI_TEXT rdi, rsi, rdx, rcx, r8

.no_rename_overlay:

    ; --- New Folder overlay (inline input at bottom) ---
    cmp byte [exp_newfolder_active], 0
    je .no_newfolder_overlay

    ; Dark overlay bar
    mov rdi, r12
    add rdi, BORDER_WIDTH
    mov rsi, r13
    add rsi, r15
    sub rsi, BORDER_WIDTH + 40
    mov rdx, r14
    sub rdx, BORDER_WIDTH * 2
    mov ecx, 22
    mov r8d, 0x00443355
    SYS_GUI_RECT rdi, rsi, rdx, rcx, r8

    ; "New Folder:" label
    mov rdi, r12
    add rdi, BORDER_WIDTH + 4
    mov rsi, r13
    add rsi, r15
    sub rsi, BORDER_WIDTH + 38
    mov rdx, szNewFolderLabel
    mov ecx, 0x00FFAACC
    mov r8d, 0x00443355
    SYS_GUI_TEXT rdi, rsi, rdx, rcx, r8

    ; Folder name input value
    mov rdi, r12
    add rdi, BORDER_WIDTH + 96
    mov rsi, r13
    add rsi, r15
    sub rsi, BORDER_WIDTH + 38
    lea rdx, [exp_newfolder_buf]
    mov ecx, COLOR_TEXT_WHITE
    mov r8d, 0x00443355
    SYS_GUI_TEXT rdi, rsi, rdx, rcx, r8

    ; Cursor
    mov eax, [exp_newfolder_cursor]
    imul eax, FONT_WIDTH
    add eax, BORDER_WIDTH + 96
    mov edi, eax
    add edi, r12d
    mov rsi, r13
    add rsi, r15
    sub rsi, BORDER_WIDTH + 38
    mov rdx, szCursor
    mov ecx, COLOR_TEXT_WHITE
    mov r8d, 0x00443355
    SYS_GUI_TEXT rdi, rsi, rdx, rcx, r8

.no_newfolder_overlay:

    ; --- "Folder Created!" message overlay ---
    cmp byte [exp_newfolder_done_msg], 0
    je .no_newfolder_msg

    mov rdi, r12
    mov eax, r14d
    sub eax, 140
    shr eax, 1
    add edi, eax
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 60
    mov edx, 140
    mov ecx, 30
    mov r8d, 0x00228B22
    SYS_GUI_RECT rdi, rsi, rdx, rcx, r8

    mov rdi, r12
    mov eax, r14d
    sub eax, 110
    shr eax, 1
    add edi, eax
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 68
    mov rdx, szNewFolderDone
    mov ecx, COLOR_TEXT_WHITE
    mov r8d, 0x00228B22
    SYS_GUI_TEXT rdi, rsi, rdx, rcx, r8
    jmp .no_newfolder_msg

.no_newfolder_msg:
    ; Continue to context menu

    ; --- Context menu overlay ---
    cmp byte [ctx_menu_visible], 0
    je .no_ctx_menu

    ; Draw context menu background (4 items: Open, Rename, New Folder, Properties)
    mov edi, [ctx_menu_x]
    mov esi, [ctx_menu_y]
    mov edx, CTX_WIDTH
    mov ecx, CTX_ITEM_H * 4 + 4
    mov r8d, 0x00F0F0F0
    SYS_GUI_RECT rdi, rsi, rdx, rcx, r8

    ; Border
    mov edi, [ctx_menu_x]
    mov esi, [ctx_menu_y]
    mov edx, CTX_WIDTH
    mov ecx, 1
    mov r8d, 0x00999999
    SYS_GUI_RECT rdi, rsi, rdx, rcx, r8

    ; Item 0: Open
    mov edi, [ctx_menu_x]
    add edi, 8
    mov esi, [ctx_menu_y]
    add esi, 4
    mov rdx, szCtxOpen
    mov ecx, 0x00222222
    mov r8d, 0x00F0F0F0
    SYS_GUI_TEXT rdi, rsi, rdx, rcx, r8

    ; Item 1: Rename
    mov edi, [ctx_menu_x]
    add edi, 8
    mov esi, [ctx_menu_y]
    add esi, 4 + CTX_ITEM_H
    mov rdx, szCtxRename
    mov ecx, 0x00222222
    mov r8d, 0x00F0F0F0
    SYS_GUI_TEXT rdi, rsi, rdx, rcx, r8

    ; Item 2: New Folder
    mov edi, [ctx_menu_x]
    add edi, 8
    mov esi, [ctx_menu_y]
    add esi, 4 + CTX_ITEM_H * 2
    mov rdx, szCtxNewFolder
    mov ecx, 0x00222222
    mov r8d, 0x00F0F0F0
    SYS_GUI_TEXT rdi, rsi, rdx, rcx, r8

    ; Item 3: Properties
    mov edi, [ctx_menu_x]
    add edi, 8
    mov esi, [ctx_menu_y]
    add esi, 4 + CTX_ITEM_H * 3
    mov rdx, szCtxProperties
    mov ecx, 0x00666666
    mov r8d, 0x00F0F0F0
    SYS_GUI_TEXT rdi, rsi, rdx, rcx, r8

.no_ctx_menu:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

; Click callback: RDI=window_ptr, RSI=client_x, RDX=client_y
app_explorer_click:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r15
    push rbp        ; 8 pushes = 64 bytes (16-byte aligned)

    ; Dismiss "Folder Created!" message on click
    cmp byte [exp_newfolder_done_msg], 0
    je .exp_no_nf_dismiss
    mov byte [exp_newfolder_done_msg], 0
    jmp .exp_click_ret
.exp_no_nf_dismiss:

    ; Cancel rename/newfolder mode on click outside
    cmp byte [exp_rename_active], 0
    je .exp_no_rename_dismiss
    mov byte [exp_rename_active], 0
.exp_no_rename_dismiss:
    cmp byte [exp_newfolder_active], 0
    je .exp_no_nf_dismiss2
    mov byte [exp_newfolder_active], 0
.exp_no_nf_dismiss2:

    ; Check if context menu is open - handle menu click
    cmp byte [ctx_menu_visible], 0
    je .exp_no_ctx_click

    ; Check if click is inside context menu
    ; ctx_menu_x/y are screen coords; rsi/rdx are client coords
    ; Convert client to screen: add window X/Y + border + titlebar
    mov rax, [rdi + WIN_OFF_X]
    add rax, BORDER_WIDTH
    add rsi, rax
    mov rax, [rdi + WIN_OFF_Y]
    add rax, TITLEBAR_HEIGHT
    add rdx, rax

    mov eax, [ctx_menu_x]
    cmp esi, eax
    jl .ctx_dismiss
    add eax, CTX_WIDTH
    cmp esi, eax
    jge .ctx_dismiss
    mov eax, [ctx_menu_y]
    cmp edx, eax
    jl .ctx_dismiss
    mov ecx, eax
    add ecx, CTX_ITEM_H * 4 + 4
    cmp edx, ecx
    jge .ctx_dismiss

    ; Which item clicked?
    sub edx, [ctx_menu_y]
    sub edx, 4
    mov eax, edx
    xor edx, edx
    mov ecx, CTX_ITEM_H
    div ecx
    ; eax = item index (0=Open, 1=Rename, 2=New Folder, 3=Properties)
    cmp eax, 0
    je .ctx_open
    cmp eax, 1
    je .ctx_rename
    cmp eax, 2
    je .ctx_new_folder
    cmp eax, 3
    je .ctx_properties
    jmp .ctx_dismiss

.ctx_open:
    ; Open selected file in notepad
    mov byte [ctx_menu_visible], 0
    mov edi, [explorer_sel]
    SYS_FS_ENTRY rdi
    test rax, rax
    jz .ctx_dismiss
    ; Check it's a file (not dir)
    mov cl, [rax + 11]
    test cl, 0x10
    jnz .ctx_dismiss
    mov rdi, rax
    mov rsi, rbx
    call app_open_file
    jmp .exp_click_ret

.ctx_rename:
    ; Enter rename mode - copy current name into rename buffer
    mov byte [ctx_menu_visible], 0
    mov byte [exp_rename_active], 1
    mov dword [exp_rename_cursor], 0
    ; Get current entry name
    mov edi, [explorer_sel]
    SYS_FS_ENTRY rdi
    test rax, rax
    jz .ctx_dismiss
    ; Copy name into rename buffer (up to 23 chars from VFS 24-byte name)
    push rsi
    push rdi
    push rcx
    mov rsi, rax
    lea rdi, [exp_rename_buf]
    xor ecx, ecx
.ctx_rename_copy:
    cmp ecx, 23
    jge .ctx_rename_copy_done
    mov al, [rsi + rcx]
    test al, al
    jz .ctx_rename_copy_done
    mov [rdi + rcx], al
    inc ecx
    jmp .ctx_rename_copy
.ctx_rename_copy_done:
    mov byte [rdi + rcx], 0
    mov [exp_rename_cursor], ecx
    pop rcx
    pop rdi
    pop rsi
    jmp .exp_click_ret

.ctx_new_folder:
    ; Enter new folder mode - show input for folder name
    mov byte [ctx_menu_visible], 0
    mov byte [exp_newfolder_active], 1
    mov dword [exp_newfolder_cursor], 0
    ; Clear the buffer
    lea rdi, [exp_newfolder_buf]
    mov byte [rdi], 0
    jmp .exp_click_ret

.ctx_properties:
    mov byte [ctx_menu_visible], 0
    mov edi, [explorer_sel]
    SYS_FS_ENTRY rdi
    test rax, rax
    jz .ctx_dismiss
    mov [prop_entry_ptr], rax
    ; Open a Properties window
    lea rdi, [rel szPropTitle]
    mov rsi, 250
    mov rdx, 200
    mov r10, 240
    mov r8, 160
    lea r9, [rel app_properties_draw]
    SYS_WM_CREATE rdi, rsi, rdx, r10, r8, r9
    jmp .exp_click_ret

.ctx_dismiss:
    mov byte [ctx_menu_visible], 0
    jmp .exp_click_ret

.exp_no_ctx_click:
    ; Restore original rsi/rdx (client coords)
    mov rsi, [rsp + 8]     ; original rsi
    mov rdx, [rsp + 16]    ; original rdx

    ; Check if right button - show context menu
    ; We don't have right-button info here directly...
    ; Context menu is triggered by explorer_key or by the main event loop

    ; client_y relative to client area top
    ; Check if Back button clicked (X > width - 60, Y < 20)
    cmp rdx, 20
    jge .exp_not_back
    mov rax, [rdi + WIN_OFF_W]
    sub rax, 60
    cmp rsi, rax
    jge .exp_back_click
.exp_not_back:

    cmp rdx, 42
    jl .exp_click_ret

    ; Calculate entry index
    sub rdx, 42
    mov rax, rdx
    xor edx, edx
    mov rcx, 18
    div rcx

    ; Check against FAT16 file count
    push rax
    SYS_FS_COUNT
    mov ecx, eax
    pop rax
    cmp eax, ecx
    jge .exp_click_ret
    jmp .exp_select

.exp_back_click:
    xor di, di
    SYS_FS_CHDIR rdi
    mov dword [explorer_sel], 0
    jmp .exp_click_ret

.exp_select:
    ; Check if same item (double-click = open)
    cmp eax, [explorer_sel]
    jne .exp_first_click

    ; Double-click: open file
    push rax
    mov edi, eax
    SYS_FS_ENTRY rdi
    test rax, rax
    jz .dblclick_done
    ; Check if directory
    mov cl, [rax + 11]
    test cl, 0x10
    jnz .dblclick_done
    ; Open file in notepad
    mov rdi, rax
    mov rsi, rbx
    call app_open_file
.dblclick_done:
    pop rax
    jmp .exp_click_ret

.exp_first_click:
    mov [explorer_sel], eax

.exp_click_ret:
    pop rbp
    pop r15
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; Key handler for explorer (arrow navigation + Enter to open + right-click menu key)
app_explorer_key:
    push rax
    push rbx
    push rcx
    push rdx
    push rbp        ; Align stack

    ; Check if rename mode is active
    cmp byte [exp_rename_active], 1
    je .exp_rename_key
    ; Check if new folder mode is active
    cmp byte [exp_newfolder_active], 1
    je .exp_newfolder_key

    mov eax, esi
    ; Extract scancode (lowest byte)
    movzx ecx, al           ; scancode

    ; Check for extended arrow keys
    cmp cl, 0xC8            ; Up arrow (E0 48 -> stored as 0xC8)
    je .exp_key_up
    cmp cl, 0xD0            ; Down arrow
    je .exp_key_down
    cmp cl, 0x1C            ; Enter scancode
    je .exp_key_enter

    ; Check ASCII
    mov eax, esi
    shr eax, 8
    and eax, 0xFF
    cmp al, 13              ; Enter ASCII
    je .exp_key_enter

    jmp .exp_key_done

; --- Rename input key handler ---
.exp_rename_key:
    mov eax, esi
    movzx ecx, al           ; scancode
    shr eax, 8
    and eax, 0xFF            ; ASCII
    mov edx, eax

    ; Escape cancels
    cmp cl, 0x01
    je .exp_rename_cancel

    ; Enter confirms rename
    cmp dl, 13
    je .exp_rename_confirm

    ; Backspace
    cmp dl, 8
    je .exp_rename_bs

    ; Printable chars
    cmp dl, 32
    jl .exp_key_done
    cmp dl, 126
    jg .exp_key_done

    ; Add char if room
    mov ecx, [exp_rename_cursor]
    cmp ecx, 22
    jge .exp_key_done
    lea rax, [exp_rename_buf]
    mov [rax + rcx], dl
    inc ecx
    mov byte [rax + rcx], 0
    mov [exp_rename_cursor], ecx
    jmp .exp_key_done

.exp_rename_bs:
    mov ecx, [exp_rename_cursor]
    test ecx, ecx
    jz .exp_key_done
    dec ecx
    lea rax, [exp_rename_buf]
    mov byte [rax + rcx], 0
    mov [exp_rename_cursor], ecx
    jmp .exp_key_done

.exp_rename_cancel:
    mov byte [exp_rename_active], 0
    jmp .exp_key_done

.exp_rename_confirm:
    ; Apply rename through the filesystem syscall so the current FAT16 cache and
    ; disk state are updated together.
    mov byte [exp_rename_active], 0
    mov edi, [explorer_sel]
    SYS_FS_ENTRY rdi
    test rax, rax
    jz .exp_key_done
    push rax
    lea rdi, [exp_rename_buf]
    lea rsi, [fat16_name_buf]
    call filename_to_83
    pop rdi
    lea rsi, [fat16_name_buf]
    SYS_FS_RENAME rdi, rsi
    jmp .exp_key_done

; --- New Folder input key handler ---
.exp_newfolder_key:
    mov eax, esi
    movzx ecx, al           ; scancode
    shr eax, 8
    and eax, 0xFF
    mov edx, eax

    ; Escape cancels
    cmp cl, 0x01
    je .exp_newfolder_cancel

    ; Enter confirms
    cmp dl, 13
    je .exp_newfolder_confirm

    ; Backspace
    cmp dl, 8
    je .exp_newfolder_bs

    ; Printable chars
    cmp dl, 32
    jl .exp_key_done
    cmp dl, 126
    jg .exp_key_done

    ; Add char
    mov ecx, [exp_newfolder_cursor]
    cmp ecx, 22
    jge .exp_key_done
    lea rax, [exp_newfolder_buf]
    mov [rax + rcx], dl
    inc ecx
    mov byte [rax + rcx], 0
    mov [exp_newfolder_cursor], ecx
    jmp .exp_key_done

.exp_newfolder_bs:
    mov ecx, [exp_newfolder_cursor]
    test ecx, ecx
    jz .exp_key_done
    dec ecx
    lea rax, [exp_newfolder_buf]
    mov byte [rax + rcx], 0
    mov [exp_newfolder_cursor], ecx
    jmp .exp_key_done

.exp_newfolder_cancel:
    mov byte [exp_newfolder_active], 0
    jmp .exp_key_done

.exp_newfolder_confirm:
    ; Create a real FAT16 directory in the current directory listing.
    mov byte [exp_newfolder_active], 0
    ; Check name is not empty
    cmp byte [exp_newfolder_buf], 0
    je .exp_key_done
    lea rdi, [exp_newfolder_buf]
    lea rsi, [fat16_name_buf]
    call filename_to_83
    lea rdi, [fat16_name_buf]
    SYS_FS_MKDIR rdi
    cmp eax, -1
    je .exp_key_done
    mov byte [exp_newfolder_done_msg], 1
    jmp .exp_key_done

.exp_key_up:
    mov eax, [explorer_sel]
    test eax, eax
    jz .exp_key_done
    dec eax
    mov [explorer_sel], eax
    jmp .exp_key_done

.exp_key_down:
    mov eax, [explorer_sel]
    inc eax
    ; Check against FAT16 file count
    push rax
    SYS_FS_COUNT
    mov ecx, eax
    pop rax
    cmp eax, ecx
    jge .exp_key_done
    mov [explorer_sel], eax
    jmp .exp_key_done

.exp_key_enter:
    ; Open selected file
    mov eax, [explorer_sel]
    mov edi, eax
    call fat16_get_entry
    test rax, rax
    jz .eke_done
    ; Check if directory
    mov cl, [rax + 11]
    test cl, 0x10
    jz .eke_file

    ; Enter directory
    ; Cluster is at +26 (low word)
    movzx eax, word [rax + 26]
    call fat16_change_dir
    ; Reset selection
    mov dword [explorer_sel], 0
    jmp .eke_done

.eke_file:
    mov rdi, rax
    mov rsi, rbx
    call app_open_file
.eke_done:
    jmp .exp_key_done

.exp_key_done:
    pop rbp
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; ============================================================================
; TERMINAL APP - Command Handlers & FS Helpers
; ============================================================================

; Helper: Find a directory by name in current view and return cluster
; RSI = name to find. Returns AX = cluster or 0xFFFF
term_find_dir_cluster:
    push rbx
    push rcx
    push rdx
    push rsi
    push r12
    push r13
    push r14
    push r15
    mov r12, rsi ; target name
    
    SYS_FS_COUNT
    mov r13d, eax
    xor r14d, r14d ; index
    
.fdir_loop:
    cmp r14d, r13d
    jge .fdir_fail
    
    mov edi, r14d
    call fat16_get_entry
    test rax, rax
    jz .fdir_next
    
    mov r15, rax ; entry pointer
    
    ; Format name for comparison
    mov rdi, fat16_name_buf
    mov rsi, r15
    call fat16_format_name
    
    ; Compare fat16_name_buf with r12
    mov rsi, fat16_name_buf
    mov rdi, r12
    call term_strcmp_nc ; case insensitive
    test eax, eax
    jnz .fdir_match
    jmp .fdir_next

.fdir_match:
    ; Match! Check if directory
    mov al, [r15 + 11]
    test al, 0x10
    jz .fdir_next
    
    ; It's a directory! return cluster
    movzx eax, word [r15 + 26]
    jmp .fdir_done

.fdir_next:
    inc r14d
    jmp .fdir_loop

.fdir_fail:
    mov ax, 0xFFFF
.fdir_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

; Case-insensitive strcmp for terminal
term_strcmp_nc:
    push rsi
    push rdi
.snc_loop:
    mov al, [rsi]
    mov bl, [rdi]
    test al, al
    jnz .snc_not_end
    test bl, bl
    jnz .snc_fail
    mov eax, 1
    jmp .snc_done
.snc_not_end:
    ; toupper al
    cmp al, 'a'
    jl .snc_up_bl
    cmp al, 'z'
    jg .snc_up_bl
    sub al, 32
.snc_up_bl:
    ; toupper bl
    cmp bl, 'a'
    jl .snc_cmp
    cmp bl, 'z'
    jg .snc_cmp
    sub bl, 32
.snc_cmp:
    cmp al, bl
    jne .snc_fail
    inc rsi
    inc rdi
    jmp .snc_loop
.snc_fail:
    xor eax, eax
.snc_done:
    pop rdi
    pop rsi
    ret

; Helper: Build a string of all files in current directory
term_build_ls_string:
    push rdi
    push rsi
    push rbx
    push rcx
    push r12
    push r13
    
    lea rdi, [term_ls_buf]
    mov byte [rdi], 0
    
    SYS_FS_COUNT
    test eax, eax
    jz .ls_empty
    
    mov r12d, eax ; count
    xor r13d, r13d ; index
    
.ls_loop:
    cmp r13d, r12d
    jge .ls_done
    
    push rdi
    mov edi, r13d
    call fat16_get_entry
    pop rdi
    test rax, rax
    jz .ls_next
    
    ; Format name into fat16_name_buf
    push rdi
    mov rsi, rax
    mov rdi, fat16_name_buf
    call fat16_format_name
    pop rdi
    
    ; Copy from fat16_name_buf to rdi
    push rsi
    lea rsi, [fat16_name_buf]
.ls_cp:
    lodsb
    test al, al
    jz .ls_cp_done
    stosb
    jmp .ls_cp
.ls_cp_done:
    ; Add spaces
    mov al, ' '
    stosb
    stosb
    pop rsi
    
.ls_next:
    inc r13d
    jmp .ls_loop

.ls_empty:
    lea rsi, [szEmptyDir]
.ls_copy_empty:
    lodsb
    stosb
    test al, al
    jnz .ls_copy_empty

.ls_done:
    mov byte [rdi], 0
    pop r13
    pop r12
    pop rcx
    pop rbx
    pop rsi
    pop rdi
    ret


; ============================================================================
; TERMINAL APP
; Command prompt with scrollable output history
; This block is copied into the per-slot L3 arena before callbacks run.
; ============================================================================
