; ============================================================================
; gesture_update - Update gesture detection state machine
; Input:  EDI = contact count (0-10)
;         ESI = tip switch (0 or 1)
; Called once per touchpad report from hid_process_touchpad_report.
; ============================================================================
; auto-wrapped (FN_BEGIN emits global): global gesture_update
FN_BEGIN gesture_update, 0, 0, FN_RET_SCALAR
    push rax
    push rbx
    push rcx
    push rdx

    mov eax, edi                ; contact count
    mov ecx, esi                ; tip switch

    ; --- Tap-to-click detection ---
    ; Transition: 0 contacts -> 1 contact = finger down
    cmp byte [gesture_prev_count], 0
    jne .not_tap_start
    cmp eax, 1
    jne .not_tap_start
    ; Finger just touched - record start
    mov rbx, [tick_count]
    mov [gesture_tap_start_tick], rbx
    mov ebx, [mouse_x]
    mov [gesture_tap_start_x], ebx
    mov ebx, [mouse_y]
    mov [gesture_tap_start_y], ebx
    mov byte [gesture_tap_pending], 1
    jmp .check_scroll

.not_tap_start:
    ; Transition: 1 contact -> 0 contacts = finger lifted
    cmp byte [gesture_prev_count], 1
    jne .not_tap_end
    cmp eax, 0
    jne .not_tap_end
    cmp byte [gesture_tap_pending], 0
    je .not_tap_end

    ; Finger lifted - check if it's a tap
    mov byte [gesture_tap_pending], 0
    mov rbx, [tick_count]
    sub rbx, [gesture_tap_start_tick]
    cmp rbx, 25                 ; < 250ms (25 ticks at 100Hz)
    jg .not_tap_end

    ; Check distance moved
    mov ebx, [mouse_x]
    sub ebx, [gesture_tap_start_x]
    ; abs(ebx)
    test ebx, ebx
    jns .tap_dx_pos
    neg ebx
.tap_dx_pos:
    cmp ebx, 20
    jg .not_tap_end

    mov ebx, [mouse_y]
    sub ebx, [gesture_tap_start_y]
    test ebx, ebx
    jns .tap_dy_pos
    neg ebx
.tap_dy_pos:
    cmp ebx, 20
    jg .not_tap_end

    ; It's a tap! Generate click
    mov byte [gesture_tap_click], 1
    jmp .check_scroll

.not_tap_end:
    ; If contact count > 1, cancel tap
    cmp eax, 1
    jle .check_scroll
    mov byte [gesture_tap_pending], 0

.check_scroll:
    ; --- Two-finger scroll detection ---
    ; Transition: anything -> 2 contacts = start scroll
    cmp eax, 2
    jne .not_scroll_active

    cmp byte [gesture_scroll_active], 1
    je .scroll_continue

    ; Start scrolling - use averaged two-finger Y if available, else mouse_y
    mov byte [gesture_scroll_active], 1
    mov ebx, [hid_f1_avg_y]
    test ebx, ebx
    jnz .scroll_start_ref
    mov ebx, [mouse_y]
.scroll_start_ref:
    mov [gesture_scroll_ref_y], ebx
    mov ebx, [mouse_x]
    mov [gesture_scroll_ref_x], ebx
    jmp .gesture_done

.scroll_continue:
    ; Compute scroll delta using best available position
    mov ebx, [hid_f1_avg_y]
    test ebx, ebx
    jnz .scroll_use_avg
    mov ebx, [mouse_y]
.scroll_use_avg:
    sub ebx, [gesture_scroll_ref_y]
    ; Scale: divide by 8 for smoother scrolling
    sar ebx, 3
    mov [mouse_scroll_y], ebx

    ; Update reference
    mov ebx, [hid_f1_avg_y]
    test ebx, ebx
    jnz .scroll_ref_avg
    mov ebx, [mouse_y]
.scroll_ref_avg:
    mov [gesture_scroll_ref_y], ebx
    jmp .gesture_done

.not_scroll_active:
    ; If we were scrolling and contact count dropped, stop
    cmp byte [gesture_scroll_active], 1
    jne .check_pinch
    mov byte [gesture_scroll_active], 0
    mov dword [mouse_scroll_y], 0

.check_pinch:
    ; --- Pinch-to-zoom: 2 fingers, compute Manhattan distance delta ---
    cmp eax, 2
    jne .check_3finger
    ; Manhattan distance = |f0x - f1x| + |f0y - f1y|
    mov ebx, [mouse_x]
    sub ebx, [hid_f1_x]
    test ebx, ebx
    jns .pinch_dx_pos
    neg ebx
.pinch_dx_pos:
    mov ecx, [hid_f1_avg_y]
    test ecx, ecx
    jz .check_3finger           ; no finger1 data
    mov edx, [mouse_y]
    sub edx, ecx
    test edx, edx
    jns .pinch_dy_pos
    neg edx
.pinch_dy_pos:
    add ebx, edx                ; ebx = current distance
    ; Compute delta vs previous distance
    mov edx, [gesture_pinch_dist_prev]
    mov [gesture_pinch_dist_prev], ebx
    test edx, edx
    jz .check_3finger           ; no previous sample
    sub ebx, edx                ; ebx = distance delta (positive=zoom in)
    ; Apply threshold to reduce noise (ignore if < 8 pixels)
    mov ecx, ebx
    test ecx, ecx
    jns .pinch_delta_pos
    neg ecx
.pinch_delta_pos:
    cmp ecx, 8
    jl .check_3finger
    sar ebx, 2                  ; scale down
    mov [mouse_pinch_delta], ebx
    jmp .gesture_done

.check_3finger:
    ; Clear pinch distance when not 2 fingers
    cmp eax, 2
    je .gesture_done
    mov dword [gesture_pinch_dist_prev], 0
    mov dword [mouse_pinch_delta], 0

    ; --- 3-finger swipe detection ---
    cmp eax, 3
    jne .gesture_done
    ; Use finger0 X motion vs reference to detect swipe direction
    cmp byte [gesture_scroll_active], 1
    je .gesture_done            ; don't swipe while scroll active
    mov ebx, [mouse_x]
    mov ecx, [gesture_scroll_ref_x]
    test ecx, ecx
    jz .swipe_set_ref           ; first frame with 3 fingers
    sub ebx, ecx                ; ebx = X delta from ref
    ; Threshold: > 40px horizontal motion = swipe
    cmp ebx, 40
    jge .swipe_right
    cmp ebx, -40
    jle .swipe_left
    jmp .gesture_done
.swipe_right:
    mov byte [gesture_swipe_dir], 1
    mov ebx, [mouse_x]
    mov [gesture_scroll_ref_x], ebx
    jmp .gesture_done
.swipe_left:
    mov byte [gesture_swipe_dir], -1
    mov ebx, [mouse_x]
    mov [gesture_scroll_ref_x], ebx
    jmp .gesture_done
.swipe_set_ref:
    mov [gesture_scroll_ref_x], ebx
    mov byte [gesture_swipe_dir], 0

.gesture_done:
    ; Save current contact count as previous
    mov [gesture_prev_count], al

    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; ============================================================================
; Data Section
; ============================================================================
section .data

; --- Parser temporary state ---
hp_usage_page:      dw 0
hp_usage:           dw 0
HP_USAGE_LIST_MAX   equ 8
hp_usage_count:     db 0
hp_usage_list:      times HP_USAGE_LIST_MAX dw 0
hp_logical_min:     dd 0
hp_logical_max:     dd 0
hp_report_size:     db 0
hp_report_count:    db 0
hp_report_id:       dw 0
hp_bit_offset:      dd 0
hp_in_finger:           db 0
hp_finger_idx:          db 0
hp_found_fields:        db 0    ; bitmask: 1=buttons, 2=X, 4=Y, 8=tip, 16=contact_count
hp_is_absolute:         db 0
hp_finger_start_offset: dd 0   ; bit offset at start of current finger collection

; --- Parsed report descriptor results ---
global hid_parsed_report_id
global hid_parsed_has_report_id
global hid_parsed_is_absolute
global hid_parsed_is_touchpad
global hid_parsed_report_bytes
global hid_parsed_x_bit_offset, hid_parsed_x_bit_size
global hid_parsed_y_bit_offset, hid_parsed_y_bit_size
global hid_parsed_x_logical_min, hid_parsed_x_logical_max
global hid_parsed_y_logical_min, hid_parsed_y_logical_max
global hid_parsed_btn_bit_offset, hid_parsed_btn_count
global hid_parsed_tip_bit_offset
global hid_parsed_cid_bit_offset, hid_parsed_cid_bit_size
global hid_parsed_cc_bit_offset, hid_parsed_cc_bit_size
global hid_parsed_max_contacts
global hid_parsed_contact_stride

hid_parsed_report_id:       db 0
hid_parsed_has_report_id:   db 0
hid_parsed_is_absolute:     db 0
hid_parsed_is_touchpad:     db 0
hid_parsed_report_bytes:    db 0

hid_parsed_x_bit_offset:   dw 0
hid_parsed_x_bit_size:     db 0
hid_parsed_y_bit_offset:   dw 0
hid_parsed_y_bit_size:     db 0
hid_parsed_x_logical_min:  dd 0
hid_parsed_x_logical_max:  dd 4095
hid_parsed_y_logical_min:  dd 0
hid_parsed_y_logical_max:  dd 4095

hid_parsed_btn_bit_offset: dw 0
hid_parsed_btn_count:      db 0

hid_parsed_tip_bit_offset: dw 0
hid_parsed_cid_bit_offset: dw 0
hid_parsed_cid_bit_size:   db 0
hid_parsed_cc_bit_offset:  dw 0
hid_parsed_cc_bit_size:    db 0
hid_parsed_max_contacts:    db 1
hid_parsed_contact_stride:  dw 0    ; bits between contacts in multi-touch report
hid_parsed_conf_bit_offset: dw 0    ; bit offset of Confidence field (palm rejection)
hid_parsed_conf_bit_size:   db 0    ; bit size of Confidence field (0=not present)
hid_parsed_end:

; --- Gesture engine state ---
global gesture_tap_click
global mouse_scroll_y

gesture_prev_count:         db 0
gesture_tap_start_tick:     dq 0
gesture_tap_start_x:        dd 0
gesture_tap_start_y:        dd 0
gesture_tap_pending:        db 0
gesture_tap_click:          db 0
gesture_scroll_active:      db 0
gesture_scroll_ref_y:       dd 0
gesture_scroll_ref_x:       dd 0
gesture_pinch_dist_prev:    dd 0    ; previous pinch distance for delta
gesture_swipe_dir:          db 0    ; 1=right, -1=left, 0=none (3-finger swipe)

global mouse_pinch_delta
mouse_pinch_delta:          dd 0    ; pinch zoom delta (+zoom in, -zoom out)
mouse_scroll_y:             dd 0    ; vertical scroll delta (shared global)

; --- Temporary extraction values ---
hid_abs_x:  dd 0
hid_abs_y:  dd 0
hid_abs_prev_x: dd 0
hid_abs_prev_y: dd 0
hid_abs_prev_valid: db 0
hid_rel_x:  dd 0
hid_rel_y:  dd 0
hid_f1_avg_y: dd 0
hid_f1_x:   dd 0            ; finger1 screen X for pinch detection

; Externs
extern mouse_x, mouse_y
extern scr_width, scr_height
