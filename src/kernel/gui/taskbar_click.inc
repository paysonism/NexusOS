
; Handle click on taskbar / start menu
; RDI = Mouse X, RSI = Mouse Y
; Returns: RAX = 0 (not handled), 1 (handled, no app), or 2..6 (menu item 0..4 clicked)
FN_BEGIN tb_handle_click, 0, 0, FN_RET_SCALAR
    push rbx
    push r12
    push r13

    ; Check if start menu is open and click is inside it
    cmp byte [tb_start_menu_open], 0
    je .check_taskbar

    ; Check bounds of start menu
    cmp rdi, START_MENU_X
    jl .close_menu
    cmp rdi, START_MENU_X + START_MENU_W
    jg .close_menu
    movsxd rax, dword [scr_start_menu_y]
    cmp rsi, rax
    jl .close_menu
    movsxd rax, dword [scr_taskbar_y]
    cmp rsi, rax
    jge .check_taskbar

    ; Click inside menu - determine which item
    mov rax, rsi
    movsxd rcx, dword [scr_start_menu_y]
    sub rax, rcx
    sub rax, 8
    cmp rax, 0
    jl .close_menu
    xor rdx, rdx
    mov rcx, MENU_ITEM_H
    div rcx

    ; Validate range
    cmp rax, MENU_ITEM_COUNT
    jge .close_menu

    ; Close menu and return the app id for this menu row.
    mov byte [tb_start_menu_open], 0
    mov rcx, MENU_ENTRY_SIZE
    mul rcx                       ; rax = row * MENU_ENTRY_SIZE
    lea rcx, [rel menu_entries]
    movzx rax, byte [rcx + rax + MENU_OFF_APP]
    jmp .tb_click_ret

.close_menu:
    mov byte [tb_start_menu_open], 0
    mov rax, 1
    jmp .tb_click_ret

.check_taskbar:
    ; Check if within taskbar Y range
    movsxd rax, dword [scr_taskbar_y]
    cmp rsi, rax
    jl .not_handled

    ; Check Start Button
    cmp rdi, START_BTN_X
    jl .check_tb_windows
    cmp rdi, START_BTN_X + START_BTN_W
    jg .check_tb_windows

    ; Clicked start button - toggle menu
    xor byte [tb_start_menu_open], 1
    mov rax, 1
    jmp .tb_click_ret

.check_tb_windows:
    ; Close menu
    mov byte [tb_start_menu_open], 0

    ; Check if click is on one of the window buttons
    ; Iterate active windows and check X ranges
    mov rbx, WINDOW_POOL_ADDR
    xor r12d, r12d               ; slot index
    mov r13d, TB_BTN_START_X     ; current button X

.tb_click_loop:
    cmp r12d, MAX_WINDOWS
    jge .tb_click_none

    test qword [rbx + WIN_OFF_FLAGS], WF_ACTIVE
    jz .tb_click_next

    ; Check if click X is within this button
    cmp edi, r13d
    jl .tb_click_next_active
    mov eax, r13d
    add eax, TB_BTN_W
    cmp edi, eax
    jge .tb_click_next_active

    ; Click Y must be within button height
    cmp esi, [scr_tb_btn_y]
    jl .tb_click_next_active
    mov eax, [scr_tb_btn_y]
    add eax, TB_BTN_H
    cmp esi, eax
    jge .tb_click_next_active

    ; Click is on this button. Check if on the X close area
    mov eax, r13d
    add eax, TB_CLOSE_OFF_X
    cmp edi, eax
    jl .tb_btn_activate
    ; Click is on X button - close this window
    push rdi
    push rsi
    mov rdi, r12               ; window ID
    call wm_close_window
    pop rsi
    pop rdi
    mov rax, 1
    jmp .tb_click_ret

.tb_btn_activate:
    ; Click on window name area - restore and focus
    ; If minimized, un-minimize
    test qword [rbx + WIN_OFF_FLAGS], WF_MINIMIZED
    jz .tb_btn_focus
    and qword [rbx + WIN_OFF_FLAGS], ~WF_MINIMIZED
    or qword [rbx + WIN_OFF_FLAGS], WF_VISIBLE

.tb_btn_focus:
    ; Unfocus all windows, then focus this one
    mov rcx, WINDOW_POOL_ADDR
    xor edx, edx
.tb_unfocus_loop:
    cmp edx, MAX_WINDOWS
    je .tb_unfocus_done
    and qword [rcx + WIN_OFF_FLAGS], ~WF_FOCUSED
    add rcx, WINDOW_STRUCT_SIZE
    inc edx
    jmp .tb_unfocus_loop
.tb_unfocus_done:
    or qword [rbx + WIN_OFF_FLAGS], WF_FOCUSED
    mov [wm_focused_window], r12
    mov rax, 1
    jmp .tb_click_ret

.tb_click_next_active:
    add r13d, TB_BTN_W + TB_BTN_GAP
.tb_click_next:
    add rbx, WINDOW_STRUCT_SIZE
    inc r12d
    jmp .tb_click_loop

.tb_click_none:
    mov rax, 1
    jmp .tb_click_ret

.not_handled:
    xor rax, rax

.tb_click_ret:
    pop r13
    pop r12
    pop rbx
    ret

; ============================================================================
; Handle right-click on start menu: RDI=mouseX, RSI=mouseY
; Returns RAX: 0=not handled, 1=handled
; ============================================================================
; auto-wrapped (FN_BEGIN emits global): global tb_handle_rclick
FN_BEGIN tb_handle_rclick, 0, 0, FN_RET_SCALAR
    push rbx

    ; First check if submenu is open and click is inside it
    cmp byte [sm_submenu_open], 0
    je .rc_check_menu

    ; Check if click is inside the submenu (2 items: 20px each + 4px pad)
    mov eax, [sm_submenu_x]
    cmp edi, eax
    jl .rc_close_sub
    add eax, SM_SUB_W
    cmp edi, eax
    jg .rc_close_sub
    mov eax, [sm_submenu_y]
    cmp esi, eax
    jl .rc_close_sub
    add eax, SM_SUB_H
    cmp esi, eax
    jg .rc_close_sub

    ; Click inside submenu - determine which item
    mov eax, esi
    sub eax, [sm_submenu_y]
    xor edx, edx
    mov ecx, 22
    div ecx
    ; eax = item index (0 = add/remove)
    test eax, eax
    jnz .rc_close_sub         ; only 1 item

    ; Toggle desktop icon for the saved app
    movzx edi, byte [sm_submenu_app]
    call desktop_has_icon
    test eax, eax
    jnz .rc_remove
    ; Add to desktop
    movzx edi, byte [sm_submenu_app]
    call desktop_add_icon
    jmp .rc_close_sub
.rc_remove:
    movzx edi, byte [sm_submenu_app]
    call desktop_remove_icon

.rc_close_sub:
    mov byte [sm_submenu_open], 0
    mov rax, 1
    jmp .rc_ret

.rc_check_menu:
    ; Is start menu open?
    cmp byte [tb_start_menu_open], 0
    je .rc_not_handled

    ; Check bounds of start menu
    cmp edi, START_MENU_X
    jl .rc_not_handled
    cmp edi, START_MENU_X + START_MENU_W
    jg .rc_not_handled
    cmp esi, [scr_start_menu_y]
    jl .rc_not_handled
    cmp esi, [scr_taskbar_y]
    jge .rc_not_handled

    ; Right-click inside menu - determine which item
    mov eax, esi
    sub eax, [scr_start_menu_y]
    sub eax, 8
    cmp eax, 0
    jl .rc_not_handled
    xor edx, edx
    mov ecx, MENU_ITEM_H
    div ecx

    ; Items 0-4 are apps (Explorer thru Paint), item 5 is About
    cmp eax, MENU_ITEM_COUNT
    jge .rc_not_handled

    ; eax = menu row index. Look up the app id; keep the row in r9 for Y placement.
    mov r9d, eax                  ; r9 = row index (preserved)
    mov rcx, MENU_ENTRY_SIZE
    mul rcx                       ; rax = row * MENU_ENTRY_SIZE
    lea rcx, [rel menu_entries]
    movzx edx, byte [rcx + rax + MENU_OFF_APP]
    mov byte [sm_submenu_app], dl
    mov dword [sm_submenu_x], START_MENU_X + START_MENU_W + 2
    mov ecx, r9d
    imul ecx, MENU_ITEM_H
    add ecx, [scr_start_menu_y]
    add ecx, 4
    mov [sm_submenu_y], ecx
    mov byte [sm_submenu_open], 1
    mov rax, 1
    jmp .rc_ret

.rc_not_handled:
    xor eax, eax
.rc_ret:
    pop rbx
    ret

; ============================================================================
; Draw start menu submenu (called from tb_draw when submenu is open)
; ============================================================================
SM_SUB_W  equ 160
SM_SUB_H  equ 26

; auto-wrapped (FN_BEGIN emits global): global tb_draw_submenu
FN_BEGIN tb_draw_submenu, 0, 0, FN_RET_SCALAR
    cmp byte [sm_submenu_open], 0
    je .sub_ret

    push rax

    ; Background
    mov edi, [sm_submenu_x]
    mov esi, [sm_submenu_y]
    mov edx, SM_SUB_W
    mov ecx, SM_SUB_H
    mov r8d, 0x001E1E3E
    call render_rect

    ; Border top
    mov edi, [sm_submenu_x]
    mov esi, [sm_submenu_y]
    mov edx, SM_SUB_W
    mov ecx, 1
    mov r8d, COLOR_BEVEL_LT
    call render_rect

    ; Determine text: "Add to Desktop" or "Remove from Desktop"
    movzx edi, byte [sm_submenu_app]
    call desktop_has_icon
    test eax, eax
    jnz .sub_show_remove

    ; Show "Add to Desktop"
    mov edi, [sm_submenu_x]
    add edi, 8
    mov esi, [sm_submenu_y]
    add esi, 5
    mov rdx, szSubAdd
    mov ecx, COLOR_TEXT_BLACK
    mov r8d, 0x001E1E3E
    call render_text
    jmp .sub_draw_done

.sub_show_remove:
    mov edi, [sm_submenu_x]
    add edi, 8
    mov esi, [sm_submenu_y]
    add esi, 5
    mov rdx, szSubRemove
    mov ecx, 0x00FF8888
    mov r8d, 0x001E1E3E
    call render_text

.sub_draw_done:
    pop rax
.sub_ret:
    ret

; ============================================================================
; Handle left-click on submenu (called from main loop)
; Returns RAX: 0=not in submenu, 1=handled
; ============================================================================
; auto-wrapped (FN_BEGIN emits global): global tb_handle_submenu_click
FN_BEGIN tb_handle_submenu_click, 0, 0, FN_RET_SCALAR
    cmp byte [sm_submenu_open], 0
    je .smc_no

    ; Check if click is inside the submenu
    mov eax, [sm_submenu_x]
    cmp edi, eax
    jl .smc_close
    add eax, SM_SUB_W
    cmp edi, eax
    jg .smc_close
    mov eax, [sm_submenu_y]
    cmp esi, eax
    jl .smc_close
    add eax, SM_SUB_H
    cmp esi, eax
    jg .smc_close

    ; Click inside submenu - toggle desktop icon
    push rdi
    push rsi
    movzx edi, byte [sm_submenu_app]
    call desktop_has_icon
    test eax, eax
    jnz .smc_do_remove
    pop rsi
    pop rdi
    push rdi
    push rsi
    movzx edi, byte [sm_submenu_app]
    call desktop_add_icon
    jmp .smc_close_pop
.smc_do_remove:
    pop rsi
    pop rdi
    push rdi
    push rsi
    movzx edi, byte [sm_submenu_app]
    call desktop_remove_icon
.smc_close_pop:
    pop rsi
    pop rdi
    mov byte [sm_submenu_open], 0
    mov rax, 1
    ret

.smc_close:
    mov byte [sm_submenu_open], 0
    mov rax, 1
    ret

.smc_no:
    xor eax, eax
    ret