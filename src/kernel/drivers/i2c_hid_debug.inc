; ============================================================================
; i2c_hid_debug_dump - Dump I2C state to buffer
; RDI = buffer pointer
; i2c_hid_debug_dump_line:
; RDI = buffer pointer, EAX = line index (0..2)
; ============================================================================
global i2c_hid_debug_dump
i2c_hid_debug_dump:
    xor eax, eax
    jmp i2c_hid_debug_dump_line

global i2c_hid_debug_dump_line
i2c_hid_debug_dump_line:
    mov r10d, eax
    push rdi
    push rsi
    push rax
    push rbx
    push rcx
    push rdx

    mov rbx, rdi

    lea rsi, [.hdr]
    call .copystr

    test r10d, r10d
    jz .line0
    cmp r10d, 1
    je .line1
    jmp .line2

.line0:
    lea rsi, [.s_init]
    call .copystr
    movzx eax, byte [i2c_dbg_init_code]
    call .writehex8
    lea rsi, [.s_active_short]
    call .copystr
    movzx eax, byte [i2c_hid_active]
    call .writehex8
    lea rsi, [.s_base_short]
    call .copystr
    mov rax, [i2c_base_addr]
    call .writehex32
    mov byte [rbx], '/'
    inc rbx
    movzx eax, byte [i2c_dev_addr]
    call .writehex8

    ; Parsed?
    cmp byte [i2c_use_parsed], 1
    jne .line0_done
    lea rsi, [.s_parsed]
    call .copystr
    cmp byte [hid_parsed_is_absolute], 1
    jne .line0_rel
    lea rsi, [.s_abs]
    call .copystr
    jmp .line0_done
.line0_rel:
    lea rsi, [.s_rel]
    call .copystr
.line0_done:
    jmp .done

.line1:
    lea rsi, [.s_report]
    call .copystr

    ; Report count
    lea rsi, [.s_rp]
    call .copystr
    mov eax, [i2c_dbg_rpts]
    call .writehex32

    ; Last report length
    lea rsi, [.s_ln]
    call .copystr
    movzx eax, word [i2c_dbg_len]
    call .writehex8

    ; First 8 raw report bytes
    lea rsi, [.s_by]
    call .copystr
    push r12
    push r13
    lea r12, [i2c_dbg_bytes]
    xor r13d, r13d
.dump_byte:
    cmp r13d, 8
    jge .dump_byte_done
    movzx eax, byte [r12 + r13]
    call .writehex8
    inc r13d
    jmp .dump_byte
.dump_byte_done:
    pop r13
    pop r12
    jmp .done

.line2:
    lea rsi, [.s_poll]
    call .copystr
    ; Poll state
    lea rsi, [.s_pst]
    call .copystr
    movzx eax, byte [i2c_poll_state]
    call .writehex8

    ; Burst size and FIFO depths
    lea rsi, [.s_rc]
    call .copystr
    movzx eax, word [i2c_read_count]
    call .writehex8
    mov byte [rbx], '/'
    inc rbx
    movzx eax, byte [i2c_tx_fifo_depth]
    call .writehex8
    mov byte [rbx], '/'
    inc rbx
    movzx eax, byte [i2c_rx_fifo_depth]
    call .writehex8

    ; Error count
    lea rsi, [.s_err]
    call .copystr
    movzx eax, byte [i2c_error_count]
    call .writehex8

    ; Polls / aborts / last abort source
    lea rsi, [.s_pa]
    call .copystr
    mov eax, [i2c_dbg_polls]
    call .writehex32
    mov byte [rbx], '/'
    inc rbx
    mov eax, [i2c_dbg_aborts]
    call .writehex32
    mov byte [rbx], '/'
    inc rbx
    mov eax, [i2c_dbg_abrt_src]
    call .writehex32

    ; Descriptor register / input register / report-desc length
    lea rsi, [.s_dreg]
    call .copystr
    movzx eax, word [i2c_hid_desc_reg]
    call .writehex8
    lea rsi, [.s_ireg]
    call .copystr
    movzx eax, word [i2c_hid_input_reg]
    call .writehex8
    lea rsi, [.s_rdl]
    call .copystr
    movzx eax, word [i2c_report_desc_len]
    call .writehex32

.done:
    ; Null terminate
    mov byte [rbx], 0

    pop rdx
    pop rcx
    pop rbx
    pop rax
    pop rsi
    pop rdi
    ret

.copystr:
    lodsb
    test al, al
    jz .cs_done
    mov [rbx], al
    inc rbx
    jmp .copystr
.cs_done:
    ret

.writehex8:
    push rax
    shr al, 4
    call .nib
    pop rax
    push rax
    and al, 0x0F
    call .nib
    pop rax
    ret

.writehex32:
    push rax
    shr eax, 28
    and al, 0x0F
    call .nib
    pop rax
    push rax
    shr eax, 24
    and al, 0x0F
    call .nib
    pop rax
    push rax
    shr eax, 20
    and al, 0x0F
    call .nib
    pop rax
    push rax
    shr eax, 16
    and al, 0x0F
    call .nib
    pop rax
    push rax
    shr eax, 12
    and al, 0x0F
    call .nib
    pop rax
    push rax
    shr eax, 8
    and al, 0x0F
    call .nib
    pop rax
    push rax
    shr eax, 4
    and al, 0x0F
    call .nib
    pop rax
    push rax
    and al, 0x0F
    call .nib
    pop rax
    ret

.nib:
    cmp al, 10
    jb .nib_digit
    add al, 'A' - 10
    jmp .nib_out
.nib_digit:
    add al, '0'
.nib_out:
    mov [rbx], al
    inc rbx
    ret

.hdr        db "I2C", 0
.s_active   db " Active:", 0
.s_base     db " Base:", 0
.s_intel    db " [Intel]", 0
.s_parsed   db " Parsed:", 0
.s_abs      db "Abs", 0
.s_rel      db "Rel", 0
.s_err      db " Err:", 0
.s_dreg     db " dReg:", 0
.s_pst      db " St:", 0
.s_ireg     db " inReg:", 0
.s_rdl      db " rdLen:", 0
.s_rp       db " rp:", 0
.s_ln       db " ln:", 0
.s_by       db " b:", 0
.s_rc       db " rc:", 0
.s_pa       db " pa:", 0
.s_init     db " init:", 0
.s_active_short db " a:", 0
.s_base_short db " ba:", 0
.s_report   db " rep", 0
.s_poll     db " poll", 0
