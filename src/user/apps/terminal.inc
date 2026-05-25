global app_terminal_blob_start
global app_terminal_blob_end
app_terminal_blob_start:
app_terminal_draw:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15

    ; Pump one async ping per frame if a `ping <ip>` is in flight. This lets
    ; each reply line appear live and keeps typing responsive between the
    ; 200ms blocking echo cycles instead of freezing all four at once.
    call app_terminal_key.term_ping_pump

    mov rbx, rdi
    mov r12, [rbx + WIN_OFF_X]
    mov r13, [rbx + WIN_OFF_Y]
    mov r14, [rbx + WIN_OFF_W]
    mov r15, [rbx + WIN_OFF_H]

    ; Background (sc_gui_rect: rdi=x, rsi=y, rdx=w, r10=h, r8=color)
    mov rdi, r12
    add rdi, BORDER_WIDTH
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT
    mov rdx, r14
    sub rdx, BORDER_WIDTH * 2
    mov rcx, r15
    sub rcx, TITLEBAR_HEIGHT + BORDER_WIDTH
    cmp rcx, 0
    jle .term_draw_done
    mov r10, rcx
    mov r8, 0x00111111
    mov rax, 2
    syscall

    ; Header (sc_gui_text: rdi=x, rsi=y, rdx=str, r10=color)
    mov rdi, r12
    add rdi, BORDER_WIDTH + 6
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 4
    lea rdx, [rel term_blob_welcome]
    mov r10, 0x0000DD00
    mov rax, 3
    syscall

    ; History lines, or help hint when empty
    mov ecx, [rel term_blob_hist_count]
    test ecx, ecx
    jnz .term_draw_hist
    mov rdi, r12
    add rdi, BORDER_WIDTH + 6
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 20
    lea rdx, [rel term_blob_help_hint]
    mov r10, 0x00CCCCCC
    mov rax, 3
    syscall
    jmp .term_after_hist
.term_draw_hist:
    xor r14d, r14d                   ; line index
.term_hist_loop:
    cmp r14d, [rel term_blob_hist_count]
    jge .term_after_hist
    mov rdi, r12
    add rdi, BORDER_WIDTH + 6
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT + 20
    mov eax, r14d
    imul eax, 14
    add esi, eax
    mov eax, r14d
    imul eax, TERM_HIST_LINE
    lea rdx, [rel term_blob_hist_buf]
    add rdx, rax
    mov r10, 0x00CCCCCC
    mov rax, 3
    syscall
    inc r14d
    jmp .term_hist_loop
.term_after_hist:

    ; Prompt y = below history (or default 28 below header if empty)
    mov eax, [rel term_blob_hist_count]
    test eax, eax
    jnz .term_prompt_y_have
    mov eax, 1                       ; reserve one line for help-hint
.term_prompt_y_have:
    imul eax, 14
    add eax, 24                       ; 20 (hist_y0) + 4 padding
    ; Keep prompt-y in RBP rather than R15: the kernel syscall handler
    ; deliberately overwrites R15D with the active slot index
    ; (syscall.asm:276), so any value parked in R15 is destroyed by the
    ; very first gui_text syscall and the input row ends up at the wrong y.
    mov ebp, eax

    ; Suppress the prompt + input + cursor while a ping is in flight. The
    ; user already saw their command echoed into history, and locking input
    ; here prevents typing from looking like it lands on the wrong line.
    cmp dword [rel term_blob_ping_pending], 0
    jne .term_skip_prompt

    ; Prompt "C:\> "
    mov rdi, r12
    add rdi, BORDER_WIDTH + 6
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT
    add esi, ebp
    lea rdx, [rel term_blob_prompt]
    mov r10, 0x0000FF00
    mov rax, 3
    syscall

    ; Input text
    mov rdi, r12
    add rdi, BORDER_WIDTH + 6 + 40
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT
    add esi, ebp
    lea rdx, [rel term_blob_input_buf]
    mov r10, 0x00FFFFFF
    mov rax, 3
    syscall

    ; Cursor
    mov eax, [rel term_blob_cursor_val]
    imul eax, FONT_WIDTH
    add eax, BORDER_WIDTH + 6 + 40
    mov rdi, r12
    add edi, eax
    mov rsi, r13
    add rsi, TITLEBAR_HEIGHT
    add esi, ebp
    lea rdx, [rel term_blob_cursor]
    mov r10, 0x00FFFFFF
    mov rax, 3
    syscall
.term_skip_prompt:

.term_draw_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret

app_terminal_kernel_draw:
    jmp app_terminal_draw

app_terminal_click:
    ret

; Key handler: RDI=window_ptr, ESI=key_event [pressed:8|mods:8|ascii:8|scan:8]
app_terminal_key:
    push rbx
    push rcx
    push rdx

    ; Extract ASCII + mods. Layout: [pressed:8 | mods:8 | ascii:8 | scan:8]
    mov edx, esi
    shr edx, 16
    and edx, 0xFF                    ; edx = mods byte (KMOD_*)

    mov eax, esi
    shr eax, 8
    and eax, 0xFF
    test eax, eax
    jz .term_key_done

    ; While a ping is in flight, the only key we honor is Ctrl+C (abort).
    ; All other input is dropped so the user can't blindly type into a
    ; locked prompt — matches the Windows ping UX.
    cmp dword [rel term_blob_ping_pending], 0
    je .term_key_normal
    test dl, KMOD_CTRL
    jz .term_key_done
    cmp al, 'c'
    je .term_ping_abort
    cmp al, 'C'
    je .term_ping_abort
    cmp al, 3                        ; raw ^C ascii
    je .term_ping_abort
    jmp .term_key_done
.term_ping_abort:
    mov dword [rel term_blob_ping_pending], 0
    lea rsi, [rel term_blob_ping_aborted]
    call .term_push_hist
    jmp .term_key_done

.term_key_normal:
    ; Enter
    cmp al, 13
    je .term_enter
    ; Backspace
    cmp al, 8
    je .term_backspace

    ; Normal printable char
    cmp al, 32
    jl .term_key_done
    cmp al, 126
    jg .term_key_done

    mov ecx, [rel term_blob_cursor_val]
    cmp ecx, TERM_INPUT_MAX
    jge .term_key_done
    lea rbx, [rel term_blob_input_buf]
    mov [rbx + rcx], al
    inc ecx
    mov byte [rbx + rcx], 0
    mov [rel term_blob_cursor_val], ecx
    jmp .term_key_done

.term_backspace:
    mov ecx, [rel term_blob_cursor_val]
    test ecx, ecx
    jz .term_key_done
    dec ecx
    lea rbx, [rel term_blob_input_buf]
    mov byte [rbx + rcx], 0
    mov [rel term_blob_cursor_val], ecx
    jmp .term_key_done

.term_enter:
    ; Ignore Enter on an empty input — feels right for an interactive shell.
    cmp byte [rel term_blob_input_buf], 0
    je .term_key_done

    ; Echo the typed command to history *immediately* so the user sees their
    ; submission confirmed even when the command launches a long-running task
    ; (e.g. ping). Builds "C:\> <input>" in line_tmp and pushes it.
    lea rdi, [rel term_blob_line_tmp]
    lea rsi, [rel term_blob_prompt]
    call .term_copy_str
    lea rsi, [rel term_blob_input_buf]
    call .term_append_str
    lea rsi, [rel term_blob_line_tmp]
    call .term_push_hist

    lea rbx, [rel term_blob_input_buf]
    lea rsi, [rel term_blob_cmd_cls]
    mov rdi, rbx
    call .term_str_eq
    test al, al
    jnz .term_cls
    lea rsi, [rel term_blob_cmd_ver]
    lea rdi, [rel term_blob_input_buf]
    call .term_str_eq
    test al, al
    jnz .term_ver
    lea rsi, [rel term_blob_cmd_help]
    lea rdi, [rel term_blob_input_buf]
    call .term_str_eq
    test al, al
    jnz .term_help
    ; Built-in `ping <ip>` runs 4 echo requests in the terminal itself via
    ; SYS_NET_PING4. This shares the kernel ping engine with the Networking
    ; app (which also calls SYS_NET_PING4), so both surfaces stay consistent.
    lea rdi, [rel term_blob_input_buf]
    lea rsi, [rel term_blob_cmd_ping]
    call .term_starts_with_space
    test al, al
    jz .term_no_ping_builtin
    add rdi, 5                       ; skip "ping "
    call .term_do_ping
    jmp .term_clear_input
.term_no_ping_builtin:

    ; Accept an optional "open " prefix so `open ping 8.8.8.8` works the same
    ; as a bare `ping 8.8.8.8`. kernel_open_app_command parses "<app> <params>".
    lea rdi, [rel term_blob_input_buf]
    lea rsi, [rel term_blob_cmd_open]
    call .term_starts_with_space
    test al, al
    jz .term_no_open_prefix
    add rdi, 5                       ; skip "open "
.term_no_open_prefix:
    mov rax, 23
    syscall
    mov r8, rax                       ; preserve result across line build
    cmp r8, -1
    je .term_open_failed
    ; Success: "  launched window N"
    lea rdi, [rel term_blob_line_tmp]
    lea rsi, [rel term_blob_launch_ok]
    call .term_copy_str
    mov rax, r8
    call .term_append_uint
    lea rsi, [rel term_blob_line_tmp]
    call .term_push_hist
    jmp .term_clear_input
.term_open_failed:
    lea rsi, [rel term_blob_launch_err]
    call .term_push_hist
    jmp .term_clear_input

.term_cls:
    mov dword [rel term_blob_hist_count], 0
    jmp .term_clear_input

.term_ver:
    lea rsi, [rel term_blob_welcome]
    call .term_push_hist
    jmp .term_clear_input

.term_help:
    lea rsi, [rel term_blob_help_hint]
    call .term_push_hist
    jmp .term_clear_input

; Push string at RSI as a new history line. Shifts older lines up if full.
.term_push_hist:
    push rax
    push rcx
    push rdx
    push rdi
    push rsi
    push r8
    push r9

    mov ecx, [rel term_blob_hist_count]
    cmp ecx, TERM_HIST_MAX
    jl .term_ph_have_slot
    ; Full: shift entries [1..N-1] -> [0..N-2]
    push rsi
    lea rdi, [rel term_blob_hist_buf]
    lea rsi, [rdi + TERM_HIST_LINE]
    mov rcx, (TERM_HIST_MAX - 1) * TERM_HIST_LINE
    cld
    rep movsb
    pop rsi
    mov ecx, TERM_HIST_MAX - 1
.term_ph_have_slot:
    mov eax, ecx
    imul eax, TERM_HIST_LINE
    lea rdi, [rel term_blob_hist_buf]
    add rdi, rax
    xor edx, edx
.term_ph_copy:
    cmp edx, TERM_HIST_LINE - 1
    jge .term_ph_end
    mov al, [rsi]
    test al, al
    jz .term_ph_end
    mov [rdi], al
    inc rdi
    inc rsi
    inc edx
    jmp .term_ph_copy
.term_ph_end:
    mov byte [rdi], 0
    mov eax, [rel term_blob_hist_count]
    cmp eax, TERM_HIST_MAX
    jge .term_ph_done
    inc eax
    mov [rel term_blob_hist_count], eax
.term_ph_done:
    pop r9
    pop r8
    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rax
    ret

.term_copy_str:
.copy_loop:
    lodsb
    stosb
    test al, al
    jnz .copy_loop
    dec rdi
    ret

.term_append_str:
.append_loop:
    lodsb
    stosb
    test al, al
    jnz .append_loop
    ret

.term_str_eq:
.cmp_loop:
    mov al, [rdi]
    mov dl, [rsi]
    cmp al, dl
    jne .cmp_no
    test al, al
    jz .cmp_yes
    inc rdi
    inc rsi
    jmp .cmp_loop
.cmp_no:
    xor eax, eax
    ret
.cmp_yes:
    mov al, 1
    ret

; --------------------------------------------------------------------------
; Ping builtin: RDI = pointer to first byte of the IP literal (after "ping ").
; Echoes a Windows-style "Pinging A.B.C.D with 32 bytes of data:" header,
; then 4 reply lines (or "Request timed out."). Uses SYS_NET_PING4 (56) for
; the actual echo and SYS_NET_INFO selector 8 for the last reply's TTL.
; --------------------------------------------------------------------------
; .term_do_ping — RDI = pointer past "ping " in input_buf. Synchronously
; pushes the "Pinging A.B.C.D with 32 bytes of data:" header, captures the
; parsed IP + literal, sets pending=4. The actual echo loop runs one cycle
; per frame inside .term_ping_pump so each line appears live and the input
; row keeps redrawing between attempts.
.term_do_ping:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15

    mov r15, rdi                     ; r15 = literal start (IP or hostname)

    ; Refuse to start a new ping while one is still draining.
    cmp dword [rel term_blob_ping_pending], 0
    jne .tdp_already

    ; Try IPv4 literal first; on success r12d holds (A<<24)|(B<<16)|(C<<8)|D
    ; and we mark the host string empty so the header omits the "[ip]" bit.
    call .term_parse_ipv4
    test al, al
    jz .tdp_try_dns
    mov byte [rel term_blob_ping_host], 0
    jmp .tdp_format_ip

.tdp_try_dns:
    ; Snapshot hostname (stop at space/CR/LF/NUL) so DNS gets a clean C-string
    ; and the header can echo back what the user typed.
    lea rdi, [rel term_blob_ping_host]
    mov rsi, r15
    mov ecx, 63                      ; cap to host buffer size - 1
.tdp_host_copy:
    test ecx, ecx
    jz .tdp_host_copy_done
    mov al, [rsi]
    test al, al
    jz .tdp_host_copy_done
    cmp al, ' '
    je .tdp_host_copy_done
    cmp al, 0x0A
    je .tdp_host_copy_done
    cmp al, 0x0D
    je .tdp_host_copy_done
    mov [rdi], al
    inc rdi
    inc rsi
    dec ecx
    jmp .tdp_host_copy
.tdp_host_copy_done:
    mov byte [rdi], 0
    cmp byte [rel term_blob_ping_host], 0
    je .tdp_bad

    ; Synchronous DNS resolve. SYS_NET_DNS_A returns the IP A.B.C.D-packed
    ; (A in high byte) which is the same layout as parse_ipv4 produces, so we
    ; can store the result directly into r12d.
    lea rdi, [rel term_blob_ping_host]
    mov rax, 61
    syscall
    test rax, rax
    jle .tdp_dns_fail
    mov r12d, eax

.tdp_format_ip:
    ; Render r12d as dotted-decimal into term_blob_ping_ip_buf so every reply
    ; line can echo it. Byte 3 = A, byte 0 = D.
    lea rdi, [rel term_blob_ping_ip_buf]
    mov eax, r12d
    shr eax, 24
    and eax, 0xFF
    call .term_app_uint
    mov byte [rdi], '.'
    inc rdi
    mov eax, r12d
    shr eax, 16
    and eax, 0xFF
    call .term_app_uint
    mov byte [rdi], '.'
    inc rdi
    mov eax, r12d
    shr eax, 8
    and eax, 0xFF
    call .term_app_uint
    mov byte [rdi], '.'
    inc rdi
    mov eax, r12d
    and eax, 0xFF
    call .term_app_uint
    mov byte [rdi], 0

    ; Build the header. With a hostname it matches the Windows form:
    ;   "Pinging google.com [142.250.129.101] with 32 bytes of data:"
    ; For a bare IP we keep the original:
    ;   "Pinging 8.8.8.8 with 32 bytes of data:"
    lea rdi, [rel term_blob_line_tmp]
    lea rsi, [rel term_blob_ping_hdr_pre]
    call .term_app_cstr
    cmp byte [rel term_blob_ping_host], 0
    je .tdp_hdr_ip_only
    lea rsi, [rel term_blob_ping_host]
    call .term_app_cstr
    lea rsi, [rel term_blob_ping_hdr_brk]
    call .term_app_cstr
    lea rsi, [rel term_blob_ping_ip_buf]
    call .term_app_cstr
    lea rsi, [rel term_blob_ping_hdr_brkend]
    call .term_app_cstr
    jmp .tdp_hdr_tail
.tdp_hdr_ip_only:
    lea rsi, [rel term_blob_ping_ip_buf]
    call .term_app_cstr
.tdp_hdr_tail:
    lea rsi, [rel term_blob_ping_hdr_end]
    call .term_app_cstr
    lea rsi, [rel term_blob_line_tmp]
    call .term_push_hist

    ; Arm the per-frame pump. Setting next_tick to 0 means the first attempt
    ; fires on the very next draw frame; subsequent attempts wait ~1s each.
    mov [rel term_blob_ping_target], r12d
    mov dword [rel term_blob_ping_pending], 4
    mov qword [rel term_blob_ping_next_tick], 0
    jmp .tdp_done

.tdp_bad:
    lea rsi, [rel term_blob_ping_bad_ip]
    call .term_push_hist
    jmp .tdp_done

.tdp_dns_fail:
    lea rsi, [rel term_blob_ping_dns_fail]
    call .term_push_hist
    jmp .tdp_done

.tdp_already:
    lea rsi, [rel term_blob_ping_busy]
    call .term_push_hist

.tdp_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

; .term_ping_pump — called at the start of every draw frame. Drives the
; async SYS_NET_PING4_TICK state machine so a ping never freezes the WM.
; When the tick syscall returns >0/-1 we push the reply or timeout line and
; schedule the next echo ~1s later. While the kernel state machine is mid-
; flight the syscall returns 0 immediately and we keep redrawing frames.
.term_ping_pump:
    cmp dword [rel term_blob_ping_pending], 0
    je .tpp_done
    push rax
    mov rax, 18
    syscall
    cmp rax, [rel term_blob_ping_next_tick]
    pop rax
    jb .tpp_done

    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r12
    push r13
    push r14

    mov r12d, [rel term_blob_ping_target]
    mov edi, r12d
    mov rax, 62                       ; SYS_NET_PING4_TICK
    syscall
    mov r14, rax

    ; 0 = state machine still in flight. -2 = a different target's ping is
    ; in flight (shouldn't happen here, but retry next frame). Either way
    ; bail out without consuming the pending counter — the WM redraws and
    ; we resume next frame.
    cmp r14, 0
    je .tpp_yield
    cmp r14, -2
    je .tpp_yield

    cmp r14, 0
    jl .tpp_timeout

    mov rdi, 8
    mov rax, 57
    syscall
    mov rbx, rax                     ; ttl

    lea rdi, [rel term_blob_line_tmp]
    lea rsi, [rel term_blob_ping_reply_pre]
    call .term_app_cstr
    lea rsi, [rel term_blob_ping_ip_buf]
    call .term_app_cstr
    lea rsi, [rel term_blob_ping_reply_mid]
    call .term_app_cstr
    mov rax, r14
    add rax, 500
    xor rdx, rdx
    mov rcx, 1000
    div rcx
    call .term_app_uint
    lea rsi, [rel term_blob_ping_reply_ttl]
    call .term_app_cstr
    mov rax, rbx
    call .term_app_uint
    lea rsi, [rel term_blob_line_tmp]
    call .term_push_hist
    jmp .tpp_advance

.tpp_timeout:
    lea rsi, [rel term_blob_ping_timeout]
    call .term_push_hist

.tpp_advance:
    dec dword [rel term_blob_ping_pending]
    push rax
    mov rax, 18
    syscall
    add rax, 100                      ; ~1s gap before the next echo
    mov [rel term_blob_ping_next_tick], rax
    pop rax

.tpp_yield:
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
.tpp_done:
    ret

; RDI=cstring. AL=1 on success, R12D=packed (A<<24)|(B<<16)|(C<<8)|D.
; Preserves RDI (caller's IP-string pointer).
.term_parse_ipv4:
    push rbx
    push rcx
    push rdx
    push rdi
    xor r12d, r12d
    mov ecx, 4
.tpip_part:
    xor edx, edx                     ; current octet
    xor ebx, ebx                     ; digit count
.tpip_dig:
    mov al, [rdi]
    cmp al, '0'
    jb .tpip_part_end
    cmp al, '9'
    ja .tpip_part_end
    sub al, '0'
    imul edx, edx, 10
    movzx eax, al
    add edx, eax
    cmp edx, 255
    ja .tpip_fail
    inc rdi
    inc ebx
    jmp .tpip_dig
.tpip_part_end:
    test ebx, ebx
    jz .tpip_fail
    shl r12d, 8
    or  r12d, edx
    dec ecx
    jz .tpip_ok
    mov al, [rdi]
    cmp al, '.'
    jne .tpip_fail
    inc rdi
    jmp .tpip_part
.tpip_ok:
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    mov al, 1
    ret
.tpip_fail:
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    xor al, al
    ret

; RDI=dest at NUL. RSI=src cstring. Copies bytes (excluding src NUL), writes
; NUL at end, returns RDI=new NUL position.
.term_app_cstr:
.tac_loop:
    lodsb
    test al, al
    jz .tac_done
    stosb
    jmp .tac_loop
.tac_done:
    mov byte [rdi], 0
    ret

; RDI=dest at NUL. RAX=uint64. Writes decimal digits + NUL, returns RDI=new NUL.
.term_app_uint:
    push rbx
    push rcx
    push rdx
    mov rbx, rdi
    mov rcx, 10
    test rax, rax
    jnz .tau2_loop
    mov byte [rdi], '0'
    inc rdi
    jmp .tau2_emit_done
.tau2_loop:
    xor rdx, rdx
    div rcx
    add dl, '0'
    mov [rdi], dl
    inc rdi
    test rax, rax
    jnz .tau2_loop
.tau2_emit_done:
    mov byte [rdi], 0
    lea rdx, [rdi - 1]
.tau2_rev:
    cmp rbx, rdx
    jge .tau2_done
    mov al, [rbx]
    mov cl, [rdx]
    mov [rbx], cl
    mov [rdx], al
    inc rbx
    dec rdx
    jmp .tau2_rev
.tau2_done:
    pop rdx
    pop rcx
    pop rbx
    ret

; RDI=dest (at NUL), RAX=uint64. Appends decimal digits + NUL. Preserves RAX.
.term_append_uint:
    push rax
    push rbx
    push rcx
    push rdx
    push rdi
    mov rbx, rdi
    mov rcx, 10
    xor r9d, r9d                     ; digit count
    test rax, rax
    jnz .tau_loop
    mov byte [rdi], '0'
    inc rdi
    inc r9d
    jmp .tau_emit_done
.tau_loop:
    xor rdx, rdx
    div rcx
    add dl, '0'
    mov [rdi], dl
    inc rdi
    inc r9d
    test rax, rax
    jnz .tau_loop
.tau_emit_done:
    mov byte [rdi], 0
    ; reverse [rbx .. rdi-1]
    lea rdx, [rdi - 1]
.tau_rev:
    cmp rbx, rdx
    jge .tau_rev_done
    mov al, [rbx]
    mov cl, [rdx]
    mov [rbx], cl
    mov [rdx], al
    inc rbx
    dec rdx
    jmp .tau_rev
.tau_rev_done:
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; RDI=input cstring, RSI=prefix cstring. Returns AL=1 if input starts with
; prefix (byte-equal, case-sensitive). Preserves RDI/RSI.
.term_starts_with_space:
    push rdi
    push rsi
    push rdx
.tsws_loop:
    mov dl, [rsi]
    test dl, dl
    jz .tsws_match
    mov al, [rdi]
    cmp al, dl
    jne .tsws_no
    inc rdi
    inc rsi
    jmp .tsws_loop
.tsws_match:
    pop rdx
    pop rsi
    pop rdi
    mov al, 1
    ret
.tsws_no:
    pop rdx
    pop rsi
    pop rdi
    xor eax, eax
    ret

.term_clear_input:
    mov byte [rel term_blob_input_buf], 0
    mov dword [rel term_blob_cursor_val], 0

.term_key_done:
    pop rdx
    pop rcx
    pop rbx
    ret

app_terminal_kernel_key:
    jmp app_terminal_key

term_blob_welcome:
    db "NexusOS Terminal v3.0", 0
term_blob_help_hint:
    db "Type 'help', 'ver', or 'cls'", 0
term_blob_prompt:
    db "C:\> ", 0
term_blob_cursor:
    db "_", 0
term_blob_cmd_help:
    db "help", 0
term_blob_cmd_ver:
    db "ver", 0
term_blob_cmd_cls:
    db "cls", 0
term_blob_cmd_open:
    db "open ", 0
term_blob_launch_ok:
    db "  launched window ", 0
term_blob_launch_err:
    db "  error: unknown app", 0
term_blob_cmd_ping:
    db "ping ", 0
term_blob_ping_hdr_pre:
    db "Pinging ", 0
term_blob_ping_hdr_brk:
    db " [", 0
term_blob_ping_hdr_brkend:
    db "]", 0
term_blob_ping_hdr_end:
    db " with 32 bytes of data:", 0
term_blob_ping_dns_fail:
    db "  error: DNS lookup failed", 0
term_blob_ping_reply_pre:
    db "Reply from ", 0
term_blob_ping_reply_mid:
    db ": bytes=32 time=", 0
term_blob_ping_reply_ttl:
    db "ms TTL=", 0
term_blob_ping_timeout:
    db "Request timed out.", 0
term_blob_ping_bad_ip:
    db "  error: invalid IPv4 address", 0
term_blob_ping_no_link:
    db "  error: no network (DHCP not bound)", 0
term_blob_ping_busy:
    db "  error: ping already in flight", 0
term_blob_ping_aborted:
    db "^C", 0

; Per-slot mutable state (lives inside the blob image so each L3 slot gets its
; own copy after l3_copy_app_blob_to_slot). Zero-initialised at boot.
TERM_HIST_MAX  equ 8
TERM_HIST_LINE equ 64
align 8
term_blob_cursor_val: dd 0
term_blob_hist_count: dd 2
term_blob_input_buf:  times 64  db 0
term_blob_line_tmp:   times TERM_HIST_LINE db 0
term_blob_ping_ip_buf: times 20 db 0
term_blob_ping_host:   times 64 db 0
align 4
term_blob_ping_pending: dd 0
term_blob_ping_target:  dd 0
align 8
term_blob_ping_next_tick: dq 0
term_blob_hist_buf:
    db "NexusOS Terminal v3.0", 0
    times TERM_HIST_LINE - 22 db 0
    db "Type 'help', 'ver', or 'cls'", 0
    times TERM_HIST_LINE - 29 db 0
    times (TERM_HIST_MAX - 2) * TERM_HIST_LINE db 0

app_terminal_blob_end:

; Helper: add echo buffer pointer to history
term_add_history_echo:
    push rax
    push rcx
    push rdx
    mov eax, [rel term_hist_count]
    cmp eax, TERM_MAX_HIST
    jge .echo_scroll

    lea rcx, [rel term_hist_ptrs]
    lea rdx, [rel term_echo_buf]
    mov [rcx + rax * 8], rdx
    inc dword [rel term_hist_count]
    jmp .echo_done

.echo_scroll:
    lea rcx, [term_hist_ptrs]
    mov eax, 0
.echo_shift:
    cmp eax, TERM_MAX_HIST - 1
    jge .echo_shift_done
    mov rdx, [rcx + rax * 8 + 8]
    mov [rcx + rax * 8], rdx
    inc eax
    jmp .echo_shift
.echo_shift_done:
    lea rdx, [rel term_echo_buf]
    mov [rcx + (TERM_MAX_HIST - 1) * 8], rdx
.echo_done:
    pop rdx
    pop rcx
    pop rax
    ret

; Internal helper: string compare (case insensitive)
; RSI = input, RDI = cmd string
; Returns EAX=1 if match, 0 if not
term_strcmp:
    push rsi
    push rdi
.tcmp_loop:
    mov al, [rsi]
    mov bl, [rdi]
    
    ; Lowercase AL
    cmp al, 'A'
    jl .al_lower
    cmp al, 'Z'
    jg .al_lower
    add al, 32
.al_lower:

    ; Lowercase BL (should be already, but safe)
    cmp bl, 'A'
    jl .bl_lower
    cmp bl, 'Z'
    jg .bl_lower
    add bl, 32
.bl_lower:

    cmp al, bl
    jne .tcmp_fail
    test bl, bl
    jz .tcmp_match
    inc rsi
    inc rdi
    jmp .tcmp_loop
.tcmp_fail:
    pop rdi
    pop rsi
    xor eax, eax
    ret
.tcmp_match:
    pop rdi
    pop rsi
    mov eax, 1
    ret

; Helper: starts with
term_starts_with:
    push rsi
    push rdi
.tsw_loop:
    mov bl, [rdi]
    test bl, bl
    jz .tsw_match
    mov al, [rsi]
    or al, 0x20
    cmp al, bl
    jne .tsw_fail
    inc rsi
    inc rdi
    jmp .tsw_loop
.tsw_fail:
    pop rdi
    pop rsi
    xor eax, eax
    ret
.tsw_match:
    pop rdi
    pop rsi
    mov eax, 1
    ret

; ============================================================================
; NOTEPAD APP
; Multi-line text editor with arrow navigation, Enter, File/Edit menus
; Buffer layout: NP_MAX_LINES lines, each NP_MAX_COLS bytes
; np_line_len[i] = length of line i
; ============================================================================

