; ============================================================================
; NexusOS v3.0 - Window Manager
; ============================================================================
bits 64

section .text

%include "constants.inc"
%include "macros.inc"
%include "window_layout.inc"

section .text
global wm_init
global wm_create_window
global wm_create_window_ex
global wm_draw_window
global wm_draw_desktop
global wm_handle_mouse_event
; wm_get_window_at migrated to src/kernel/nexushlk/wm_helpers.nxh (its `global`
; is emitted by that module's FN_BEGIN).
global wm_close_window
global wm_window_count
global wm_focused_window
global wm_drag_window_id
global desktop_bg_theme
global wallpaper_selected
global wallpaper_cache_valid
global wallpaper_cache_active_addr
global wallpaper_render_active
global wallpaper_cache_presented
global wallpaper_render_target_addr
global wallpaper_render_w
global wallpaper_render_h
global wm_poll_wallpaper_render

; Plain desktop fill colour used until a wallpaper is selected (0x00RRGGBB).
DESKTOP_SOLID_COLOR equ 0x00202632

extern render_rect
extern render_text
extern render_line
extern nx_icon_blit
extern render_get_backbuffer
extern render_mark_dirty
extern render_save_backbuffer
extern draw_hline
extern draw_vline
extern bb_addr
extern scr_pitch_q
extern memcpy
extern cursor_mode
extern call_app_l3
extern dispatch_app_callback           ; Stage 2d cross-core chokepoint
extern cpi_verify_callback             ; CPI-lite: authenticate tagged callback ptrs
extern call_app_l3_packed
extern process_submit_job
extern workqueue_done
extern workqueue_reap
extern wq_lock
extern wq_unlock
extern app_callback_lock
extern raster_select_default_target
extern ser_print_hex64
extern process_kill_window
extern process_create
extern l3_slot_base
extern desktop_draw_icons
extern nx_icon_close_16
extern app_hl_wallpaper_draw
extern app_media_draw
extern scr_width
extern scr_height
extern scene_dirty

FN_BEGIN wm_init, 0, 0, FN_RET_VOID
    push rbx
    ; Zero out window pool
    mov rdi, WINDOW_POOL_ADDR
    mov rcx, MAX_WINDOWS * WINDOW_STRUCT_SIZE
    xor rax, rax
    rep stosb
    mov qword [wm_window_count], 0
    mov qword [wm_drag_window_id], -1
    mov qword [wm_app_drag_window_id], -1
    mov qword [wm_focused_window], -1

    ; Slot 0 = native NexusHL wallpaper renderer. Set it up like a regular
    ; window so wm_draw_desktop_background can call into app_hl_wallpaper_draw
    ; through call_app_l3 / the normal l3 ABI.
    mov rbx, WINDOW_POOL_ADDR
    mov qword [rbx + WIN_OFF_ID], 0
    mov qword [rbx + WIN_OFF_X], 0
    mov qword [rbx + WIN_OFF_Y], 0
    mov eax, [scr_width]
    mov [rbx + WIN_OFF_W], rax
    mov eax, [scr_height]
    mov [rbx + WIN_OFF_H], rax
    ; Note: NO flags. Slot 0 is invisible to window iteration (focus, hit
    ; testing, draw loop) -- it only exists to give call_app_l3 a stable
    ; per-slot L3 arena for the wallpaper renderer.
    mov qword [rbx + WIN_OFF_FLAGS], 0
    lea rax, [rel app_hl_wallpaper_draw]
    mov [rbx + WIN_OFF_DRAWFN], rax
    xor edi, edi
    call l3_slot_base
    mov [rbx + WIN_OFF_APPDATA], rax

    ; Give the hidden wallpaper renderer a PCB so expensive SVG callbacks can
    ; be pinned to an AP home_core instead of falling back to the BSP.
    lea rdi, [rel app_hl_wallpaper_draw]
    xor esi, esi
    xor edx, edx
    call process_create
    mov [wallpaper_process_id], eax

    pop rbx
    FN_END wm_init
    ret

; Create window (simple): RDI=title, RSI=x, RDX=y, RCX=w, R8=h
; Returns RAX = window ID (-1 on fail)
FN_BEGIN wm_create_window, 5, 0, FN_RET_HANDLE
    xor r9d, r9d
    FN_END wm_create_window
    jmp wm_do_create

FN_BEGIN wm_create_window_ex, 6, 0, FN_RET_HANDLE
    FN_END wm_create_window_ex
    jmp wm_do_create

wm_do_create:
    push rbx
    push r12
    push r13
    push r14
    push r15

    ; Save args
    mov r12, rdi         ; title
    mov r13, rsi         ; x
    mov r14, rdx         ; y
    mov r15, rcx         ; w
    ; r8 = h, r9 = draw_fn already in regs

    mov rax, r13
    or  rax, r14
    or  rax, r15
    or  rax, r8
    shr rax, 32
    jnz .fail
    cmp r15d, MIN_WINDOW_W
    jb .fail
    cmp r8d, MIN_WINDOW_H
    jb .fail
    mov eax, r13d
    add eax, r15d
    jc .fail
    cmp eax, SCREEN_WIDTH
    ja .fail
    mov eax, r14d
    add eax, r8d
    jc .fail
    cmp eax, SCREEN_HEIGHT
    ja .fail

    ; Slot 0 is reserved for the native desktop wallpaper renderer's
    ; NexusHL state. Normal windows use slots 1..MAX_WINDOWS-1.
    cmp qword [wm_window_count], MAX_WINDOWS - 1
    jge .fail

    ; Unfocus all existing windows
    mov rbx, WINDOW_POOL_ADDR
    xor ecx, ecx
.unfocus_loop:
    cmp ecx, MAX_WINDOWS
    je .unfocus_done
    test qword [rbx + WIN_OFF_FLAGS], WF_ACTIVE
    jz .unfocus_next
    and qword [rbx + WIN_OFF_FLAGS], ~WF_FOCUSED
.unfocus_next:
    add rbx, WINDOW_STRUCT_SIZE
    inc ecx
    jmp .unfocus_loop
.unfocus_done:

    ; Find free slot
    mov rbx, WINDOW_POOL_ADDR + WINDOW_STRUCT_SIZE
    mov ecx, 1
.find_loop:
    cmp ecx, MAX_WINDOWS
    je .fail
    test qword [rbx + WIN_OFF_FLAGS], WF_ACTIVE
    jz .found_slot
    add rbx, WINDOW_STRUCT_SIZE
    inc ecx
    jmp .find_loop

.found_slot:
    ; Zero entire slot first
    push rcx
    mov rdi, rbx
    xor eax, eax
    mov ecx, WINDOW_STRUCT_SIZE
    rep stosb
    pop rcx

    ; ecx = slot index, rbx = ptr
    mov qword [rbx + WIN_OFF_ID], rcx
    mov [rbx + WIN_OFF_X], r13
    mov [rbx + WIN_OFF_Y], r14
    mov [rbx + WIN_OFF_W], r15
    mov [rbx + WIN_OFF_H], r8

    ; Flags = Active | Visible | Focused
    mov rax, WF_VISIBLE | WF_ACTIVE | WF_FOCUSED
    mov [rbx + WIN_OFF_FLAGS], rax

    ; Copy title (up to 63 chars)
    mov rsi, r12
    lea rdi, [rbx + WIN_OFF_TITLE]
    mov eax, 63
.copy_title:
    test eax, eax
    jz .title_done
    lodsb
    stosb
    test al, al
    jz .title_null
    dec eax
    jmp .copy_title
.title_null:
.title_done:
    mov byte [rdi], 0

    ; Set draw callback
    mov [rbx + WIN_OFF_DRAWFN], r9
    push rcx
    movzx edi, cx
    call l3_slot_base
    pop rcx
    mov [rbx + WIN_OFF_APPDATA], rax

    ; Register process
    mov rdi, r9
    movzx rsi, cx
    movzx rdx, cx
    call process_create

    ; Update globals
    movzx eax, cx
    mov [wm_focused_window], rax
    inc qword [wm_window_count]

    mov rax, rcx         ; Return window ID
    jmp .done

.fail:
    mov rax, -1
.done:
    FN_END wm_create_window_ex
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

; Close window by ID: RDI = window ID
FN_BEGIN wm_close_window, 1, 0, FN_RET_VOID
    ; Use unsigned compare: jge treats rdi as signed, so a caller-supplied
    ; negative index (e.g. -1) falls through and lets the code below write
    ; WIN_OFF_FLAGS at WINDOW_POOL_ADDR + rdi*256 -- a limited kernel write.
    cmp rdi, MAX_WINDOWS
    jae .close_ret
    push rax
    push rbx
    call process_kill_window
    mov rax, rdi
    mov rbx, WINDOW_STRUCT_SIZE
    imul rax, rbx
    add rax, WINDOW_POOL_ADDR
    mov qword [rax + WIN_OFF_FLAGS], 0   ; Clear all flags (inactive)
    dec qword [wm_window_count]
    ; If this was focused, move focus to another active visible window so the
    ; user can keep working after closing a launched document.
    cmp [wm_focused_window], rdi
    jne .close_nofocus
    call wm_focus_top_active
.close_nofocus:
    pop rbx
    pop rax
.close_ret:
    FN_END wm_close_window
    ret

wm_focus_top_active:
    push rax
    push rbx
    push rcx
    mov rcx, MAX_WINDOWS
    dec rcx
.fta_loop:
    cmp rcx, 0
    jl .fta_none
    mov rax, rcx
    imul rax, WINDOW_STRUCT_SIZE
    add rax, WINDOW_POOL_ADDR
    test qword [rax + WIN_OFF_FLAGS], WF_ACTIVE
    jz .fta_next
    test qword [rax + WIN_OFF_FLAGS], WF_VISIBLE
    jz .fta_next
    test qword [rax + WIN_OFF_FLAGS], WF_MINIMIZED
    jnz .fta_next
    mov rbx, WINDOW_POOL_ADDR
    xor eax, eax
.fta_clear_loop:
    cmp eax, MAX_WINDOWS
    je .fta_set
    and qword [rbx + WIN_OFF_FLAGS], ~WF_FOCUSED
    add rbx, WINDOW_STRUCT_SIZE
    inc eax
    jmp .fta_clear_loop
.fta_set:
    mov rax, rcx
    imul rax, WINDOW_STRUCT_SIZE
    add rax, WINDOW_POOL_ADDR
    or qword [rax + WIN_OFF_FLAGS], WF_FOCUSED
    mov [wm_focused_window], rcx
    jmp .fta_done
.fta_next:
    dec rcx
    jmp .fta_loop
.fta_none:
    mov qword [wm_focused_window], -1
.fta_done:
    pop rcx
    pop rbx
    pop rax
    ret

; Draw all windows (painter's algorithm)
FN_BEGIN wm_draw_desktop, 0, 0, FN_RET_VOID
    push rbx
    push r12

    ; 1. Desktop background
    call wm_draw_desktop_background
    cmp byte [wallpaper_render_active], 0
    jne .draw_done

    ; 1b. Desktop icons (between background and windows so apps cover them)
    call desktop_draw_icons

    ; 2. Draw non-focused windows first, then focused
    ; Pass 1: non-focused
    mov rbx, WINDOW_POOL_ADDR
    xor r12d, r12d
.draw_nf:
    cmp r12d, MAX_WINDOWS
    je .draw_focused_pass
    test qword [rbx + WIN_OFF_FLAGS], WF_ACTIVE
    jz .next_nf
    test qword [rbx + WIN_OFF_FLAGS], WF_VISIBLE
    jz .next_nf
    test qword [rbx + WIN_OFF_FLAGS], WF_MINIMIZED
    jnz .next_nf
    test qword [rbx + WIN_OFF_FLAGS], WF_FOCUSED
    jnz .next_nf
    mov rdi, r12
    call wm_draw_window
.next_nf:
    add rbx, WINDOW_STRUCT_SIZE
    inc r12d
    jmp .draw_nf

    ; Pass 2: focused window on top
.draw_focused_pass:
    mov rax, [wm_focused_window]
    cmp rax, -1
    je .draw_done
    cmp rax, MAX_WINDOWS
    jge .draw_done
    ; Check it's active+visible
    mov rbx, rax
    imul rbx, WINDOW_STRUCT_SIZE
    add rbx, WINDOW_POOL_ADDR
    test qword [rbx + WIN_OFF_FLAGS], WF_ACTIVE
    jz .draw_done
    test qword [rbx + WIN_OFF_FLAGS], WF_VISIBLE
    jz .draw_done
    test qword [rbx + WIN_OFF_FLAGS], WF_MINIMIZED
    jnz .draw_done
    mov rdi, rax
    call wm_draw_window

.draw_done:
    FN_END wm_draw_desktop
    pop r12
    pop rbx
    ret

; Desktop background renderer. Drives the NexusHL wallpaper app
; (app_hl_wallpaper_draw -> svg_render on the inline SVG strings) through the
; standard l3 ABI. Each theme has its own raster cache so changing backgrounds
; is a cache blit, not a full SVG render in the interactive frame loop.
FN_BEGIN wm_draw_desktop_background, 0, 0, FN_RET_VOID
    push rbx
    push r12
    push r13
    push r14
    push r15

    ; Until the user picks a wallpaper in Settings, the desktop uses a plain
    ; solid fill. This keeps the SVG rasterizer (a multi-second, syscall-heavy
    ; pass) entirely off the boot path so no core stalls while booting.
    cmp byte [wallpaper_selected], 0
    jne .have_wallpaper
    call wm_bg_fill_solid
    jmp .done
.have_wallpaper:
    movzx r12d, byte [desktop_bg_theme]
    cmp r12d, 2
    ja .theme_zero
.theme_ready:
    call wm_wallpaper_cache_addr
    mov r15, rax
    mov [wallpaper_cache_active_addr], r15

    mov ecx, [scr_width]
    cmp [wallpaper_cache_w], ecx
    jne .invalidate_all
    mov ecx, [scr_height]
    cmp [wallpaper_cache_h], ecx
    jne .invalidate_all
    cmp byte [wallpaper_cache_valid_by_theme + r12], 1
    jne .render
    cmp byte [wallpaper_cache_valid], 1
    jne .render
    mov rdi, r15
    call wm_bg_restore_cache
    mov byte [wallpaper_cache_presented], 1
    jmp .done

.theme_zero:
    xor r12d, r12d
    mov byte [desktop_bg_theme], 0
    jmp .theme_ready

.invalidate_all:
    mov byte [wallpaper_cache_valid], 0
    mov byte [wallpaper_cache_valid_by_theme + 0], 0
    mov byte [wallpaper_cache_valid_by_theme + 1], 0
    mov byte [wallpaper_cache_valid_by_theme + 2], 0
    mov byte [wallpaper_cache_presented], 0

.render:
    cmp byte [wallpaper_render_state], 1
    je .poll_render
    ; Refresh slot 0's shadow window to the current resolution before invoking
    ; the renderer -- wallpaper.nxh reads display_current_width/height through
    ; syscalls so this is only defense in depth.
    mov rbx, WINDOW_POOL_ADDR
    mov eax, [scr_width]
    mov [rbx + WIN_OFF_W], rax
    mov eax, [scr_height]
    mov [rbx + WIN_OFF_H], rax

    mov eax, [scr_width]
    mov [wallpaper_render_w], eax
    mov eax, [scr_height]
    mov [wallpaper_render_h], eax
    mov [wallpaper_render_theme], r12d
    mov [wallpaper_render_target_addr], r15
    mov byte [wallpaper_cache_presented], 0

    lea rax, [rel app_hl_wallpaper_draw]
    mov [wallpaper_render_pack + 0], rax
    mov [wallpaper_render_pack + 8], rbx
    mov qword [wallpaper_render_pack + 16], 0
    mov qword [wallpaper_render_pack + 24], 0

    mov byte [wallpaper_render_active], 1
    mov edi, [wallpaper_process_id]
    test edi, edi
    jle .render_unavailable
    lea rsi, [rel wallpaper_render_job]
    xor edx, edx
    xor r8d, r8d                       ; low priority background work
    call process_submit_job
    cmp eax, -1
    je .render_unavailable
    mov [wallpaper_render_handle], eax
    mov byte [wallpaper_render_state], 1
    mov byte [scene_dirty], 1
    jmp .done

.poll_render:
    call wm_poll_wallpaper_render
    cmp byte [wallpaper_render_state], 1
    je .render_still_pending
    cmp byte [wallpaper_cache_valid_by_theme + r12], 1
    jne .render
    cmp byte [wallpaper_cache_valid], 1
    jne .render
    mov rdi, r15
    call wm_bg_restore_cache
    mov byte [wallpaper_cache_presented], 1
    jmp .done

.render_still_pending:
    mov byte [scene_dirty], 1
    jmp .done

.render_unavailable:
    mov byte [wallpaper_render_active], 0
    mov byte [wallpaper_cache_presented], 1
    call wm_bg_fill_solid

.done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    FN_END wm_draw_desktop_background
    ret

; Poll the background wallpaper job without waiting for it. This is called from
; the BSP render loop so completed jobs are reaped without blocking core 0.
FN_BEGIN wm_poll_wallpaper_render, 0, 0, FN_RET_VOID
    cmp byte [wallpaper_render_state], 1
    jne .poll_done
    mov edi, [wallpaper_render_handle]
    call workqueue_done
    test eax, eax
    jz .poll_done
    mov edi, [wallpaper_render_handle]
    call workqueue_reap
    mov byte [wallpaper_render_state], 0
    mov byte [scene_dirty], 1
.poll_done:
    FN_END wm_poll_wallpaper_render
    ret

; Runs on an AP through process_submit_job. It renders the wallpaper app into
; the selected wallpaper cache. SVG raster syscalls select that cache as their
; destination, so this job never mutates bb_addr and the BSP can keep using the
; real backbuffer.
wallpaper_render_job:
    push rbx
    push r12
    push r13

    lea rdi, [rel app_callback_lock]
    call wq_lock

    lea rdi, [rel wallpaper_render_pack]
    call call_app_l3_packed

    call raster_select_default_target

    mov eax, [wallpaper_render_w]
    mov [wallpaper_cache_w], eax
    mov eax, [wallpaper_render_h]
    mov [wallpaper_cache_h], eax
    mov eax, [wallpaper_render_theme]
    cmp eax, 2
    ja .skip_theme_valid
    mov byte [wallpaper_cache_valid_by_theme + rax], 1
.skip_theme_valid:
    mov byte [wallpaper_cache_valid], 1

    lea rdi, [rel app_callback_lock]
    call wq_unlock
    mov byte [wallpaper_render_active], 0
    mov byte [scene_dirty], 1
    xor eax, eax

    pop r13
    pop r12
    pop rbx
    ret

wm_wallpaper_cache_addr:
    cmp r12d, 1
    je .cache1
    cmp r12d, 2
    je .cache2
    mov rax, WALLPAPER_CACHE0_ADDR
    ret
.cache1:
    mov rax, WALLPAPER_CACHE1_ADDR
    ret
.cache2:
    mov rax, WALLPAPER_CACHE2_ADDR
    ret

; wm_bg_fill_solid, wm_bg_save_cache, wm_bg_restore_cache, wm_bg_diamond migrated
; to src/kernel/nexushlk/wm_helpers.nxh (zero-asm; per-pixel dword loops replace
; the rep stosd/movsd with a byte-identical pixel stream). DESKTOP_SOLID_COLOR is
; mirrored as a const there.

; Draw a specific window: RDI = window ID
FN_BEGIN wm_draw_window, 1, 0, FN_RET_VOID
    push rbx
    push r12
    push r13
    push r14
    push r15

    ; Calculate struct pointer
    mov rax, rdi
    imul rax, WINDOW_STRUCT_SIZE
    add rax, WINDOW_POOL_ADDR
    mov rbx, rax

    ; Load dimensions
    mov r12, [rbx + WIN_OFF_X]
    mov r13, [rbx + WIN_OFF_Y]
    mov r14, [rbx + WIN_OFF_W]
    mov r15, [rbx + WIN_OFF_H]

    ; --- Raised bevel border (VGA98 style) ---
    ; Outer black frame
    mov rdi, r12
    mov rsi, r13
    mov rdx, r14
    mov rcx, r15
    mov r8d, COLOR_BEVEL_XDK
    call render_rect

    ; Top highlight
    mov rdi, r12
    mov rsi, r13
    mov rdx, r14
    mov rcx, COLOR_BEVEL_LT
    call draw_hline

    ; Left highlight
    mov rdi, r12
    mov rsi, r13
    mov rdx, r15
    mov rcx, COLOR_BEVEL_LT
    call draw_vline

    ; Bottom shadow (1px up from outer)
    mov rdi, r12
    mov rsi, r13
    add rsi, r15
    sub rsi, 1
    mov rdx, r14
    mov rcx, COLOR_BEVEL_DK
    call draw_hline

    ; Right shadow (1px left from outer)
    mov rdi, r12
    add rdi, r14
    sub rdi, 1
    mov rsi, r13
    mov rdx, r15
    mov rcx, COLOR_BEVEL_DK
    call draw_vline

    ; --- Client area ---
    mov rdi, r12
    add rdi, BORDER_WIDTH
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT
    mov rdx, r14
    sub rdx, BORDER_WIDTH * 2
    mov rcx, r15
    sub rcx, TITLEBAR_HEIGHT
    sub rcx, BORDER_WIDTH
    ; Clamp to at least 0
    cmp rcx, 0
    jle .skip_client
    cmp rdx, 0
    jle .skip_client
    mov r8d, COLOR_WINDOW_BG
    call render_rect
.skip_client:

    ; --- Title bar ---
    mov rdi, r12
    add rdi, BORDER_WIDTH
    mov rsi, r13
    add rsi, BORDER_WIDTH
    mov rdx, r14
    sub rdx, BORDER_WIDTH * 2
    mov ecx, TITLEBAR_HEIGHT - BORDER_WIDTH
    mov rax, [rbx + WIN_OFF_FLAGS]
    test rax, WF_FOCUSED
    jnz .tb_focused
    mov r8d, COLOR_TITLEBAR_UNF
    jmp .tb_draw
.tb_focused:
    mov r8d, COLOR_TITLEBAR
.tb_draw:
    call render_rect

    ; --- Title text ---
    mov rdi, r12
    add rdi, 8
    mov rsi, r13
    add rsi, 5
    lea rdx, [rbx + WIN_OFF_TITLE]
    mov ecx, COLOR_TEXT_WHITE
    ; bg = titlebar color
    mov rax, [rbx + WIN_OFF_FLAGS]
    test rax, WF_FOCUSED
    jnz .tt_focused
    mov r8d, COLOR_TITLEBAR_UNF
    jmp .tt_draw
.tt_focused:
    mov r8d, COLOR_TITLEBAR
.tt_draw:
    call render_text

    ; --- Close button [X] ---
    mov rdi, r12
    add rdi, r14
    sub rdi, CLOSE_BTN_SIZE + 4
    mov rsi, r13
    add rsi, 4
    mov edx, CLOSE_BTN_SIZE
    mov ecx, CLOSE_BTN_SIZE
    mov r8d, COLOR_CLOSE_BTN
    call render_rect

    ; Close icon
    mov rdi, r12
    add rdi, r14
    sub rdi, CLOSE_BTN_SIZE + 3
    mov rsi, r13
    add rsi, 5
    mov rdx, rsi
    mov rsi, rdi
    mov rdi, nx_icon_close_16
    call nx_icon_blit

    ; --- Minimize button [-] ---
    mov rdi, r12
    add rdi, r14
    sub rdi, CLOSE_BTN_SIZE * 2 + 8
    mov rsi, r13
    add rsi, 4
    mov edx, MIN_BTN_SIZE
    mov ecx, MIN_BTN_SIZE
    mov r8d, COLOR_MIN_BTN
    call render_rect

    ; Min label
    mov rdi, r12
    add rdi, r14
    sub rdi, CLOSE_BTN_SIZE * 2 + 5
    mov rsi, r13
    add rsi, 5
    mov rdx, szMinDash
    mov ecx, COLOR_TEXT_BLACK
    mov r8d, COLOR_MIN_BTN
    call render_text

    ; --- App content ---
    ; Call draw_fn if set, else default content
    mov rax, [rbx + WIN_OFF_DRAWFN]
    test rax, rax
    jz .default_content
    cmp rax, app_media_draw
    jne .dispatch_user_draw
    mov rdi, rbx
    call app_media_draw
    jmp .draw_done
.dispatch_user_draw:
    mov rdi, rax
    mov rsi, rbx         ; arg0: window_ptr
    xor edx, edx         ; arg1
    xor ecx, ecx         ; arg2
    call dispatch_app_callback
.draw_done:
    jmp .content_done

.default_content:
    ; Default: show "Empty Window"
    mov rdi, r12
    add rdi, BORDER_WIDTH + 8
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 8
    mov rdx, szEmptyWin
    mov ecx, COLOR_TEXT_GRAY
    mov r8d, COLOR_WINDOW_BG
    call render_text

.content_done:
    FN_END wm_draw_window
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

; wm_handle_mouse_event migrated to src/kernel/nexushlk/wm_helpers.nxh.
; Keep click/drag callback routing in NexusHLK so the event path cannot dispatch
; a tagged/stale window-struct pointer directly into ring 3.
; Draw drag outline (called from main loop when dragging)
; Uses wm_drag_preview_x/y/w/h to draw a 2px rectangle outline
global wm_draw_drag_outline
FN_BEGIN wm_draw_drag_outline, 0, 0, FN_RET_VOID
    cmp qword [wm_drag_window_id], -1
    je .outline_ret

    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r12, [wm_drag_preview_x]    ; x
    mov r13, [wm_drag_preview_y]    ; y
    mov r14, [wm_drag_preview_w]    ; w
    mov r15, [wm_drag_preview_h]    ; h

    ; Top edge: full width, 2px tall
    mov edi, r12d
    mov esi, r13d
    mov edx, r14d
    mov ecx, 2
    mov r8d, COLOR_HIGHLIGHT
    call render_rect

    ; Bottom edge
    mov edi, r12d
    mov esi, r13d
    add esi, r15d
    sub esi, 2
    mov edx, r14d
    mov ecx, 2
    mov r8d, COLOR_HIGHLIGHT
    call render_rect

    ; Left edge
    mov edi, r12d
    mov esi, r13d
    mov edx, 2
    mov ecx, r15d
    mov r8d, COLOR_HIGHLIGHT
    call render_rect

    ; Right edge
    mov edi, r12d
    add edi, r14d
    sub edi, 2
    mov esi, r13d
    mov edx, 2
    mov ecx, r15d
    mov r8d, COLOR_HIGHLIGHT
    call render_rect

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
.outline_ret:
    FN_END wm_draw_drag_outline
    ret

; wm_mark_outline_dirty migrated to src/kernel/nexushlk/wm_helpers.nxh
; (R8=x R9=y R10=w R11=h; four render_mark_dirty edge calls).

; wm_get_window_at migrated to src/kernel/nexushlk/wm_helpers.nxh
; (RDI=x RSI=y -> RAX=window ID or -1; pure geometry hit-test).

; ============================================================================
; §6 — Kernel-owned per-slot callback trampoline
;
; Threat: today the WM invokes app callbacks by reading a RAW function pointer
; straight out of the window struct (WIN_OFF_CLICKFN/KEYFN/DRAGFN/RCLICKFN) and
; jumping to it, so the invocation target is a ring-3-influenced qword.
;
; This adds a kernel-owned indirection so the WM's invocation no longer trusts
; the window-struct qword as the call target. Each (slot, field) callback is
; INTERNED — the pointer is copied into a per-slot callback table that lives in
; KERNEL BSS, OUTSIDE the ring-3 app arena (so an app's own slot-memory write
; bug can't forge an entry) — and the WM then dispatches by ID through
; wm_cb_resolve/wm_cb_trampoline, which read the target from the kernel table.
; The window struct's qword is reduced to "intern input", not "the address we
; jump to". Same per-slot-array + index discipline as the handle table
; (src/kernel/proc/handle_table.inc): one fixed-size row per slot, kernel BSS.
;
; SCOPE (strict file ownership; other agents edit syscall.asm / main.asm /
; launch.inc concurrently):
;   - INVOCATION sites this file owns are routed through the table:
;     CLICKFN (.client_click), RCLICKFN (.right_click), DRAGFN
;     (.app_drag_active). The call target is taken from wm_cb_table, not the
;     window struct.
;   - REGISTRATION (apps installing a callback) lives in syscall.asm
;     (.sc_wm_handlers, CLICKFN/KEYFN) and src/user/apps/launch.inc (KEYFN
;     direct write) — NOT owned here. The full ABI cutover (app registers a
;     slot-local ID instead of a raw pointer; the kernel interns at
;     registration time via wm_cb_intern) requires those owners to call
;     wm_cb_intern at the store site and have apps pass an ID. Until then we
;     intern lazily at dispatch, which still removes the raw pointer from the
;     WM's call target and gives the table a single trusted fill point.
;   - KEYFN INVOCATION lives in main.asm (the two WIN_OFF_KEYFN dispatch
;     sites) — NOT owned here. That owner should swap
;     `mov rdi,[win+KEYFN]; call dispatch_app_callback` for the same
;     intern+`call wm_cb_trampoline` shape used below (field id
;     WM_CB_FIELD_KEY reserved for it).
;   - If CPI-lite callback signing (cpi_sign/verify_callback) lands/relands in
;     this dispatch path, intern the CPI-VERIFIED pointer (defense in depth):
;     verify first, then pass the cleaned pointer to wm_cb_intern.
; ============================================================================

; Per-(slot,field) callback target table — kernel BSS, indexed
; [slot * WM_CB_FIELDS + field]. Holds the trusted kernel-image VA the WM will
; actually jump to. A zero entry means "no callback interned".
WM_CB_FIELD_CLICK   equ 0
WM_CB_FIELD_KEY     equ 1            ; reserved for the main.asm KEYFN site
WM_CB_FIELD_DRAG    equ 2
WM_CB_FIELD_RCLICK  equ 3
WM_CB_FIELDS        equ 4

; wm_cb_intern and wm_cb_resolve migrated to src/kernel/nexushlk/wm_helpers.nxh
; (bounded callback-table fill/lookup with #UD-on-OOB indexing). WM_CB_FIELDS /
; WM_CB_FIELD_* equs above stay here (used by the mouse handler + trampoline);
; the wm_cb_table BSS array is defined below. wm_cb_trampoline (CPI-adjacent
; dispatch) stays in asm and calls wm_cb_resolve cross-module within this unit.

; wm_cb_trampoline — the kernel-owned invoker. Resolve a slot-local callback id
; against the table and dispatch the stored TRUSTED target.
;   EDI = slot-local callback id (0 = none)
;   RSI = window ptr (arg0); RDX = arg1; RCX = arg2
; Returns dispatch_app_callback's rax, or 0 (no call) if the id resolves empty.
; Clobbers per dispatch_app_callback. Exposed (FN_BEGIN -> global) so the
; main.asm KEYFN dispatch site can route through it in a later cutover.
FN_BEGIN wm_cb_trampoline, 4, 0, FN_RET_SCALAR
    push rsi
    push rdx
    push rcx
    call wm_cb_resolve                ; rax = trusted target from kernel BSS
    pop rcx
    pop rdx
    pop rsi
    test rax, rax
    jz .ct_none
    mov rdi, rax                      ; target from KERNEL table, not the window
    call dispatch_app_callback
    FN_END wm_cb_trampoline
    ret
.ct_none:
    xor eax, eax
    FN_END wm_cb_trampoline
    ret

section .data
szCloseX      db "X", 0
szMinDash     db "-", 0
szEmptyWin    db "Empty Window", 0

global wm_window_count
global wm_focused_window
wm_window_count   dq 0
wm_focused_window dq -1
wm_click_focus_before dq -1
wm_drag_window_id dq -1
wm_drag_off_x     dq 0
wm_drag_off_y     dq 0
; App-drag (per-window drag callback) tracking. Independent from the
; titlebar window-drag above — that one moves the whole window; this one
; routes mouse-move events to the app while the left button stays held.
; Latched on left-button-down inside a client area whose window has a
; non-zero WIN_OFF_DRAGFN. Cleared on left-button release.
wm_app_drag_window_id dq -1
wm_app_drag_last_x    dq 0
wm_app_drag_last_y    dq 0
global wm_drag_preview_x
global wm_drag_preview_y
global wm_drag_preview_w
global wm_drag_preview_h
wm_drag_preview_x dq 0          ; outline X position
wm_drag_preview_y dq 0          ; outline Y position
wm_drag_preview_w dq 0          ; outline width
wm_drag_preview_h dq 0          ; outline height
wm_last_buttons   dq 0
desktop_bg_theme  db 0
; 0 = no wallpaper chosen yet -> desktop draws a solid colour and the SVG
; rasterizer never runs. Set to 1 by SYS_DESKTOP_SET_BG when the user picks a
; theme in Settings; only then is a wallpaper rendered.
wallpaper_selected db 0
wallpaper_cache_valid db 0
wallpaper_cache_presented db 0
wallpaper_cache_valid_by_theme db 0, 0, 0
align 8
wallpaper_cache_active_addr dq WALLPAPER_CACHE0_ADDR
align 4
wallpaper_cache_w dd 0
wallpaper_cache_h dd 0
wallpaper_process_id dd -1
wallpaper_render_state db 0
wallpaper_render_active db 0
times 2 db 0
wallpaper_render_handle dd -1
wallpaper_render_theme dd 0
wallpaper_render_w dd 0
wallpaper_render_h dd 0
wallpaper_render_target_addr dq WALLPAPER_CACHE0_ADDR
align 64
wallpaper_render_pack times 32 db 0

; §6 per-slot callback target table (kernel BSS — OUTSIDE the ring-3 app arena,
; so a slot-memory write bug can't forge an entry). One trusted kernel-image VA
; per (slot, field). Indexed [slot * WM_CB_FIELDS + field]; a zero entry means
; "no callback interned". BSS-zero = empty, so no boot seed is needed; a
; recycled slot re-interns on its next dispatch. Mirrors the per-slot handle
; table's kernel-BSS discipline.
section .bss
align 16
global wm_cb_table
wm_cb_table  resq MAX_WINDOWS * WM_CB_FIELDS

section .text
