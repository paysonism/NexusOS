; ============================================================================
; NexusOS Media Player — kernel-side renderer & timeline driver.
;
; This file lives inside the user app blob (apps.asm) but its main entry
; point `app_media_draw` is registered as a window draw fn, which means
; the window manager invokes it in kernel context. That is what lets us
; read `bb_addr`, `scr_pitch`, `scr_height`, and `tick_count` directly —
; those symbols would not be reachable from a Ring-3 slot copy.
;
; Surface area, kept small and documented
; ---------------------------------------
;   Pixel I/O   : direct writes to `[bb_addr + y*pitch + x*4]` (UEFI GOP
;                 framebuffer, BGRA). No iGPU acceleration, no SIMD —
;                 plain scalar code that is portable across every machine
;                 NexusOS boots on. See docs/media-formats.md → "Scope".
;   Timing      : the global 100 Hz PIT `tick_count`. Per-window state
;                 stored slot-local (see media.nxh `state { ... }`) so
;                 two players can coexist.
;   Scaling     : nearest-neighbor with a 16.16 fixed-point step, aspect
;                 preserved, letterboxed inside the client area. Shared
;                 by every BGRA-source codec via `nx_media_blit_scaled`.
;   Codecs      : one cmp/je ladder in `app_media_draw`. Adding a codec
;                 = new magic + new blitter that ultimately tail-calls
;                 `nx_media_blit_scaled` (or draws directly, for vector
;                 codecs like SVG).
;
; File map
; --------
;   §1  Magic & layout constants
;   §2  Codec dispatch                       (app_media_draw)
;   §3  Generic helpers                      (fill_rect, scaler, fit)
;   §4  Image codecs                         (NIC, BMP)
;   §5  Video codecs                         (NBA + timeline advance)
;   §6  Vector codecs                        (SVG subset, XML text)
;   §7  Control bar UI                       (play / ±10s / scrubber)
;   §8  Future-work notes
;
; Adding a codec — checklist
; --------------------------
;   1. Pick a 32-bit magic and constant in §1.
;   2. Add one `cmp eax, <MAGIC>` row in §2.
;   3. Implement `nx_media_blit_<fmt>(rdi=file, rsi=window)` in §4–§6.
;   4. (Optional) Extend media.nxh `media_probe` so user-mode tools can
;      recognise it for thumbnails / property dialogs.
;   5. Update docs/media-formats.md.
; ============================================================================

; ---------------------------------------------------------------------------
; §1  Magic & layout constants
; ---------------------------------------------------------------------------
NIC1_MAGIC      equ 0x3143494E              ; 'NIC1'
NBA1_MAGIC      equ 0x3141424E              ; 'NBA1'
BMP_MAGIC16     equ 0x4D42                  ; 'BM'
XML_MAGIC16     equ 0x3F3C                  ; '<?'  catches <?xml ...?>
SVG_MAGIC32     equ 0x67767321              ; '<svg' little-endian probe

; Control bar layout. Kept in lockstep with media.nxh — change one, change
; the other. Both files use these names so hit-test (nxh) and drawing
; (here) cannot drift apart.
MEDIA_BAR_H         equ 26
MEDIA_BTN_W         equ 28
MEDIA_BTN_PLAY_X    equ 0
MEDIA_BTN_BACK_X    equ 28
MEDIA_BTN_FWD_X     equ 56
MEDIA_SCRUB_X       equ 88
MEDIA_TIME_W        equ 56

; Palette — centralised so a theme change touches one block.
MEDIA_COL_BAR_BG    equ 0x00131620
MEDIA_COL_BTN_BG    equ 0x002A6FFF
MEDIA_COL_TRACK_BG  equ 0x004B5563
MEDIA_COL_TRACK_FG  equ 0x002A6FFF
MEDIA_COL_KNOB      equ 0x00FFFFFF
MEDIA_COL_GLYPH     equ 0x00FFFFFF
MEDIA_COL_LETTERBOX equ 0x00000000
MEDIA_COL_TEXT_FG   equ 0x00FFFFFF
MEDIA_COL_TEXT_BG   equ 0x00131620

; Media-only BMP decode scratch. These offsets overlap Paint's per-window
; buffers, which is fine because every app window owns a private 2 MiB slot.
MEDIA_BMP_SCRATCH_OFF equ APP_SLOT_PAINT_CANVAS_OFF
MEDIA_BMP_SCRATCH_SZ  equ 0x43000
; Per-window full-clip buffers. NBA videos can be far larger than a slot's
; 256 KiB media buffer, so each media window allocates its own physically
; contiguous buffer (page_alloc_contig, identity-mapped so the phys address
; doubles as a CPU pointer) sized to the file. Indexed by window id; ptr 0 =
; none, in which case the renderer falls back to the slot buffer. `pages` is
; the run length kept for page_free_contig on window close.
; (MEDIA_FULL_BUF_MAX_SZ lives in constants.inc — used by the loader.)
extern page_alloc_contig
extern page_free_contig
extern fat16_get_file_size

global media_full_buf
media_full_buf:        times MAX_WINDOWS dq 0
global media_full_buf_pages
media_full_buf_pages:  times MAX_WINDOWS dq 0
global media_direct_present
global media_direct_presented
media_direct_present db 0
media_direct_presented db 0

global app_media_draw
; nx_media_blit_scaled is reachable from the kernel via SYS_MEDIA_BLIT_SCALED
; (see syscall.asm → .sc_media_blit_scaled). Caller-side validation runs in
; the syscall stub; this routine itself trusts its register inputs.
global nx_media_blit_scaled


; ---------------------------------------------------------------------------
; §2  Codec dispatch — app_media_draw
;
; RDI = window struct ptr (kernel address).
; Probes the 32-bit magic at the start of the slot's media buffer and
; tail-calls the matching codec blitter. Unknown magic → blank frame so
; the window stays usable while the user tries another file.
;
; The dispatch ladder is intentionally cmp/je (not a pointer table)
; because the user-blob is COPIED into per-window slots at run time and
; runs at a different virtual address than where it was linked; any
; absolute function pointer baked into a `dq` row would still point at
; the kernel-image copy. Direct relative `call` instructions stay correct
; under that relocation.
; ---------------------------------------------------------------------------
app_media_draw:
    push rbx
    push r12
    push r13

    mov r13, rdi
    mov edi, [r13 + WIN_OFF_ID]
    call l3_slot_base
    lea r12, [rax + APP_SLOT_BMP_FILE_OFF]   ; file buffer

    ; SMAP: app_media_draw runs in KERNEL context (registered as a window draw
    ; fn — see header) yet reads the slot's media buffer (user, PTE.U=1) every
    ; frame and the blitters below stream slot pixels in tight loops. Arm AC for
    ; the whole body; the blitters / advance_frame it calls never touch AC, so
    ; it propagates, and they also write the kernel back buffer (fine with AC).
    USER_ACCESS_BEGIN

    mov eax, [r12]
    cmp eax, NIC1_MAGIC
    je .blit_nic
    cmp eax, NBA1_MAGIC
    je .blit_nba
    cmp eax, SVG_MAGIC32                     ; '<svg' bare-element form
    je .blit_svg

    ; 16-bit magics probed last so a stray high-word match in a 32-bit
    ; magic cannot mis-route.
    cmp word [r12], BMP_MAGIC16
    je .blit_bmp
    cmp word [r12], XML_MAGIC16
    je .blit_xml

    jmp .draw_done

.blit_nic:
    mov rdi, r12
    mov rsi, r13
    call nx_media_blit_nic
    jmp .draw_done
.blit_nba:
    mov rdi, r12                             ; default source = slot file buffer
    mov r8d, APP_SLOT_BMP_FILE_SZ            ; default capacity (bytes)
    mov eax, [r13 + WIN_OFF_ID]
    cmp eax, MAX_WINDOWS
    jae .blit_nba_go
    lea r9, [rel media_full_buf]
    mov r10, [r9 + rax*8]                    ; this window's full-clip buffer
    test r10, r10
    jz .blit_nba_go
    cmp dword [r10], NBA1_MAGIC              ; still a live NBA buffer?
    jne .blit_nba_go
    mov rdi, r10                             ; play from the full buffer
    lea r9, [rel media_full_buf_pages]
    mov r8, [r9 + rax*8]
    shl r8, 12                               ; pages -> capacity in bytes
.blit_nba_go:
    mov rsi, r13
    call nx_media_blit_nba                   ; rdi=src, rsi=window, r8=src capacity
    jmp .draw_done
.blit_bmp:
    mov rdi, r12
    mov rsi, r13
    call nx_media_blit_bmp
    jmp .draw_done
.blit_xml:
    mov rdi, r12
    mov rsi, r13
    call nx_media_blit_xml
    jmp .draw_done
.blit_svg:
    mov rdi, r12
    mov rsi, r13
    call nx_media_blit_svg

.draw_done:
    USER_ACCESS_END
    pop r13
    pop r12
    pop rbx
    ret


; media_release_window_buf(edi = window id)
;   Frees this window's per-window full-clip buffer (if any) and clears its
;   ownership slots. Called from the close path (wm_close_window) and before a
;   media window reuses its slot for a new clip. Safe to call when no buffer is
;   owned. Preserves all integer registers so it can drop into existing call
;   sequences without disturbing their state.
global media_release_window_buf
media_release_window_buf:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    mov ebx, edi
    cmp ebx, MAX_WINDOWS
    jae .mrwb_ret
    lea rdx, [rel media_full_buf]
    mov rdi, [rdx + rbx*8]                   ; buffer base (0 = none)
    test rdi, rdi
    jz .mrwb_ret
    lea rcx, [rel media_full_buf_pages]
    mov rsi, [rcx + rbx*8]                   ; page count
    mov qword [rdx + rbx*8], 0               ; clear ownership before freeing
    mov qword [rcx + rbx*8], 0
    call page_free_contig                    ; (rdi = base, rsi = pages)
.mrwb_ret:
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret


; ---------------------------------------------------------------------------
; §3  Generic helpers
; ---------------------------------------------------------------------------

; nx_media_fill_rect(edi=x, esi=y, edx=w, ecx=h, r8d=color)
;   Clipped solid fill. Used by the control bar and the letterbox pass.
nx_media_fill_rect:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15

    mov r12d, edi                            ; x
    mov r13d, esi                            ; y
    mov r14d, edx                            ; w
    mov r15d, ecx                            ; h
    mov ebp, r8d                             ; color
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
    test edx, edx
    js .fill_skip
    cmp edx, [scr_height]
    jge .fill_done
    mov eax, edx
    imul eax, [scr_pitch]
    mov r10, [bb_addr]
    add r10, rax
    lea r10, [r10 + r12 * 4]
    xor r11, r11
    cmp byte [rel media_direct_present], 0
    je .fill_no_fb_row
    mov r11, [fb_addr]
    add r11, rax
    lea r11, [r11 + r12 * 4]
.fill_no_fb_row:
    mov edi, r14d
.fill_px:
    test edi, edi
    jz .fill_skip
    mov [r10], ebp
    test r11, r11
    je .fill_no_fb
    mov [r11], ebp
    add r11, 4
.fill_no_fb:
    add r10, 4
    dec edi
    jmp .fill_px
.fill_skip:
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

; ---------------------------------------------------------------------------
; nx_media_compute_fit
;   Aspect-preserving fit of (src_w, src_h) into (dst_w, dst_h).
;
;   Inputs : edi=src_w, esi=src_h, edx=dst_w, ecx=dst_h
;   Output : eax = fit_w, ebx = fit_h, r10d = off_x, r11d = off_y
;   Clobbers: rax, rdx, r8, r9, r10, r11
;
;   Picks the smaller of (dst_w/src_w) and (dst_h/src_h) in 16.16 fixed
;   point, then multiplies src by the chosen ratio. Inputs are spilled to
;   the stack on entry so we can still read dst_w/dst_h after the
;   intermediate divides clobber edx.
;
;   Stack frame (after `sub rsp, 32`):
;     [rsp +  0]  src_w
;     [rsp +  4]  src_h
;     [rsp +  8]  dst_w
;     [rsp + 12]  dst_h
; ---------------------------------------------------------------------------
nx_media_compute_fit:
    sub rsp, 32
    mov [rsp + 0], edi                       ; src_w
    mov [rsp + 4], esi                       ; src_h
    mov [rsp + 8], edx                       ; dst_w
    mov [rsp + 12], ecx                      ; dst_h

    test edi, edi
    jz .cf_zero
    test esi, esi
    jz .cf_zero
    test edx, edx
    jz .cf_zero
    test ecx, ecx
    jz .cf_zero

    ; ratio_w = (dst_w << 16) / src_w
    mov eax, edx
    shl rax, 16
    xor edx, edx
    div rdi
    mov r8, rax                              ; ratio_w in r8

    ; ratio_h = (dst_h << 16) / src_h
    mov eax, [rsp + 12]
    shl rax, 16
    xor edx, edx
    div rsi
    cmp rax, r8
    jb .cf_use_h
    mov rax, r8
.cf_use_h:
    mov r9, rax                              ; chosen ratio (16.16)

    ; fit_w = src_w * ratio >> 16
    mov eax, [rsp + 0]
    imul rax, r9
    shr rax, 16
    mov ebx, eax                             ; fit_w in ebx
    ; fit_h = src_h * ratio >> 16
    mov eax, [rsp + 4]
    imul rax, r9
    shr rax, 16                              ; fit_h in eax

    ; Clamp to dst (rounding can overshoot by 1).
    mov r10d, [rsp + 8]                      ; dst_w
    cmp ebx, r10d
    jbe .cf_w_ok
    mov ebx, r10d
.cf_w_ok:
    mov r11d, [rsp + 12]                     ; dst_h
    cmp eax, r11d
    jbe .cf_h_ok
    mov eax, r11d
.cf_h_ok:

    ; Centre offsets.
    mov r10d, [rsp + 8]
    sub r10d, ebx
    shr r10d, 1                              ; off_x
    mov r11d, [rsp + 12]
    sub r11d, eax
    shr r11d, 1                              ; off_y

    ; Pack outputs: caller expects eax=fit_w, ebx=fit_h.
    xchg eax, ebx
    add rsp, 32
    ret

.cf_zero:
    xor eax, eax
    xor ebx, ebx
    xor r10d, r10d
    xor r11d, r11d
    add rsp, 32
    ret


; ---------------------------------------------------------------------------
; nx_media_blit_scaled
;   Aspect-preserving nearest-neighbor blit of a top-down BGRA source
;   into a viewport inside the window's client area.
;
;   Inputs (caller-saved values stashed on a local frame):
;     r12 = source BGRA pixels  (top-down, row-major, stride = src_w*4)
;     r13 = window struct ptr
;     r14d = src_w
;     r15d = src_h
;     dl   = 1 if alpha-keyed (skip pixels with A==0); 0 = opaque
;     r9d  = reserve_bottom_px (e.g. MEDIA_BAR_H for video; 0 for stills)
;
;   The viewport = client area minus the reserved bottom strip. We
;   letterbox the viewport in black, fit the source with aspect kept,
;   then walk the destination once with a 16.16 fixed-point step.
;
;   Performance notes
;   -----------------
;   - One unsigned divide per axis to compute the step. No divide in the
;     inner loop.
;   - One add per pixel for the U/V accumulators. No multiplies in the
;     inner loop.
;   - Pure scalar — no SSE — for portability across every CPU we boot
;     on. The framebuffer is WC-mapped (see fbperf_wc_landed memory) so
;     a single 32-bit `mov [r10], eax` is already a fast write. A SIMD
;     gather/store rewrite is sketched in §8.
; ---------------------------------------------------------------------------
;
; Stack frame (offsets from RSP after the `sub rsp, 64` below):
;     [rsp +  0]  src_ptr                   (qword)
;     [rsp +  8]  step_x (16.16)            (dword)
;     [rsp + 12]  step_y (16.16)            (dword)
;     [rsp + 16]  dst_x                     (dword)
;     [rsp + 20]  dst_y                     (dword)
;     [rsp + 24]  fit_w                     (dword)
;     [rsp + 28]  fit_h                     (dword)
;     [rsp + 32]  alpha_key flag (0/1)      (dword)
;     [rsp + 36]  viewport_w                (dword)
;     [rsp + 40]  viewport_h                (dword)
;     [rsp + 48]  direct fb row ptr         (qword)
nx_media_blit_scaled:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15
    sub rsp, 64

    mov [rsp + 0], r12                       ; src
    movzx eax, dl
    mov [rsp + 32], eax                      ; alpha-key flag

    ; Compute viewport (client area minus reserved bottom strip).
    mov edx, [r13 + WIN_OFF_W]
    sub edx, BORDER_WIDTH * 2                ; viewport_w
    mov ecx, [r13 + WIN_OFF_H]
    sub ecx, TITLEBAR_HEIGHT
    sub ecx, BORDER_WIDTH
    sub ecx, r9d                             ; minus reserved bottom strip
    test edx, edx
    jle .sc_done
    test ecx, ecx
    jle .sc_done
    mov [rsp + 36], edx
    mov [rsp + 40], ecx

    ; Compute fit.
    mov edi, r14d
    mov esi, r15d
    call nx_media_compute_fit
    ; eax=fit_w, ebx=fit_h, r10d=off_x, r11d=off_y
    test eax, eax
    jz .sc_done
    test ebx, ebx
    jz .sc_done
    mov [rsp + 24], eax
    mov [rsp + 28], ebx

    ; Destination origin = (client_x + off_x, client_y + off_y).
    mov ecx, [r13 + WIN_OFF_X]
    add ecx, BORDER_WIDTH
    add ecx, r10d
    mov [rsp + 16], ecx
    mov edx, [r13 + WIN_OFF_Y]
    add edx, TITLEBAR_HEIGHT
    add edx, r11d
    mov [rsp + 20], edx

    ; step_x = (src_w << 16) / fit_w
    mov rax, r14
    shl rax, 16
    xor edx, edx
    div dword [rsp + 24]
    mov [rsp + 8], eax
    ; step_y = (src_h << 16) / fit_h
    mov rax, r15
    shl rax, 16
    xor edx, edx
    div dword [rsp + 28]
    mov [rsp + 12], eax

    ; Fast path for native-size opaque video: no letterbox, no scaling, just
    ; copy BGRA rows into the backbuffer. BOOTANIM.NBA opens at this size.
    cmp dword [rsp + 32], 0
    jne .sc_letterbox
    mov eax, [rsp + 24]
    cmp eax, r14d
    jne .sc_check_2x
    cmp eax, [rsp + 36]
    jne .sc_check_2x
    mov eax, [rsp + 28]
    cmp eax, r15d
    jne .sc_check_2x
    cmp eax, [rsp + 40]
    jne .sc_check_2x
    cmp dword [rsp + 8], 0x10000
    jne .sc_check_2x
    cmp dword [rsp + 12], 0x10000
    jne .sc_check_2x
    jmp .sc_copy_opaque_1x

    ; Fast path for exact 2x opaque video. This is the full-size BOOTANIM.NBA
    ; case: read one source pixel and emit a 2x2 block instead of doing four
    ; fixed-point source lookups.
.sc_check_2x:
    cmp dword [rsp + 8], 0x8000
    jne .sc_letterbox
    cmp dword [rsp + 12], 0x8000
    jne .sc_letterbox
    mov eax, r14d
    shl eax, 1
    cmp eax, [rsp + 24]
    jne .sc_letterbox
    cmp eax, [rsp + 36]
    jne .sc_letterbox
    mov eax, r15d
    shl eax, 1
    cmp eax, [rsp + 28]
    jne .sc_letterbox
    cmp eax, [rsp + 40]
    jne .sc_letterbox
    jmp .sc_copy_opaque_2x

.sc_letterbox:
    ; Letterbox the whole viewport black so off-aspect borders are clean.
    mov edi, [r13 + WIN_OFF_X]
    add edi, BORDER_WIDTH
    mov esi, [r13 + WIN_OFF_Y]
    add esi, TITLEBAR_HEIGHT
    mov edx, [r13 + WIN_OFF_W]
    sub edx, BORDER_WIDTH * 2
    mov ecx, [r13 + WIN_OFF_H]
    sub ecx, TITLEBAR_HEIGHT
    sub ecx, BORDER_WIDTH
    sub ecx, r9d
    mov r8d, MEDIA_COL_LETTERBOX
    call nx_media_fill_rect

    ; Inner loop — one pass over the fit rectangle.
    ;   edi = dy
    ;   r10d = v (16.16 src y)
    xor edi, edi
    xor r10d, r10d
.sc_row:
    cmp edi, [rsp + 28]                      ; fit_h
    jge .sc_done

    ; screen_y = dst_y + dy
    mov edx, [rsp + 20]
    add edx, edi
    test edx, edx
    js .sc_row_next
    cmp edx, [scr_height]
    jge .sc_done

    ; src_row_ptr = src + (v >> 16) * src_w * 4
    mov eax, r10d
    shr eax, 16
    cmp eax, r15d
    jae .sc_row_next
    mov ecx, r14d
    imul ecx, eax
    shl ecx, 2
    mov r8, [rsp + 0]
    add r8, rcx                              ; r8 = src row ptr

    ; dst_row_ptr = bb + screen_y * pitch + dst_x * 4
    mov eax, edx
    imul eax, [scr_pitch]
    mov r9, [bb_addr]
    add r9, rax
    mov eax, [rsp + 16]
    lea r9, [r9 + rax * 4]                   ; r9 = dst row ptr
    cmp byte [rel media_direct_present], 0
    je .sc_no_direct_row
    mov eax, edx
    imul eax, [scr_pitch]
    mov rbx, [fb_addr]
    add rbx, rax
    mov eax, [rsp + 16]
    lea rbx, [rbx + rax * 4]
    mov [rsp + 48], rbx
    mov byte [rel media_direct_presented], 1
.sc_no_direct_row:

    ; Per-pixel walk.
    xor r11d, r11d                            ; u (16.16 src x)
    mov ecx, [rsp + 24]                       ; remaining pixels (fit_w)
    mov edx, [rsp + 8]                        ; step_x (loop-constant)
.sc_px:
    test ecx, ecx
    jz .sc_row_next
    mov eax, r11d
    shr eax, 16
    cmp eax, r14d
    jae .sc_px_skip
    mov eax, [r8 + rax * 4]
    cmp dword [rsp + 32], 0
    je .sc_px_write                          ; opaque source — always write
    test eax, 0xFF000000
    jz .sc_px_skip                           ; alpha-keyed and A==0 → skip
.sc_px_write:
    mov [r9], eax
    cmp byte [rel media_direct_present], 0
    je .sc_px_skip
    mov rbx, [rsp + 48]
    mov [rbx], eax
.sc_px_skip:
    add r9, 4
    cmp byte [rel media_direct_present], 0
    je .sc_px_no_fb_advance
    add qword [rsp + 48], 4
.sc_px_no_fb_advance:
    add r11d, edx
    dec ecx
    jmp .sc_px

.sc_row_next:
    add r10d, [rsp + 12]                     ; v += step_y (always)
    inc edi
    jmp .sc_row

.sc_copy_opaque_1x:
    xor ebp, ebp                                ; row index
    mov r8, [rsp + 0]                           ; src row
.sc_copy_row:
    cmp ebp, r15d
    jge .sc_done
    mov edx, [rsp + 20]
    add edx, ebp
    test edx, edx
    js .sc_copy_next
    cmp edx, [scr_height]
    jge .sc_done

    mov eax, edx
    imul eax, [scr_pitch]
    mov r9, [bb_addr]
    add r9, rax
    mov eax, [rsp + 16]
    lea r9, [r9 + rax * 4]

    mov rsi, r8
    mov rdi, r9
    mov ecx, r14d
    rep movsd
    cmp byte [rel media_direct_present], 0
    je .sc_copy_next
    mov rsi, r8
    mov eax, edx
    imul eax, [scr_pitch]
    mov rdi, [fb_addr]
    add rdi, rax
    mov eax, [rsp + 16]
    lea rdi, [rdi + rax * 4]
    mov ecx, r14d
    rep movsd
    mov byte [rel media_direct_presented], 1

.sc_copy_next:
    mov eax, r14d
    shl eax, 2
    add r8, rax
    inc ebp
    jmp .sc_copy_row

.sc_copy_opaque_2x:
    xor ebp, ebp                                ; source row index
    mov r8, [rsp + 0]                           ; src row
.sc2_row:
    cmp ebp, r15d
    jge .sc_done

    mov edx, [rsp + 20]
    mov eax, ebp
    shl eax, 1
    add edx, eax                                ; dest y = dst_y + sy*2
    test edx, edx
    js .sc2_next_src
    cmp edx, [scr_height]
    jge .sc_done

    mov eax, edx
    imul eax, [scr_pitch]
    mov r9, [bb_addr]
    add r9, rax
    mov eax, [rsp + 16]
    lea r9, [r9 + rax * 4]                      ; bb row 0
    mov r10, r9
    movsxd rax, dword [scr_pitch]
    add r10, rax                                ; bb row 1

    xor rbx, rbx                                ; fb row 0, optional
    xor r11, r11                                ; fb row 1, optional
    cmp byte [rel media_direct_present], 0
    je .sc2_no_fb_row
    mov eax, edx
    imul eax, [scr_pitch]
    mov rbx, [fb_addr]
    add rbx, rax
    mov eax, [rsp + 16]
    lea rbx, [rbx + rax * 4]
    mov r11, rbx
    movsxd rax, dword [scr_pitch]
    add r11, rax
    mov byte [rel media_direct_presented], 1
.sc2_no_fb_row:

    mov rsi, r8
    mov ecx, r14d
.sc2_px:
    test ecx, ecx
    jz .sc2_next_src
    mov eax, [rsi]
    add rsi, 4
    mov [r9], eax
    mov [r9 + 4], eax
    mov [r10], eax
    mov [r10 + 4], eax
    test rbx, rbx
    jz .sc2_advance
    mov [rbx], eax
    mov [rbx + 4], eax
    mov [r11], eax
    mov [r11 + 4], eax
    add rbx, 8
    add r11, 8
.sc2_advance:
    add r9, 8
    add r10, 8
    dec ecx
    jmp .sc2_px

.sc2_next_src:
    mov eax, r14d
    shl eax, 2
    add r8, rax
    inc ebp
    jmp .sc2_row

.sc_done:
    add rsp, 64
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret


; ---------------------------------------------------------------------------
; §4  Image codecs
; ---------------------------------------------------------------------------

; nx_media_blit_nic
;   NIC1: magic +0, u16 w +4, u16 h +6, u8 bpp +8, BGRA pixels +16.
;   Alpha-keyed: A==0 transparent.
nx_media_blit_nic:
    push rbx
    push r14
    push r15
    cmp byte [rdi + 8], 32
    jne .nic_done
    movzx r14d, word [rdi + 4]
    movzx r15d, word [rdi + 6]
    test r14d, r14d
    jz .nic_done
    test r15d, r15d
    jz .nic_done
    lea r12, [rdi + 16]                      ; source
    mov r13, rsi                             ; window
    mov dl, 1                                ; alpha-keyed
    xor r9d, r9d                             ; no reserved bottom strip
    call nx_media_blit_scaled
.nic_done:
    pop r15
    pop r14
    pop rbx
    ret

; nx_media_blit_bmp
;   Decode uncompressed 24/32bpp BMP into slot-local top-down BGRA scratch,
;   then route through the shared scaler so BMP stills are fitted and
;   letterboxed like NIC images. The legacy standalone BMP viewer keeps
;   using app_bmp_draw; this path is media-player-only.
nx_media_blit_bmp:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15
    sub rsp, 48
    ; [rsp +  0] row_stride
    ; [rsp +  4] bpp
    ; [rsp +  8] top_down flag
    ; [rsp + 16] pixel_data ptr
    ; [rsp + 24] scratch ptr

    mov r12, rdi                             ; BMP file
    mov r13, rsi                             ; window

    cmp word [r12], BMP_MAGIC16
    jne .bmp_done
    cmp dword [r12 + 14], 40                 ; BITMAPINFOHEADER minimum
    jb .bmp_done
    cmp word [r12 + 26], 1                   ; planes
    jne .bmp_done
    cmp dword [r12 + 30], 0                  ; BI_RGB only
    jne .bmp_done

    mov r14d, [r12 + 18]                     ; width
    test r14d, r14d
    jle .bmp_done
    mov r15d, [r12 + 22]                     ; signed height
    test r15d, r15d
    jz .bmp_done
    xor eax, eax
    test r15d, r15d
    jns .bmp_height_ok
    neg r15d
    mov eax, 1
.bmp_height_ok:
    mov [rsp + 8], eax                       ; top-down if original < 0

    movzx eax, word [r12 + 28]
    cmp eax, 24
    je .bmp_bpp_ok
    cmp eax, 32
    jne .bmp_done
.bmp_bpp_ok:
    mov [rsp + 4], eax

    ; Scratch guard: w * h * 4 must fit in MEDIA_BMP_SCRATCH_SZ.
    mov eax, r14d
    mul r15d
    jo .bmp_done
    shl rax, 2
    cmp rax, MEDIA_BMP_SCRATCH_SZ
    ja .bmp_done

    ; Row stride = ((w * bytes_per_pixel) + 3) & ~3.
    mov eax, r14d
    cmp dword [rsp + 4], 32
    je .bmp_stride_32
    imul eax, 3
    jmp .bmp_stride_pad
.bmp_stride_32:
    shl eax, 2
.bmp_stride_pad:
    add eax, 3
    and eax, ~3
    mov [rsp + 0], eax

    mov eax, [r12 + 10]
    lea rax, [r12 + rax]
    mov [rsp + 16], rax

    mov rax, [r13 + WIN_OFF_APPDATA]
    add rax, MEDIA_BMP_SCRATCH_OFF
    mov [rsp + 24], rax

    xor ebp, ebp                             ; dest y
.bmp_row_loop:
    cmp ebp, r15d
    jge .bmp_scale

    ; Source row index: top-down keeps y, bottom-up flips y.
    mov eax, ebp
    cmp dword [rsp + 8], 0
    jne .bmp_src_row_ready
    mov eax, r15d
    dec eax
    sub eax, ebp
.bmp_src_row_ready:
    imul eax, [rsp + 0]
    mov rsi, [rsp + 16]
    add rsi, rax

    mov eax, ebp
    imul eax, r14d
    shl eax, 2
    mov rdi, [rsp + 24]
    add rdi, rax

    xor ebx, ebx                             ; x
.bmp_px_loop:
    cmp ebx, r14d
    jge .bmp_next_row

    cmp dword [rsp + 4], 32
    je .bmp_copy_32
    ; 24bpp source is BGR. Store opaque BGRA.
    movzx eax, byte [rsi]                    ; B
    movzx ecx, byte [rsi + 1]                ; G
    shl ecx, 8
    or eax, ecx
    movzx ecx, byte [rsi + 2]                ; R
    shl ecx, 16
    or eax, ecx
    or eax, 0xFF000000
    mov [rdi], eax
    add rsi, 3
    jmp .bmp_px_done
.bmp_copy_32:
    mov eax, [rsi]                           ; already BGRA for BI_RGB
    mov [rdi], eax
    add rsi, 4
.bmp_px_done:
    add rdi, 4
    inc ebx
    jmp .bmp_px_loop

.bmp_next_row:
    inc ebp
    jmp .bmp_row_loop

.bmp_scale:
    mov r12, [rsp + 24]                      ; source BGRA scratch
    mov dl, 0                                ; opaque
    xor r9d, r9d                             ; no reserved bottom strip
    call nx_media_blit_scaled

.bmp_done:
    add rsp, 48
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret


; ---------------------------------------------------------------------------
; §5  Video codecs — NBA + timeline
; ---------------------------------------------------------------------------

; nx_media_advance_frame
;   Per-tick frame advance. Honours pause / loop / pending seek. Writes
;   the resolved frame back into slot state and sets `scene_dirty` on
;   visible change so the WM repaints the next vsync.
;
;   Inputs:
;     r12 = file ptr
;     r13 = window struct ptr
;     ecx = frame_count
;     edx = fps
;   Output:
;     eax = current frame index in [0, frame_count)
;   Clobbers: rax, rbx, rdx (caller saves anything else it cares about).
nx_media_advance_frame:
    push rsi
    push rdi
    push r8
    push r9
    push r10
    push r11

    mov r8, [r13 + WIN_OFF_APPDATA]          ; slot base

    ; 1. Consume any pending seek. mp_seek_to stores target+1; zero =
    ;    "no seek". Clamp and rebase mp_last_tick.
    mov eax, [r8 + app_hl_media_mp_seek_to - app_blob_start]
    test eax, eax
    jz .adv_no_seek
    dec eax
    test eax, eax
    jns .adv_seek_nonneg
    xor eax, eax
.adv_seek_nonneg:
    cmp eax, ecx
    jb .adv_seek_in_range
    mov eax, ecx
    dec eax
.adv_seek_in_range:
    mov [r8 + app_hl_media_mp_frame - app_blob_start], eax
    mov rbx, [tick_count]
    mov [r8 + app_hl_media_mp_last_tick - app_blob_start], rbx
    mov dword [r8 + app_hl_media_mp_seek_to - app_blob_start], 0
    mov byte [scene_dirty], 1
    jmp .adv_clamp

.adv_no_seek:
    ; 2. Bring slot-saved frame into range (slots zero-init so frame 0 is
    ;    the valid resting state on first draw).
    mov eax, [r8 + app_hl_media_mp_frame - app_blob_start]
    cmp eax, ecx
    jb .adv_in_range
    xor eax, eax
    mov [r8 + app_hl_media_mp_frame - app_blob_start], eax
.adv_in_range:

    ; 3. Frozen if paused or single-frame clip.
    cmp dword [r8 + app_hl_media_mp_paused - app_blob_start], 0
    jne .adv_clamp
    cmp ecx, 1
    jbe .adv_clamp

    ; Animated and playing: media_live_refresh wakes the compositor on the
    ; frame boundary. Do not dirty here unless the frame actually changes.

    ; 4. interval_ticks = max(1, 100 / fps).
    mov r10d, eax                            ; current frame
    mov eax, 100
    xor edx, edx
    div dword [r12 + 16]
    test eax, eax
    jnz .adv_interval_ok
    mov eax, 1
.adv_interval_ok:
    mov r11d, eax                            ; interval ticks

    mov rax, [tick_count]
    mov rbx, [r8 + app_hl_media_mp_last_tick - app_blob_start]
    test rbx, rbx
    jnz .adv_have_last_tick
    ; First tick after open: seed last_tick, stay on frame 0.
    mov [r8 + app_hl_media_mp_last_tick - app_blob_start], rax
    mov eax, r10d
    jmp .adv_clamp
.adv_have_last_tick:
    mov r9, rax
    sub r9, rbx
    cmp r9d, r11d
    jb .adv_no_advance

    ; advanced_frames = (now - last) / interval
    mov rax, r9
    xor edx, edx
    div r11
    add eax, r10d                            ; new frame index (raw)

    cmp dword [r8 + app_hl_media_mp_no_loop - app_blob_start], 0
    je .adv_loop
    ; Freeze at last frame.
    cmp eax, ecx
    jb .adv_store
    mov eax, ecx
    dec eax
    jmp .adv_store
.adv_loop:
    xor edx, edx
    div ecx
    mov eax, edx                             ; raw mod frame_count
.adv_store:
    mov [r8 + app_hl_media_mp_frame - app_blob_start], eax
    mov rbx, [tick_count]
    mov [r8 + app_hl_media_mp_last_tick - app_blob_start], rbx
    mov byte [scene_dirty], 1
    jmp .adv_clamp
.adv_no_advance:
    mov eax, r10d

.adv_clamp:
    cmp eax, ecx
    jb .adv_ret
    xor eax, eax
.adv_ret:
    pop r11
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
    ret


; nx_media_blit_nba
;   NBA1: magic +0, u32 w +4, u32 h +8, u32 frame_count +12, u32 fps +16,
;   dense BGRA frames at +20.
nx_media_blit_nba:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi
    mov r13, rsi

    mov r14d, [r12 + 4]
    mov r15d, [r12 + 8]
    mov ecx,  [r12 + 12]
    mov edx,  [r12 + 16]
    test r14d, r14d
    jz .nba_done
    test r15d, r15d
    jz .nba_done
    test ecx, ecx
    jz .nba_done
    test edx, edx
    jz .nba_done

    ; Clamp frame_count to what the active source buffer can actually hold.
    ; r8 (set by app_media_draw) = source buffer capacity in bytes: either the
    ; window's own full-clip buffer or, when none is live, the 256 KiB slot
    ; buffer. A header may advertise more frames than the buffer holds (e.g. a
    ; truncated/failed load); without this clamp the per-frame source walk reads
    ; past the buffer into unmapped memory and faults, freezing the OS.
    push rdx                                 ; preserve fps
    mov eax, r14d
    mov r9d, r15d
    imul rax, r9                             ; w * h
    shl rax, 2                               ; frame stride in bytes
    jz .nba_clamp_done                       ; degenerate stride: leave as-is
    mov r10, rax                             ; r10 = frame stride
    mov rax, r8                              ; source capacity in bytes
    cmp rax, 20
    jbe .nba_clamp_none                      ; can't even hold the header
    sub rax, 20                              ; minus NBA header
    xor edx, edx
    div r10                                  ; rax = whole frames that fit
    cmp ecx, eax
    jbe .nba_clamp_done
    mov ecx, eax                             ; clamp frame_count down to fit
    jmp .nba_clamp_done
.nba_clamp_none:
    xor ecx, ecx
.nba_clamp_done:
    pop rdx                                  ; restore fps
    test ecx, ecx
    jz .nba_done                             ; nothing fits -> blank, never fault

    ; Resolve current frame (handles seek/pause/loop, writes state).
    call nx_media_advance_frame              ; eax = frame index
    mov ebx, eax                             ; preserve

    ; Source frame ptr.
    mov esi, r14d
    imul esi, r15d
    shl esi, 2                               ; frame stride bytes
    mov eax, ebx
    mul rsi                                  ; rax = frame * stride
    lea rsi, [r12 + 20]
    add rsi, rax

    ; Hand off to the scaler.
    push r12
    mov r12, rsi                             ; source for scaler
    mov dl, 0                                ; opaque
    mov r9d, MEDIA_BAR_H                     ; reserve bottom strip
    call nx_media_blit_scaled
    pop r12

    ; Draw the control bar over the bottom MEDIA_BAR_H px.
    mov rdi, r12
    mov rsi, r13
    mov edx, ebx
    mov ecx, [r12 + 12]
    mov r8d, [r12 + 16]
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
; §6  Vector codecs — SVG (subset) and XML text view
;
; Scope (mirrored in docs/media-formats.md):
;   * XML: rendered as plain top-aligned text. No scrolling (TODO).
;   * SVG: static preview. The real NexusHL SVG2 renderer supports the
;     wallpaper sources; this asm draw path paints a recognisable dark
;     ribbon preview instead of opening SVGs as blank/white text.
;
; Why a subset rather than full SVG: a complete SVG implementation
; (transforms, gradients, paths, text, CSS) is a multi-week project in
; asm. The subset is enough for icons and simple diagrams while keeping
; the renderer auditable in one screen.
; ---------------------------------------------------------------------------

; nx_media_blit_xml
;   Render the file as plain text, one line per FONT_HEIGHT+1 row.
;   RDI = file, RSI = window. The file is null-padded by the loader so
;   a NUL terminates the walk.
nx_media_blit_xml:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi
    mov r13, rsi

    ; Letterbox the client area in the text-bg colour.
    mov edi, [r13 + WIN_OFF_X]
    add edi, BORDER_WIDTH
    mov esi, [r13 + WIN_OFF_Y]
    add esi, TITLEBAR_HEIGHT
    mov edx, [r13 + WIN_OFF_W]
    sub edx, BORDER_WIDTH * 2
    mov ecx, [r13 + WIN_OFF_H]
    sub ecx, TITLEBAR_HEIGHT
    sub ecx, BORDER_WIDTH
    mov r8d, MEDIA_COL_TEXT_BG
    call nx_media_fill_rect

    mov r14, r12                             ; line start cursor
    mov r15d, [r13 + WIN_OFF_Y]
    add r15d, TITLEBAR_HEIGHT + 4            ; current text y

    mov ebp, [r13 + WIN_OFF_Y]
    add ebp, [r13 + WIN_OFF_H]
    sub ebp, BORDER_WIDTH                    ; bottom edge

.xml_line:
    cmp r15d, ebp
    jge .xml_done
    cmp byte [r14], 0
    je .xml_done

    ; Find end-of-line: LF or NUL.
    mov rbx, r14
.xml_eol:
    mov al, [rbx]
    test al, al
    jz .xml_emit_eof
    cmp al, 0x0A
    je .xml_emit_lf
    inc rbx
    jmp .xml_eol

.xml_emit_lf:
    ; Temporarily replace LF with NUL so draw_string treats this slice
    ; as a C string. Restore after.
    mov byte [rbx], 0
    mov edi, [r13 + WIN_OFF_X]
    add edi, BORDER_WIDTH + 4
    mov esi, r15d
    mov rdx, r14
    mov ecx, MEDIA_COL_TEXT_FG
    mov r8d, MEDIA_COL_TEXT_BG
    push rbx
    call draw_string
    pop rbx
    mov byte [rbx], 0x0A                     ; restore
    inc rbx
    mov r14, rbx
    add r15d, FONT_HEIGHT + 1
    jmp .xml_line

.xml_emit_eof:
    mov edi, [r13 + WIN_OFF_X]
    add edi, BORDER_WIDTH + 4
    mov esi, r15d
    mov rdx, r14
    mov ecx, MEDIA_COL_TEXT_FG
    mov r8d, MEDIA_COL_TEXT_BG
    call draw_string

.xml_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret


; nx_media_blit_svg
;   Static SVG preview for Media Player's kernel-side draw fn.
;
;   A full SVG2 renderer already exists in nxh land:
;   `src/user/nexushl/lib/svg2.nxh → svg_render(buf, len, x, y, w, h)`.
;   Wiring it directly to this codec still requires moving this draw fn to
;   user-mode. Until then, this path draws a deterministic thumbnail-like
;   preview so SVG-backed wallpapers are visibly viewable from Explorer.
nx_media_blit_svg:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15
    sub rsp, 32

    mov r12, rdi
    mov r13, rsi

    mov edi, [r13 + WIN_OFF_X]
    add edi, BORDER_WIDTH
    mov [rsp + 0], edi                       ; client_x
    mov esi, [r13 + WIN_OFF_Y]
    add esi, TITLEBAR_HEIGHT
    mov [rsp + 4], esi                       ; client_y
    mov edx, [r13 + WIN_OFF_W]
    sub edx, BORDER_WIDTH * 2
    mov [rsp + 8], edx                       ; client_w
    mov ecx, [r13 + WIN_OFF_H]
    sub ecx, TITLEBAR_HEIGHT
    sub ecx, BORDER_WIDTH
    mov [rsp + 12], ecx                      ; client_h
    mov r8d, 0x00050508
    call nx_media_fill_rect

    ; Soft central glow, approximated with nested solid rectangles.
    mov edi, [rsp + 8]
    imul edi, 30
    mov eax, edi
    mov ecx, 100
    cdq
    idiv ecx
    mov r14d, eax                            ; glow_w = w * 30%
    mov edi, [rsp + 12]
    imul edi, 22
    mov eax, edi
    mov ecx, 100
    cdq
    idiv ecx
    mov r15d, eax                            ; glow_h = h * 22%

    mov edi, [rsp + 0]
    mov eax, [rsp + 8]
    sub eax, r14d
    sar eax, 1
    add edi, eax
    mov esi, [rsp + 4]
    mov eax, [rsp + 12]
    sub eax, r15d
    sar eax, 1
    add esi, eax
    mov edx, r14d
    mov ecx, r15d
    mov r8d, 0x00102A4A
    call nx_media_fill_rect

    ; Cyan lower-left ribbon.
    mov edi, [rsp + 0]
    mov esi, [rsp + 4]
    mov eax, [rsp + 12]
    imul eax, 58
    mov ecx, 100
    cdq
    idiv ecx
    add esi, eax
    mov edx, [rsp + 8]
    imul edx, 62
    mov eax, edx
    mov ecx, 100
    cdq
    idiv ecx
    mov edx, eax
    mov ecx, [rsp + 12]
    imul ecx, 9
    mov eax, ecx
    mov ecx, 100
    cdq
    idiv ecx
    mov ecx, eax
    mov r8d, 0x0000D7E8
    call nx_media_fill_rect

    ; Magenta upper-left fold.
    mov edi, [rsp + 0]
    mov esi, [rsp + 4]
    mov eax, [rsp + 12]
    imul eax, 30
    mov ecx, 100
    cdq
    idiv ecx
    add esi, eax
    mov edx, [rsp + 8]
    imul edx, 52
    mov eax, edx
    mov ecx, 100
    cdq
    idiv ecx
    mov edx, eax
    mov ecx, [rsp + 12]
    imul ecx, 8
    mov eax, ecx
    mov ecx, 100
    cdq
    idiv ecx
    mov ecx, eax
    mov r8d, 0x00FF0844
    call nx_media_fill_rect

    ; Violet upper-right flow.
    mov edi, [rsp + 0]
    mov eax, [rsp + 8]
    imul eax, 45
    mov ecx, 100
    cdq
    idiv ecx
    add edi, eax
    mov esi, [rsp + 4]
    mov eax, [rsp + 12]
    imul eax, 24
    mov ecx, 100
    cdq
    idiv ecx
    add esi, eax
    mov edx, [rsp + 8]
    imul edx, 50
    mov eax, edx
    mov ecx, 100
    cdq
    idiv ecx
    mov edx, eax
    mov ecx, [rsp + 12]
    imul ecx, 10
    mov eax, ecx
    mov ecx, 100
    cdq
    idiv ecx
    mov ecx, eax
    mov r8d, 0x00667EEA
    call nx_media_fill_rect

    ; Deep lower-right twist.
    mov edi, [rsp + 0]
    mov eax, [rsp + 8]
    imul eax, 48
    mov ecx, 100
    cdq
    idiv ecx
    add edi, eax
    mov esi, [rsp + 4]
    mov eax, [rsp + 12]
    imul eax, 70
    mov ecx, 100
    cdq
    idiv ecx
    add esi, eax
    mov edx, [rsp + 8]
    imul edx, 48
    mov eax, edx
    mov ecx, 100
    cdq
    idiv ecx
    mov edx, eax
    mov ecx, [rsp + 12]
    imul ecx, 9
    mov eax, ecx
    mov ecx, 100
    cdq
    idiv ecx
    mov ecx, eax
    mov r8d, 0x004F46E5
    call nx_media_fill_rect

    add rsp, 32
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret


; ---------------------------------------------------------------------------
; §7  Control bar UI
;
; Layout (mirrored in media.nxh):
;
;   +-------+-------+-------+--------------------------------+--------+
;   | PLAY  | -10s  | +10s  |  scrub track                   |  MM:SS |
;   +-------+-------+-------+--------------------------------+--------+
;     28px    28px    28px        flex                          56px
;
; All drawing is clipped by nx_media_fill_rect, so an undersized window
; just clips the rightmost elements instead of crashing.
; ---------------------------------------------------------------------------

; Glyph: ▶ play triangle. 12 px tall, widens by 1 px per row up to the
; midpoint, then narrows. edi=x, esi=y, edx=color.
nx_media_draw_glyph_play:
    push rbx
    push r12
    push r13
    push r14
    mov r12d, edi
    mov r13d, esi
    mov r14d, edx
    xor ebx, ebx
.gp_row:
    cmp ebx, 12
    jge .gp_done
    mov edi, r12d
    mov esi, r13d
    add esi, ebx
    mov edx, ebx
    cmp edx, 6
    jb .gp_grow
    mov edx, 11
    sub edx, ebx
.gp_grow:
    add edx, 1
    mov ecx, 1
    mov r8d, r14d
    call nx_media_fill_rect
    inc ebx
    jmp .gp_row
.gp_done:
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

; Glyph: ⏸ pause. Two 3×10 bars 4 px apart. edi=x, esi=y, edx=color.
nx_media_draw_glyph_pause:
    push r12
    push r13
    push r14
    mov r12d, edi
    mov r13d, esi
    mov r14d, edx

    mov edi, r12d
    mov esi, r13d
    mov edx, 3
    mov ecx, 10
    mov r8d, r14d
    call nx_media_fill_rect

    mov edi, r12d
    add edi, 7
    mov esi, r13d
    mov edx, 3
    mov ecx, 10
    mov r8d, r14d
    call nx_media_fill_rect

    pop r14
    pop r13
    pop r12
    ret

; Glyph: ⏪ skip back. Two ◀ triangles, 12 px wide total, 10 px tall.
;   edi=x, esi=y, edx=color
nx_media_draw_glyph_skip_back:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    mov r12d, edi                            ; x
    mov r13d, esi                            ; y
    mov r14d, edx                            ; color
    xor ebx, ebx
.gsb_row:
    cmp ebx, 10
    jge .gsb_done
    ; width grows then shrinks across 10 rows (peak at row 5).
    mov ebp, ebx
    cmp ebp, 5
    jb .gsb_grow
    mov ebp, 9
    sub ebp, ebx
.gsb_grow:
    add ebp, 1                               ; ebp = current row width
    ; First triangle: apex left at x+5-w, base flush at x+5.
    mov edi, r12d
    add edi, 5
    sub edi, ebp
    mov esi, r13d
    add esi, ebx
    mov edx, ebp
    mov ecx, 1
    mov r8d, r14d
    call nx_media_fill_rect
    ; Second triangle: apex at x+11-w, base flush at x+11.
    mov edi, r12d
    add edi, 11
    sub edi, ebp
    mov esi, r13d
    add esi, ebx
    mov edx, ebp
    mov ecx, 1
    mov r8d, r14d
    call nx_media_fill_rect
    inc ebx
    jmp .gsb_row
.gsb_done:
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret

; Glyph: ⏩ skip forward.
nx_media_draw_glyph_skip_fwd:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    mov r12d, edi
    mov r13d, esi
    mov r14d, edx
    xor ebx, ebx
.gsf_row:
    cmp ebx, 10
    jge .gsf_done
    mov ebp, ebx
    cmp ebp, 5
    jb .gsf_grow
    mov ebp, 9
    sub ebp, ebx
.gsf_grow:
    add ebp, 1
    ; First triangle: apex right at x+ebp, base flush at x.
    mov edi, r12d
    mov esi, r13d
    add esi, ebx
    mov edx, ebp
    mov ecx, 1
    mov r8d, r14d
    call nx_media_fill_rect
    ; Second triangle: apex at x+6+ebp, base flush at x+6.
    mov edi, r12d
    add edi, 6
    mov esi, r13d
    add esi, ebx
    mov edx, ebp
    mov ecx, 1
    mov r8d, r14d
    call nx_media_fill_rect
    inc ebx
    jmp .gsf_row
.gsf_done:
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret

; nx_media_format_mmss(rdi=buf, eax=seconds)
;   Writes "MM:SS" + NUL into the 6-byte buffer at RDI. Caps minutes at
;   99 (display rolls over at 99:59).
nx_media_format_mmss:
    push rbx
    push rcx
    push rdx
    push rdi
    xor edx, edx
    mov ecx, 60
    div ecx                                  ; eax = minutes, edx = secs
    mov ebx, edx                             ; secs
    cmp eax, 99
    jbe .mmss_ok
    mov eax, 99
    mov ebx, 59
.mmss_ok:
    mov edi, [rsp]
    ; minutes (two digits).
    xor edx, edx
    mov ecx, 10
    div ecx
    add al, '0'
    mov [rdi + 0], al
    add dl, '0'
    mov [rdi + 1], dl
    mov byte [rdi + 2], ':'
    ; seconds.
    mov eax, ebx
    xor edx, edx
    mov ecx, 10
    div ecx
    add al, '0'
    mov [rdi + 3], al
    add dl, '0'
    mov [rdi + 4], dl
    mov byte [rdi + 5], 0
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    ret

; Scratch text buffers for the time label. Single-tenant — the WM draws
; windows sequentially so two players don't overlap their formatting.
nx_media_time_cur: times 8 db 0
nx_media_time_dur: times 8 db 0
sz_media_time_sep: db " / ", 0

; nx_media_draw_nba_controls
;   Inputs:
;     rdi = file ptr (NBA header)
;     rsi = window struct ptr
;     edx = current frame
;     ecx = frame count
;     r8d = fps
;
;   Local stack frame (after `sub rsp, 32`):
;     [rsp +  0]  bar_x  (dword)
;     [rsp +  4]  bar_y  (dword)
;     [rsp +  8]  bar_w  (dword)
;     [rsp + 12]  fps    (dword)
;     [rsp + 16]  cur_frame
;     [rsp + 20]  frame_count
;     [rsp + 24]  track_w
;     [rsp + 28]  filled_px
nx_media_draw_nba_controls:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15
    sub rsp, 32

    mov r12, rdi
    mov r13, rsi
    mov [rsp + 16], edx                      ; cur frame
    mov [rsp + 20], ecx                      ; frame count
    mov [rsp + 12], r8d                      ; fps

    ; Bar geometry.
    mov eax, [r13 + WIN_OFF_X]
    add eax, BORDER_WIDTH
    mov [rsp + 0], eax                       ; bar_x
    mov eax, [r13 + WIN_OFF_Y]
    add eax, [r13 + WIN_OFF_H]
    sub eax, BORDER_WIDTH
    sub eax, MEDIA_BAR_H
    mov [rsp + 4], eax                       ; bar_y
    mov eax, [r13 + WIN_OFF_W]
    sub eax, BORDER_WIDTH * 2
    mov [rsp + 8], eax                       ; bar_w

    ; Bar background.
    mov edi, [rsp + 0]
    mov esi, [rsp + 4]
    mov edx, [rsp + 8]
    mov ecx, MEDIA_BAR_H
    mov r8d, MEDIA_COL_BAR_BG
    call nx_media_fill_rect

    ; Three button backgrounds (PLAY / -10s / +10s).
    ; PLAY
    mov edi, [rsp + 0]
    add edi, MEDIA_BTN_PLAY_X + 2
    mov esi, [rsp + 4]
    add esi, 5
    mov edx, MEDIA_BTN_W - 4
    mov ecx, 16
    mov r8d, MEDIA_COL_BTN_BG
    call nx_media_fill_rect
    ; -10s
    mov edi, [rsp + 0]
    add edi, MEDIA_BTN_BACK_X + 2
    mov esi, [rsp + 4]
    add esi, 5
    mov edx, MEDIA_BTN_W - 4
    mov ecx, 16
    mov r8d, MEDIA_COL_BTN_BG
    call nx_media_fill_rect
    ; +10s
    mov edi, [rsp + 0]
    add edi, MEDIA_BTN_FWD_X + 2
    mov esi, [rsp + 4]
    add esi, 5
    mov edx, MEDIA_BTN_W - 4
    mov ecx, 16
    mov r8d, MEDIA_COL_BTN_BG
    call nx_media_fill_rect

    ; Play / pause glyph.
    mov rax, [r13 + WIN_OFF_APPDATA]
    cmp dword [rax + app_hl_media_mp_paused - app_blob_start], 0
    je .ctl_glyph_pause
    mov edi, [rsp + 0]
    add edi, MEDIA_BTN_PLAY_X + 7
    mov esi, [rsp + 4]
    add esi, 7
    mov edx, MEDIA_COL_GLYPH
    call nx_media_draw_glyph_play
    jmp .ctl_skip_glyphs
.ctl_glyph_pause:
    mov edi, [rsp + 0]
    add edi, MEDIA_BTN_PLAY_X + 9
    mov esi, [rsp + 4]
    add esi, 8
    mov edx, MEDIA_COL_GLYPH
    call nx_media_draw_glyph_pause
.ctl_skip_glyphs:

    ; -10s glyph
    mov edi, [rsp + 0]
    add edi, MEDIA_BTN_BACK_X + 8
    mov esi, [rsp + 4]
    add esi, 8
    mov edx, MEDIA_COL_GLYPH
    call nx_media_draw_glyph_skip_back

    ; +10s glyph
    mov edi, [rsp + 0]
    add edi, MEDIA_BTN_FWD_X + 8
    mov esi, [rsp + 4]
    add esi, 8
    mov edx, MEDIA_COL_GLYPH
    call nx_media_draw_glyph_skip_fwd

    ; Scrub track.
    mov eax, [rsp + 8]                       ; bar_w
    sub eax, MEDIA_SCRUB_X
    sub eax, MEDIA_TIME_W
    cmp eax, 4
    jle .ctl_no_scrub
    mov [rsp + 24], eax                      ; track_w
    mov edi, [rsp + 0]
    add edi, MEDIA_SCRUB_X
    mov esi, [rsp + 4]
    add esi, 12
    mov edx, eax
    mov ecx, 3
    mov r8d, MEDIA_COL_TRACK_BG
    call nx_media_fill_rect

    ; Progress fill: (cur+1) * track_w / frame_count.
    mov eax, [rsp + 16]
    inc eax
    mul dword [rsp + 24]                     ; rdx:rax = (cur+1)*track_w
    mov ecx, [rsp + 20]
    test ecx, ecx
    jz .ctl_no_progress
    div ecx                                   ; eax = filled px
    mov [rsp + 28], eax
    mov edi, [rsp + 0]
    add edi, MEDIA_SCRUB_X
    mov esi, [rsp + 4]
    add esi, 12
    mov edx, eax
    mov ecx, 3
    mov r8d, MEDIA_COL_TRACK_FG
    call nx_media_fill_rect

    ; Knob: 5×9 centred at the fill end.
    mov edi, [rsp + 0]
    add edi, MEDIA_SCRUB_X
    add edi, [rsp + 28]
    sub edi, 2
    mov esi, [rsp + 4]
    add esi, 9
    mov edx, 5
    mov ecx, 9
    mov r8d, MEDIA_COL_KNOB
    call nx_media_fill_rect
.ctl_no_progress:
.ctl_no_scrub:

    ; "MM:SS" current — drawn in the right-edge time area. We only show
    ; current (duration would overflow MEDIA_TIME_W with default font).
    mov ecx, [rsp + 12]                      ; fps
    test ecx, ecx
    jz .ctl_done
    mov eax, [rsp + 16]
    xor edx, edx
    div ecx                                   ; eax = current seconds
    lea rdi, [rel nx_media_time_cur]
    call nx_media_format_mmss

    mov eax, [rsp + 0]
    add eax, [rsp + 8]
    sub eax, MEDIA_TIME_W
    add eax, 4
    mov edi, eax
    mov esi, [rsp + 4]
    add esi, 8
    lea rdx, [rel nx_media_time_cur]
    mov ecx, MEDIA_COL_TEXT_FG
    mov r8d, MEDIA_COL_BAR_BG
    call draw_string

.ctl_done:
    add rsp, 32
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret


; ---------------------------------------------------------------------------
; §8  Future-work notes (kept here so the work surface stays discoverable)
;
;   STATUS: SYS_MEDIA_BLIT_SCALED (syscall #66) is live. The scaler in
;   §3 is now reachable from user-mode NexusHL via the helper
;   `media_blit_scaled(...)` in `src/user/nexushl/lib/media.nxh`. The
;   kernel-side validation lives in `syscall.asm → .sc_media_blit_scaled`
;   and covers: buffer range, dim bounds, byte-count cap, window id,
;   reserve-bottom clamp, alpha-key normalisation. Future apps should
;   call the syscall rather than carry their own scaler.
;
;   * SIMD scaler. The §3 inner loop is scalar. An SSE2 form that
;     advances `u` by 4*step per iteration and writes a 16-byte chunk
;     would roughly double throughput on real HW. Blocked on the WM
;     adding xmm save/restore around draw callbacks — none of the other
;     codecs need xmm today and the WM doesn't preserve it.
;
;   * Dirty-rect awareness. We redraw the whole client area each tick.
;     Frame index changes only every (100/fps) ticks; on no-change
;     ticks we could skip the blit and just redraw the scrub knob.
;     This would slash idle CPU during paused / single-frame playback.
;
;   * BMP through the shared scaler. Landed for uncompressed 24/32bpp
;     BI_RGB BMP in the Media Player path. The standalone legacy BMP
;     viewer still routes to app_bmp_draw.
;
;   * SVG subset rasteriser. Walk the file once; for each <rect>,
;     <circle>, <line> with a recognised fill/stroke attribute, draw
;     scaled by the same fit transform we use for bitmaps. Strict
;     subset only — no transforms, no gradients, no text, no CSS.
;
;   * Audio. Out of scope until the kernel has an audio mixer.
; ---------------------------------------------------------------------------
