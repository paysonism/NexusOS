; ============================================================================
; NexusOS Media Viewer
;
; Provides the open-side glue and the draw callback for the Media Player app.
; Dispatches by 32-bit magic at offset 0 of the loaded file. Adding a codec
; requires only:
;   1. A new `nx_media_blit_<fmt>` routine matching the calling convention
;      below.
;   2. One row appended to `nx_media_codec_table`.
;   3. An extension hook in `app_open_file` (src/user/apps/launch.inc).
;
; Calling convention for codec blitters:
;   RDI = pointer to file buffer (magic at [rdi])
;   RSI = window struct pointer (read WIN_OFF_X/Y, WIN_OFF_W/H, etc.)
;   Returns: nothing. Must preserve callee-saved registers.
;
; State strategy:
;   NBA playback state lives in the owning app slot. No state is stashed in
;   kernel globals, so two Media Player windows can coexist safely.
; ============================================================================

NIC1_MAGIC equ 0x3143494E
NBA1_MAGIC equ 0x3141424E
BMP_MAGIC16 equ 0x4D42                  ; 'BM' as little-endian word

global app_media_draw

; The Media Player window is opened by `kernel_open_file_in_media` in
; src/user/apps/launch.inc (mirrors kernel_open_file_in_notepad). That helper
; runs in kernel context with the real fat16 globals available, creates the
; window with app_media_draw as the draw callback, and reads the file into
; `[slot + APP_SLOT_BMP_FILE_OFF]` — the same offset the codec blitters read
; from below.

; ---------------------------------------------------------------------------
; app_media_draw — window draw callback. RDI = window struct ptr.
; Probes the magic at the start of the slot buffer and tail-calls the
; matching codec blitter. Falls back to a blank frame on unknown magic so
; the window stays usable while the user tries another file.
; ---------------------------------------------------------------------------
; Codec dispatch.
;   The dispatch chain below is intentionally a cmp/je ladder rather than a
;   pointer table: the user app blob is COPIED into a per-window slot and
;   runs at a different virtual address than where it was linked, so any
;   absolute function pointer baked into a `dq` row would point at the
;   kernel-image copy instead of the running slot copy. Direct relative
;   `call` instructions stay correct under that relocation.
;
;   To add a codec:
;     1. Add a `cmp eax, <MAGIC> / je .blit_<fmt>` block below.
;     2. Add a `.blit_<fmt>:` thunk that tail-calls your blitter.
;     3. Write the blitter (rdi=file, rsi=window).
app_media_draw:
    push rbx
    push r12
    push r13

    mov r13, rdi                          ; preserve window ptr
    mov rax, [rdi + WIN_OFF_APPDATA]
    lea r12, [rax + APP_SLOT_BMP_FILE_OFF] ; file buffer

    mov eax, [r12]                        ; first 4 bytes — codec magic
    cmp eax, NIC1_MAGIC
    je .blit_nic
    cmp eax, NBA1_MAGIC
    je .blit_nba

    ; BMP uses a 16-bit magic ('BM'). Probe it last so a stray match in the
    ; high two bytes of a NIC/NBA file can't mis-route.
    cmp word [r12], BMP_MAGIC16
    je .blit_bmp

    jmp .draw_done

.blit_nic:
    mov rdi, r12
    mov rsi, r13
    call nx_media_blit_nic
    jmp .draw_done
.blit_nba:
    mov rdi, r12
    mov rsi, r13
    call nx_media_blit_nba
    jmp .draw_done
.blit_bmp:
    mov rdi, r12
    mov rsi, r13
    call nx_media_blit_bmp

.draw_done:
    pop r13
    pop r12
    pop rbx
    ret

; ---------------------------------------------------------------------------
; nx_media_blit_nic — NIC1 image renderer.
;   Header layout (see docs/media-formats.md):
;     +0  'NIC1', +4 u16 w, +6 u16 h, +8 bpp(32), +16 BGRA top-down
;
;   Renders binary-alpha BGRA into the window's client area, clipped to
;   both window and screen bounds. No scaling — pixels are 1:1.
; ---------------------------------------------------------------------------
nx_media_blit_nic:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15

    cmp byte [rdi + 8], 32
    jne .nic_done

    mov r12, rdi                          ; file
    mov r13, rsi                          ; window

    movzx r14d, word [r12 + 4]            ; image w
    movzx r15d, word [r12 + 6]            ; image h

    ; Destination origin = window client (x+BORDER, y+TITLEBAR).
    mov ebp, dword [r13 + WIN_OFF_X]
    add ebp, BORDER_WIDTH                  ; ebp = dst x base
    mov ebx, dword [r13 + WIN_OFF_Y]
    add ebx, TITLEBAR_HEIGHT               ; ebx = dst y base

    ; Per-row blit. r9 = source ptr, advanced by stride each row.
    lea r9, [r12 + 16]                     ; pixel data
    xor ecx, ecx                           ; row counter
.nic_row:
    cmp ecx, r15d
    jge .nic_done
    mov edx, ebx
    add edx, ecx
    cmp edx, [scr_height]
    jge .nic_done

    ; dst row addr = bb_addr + y*pitch
    mov eax, edx
    imul eax, [scr_pitch]
    mov r10, [bb_addr]
    add r10, rax
    lea r10, [r10 + rbp * 4]               ; + x*4

    mov r11, r9                            ; src pixel
    mov edi, r14d                          ; pixels remaining this row
.nic_px:
    test edi, edi
    jz .nic_row_done
    mov eax, [r11]
    test eax, 0xFF000000
    jz .nic_px_skip
    mov [r10], eax
.nic_px_skip:
    add r11, 4
    add r10, 4
    dec edi
    jmp .nic_px
.nic_row_done:
    ; advance source by w*4
    mov eax, r14d
    shl eax, 2
    add r9, rax
    inc ecx
    jmp .nic_row

.nic_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret

; ---------------------------------------------------------------------------
; nx_media_blit_nba — NBA1 video renderer.
;   Picks current frame from the global tick_count modulo the clip length
;   (looping playback). Frames are dense BGRA, top-down.
; ---------------------------------------------------------------------------
nx_media_blit_nba:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi                          ; file
    mov r13, rsi                          ; window

    mov r14d, [r12 + 4]                   ; w
    mov r15d, [r12 + 8]                   ; h
    mov ecx,  [r12 + 12]                  ; frame_count
    mov edx,  [r12 + 16]                  ; fps
    test r14d, r14d
    jz .nba_done
    test r15d, r15d
    jz .nba_done
    test ecx, ecx
    jz .nba_done
    test edx, edx
    jz .nba_done

    ; Resolve slot-local playback state.
    mov r8, [r13 + WIN_OFF_APPDATA]
    mov eax, [r8 + app_hl_media_mp_frame - app_blob_start]
    cmp eax, ecx
    jb .frame_in_range
    xor eax, eax
    mov [r8 + app_hl_media_mp_frame - app_blob_start], eax
.frame_in_range:
    cmp dword [r8 + app_hl_media_mp_paused - app_blob_start], 0
    jne .have_frame
    cmp ecx, 1
    jbe .have_frame

    ; interval_ticks = max(1, 100 / fps)
    mov r10d, eax
    mov eax, 100
    xor edx, edx
    div dword [r12 + 16]
    test eax, eax
    jnz .interval_ok
    mov eax, 1
.interval_ok:
    mov r11d, eax
    mov rax, [tick_count]
    mov rbx, [r8 + app_hl_media_mp_last_tick - app_blob_start]
    test rbx, rbx
    jnz .have_last_tick
    mov [r8 + app_hl_media_mp_last_tick - app_blob_start], rax
    mov eax, r10d
    jmp .have_frame
.have_last_tick:
    mov r9, rax
    sub r9, rbx
    cmp r9d, r11d
    jb .no_advance
    mov rax, r9
    xor edx, edx
    div r11
    add eax, r10d
    xor edx, edx
    div ecx
    mov eax, edx
    mov [r8 + app_hl_media_mp_frame - app_blob_start], eax
    mov rbx, [tick_count]
    mov [r8 + app_hl_media_mp_last_tick - app_blob_start], rbx
    mov byte [scene_dirty], 1
    jmp .have_frame
.no_advance:
    mov eax, r10d
.have_frame:
    mov r8d, eax                          ; frame idx for controls

    ; src = file + 20 + frame * (w*h*4)
    mov ebx, r14d
    imul ebx, r15d
    shl ebx, 2                            ; stride
    mul rbx
    lea r9, [r12 + 20]
    add r9, rax

    ; Destination origin same as NIC. NBA frames are opaque so we skip
    ; the binary-alpha test for speed.
    mov ebp, dword [r13 + WIN_OFF_X]
    add ebp, BORDER_WIDTH
    mov ebx, dword [r13 + WIN_OFF_Y]
    add ebx, TITLEBAR_HEIGHT

    xor ecx, ecx
.nba_row:
    cmp ecx, r15d
    jge .nba_blit_done
    mov edx, ebx
    add edx, ecx
    cmp edx, [scr_height]
    jge .nba_done

    mov eax, edx
    imul eax, [scr_pitch]
    mov r10, [bb_addr]
    add r10, rax
    lea r10, [r10 + rbp * 4]

    mov r11, r9
    mov edi, r14d
.nba_px:
    test edi, edi
    jz .nba_row_done
    mov eax, [r11]
    mov [r10], eax
    add r11, 4
    add r10, 4
    dec edi
    jmp .nba_px
.nba_row_done:
    mov eax, r14d
    shl eax, 2
    add r9, rax
    inc ecx
    jmp .nba_row
.nba_blit_done:
    mov rdi, r12
    mov rsi, r13
    mov edx, r8d
    mov ecx, [r12 + 12]
    call nx_media_draw_nba_controls
.nba_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret

; ---------------------------------------------------------------------------
; nx_media_blit_bmp — thin wrapper around the existing 24bpp BMP viewer.
;   The legacy app_bmp_draw expects:
;     RDI = window struct, slot buffer at APP_SLOT_BMP_FILE_OFF, plus a
;     few kernel globals (bmp_width/height/bpp/data_offset) pre-populated.
;   We parse the header inline here so Media Player and the legacy BMP
;   path can share the same renderer without taking a dependency on the
;   legacy open path.
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
; Tiny framebuffer UI helpers for the kernel-side Media Player controls.
; ---------------------------------------------------------------------------
nx_media_fill_rect:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15

    mov r12d, edi                         ; x
    mov r13d, esi                         ; y
    mov r14d, edx                         ; w
    mov r15d, ecx                         ; h
    mov ebp, r8d                          ; color
    test r14d, r14d
    jle .fill_done
    test r15d, r15d
    jle .fill_done
    xor ebx, ebx
.fill_row:
    cmp ebx, r15d
    jge .fill_done
    mov edx, r13d
    add edx, ebx
    cmp edx, [scr_height]
    jge .fill_done
    mov eax, edx
    imul eax, [scr_pitch]
    mov r10, [bb_addr]
    add r10, rax
    lea r10, [r10 + r12 * 4]
    mov edi, r14d
.fill_px:
    test edi, edi
    jz .fill_row_done
    mov [r10], ebp
    add r10, 4
    dec edi
    jmp .fill_px
.fill_row_done:
    inc ebx
    jmp .fill_row
.fill_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret

nx_media_draw_play_triangle:
    push rbx
    push r12
    push r13
    push r14

    mov r12d, edi                         ; x
    mov r13d, esi                         ; y
    mov r14d, edx                         ; color
    xor ebx, ebx
.tri_row:
    cmp ebx, 12
    jge .tri_done
    mov edi, r12d
    mov esi, r13d
    add esi, ebx
    mov edx, ebx
    shr edx, 1
    add edx, 3
    mov ecx, 1
    mov r8d, r14d
    call nx_media_fill_rect
    inc ebx
    jmp .tri_row
.tri_done:
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

nx_media_draw_nba_controls:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15

    mov r13, rsi                          ; window
    mov r14d, edx                         ; frame
    mov r15d, ecx                         ; frame_count

    mov ebx, [r13 + WIN_OFF_X]
    add ebx, BORDER_WIDTH
    mov ebp, [r13 + WIN_OFF_Y]
    add ebp, TITLEBAR_HEIGHT
    mov eax, [r13 + WIN_OFF_H]
    sub eax, TITLEBAR_HEIGHT
    sub eax, BORDER_WIDTH
    add ebp, eax
    sub ebp, 26                           ; control bar y

    mov edi, ebx
    mov esi, ebp
    mov edx, [r13 + WIN_OFF_W]
    sub edx, BORDER_WIDTH * 2
    mov ecx, 26
    mov r8d, 0x00131620
    call nx_media_fill_rect

    mov edi, ebx
    add edi, 8
    mov esi, ebp
    add esi, 5
    mov edx, 16
    mov ecx, 16
    mov r8d, 0x002A6FFF
    call nx_media_fill_rect

    mov rax, [r13 + WIN_OFF_APPDATA]
    cmp dword [rax + app_hl_media_mp_paused - app_blob_start], 0
    je .draw_pause_icon
    mov edi, ebx
    add edi, 13
    mov esi, ebp
    add esi, 7
    mov edx, 0x00FFFFFF
    call nx_media_draw_play_triangle
    jmp .draw_track
.draw_pause_icon:
    mov edi, ebx
    add edi, 13
    mov esi, ebp
    add esi, 8
    mov edx, 3
    mov ecx, 10
    mov r8d, 0x00FFFFFF
    call nx_media_fill_rect
    mov edi, ebx
    add edi, 20
    mov esi, ebp
    add esi, 8
    mov edx, 3
    mov ecx, 10
    mov r8d, 0x00FFFFFF
    call nx_media_fill_rect

.draw_track:
    mov edi, ebx
    add edi, 34
    mov esi, ebp
    add esi, 12
    mov edx, [r13 + WIN_OFF_W]
    sub edx, BORDER_WIDTH * 2
    sub edx, 48
    cmp edx, 1
    jle .controls_done
    mov ecx, 3
    mov r8d, 0x004B5563
    call nx_media_fill_rect

    mov eax, [r13 + WIN_OFF_W]
    sub eax, BORDER_WIDTH * 2
    sub eax, 48
    cmp r15d, 1
    jbe .progress_ready
    mov ecx, r14d
    inc ecx
    mul ecx
    xor edx, edx
    div r15d
.progress_ready:
    mov edi, ebx
    add edi, 34
    mov esi, ebp
    add esi, 12
    mov edx, eax
    mov ecx, 3
    mov r8d, 0x002A6FFF
    call nx_media_fill_rect

    mov edi, ebx
    add edi, 34
    add edi, eax
    sub edi, 2
    mov esi, ebp
    add esi, 9
    mov edx, 5
    mov ecx, 9
    mov r8d, 0x00FFFFFF
    call nx_media_fill_rect
.controls_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret

nx_media_blit_bmp:
    push rdi
    push rsi
    push rdx

    mov eax, [rdi + 18]
    mov [bmp_width], eax
    mov eax, [rdi + 22]
    mov [bmp_height], eax
    mov eax, [rdi + 10]
    mov [bmp_data_offset], eax
    movzx eax, word [rdi + 28]
    mov [bmp_bpp], eax

    mov rdi, rsi                          ; app_bmp_draw expects window in RDI
    call app_bmp_draw

    pop rdx
    pop rsi
    pop rdi
    ret

; Codec extension point lives in `app_media_draw` above — see the comment
; there. No data table needed because user-blob relocation breaks absolute
; function pointers.
