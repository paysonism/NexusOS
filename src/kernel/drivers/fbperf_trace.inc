; ---------------------------------------------------------------------------
fbperf_rdtsc:
    rdtsc
    shl rdx, 32
    or  rax, rdx
    ret

; ---------------------------------------------------------------------------
; Print rdi as 16 hex digits via serial_putc. Preserves all regs.
; ---------------------------------------------------------------------------
fbperf_ser_hex64:
    push rax
    push rbx
    push rcx
    push rdx
    push rdi
    mov rbx, rdi
    mov rcx, 16
.loop:
    rol rbx, 4
    mov al, bl
    and al, 0x0F
    cmp al, 10
    jl  .digit
    add al, 'A' - '0' - 10
.digit:
    add al, '0'
    call serial_putc
    dec rcx
    jnz .loop
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; ---------------------------------------------------------------------------
; Emit "<label> <hex64>\r\n"
; rdi = label cstring, rsi = qword
; ---------------------------------------------------------------------------
fbperf_ser_kv:
    push rax
    push rdi
    push rsi
    call serial_puts                ; consumes rdi
    pop  rsi
    pop  rdi
    push rdi
    push rsi
    mov  rdi, rsi
    call fbperf_ser_hex64
    call serial_crlf
    pop  rsi
    pop  rdi
    pop  rax
    ret

; ---------------------------------------------------------------------------
; fbperf_flip_full_begin  -- called from display_flip top
; fbperf_flip_full_end    -- called from display_flip bottom
;   rax = bytes copied (passed at end)
; fbperf_flip_rect_*      -- same idea for display_flip_rect
;
; Begin stores TSC into fbperf_tsc_at_begin (no other side effects).
; End computes delta, updates min/max/sum/last, increments flip counters.
; All caller-saved regs preserved across both halves.
; ---------------------------------------------------------------------------
fbperf_flip_full_begin:
    push rax
    push rdx
    rdtsc
    shl  rdx, 32
    or   rax, rdx
    mov  [fbperf_tsc_at_begin], rax
    pop  rdx
    pop  rax
    ret

fbperf_flip_full_end:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi

    rdtsc
    shl  rdx, 32
    or   rax, rdx
    mov  rcx, [fbperf_tsc_at_begin]
    sub  rax, rcx                  ; rax = delta TSC
    mov  [fbperf_tsc_last], rax

    inc  qword [fbperf_flips_total]
    inc  qword [fbperf_full_flips]

    add  [fbperf_tsc_total], rax

    ; min
    mov  rbx, [fbperf_tsc_min]
    test rbx, rbx
    jnz  .have_min
    mov  rbx, -1
.have_min:
    cmp  rax, rbx
    jae  .skip_min
    mov  [fbperf_tsc_min], rax
.skip_min:
    ; max
    mov  rbx, [fbperf_tsc_max]
    cmp  rax, rbx
    jbe  .skip_max
    mov  [fbperf_tsc_max], rax
.skip_max:

    ; Bytes copied: scr_pitch * scr_height
    mov  eax, [scr_pitch]
    mov  esi, [scr_height]
    imul rax, rsi
    add  [fbperf_bytes_total], rax
    add  [fbperf_full_bytes],  rax

    pop  rsi
    pop  rdx
    pop  rcx
    pop  rbx
    pop  rax
    ret

fbperf_flip_rect_begin:
    push rax
    push rdx
    rdtsc
    shl  rdx, 32
    or   rax, rdx
    mov  [fbperf_tsc_at_begin], rax
    mov  dword [fbperf_rect_last_w], 0
    mov  dword [fbperf_rect_last_h], 0
    pop  rdx
    pop  rax
    ret

; Called by display_flip_rect once clipping passed.
; edi = clipped width, esi = clipped height.
global fbperf_flip_rect_note_size
fbperf_flip_rect_note_size:
    mov  [fbperf_rect_last_w], edi
    mov  [fbperf_rect_last_h], esi
    ret

; r8d = clipped width, r9d = clipped height
fbperf_flip_rect_end:
    push rax
    push rbx
    push rcx
    push rdx

    rdtsc
    shl  rdx, 32
    or   rax, rdx
    mov  rbx, [fbperf_tsc_at_begin]
    sub  rax, rbx
    mov  [fbperf_tsc_last], rax

    inc  qword [fbperf_flips_total]
    inc  qword [fbperf_rect_flips]
    add  [fbperf_tsc_total], rax

    mov  rbx, [fbperf_tsc_min]
    test rbx, rbx
    jnz  .have_min
    mov  rbx, -1
.have_min:
    cmp  rax, rbx
    jae  .skip_min
    mov  [fbperf_tsc_min], rax
.skip_min:
    mov  rbx, [fbperf_tsc_max]
    cmp  rax, rbx
    jbe  .skip_max
    mov  [fbperf_tsc_max], rax
.skip_max:

    mov  eax, [fbperf_rect_last_w]
    imul eax, [fbperf_rect_last_h]
    shl  rax, 2
    add  [fbperf_bytes_total], rax
    add  [fbperf_rect_bytes],  rax

    pop  rdx
    pop  rcx
    pop  rbx
    pop  rax
    ret

fbperf_note_dirty_count:
    ; rdi = dirty rect count this flush
    add  [fbperf_dirty_rect_sum], rdi
    ret
