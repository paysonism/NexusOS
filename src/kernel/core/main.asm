; ============================================================================
; NexusOS v3.0 - Kernel Main (Free-running render loop)
; ============================================================================
bits 64

%include "constants.inc"
%include "macros.inc"

section .text
; auto-wrapped (FN_BEGIN emits global): global kmain
; auto-wrapped (FN_BEGIN emits global): global process_keyboard
; auto-wrapped (FN_BEGIN emits global): global process_mouse
; auto-wrapped (FN_BEGIN emits global): global debug_print
; auto-wrapped (FN_BEGIN emits global): global serial_poll_command

; Kernel
extern idt_init
extern pic_init
extern pit_init
extern acpi_init
extern apic_init
extern smp_ap_startup
extern ioapic_init
extern spi_init
extern spi_hid_init
extern acpi_pci_init
extern perfdiag_init
extern perfdiag_print_profile
extern perfdiag_print_memory
extern perfdiag_print_smp
extern perfdiag_benchmark
extern trace_dump_serial

; Drivers
extern mouse_init
extern usb_hid_init
extern i2c_hid_init
extern i2c_hid_poll
extern battery_init
extern battery_poll
extern keyboard_init
extern display_init
extern mouse_check_moved
extern mouse_x
extern mouse_y
extern mouse_buttons
extern mouse_moved
extern usb_poll_mouse
extern uefi_mouse_poll
extern usb_mouse_active
extern usb_no_xhci
extern i2c_hid_active
extern xhci_probe
extern keyboard_read
extern keyboard_repeat_tick
extern keyboard_available
extern kb_numlock

extern frame_count
extern start_tick
extern last_fps
extern fps_show
extern tick_count
extern uint32_to_str
extern render_text

; GUI
extern wm_init
extern render_init
extern cursor_init
extern wm_create_window
extern wm_create_window_ex
extern wm_draw_desktop
extern wm_draw_window
extern desktop_draw_icons
extern tb_draw
extern cursor_draw
extern cursor_hide
extern render_flush
extern render_mark_full
extern wm_handle_mouse_event
extern wm_close_window
extern tb_handle_click
extern desktop_handle_click
extern wm_focused_window
extern wm_window_count
extern wm_draw_drag_outline
extern wm_drag_window_id
extern render_restore_backbuffer
extern render_mark_dirty
extern render_save_backbuffer
extern display_flip_rect
extern call_app_l3
extern bb_addr
extern scr_pitch
extern scr_pitch_q
extern display_flip
extern wait_vsync
extern vsync_enabled

; Filesystem
extern fat16_init

; SVG render-comparison probe
extern wm_draw_desktop_background
extern desktop_bg_theme
extern wallpaper_selected
extern wallpaper_cache_valid
extern wallpaper_cache_active_addr
extern scr_width
extern scr_height

; Apps
extern app_launch
extern app_show_context_menu
extern ctx_menu_visible
extern ctx_menu_x
extern ctx_menu_y
extern szCtxOpen
extern explorer_sel
extern fat16_get_entry
extern kernel_open_file_in_notepad

; Start menu submenu
extern tb_handle_rclick
extern tb_draw_submenu
extern tb_handle_submenu_click
extern sm_submenu_open

; Window struct offsets
WIN_OFF_ID      equ 0
WIN_OFF_X       equ 8
WIN_OFF_Y       equ 16
WIN_OFF_W       equ 24
WIN_OFF_H       equ 32
WIN_OFF_FLAGS   equ 40
WIN_OFF_TITLE   equ 48
WIN_OFF_DRAWFN  equ 112
WIN_OFF_KEYFN   equ 120
WIN_OFF_CLICKFN equ 128
WIN_OFF_APPDATA equ 136
WIN_OFF_DRAGFN  equ 144         ; optional fn(win, client_x, client_y) fired while left button held

; FPS overlay region
FPS_REGION_X    equ 8
FPS_REGION_Y    equ 8
FPS_REGION_W    equ 290
FPS_REGION_H    equ 40

extern fill_rect

section .data
debug_y: dd 40
global gui_initialized
gui_initialized db 0
global scene_dirty
scene_dirty db 1

section .text

; --- debug_print ---
; RSI = string pointer
FN_BEGIN debug_print, 0, 0, FN_RET_SCALAR
    push rax
    push rbx
    push rcx
    push rdx
    push rdi
    push rsi
    push r8
    push r9
    push r10
    push r11
    push r12
    
    mov r12, rsi     ; Preserve RSI

    ; Screen Output
    mov rax, [bb_addr]
    test rax, rax
    jz .done

    ; Boot splash: keep the green console hidden during boot so the animation
    ; owns the screen. Holding a key reveals the live console.
    extern kb_repeat_scancode
    cmp byte [gui_initialized], 1
    je .console_draw
    movzx ecx, byte [kb_repeat_scancode]
    test ecx, ecx
    jz .done
.console_draw:

    mov edi, 0
    mov esi, [debug_y]
    mov edx, 800
    mov ecx, 16
    mov r8d, 0x00000000
    call fill_rect
    
    mov edi, 10
    mov esi, [debug_y]
    mov rdx, r12
    mov ecx, 0x0000FF00
    mov r8d, 0x00000000
    call render_text
    add dword [debug_y], 16
    
    cmp dword [debug_y], 600
    jl .y_ok
    mov dword [debug_y], 0
.y_ok:

    cmp byte [gui_initialized], 1
    je .done
    call display_flip
.done:
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; ============================================================================
; Context menu (kernel-side render + click).
; The user-mode explorer can no longer draw or handle ctx_menu_visible (the
; NexusHL rewrite dropped that path), so the kernel renders a minimal "Open"
; menu on right-click and routes the left-click hit straight to the file
; opener.
; ============================================================================
CTX_W   equ 100
CTX_H   equ 22

global ctx_menu_draw
ctx_menu_draw:
    cmp byte [ctx_menu_visible], 0
    je .cmd_done
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    ; Background
    mov edi, [ctx_menu_x]
    mov esi, [ctx_menu_y]
    mov edx, CTX_W
    mov ecx, CTX_H
    mov r8d, 0x00F0F0F0
    call fill_rect
    ; Top border
    mov edi, [ctx_menu_x]
    mov esi, [ctx_menu_y]
    mov edx, CTX_W
    mov ecx, 1
    mov r8d, 0x00999999
    call fill_rect
    ; Bottom border
    mov edi, [ctx_menu_x]
    mov esi, [ctx_menu_y]
    add esi, CTX_H - 1
    mov edx, CTX_W
    mov ecx, 1
    mov r8d, 0x00999999
    call fill_rect
    ; Left border
    mov edi, [ctx_menu_x]
    mov esi, [ctx_menu_y]
    mov edx, 1
    mov ecx, CTX_H
    mov r8d, 0x00999999
    call fill_rect
    ; Right border
    mov edi, [ctx_menu_x]
    add edi, CTX_W - 1
    mov esi, [ctx_menu_y]
    mov edx, 1
    mov ecx, CTX_H
    mov r8d, 0x00999999
    call fill_rect
    ; "Open" label
    mov edi, [ctx_menu_x]
    add edi, 10
    mov esi, [ctx_menu_y]
    add esi, 6
    lea rdx, [rel szCtxOpen]
    mov ecx, 0x00222222
    mov r8d, 0x00F0F0F0
    call render_text
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
.cmd_done:
    ret

; Called when a left-click happens while ctx_menu_visible is set. The caller
; already loaded the click coords into EDI/ESI and the buttons mask in EDX.
global ctx_menu_handle_click
ctx_menu_handle_click:
    push rax
    push rcx
    push rdi
    ; Hit-test the menu rect.
    mov eax, [ctx_menu_x]
    cmp edi, eax
    jl .cmh_done
    mov ecx, eax
    add ecx, CTX_W
    cmp edi, ecx
    jge .cmh_done
    mov eax, [ctx_menu_y]
    cmp esi, eax
    jl .cmh_done
    mov ecx, eax
    add ecx, CTX_H
    cmp esi, ecx
    jge .cmh_done
    ; Inside menu -> "Open" the explorer-selected entry.
    mov edi, [explorer_sel]
    call fat16_get_entry
    test rax, rax
    jz .cmh_done
    mov cl, [rax + 11]
    test cl, 0x10                ; skip directories
    jnz .cmh_done
    mov rdi, rax
    call kernel_open_file_in_notepad
.cmh_done:
    pop rdi
    pop rcx
    pop rax
    ret

; --- Kernel Entry ---
FN_BEGIN kmain, 0, 0, FN_RET_SCALAR
    extern app_blob_init
    call app_blob_init          ; read loaded APPS.BIN pointer before anyone uses it
    call display_init
    call display_flip

    extern xml_self_test
    call xml_self_test
    extern raster_self_test
    call raster_self_test

    call idt_init
    extern gdt64_init
    extern tss_init
    extern syscall_init
    call gdt64_init
    call tss_init
    call syscall_init

    extern scheduler_init
    call scheduler_init
    call pic_init
    call pit_init

    ; Enable interrupts early so the boot splash has a PIT tick to time frames
    ; with and a keyboard IRQ to be skipped by.
    sti
    call fat16_init             ; needed to load BOOTANIM.NBA
    call keyboard_init          ; needed so the splash can be skipped by a key

    ; Boot splash: plays BOOTANIM.NBA before any hardware init prints to the
    ; console. The green console stays hidden unless a key is held.
    extern boot_anim_play
    call boot_anim_play

    call acpi_init
    call apic_init
    call ioapic_init
    call spi_init
    call spi_hid_init
    
    call usb_hid_init
    call i2c_hid_init

    ; SMP work queue must be initialised BEFORE the APs are started: workers
    ; gate on workqueue_ready, so init first guarantees they see a clean queue.
    extern workqueue_init
    extern workqueue_selftest
    call workqueue_init

%ifdef NEXUS_CACHE32_MAX
    call smp_ap_startup
%endif
    call workqueue_selftest
    call perfdiag_init
    call mouse_init

    call render_init
    call cursor_init
    call wm_init
    ; Wallpapers are NOT prewarmed here: the desktop boots with a solid
    ; background and only rasterizes an SVG wallpaper once one is selected in
    ; Settings, so boot never stalls on the renderer.

    mov byte [gui_initialized], 1

    call cpu_acct_init
    call render_frame

.infinite:
    call cpu_acct_idle_end
    cmp byte [gui_initialized], 1
    jne .skip_gui
    call render_frame
    call usb_poll_mouse
    call i2c_hid_poll
    call battery_poll
    call process_mouse
    call keyboard_repeat_tick
.drain_kb:
    call process_keyboard
    call keyboard_available
    test eax, eax
    jnz .drain_kb
    call serial_poll_command
.skip_gui:
    call cpu_acct_work_end
    hlt
    jmp .infinite

; ============================================================================
; CPU utilization accounting for the BSP (core 0).
; The main loop alternates between a work phase (render + polling) and an
; idle phase (hlt until the next interrupt). We timestamp each transition
; with RDTSC, accumulate busy vs idle cycles, and every ~0.5s collapse the
; window into a 0..100 percentage in [bsp_util]. Task Manager reads this
; through SYS_SYSINFO.
; ============================================================================
cpu_acct_init:
    rdtsc
    shl rdx, 32
    or rax, rdx
    mov [acct_last_mark], rax
    mov [acct_work_start], rax
    mov rax, [tick_count]
    mov [acct_win_tick], rax
    ret

; Called at the top of each loop iteration: the time since the previous
; mark was spent halted, so bank it as idle and start the work timer.
cpu_acct_idle_end:
    push rcx
    push rdx
    rdtsc
    shl rdx, 32
    or rax, rdx
    mov rcx, rax
    sub rax, [acct_last_mark]
    add [acct_idle_acc], rax
    mov [acct_work_start], rcx
    pop rdx
    pop rcx
    ret

; Called right before hlt: bank the work-phase cycles and, once the 50-tick
; window closes, recompute the utilization percentage.
cpu_acct_work_end:
    push rbx
    push rcx
    push rdx
    rdtsc
    shl rdx, 32
    or rax, rdx
    mov rbx, rax
    sub rax, [acct_work_start]
    add [acct_busy_acc], rax
    mov [acct_last_mark], rbx
    mov rax, [tick_count]
    sub rax, [acct_win_tick]
    cmp rax, 50
    jl .acct_done
    mov rax, [acct_busy_acc]
    mov rcx, [acct_idle_acc]
    add rcx, rax
    test rcx, rcx
    jz .acct_reset
    mov rbx, 100
    xor rdx, rdx
    mul rbx                  ; rdx:rax = busy * 100
    div rcx                  ; rax = busy*100 / total
    cmp rax, 100
    jbe .acct_store
    mov rax, 100
.acct_store:
    mov [bsp_util], eax
.acct_reset:
    mov qword [acct_busy_acc], 0
    mov qword [acct_idle_acc], 0
    mov rax, [tick_count]
    mov [acct_win_tick], rax
.acct_done:
    pop rdx
    pop rcx
    pop rbx
    ret

; ============================================================================
; serial_poll_command - poll COM1 for serial automation input
;  raw bytes become focused-window keypresses
;  0x01 + '2'..'8' launches app IDs directly
;  0x01 + 'x' closes the focused window
; ============================================================================
FN_BEGIN serial_poll_command, 0, 0, FN_RET_SCALAR
    push rax
    push rcx
    push rdx
    push rdi

.poll:
    mov dx, 0x3F8 + 5
    in al, dx
    test al, 1
    jz .done

    mov dx, 0x3F8
    in al, dx

    cmp byte [serial_command_armed], 0
    jne .dispatch_control

    cmp al, 1
    je .arm_control

    call serial_forward_input
    jmp .poll

.arm_control:
    mov byte [serial_command_armed], 1
    jmp .poll

.dispatch_control:
    mov byte [serial_command_armed], 0
    call serial_dispatch_control
    jmp .poll

.done:
    pop rdi
    pop rdx
    pop rcx
    pop rax
    ret

serial_dispatch_control:
    cmp al, '2'
    jb .check_close
    cmp al, '8'
    ja .check_close
    movzx edi, al
    sub edi, '0'
    SER 'L'
    push rax
    push rdi
    call ser_print_hex64
    pop rdi
    pop rax
    sub rsp, 8
    call app_launch
    add rsp, 8
    SER 'R'
    push rdi
    mov rdi, rax
    call ser_print_hex64
    pop rdi
    mov byte [scene_dirty], 1
    ret

.check_close:
    cmp al, 'o'
    je .desktop_open_first
    cmp al, 'q'
    je .dump_windows
    cmp al, 'p'
    je .diag_profile
    cmp al, 'm'
    je .diag_memory
    cmp al, 's'
    je .diag_smp
    cmp al, 't'
    je .dump_trace
    cmp al, 'g'
    je .svg_dump
    cmp al, 'b'
    je .diag_bench
    cmp al, 'x'
    je .close_focused
    cmp al, 'X'
    jne .control_done

.dump_windows:
    SER 'Q'
    push rax
    mov rdi, [wm_window_count]
    call ser_print_hex64
    SER ','
    mov rdi, [wm_focused_window]
    call ser_print_hex64
    pop rax
    ret

.desktop_open_first:
    mov edi, 48
    mov esi, 48
    call desktop_handle_click
    SER 'O'
    push rax
    mov rdi, rax
    call ser_print_hex64
    pop rax
    mov byte [scene_dirty], 1
    ret

.diag_profile:
    call perfdiag_print_profile
    ret

.diag_memory:
    call perfdiag_print_memory
    ret

.diag_smp:
    call perfdiag_print_smp
    ret

.diag_bench:
    call perfdiag_benchmark
    ret

.dump_trace:
%ifdef ENABLE_TRACE
    call trace_dump_serial
%endif
    ret

; 0x01 'g' — SVG render-comparison probe. Forces the glass-ribbons SVG
; wallpaper, re-renders it through the NexusOS svg2 rasterizer into the
; wallpaper cache (a clean copy of the render with no icons/windows on top),
; then streams that image, downsampled to 160x90, over COM1 so a host harness
; can diff it against a reference renderer.
.svg_dump:
    SER 'G'
    mov byte [desktop_bg_theme], 1       ; glass ribbons
    mov byte [wallpaper_selected], 1     ; probe needs the SVG path, not solid fill
    mov byte [wallpaper_cache_valid], 0  ; force a fresh rasterize
    sub rsp, 8
    call wm_draw_desktop_background      ; rasterize + populate cache
    add rsp, 8
    call svg_dump_serial
    mov byte [scene_dirty], 1
    ret

.close_focused:
    mov rdi, [wm_focused_window]
    cmp rdi, -1
    je .control_done
    sub rsp, 8
    call wm_close_window
    add rsp, 8
    mov byte [scene_dirty], 1

.control_done:
    ret

; ============================================================================
; svg_dump_serial - stream the wallpaper-cache render over COM1.
; Downsamples the active wallpaper cache (scr_width x scr_height, 32bpp, tightly
; packed) to 160x90 with nearest-neighbour sampling and emits it framed as:
;   [SVGDUMP]\n  <90 lines of 160 uppercase hex RGB triplets>  [SVGEND]\n
; ============================================================================
SVG_DUMP_W equ 160
SVG_DUMP_H equ 90

svg_dump_serial:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    push r12
    push r13
    push r14
    push r15

    lea rsi, [rel svg_dump_hdr]
    call svg_dump_puts

    ; "DIM <scr_width> <scr_height>\n" — lets the host render its reference at
    ; the same source resolution so letterboxing matches before downsampling.
    lea rsi, [rel svg_dump_dim]
    call svg_dump_puts
    mov eax, [scr_width]
    call svg_dump_dec
    mov al, ' '
    call svg_dump_putc
    mov eax, [scr_height]
    call svg_dump_dec
    mov al, 10
    call svg_dump_putc

    xor r12d, r12d                       ; oy
.row:
    cmp r12d, SVG_DUMP_H
    jae .rows_done
    mov eax, r12d                        ; sy = oy * scr_height / SVG_DUMP_H
    mov ecx, [scr_height]
    imul eax, ecx
    xor edx, edx
    mov ebx, SVG_DUMP_H
    div ebx
    mov ecx, [scr_width]                 ; row base = cache + sy*scr_width*4
    imul eax, ecx
    shl eax, 2
    mov r13, [wallpaper_cache_active_addr]
    add r13, rax

    xor r14d, r14d                       ; ox
.col:
    cmp r14d, SVG_DUMP_W
    jae .col_done
    mov eax, r14d                        ; sx = ox * scr_width / SVG_DUMP_W
    mov ecx, [scr_width]
    imul eax, ecx
    xor edx, edx
    mov ebx, SVG_DUMP_W
    div ebx
    lea r15, [r13 + rax*4]
    mov r8d, [r15]                       ; pixel (0x00RRGGBB)
    mov eax, r8d
    shr eax, 16
    call svg_dump_hexbyte                ; R
    mov eax, r8d
    shr eax, 8
    call svg_dump_hexbyte                ; G
    mov eax, r8d
    call svg_dump_hexbyte                ; B
    inc r14d
    jmp .col
.col_done:
    mov al, 10
    call svg_dump_putc
    inc r12d
    jmp .row
.rows_done:
    lea rsi, [rel svg_dump_ftr]
    call svg_dump_puts

    pop r15
    pop r14
    pop r13
    pop r12
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; al = character -> COM1
svg_dump_putc:
    push rax
    push rdx
    mov dx, 0x3F8
    out dx, al
    pop rdx
    pop rax
    ret

; rsi = NUL-terminated string -> COM1
svg_dump_puts:
    push rax
    push rsi
.puts_loop:
    mov al, [rsi]
    test al, al
    jz .puts_done
    call svg_dump_putc
    inc rsi
    jmp .puts_loop
.puts_done:
    pop rsi
    pop rax
    ret

; eax = byte (low 8 bits) -> two uppercase hex chars
svg_dump_hexbyte:
    push rax
    push rbx
    movzx ebx, al
    mov eax, ebx
    shr eax, 4
    call svg_dump_nibble
    mov eax, ebx
    and eax, 0x0F
    call svg_dump_nibble
    pop rbx
    pop rax
    ret

; al = nibble (low 4 bits) -> one uppercase hex char
svg_dump_nibble:
    push rax
    and al, 0x0F
    cmp al, 10
    jb .nib_digit
    add al, 'A' - 10
    jmp .nib_emit
.nib_digit:
    add al, '0'
.nib_emit:
    call svg_dump_putc
    pop rax
    ret

; eax = unsigned value -> decimal digits on COM1
svg_dump_dec:
    push rax
    push rbx
    push rcx
    push rdx
    mov ebx, 10
    xor ecx, ecx                         ; digit count
.dec_div:
    xor edx, edx
    div ebx                              ; eax/=10, edx=digit
    push rdx
    inc ecx
    test eax, eax
    jnz .dec_div
.dec_emit:
    pop rax
    add al, '0'
    call svg_dump_putc
    loop .dec_emit
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

svg_dump_hdr db "[SVGDUMP]", 10, 0
svg_dump_dim db "DIM ", 0
svg_dump_ftr db "[SVGEND]", 10, 0

serial_forward_input:
    cmp al, 0
    je .input_done
    cmp al, 10
    jne .input_check_cr
    mov al, 13
.input_check_cr:
    cmp al, 13
    je .input_dispatch
    cmp al, 8
    je .input_dispatch
    cmp al, 9
    je .input_dispatch
    cmp al, 32
    jb .input_done
    cmp al, 126
    ja .input_done

.input_dispatch:
    mov dl, al
    mov r8, [wm_focused_window]
    cmp r8, -1
    je .input_done
    mov rax, r8
    imul rax, WINDOW_STRUCT_SIZE
    add rax, WINDOW_POOL_ADDR
    mov r9, [rax + WIN_OFF_KEYFN]
    test r9, r9
    jz .input_done

    movzx edx, dl
    shl edx, 8
    or edx, 0x01000000
    mov rsi, rax
    mov rdi, r9
    call call_app_l3
.input_dispatch_done:
    mov byte [scene_dirty], 1

.input_done:
    ret

; ============================================================================
; Process mouse input - sets scene_dirty if needed
; ============================================================================
FN_BEGIN process_mouse, 0, 0, FN_RET_SCALAR
    call mouse_check_moved
    test al, al
    jnz .pm_have_event
    mov al, [mouse_buttons]
    cmp al, [process_mouse_last_buttons]
    je .pm_done

.pm_have_event:
    mov edi, [mouse_x]
    mov esi, [mouse_y]
    movzx edx, byte [mouse_buttons]
    mov [process_mouse_last_buttons], dl
    ; If context menu is visible and left button just pressed, handle it
    ; before anything else can swallow the click.
    test dl, 1
    jz .pm_no_ctx_consume
    cmp byte [ctx_menu_visible], 0
    je .pm_no_ctx_consume
    call ctx_menu_handle_click
    mov byte [ctx_menu_visible], 0
    mov byte [scene_dirty], 1
    ret
.pm_no_ctx_consume:
    push rdi
    push rsi
    push rdx
    call wm_handle_mouse_event
    mov r15, rax
    pop rdx
    pop rsi
    pop rdi
    test r15, r15
    jnz .pm_set_dirty
    test dl, 1
    jz .pm_check_rclick
    push rdi
    push rsi
    call tb_handle_submenu_click
    pop rsi
    pop rdi
    test eax, eax
    jnz .pm_set_dirty
    push rdx
    push rdi
    push rsi
    call tb_handle_click
    cmp rax, 2
    jl .pm_tb_no_app
    pop rsi
    pop rdi
    pop rdx
    push rdx
    mov rdi, rax
    call app_launch
    jmp .pm_handled_click
.pm_tb_no_app:
    pop rsi
    pop rdi
    test rax, rax
    jnz .pm_handled_click_pop
    mov byte [ctx_menu_visible], 0
    mov byte [sm_submenu_open], 0
    call desktop_handle_click
.pm_handled_click_pop:
    pop rdx
    jmp .pm_set_dirty
.pm_handled_click:
    pop rdx
.pm_set_dirty:
    mov byte [scene_dirty], 1
.pm_done:
    ret
.pm_check_rclick:
    test dl, 2
    jz .pm_no_click
    call tb_handle_rclick
    test eax, eax
    jnz .pm_rclick_done
    call app_show_context_menu
.pm_rclick_done:
    mov byte [scene_dirty], 1
    ret
.pm_no_click:
    cmp qword [wm_drag_window_id], -1
    jne .pm_set_dirty
    cmp byte [vsync_enabled], 1
    jne .pm_skip_vs
    call wait_vsync
.pm_skip_vs:
    call cursor_hide
    mov edi, [mouse_x]
    mov esi, [mouse_y]
    call cursor_draw
    ret

; ============================================================================
; Process keyboard input - sets scene_dirty if needed
; ============================================================================
FN_BEGIN process_keyboard, 0, 0, FN_RET_SCALAR
    call keyboard_read
    test eax, eax
    jz .pk_done
    mov r15d, eax
    mov ecx, eax
    shr ecx, 24
    test cl, cl
    jz .pk_done
    mov bl, al
    mov cl, ah
    cmp byte [kb_numlock], 0
    jne .pk_numlock_on
    cmp bl, 0xC8
    je .pk_key_up
    cmp bl, 0xD0
    je .pk_key_down
    cmp bl, 0xCB
    je .pk_key_left
    cmp bl, 0xCD
    je .pk_key_right
    cmp cl, '*'
    je .pk_key_lclick
    cmp cl, '-'
    je .pk_key_rclick
.pk_numlock_on:
.pk_forward_to_window:
    mov r8, [wm_focused_window]
    cmp r8, -1
    je .pk_done
    mov rax, r8
    imul rax, WINDOW_STRUCT_SIZE
    add rax, WINDOW_POOL_ADDR
    mov r9, [rax + WIN_OFF_KEYFN]
    test r9, r9
    jz .pk_done
    mov rsi, rax
    mov rdi, r9
    mov edx, r15d
    call call_app_l3
.pk_forward_done:
    mov byte [scene_dirty], 1
.pk_done:
    ret
.pk_key_up:
    mov eax, [mouse_y]
    sub eax, 5
    jns .pk_set_y
    xor eax, eax
.pk_set_y:
    mov [mouse_y], eax
    mov byte [mouse_moved], 1
    mov byte [scene_dirty], 1
    ret
.pk_key_down:
    mov eax, [mouse_y]
    add eax, 5
    cmp eax, SCREEN_HEIGHT - 1
    jle .pk_set_y2
    mov eax, SCREEN_HEIGHT - 1
.pk_set_y2:
    mov [mouse_y], eax
    mov byte [mouse_moved], 1
    mov byte [scene_dirty], 1
    ret
.pk_key_left:
    mov eax, [mouse_x]
    sub eax, 5
    jns .pk_set_x
    xor eax, eax
.pk_set_x:
    mov [mouse_x], eax
    mov byte [mouse_moved], 1
    mov byte [scene_dirty], 1
    ret
.pk_key_right:
    mov eax, [mouse_x]
    add eax, 5
    cmp eax, SCREEN_WIDTH - 1
    jle .pk_set_x2
    mov eax, SCREEN_WIDTH - 1
.pk_set_x2:
    mov [mouse_x], eax
    mov byte [mouse_moved], 1
    mov byte [scene_dirty], 1
    ret
.pk_key_lclick:
    mov byte [mouse_buttons], 1
    mov edi, [mouse_x]
    mov esi, [mouse_y]
    call wm_handle_mouse_event
    call tb_handle_click
    cmp rax, 2
    jl .pk_kc_no_app
    mov rdi, rax
    call app_launch
    jmp .pk_kc_handled
.pk_kc_no_app:
    call desktop_handle_click
.pk_kc_handled:
    mov byte [mouse_buttons], 0
    mov edi, [mouse_x]
    mov esi, [mouse_y]
    xor edx, edx
    call wm_handle_mouse_event
    mov byte [scene_dirty], 1
    ret
.pk_key_rclick:
    mov edi, [mouse_x]
    mov esi, [mouse_y]
    call tb_handle_rclick
    test eax, eax
    jnz .pk_kr_done
    call app_show_context_menu
.pk_kr_done:
    mov byte [scene_dirty], 1
    ret

; ============================================================================
; Render one frame
; ============================================================================
render_frame:
    mov rax, [tick_count]
    xor edx, edx
    mov ecx, 30
    div ecx
    and al, 1
    cmp al, [ui_blink_phase]
    je .rf_blink_unchanged
    mov [ui_blink_phase], al
    mov byte [scene_dirty], 1
.rf_blink_unchanged:
    cmp qword [wm_drag_window_id], -1
    jne .rf_draw_drag
    cmp byte [scene_dirty], 0
    je .rf_fast_path
    call wm_draw_desktop
    call tb_draw
    call tb_draw_submenu
    call ctx_menu_draw
    call .rf_update_fps
    call .rf_draw_fps_text
    call render_save_backbuffer
    mov byte [scene_dirty], 0
    cmp byte [vsync_enabled], 1
    jne .fr_skip_full_vs
    call wait_vsync
.fr_skip_full_vs:
    call cursor_hide
    call render_mark_full
    call render_flush
    mov edi, [mouse_x]
    mov esi, [mouse_y]
    call cursor_draw
    ret
.rf_fast_path:
    call .rf_update_fps
    call .rf_restore_fps_region
    call .rf_draw_fps_text
    cmp byte [vsync_enabled], 1
    jne .fr_skip_fast_vs
    call wait_vsync
.fr_skip_fast_vs:
    call cursor_hide
    mov edi, FPS_REGION_X
    mov esi, FPS_REGION_Y
    mov edx, FPS_REGION_W
    mov ecx, FPS_REGION_H
    call display_flip_rect
    mov edi, [mouse_x]
    mov esi, [mouse_y]
    call cursor_draw
    ret
.rf_draw_drag:
    call render_restore_backbuffer
    call wm_draw_drag_outline
    call .rf_update_fps
    call .rf_draw_fps_text
    call render_mark_full
    cmp byte [vsync_enabled], 1
    jne .fr_skip_drag_vs
    call wait_vsync
.fr_skip_drag_vs:
    call cursor_hide
    call render_flush
    mov edi, [mouse_x]
    mov esi, [mouse_y]
    call cursor_draw
    ret

.rf_update_fps:
    inc dword [frame_count]
    mov rax, [tick_count]
    mov rdx, rax
    sub rdx, [start_tick]
    cmp rdx, 100
    jl .rf_fps_no_update
    mov eax, [frame_count]
    mov [last_fps], eax
    mov dword [frame_count], 0
    mov [start_tick], rax
.rf_fps_no_update:
    ret

.rf_draw_fps_text:
    mov edi, [last_fps]
    lea rsi, [fps_str]
    call uint32_to_str
    mov edi, FPS_REGION_X + 4
    mov esi, FPS_REGION_Y + 4
    lea rdx, [szFPSPrefix]
    mov ecx, 0x00FFFFFF
    mov r8d, -1
    call render_text
    ret

.rf_restore_fps_region:
    mov rax, FPS_REGION_Y
    imul rax, [scr_pitch_q]
    add rax, FPS_REGION_X * 4
    mov r8, [bb_addr]
    add r8, rax
    mov r9, BACK_BUFFER_SAVE_ADDR
    add r9, rax
    mov r10, [scr_pitch_q]
    mov r11d, FPS_REGION_H
.rfr_row:
    mov rdi, r8
    mov rsi, r9
    mov ecx, FPS_REGION_W
    rep movsd
    add r8, r10
    add r9, r10
    dec r11d
    jnz .rfr_row
    ret

section .data
szFPSPrefix db "FPS:", 0
fps_str     times 16 db 0

; BSP CPU utilization accounting (see cpu_acct_* routines above).
global bsp_util
bsp_util         dd 0
acct_last_mark   dq 0
acct_work_start  dq 0
acct_busy_acc    dq 0
acct_idle_acc    dq 0
acct_win_tick    dq 0

section .bss
serial_command_armed resb 1
ui_blink_phase resb 1
process_mouse_last_buttons resb 1
