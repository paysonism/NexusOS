; ============================================================================
; NexusOS v3.0 - Kernel Main (Free-running render loop)
; ============================================================================
bits 64

%include "constants.inc"
%include "macros.inc"
; smap.inc is included by usermode.asm too, but that include is reached AFTER
; main.asm in the monolithic build, so pull it in here for the USER_ACCESS_*
; macros used by the media live-refresh scanner below. The SMAP_INC guard makes
; the later includes no-ops; this becomes the sole definition of smap_smep_init.
%include "smap.inc"
; CET (security_todo.md §3): SHSTK/IBT detection (always) + the gated hardware
; enable scaffold. Included here in main.asm so cet_detect/cet_enable have a
; single definition site in the monolithic build, mirroring smap.inc above.
%include "cet.inc"

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
extern perfdiag_print_pci_gpu
extern perfdiag_benchmark
extern fbperf_init_done
extern fbperf_pat_msr
extern fbperf_mtrrcap
extern fbperf_mtrr_def_type
extern fbperf_mtrr_var_count
extern fbperf_mtrr_var
extern fbperf_fb_pte_value
extern fbperf_fb_pte_level
extern fbperf_fb_caching_type
extern fbperf_wc_plan_pat
extern fbperf_wc_armed
extern fbperf_wc_activated
extern fbperf_cr4
extern fbperf_cpuid_pat_supported
extern fbperf_flips_total
extern fbperf_full_flips
extern fbperf_rect_flips
extern fbperf_full_bytes
extern fbperf_tsc_total
extern fbperf_tsc_min
extern fbperf_tsc_max
extern fbperf_tsc_last
extern fbperf_bytes_total
extern fbperf_rect_bytes
extern trace_dump_serial
extern memory_init

; Drivers
extern mouse_init
extern usb_hid_init
extern usb_hid_flush_log
extern i2c_hid_init
extern i2c_hid_poll
extern i2c_hid_debug_dump
extern i2c_hid_debug_dump_line
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
extern rtl8139_init
extern rtl8139_icmp_ping_gateway
extern rtl8139_icmp_ping_ics
extern net_ping_ipv4
extern pci_gpu_scan
extern pci_gpu_count
extern pci_gpu_radeon780m_found
extern pci_gpu_radeon780m_bdf
extern pci_gpu_radeon780m_id
extern pci_gpu_radeon780m_class
extern pci_gpu_radeon780m_bar0
extern pci_gpu_radeon780m_cmd
extern pci_gpu_amd_display_found
extern pci_gpu_amd_display_bdf
extern pci_gpu_amd_display_id
extern pci_gpu_amd_display_class
extern amd_display_active
extern amd_display_status
extern amd_display_bdf
extern amd_display_id
extern amd_display_class
extern amd_display_fb_addr
extern amd_display_mode_w
extern amd_display_mode_h
extern amd_display_mode_pitch
extern amd_display_mode_bpp
; --- USB-mouse debug overlay data sources ---
extern xhci_active, xhci_port_num, xhci_port_speed, xhci_slot_id
extern init_retry_counter, usb_slot1_id, usb_slot2_active
extern usb_ep_addr, usb_ep_mps, usb_hid_protocol
extern usb_dbg_evt, usb_dbg_rpt, usb_dbg_err, usb_dbg_errcode, usb_dbg_report
extern usb_dbg_stage
extern usb_dbg_stage_max
extern xhci_op_base, xhci_max_ports
extern pci_read_conf_dword, pci_write_conf_dword
extern xhci_initlog_n, xhci_initlog
extern xhci_dbg_fp_n, xhci_dbg_fp
extern xhci_dbg_addrn, xhci_dbg_addrcc, xhci_scratchpad_count, xhci_scratchpad_req
extern xhci_dbg_adstage, xhci_dbg_adcc1, xhci_dbg_adcc2, xhci_dbg_portsc
extern xhci_dbg_rststage, xhci_dbg_portsc_pre, xhci_dbg_portsc_post
extern xhci_dbg_speed_pre, xhci_dbg_speed_post, xhci_dbg_ped_ok, xhci_dbg_ccs_ok
extern xhci_dbg_slotstate, xhci_dbg_portsc_written, xhci_dbg_portsc_immed
extern xhci_dbg_portsc_wait, xhci_dbg_reset_polls
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
extern smp_core_states
extern cpu_tsc_per_tick
extern app_hl_taskmgr_draw
extern app_media_draw
extern media_draw_dispatch
extern app_hl_media_mp_paused
extern app_blob_start

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
extern render_restore_dirty_backbuffer
extern render_mark_dirty
extern render_save_backbuffer
extern render_save_dirty_backbuffer
extern display_flip_rect
extern call_app_l3
extern dispatch_app_callback           ; Stage 2d cross-core chokepoint
extern cpi_verify_callback             ; CPI-lite: validate tagged callback ptrs
extern media_direct_present
extern media_direct_presented
extern l3_slot_base
extern bb_addr
extern fb_addr
extern scr_pitch
extern scr_pitch_q
extern display_flip
extern wait_vsync
extern vsync_enabled
extern fb_native_width
extern fb_native_height

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

APP_SLOT_BMP_FILE_OFF equ 0x17D000
NBA1_MAGIC            equ 0x3141424E

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
global main_loop_stage, main_loop_stage_done, main_loop_iters
main_loop_stage      db 0    ; stage we are about to enter
main_loop_stage_done db 0    ; last stage that completed
main_loop_iters      dd 0    ; full iterations of the .infinite loop
global scene_dirty
scene_dirty db 1
rf_last_mouse_x dd 0xFFFFFFFF
rf_last_mouse_y dd 0xFFFFFFFF
rf_last_fps     dd 0xFFFFFFFF

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

    ; Always capture the message in the kernel log ring buffer, regardless of
    ; whether the framebuffer is available or the GUI has started. This is the
    ; data source for the F12 overlay and the (future) USB MSC log flush.
    extern klog_write
    call klog_write

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
; usb_debug_overlay - draw USB-mouse driver diagnostics over the GUI.
; Rendered straight into the backbuffer; the overlay rect is then flipped to
; screen every frame so it survives fast-path frames. Debug aid only.
; ============================================================================
%define OVL_X   8
%define OVL_Y   56
%define OVL_W   760
%define OVL_H   320
usb_debug_overlay:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    push r9
    push r10

    cmp qword [bb_addr], 0
    je .uo_done

    ; line 1: controller / mouse-active state
    lea rdi, [ovl_buf]
    lea rsi, [s_o_l1]
    call ovl_puts
    movzx edx, byte [xhci_active]
    call ovl_putu
    lea rsi, [s_o_noxhci]
    call ovl_puts
    movzx edx, byte [usb_no_xhci]
    call ovl_putu
    lea rsi, [s_o_mact]
    call ovl_puts
    movzx edx, byte [usb_mouse_active]
    call ovl_putu
    lea rsi, [s_o_retry]
    call ovl_puts
    mov edx, [init_retry_counter]
    call ovl_putu
    lea rsi, [s_o_stage]
    call ovl_puts
    movzx edx, byte [usb_dbg_stage]
    call ovl_putu
    lea rsi, [s_o_stagemax]
    call ovl_puts
    movzx edx, byte [usb_dbg_stage_max]
    call ovl_putu
    lea rsi, [s_o_fpn]
    call ovl_puts
    movzx edx, byte [xhci_dbg_fp_n]
    call ovl_putu
    mov byte [rdi], 0
    mov edi, OVL_X
    mov esi, OVL_Y
    lea rdx, [ovl_buf]
    mov ecx, 0x0000FF00
    mov r8d, 0x00101010
    call render_text

    ; line 2: port / speed / slot
    lea rdi, [ovl_buf]
    lea rsi, [s_o_port]
    call ovl_puts
    movzx edx, byte [xhci_port_num]
    call ovl_putu
    lea rsi, [s_o_spd]
    call ovl_puts
    movzx edx, byte [xhci_port_speed]
    call ovl_putu
    lea rsi, [s_o_slot]
    call ovl_puts
    movzx edx, byte [usb_slot1_id]
    call ovl_putu
    lea rsi, [s_o_s2]
    call ovl_puts
    movzx edx, byte [usb_slot2_active]
    call ovl_putu
    lea rsi, [s_o_hwslot]
    call ovl_puts
    movzx edx, byte [xhci_slot_id]
    call ovl_putu
    mov byte [rdi], 0
    mov edi, OVL_X
    mov esi, OVL_Y + 16
    lea rdx, [ovl_buf]
    mov ecx, 0x00FFFFFF
    mov r8d, 0x00101010
    call render_text

    ; line 3: endpoint addr / mps / protocol
    lea rdi, [ovl_buf]
    lea rsi, [s_o_ep]
    call ovl_puts
    movzx edx, byte [usb_ep_addr]
    call ovl_putu
    lea rsi, [s_o_mps]
    call ovl_puts
    movzx edx, word [usb_ep_mps]
    call ovl_putu
    lea rsi, [s_o_proto]
    call ovl_puts
    movzx edx, byte [usb_hid_protocol]
    call ovl_putu
    mov byte [rdi], 0
    mov edi, OVL_X
    mov esi, OVL_Y + 32
    lea rdx, [ovl_buf]
    mov ecx, 0x00FFFFFF
    mov r8d, 0x00101010
    call render_text

    ; line 4: event / report / error counters
    lea rdi, [ovl_buf]
    lea rsi, [s_o_evt]
    call ovl_puts
    mov edx, [usb_dbg_evt]
    call ovl_putu
    lea rsi, [s_o_rpt]
    call ovl_puts
    mov edx, [usb_dbg_rpt]
    call ovl_putu
    lea rsi, [s_o_err]
    call ovl_puts
    mov edx, [usb_dbg_err]
    call ovl_putu
    lea rsi, [s_o_ec]
    call ovl_puts
    movzx edx, byte [usb_dbg_errcode]
    call ovl_putu
    lea rsi, [s_o_adn]
    call ovl_puts
    movzx edx, byte [xhci_dbg_addrn]
    call ovl_putu
    lea rsi, [s_o_adcc]
    call ovl_puts
    movzx edx, byte [xhci_dbg_addrcc]
    call ovl_putu
    lea rsi, [s_o_scr]
    call ovl_puts
    movzx edx, word [xhci_scratchpad_count]
    call ovl_putu
    lea rsi, [s_o_scr_req]
    call ovl_puts
    movzx edx, word [xhci_scratchpad_req]
    call ovl_putu
    mov byte [rdi], 0
    mov edi, OVL_X
    mov esi, OVL_Y + 48
    lea rdx, [ovl_buf]
    mov ecx, 0x0000FFFF
    mov r8d, 0x00101010
    call render_text

    ; line 4b: Address Device sub-stage and PORTSC snapshot (real-HW debug)
    lea rdi, [ovl_buf]
    lea rsi, [s_o_adst_h]         ; "adSt="
    call ovl_puts
    movzx edx, byte [xhci_dbg_adstage]
    call ovl_putu
    lea rsi, [s_o_cc1]
    call ovl_puts
    movzx edx, byte [xhci_dbg_adcc1]
    call ovl_putu
    lea rsi, [s_o_cc2]
    call ovl_puts
    movzx edx, byte [xhci_dbg_adcc2]
    call ovl_putu
    lea rsi, [s_o_portsc]
    call ovl_puts
    mov edx, [xhci_dbg_portsc]
    call ovl_puth32
    lea rsi, [s_o_slotst]
    call ovl_puts
    movzx edx, byte [xhci_dbg_slotstate]
    call ovl_putu
    mov byte [rdi], 0
    mov edi, OVL_X
    mov esi, OVL_Y + 64
    lea rdx, [ovl_buf]
    mov ecx, 0x0000FFFF
    mov r8d, 0x00101010
    call render_text

    ; line 4c: port-reset granular debug
    lea rdi, [ovl_buf]
    lea rsi, [s_o_rst_h]
    call ovl_puts
    movzx edx, byte [xhci_dbg_rststage]
    call ovl_putu
    lea rsi, [s_o_ped]
    call ovl_puts
    movzx edx, byte [xhci_dbg_ped_ok]
    call ovl_putu
    lea rsi, [s_o_ccs]
    call ovl_puts
    movzx edx, byte [xhci_dbg_ccs_ok]
    call ovl_putu
    lea rsi, [s_o_sppre]
    call ovl_puts
    movzx edx, byte [xhci_dbg_speed_pre]
    call ovl_putu
    lea rsi, [s_o_sppost]
    call ovl_puts
    movzx edx, byte [xhci_dbg_speed_post]
    call ovl_putu
    lea rsi, [s_o_pscpre]
    call ovl_puts
    mov edx, [xhci_dbg_portsc_pre]
    call ovl_puth32
    lea rsi, [s_o_pscpost]
    call ovl_puts
    mov edx, [xhci_dbg_portsc_post]
    call ovl_puth32
    mov byte [rdi], 0
    mov edi, OVL_X
    mov esi, OVL_Y + 80
    lea rdx, [ovl_buf]
    mov ecx, 0x00FF8800
    mov r8d, 0x00101010
    call render_text

    ; line 4d: reset-write granular trace - did write take, mid-wait state, polls
    lea rdi, [ovl_buf]
    lea rsi, [s_o_wrt]
    call ovl_puts
    mov edx, [xhci_dbg_portsc_written]
    call ovl_puth32
    lea rsi, [s_o_imm]
    call ovl_puts
    mov edx, [xhci_dbg_portsc_immed]
    call ovl_puth32
    lea rsi, [s_o_wait]
    call ovl_puts
    mov edx, [xhci_dbg_portsc_wait]
    call ovl_puth32
    lea rsi, [s_o_polls]
    call ovl_puts
    mov edx, [xhci_dbg_reset_polls]
    call ovl_putu
    mov byte [rdi], 0
    mov edi, OVL_X
    mov esi, OVL_Y + 96
    lea rdx, [ovl_buf]
    mov ecx, 0x00FFAA44
    mov r8d, 0x00101010
    call render_text

    ; line 5: last raw report bytes (b1/b2 = signed dX/dY)
    lea rdi, [ovl_buf]
    lea rsi, [s_o_r0]
    call ovl_puts
    movzx edx, byte [usb_dbg_report]
    call ovl_putu
    lea rsi, [s_o_r1]
    call ovl_puts
    movsx edx, byte [usb_dbg_report + 1]
    call ovl_puti
    lea rsi, [s_o_r2]
    call ovl_puts
    movsx edx, byte [usb_dbg_report + 2]
    call ovl_puti
    lea rsi, [s_o_r3]
    call ovl_puts
    movzx edx, byte [usb_dbg_report + 3]
    call ovl_putu
    mov byte [rdi], 0
    mov edi, OVL_X
    mov esi, OVL_Y + 112
    lea rdx, [ovl_buf]
    mov ecx, 0x00FFFF00
    mov r8d, 0x00101010
    call render_text

    ; touchpad (I2C-HID) status lines, kept short to avoid overlay clipping.
    lea rdi, [ovl_buf]
    xor eax, eax
    call i2c_hid_debug_dump_line
    mov edi, OVL_X
    mov esi, OVL_Y + 128
    lea rdx, [ovl_buf]
    mov ecx, 0x0000FF88
    mov r8d, 0x00101010
    call render_text

    lea rdi, [ovl_buf]
    mov eax, 1
    call i2c_hid_debug_dump_line
    mov edi, OVL_X
    mov esi, OVL_Y + 144
    lea rdx, [ovl_buf]
    mov ecx, 0x0000FF88
    mov r8d, 0x00101010
    call render_text

    lea rdi, [ovl_buf]
    mov eax, 2
    call i2c_hid_debug_dump_line
    mov edi, OVL_X
    mov esi, OVL_Y + 160
    lea rdx, [ovl_buf]
    mov ecx, 0x0000FF88
    mov r8d, 0x00101010
    call render_text

    ; --- Crash detector: main-loop liveness ---
    ; If the main loop hangs, iters stops counting and stage/done tell you
    ; which call in the loop body is wedged (stage = entering, done = last
    ; completed). The overlay only refreshes when the loop reaches stage 4,
    ; so a frozen snapshot here IS the diagnostic.
    lea rdi, [ovl_buf]
    lea rsi, [s_o_ml_iters]
    call ovl_puts
    mov edx, [main_loop_iters]
    call ovl_putu
    lea rsi, [s_o_ml_stage]
    call ovl_puts
    movzx edx, byte [main_loop_stage]
    call ovl_putu
    lea rsi, [s_o_ml_done]
    call ovl_puts
    movzx edx, byte [main_loop_stage_done]
    call ovl_putu
    lea rsi, [s_o_ml_tick]
    call ovl_puts
    mov edx, [tick_count]
    call ovl_putu
    mov byte [rdi], 0
    mov edi, OVL_X
    mov esi, OVL_Y + 304
    lea rdx, [ovl_buf]
    mov ecx, 0x00FF4040
    mov r8d, 0x00101010
    call render_text

    ; lines 8+: PCI xHCI controller inventory (scanned once)
    ;   map digit = USB speed code per port: 1=Full 2=Low 3=High 4=SS 5=SS+
    call usb_dbg_pci_scan
    cmp byte [usb_dbg_xhci_n], 0
    jne .uo_have_ctrls
    lea rdi, [ovl_buf]
    lea rsi, [s_o_noctrl]
    call ovl_puts
    mov byte [rdi], 0
    mov edi, OVL_X
    mov esi, OVL_Y + 176
    lea rdx, [ovl_buf]
    mov ecx, 0x00FF00FF
    mov r8d, 0x00101010
    call render_text
    jmp .uo_initlog

.uo_have_ctrls:
    mov dword [ovl_ci], 0
.uo_ctrl_loop:
    mov eax, [ovl_ci]
    cmp al, [usb_dbg_xhci_n]
    jae .uo_initlog
    cmp eax, 4
    jae .uo_initlog
    ; record ptr = usb_dbg_xhci_rec + ci*64
    shl eax, 6
    lea r11, [usb_dbg_xhci_rec]
    add r11, rax
    mov [ovl_rec], r11

    lea rdi, [ovl_buf]
    lea rsi, [s_o_ctrl]
    call ovl_puts
    mov edx, [ovl_ci]
    call ovl_putu
    lea rsi, [s_o_cbus]
    call ovl_puts
    mov r11, [ovl_rec]
    movzx edx, byte [r11 + 0]
    call ovl_putu
    lea rsi, [s_o_cdev]
    call ovl_puts
    mov r11, [ovl_rec]
    movzx edx, byte [r11 + 1]
    call ovl_putu
    lea rsi, [s_o_cfn]
    call ovl_puts
    mov r11, [ovl_rec]
    movzx edx, byte [r11 + 2]
    call ovl_putu
    lea rsi, [s_o_cports]
    call ovl_puts
    mov r11, [ovl_rec]
    movzx edx, byte [r11 + 3]
    call ovl_putu
    lea rsi, [s_o_cmap]
    call ovl_puts
    ; append per-port speed map
    mov r11, [ovl_rec]
    movzx ecx, byte [r11 + 3]
    xor ebx, ebx
.uo_cmap:
    cmp ebx, ecx
    jge .uo_cmap_done
    cmp ebx, 24
    jge .uo_cmap_done
    movzx eax, byte [r11 + rbx + 4]
    test eax, eax
    jz .uo_cmap_empty
    add al, '0'
    mov [rdi], al
    inc rdi
    jmp .uo_cmap_next
.uo_cmap_empty:
    mov byte [rdi], '.'
    inc rdi
.uo_cmap_next:
    inc ebx
    jmp .uo_cmap
.uo_cmap_done:
    mov byte [rdi], 0
    mov edi, OVL_X
    mov eax, [ovl_ci]
    shl eax, 4
    add eax, OVL_Y + 176
    mov esi, eax
    lea rdx, [ovl_buf]
    mov ecx, 0x00FF00FF
    mov r8d, 0x00101010
    call render_text
    inc dword [ovl_ci]
    jmp .uo_ctrl_loop

.uo_initlog:
    ; xhci_init per-controller progress log
    ;   stage: 1=pciFound 2=capsRead 3=ownership 4=reset 5=ringsUp 6=running
    mov dword [ovl_li], 0
.uo_il_loop:
    mov eax, [ovl_li]
    cmp al, [xhci_initlog_n]
    jae .uo_fplog
    cmp eax, 8
    jae .uo_fplog
    shl eax, 2
    lea r11, [xhci_initlog]
    add r11, rax
    mov [ovl_rec], r11
    lea rdi, [ovl_buf]
    lea rsi, [s_o_init]
    call ovl_puts
    mov edx, [ovl_li]
    call ovl_putu
    lea rsi, [s_o_cbus]
    call ovl_puts
    mov r11, [ovl_rec]
    movzx edx, byte [r11 + 0]
    call ovl_putu
    lea rsi, [s_o_cdev]
    call ovl_puts
    mov r11, [ovl_rec]
    movzx edx, byte [r11 + 1]
    call ovl_putu
    lea rsi, [s_o_cfn]
    call ovl_puts
    mov r11, [ovl_rec]
    movzx edx, byte [r11 + 2]
    call ovl_putu
    lea rsi, [s_o_istage]
    call ovl_puts
    mov r11, [ovl_rec]
    movzx edx, byte [r11 + 3]
    call ovl_putu
    mov byte [rdi], 0
    mov edi, OVL_X
    mov eax, [ovl_li]
    shl eax, 4
    add eax, OVL_Y + 240
    mov esi, eax
    lea rdx, [ovl_buf]
    mov ecx, 0x0000FFFF
    mov r8d, 0x00101010
    call render_text
    inc dword [ovl_li]
    jmp .uo_il_loop

.uo_fplog:
    ; xhci_find_port snapshots: ports it scanned + speed map it saw + result
    ;   result: 1=found 0=none 255=never returned
    mov dword [ovl_li], 0
.uo_fp_loop:
    mov eax, [ovl_li]
    cmp al, [xhci_dbg_fp_n]
    jae .uo_flip
    cmp eax, 4
    jae .uo_flip
    shl eax, 4
    lea r11, [xhci_dbg_fp]
    add r11, rax
    mov [ovl_rec], r11
    lea rdi, [ovl_buf]
    lea rsi, [s_o_fp]
    call ovl_puts
    mov edx, [ovl_li]
    call ovl_putu
    lea rsi, [s_o_fmp]
    call ovl_puts
    mov r11, [ovl_rec]
    movzx edx, byte [r11 + 4]
    call ovl_putu
    lea rsi, [s_o_fr]
    call ovl_puts
    mov r11, [ovl_rec]
    movzx edx, byte [r11 + 5]
    call ovl_putu
    lea rsi, [s_o_fmap]
    call ovl_puts
    mov r11, [ovl_rec]
    xor ebx, ebx
.uo_fpmap:
    cmp ebx, 10
    jge .uo_fpmap_done
    movzx eax, byte [r11 + rbx + 6]
    test eax, eax
    jz .uo_fpmap_e
    add al, '0'
    mov [rdi], al
    inc rdi
    jmp .uo_fpmap_n
.uo_fpmap_e:
    mov byte [rdi], '.'
    inc rdi
.uo_fpmap_n:
    inc ebx
    jmp .uo_fpmap
.uo_fpmap_done:
    mov byte [rdi], 0
    mov edi, OVL_X
    movzx eax, byte [xhci_initlog_n]
    add eax, [ovl_li]
    shl eax, 4
    add eax, OVL_Y + 256
    mov esi, eax
    lea rdx, [ovl_buf]
    mov ecx, 0x0000FF00
    mov r8d, 0x00101010
    call render_text
    inc dword [ovl_li]
    jmp .uo_fp_loop

.uo_flip:
    ; flip the overlay rect to the visible screen
    mov edi, OVL_X
    mov esi, OVL_Y
    mov edx, OVL_W
    mov ecx, OVL_H
    call display_flip_rect

.uo_done:
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; rsi = src (null-terminated), rdi = dest cursor -> rdi advanced (no null)
ovl_puts:
    push rax
.l: mov al, [rsi]
    test al, al
    jz .e
    mov [rdi], al
    inc rsi
    inc rdi
    jmp .l
.e: pop rax
    ret

; edx = unsigned value, rdi = dest cursor -> appends decimal, rdi advanced
ovl_putu:
    push rax
    push rsi
    push rdi
    mov rsi, rdi
    mov edi, edx
    call uint32_to_str
    pop rdi
.a: cmp byte [rdi], 0
    je .d
    inc rdi
    jmp .a
.d: pop rsi
    pop rax
    ret

; edx = signed value, rdi = dest cursor -> appends signed decimal
ovl_puti:
    test edx, edx
    jns ovl_putu
    mov byte [rdi], '-'
    inc rdi
    neg edx
    jmp ovl_putu

; edx = u32 value, rdi = dest cursor -> appends 8-char uppercase hex
ovl_puth32:
    push rax
    push rcx
    mov ecx, 8
.lp:
    rol edx, 4
    mov eax, edx
    and eax, 0x0F
    cmp eax, 10
    jl .dig
    add eax, 'A' - 10
    jmp .st
.dig:
    add eax, '0'
.st:
    mov [rdi], al
    inc rdi
    dec ecx
    jnz .lp
    pop rcx
    pop rax
    ret

; ============================================================================
; usb_dbg_pci_scan - one-time PCI bus scan for every xHCI controller
; (class 0x0C0330). Fills usb_dbg_xhci_rec / usb_dbg_xhci_n. No-op after the
; first call. Enables Memory Space decode so root-port registers are readable.
; ============================================================================
usb_dbg_pci_scan:
    cmp byte [usb_dbg_pci_done], 0
    jne .ds_ret
    mov byte [usb_dbg_pci_done], 1
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15

    xor r12d, r12d                ; controller count
    xor r8d, r8d                  ; bus
.ds_bus:
    cmp r8d, 256
    jge .ds_done
    xor r9d, r9d                  ; dev
.ds_dev:
    cmp r9d, 32
    jge .ds_bus_next
    xor r10d, r10d                ; fn
.ds_fn:
    cmp r10d, 8
    jge .ds_dev_next
    ; packed config address (reg 0)
    mov eax, r8d
    shl eax, 16
    mov ecx, r9d
    shl ecx, 11
    or eax, ecx
    mov ecx, r10d
    shl ecx, 8
    or eax, ecx
    mov r11d, eax                 ; r11 = packed base
    call pci_read_conf_dword
    cmp eax, 0xFFFFFFFF
    je .ds_fn_next
    ; class code at reg 0x08, want base=0C sub=03 progIF=30
    mov eax, r11d
    or eax, 0x08
    call pci_read_conf_dword
    shr eax, 8
    and eax, 0x00FFFFFF
    cmp eax, 0x0C0330
    jne .ds_fn_next
    cmp r12d, 4
    jge .ds_fn_next
    ; record ptr = usb_dbg_xhci_rec + count*64
    mov eax, r12d
    shl eax, 6
    lea r13, [usb_dbg_xhci_rec]
    add r13, rax
    mov [r13 + 0], r8b
    mov [r13 + 1], r9b
    mov [r13 + 2], r10b
    mov byte [r13 + 3], 0
    ; enable Memory Space + Bus Master (command reg 0x04, bits 1+2)
    mov eax, r11d
    or eax, 0x04
    call pci_read_conf_dword
    mov ecx, eax
    or ecx, 0x06
    mov eax, r11d
    or eax, 0x04
    call pci_write_conf_dword
    ; BAR0 (reg 0x10)
    mov eax, r11d
    or eax, 0x10
    call pci_read_conf_dword
    mov r14d, eax                 ; raw BAR0
    mov ebx, eax
    and ebx, 0xFFFFFFF0
    mov r15, rbx                  ; MMIO base (low 32)
    test r14d, 0x04               ; 64-bit BAR?
    jz .ds_bar32
    mov eax, r11d
    or eax, 0x14
    call pci_read_conf_dword
    shl rax, 32
    or r15, rax
.ds_bar32:
    test r15, r15
    jz .ds_store
    ; CAPLENGTH = byte 0, sanity 1..0x40
    movzx ecx, byte [r15]
    test ecx, ecx
    jz .ds_store
    cmp ecx, 0x40
    ja .ds_store
    ; HCSPARAMS1 at +4, MaxPorts = bits[31:24]
    mov edx, [r15 + 4]
    shr edx, 24
    and edx, 0xFF
    test edx, edx
    jz .ds_store
    cmp edx, 60
    ja .ds_store
    mov [r13 + 3], dl
    ; port register base = MMIO + CAPLENGTH + 0x400
    lea rsi, [r15 + rcx]
    add rsi, 0x400
    xor edi, edi                  ; port index
.ds_port:
    cmp edi, edx
    jge .ds_store
    mov eax, edi
    shl eax, 4
    mov eax, [rsi + rax]          ; PORTSC
    xor ecx, ecx
    test eax, 1                   ; CCS
    jz .ds_port_w
    mov ecx, eax
    shr ecx, 10
    and ecx, 0x0F                 ; speed code
.ds_port_w:
    mov [r13 + rdi + 4], cl
    inc edi
    jmp .ds_port
.ds_store:
    inc r12d
.ds_fn_next:
    inc r10d
    jmp .ds_fn
.ds_dev_next:
    inc r9d
    jmp .ds_dev
.ds_bus_next:
    inc r8d
    jmp .ds_bus
.ds_done:
    mov [usb_dbg_xhci_n], r12b
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
.ds_ret:
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
    call memory_init
%ifdef ENABLE_SMAP
    ; Kernel/user boundary hardening: enable CR4.SMEP/SMAP now that the page
    ; tables (and their PTE.U bits) are live but before any ring-3 entry.
    ; CPUID-gated inside; APs mirror CR4 from the BSP in apic.asm. Every
    ; intentional user-pointer deref is bracketed by USER_ACCESS_BEGIN/END.
    ; smap_smep_init is defined by the smap.inc include at the top of this file.
    call smap_smep_init
%endif
    ; CET detection (security_todo.md §3): record SHSTK (CPUID(7,0).ECX bit 7)
    ; and IBT (EDX bit 20) into cet_have_shstk/cet_have_ibt. Always run — it is
    ; a cheap CPUID probe with no side effects, and it is the inventory the
    ; gated cet_enable (and a future attestation syscall) consults. Under QEMU
    ; TCG (qemu64) neither bit is reported, so cet_enable below stays inert.
    call cet_detect
%ifdef ENABLE_CET
    ; Hardware CET enable scaffold (gated; OFF by default). No-op unless SHSTK
    ; was just detected. Establishes CR4.CET + IA32_S_CET without arming the
    ; supervisor shadow-stack RET-check (that needs a seeded PL0_SSP — the
    ; documented follow-up); the portable software shadow stack in
    ; shadow_stack.inc remains the active kernel-ROP defense meanwhile.
    call cet_enable
%endif
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
    extern kernel_canary_init
    extern slot_cap_hmac_init
    extern l3_install_syscall_stack_pt
    call gdt64_init
    call tss_init
    call kernel_canary_init
    ; Seed the per-slot capability-mask HMACs now that kernel_canary holds its
    ; final value. slot_cap_mask[] is statically CAP_ALL; the matching HMAC
    ; cannot be assembled in (the canary key is runtime-only), so stamp every
    ; slot's authenticator here before any syscall can read the mask.
    call slot_cap_hmac_init
    ; Measured boot (security_todo.md §9): fold every loaded boot stage
    ; (kernel image + app blob) into a kernel-owned measurement chain and
    ; publish the digest to mb_digest. Done now — after the canary is final
    ; and before any ring-3 entry — so the measurement reflects the image as
    ; launched. Kernel-only storage; a sealed attestation syscall is a follow-up.
    extern measured_boot_init
    call measured_boot_init
    ; Sign the user blob (security_todo.md §9): verify the kernel-held-key MAC
    ; over [app_blob_base_v, +app_blob_size_v) against the build-time expected
    ; MAC before any app can launch. Fails closed (kernel_panic_canary) on a
    ; tampered/corrupted/truncated blob. Runs here — after the blob extent is
    ; known (app_blob_init above) and before the first ring-3 entry. See the
    ; threat-model section in docs/STATUS.md for why a symmetric MAC suffices.
    extern app_blob_verify_signature
    call app_blob_verify_signature
    ; Split the PDE covering l3_syscall_stacks into 4 KiB pages and punch
    ; per-slot guard pages BEFORE the first syscall path is wired up.
    call l3_install_syscall_stack_pt
%ifdef ENABLE_SHADOW_STACK_POC
    ; Build-gated shadow-stack proof harness. Runs a protected frame on the
    ; now-mapped slot-0 syscall stack, smashes its return address, and expects
    ; KEPILOGUE to trap to kernel_panic_shadow ("SHADOW ..." + halt). Never
    ; present in release builds.
    extern shadow_stack_poc_run
    call shadow_stack_poc_run
%endif
    call syscall_init

    extern scheduler_init
    call scheduler_init
    call pic_init
    call pit_init

    ; Enable interrupts early so the boot splash has a PIT tick to time frames
    ; with and a keyboard IRQ to be skipped by.
    sti
    ; Register the UEFI-provided DATA.IMG ramdisk (if any) BEFORE fat16_init
    ; so the FS driver's first sector reads go to RAM on real hardware.
    ; No-op on BIOS boot or when the loader did not find DATA.IMG.
    extern ramdisk_init
    call ramdisk_init
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
    call rtl8139_init

    ; Do not run network self-tests before the GUI. The RTL8156 path probes
    ; USB ports and can disturb HID devices when no USB NIC is attached.
    ; Network drivers are still available through their normal lazy paths.
    call usb_hid_init
    call usb_hid_flush_log
    call i2c_hid_init

    ; rtl8156_init's xhci_flush_events drained the mouse's pending Transfer
    ; Events along with its own. The 4 initial reads queued by usb_hid_init
    ; completed before flush, but their completion events were dropped — so
    ; usb_poll_mouse never sees them and never re-queues, killing the mouse.
    ; Re-prime the slot1 interrupt ring now that the NIC is done flushing.
    ; Also restores xhci_slot_id / xhci_int_ep_dci which rtl8156 overwrote.
    extern usb_hid_requeue_slot1_reads
    call usb_hid_requeue_slot1_reads

    ; Driver capability gates + MMIO bounds policy (security_todo.md §8): now
    ; that apic_init resolved lapic_base and the xHCI probe resolved
    ; xhci_mmio_base, declare each driver's reachable-region descriptor into the
    ; kernel-owned MMIO registry. From here on, instrumented driver MMIO sites
    ; call mmio_bounds_assert against this same registry and panic fail-closed
    ; on an out-of-BAR access. mmio_bounds.inc is included via memory.asm.
    extern mmio_drv_caps_init
    call mmio_drv_caps_init

    ; SMP work queue must be initialised BEFORE the APs are started: workers
    ; gate on workqueue_ready, so init first guarantees they see a clean queue.
    extern workqueue_init
    extern workqueue_selftest
    call workqueue_init

%ifdef NEXUS_SMP
    call smp_ap_startup
%endif
    call workqueue_selftest
    call perfdiag_init
    extern fbperf_init
    extern fbperf_serial_dump
    extern fbperf_arm_wc
    extern fbperf_wc_activate
    SER 'a'
    call fbperf_init
    SER 'b'
    call fbperf_serial_dump     ; snapshot 1: pre-activation
    SER 'c'

    ; Single-boot WC arm + activate. Activate returns rax: 0=ok, -1=disarmed,
    ; -2=not mapped, -3=leaf at PML4. Halt on non-zero so we don't continue blind.
    ; Define FBPERF_NO_WC at assemble time (`-DFBPERF_NO_WC`) to keep the WB/UC
    ; baseline for Phase A perf measurement -- skips arm+activate, leaves the
    ; FB on whatever the firmware mapped (typically WB).
%ifndef FBPERF_NO_WC
    call fbperf_arm_wc
    call fbperf_wc_activate
%else
    xor  eax, eax                  ; pretend activate returned 0 so the same
                                   ; log line/jump structure still works
%endif
    mov  r15, rax               ; preserve return code across calls
    lea  rdi, [s_wcact_tag]
    call serial_puts
    mov  rdi, r15
    call ser_print_hex64
    call serial_crlf
    test r15, r15
    jnz  .wcact_failed

    SER 'd'
    call fbperf_init            ; refresh page-walk + MSR snapshots after WC patch
    call fbperf_serial_dump     ; snapshot 2: post-activation (verify wc_activated=1, cache=1)
    SER 'e'
    jmp  .wcact_done

.wcact_failed:
    lea  rdi, [s_wcact_fail]
    call serial_puts
    call serial_crlf
    ; also re-dump so we can see fb_pte_level / addr that caused the fail
    call fbperf_serial_dump
.wcact_halt:
    cli
    hlt
    jmp  .wcact_halt

.wcact_done:
    call mouse_init
    call battery_init           ; probe EC, set bat_layout + state for taskbar

    call render_init
    call cursor_init
    call wm_init
    ; Wallpapers are NOT prewarmed here: the desktop boots with a solid
    ; background and only rasterizes an SVG wallpaper once one is selected in
    ; Settings, so boot never stalls on the renderer.

    mov byte [gui_initialized], 1

    call cpu_acct_init
    call render_frame

    ; ---- FBPERF deterministic bench ----
    ; 64 back-to-back forced full flips. fbperf_flip_full_begin/end inside
    ; display_flip accumulate TSC + bytes into the same counters the `=`
    ; overlay shows. Phase A vs Phase B compare these 64 samples directly,
    ; eliminating the dependency on user workload (cursor circles produce
    ; mostly dirty-rect blits, which dilute the full-flip signal).
    extern display_flip
    mov ecx, 64
.fbp_bench_loop:
    push rcx
    call display_flip
    pop rcx
    dec ecx
    jnz .fbp_bench_loop

    ; Read-only kernel after init (security_todo.md §9): all kernel setup is
    ; done, so lock the kernel .text PDEs read-only and enable CR0.WP. Any
    ; subsequent kernel-side write into code now page-faults. One-shot; placed
    ; here, the last thing before the main loop, so every init-time write to
    ; .text (if any) has already happened.
    extern kernel_lockdown_ro
    call kernel_lockdown_ro

.infinite:
    mov byte [main_loop_stage], 1
    call cpu_acct_idle_end
    mov byte [main_loop_stage_done], 1
    cmp byte [gui_initialized], 1
    jne .skip_gui
    mov byte [main_loop_stage], 2
    call render_frame
    mov byte [main_loop_stage_done], 2
    mov byte [main_loop_stage], 3
    call usb_poll_mouse
    extern rtl8156_dhcp_pump
    call rtl8156_dhcp_pump
    ; Drive a NIC RX poll each frame so ICMP echo replies (and ARP) land
    ; promptly even when no syscall is being made. Without this, async ping
    ; misses replies that arrive between frames.
    extern net_nic_poll_rx
    call net_nic_poll_rx
    mov byte [main_loop_stage_done], 3
    mov byte [main_loop_stage], 4
    ; call usb_debug_overlay   ; disabled - debug overlay hidden
    mov byte [main_loop_stage_done], 4
    mov byte [main_loop_stage], 5
    call i2c_hid_poll
    mov byte [main_loop_stage_done], 5
    mov byte [main_loop_stage], 6
    call battery_poll
    mov byte [main_loop_stage_done], 6
    mov byte [main_loop_stage], 7
    call process_mouse
    mov byte [main_loop_stage_done], 7
    mov byte [main_loop_stage], 8
    call keyboard_repeat_tick
    mov byte [main_loop_stage_done], 8
.drain_kb:
    mov byte [main_loop_stage], 9
    call process_keyboard
    call keyboard_available
    test eax, eax
    jnz .drain_kb
    mov byte [main_loop_stage_done], 9
    mov byte [main_loop_stage], 10
    call serial_poll_command
    mov byte [main_loop_stage_done], 10
    inc dword [main_loop_iters]
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
    mov [acct_tsc_start], rax
    mov rax, [tick_count]
    mov [acct_win_tick], rax
    mov dword [abs smp_core_states + 24], 0
    mov rax, [cpu_tsc_per_tick]
    xor rdx, rdx
    mov rcx, 10000
    div rcx
    mov [abs smp_core_states + 28], eax
    call cpu_acct_init_aperf
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
    push r8
    push r9
    push r10
    mov r8, rax              ; elapsed PIT ticks in this accounting window
    mov r10, rbx             ; current TSC before RBX is reused below
    mov rax, [acct_busy_acc]
    mov rcx, [acct_idle_acc]
    add rcx, rax
    test rcx, rcx
    jz .acct_clock
    mov rbx, 100
    xor rdx, rdx
    mul rbx                  ; rdx:rax = busy * 100
    div rcx                  ; rax = busy*100 / total
    cmp rax, 100
    jbe .acct_store
    mov rax, 100
.acct_store:
    mov [bsp_util], eax
    mov [abs smp_core_states + 24], eax
.acct_clock:
    call cpu_acct_publish_mhz
.acct_clock_done:
    mov [acct_tsc_start], r10
    pop r10
    pop r9
    pop r8
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

cpu_acct_init_aperf:
    push rax
    push rbx
    push rcx
    push rdx
    xor eax, eax
    cpuid
    cmp eax, 6
    jb .done
    mov eax, 6
    cpuid
    test ecx, 1
    jz .done
    mov ecx, 0xE8                  ; IA32_APERF
    rdmsr
    shl rdx, 32
    or rax, rdx
    mov [abs smp_core_states + 64], rax
    mov ecx, 0xE7                  ; IA32_MPERF
    rdmsr
    shl rdx, 32
    or rax, rdx
    mov [abs smp_core_states + 72], rax
.done:
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; R8 = elapsed PIT ticks, R10 = current TSC for this accounting window.
cpu_acct_publish_mhz:
    push rax
    push rbx
    push rcx
    push rdx
    push r9
    xor eax, eax
    cpuid
    cmp eax, 6
    jb .tsc_fallback
    mov eax, 6
    cpuid
    test ecx, 1
    jz .tsc_fallback
    mov ecx, 0xE8                  ; IA32_APERF
    rdmsr
    shl rdx, 32
    or rax, rdx
    mov rbx, rax
    sub rax, [abs smp_core_states + 64]
    mov [abs smp_core_states + 64], rbx
    mov r9, rax
    mov ecx, 0xE7                  ; IA32_MPERF
    rdmsr
    shl rdx, 32
    or rax, rdx
    mov rbx, rax
    sub rax, [abs smp_core_states + 72]
    mov [abs smp_core_states + 72], rbx
    mov rcx, rax
    test rcx, rcx
    jz .tsc_fallback
    mov rax, [cpu_tsc_per_tick]
    xor rdx, rdx
    mov rbx, 10000
    div rbx                        ; base TSC MHz
    mul r9                         ; base MHz * aperf delta
    xor rdx, rdx
    div rcx                        ; scale by aperf/mperf
    mov [abs smp_core_states + 28], eax
    jmp .done
.tsc_fallback:
    mov rax, r10
    sub rax, [acct_tsc_start]
    mov r9, r8
    imul r9, 10000
    test r9, r9
    jz .done
    xor rdx, rdx
    div r9
    mov [abs smp_core_states + 28], eax
.done:
    pop r9
    pop rdx
    pop rcx
    pop rbx
    pop rax
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

    ; Cap bytes consumed per call. On real hardware with no UART attached,
    ; reading the LSR at 0x3FD can return 0xFF (data-ready bit permanently
    ; set), which would freeze the main loop in an infinite read here.
    ; 256 bytes is far more than any legitimate burst per ~10ms tick.
    mov ecx, 256

.poll:
    mov dx, 0x3F8 + 5
    in al, dx
    ; LSR == 0xFF means no UART present (floating bus / pull-ups).
    ; Treat as "no data" and bail out so the main loop can keep running.
    cmp al, 0xFF
    je .done
    test al, 1
    jz .done

    mov dx, 0x3F8
    in al, dx

    cmp byte [serial_command_armed], 0
    jne .dispatch_control

    cmp al, 1
    je .arm_control

    call serial_forward_input
    dec ecx
    jnz .poll
    jmp .done

.arm_control:
    mov byte [serial_command_armed], 1
    dec ecx
    jnz .poll
    jmp .done

.dispatch_control:
    mov byte [serial_command_armed], 0
    call serial_dispatch_control
    dec ecx
    jnz .poll
    jmp .done

.done:
    pop rdi
    pop rdx
    pop rcx
    pop rax
    ret

serial_dispatch_control:
    cmp al, '2'
    jb .check_close
    cmp al, '9'
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
    cmp al, 'v'
    je .diag_pci_gpu
    cmp al, '='
    je .diag_real_boot
    cmp al, 't'
    je .dump_trace
    cmp al, 'g'
    je .svg_dump
    cmp al, 'b'
    je .diag_bench
    cmp al, 'n'
    je .net_ping
    cmp al, 'N'
    je .net_ping_ics
    cmp al, 'i'
    je .net_ping_google
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

.diag_pci_gpu:
    call perfdiag_print_pci_gpu
    ret

.diag_real_boot:
    call real_boot_diag_dump
    extern klog_visible
    mov byte [klog_visible], 1
    mov byte [scene_dirty], 1
    ret

.diag_bench:
    call perfdiag_benchmark
    ret

.net_ping:
    lea rsi, [rel net_ping_start_msg]
    call svg_dump_puts
    call rtl8139_icmp_ping_gateway
    test eax, eax
    jz .net_ping_serial_fail
    lea rsi, [rel net_ping_ok_msg]
    call svg_dump_puts
    ret
.net_ping_serial_fail:
    lea rsi, [rel net_ping_fail_msg]
    call svg_dump_puts
    ret

.net_ping_ics:
    lea rsi, [rel net_ping_ics_start_msg]
    call svg_dump_puts
    call rtl8139_icmp_ping_ics
    test eax, eax
    jz .net_ping_ics_serial_fail
    lea rsi, [rel net_ping_ok_msg]
    call svg_dump_puts
    ret
.net_ping_ics_serial_fail:
    lea rsi, [rel net_ping_fail_msg]
    call svg_dump_puts
    ret

.net_ping_google:
    lea rsi, [rel net_ping_google_start_msg]
    call svg_dump_puts
    mov edi, 0x08080808
    call net_ping_ipv4
    cmp rax, -1
    je .net_ping_google_fail
    lea rsi, [rel net_ping_ok_msg]
    call svg_dump_puts
    ret
.net_ping_google_fail:
    lea rsi, [rel net_ping_fail_msg]
    call svg_dump_puts
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
real_boot_diag_dump:
    push rax
    push rdx
    push rsi
    push rdi

    call pci_gpu_scan

    lea rdi, [ovl_buf]
    lea rsi, [s_diag_begin]
    call ovl_puts
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_diag_boot]
    call ovl_puts
    mov rdx, [abs VBE_INFO_ADDR + VBE_FB_ADDR_OFF]
    call diag_puth64
    lea rsi, [s_diag_w]
    call ovl_puts
    mov edx, [abs VBE_INFO_ADDR + VBE_WIDTH_OFF]
    call ovl_putu
    lea rsi, [s_diag_h]
    call ovl_puts
    mov edx, [abs VBE_INFO_ADDR + VBE_HEIGHT_OFF]
    call ovl_putu
    lea rsi, [s_diag_pitch]
    call ovl_puts
    mov edx, [abs VBE_INFO_ADDR + VBE_PITCH_OFF]
    call ovl_putu
    lea rsi, [s_diag_bpp]
    call ovl_puts
    mov edx, [abs VBE_INFO_ADDR + VBE_BPP_OFF]
    call ovl_putu
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_diag_mem]
    call ovl_puts
    mov rdx, [abs VBE_INFO_ADDR + VBE_BACKBUF_OFF]
    call diag_puth64
    lea rsi, [s_diag_sz]
    call ovl_puts
    mov rdx, [abs VBE_INFO_ADDR + VBE_BACKBUF_SIZE_OFF]
    call diag_puth64
    lea rsi, [s_diag_apps]
    call ovl_puts
    mov rdx, [abs VBE_INFO_ADDR + VBE_APPS_BASE_OFF]
    call diag_puth64
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_diag_disp]
    call ovl_puts
    mov rdx, [fb_addr]
    call diag_puth64
    lea rsi, [s_diag_bb]
    call ovl_puts
    mov rdx, [bb_addr]
    call diag_puth64
    lea rsi, [s_diag_w]
    call ovl_puts
    mov edx, [scr_width]
    call ovl_putu
    lea rsi, [s_diag_h]
    call ovl_puts
    mov edx, [scr_height]
    call ovl_putu
    lea rsi, [s_diag_pitch]
    call ovl_puts
    mov edx, [scr_pitch]
    call ovl_putu
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_diag_native]
    call ovl_puts
    mov edx, [fb_native_width]
    call ovl_putu
    lea rsi, [s_diag_x]
    call ovl_puts
    mov edx, [fb_native_height]
    call ovl_putu
    lea rsi, [s_diag_vsync]
    call ovl_puts
    movzx edx, byte [vsync_enabled]
    call ovl_putu
    lea rsi, [s_diag_fps]
    call ovl_puts
    mov edx, [last_fps]
    call ovl_putu
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_diag_pci]
    call ovl_puts
    movzx edx, byte [pci_gpu_count]
    call ovl_putu
    lea rsi, [s_diag_780m]
    call ovl_puts
    movzx edx, byte [pci_gpu_radeon780m_found]
    call ovl_putu
    lea rsi, [s_diag_amd]
    call ovl_puts
    movzx edx, byte [pci_gpu_amd_display_found]
    call ovl_putu
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_diag_780m_line]
    call ovl_puts
    mov edx, [pci_gpu_radeon780m_bdf]
    call ovl_puth32
    lea rsi, [s_diag_id]
    call ovl_puts
    mov edx, [pci_gpu_radeon780m_id]
    call ovl_puth32
    lea rsi, [s_diag_class]
    call ovl_puts
    mov edx, [pci_gpu_radeon780m_class]
    call ovl_puth32
    lea rsi, [s_diag_cmd]
    call ovl_puts
    mov edx, [pci_gpu_radeon780m_cmd]
    call ovl_puth32
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_diag_780m_bar]
    call ovl_puts
    mov rdx, [pci_gpu_radeon780m_bar0]
    call diag_puth64
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_diag_amd_line]
    call ovl_puts
    mov edx, [pci_gpu_amd_display_bdf]
    call ovl_puth32
    lea rsi, [s_diag_id]
    call ovl_puts
    mov edx, [pci_gpu_amd_display_id]
    call ovl_puth32
    lea rsi, [s_diag_class]
    call ovl_puts
    mov edx, [pci_gpu_amd_display_class]
    call ovl_puth32
    lea rsi, [s_diag_cmd]
    call ovl_puts
    mov edx, [pci_gpu_amd_display_cmd]
    call ovl_puth32
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_diag_amddisp]
    call ovl_puts
    movzx edx, byte [amd_display_active]
    call ovl_putu
    lea rsi, [s_diag_status]
    call ovl_puts
    mov edx, [amd_display_status]
    call ovl_putu
    lea rsi, [s_diag_bdf]
    call ovl_puts
    mov edx, [amd_display_bdf]
    call ovl_puth32
    lea rsi, [s_diag_id]
    call ovl_puts
    mov edx, [amd_display_id]
    call ovl_puth32
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_diag_amdmode]
    call ovl_puts
    mov edx, [amd_display_mode_w]
    call ovl_putu
    lea rsi, [s_diag_x]
    call ovl_puts
    mov edx, [amd_display_mode_h]
    call ovl_putu
    lea rsi, [s_diag_pitch]
    call ovl_puts
    mov edx, [amd_display_mode_pitch]
    call ovl_putu
    lea rsi, [s_diag_bpp]
    call ovl_puts
    mov edx, [amd_display_mode_bpp]
    call ovl_putu
    lea rsi, [s_diag_fb]
    call ovl_puts
    mov rdx, [amd_display_fb_addr]
    call diag_puth64
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_diag_loop]
    call ovl_puts
    mov edx, [main_loop_iters]
    call ovl_putu
    lea rsi, [s_o_ml_stage]
    call ovl_puts
    movzx edx, byte [main_loop_stage]
    call ovl_putu
    lea rsi, [s_o_ml_done]
    call ovl_puts
    movzx edx, byte [main_loop_stage_done]
    call ovl_putu
    lea rsi, [s_o_ml_tick]
    call ovl_puts
    mov edx, [tick_count]
    call ovl_putu
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_diag_input]
    call ovl_puts
    movzx edx, byte [kb_numlock]
    call ovl_putu
    lea rsi, [s_diag_usbkb]
    call ovl_puts
    movzx edx, byte [usb_hid_protocol]
    call ovl_putu
    lea rsi, [s_diag_usbkb2]
    call ovl_puts
    movzx edx, byte [usb_hid_protocol2]
    call ovl_putu
    lea rsi, [s_diag_xhci]
    call ovl_puts
    movzx edx, byte [xhci_active]
    call ovl_putu
    mov byte [rdi], 0
    call diag_emit_line

    ; FS diagnostic — confirms whether the UEFI loader registered DATA.IMG
    ; as a ramdisk and whether fat16_init mounted it. If rdBase=0 the loader
    ; never published the region (AllocatePages failed or file missing);
    ; if fatTot=0 the BPB read failed even with the ramdisk present.
    extern fat16_total_sects, fat16_file_count_val
    extern ramdisk_active, ramdisk_base
    lea rdi, [ovl_buf]
    lea rsi, [s_diag_fs]
    call ovl_puts
    mov rdx, [abs VBE_INFO_ADDR + VBE_RAMDISK_BASE_OFF]
    call diag_puth64
    lea rsi, [s_diag_fs_sz]
    call ovl_puts
    mov rdx, [abs VBE_INFO_ADDR + VBE_RAMDISK_SIZE_OFF]
    call diag_puth64
    lea rsi, [s_diag_fs_tot]
    call ovl_puts
    mov edx, [fat16_total_sects]
    call ovl_puth32
    lea rsi, [s_diag_fs_n]
    call ovl_puts
    mov edx, [fat16_file_count_val]
    call ovl_putu
    mov byte [rdi], 0
    call diag_emit_line

    ; Second FS line: ramdisk_active flag + first qword at rdBase
    ; (should be 0x2020534F5355584E because LE of "NEXUSOS " starting at +3,
    ; so qword at +0 is 0x4E5558534F539090EB → in display 'EB903C904E5558534F53'? actually
    ; the BPB bytes 0..7 = EB 3C 90 4E 45 58 55 53; qword LE = 0x5355584E903C90EB).
    ; And first qword at FAT16_SECTOR_BUF (what fat16_init saw after read).
    lea rdi, [ovl_buf]
    lea rsi, [s_diag_fs2]
    call ovl_puts
    movzx edx, byte [ramdisk_active]
    call ovl_putu
    lea rsi, [s_diag_fs2_b0]
    call ovl_puts
    mov rax, [abs VBE_INFO_ADDR + VBE_RAMDISK_BASE_OFF]
    test rax, rax
    jz .fs2_skip_b0
    mov rdx, [rax]
    call diag_puth64
.fs2_skip_b0:
    lea rsi, [s_diag_fs2_sb]
    call ovl_puts
    mov rdx, [abs 0x1A00000]            ; FAT16_SECTOR_BUF first qword
    call diag_puth64
    mov byte [rdi], 0
    call diag_emit_line

%ifdef NEXUS_DIAG_LEGACY
    ; ---- FBPERF block (legacy diag — landed 2026-05-25; off by default) ----
    lea rdi, [ovl_buf]
    lea rsi, [s_fbp_hdr]
    call ovl_puts
    movzx edx, byte [fbperf_init_done]
    call ovl_putu
    lea rsi, [s_fbp_patok]
    call ovl_puts
    mov edx, [fbperf_cpuid_pat_supported]
    call ovl_putu
    lea rsi, [s_fbp_cr4]
    call ovl_puts
    mov rdx, [fbperf_cr4]
    call diag_puth64
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_fbp_pat]
    call ovl_puts
    mov rdx, [fbperf_pat_msr]
    call diag_puth64
    lea rsi, [s_fbp_mtrrcap]
    call ovl_puts
    mov edx, [fbperf_mtrrcap]
    call ovl_puth32
    lea rsi, [s_fbp_mtrrdef]
    call ovl_puts
    mov edx, [fbperf_mtrr_def_type]
    call ovl_puth32
    lea rsi, [s_fbp_mtrrn]
    call ovl_puts
    mov edx, [fbperf_mtrr_var_count]
    call ovl_putu
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_fbp_pteline]
    call ovl_puts
    mov edx, [fbperf_fb_pte_level]
    call ovl_putu
    lea rsi, [s_fbp_pteval]
    call ovl_puts
    mov rdx, [fbperf_fb_pte_value]
    call diag_puth64
    lea rsi, [s_fbp_caching]
    call ovl_puts
    mov edx, [fbperf_fb_caching_type]
    call ovl_putu
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_fbp_wcplan]
    call ovl_puts
    mov rdx, [fbperf_wc_plan_pat]
    call diag_puth64
    lea rsi, [s_fbp_wcarm]
    call ovl_puts
    movzx edx, byte [fbperf_wc_armed]
    call ovl_putu
    lea rsi, [s_fbp_wcact]
    call ovl_puts
    movzx edx, byte [fbperf_wc_activated]
    call ovl_putu
    mov byte [rdi], 0
    call diag_emit_line

    ; perf counters
    lea rdi, [ovl_buf]
    lea rsi, [s_fbp_flips]
    call ovl_puts
    mov rdx, [fbperf_flips_total]
    call diag_puth64
    lea rsi, [s_fbp_full]
    call ovl_puts
    mov rdx, [fbperf_full_flips]
    call diag_puth64
    lea rsi, [s_fbp_rect]
    call ovl_puts
    mov rdx, [fbperf_rect_flips]
    call diag_puth64
    lea rsi, [s_fbp_fbytes]
    call ovl_puts
    mov rdx, [fbperf_full_bytes]
    call diag_puth64
    lea rsi, [s_fbp_rbytes]
    call ovl_puts
    mov rdx, [fbperf_rect_bytes]
    call diag_puth64
    lea rsi, [s_fbp_tbytes]
    call ovl_puts
    mov rdx, [fbperf_bytes_total]
    call diag_puth64
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_fbp_tsctot]
    call ovl_puts
    mov rdx, [fbperf_tsc_total]
    call diag_puth64
    lea rsi, [s_fbp_tscmin]
    call ovl_puts
    mov rdx, [fbperf_tsc_min]
    call diag_puth64
    lea rsi, [s_fbp_tscmax]
    call ovl_puts
    mov rdx, [fbperf_tsc_max]
    call diag_puth64
    lea rsi, [s_fbp_tsclast]
    call ovl_puts
    mov rdx, [fbperf_tsc_last]
    call diag_puth64
    mov byte [rdi], 0
    call diag_emit_line

    ; per-MTRR rows (16 bytes each: qword base, qword mask)
    push rbx
    push rcx
    xor ecx, ecx
.fbp_mtrr_loop:
    cmp ecx, [fbperf_mtrr_var_count]
    jae .fbp_mtrr_done
    mov rax, rcx
    shl rax, 4                              ; *16 bytes per entry
    lea rbx, [fbperf_mtrr_var]
    add rbx, rax
    push rcx
    push rbx
    lea rdi, [ovl_buf]
    lea rsi, [s_fbp_mtrri]
    call ovl_puts
    mov edx, ecx
    call ovl_putu
    pop rbx
    push rbx
    lea rsi, [s_fbp_mtrri_b]
    call ovl_puts
    mov rdx, [rbx]
    call diag_puth64
    lea rsi, [s_fbp_mtrri_m]
    call ovl_puts
    pop rbx
    mov rdx, [rbx + 8]
    call diag_puth64
    mov byte [rdi], 0
    call diag_emit_line
    pop rcx
    inc ecx
    jmp .fbp_mtrr_loop
.fbp_mtrr_done:
    pop rcx
    pop rbx
%endif ; NEXUS_DIAG_LEGACY (FBPERF)

    ; Save rbx/rcx around DCN+EC+GFX additions (we clobber them).
    push rbx
    push rcx
%ifdef NEXUS_DIAG_LEGACY
    ; ---- DCN probe (read-only; parked — DMUB bring-up paused) ----
    extern amd_dcn_probe
    extern amd_dcn_bar0
    extern amd_dcn_mmio_ok
    extern amd_dcn_pte_value
    extern amd_dcn_pte_level
    extern amd_dcn_pat_index
    extern amd_dcn_cache_type
    extern amd_dcn_reg0000
    extern amd_dcn_reg0004
    extern amd_dcn_reg0008
    extern amd_dcn_reg000C
    extern amd_dcn_cfg_base
    extern amd_dcn_cmd_pre
    extern amd_dcn_cmd_post
    extern amd_dcn_uc_ok
    extern amd_dcn_uc_r0000
    extern amd_dcn_uc_r0004
    extern amd_dcn_uc_r0008
    extern amd_dcn_uc_r000C
    extern amd_dcn_uc_walk_pte
    extern amd_dcn_uc_walk_lvl
    extern amd_dcn_dmub_diag_ok
    extern amd_dcn_dmub_cntl
    extern amd_dcn_dmub_cntl2
    extern amd_dcn_dmub_sec_cntl
    extern amd_dcn_dmub_scratch0
    extern amd_dcn_dmub_scratch1
    extern amd_dcn_dmub_scratch2
    extern amd_dcn_dmub_scratch3
    extern amd_dcn_dmub_scratch7
    extern amd_dcn_dmub_scratch14
    extern amd_dcn_dmub_scratch15
    extern amd_dcn_dmub_boot_bits
    extern amd_dcn_dmub_inbox1_base
    extern amd_dcn_dmub_inbox1_size
    extern amd_dcn_dmub_inbox1_rptr
    extern amd_dcn_dmub_inbox1_wptr
    extern amd_dcn_dmub_outbox1_base
    extern amd_dcn_dmub_outbox1_size
    extern amd_dcn_dmub_outbox1_rptr
    extern amd_dcn_dmub_outbox1_wptr
    extern amd_dcn_dmub_gpint_in
    extern amd_dcn_dmub_gpint_out
    extern amd_dcn_dmub_inst_fault
    extern amd_dcn_dmub_data_fault
    extern amd_dcn_dmub_undef_fault
    extern amd_dcn_dmub_timer
    extern amd_dcn_dmub_fb_base_reg
    extern amd_dcn_dmub_fb_offset_reg
    extern amd_dcn_dmub_cw6_base
    extern amd_dcn_dmub_cw6_top
    extern amd_dcn_dmub_cw6_offset_lo
    extern amd_dcn_dmub_cw6_offset_hi
    extern amd_dcn_fw_probe
    extern amd_dcn_fw_status
    extern amd_dcn_fw_size
    extern amd_dcn_fw_inst_const_bytes
    extern amd_dcn_fw_region_size
    extern amd_dcn_fw_trace_buf_size
    extern amd_dcn_fw_version
    extern amd_dcn_fw_shared_state_size
    extern amd_dcn_fw_shared_features
    extern amd_dcn_fw_feature_bits
    extern amd_dcn_dmub_state_flags
    extern amd_dcn_dmub_rings_arm
    extern amd_dcn_dmub_ring_status
    extern amd_dcn_dmub_ring_sys_phys
    extern amd_dcn_dmub_ring_fb_addr
    extern amd_dcn_dmub_ring_inbox_fb
    extern amd_dcn_dmub_ring_outbox_fb
    extern amd_dcn_dmub_fb_base_phys
    extern amd_dcn_dmub_fb_offset_phys
    extern amd_dcn_dmub_gpint_status
    extern amd_dcn_dmub_gpint_req
    extern amd_dcn_dmub_gpint_response
    extern amd_dcn_dmub_gpint_dataout_after
    extern amd_dcn_dmub_gpint_polls_left
    extern amd_dcn_dmub_gpint_tick_start
    extern amd_dcn_dmub_gpint_tick_end
    extern amd_dcn_dmub_cmd_status
    extern amd_dcn_dmub_cmd_rptr0
    extern amd_dcn_dmub_cmd_wptr0
    extern amd_dcn_dmub_cmd_rptr1
    extern amd_dcn_dmub_cmd_wptr1
    extern amd_dcn_dmub_cmd_q0
    extern amd_dcn_dmub_cmd_q1
    extern amd_dcn_dmub_cmd_tick_start
    extern amd_dcn_dmub_cmd_tick_end
    call amd_dcn_probe

    lea rdi, [ovl_buf]
    lea rsi, [s_dcn_hdr]
    call ovl_puts
    mov rdx, [amd_dcn_bar0]
    call diag_puth64
    lea rsi, [s_dcn_ok]
    call ovl_puts
    movzx edx, byte [amd_dcn_mmio_ok]
    call ovl_putu
    lea rsi, [s_dcn_lvl]
    call ovl_puts
    mov edx, [amd_dcn_pte_level]
    call ovl_putu
    lea rsi, [s_dcn_pat]
    call ovl_puts
    mov edx, [amd_dcn_pat_index]
    call ovl_putu
    lea rsi, [s_dcn_cache]
    call ovl_puts
    mov edx, [amd_dcn_cache_type]
    call ovl_putu
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_dcn_pte]
    call ovl_puts
    mov rdx, [amd_dcn_pte_value]
    call diag_puth64
    mov byte [rdi], 0
    call diag_emit_line

    ; UC alias install verification + sparse-offset MMIO sample
    lea rdi, [ovl_buf]
    lea rsi, [s_dcn_uc_walk]
    call ovl_puts
    mov edx, [amd_dcn_uc_walk_lvl]
    call ovl_putu
    lea rsi, [s_dcn_uc_walk_p]
    call ovl_puts
    mov rdx, [amd_dcn_uc_walk_pte]
    call diag_puth64
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_dcn_uc_hdr]
    call ovl_puts
    movzx edx, byte [amd_dcn_uc_ok]
    call ovl_putu
    lea rsi, [s_dcn_uc_r0]
    call ovl_puts
    mov edx, [amd_dcn_uc_r0000]
    call ovl_puth32
    lea rsi, [s_dcn_uc_r4]
    call ovl_puts
    mov edx, [amd_dcn_uc_r0004]
    call ovl_puth32
    lea rsi, [s_dcn_uc_r8]
    call ovl_puts
    mov edx, [amd_dcn_uc_r0008]
    call ovl_puth32
    lea rsi, [s_dcn_uc_rC]
    call ovl_puts
    mov edx, [amd_dcn_uc_r000C]
    call ovl_puth32
    mov byte [rdi], 0
    call diag_emit_line

    ; ---- DMCUB/DMUB read-only status (DCN3.1.4 offsets) ----
    lea rdi, [ovl_buf]
    lea rsi, [s_dmub_hdr]
    call ovl_puts
    movzx edx, byte [amd_dcn_dmub_diag_ok]
    call ovl_putu
    lea rsi, [s_dmub_cntl]
    call ovl_puts
    mov edx, [amd_dcn_dmub_cntl]
    call ovl_puth32
    lea rsi, [s_dmub_cntl2]
    call ovl_puts
    mov edx, [amd_dcn_dmub_cntl2]
    call ovl_puth32
    lea rsi, [s_dmub_sec]
    call ovl_puts
    mov edx, [amd_dcn_dmub_sec_cntl]
    call ovl_puth32
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_dmub_scr0]
    call ovl_puts
    mov edx, [amd_dcn_dmub_scratch0]
    call ovl_puth32
    lea rsi, [s_dmub_bits]
    call ovl_puts
    mov edx, [amd_dcn_dmub_boot_bits]
    call ovl_puth32
    lea rsi, [s_dmub_scr7]
    call ovl_puts
    mov edx, [amd_dcn_dmub_scratch7]
    call ovl_puth32
    lea rsi, [s_dmub_timer]
    call ovl_puts
    mov edx, [amd_dcn_dmub_timer]
    call ovl_puth32
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_dmub_state]
    call ovl_puts
    mov edx, [amd_dcn_dmub_state_flags]
    call ovl_puth32
    lea rsi, [s_dmub_s1]
    call ovl_puts
    mov edx, [amd_dcn_dmub_scratch1]
    call ovl_puth32
    lea rsi, [s_dmub_s14]
    call ovl_puts
    mov edx, [amd_dcn_dmub_scratch14]
    call ovl_puth32
    lea rsi, [s_dmub_s15]
    call ovl_puts
    mov edx, [amd_dcn_dmub_scratch15]
    call ovl_puth32
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_dmub_fbraw]
    call ovl_puts
    mov edx, [amd_dcn_dmub_fb_base_reg]
    call ovl_puth32
    lea rsi, [s_dmub_fboffraw]
    call ovl_puts
    mov edx, [amd_dcn_dmub_fb_offset_reg]
    call ovl_puth32
    lea rsi, [s_dmub_fbbase]
    call ovl_puts
    mov rdx, [amd_dcn_dmub_fb_base_phys]
    call diag_puth64
    lea rsi, [s_dmub_fboff]
    call ovl_puts
    mov rdx, [amd_dcn_dmub_fb_offset_phys]
    call diag_puth64
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_dmub_ring]
    call ovl_puts
    movzx edx, byte [amd_dcn_dmub_rings_arm]
    call ovl_putu
    lea rsi, [s_dmub_rstat]
    call ovl_puts
    mov edx, [amd_dcn_dmub_ring_status]
    call ovl_puth32
    lea rsi, [s_dmub_rphys]
    call ovl_puts
    mov rdx, [amd_dcn_dmub_ring_sys_phys]
    call diag_puth64
    lea rsi, [s_dmub_rfb]
    call ovl_puts
    mov rdx, [amd_dcn_dmub_ring_fb_addr]
    call diag_puth64
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_dmub_ring2]
    call ovl_puts
    mov edx, [amd_dcn_dmub_ring_inbox_fb]
    call ovl_puth32
    lea rsi, [s_dmub_outfb]
    call ovl_puts
    mov edx, [amd_dcn_dmub_ring_outbox_fb]
    call ovl_puth32
    lea rsi, [s_dmub_gpstat]
    call ovl_puts
    mov edx, [amd_dcn_dmub_gpint_status]
    call ovl_puth32
    lea rsi, [s_dmub_gpreq]
    call ovl_puts
    mov edx, [amd_dcn_dmub_gpint_req]
    call ovl_puth32
    lea rsi, [s_dmub_gpresp]
    call ovl_puts
    mov edx, [amd_dcn_dmub_gpint_response]
    call ovl_puth32
    mov byte [rdi], 0
    call diag_emit_line

    ; CW6 shared-state region (read-only). BIOS-loaded firmware programs this
    ; with the dmub_shared_state region; needed for IPS-exit signaling.
    lea rdi, [ovl_buf]
    lea rsi, [s_dmub_cw6]
    call ovl_puts
    mov edx, [amd_dcn_dmub_cw6_base]
    call ovl_puth32
    lea rsi, [s_dmub_cw6_top]
    call ovl_puts
    mov edx, [amd_dcn_dmub_cw6_top]
    call ovl_puth32
    lea rsi, [s_dmub_cw6_olo]
    call ovl_puts
    mov edx, [amd_dcn_dmub_cw6_offset_lo]
    call ovl_puth32
    lea rsi, [s_dmub_cw6_ohi]
    call ovl_puts
    mov edx, [amd_dcn_dmub_cw6_offset_hi]
    call ovl_puth32
    mov byte [rdi], 0
    call diag_emit_line

    ; DMCUB firmware blob probe (read-only). Locates DCN35DMC.BIN on the
    ; ramdisk and parses dmub_fw_meta_info. Phase 2 will use these sizes
    ; to allocate work regions for a full reset+load+release.
    call amd_dcn_fw_probe
    lea rdi, [ovl_buf]
    lea rsi, [s_fw_a]
    call ovl_puts
    mov edx, [amd_dcn_fw_status]
    call ovl_puth32
    lea rsi, [s_fw_size]
    call ovl_puts
    mov edx, [amd_dcn_fw_size]
    call ovl_puth32
    lea rsi, [s_fw_inst]
    call ovl_puts
    mov edx, [amd_dcn_fw_inst_const_bytes]
    call ovl_puth32
    lea rsi, [s_fw_ver]
    call ovl_puts
    mov edx, [amd_dcn_fw_version]
    call ovl_puth32
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_fw_b]
    call ovl_puts
    mov edx, [amd_dcn_fw_region_size]
    call ovl_puth32
    lea rsi, [s_fw_trace]
    call ovl_puts
    mov edx, [amd_dcn_fw_trace_buf_size]
    call ovl_puth32
    lea rsi, [s_fw_ss]
    call ovl_puts
    mov edx, [amd_dcn_fw_shared_state_size]
    call ovl_puth32
    lea rsi, [s_fw_feat]
    call ovl_puts
    mov edx, [amd_dcn_fw_feature_bits]
    call ovl_puth32
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_dmub_gp2]
    call ovl_puts
    mov edx, [amd_dcn_dmub_gpint_dataout_after]
    call ovl_puth32
    lea rsi, [s_dmub_gppolls]
    call ovl_puts
    mov edx, [amd_dcn_dmub_gpint_polls_left]
    call ovl_putu
    lea rsi, [s_dmub_gpstart]
    call ovl_puts
    mov edx, [amd_dcn_dmub_gpint_tick_start]
    call ovl_putu
    lea rsi, [s_dmub_gpend]
    call ovl_puts
    mov edx, [amd_dcn_dmub_gpint_tick_end]
    call ovl_putu
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_dmub_cmd]
    call ovl_puts
    mov edx, [amd_dcn_dmub_cmd_status]
    call ovl_puth32
    lea rsi, [s_dmub_cmd_r0]
    call ovl_puts
    mov edx, [amd_dcn_dmub_cmd_rptr0]
    call ovl_puth32
    lea rsi, [s_dmub_cmd_w0]
    call ovl_puts
    mov edx, [amd_dcn_dmub_cmd_wptr0]
    call ovl_puth32
    lea rsi, [s_dmub_cmd_r1]
    call ovl_puts
    mov edx, [amd_dcn_dmub_cmd_rptr1]
    call ovl_puth32
    lea rsi, [s_dmub_cmd_w1]
    call ovl_puts
    mov edx, [amd_dcn_dmub_cmd_wptr1]
    call ovl_puth32
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_dmub_cmd2]
    call ovl_puts
    mov rdx, [amd_dcn_dmub_cmd_q0]
    call diag_puth64
    lea rsi, [s_dmub_cmd_q1]
    call ovl_puts
    mov rdx, [amd_dcn_dmub_cmd_q1]
    call diag_puth64
    lea rsi, [s_dmub_gpstart]
    call ovl_puts
    mov edx, [amd_dcn_dmub_cmd_tick_start]
    call ovl_putu
    lea rsi, [s_dmub_gpend]
    call ovl_puts
    mov edx, [amd_dcn_dmub_cmd_tick_end]
    call ovl_putu
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_dmub_inb]
    call ovl_puts
    mov edx, [amd_dcn_dmub_inbox1_base]
    call ovl_puth32
    lea rsi, [s_dmub_size]
    call ovl_puts
    mov edx, [amd_dcn_dmub_inbox1_size]
    call ovl_puth32
    lea rsi, [s_dmub_rptr]
    call ovl_puts
    mov edx, [amd_dcn_dmub_inbox1_rptr]
    call ovl_puth32
    lea rsi, [s_dmub_wptr]
    call ovl_puts
    mov edx, [amd_dcn_dmub_inbox1_wptr]
    call ovl_puth32
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_dmub_outb]
    call ovl_puts
    mov edx, [amd_dcn_dmub_outbox1_base]
    call ovl_puth32
    lea rsi, [s_dmub_size]
    call ovl_puts
    mov edx, [amd_dcn_dmub_outbox1_size]
    call ovl_puth32
    lea rsi, [s_dmub_rptr]
    call ovl_puts
    mov edx, [amd_dcn_dmub_outbox1_rptr]
    call ovl_puth32
    lea rsi, [s_dmub_wptr]
    call ovl_puts
    mov edx, [amd_dcn_dmub_outbox1_wptr]
    call ovl_puth32
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_dmub_gpint]
    call ovl_puts
    mov edx, [amd_dcn_dmub_gpint_in]
    call ovl_puth32
    lea rsi, [s_dmub_out]
    call ovl_puts
    mov edx, [amd_dcn_dmub_gpint_out]
    call ovl_puth32
    lea rsi, [s_dmub_ifault]
    call ovl_puts
    mov edx, [amd_dcn_dmub_inst_fault]
    call ovl_puth32
    lea rsi, [s_dmub_dfault]
    call ovl_puts
    mov edx, [amd_dcn_dmub_data_fault]
    call ovl_puth32
    lea rsi, [s_dmub_ufault]
    call ovl_puts
    mov edx, [amd_dcn_dmub_undef_fault]
    call ovl_puth32
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_dcn_cfg]
    call ovl_puts
    mov edx, [amd_dcn_cfg_base]
    call ovl_puth32
    lea rsi, [s_dcn_cmd_pre]
    call ovl_puts
    mov edx, [amd_dcn_cmd_pre]
    call ovl_puth32
    lea rsi, [s_dcn_cmd_post]
    call ovl_puts
    mov edx, [amd_dcn_cmd_post]
    call ovl_puth32
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_dcn_r0]
    call ovl_puts
    mov edx, [amd_dcn_reg0000]
    call ovl_puth32
    lea rsi, [s_dcn_r4]
    call ovl_puts
    mov edx, [amd_dcn_reg0004]
    call ovl_puth32
    lea rsi, [s_dcn_r8]
    call ovl_puts
    mov edx, [amd_dcn_reg0008]
    call ovl_puth32
    lea rsi, [s_dcn_rC]
    call ovl_puts
    mov edx, [amd_dcn_reg000C]
    call ovl_puth32
    mov byte [rdi], 0
    call diag_emit_line

    ; ---- DCN IP-block enumeration (Task B) ----
    ; One dword sample per 4KB page across the 1MB UC mapping. Emit only
    ; non-zero entries, 4 per line, format "IP+xxxxx=hhhhhhhh".
    push r12
    push r13
    extern amd_dcn_ip_table
    extern amd_dcn_ip_count
    extern amd_dcn_bl_table
    extern amd_dcn_bl_count
    extern amd_dcn_bl_base
    extern amd_dcn_bl_stride
    lea rdi, [ovl_buf]
    lea rsi, [s_dcn_ip_hdr]
    call ovl_puts
    mov byte [rdi], 0
    call diag_emit_line

    xor r12d, r12d                       ; index
    xor r13d, r13d                       ; per-line counter
    lea rdi, [ovl_buf]
.ip_dump_loop:
    mov ecx, [amd_dcn_ip_count]
    cmp r12d, ecx
    jae .ip_dump_flush
    lea rbx, [amd_dcn_ip_table]
    mov eax, [rbx + r12*4]
    test eax, eax
    jz  .ip_dump_next
    ; emit "IP+xxxxx=hhhhhhhh "
    lea rsi, [s_dcn_ip_pfx]
    call ovl_puts
    mov edx, r12d
    shl edx, 12                          ; offset = idx * 0x1000
    call ovl_puth32
    lea rsi, [s_dcn_eq]
    call ovl_puts
    mov edx, [rbx + r12*4]
    call ovl_puth32
    lea rsi, [s_dcn_sp]
    call ovl_puts
    inc r13d
    cmp r13d, 4
    jb  .ip_dump_next
    mov byte [rdi], 0
    call diag_emit_line
    lea rdi, [ovl_buf]
    xor r13d, r13d
.ip_dump_next:
    inc r12d
    jmp .ip_dump_loop
.ip_dump_flush:
    test r13d, r13d
    jz  .ip_dump_done
    mov byte [rdi], 0
    call diag_emit_line
.ip_dump_done:

    ; DCN BL register sweep disabled: DCN 3.1+/3.5 has no CPU-accessible
    ; BL_PWM register. Backlight is owned by DMUB firmware via the inbox
    ; ring (cmd.panel_cntl) — confirmed in drm/amd/display/dc/resource/
    ; dcn35/dcn35_resource.c which reuses dcn31_panel_cntl. Brightness
    ; will be controlled either via EC scratch byte (see acpi_ec_dump_mid)
    ; or by sending a DMUB packet.
    pop r13
    pop r12

    ; ---- ACPI EC RAM dump (low + high zones) ----
    extern acpi_ec_dump_zone
    extern acpi_ec_dump_ok
    extern acpi_ec_dump_low
    extern acpi_ec_dump_high
    call acpi_ec_dump_zone

    lea rdi, [ovl_buf]
    lea rsi, [s_ec_hdr]
    call ovl_puts
    movzx edx, byte [acpi_ec_dump_ok]
    call ovl_putu
    mov byte [rdi], 0
    call diag_emit_line

    ; Low zone (0x00..0x1F) as 32 hex bytes
    lea rdi, [ovl_buf]
    lea rsi, [s_ec_low]
    call ovl_puts
    lea rbx, [acpi_ec_dump_low]
    mov ecx, 32
    call diag_emit_hexbytes
    mov byte [rdi], 0
    call diag_emit_line

    ; Mid zone (0x20..0x6F) — 80 bytes
    extern acpi_ec_dump_mid
    lea rdi, [ovl_buf]
    lea rsi, [s_ec_mid]
    call ovl_puts
    lea rbx, [acpi_ec_dump_mid]
    mov ecx, 80
    call diag_emit_hexbytes
    mov byte [rdi], 0
    call diag_emit_line

    ; High zone (0x70..0x8F)
    lea rdi, [ovl_buf]
    lea rsi, [s_ec_high]
    call ovl_puts
    lea rbx, [acpi_ec_dump_high]
    mov ecx, 32
    call diag_emit_hexbytes
    mov byte [rdi], 0
    call diag_emit_line
%endif ; NEXUS_DIAG_LEGACY (DCN/IP/EC)

%ifdef NEXUS_GFX_BRINGUP
    ; ---- GFX11 bring-up (H/I/J). See docs/gpu-bringup.md. ----
    extern gfx_bringup
    extern gfx_last_stage
    extern gpu_bringup_state
    extern gpu_bar0_base
    extern gpu_doorbell_base
    extern smu_last_result
    extern smu_last_msg_id
    extern smn_r32
    extern gmc_fault_status

    ; Precondition for the SMN proxy: PCI MEM-decode + bus-master must be
    ; enabled on the AMD display device, and BAR0 needs the UC alias.
    ; Both are done by amd_dcn_probe. When NEXUS_DIAG_LEGACY is off
    ; (the 2026-05-25 DMUB-park default) the diag block doesn't call it,
    ; so we must call it explicitly here or every SMN read returns
    ; 0xFFFFFFFF and writes black-hole (BAR decode disabled).
    extern amd_dcn_probe
    call amd_dcn_probe
    call gfx_bringup
    ; al = post-walk state (0..4, 0xFF on early-bar failure)

    lea rdi, [ovl_buf]
    lea rsi, [s_gfx_hdr]
    call ovl_puts
    movzx edx, byte [gpu_bringup_state]
    call ovl_putu
    lea rsi, [s_gfx_stage]
    call ovl_puts
    movzx edx, byte [gfx_last_stage]
    call ovl_putu                       ; ASCII letter shown as decimal
    lea rsi, [s_gfx_smu]
    call ovl_puts
    mov edx, [smu_last_result]
    call ovl_puth32
    lea rsi, [s_gfx_fault]
    call ovl_puts
    mov edx, [gmc_fault_status]
    call ovl_puth32
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_gfx_bar]
    call ovl_puts
    mov rdx, [gpu_bar0_base]
    call diag_puth64
    lea rsi, [s_gfx_db]
    call ovl_puts
    mov rdx, [gpu_doorbell_base]
    call diag_puth64
    mov byte [rdi], 0
    call diag_emit_line

    ; Raw SMN probe + SMU TestMessage echo. smn_r32 takes its arg in edi,
    ; which is also the overlay-buffer pointer for ovl_*; we save/restore
    ; rdi around every SMN call.
    extern smu_test_echo
    extern smu_disallow_result
    lea rdi, [ovl_buf]
    lea rsi, [s_gfx_smn]
    call ovl_puts
    push rdi                         ; preserve buffer pointer
    mov  edi, 0x03B10A68             ; SMN_MP1_C2PMSG_90
    call smn_r32
    pop  rdi
    mov  edx, eax
    call ovl_puth32
    lea rsi, [s_gfx_smn_idx]
    call ovl_puts
    push rdi
    mov  edi, 0x03B10A08             ; SMN_MP1_C2PMSG_66
    call smn_r32
    pop  rdi
    mov  edx, eax
    call ovl_puth32
    lea rsi, [s_gfx_smn_arg]
    call ovl_puts
    push rdi
    mov  edi, 0x03B10A48             ; SMN_MP1_C2PMSG_82
    call smn_r32
    pop  rdi
    mov  edx, eax
    call ovl_puth32
    mov byte [rdi], 0
    call diag_emit_line

    ; SMU test echo + DisallowGfxOff result (both populated by stage H).
    lea rdi, [ovl_buf]
    lea rsi, [s_gfx_test]
    call ovl_puts
    mov  edx, [smu_test_echo]
    call ovl_puth32
    lea rsi, [s_gfx_dis]
    call ovl_puts
    mov  edx, [smu_disallow_result]
    call ovl_puth32
    lea rsi, [s_gfx_msgid]
    call ovl_puts
    mov  edx, [smu_last_msg_id]
    call ovl_puth32
    mov byte [rdi], 0
    call diag_emit_line

    ; GMC sub-stage diag: where I died, ACK readback, CNTL readback,
    ; fault address.
    extern gmc_substep
    extern gmc_invalidate_ack_seen
    extern gmc_cntl_readback
    extern gmc_fault_addr_lo
    extern gmc_fault_addr_hi
    lea rdi, [ovl_buf]
    lea rsi, [s_gmc_sub]
    call ovl_puts
    movzx edx, byte [gmc_substep]
    call ovl_putu
    lea rsi, [s_gmc_ack]
    call ovl_puts
    mov  edx, [gmc_invalidate_ack_seen]
    call ovl_puth32
    lea rsi, [s_gmc_cntl]
    call ovl_puts
    mov  edx, [gmc_cntl_readback]
    call ovl_puth32
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_gmc_faddr]
    call ovl_puts
    mov  edx, [gmc_fault_addr_hi]
    call ovl_puth32
    mov  edx, [gmc_fault_addr_lo]
    call ovl_puth32
    mov byte [rdi], 0
    call diag_emit_line

    ; CP ring readbacks (J). If state>=4 these confirm CP regs accept
    ; writes. If they read 0xFFFFFFFF or 0 the CP block is gated.
    extern cp_ring_substep
    extern cp_rb0_cntl_readback
    extern cp_rb0_base_readback
    extern cp_rb0_rptr_readback
    lea rdi, [ovl_buf]
    lea rsi, [s_cp_sub]
    call ovl_puts
    movzx edx, byte [cp_ring_substep]
    call ovl_putu
    lea rsi, [s_cp_cntl]
    call ovl_puts
    mov  edx, [cp_rb0_cntl_readback]
    call ovl_puth32
    lea rsi, [s_cp_base]
    call ovl_puts
    mov  edx, [cp_rb0_base_readback]
    call ovl_puth32
    mov byte [rdi], 0
    call diag_emit_line

    ; PSP Wave-3 diagnostics. These are populated only when K is armed via
    ; NEXUS_GFX_WAVE3_FIRE; otherwise they remain zero and prove dormancy.
    extern psp_substep
    extern psp_fw_substep
    extern psp_solution_status
    extern psp_boot_status
    extern psp_c2pmsg33_raw
    extern psp_c2pmsg35_raw
    extern psp_sos_version
    extern psp_c2pmsg64_raw
    extern psp_c2pmsg67_raw
    extern psp_last_cmd
    extern psp_last_resp
    extern psp_tmr_status
    extern psp_fw_status
    extern psp_rlc_size
    extern psp_rlc_ack
    extern psp_rlc_fw_addr_lo
    extern psp_rlc_fw_addr_hi
    lea rdi, [ovl_buf]
    lea rsi, [s_psp_step]
    call ovl_puts
    movzx edx, byte [psp_substep]
    call ovl_putu
    lea rsi, [s_psp_fwstep]
    call ovl_puts
    movzx edx, byte [psp_fw_substep]
    call ovl_putu
    lea rsi, [s_psp_sol]
    call ovl_puts
    mov  edx, [psp_solution_status]
    call ovl_puth32
    lea rsi, [s_psp_boot]
    call ovl_puts
    mov  edx, [psp_boot_status]
    call ovl_puth32
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_psp_c33]
    call ovl_puts
    mov  edx, [psp_c2pmsg33_raw]
    call ovl_puth32
    lea rsi, [s_psp_c35]
    call ovl_puts
    mov  edx, [psp_c2pmsg35_raw]
    call ovl_puth32
    lea rsi, [s_psp_sos]
    call ovl_puts
    mov  edx, [psp_sos_version]
    call ovl_puth32
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_psp_c64]
    call ovl_puts
    mov  edx, [psp_c2pmsg64_raw]
    call ovl_puth32
    lea rsi, [s_psp_c67]
    call ovl_puts
    mov  edx, [psp_c2pmsg67_raw]
    call ovl_puth32
    lea rsi, [s_psp_cmd]
    call ovl_puts
    mov  edx, [psp_last_cmd]
    call ovl_puth32
    lea rsi, [s_psp_resp]
    call ovl_puts
    mov  edx, [psp_last_resp]
    call ovl_puth32
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_psp_tmr]
    call ovl_puts
    mov  edx, [psp_tmr_status]
    call ovl_puth32
    lea rsi, [s_psp_fwstat]
    call ovl_puts
    mov  edx, [psp_fw_status]
    call ovl_puth32
    lea rsi, [s_psp_rlcsz]
    call ovl_puts
    mov  edx, [psp_rlc_size]
    call ovl_puth32
    lea rsi, [s_psp_rlcack]
    call ovl_puts
    mov  edx, [psp_rlc_ack]
    call ovl_puth32
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_psp_rlcaddr]
    call ovl_puts
    mov  edx, [psp_rlc_fw_addr_hi]
    call ovl_puth32
    mov  edx, [psp_rlc_fw_addr_lo]
    call ovl_puth32
    mov byte [rdi], 0
    call diag_emit_line

    ; ---- Task L: CP PFP/ME/MEC PSP acks + un-halt + NOP retire ----
    extern psp_cp_substep
    extern psp_cp_last_type
    extern psp_pfp_size
    extern psp_pfp_ack
    extern psp_me_size
    extern psp_me_ack
    extern psp_mec_size
    extern psp_mec_ack
    extern cp_me_cntl_pre
    extern cp_me_cntl_post
    extern cp_nop_substep
    extern cp_nop_rptr_seen
    extern cp_nop_wptr_target
    extern gfx_last_stage
    extern gpu_bringup_state

    lea rdi, [ovl_buf]
    lea rsi, [s_l_step]
    call ovl_puts
    movzx edx, byte [psp_cp_substep]
    call ovl_putu
    lea rsi, [s_l_type]
    call ovl_puts
    mov  edx, [psp_cp_last_type]
    call ovl_puth32
    lea rsi, [s_l_stage]
    call ovl_puts
    movzx edx, byte [gfx_last_stage]
    call ovl_putu
    lea rsi, [s_l_state]
    call ovl_puts
    movzx edx, byte [gpu_bringup_state]
    call ovl_putu
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_l_pfp]
    call ovl_puts
    mov  edx, [psp_pfp_size]
    call ovl_puth32
    lea rsi, [s_l_ack]
    call ovl_puts
    mov  edx, [psp_pfp_ack]
    call ovl_puth32
    lea rsi, [s_l_me]
    call ovl_puts
    mov  edx, [psp_me_size]
    call ovl_puth32
    lea rsi, [s_l_ack]
    call ovl_puts
    mov  edx, [psp_me_ack]
    call ovl_puth32
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_l_mec]
    call ovl_puts
    mov  edx, [psp_mec_size]
    call ovl_puth32
    lea rsi, [s_l_ack]
    call ovl_puts
    mov  edx, [psp_mec_ack]
    call ovl_puth32
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_l_cme_pre]
    call ovl_puts
    mov  edx, [cp_me_cntl_pre]
    call ovl_puth32
    lea rsi, [s_l_cme_post]
    call ovl_puts
    mov  edx, [cp_me_cntl_post]
    call ovl_puth32
    lea rsi, [s_l_nop_sub]
    call ovl_puts
    movzx edx, byte [cp_nop_substep]
    call ovl_putu
    lea rsi, [s_l_rptr]
    call ovl_puts
    mov  edx, [cp_nop_rptr_seen]
    call ovl_puth32
    mov byte [rdi], 0
    call diag_emit_line

    ; MP0 SMN segment probe retired 2026-05-26 — see amd_gfx.asm. Replaced
    ; with a Phoenix-aware note so the boot screen reflects current strategy.
    lea rdi, [ovl_buf]
    lea rsi, [s_phx_note]
    call ovl_puts
    mov byte [rdi], 0
    call diag_emit_line

    ; ---- IP discovery scan results ------------------------------------------
    extern ip_disc_found
    extern ip_disc_scan_addr
    extern ip_disc_bin_size
    extern ip_disc_version
    extern ip_disc_num_dies
    extern ip_disc_mp0_base
    extern ip_disc_mp1_base
    extern ip_disc_gc_base
    extern ip_disc_mmhub_base
    extern ip_disc_dcn_base
    extern ip_disc_imu_base
    extern ip_disc_vram_hit_offset
    lea rdi, [ovl_buf]
    lea rsi, [s_ipd_hdr]
    call ovl_puts
    movzx edx, byte [ip_disc_found]
    call ovl_putu
    lea rsi, [s_ipd_at]
    call ovl_puts
    mov  rdx, [ip_disc_scan_addr]
    call diag_puth64
    lea rsi, [s_ipd_ver]
    call ovl_puts
    movzx edx, word [ip_disc_version]
    call ovl_puth32
    lea rsi, [s_ipd_dies]
    call ovl_puts
    movzx edx, word [ip_disc_num_dies]
    call ovl_putu
    mov byte [rdi], 0
    call diag_emit_line

    lea rdi, [ovl_buf]
    lea rsi, [s_ipd_mp0]
    call ovl_puts
    mov  edx, [ip_disc_mp0_base]
    call ovl_puth32
    lea rsi, [s_ipd_mp1]
    call ovl_puts
    mov  edx, [ip_disc_mp1_base]
    call ovl_puth32
    lea rsi, [s_ipd_gc]
    call ovl_puts
    mov  edx, [ip_disc_gc_base]
    call ovl_puth32
    lea rsi, [s_ipd_imu]
    call ovl_puts
    mov  edx, [ip_disc_imu_base]
    call ovl_puth32
    lea rsi, [s_ipd_vram]
    call ovl_puts
    mov  edx, [ip_disc_vram_hit_offset]
    call ovl_puth32
    mov byte [rdi], 0
    call diag_emit_line

    ; ---- IMU autoload TOC state ---------------------------------------------
    extern imu_autoload_count
    extern imu_autoload_total_size
    extern imu_autoload_missing
    extern imu_autoload_last_type
    extern imu_autoload_status
    extern imu_autoload_fat_count
    extern imu_autoload_first_name
    lea rdi, [ovl_buf]
    lea rsi, [s_imu_hdr]
    call ovl_puts
    mov  edx, [imu_autoload_count]
    call ovl_putu
    lea rsi, [s_imu_total]
    call ovl_puts
    mov  edx, [imu_autoload_total_size]
    call ovl_puth32
    lea rsi, [s_imu_miss]
    call ovl_puts
    mov  edx, [imu_autoload_missing]
    call ovl_puth32
    lea rsi, [s_imu_last]
    call ovl_puts
    mov  edx, [imu_autoload_last_type]
    call ovl_putu
    lea rsi, [s_imu_kick]
    call ovl_puts
    movzx edx, byte [imu_autoload_status]
    call ovl_putu
    mov byte [rdi], 0
    call diag_emit_line

    ; FAT sanity: file count + first dir entry name. If fat_count == 0 or
    ; the first name is empty, the walk had nothing to iterate. If the
    ; first name looks like "BOOTANIMNBA" or similar, FAT is alive — and
    ; the issue is in our name table or compare path.
    lea rdi, [ovl_buf]
    lea rsi, [s_fat_hdr]
    call ovl_puts
    mov  edx, [imu_autoload_fat_count]
    call ovl_putu
    lea rsi, [s_fat_first]
    call ovl_puts
    ; Append 11 bytes of imu_autoload_first_name verbatim.
    mov  rcx, 11
    lea  rsi, [imu_autoload_first_name]
.fat_name_loop:
    test rcx, rcx
    jz   .fat_name_done
    mov  al, [rsi]
    test al, al
    jz   .fat_name_done
    mov  [rdi], al
    inc  rdi
    inc  rsi
    dec  rcx
    jmp  .fat_name_loop
.fat_name_done:
    mov byte [rdi], 0
    call diag_emit_line
%endif

    pop rcx
    pop rbx

    lea rdi, [ovl_buf]
    lea rsi, [s_diag_end]
    call ovl_puts
    mov byte [rdi], 0
    call diag_emit_line

    pop rdi
    pop rsi
    pop rdx
    pop rax
    ret

; diag_emit_hexbytes - write ECX bytes from [RBX] into [RDI] as two-hex-digit
; chars (no separators). RDI advanced. Clobbers RAX, RCX, RBX, RDX.
diag_emit_hexbytes:
.hbloop:
    test ecx, ecx
    jz .hbdone
    movzx eax, byte [rbx]
    mov edx, eax
    shr edx, 4
    and edx, 0x0F
    cmp edx, 10
    jl .hb_h1d
    add edx, 'A'-10
    jmp .hb_h1s
.hb_h1d:
    add edx, '0'
.hb_h1s:
    mov [rdi], dl
    inc rdi
    mov edx, eax
    and edx, 0x0F
    cmp edx, 10
    jl .hb_h2d
    add edx, 'A'-10
    jmp .hb_h2s
.hb_h2d:
    add edx, '0'
.hb_h2s:
    mov [rdi], dl
    inc rdi
    inc rbx
    dec ecx
    jmp .hbloop
.hbdone:
    ret

diag_emit_line:
    push rsi
    lea rsi, [ovl_buf]
    call debug_print
    lea rsi, [ovl_buf]
    call svg_dump_puts
    mov al, 13
    call svg_dump_putc
    mov al, 10
    call svg_dump_putc
    pop rsi
    ret

diag_puth64:
    push rax
    push rcx
    mov ecx, 16
.h64_loop:
    rol rdx, 4
    mov rax, rdx
    and eax, 0x0F
    cmp eax, 10
    jl .h64_digit
    add eax, 'A' - 10
    jmp .h64_store
.h64_digit:
    add eax, '0'
.h64_store:
    mov [rdi], al
    inc rdi
    dec ecx
    jnz .h64_loop
    pop rcx
    pop rax
    ret

serial_dispatch_control.svg_dump:
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

serial_dispatch_control.close_focused:
    mov rdi, [wm_focused_window]
    cmp rdi, -1
    je serial_dispatch_control.control_done
    sub rsp, 8
    call wm_close_window
    add rsp, 8
    mov byte [scene_dirty], 1

serial_dispatch_control.control_done:
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
net_ping_start_msg db "[NETPING START]", 10, 0
net_ping_ics_start_msg db "[NETPING ICS START]", 10, 0
net_ping_google_start_msg db "[NETPING GOOGLE START]", 10, 0
net_ping_ok_msg db "[NETPING OK]", 10, 0
net_ping_fail_msg db "[NETPING FAIL]", 10, 0

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
    push rax
    push rdx
    mov rdi, [rax + WIN_OFF_KEYFN]
    mov rsi, rax
    mov rdx, WIN_OFF_KEYFN
    call cpi_verify_callback
    mov r9, rax
    pop rdx
    pop rax
    test r9, r9
    jz .input_done

    movzx edx, dl
    shl edx, 8
    or edx, 0x01000000
    mov rsi, rax
    mov rdi, r9
    call dispatch_app_callback
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
    mov al, [process_mouse_last_buttons]
    mov [process_mouse_prev_buttons], al
    mov [process_mouse_last_buttons], dl
    ; If context menu is visible and left button just pressed, handle it
    ; before anything else can swallow the click.
    test dl, 1
    jz .pm_no_ctx_consume
    test byte [process_mouse_prev_buttons], 1
    jnz .pm_no_ctx_consume
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
    test byte [process_mouse_prev_buttons], 1
    jnz .pm_no_click
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
    test byte [process_mouse_prev_buttons], 2
    jnz .pm_no_click
    call tb_handle_rclick
    test eax, eax
    jnz .pm_rclick_done
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

    ; --- klog overlay hotkeys ---
    ; The minus key '-' is the always-available global toggle. Checked here
    ; (before window-focus forwarding) so it works at any time: boot, desktop,
    ; while a window has focus, while typing in notepad, etc. The trade-off is
    ; that you cannot type a literal '-' inside apps -- that is intentional per
    ; user request ("use - for opening logs at any moment").
    ; F12 and backtick remain as alternates.
    cmp cl, '='
    je .pk_real_boot_diag
    cmp cl, '-'
    je .pk_klog_toggle
    cmp cl, '`'
    je .pk_klog_toggle
    cmp cl, '~'
    je .pk_klog_toggle
    cmp cl, KEY_F12
    je .pk_klog_toggle
    jmp .pk_not_toggle
.pk_klog_toggle:
    extern klog_toggle
    call klog_toggle
    mov byte [scene_dirty], 1
    ret
.pk_not_toggle:
    ; F11 always flushes+reboots (works if Fn-lock is on).
    cmp cl, KEY_F11
    jne .pk_not_f11
    extern klog_flush_and_reboot
    call klog_flush_and_reboot          ; does not return
.pk_not_f11:
    ; While the overlay is up, Up/Down scroll it and the key is consumed
    ; (do not forward to the focused window).
    extern klog_visible
    cmp byte [klog_visible], 0
    je .pk_overlay_closed
    ; Enter (ASCII 13) flushes+reboots while overlay is visible.
    cmp cl, 13
    jne .pk_ovl_chk_up
    extern klog_flush_and_reboot
    call klog_flush_and_reboot          ; does not return
.pk_ovl_chk_up:
    extern klog_scroll
    cmp bl, 0xC8                       ; Up arrow -> older lines
    jne .pk_ovl_chk_down
    mov edi, 4
    call klog_scroll
    mov byte [scene_dirty], 1
    ret
.pk_ovl_chk_down:
    cmp bl, 0xD0                       ; Down arrow -> newer lines
    jne .pk_overlay_consume
    mov edi, -4
    call klog_scroll
    mov byte [scene_dirty], 1
    ret
.pk_overlay_consume:
    ; Any other key while overlay is open is dropped to avoid acting on the
    ; world you can't see.
    mov byte [scene_dirty], 1
    ret
.pk_overlay_closed:
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
    push rax
    mov rdi, [rax + WIN_OFF_KEYFN]
    mov rsi, rax
    mov rdx, WIN_OFF_KEYFN
    call cpi_verify_callback
    mov r9, rax
    pop rax
    test r9, r9
    jz .pk_done
    mov rsi, rax
    mov rdi, r9
    mov edx, r15d
    call dispatch_app_callback
.pk_forward_done:
    mov byte [scene_dirty], 1
.pk_done:
    ret
.pk_real_boot_diag:
    call real_boot_diag_dump
    extern klog_visible
    mov byte [klog_visible], 1
    mov byte [scene_dirty], 1
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
.pk_kr_done:
    mov byte [scene_dirty], 1
    ret

; ============================================================================
; Render one frame
; ============================================================================
render_frame:
    ; If the F12 klog overlay is up, it owns the whole screen this frame.
    ; Draw it directly into the backbuffer, full-flush, and skip desktop
    ; rendering entirely. The cursor still gets drawn on top so the user
    ; can dismiss menus, etc.
    extern klog_visible
    cmp byte [klog_visible], 0
    je .rf_no_overlay
    extern klog_render_overlay
    call klog_render_overlay
    call render_mark_full
    call render_flush
    mov edi, [mouse_x]
    mov esi, [mouse_y]
    call cursor_draw
    ret
.rf_no_overlay:
    extern wallpaper_render_active
    cmp byte [wallpaper_render_active], 0
    je .rf_no_wallpaper_render
    extern wm_poll_wallpaper_render
    call wm_poll_wallpaper_render
    cmp byte [wallpaper_render_active], 0
    je .rf_no_wallpaper_render
    jmp .rf_wallpaper_busy_present
.rf_no_wallpaper_render:
    call taskmgr_live_refresh
    call media_live_refresh
    ; Caret blink previously dirtied the whole scene every 300ms, forcing a
    ; full desktop repaint 3x/sec even when idle. That alone burned ~30% of a
    ; core on real hardware. Track the phase for any code that wants to read
    ; it, but do NOT mark the scene dirty here.
    mov rax, [tick_count]
    xor edx, edx
    mov ecx, 30
    div ecx
    and al, 1
    mov [ui_blink_phase], al
    cmp qword [wm_drag_window_id], -1
    jne .rf_draw_drag
    cmp byte [scene_dirty], 0
    je .rf_maybe_fast_path
    jmp .rf_full_path
.rf_maybe_fast_path:
    ; True idle: nothing dirty, no drag. Skip the entire fast path (vsync
    ; wait + FPS region blit + cursor redraw) unless the mouse moved or the
    ; FPS counter changed.
    mov eax, [mouse_x]
    cmp eax, [rf_last_mouse_x]
    jne .rf_fast_path
    mov eax, [mouse_y]
    cmp eax, [rf_last_mouse_y]
    jne .rf_fast_path
    mov eax, [last_fps]
    cmp eax, [rf_last_fps]
    jne .rf_fast_path
    ret
.rf_full_path:
    call wm_draw_desktop
    cmp byte [wallpaper_render_active], 0
    jne .rf_wallpaper_busy_after_draw
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
    mov eax, [mouse_x]
    mov [rf_last_mouse_x], eax
    mov eax, [mouse_y]
    mov [rf_last_mouse_y], eax
    mov eax, [last_fps]
    mov [rf_last_fps], eax
    ret
.rf_wallpaper_busy_after_draw:
    mov byte [scene_dirty], 1
    ret
.rf_wallpaper_busy_present:
    ; The wallpaper AP owns the app callback lock while SVG rasterization is
    ; active, so do not call wm_draw_desktop/wm_draw_window here. Present a
    ; compositor-only frame from the last completed desktop snapshot: taskbar,
    ; menus, drag outline, FPS, and cursor still update while app content waits.
    call render_restore_backbuffer
    call tb_draw
    call tb_draw_submenu
    call ctx_menu_draw
    cmp qword [wm_drag_window_id], -1
    je .rf_busy_no_drag
    call wm_draw_drag_outline
.rf_busy_no_drag:
    call .rf_update_fps
    call .rf_draw_fps_text
    cmp byte [vsync_enabled], 1
    jne .fr_skip_busy_vs
    call wait_vsync
.fr_skip_busy_vs:
    call cursor_hide
    call render_mark_full
    call render_flush
    mov edi, [mouse_x]
    mov esi, [mouse_y]
    call cursor_draw
    mov eax, [mouse_x]
    mov [rf_last_mouse_x], eax
    mov eax, [mouse_y]
    mov [rf_last_mouse_y], eax
    mov eax, [last_fps]
    mov [rf_last_fps], eax
    mov byte [scene_dirty], 1
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
    mov eax, [mouse_x]
    mov [rf_last_mouse_x], eax
    mov eax, [mouse_y]
    mov [rf_last_mouse_y], eax
    mov eax, [last_fps]
    mov [rf_last_fps], eax
    ret
.rf_draw_drag:
    call render_restore_dirty_backbuffer
    call wm_draw_drag_outline
    call .rf_update_fps
    call .rf_draw_fps_text
    mov edi, FPS_REGION_X
    mov esi, FPS_REGION_Y
    mov edx, FPS_REGION_W
    mov ecx, FPS_REGION_H
    call render_mark_dirty
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

; Task Manager displays live counters, so keep it repainting while open even
; when no input event has dirtied the desktop. Keep the cadence low: this path
; dirties the whole desktop, so a high refresh rate makes Task Manager itself
; show up as idle CPU load.
taskmgr_live_refresh:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    mov rcx, [tick_count]
    mov rax, rcx
    sub rax, [taskmgr_last_refresh_tick]
    cmp rax, 100
    jb .done
    mov [taskmgr_last_refresh_tick], rcx
    mov rbx, WINDOW_POOL_ADDR
    xor ecx, ecx
.scan:
    cmp ecx, MAX_WINDOWS
    jae .done
    test qword [rbx + WIN_OFF_FLAGS], WF_ACTIVE
    jz .next
    test qword [rbx + WIN_OFF_FLAGS], WF_VISIBLE
    jz .next
    test qword [rbx + WIN_OFF_FLAGS], WF_MINIMIZED
    jnz .next
    mov rax, app_hl_taskmgr_draw
    cmp [rbx + WIN_OFF_DRAWFN], rax
    jne .next
    test qword [rbx + WIN_OFF_FLAGS], WF_FOCUSED
    jz .mark_scene_dirty
    mov rdi, [rbx + WIN_OFF_ID]
    call cursor_hide
    call wm_draw_window
    mov edi, [rbx + WIN_OFF_X]
    mov esi, [rbx + WIN_OFF_Y]
    mov edx, [rbx + WIN_OFF_W]
    mov ecx, [rbx + WIN_OFF_H]
    call render_mark_dirty
    call render_save_dirty_backbuffer
    call render_flush
    mov edi, [mouse_x]
    mov esi, [mouse_y]
    call cursor_draw
    jmp .done
.mark_scene_dirty:
    mov byte [scene_dirty], 1
    jmp .done
.next:
    add rbx, WINDOW_STRUCT_SIZE
    inc ecx
    jmp .scan
.done:
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; Repaint a focused Media Player NBA window only when it has real work: a seek
; is pending, the first timer seed is needed, or the next source frame is due.
; The focused fast path redraws and flushes just the window rectangle, avoiding
; a full desktop repaint/flip for every video frame.
media_live_refresh:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    push r9
    push r10

    mov rbx, WINDOW_POOL_ADDR
    xor ecx, ecx
.scan:
    cmp ecx, MAX_WINDOWS
    jae .done
    test qword [rbx + WIN_OFF_FLAGS], WF_ACTIVE
    jz .next
    test qword [rbx + WIN_OFF_FLAGS], WF_VISIBLE
    jz .next
    test qword [rbx + WIN_OFF_FLAGS], WF_MINIMIZED
    jnz .next
    mov rax, app_media_draw
    cmp [rbx + WIN_OFF_DRAWFN], rax
    jne .next

    mov edi, [rbx + WIN_OFF_ID]
    call l3_slot_base
    mov rdx, rax
    mov r9, rax
    ; SMAP: rdx/r9 are a user (PTE.U=1) slot base. This scan reads several slot
    ; fields before deciding whether to wake the compositor. Arm AC across the
    ; reads; every exit (.next, .wake) re-arms SMAP via USER_ACCESS_END. clac is
    ; harmless on the paths that reach those labels without having set AC.
    USER_ACCESS_BEGIN
    cmp dword [rdx + APP_SLOT_BMP_FILE_OFF], NBA1_MAGIC
    jne .next
    cmp dword [rdx + APP_SLOT_BMP_FILE_OFF + 12], 1    ; frame_count
    jbe .next
    cmp dword [rdx + APP_SLOT_BMP_FILE_OFF + 16], 0    ; fps
    je .next
    cmp dword [rdx + app_hl_media_mp_paused - app_blob_start], 0
    jne .next

    cmp dword [rdx + app_hl_media_mp_seek_to - app_blob_start], 0
    jne .wake

    mov r8, [rdx + app_hl_media_mp_last_tick - app_blob_start]
    test r8, r8
    jz .wake

    ; interval_ticks = max(1, 100 / fps). This preserves native clip FPS up to
    ; the 100 Hz PIT cadence.
    mov eax, 100
    xor edx, edx
    mov edi, [r9 + APP_SLOT_BMP_FILE_OFF + 16]
    div edi
    test eax, eax
    jnz .interval_ok
    mov eax, 1
.interval_ok:
    mov r10, [tick_count]
    sub r10, r8
    cmp r10d, eax
    jb .next

.wake:
    USER_ACCESS_END
    cmp byte [scene_dirty], 0
    jne .mark_scene_dirty
    test qword [rbx + WIN_OFF_FLAGS], WF_FOCUSED
    jz .mark_scene_dirty
    call cursor_hide
    mov byte [media_direct_present], 1
    mov byte [media_direct_presented], 0
    mov rdi, rbx
    call media_draw_dispatch
    mov byte [media_direct_present], 0
    cmp byte [media_direct_presented], 1
    je .direct_presented
    mov edi, [rbx + WIN_OFF_X]
    add edi, BORDER_WIDTH
    mov esi, [rbx + WIN_OFF_Y]
    add esi, TITLEBAR_HEIGHT
    mov edx, [rbx + WIN_OFF_W]
    sub edx, BORDER_WIDTH * 2
    mov ecx, [rbx + WIN_OFF_H]
    sub ecx, TITLEBAR_HEIGHT
    sub ecx, BORDER_WIDTH
    call render_mark_dirty
    call render_save_dirty_backbuffer
    call render_flush
    jmp .draw_cursor_done
.direct_presented:
    ; Video pixels and fill-rect controls were already mirrored to GOP/VRAM.
    ; Flush only the small control strip so draw_string time text is visible.
    mov edi, [rbx + WIN_OFF_X]
    add edi, BORDER_WIDTH
    mov esi, [rbx + WIN_OFF_Y]
    add esi, [rbx + WIN_OFF_H]
    sub esi, BORDER_WIDTH
    sub esi, 26
    mov edx, [rbx + WIN_OFF_W]
    sub edx, BORDER_WIDTH * 2
    mov ecx, 26
    call render_mark_dirty
    call render_save_dirty_backbuffer
    call render_flush
.draw_cursor_done:
    mov edi, [mouse_x]
    mov esi, [mouse_y]
    call cursor_draw
    jmp .done
.mark_scene_dirty:
    mov byte [scene_dirty], 1
    jmp .done
.next:
    USER_ACCESS_END
    add rbx, WINDOW_STRUCT_SIZE
    inc ecx
    jmp .scan
.done:
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

section .data
szFPSPrefix db "FPS:", 0
fps_str     times 16 db 0

; Real-hardware iGPU bring-up diagnostics. '=' appends these lines to the klog
; and opens the existing full-screen klog viewer; no USB/file write required.
s_diag_begin     db "IGPUDBG:BEGIN v1", 0
s_diag_end       db "IGPUDBG:END", 0
s_diag_boot      db "BOOT fb=", 0
s_diag_mem       db "MEM backbuf=", 0
s_diag_disp      db "DISP fb=", 0
s_diag_native    db "NATIVE ", 0
s_diag_pci       db "PCI gpuCount=", 0
s_diag_780m_line db "PCI780M bdf=", 0
s_diag_780m_bar  db "PCI780M bar0=", 0
s_diag_amd_line  db "PCIAMD bdf=", 0
s_diag_amddisp   db "AMDDISP active=", 0
s_diag_amdmode   db "AMDMODE ", 0
s_diag_loop      db "LOOP iters=", 0
s_diag_input     db "INPUT numlock=", 0
s_diag_w         db " w=", 0
s_diag_h         db " h=", 0
s_diag_x         db "x", 0
s_diag_pitch     db " pitch=", 0
s_diag_bpp       db " bpp=", 0
s_diag_sz        db " size=", 0
s_diag_apps      db " apps=", 0
s_diag_bb        db " bb=", 0
s_diag_vsync     db " vsync=", 0
s_diag_fps       db " fps=", 0
s_diag_780m      db " 780m=", 0
s_diag_amd       db " amd=", 0
s_diag_id        db " id=", 0
s_diag_class     db " class=", 0
s_diag_cmd       db " cmd=", 0
s_diag_status    db " status=", 0
s_diag_bdf       db " bdf=", 0
s_diag_fb        db " fb=", 0
s_diag_usbkb     db " usbKb=", 0
s_diag_usbkb2    db " usbKb2=", 0
s_diag_xhci      db " xhci=", 0
s_diag_fs        db "FS rdBase=", 0
s_diag_fs_sz     db " rdSize=", 0
s_diag_fs_tot    db " fatTot=", 0
s_diag_fs_n      db " files=", 0
s_diag_fs2       db "FS rdAct=", 0
s_diag_fs2_b0    db " rdQ0=", 0
s_diag_fs2_sb    db " sbQ0=", 0

s_fbp_hdr        db "FBPERF init=", 0
s_fbp_patok      db " patSup=", 0
s_fbp_cr4        db " cr4=", 0
s_fbp_pat        db "FBPERF PAT=", 0
s_fbp_mtrrcap    db " mtrrCap=", 0
s_fbp_mtrrdef    db " mtrrDef=", 0
s_fbp_mtrrn      db " varN=", 0
s_fbp_pteline    db "FBPERF leafLvl=", 0
s_fbp_pteval     db " leafVal=", 0
s_fbp_caching    db " cache=", 0
s_fbp_wcplan     db "FBPERF wcPlanPAT=", 0
s_fbp_wcarm      db " armed=", 0
s_fbp_wcact      db " activated=", 0
s_fbp_mtrri      db "FBPERF mtrr#", 0
s_fbp_mtrri_b    db " base=", 0
s_fbp_mtrri_m    db " mask=", 0
s_wcact_tag      db "[FBPERF] wc_activate rax=", 0
s_wcact_fail     db "[FBPERF] WC activation FAILED -- halting (see codes in fbperf.asm)", 0
s_fbp_flips      db "FBPERF flips=", 0
s_fbp_full       db " full=", 0
s_fbp_rect       db " rect=", 0
s_fbp_fbytes     db " fullB=", 0
s_fbp_rbytes     db " rectB=", 0
s_fbp_tbytes     db " totB=", 0
s_fbp_tsctot     db "FBPERF tscTot=", 0
s_fbp_tscmin     db " tscMin=", 0
s_fbp_tscmax     db " tscMax=", 0
s_fbp_tsclast    db " tscLast=", 0

; --- GFX11 bring-up diag labels ---
s_gfx_hdr     db "GFX state=", 0
s_gfx_stage   db " stage=", 0
s_gfx_smu     db " smu=", 0
s_gfx_fault   db " fault=", 0
s_gfx_bar     db "GFX bar0=", 0
s_gfx_db      db " db=", 0
s_gfx_smn     db "SMN c2p90=", 0
s_gfx_smn_idx db " c2p66=", 0
s_gfx_smn_arg db " c2p82=", 0
s_gfx_test    db "SMU test=", 0
s_gfx_dis     db " disGfx=", 0
s_gfx_msgid   db " lastMsg=", 0
s_gmc_sub     db "GMC step=", 0
s_gmc_ack     db " ack=", 0
s_gmc_cntl    db " cntl=", 0
s_gmc_faddr   db "GMC faddr=", 0
s_cp_sub      db "CP step=", 0
s_cp_cntl     db " cntl=", 0
s_cp_base     db " base=", 0
s_psp_step    db "PSP step=", 0
s_psp_fwstep  db " fwstep=", 0
s_psp_sol     db " sol=", 0
s_psp_boot    db " boot=", 0
s_psp_c33     db "PSP c33=", 0
s_psp_c35     db " c35=", 0
s_psp_sos     db " sos=", 0
s_psp_c64     db "PSP c64=", 0
s_psp_c67     db " c67=", 0
s_psp_cmd     db " cmd=", 0
s_psp_resp    db " resp=", 0
s_psp_tmr     db "PSP tmr=", 0
s_psp_fwstat  db " fwstat=", 0
s_psp_rlcsz   db " rlcSz=", 0
s_psp_rlcack  db " rlcAck=", 0
s_psp_rlcaddr db "PSP rlcAddr=", 0

; --- Task L (CP PFP/ME/MEC + un-halt + NOP) labels ---
s_l_step      db "L step=", 0
s_l_type      db " type=", 0
s_l_stage     db " stage=", 0
s_l_state     db " state=", 0
s_l_pfp       db "L pfpSz=", 0
s_l_me        db " meSz=", 0
s_l_mec       db "L mecSz=", 0
s_l_ack       db " ack=", 0
s_l_cme_pre   db "L cmePre=", 0
s_l_cme_post  db " cmePost=", 0
s_l_nop_sub   db " nop=", 0
s_l_rptr      db " rptr=", 0

; --- MP0 SMN segment probe labels ---
s_probe_hdr   db "MP0 PROBE done=", 0
s_probe_seg   db "seg=", 0
s_phx_note    db "PHX gfx_11_0_3: PSP via BAR0 MMIO (not SMN); awaiting IP-disc + FW blobs", 0
s_imu_hdr     db "IMU autoload n=", 0
s_imu_total   db " total=", 0
s_imu_miss    db " miss=", 0
s_imu_last    db " lastType=", 0
s_imu_kick    db " kick=", 0
s_fat_hdr     db "FAT n=", 0
s_fat_first   db " first=", 0
s_ipd_hdr     db "IPDISC found=", 0
s_ipd_at      db " at=", 0
s_ipd_ver     db " ver=", 0
s_ipd_dies    db " dies=", 0
s_ipd_mp0     db "IPDISC MP0=", 0
s_ipd_mp1     db " MP1=", 0
s_ipd_gc      db " GC=", 0
s_ipd_imu     db " IMU=", 0
s_ipd_vram    db " vramHit=", 0
s_probe_c33   db " c33=", 0
s_probe_c58   db " c58=", 0
s_probe_c64   db " c64=", 0
s_probe_c81   db " c81=", 0

; --- DCN read-only probe labels ---
s_dcn_hdr     db "DCN bar0=", 0
s_dcn_ok      db " mmio=", 0
s_dcn_lvl     db " pteLvl=", 0
s_dcn_pat     db " patIdx=", 0
s_dcn_cache   db " cache=", 0
s_dcn_pte     db "DCN pte=", 0
s_dcn_r0      db "DCN r00=", 0
s_dcn_r4      db " r04=", 0
s_dcn_r8      db " r08=", 0
s_dcn_rC      db " r0C=", 0
s_dcn_cfg     db "DCN cfg=", 0
s_dcn_cmd_pre db " cmdPre=", 0
s_dcn_cmd_post db " cmdPost=", 0
s_dcn_uc_hdr  db "DCN UC ok=", 0
s_dcn_uc_r0   db " r0000=", 0
s_dcn_uc_r4   db " r0004=", 0
s_dcn_uc_r8   db " r1000=", 0
s_dcn_uc_rC   db " r3000=", 0
s_dcn_uc_walk db "DCN UC walkLvl=", 0
s_dcn_uc_walk_p db " walkPte=", 0
s_dcn_ip_hdr  db "DCN IP table (off:val, non-zero only):", 0
s_dcn_ip_pfx  db "IP+", 0
s_dcn_eq      db "=", 0
s_dcn_sp      db " ", 0
s_dcn_bl_hdr  db "DCN BL hunt @BAR0+0x", 0
s_dcn_bl_pfx  db "BL+", 0
s_dmub_hdr    db "DMUB ok=", 0
s_dmub_cntl   db " cntl=", 0
s_dmub_cntl2  db " cntl2=", 0
s_dmub_sec    db " sec=", 0
s_dmub_scr0   db "DMUB scratch0=", 0
s_dmub_bits   db " bits=", 0
s_dmub_scr7   db " scratch7=", 0
s_dmub_timer  db " timer=", 0
s_dmub_state  db "DMUB state=", 0
s_dmub_s1     db " scratch1=", 0
s_dmub_s14    db " scratch14=", 0
s_dmub_s15    db " scratch15=", 0
s_dmub_fbraw  db "DMUB fbBaseReg=", 0
s_dmub_fboffraw db " fbOffReg=", 0
s_dmub_fbbase db " fbBase=", 0
s_dmub_fboff  db " fbOff=", 0
s_dmub_ring   db "DMUB ring arm=", 0
s_dmub_rstat  db " status=", 0
s_dmub_rphys  db " sys=", 0
s_dmub_rfb    db " fb=", 0
s_dmub_ring2  db "DMUB ring inFb=", 0
s_dmub_outfb  db " outFb=", 0
s_dmub_gpstat db " gpStat=", 0
s_dmub_gpreq  db " gpReq=", 0
s_dmub_gpresp db " gpResp=", 0
s_dmub_cw6      db "DMUB cw6 base=", 0
s_dmub_cw6_top  db " top=", 0
s_dmub_cw6_olo  db " offLo=", 0
s_dmub_cw6_ohi  db " offHi=", 0
s_fw_a          db "FW stat=", 0
s_fw_size       db " size=", 0
s_fw_inst       db " inst=", 0
s_fw_ver        db " ver=", 0
s_fw_b          db "FW region=", 0
s_fw_trace      db " trace=", 0
s_fw_ss         db " ss=", 0
s_fw_feat       db " feat=", 0
s_dmub_gp2    db "DMUB gp2 dataOut=", 0
s_dmub_gppolls db " polls=", 0
s_dmub_gpstart db " t0=", 0
s_dmub_gpend  db " t1=", 0
s_dmub_cmd    db "DMUB cmd stat=", 0
s_dmub_cmd_r0 db " r0=", 0
s_dmub_cmd_w0 db " w0=", 0
s_dmub_cmd_r1 db " r1=", 0
s_dmub_cmd_w1 db " w1=", 0
s_dmub_cmd2   db "DMUB cmd q0=", 0
s_dmub_cmd_q1 db " q1=", 0
s_dmub_inb    db "DMUB inb1 base=", 0
s_dmub_outb   db "DMUB outb1 base=", 0
s_dmub_size   db " size=", 0
s_dmub_rptr   db " rptr=", 0
s_dmub_wptr   db " wptr=", 0
s_dmub_gpint  db "DMUB gpint in=", 0
s_dmub_out    db " out=", 0
s_dmub_ifault db " iflt=", 0
s_dmub_dfault db " dflt=", 0
s_dmub_ufault db " uflt=", 0

; --- ACPI EC RAM labels ---
s_ec_hdr      db "EC dumpOk=", 0
s_ec_low      db "EC[00..1F]=", 0
s_ec_mid      db "EC[20..6F]=", 0
s_ec_high     db "EC[70..8F]=", 0

; --- USB-mouse debug overlay scratch + labels ---
ovl_buf     times 192 db 0
s_o_l1      db "xhci=", 0
s_o_noxhci  db "  noXHCI=", 0
s_o_mact    db "  mouseAct=", 0
s_o_retry   db "  retry=", 0
s_o_stage   db "  STAGE=", 0
s_o_stagemax db " max=", 0
s_o_fpn     db " fpCalls=", 0
s_o_hwslot  db "  hwSlot=", 0
s_o_port    db "port=", 0
s_o_spd     db "  speed=", 0
s_o_slot    db "  slot1=", 0
s_o_s2      db "  slot2act=", 0
s_o_ep      db "epAddr=", 0
s_o_mps     db "  maxpkt=", 0
s_o_proto   db "  hidProto=", 0
s_o_evt     db "xferEvt=", 0
s_o_rpt     db "  reports=", 0
s_o_err     db "  errs=", 0
s_o_ec      db "  errCode=", 0
s_o_adn     db "  adN=", 0
s_o_adcc    db " adCC=", 0
s_o_scr     db " scratch=", 0
s_o_scr_req db "/", 0
s_o_adst_h  db "adSt=", 0
s_o_cc1     db "  cc1=", 0
s_o_cc2     db "  cc2=", 0
s_o_portsc  db "  PORTSC=", 0
s_o_slotst  db "  slotSt=", 0
s_o_rst_h   db "rstSt=", 0
s_o_ped     db "  PED=", 0
s_o_ccs     db "  CCS=", 0
s_o_sppre   db "  spPre=", 0
s_o_sppost  db "  spPost=", 0
s_o_pscpre  db "  pscPre=", 0
s_o_pscpost db "  pscPost=", 0
s_o_wrt     db "wrt=", 0
s_o_imm     db "  imm=", 0
s_o_wait    db "  wait=", 0
s_o_polls   db "  pls=", 0
s_o_r0      db "report b0=", 0
s_o_r1      db "  dX=", 0
s_o_r2      db "  dY=", 0
s_o_r3      db "  b3=", 0
s_o_noctrl  db "PCI scan: no xHCI controller found", 0
s_o_ctrl    db "xHCI#", 0
s_o_cbus    db " bus=", 0
s_o_cdev    db " dev=", 0
s_o_cfn     db " fn=", 0
s_o_cports  db " ports=", 0
s_o_cmap    db " map=", 0
s_o_init    db "init#", 0
s_o_istage  db " stage=", 0
s_o_fp      db "findPort#", 0
s_o_ml_iters db "ML iters=", 0
s_o_ml_stage db "  stage=", 0
s_o_ml_done  db "  done=", 0
s_o_ml_tick  db "  tick=", 0
s_o_fmp     db " ports=", 0
s_o_fr      db " result=", 0
s_o_fmap    db " sees=", 0

ovl_ci      dd 0
ovl_li      dd 0
ovl_rec     dq 0
; PCI xHCI inventory: scanned once. Up to 4 controllers, 64-byte records:
;  +0 bus  +1 dev  +2 fn  +3 maxports  +4..: per-port speed code (0 = empty)
global usb_dbg_pci_done
usb_dbg_pci_done:  db 0
usb_dbg_xhci_n:    db 0
usb_dbg_xhci_rec:  times 4*64 db 0

; BSP CPU utilization accounting (see cpu_acct_* routines above).
global bsp_util
bsp_util         dd 0
acct_last_mark   dq 0
acct_work_start  dq 0
acct_busy_acc    dq 0
acct_idle_acc    dq 0
acct_win_tick    dq 0
acct_tsc_start   dq 0
taskmgr_last_refresh_tick dq 0

section .bss
serial_command_armed resb 1
ui_blink_phase resb 1
process_mouse_last_buttons resb 1
process_mouse_prev_buttons resb 1
