; ============================================================================
; NexusOS v3.0 - Kernel Main (Free-running render loop)
; ============================================================================
bits 64

%include "constants.inc"
%include "macros.inc"

section .text
global kmain
global process_keyboard
global process_mouse
global debug_print
global serial_poll_command

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
extern display_flip
extern wait_vsync
extern vsync_enabled

; Filesystem
extern fat16_init

; Apps
extern app_launch
extern app_show_context_menu
extern ctx_menu_visible

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
debug_print:
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

; --- Kernel Entry ---
kmain:
    extern app_blob_init
    call app_blob_init          ; read loaded APPS.BIN pointer before anyone uses it
    call display_init
    call display_flip

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
    call acpi_init
    call apic_init
    call ioapic_init
    call spi_init
    call spi_hid_init
    
    call usb_hid_init
    call i2c_hid_init
    call fat16_init

%ifdef NEXUS_CACHE32_MAX
    call smp_ap_startup
%endif
    sti
    call perfdiag_init
    call keyboard_init
    call mouse_init

    call render_init
    call cursor_init
    call wm_init
    
    mov byte [gui_initialized], 1
    call render_frame

.infinite:
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
    hlt
    jmp .infinite

; ============================================================================
; serial_poll_command - poll COM1 for serial automation input
;  raw bytes become focused-window keypresses
;  0x01 + '2'..'7' launches app IDs directly
;  0x01 + 'x' closes the focused window
; ============================================================================
serial_poll_command:
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
    cmp al, '7'
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
process_mouse:
    call mouse_check_moved
    test al, al
    jz .pm_done

    mov edi, [mouse_x]
    mov esi, [mouse_y]
    movzx edx, byte [mouse_buttons]
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
process_keyboard:
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
    cmp qword [wm_drag_window_id], -1
    jne .rf_draw_drag
    cmp byte [scene_dirty], 0
    je .rf_fast_path
    call wm_draw_desktop
    call desktop_draw_icons
    call tb_draw
    call tb_draw_submenu
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
    mov eax, FPS_REGION_Y
    imul eax, [scr_pitch]
    add eax, FPS_REGION_X * 4
    mov r8, [bb_addr]
    add r8, rax
    mov r9, BACK_BUFFER_SAVE_ADDR
    add r9, rax
    movsxd r10, dword [scr_pitch]
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

section .bss
serial_command_armed resb 1
