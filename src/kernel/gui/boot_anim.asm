; ============================================================================
; NexusOS v3.0 - Boot Animation Player
; Plays /BOOTANIM.NBA (particle-form NexusOS logo) over the boot screen.
; Skipped if any key is held when called.
;
; File format (little-endian):
;   0  : 'NBA1' magic
;   4  : uint32 width
;   8  : uint32 height
;  12  : uint32 frame_count
;  16  : uint32 fps
;  20  : BGRA frame data (width*height*4 * frame_count bytes)
; ============================================================================
bits 64

%include "constants.inc"

%macro BA_DBG 1
    push rax
    push rdx
    mov dx, 0x3F8
    mov al, %1
    out dx, al
    pop rdx
    pop rax
%endmacro

extern fat16_file_count
extern fat16_get_entry
extern fat16_read_file
extern bb_addr
extern scr_width
extern scr_height
extern scr_pitch_q
extern display_flip
extern tick_count
extern kb_head
extern kb_tail
extern kb_repeat_scancode

; 8 MiB scratch region for the loaded .nba file. Above SYSTEM_RESERVED_END
; (0x5600000) so it does not clash with the wallpaper/drag caches or the
; XHCI rings; well within the 512 GiB the UEFI loader maps.
BOOT_ANIM_BUF       equ 0x6000000
BOOT_ANIM_BUF_SIZE  equ 0x1000000

DIR_FIRST_CLUS_LO   equ 26
DIR_FILE_SIZE       equ 28
DIR_ENTRY_SIZE      equ 32

section .text

; --- boot_anim_should_skip ---
; Returns eax = 1 if a key is currently held or buffered, else 0.
boot_anim_should_skip:
    ; "Currently held" only — kb_repeat_scancode is set on press and cleared
    ; on release. The kb buffer (head/tail) is not checked because boot-time
    ; PS/2 chatter (ACK bytes, etc.) can leave junk there before the main
    ; loop drains it.
    movzx eax, byte [kb_repeat_scancode]
    test eax, eax
    jz .no
    mov eax, 1
    ret
.no:
    xor eax, eax
    ret

; --- boot_anim_find ---
; Find the BOOTANIM.NBA dir entry by name. Returns rax = entry ptr or 0.
boot_anim_find:
    push rbx
    push rcx
    push rdi
    push rsi
    call fat16_file_count
    mov ecx, eax
    xor ebx, ebx
.loop:
    cmp ebx, ecx
    jge .notfound
    mov edi, ebx
    call fat16_get_entry
    test rax, rax
    jz .notfound
    ; Compare first 11 bytes vs "BOOTANIMNBA"
    lea rsi, [rel boot_anim_name]
    mov rdi, rax
    push rcx
    mov ecx, 11
    repe cmpsb
    pop rcx
    je .found
    inc ebx
    jmp .loop
.notfound:
    xor eax, eax
.found:
    pop rsi
    pop rdi
    pop rcx
    pop rbx
    ret

; --- boot_anim_wait_ticks ---
; Wait edi ticks of tick_count (100Hz). Returns early (eax=1) if skip pressed.
boot_anim_wait_ticks:
    push rbx
    push rcx
    mov ebx, [tick_count]
    add ebx, edi               ; target tick
.wait:
    call boot_anim_should_skip
    test eax, eax
    jnz .skip
    mov ecx, [tick_count]
    cmp ecx, ebx
    jge .done
    hlt
    jmp .wait
.skip:
    pop rcx
    pop rbx
    mov eax, 1
    ret
.done:
    pop rcx
    pop rbx
    xor eax, eax
    ret

; --- boot_anim_blit ---
; Blit a single BGRA frame centered in the back buffer.
; rsi = frame data ptr, edi = width, edx = height
boot_anim_blit:
    push rbx
    push rcx
    push rdx
    push rdi
    push rsi
    push r8
    push r9
    push r10
    push r11

    mov r10d, edi              ; frame width
    mov r11d, edx              ; frame height

    ; dest_x = (scr_width  - w) / 2
    mov eax, [scr_width]
    sub eax, r10d
    shr eax, 1
    mov r8d, eax               ; dest_x

    ; dest_y = (scr_height - h) / 2
    mov eax, [scr_height]
    sub eax, r11d
    shr eax, 1
    mov r9d, eax               ; dest_y

    mov rbx, [bb_addr]
    test rbx, rbx
    jz .out
    mov rcx, [scr_pitch_q]

    ; Base dest pointer = bb_addr + dest_y * pitch + dest_x*4
    mov rax, r9
    imul rax, rcx
    add rbx, rax
    mov eax, r8d
    shl eax, 2
    add rbx, rax

    mov edx, r11d              ; row counter
.row_loop:
    test edx, edx
    jz .out
    ; Copy one row: r10 pixels = r10*4 bytes from rsi to rbx
    mov rdi, rbx
    push rsi
    push rcx
    mov ecx, r10d              ; pixel count
    rep movsd                   ; copies ecx dwords from [rsi] to [rdi]
    pop rcx
    pop rsi
    add rsi, r10                ; advance src by w*4
    add rsi, r10
    add rsi, r10
    add rsi, r10
    add rbx, rcx                ; next dest row
    dec edx
    jmp .row_loop
.out:
    pop r11
    pop r10
    pop r9
    pop r8
    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    ret

; --- boot_anim_clear_bb ---
; Clear back buffer to black so the centered animation has a clean canvas.
boot_anim_clear_bb:
    push rax
    push rcx
    push rdi
    mov rdi, [bb_addr]
    test rdi, rdi
    jz .done
    mov eax, [scr_height]
    mov rcx, [scr_pitch_q]
    imul rcx, rax
    shr rcx, 3                 ; qwords
    xor eax, eax
    rep stosq
.done:
    pop rdi
    pop rcx
    pop rax
    ret

; --- boot_anim_play ---
; Public entry. Loads BOOTANIM.NBA, plays it once, returns when done or skipped.
global boot_anim_play
boot_anim_play:
    push rbx
    push rcx
    push rdx
    push rdi
    push rsi
    push r12
    push r13
    push r14
    push r15

    BA_DBG '@'                  ; entered

    ; Skip if a key is already held
    call boot_anim_should_skip
    test eax, eax
    jz .nokey
    BA_DBG '/'
    jmp .ret
.nokey:
    BA_DBG '#'                  ; about to find file

    ; Find file
    call boot_anim_find
    test rax, rax
    jnz .found
    BA_DBG '?'                  ; not found
    jmp .ret
.found:
    BA_DBG '&'
    mov r12, rax               ; dir entry

    ; Read into BOOT_ANIM_BUF
    mov rdi, r12
    mov rsi, BOOT_ANIM_BUF
    mov edx, BOOT_ANIM_BUF_SIZE
    call fat16_read_file
    test eax, eax
    jg .read_ok
    BA_DBG '$'                  ; read failed
    jmp .ret
.read_ok:
    BA_DBG '%'
    mov r13d, eax              ; bytes read

    ; Validate magic 'NBA1' = 0x3141424E (little-endian: 'N'=0x4E,'B'=0x42,'A'=0x41,'1'=0x31)
    mov rbx, BOOT_ANIM_BUF
    mov eax, [rbx]
    cmp eax, 0x3141424E
    je .magic_ok
    BA_DBG '+'                  ; bad magic
    jmp .ret
.magic_ok:
    BA_DBG '*'

    ; Parse header
    mov r14d, [rbx + 4]        ; width
    mov r15d, [rbx + 8]        ; height
    mov ecx,  [rbx + 12]       ; frame_count
    mov edx,  [rbx + 16]       ; fps

    ; Sanity: width <= scr_width, height <= scr_height, frame_count > 0
    test ecx, ecx
    jz .ret
    test edx, edx
    jz .ret
    mov eax, [scr_width]
    cmp r14d, eax
    ja .ret
    mov eax, [scr_height]
    cmp r15d, eax
    ja .ret

    ; ticks_per_frame = max(1, 100 / fps)
    mov eax, 100
    xor edx, edx
    mov esi, ecx                   ; preserve frame_count in rsi temporarily
    mov ecx, [rbx + 16]            ; reload fps
    div ecx
    test eax, eax
    jnz .tpf_ok
    mov eax, 1
.tpf_ok:
    mov [rel boot_anim_tpf], eax
    mov ecx, esi                   ; restore frame_count
    mov [rel boot_anim_frames], ecx

    ; Per-frame stride in bytes = w * h * 4
    mov eax, r14d
    imul eax, r15d
    shl eax, 2
    mov [rel boot_anim_stride], eax

    ; rsi = first frame ptr = BOOT_ANIM_BUF + 20
    mov rsi, BOOT_ANIM_BUF
    add rsi, 20

    ; Clear backbuffer once
    call boot_anim_clear_bb
    BA_DBG '~'                      ; about to play

    xor ebx, ebx                   ; frame index
.frame_loop:
    cmp ebx, [rel boot_anim_frames]
    jge .done_play

    BA_DBG '.'
    ; Blit centered: edi=w, edx=h, rsi=frame ptr
    mov edi, r14d
    mov edx, r15d
    call boot_anim_blit
    BA_DBG ','

    call display_flip
    BA_DBG ';'

    mov edi, [rel boot_anim_tpf]
    call boot_anim_wait_ticks
    test eax, eax
    jnz .ret                       ; skip key pressed

    ; Advance to next frame
    mov eax, [rel boot_anim_stride]
    add rsi, rax
    inc ebx
    jmp .frame_loop

.done_play:
    BA_DBG '<'
.ret:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    ret

section .data
boot_anim_name      db "BOOTANIMNBA"

section .bss
alignb 8
boot_anim_tpf       resd 1
boot_anim_frames    resd 1
boot_anim_stride    resd 1
