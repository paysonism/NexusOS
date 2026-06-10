; ============================================================================
; i2c_hid_get_descriptor - Read HID descriptor from device
; RSI = I2C base, EDI = device address
; Returns: EAX = 1 if valid HID descriptor, 0 otherwise
; ============================================================================
i2c_hid_get_descriptor:
    push rcx
    push rbx
    push rdi
    push r10
    push r11

    ; The I2C-HID descriptor register is vendor-specific and is normally read
    ; from ACPI (_DSM). This machine's touchpad (Synaptics SYNA1B92) uses
    ; register 0x0020; ELAN parts use 0x0001. Try each candidate until one
    ; returns a structurally valid HID descriptor.
    xor r11d, r11d                  ; candidate index
.desc_try_reg:
    cmp r11d, I2C_DESC_REG_COUNT
    jge .fail
    movzx r10d, word [i2c_desc_reg_cands + r11 * 2]

    ; Clear any pending state / stale abort from a previous candidate
    mov eax, [rsi + DW_IC_CLR_INTR]
    mov eax, [rsi + DW_IC_CLR_TX_ABRT]
    call i2c_flush_rx

    ; Write HID descriptor register address (LE: low byte, then high byte)
    ; No STOP - use RESTART on first read for atomic write+read transaction
    mov eax, r10d
    and eax, 0xFF
    call i2c_write_byte
    mov eax, r10d
    shr eax, 8
    and eax, 0xFF
    call i2c_write_byte

    ; Wait for TX done
    call i2c_wait_tx_empty
    jc .desc_next_reg

    ; Small delay for device to prepare
    mov ecx, 50000
.dly: dec ecx
    jnz .dly

    ; Issue 30 read commands (HID descriptor is 30 bytes)
    mov eax, IC_CMD_READ | IC_CMD_RESTART
    mov [rsi + DW_IC_DATA_CMD], eax
    mov ecx, 28
.queue_reads:
    mov eax, IC_CMD_READ
    mov [rsi + DW_IC_DATA_CMD], eax
    dec ecx
    jnz .queue_reads
    mov eax, IC_CMD_READ | IC_CMD_STOP
    mov [rsi + DW_IC_DATA_CMD], eax

    ; Wait for 30 bytes
    mov ecx, 30
    call i2c_wait_rx_avail
    jc .desc_next_reg

    ; Read 30 bytes into i2c_desc_buf
    lea rdi, [i2c_desc_buf]
    mov ecx, 30
.read_desc:
    mov eax, [rsi + DW_IC_DATA_CMD]
    mov [rdi], al
    inc rdi
    dec ecx
    jnz .read_desc

    ; Parse HID descriptor
    ; [0:1]  wHIDDescLength
    ; [2:3]  bcdVersion
    ; [4:5]  wReportDescLength
    ; [6:7]  wReportDescRegister
    ; [8:9]  wInputRegister
    ; [10:11] wMaxInputLength
    ; [12:13] wOutputRegister
    ; [14:15] wMaxOutputLength
    ; [16:17] wCommandRegister
    ; [18:19] wDataRegister
    ; [20:21] wVendorID
    ; [22:23] wProductID
    ; [24:25] wVersionID
    lea rbx, [i2c_desc_buf]

    ; Validate wHIDDescLength
    movzx ecx, word [rbx]
    cmp ecx, 4
    jl .desc_next_reg
    cmp ecx, 64
    jg .desc_next_reg
    mov [i2c_hid_desc_len], cx
    mov [i2c_hid_desc_reg], r10w   ; remember which register worked

    ; Extract wReportDescLength [4:5]
    movzx eax, word [rbx + 4]
    mov [i2c_report_desc_len], ax

    ; Extract wReportDescRegister [6:7]
    movzx eax, word [rbx + 6]
    mov [i2c_report_desc_reg], ax

    ; Extract wInputRegister [8:9]
    movzx eax, word [rbx + 8]
    test eax, eax
    jz .keep_input_default
    mov [i2c_hid_input_reg], ax
.keep_input_default:

    ; Extract wMaxInputLength [10:11]
    movzx eax, word [rbx + 10]
    test eax, eax
    jz .keep_maxinput_default
    cmp eax, 256
    jg .keep_maxinput_default
    mov [i2c_max_input_len], ax
.keep_maxinput_default:

    ; Extract wCommandRegister [16:17]
    movzx eax, word [rbx + 16]
    test eax, eax
    jz .keep_cmd_default
    mov [i2c_hid_cmd_reg], ax
.keep_cmd_default:

    ; Extract wDataRegister [18:19]
    movzx eax, word [rbx + 18]
    test eax, eax
    jz .keep_data_default
    mov [i2c_hid_data_reg], ax
.keep_data_default:

    mov eax, 1
    jmp .desc_ret

.desc_next_reg:
    inc r11d
    jmp .desc_try_reg

.fail:
    xor eax, eax
.desc_ret:
    pop r11
    pop r10
    pop rdi
    pop rbx
    pop rcx
    ret

; ============================================================================
; i2c_hid_read_report_desc - Read and parse HID report descriptor
; Must be called after i2c_hid_get_descriptor (which populates register/length)
; ============================================================================
i2c_hid_read_report_desc:
    push rcx
    push rdx
    push rdi
    push rbx

    movzx ecx, word [i2c_report_desc_len]
    test ecx, ecx
    jz .rdesc_done
    cmp ecx, I2C_RDESC_BUF_SIZE
    jg .rdesc_done              ; Too large for our buffer

    mov [i2c_rdesc_read_len], cx

    ; Clear RX FIFO
    call i2c_flush_rx

    ; Write report descriptor register address (2 bytes)
    ; No STOP - RESTART on first read for atomic write+read transaction
    movzx eax, word [i2c_report_desc_reg]
    push rax
    and al, 0xFF                ; Low byte
    call i2c_write_byte
    pop rax
    shr eax, 8
    call i2c_write_byte

    call i2c_wait_tx_empty
    jc .rdesc_done

    ; Delay
    mov ecx, 100000
.rdesc_dly: dec ecx
    jnz .rdesc_dly

    ; Read the report descriptor in FIFO-safe chunks. The DW I2C TX/RX FIFOs
    ; are only ~32 deep; queueing all 600+ read commands at once (as the old
    ; code did) overflows them and silently truncates the descriptor. Issue up
    ; to 16 reads, drain them, repeat. The controller holds SCL between chunks.
    movzx r8d, word [i2c_rdesc_read_len]   ; total bytes to read
    lea rdi, [i2c_rdesc_buf]
    xor ebx, ebx                ; bytes read so far
    mov r11d, 1                 ; first-read flag (needs RESTART)

.rdesc_chunk:
    cmp ebx, r8d
    jge .rdesc_read_done
    ; chunk = min(16, total - read)
    mov ecx, r8d
    sub ecx, ebx
    cmp ecx, 16
    jbe .rdesc_chunk_sz
    mov ecx, 16
.rdesc_chunk_sz:
    mov r9d, ecx                ; r9d = this chunk's count
    mov edx, ebx                ; edx = absolute byte index being queued
.rdesc_q:
    mov eax, IC_CMD_READ
    test r11d, r11d
    jz .rdesc_q_nofirst
    or eax, IC_CMD_RESTART
    xor r11d, r11d
.rdesc_q_nofirst:
    lea r10d, [edx + 1]
    cmp r10d, r8d               ; STOP on the final byte of the descriptor
    jne .rdesc_q_nostop
    or eax, IC_CMD_STOP
.rdesc_q_nostop:
    mov [rsi + DW_IC_DATA_CMD], eax
    inc edx
    dec ecx
    jnz .rdesc_q

    ; wait for the chunk to arrive, then drain it
    mov ecx, r9d
    call i2c_wait_rx_avail
    jc .rdesc_read_done
    mov ecx, r9d
.rdesc_d:
    mov eax, [rsi + DW_IC_DATA_CMD]
    mov [rdi + rbx], al
    inc ebx
    dec ecx
    jnz .rdesc_d
    jmp .rdesc_chunk

.rdesc_read_done:
    ; Parse the report descriptor
    push rsi
    lea rsi, [i2c_rdesc_buf]
    mov ecx, ebx               ; actual bytes read
    call hid_parse_report_desc
    pop rsi
    ; EAX = 1 if parsed successfully

    ; If parsing succeeded, we know the report layout
    test eax, eax
    jz .rdesc_done
    mov byte [i2c_use_parsed], 1

.rdesc_done:
    pop rbx
    pop rdi
    pop rdx
    pop rcx
    ret

; ============================================================================
; i2c_hid_reset - Send HID reset command
; ============================================================================
i2c_hid_reset:
    push rcx

    ; Write to wCommandRegister: reset command
    ; Format: [cmd_reg_low, cmd_reg_high, 0x00, 0x01]
    movzx eax, word [i2c_hid_cmd_reg]
    call i2c_write_byte
    movzx eax, word [i2c_hid_cmd_reg]
    shr eax, 8
    call i2c_write_byte
    mov al, 0x00                ; reportType=0, reportID=0
    call i2c_write_byte
    mov al, 0x01                ; opcode = RESET (0x01)
    call i2c_write_byte_stop

    call i2c_wait_tx_empty

    ; Wait for reset to complete (~60ms busy-loop)
    mov ecx, 6000000
.rst_wait:
    dec ecx
    jnz .rst_wait

    ; Consume the reset-response report. After RESET the device signals
    ; completion by presenting a report at the Input Register; it will NOT
    ; produce further input reports until that response has been read out.
    ; A bare RX-FIFO flush is not enough - we must run a real I2C read
    ; transaction against wInputRegister.
    mov eax, [rsi + DW_IC_CLR_TX_ABRT]
    call i2c_flush_rx

    movzx eax, word [i2c_hid_input_reg]
    call i2c_write_byte
    movzx eax, word [i2c_hid_input_reg]
    shr eax, 8
    call i2c_write_byte
    mov eax, IC_CMD_READ | IC_CMD_RESTART
    mov [rsi + DW_IC_DATA_CMD], eax
    mov eax, IC_CMD_READ | IC_CMD_STOP
    mov [rsi + DW_IC_DATA_CMD], eax

    mov ecx, 2
    call i2c_wait_rx_avail      ; CF=1 on timeout - harmless, just drain
    call i2c_flush_rx

    pop rcx
    ret

; ============================================================================
; i2c_hid_set_power_on - Send SET_POWER(ON) command
; ============================================================================
i2c_hid_set_power_on:
    ; Write to commandReg: opcode=SET_POWER(8), powerState=ON(0)
    movzx eax, word [i2c_hid_cmd_reg]
    call i2c_write_byte
    movzx eax, word [i2c_hid_cmd_reg]
    shr eax, 8
    call i2c_write_byte
    mov al, 0x00                ; powerState = ON
    call i2c_write_byte
    mov al, 0x08                ; SET_POWER opcode
    call i2c_write_byte_stop

    call i2c_wait_tx_empty
    ret

; ============================================================================
; i2c_hid_bus_reset - Emergency bus reset on repeated errors
; Disables and re-enables the I2C controller
; ============================================================================
i2c_hid_bus_reset:
    push rcx

    ; Disable controller
    mov dword [rsi + DW_IC_ENABLE], 0
    mov ecx, 10000
.dis_wait:
    dec ecx
    jnz .dis_wait

    ; Clear all interrupt/abort state
    mov eax, [rsi + DW_IC_CLR_INTR]
    mov eax, [rsi + DW_IC_CLR_TX_ABRT]

    ; Re-enable
    mov dword [rsi + DW_IC_ENABLE], 1
    mov ecx, 10000
.en_wait:
    dec ecx
    jnz .en_wait

    ; Reset poll state
    mov byte [i2c_poll_state], 0
    mov dword [i2c_error_count], 0

    ; Re-initialize the HID device: the I2C bus reset killed the device's
    ; session state.  Without SET_POWER + RESET the touchpad stays confused
    ; and the next reads time out, causing cascading errors for several seconds.
    call i2c_hid_set_power_on
    call i2c_hid_reset

    pop rcx
    ret
