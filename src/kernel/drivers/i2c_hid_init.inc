
; ============================================================================
; i2c_hid_init - Find and initialize I2C HID touchpad
; Probes AMD FCH fixed MMIO + Intel LPSS PCI controllers
; Returns: EAX = 1 if found, 0 if not found
; ============================================================================
i2c_hid_init:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15

    mov byte [i2c_hid_active], 0
    mov byte [i2c_poll_state], 0
    mov dword [i2c_error_count], 0
    mov byte [i2c_dbg_init_code], 0x10

    ; Serial: 'T' (touchpad init)
    mov dx, 0x3F8
    mov al, 'T'
    out dx, al

    mov rsi, szI2cScan
    call debug_print

    ; === Phase 1: Try AMD FCH fixed MMIO bases ===
    lea r12, [i2c_amd_bases]
    xor r13d, r13d              ; Controller index

.try_amd_controller:
    cmp r13d, I2C_AMD_BASE_COUNT
    jge .try_intel

    mov rsi, [r12 + r13 * 8]   ; Load base address
    test rsi, rsi
    jz .next_amd_ctrl

    ; Sanity check: DW_IC_COMP_PARAM_1 must be non-zero and not 0xFFFFFFFF
    mov eax, [rsi + DW_IC_COMP_PARAM_1]
    test eax, eax
    jz .next_amd_ctrl
    cmp eax, 0xFFFFFFFF
    je .next_amd_ctrl

    mov [i2c_base_addr], rsi
    mov byte [i2c_dbg_init_code], 0x20

    ; §8: declare this AMD FCH I2C register page as the MMIO_DRV_I2C capability.
    push rsi
    push rdi
    push rax
    push rcx
    push rdx
    mov rdi, rsi
    call mmio_register_i2c
    pop rdx
    pop rcx
    pop rax
    pop rdi
    pop rsi

    push rsi
    mov rsi, szI2cProbing
    call debug_print
    pop rsi

    ; Try each touchpad address on this controller
    call i2c_try_all_addresses
    test eax, eax
    jnz .found

.next_amd_ctrl:
    inc r13d
    jmp .try_amd_controller

    ; === Phase 2: Try Intel LPSS I2C via PCI ===
.try_intel:
    mov rsi, szI2cIntel
    call debug_print
    mov byte [i2c_dbg_init_code], 0x30

    ; Scan PCI for Intel LPSS I2C controllers
    ; Look for: vendor=0x8086, class code byte 0x0C (Serial Bus), subclass 0x80
    xor r13d, r13d              ; PCI bus
    xor r14d, r14d              ; PCI device
    xor r15d, r15d              ; PCI function

.pci_scan:
    ; Build PCI address: bus<<16 | dev<<11 | func<<8 | reg
    mov eax, r13d
    shl eax, 16
    mov ecx, r14d
    shl ecx, 11
    or eax, ecx
    mov ecx, r15d
    shl ecx, 8
    or eax, ecx
    ; Read vendor/device (reg 0x00)
    push rax
    call pci_read_conf_dword
    cmp eax, 0xFFFFFFFF
    jne .pci_check_vendor
    pop rax                     ; balance push before jumping
    jmp .pci_next
.pci_check_vendor:
    ; Check vendor = 0x8086 (Intel) or 0x1022 (AMD)
    cmp ax, 0x8086
    je .pci_check_class
    cmp ax, 0x1022
    jne .pci_next_pop
    ; AMD: skip class check - different Strix/Hawk Point I2C IDs use varied classes.
    ; Instead rely on BAR0 validity + DW I2C comp_param_1 signature below.
    jmp .pci_read_bar0

.pci_check_class:
    ; Read class code (reg 0x08)
    pop rax
    push rax
    or eax, 0x08                ; Register 0x08
    call pci_read_conf_dword
    ; Class code is in bits 31:8
    shr eax, 8
    ; Check class=0x0C (Serial Bus), subclass=0x80 (Other)
    ; EAX high 16 bits = class:subclass
    shr eax, 8
    cmp ax, 0x0C80
    jne .pci_next_pop

    ; Found Intel LPSS / AMD I2C controller!
.pci_read_bar0:
    ; Read BAR0 (reg 0x10)
    pop rax
    push rax
    or eax, 0x10
    call pci_read_conf_dword
    ; BAR0 is memory-mapped, mask off type bits
    and eax, 0xFFFFF000
    test eax, eax
    jz .pci_next_pop

    ; Verify it's a DesignWare I2C by reading IC_COMP_PARAM_1
    mov rsi, rax                ; RSI = I2C MMIO base (zero-extended ok for < 4GB)
    mov esi, eax                ; zero-extend to 64-bit via 32-bit write
    mov ecx, [rsi + DW_IC_COMP_PARAM_1]
    test ecx, ecx
    jz .pci_next_pop
    cmp ecx, 0xFFFFFFFF
    je .pci_next_pop

    mov [i2c_base_addr], rsi
    mov byte [i2c_is_intel], 1
    mov byte [i2c_dbg_init_code], 0x31

    ; §8: declare this Intel LPSS I2C BAR0 page as the MMIO_DRV_I2C capability.
    push rsi
    push rdi
    push rax
    push rcx
    push rdx
    mov rdi, rsi
    call mmio_register_i2c
    pop rdx
    pop rcx
    pop rax
    pop rdi
    pop rsi

    push rsi
    mov rsi, szI2cIntelFound
    call debug_print
    pop rsi

    ; Try touchpad addresses on this Intel I2C controller
    call i2c_try_all_addresses
    test eax, eax
    jnz .found_pop

.pci_next_pop:
    pop rax
.pci_next:
    ; Advance PCI scan
    inc r15d
    cmp r15d, 8
    jl .pci_scan
    xor r15d, r15d
    inc r14d
    cmp r14d, 32
    jl .pci_scan
    xor r14d, r14d
    inc r13d
    cmp r13d, 256
    jl .pci_scan

    ; Nothing found
    jmp .not_found

.found_pop:
    add rsp, 8                  ; pop saved rax
.found:
    mov byte [i2c_hid_active], 1
    mov byte [i2c_dbg_init_code], 0x80

    ; Serial: 'TK' (touchpad OK)
    mov dx, 0x3F8
    mov al, 'K'
    out dx, al

    mov rsi, szI2cSuccess
    call debug_print

    mov eax, 1
    jmp .ret

.not_found:
    cmp byte [i2c_dbg_init_code], 0xE0
    jae .not_found_keep_code
    mov byte [i2c_dbg_init_code], 0xF0
.not_found_keep_code:
    ; Serial: 'TF'
    mov dx, 0x3F8
    mov al, 'F'
    out dx, al

    mov rsi, szI2cFail
    call debug_print

    xor eax, eax

.ret:
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

; ============================================================================
; i2c_try_all_addresses - Try all known touchpad I2C addresses
; RSI = I2C controller base
; Returns: EAX = 1 if found, 0 if not
; ============================================================================
i2c_try_all_addresses:
    push rcx
    push rdi
    push r14

    lea r14, [i2c_tp_addrs]
    xor ecx, ecx

.try_addr:
    cmp ecx, I2C_TP_ADDR_COUNT
    jge .addr_fail

    movzx edi, byte [r14 + rcx]
    push rcx

    ; Initialize this I2C controller with target address
    call i2c_init_controller
    test eax, eax
    jnz .ctrl_ready
    mov byte [i2c_dbg_init_code], 0xE1
    jmp .next_addr
.ctrl_ready:
    mov byte [i2c_dbg_init_code], 0x41

    ; Try to read I2C-HID descriptor
    call i2c_hid_get_descriptor
    test eax, eax
    jnz .desc_ready
    mov byte [i2c_dbg_init_code], 0xE2
    jmp .next_addr
.desc_ready:
    mov byte [i2c_dbg_init_code], 0x42

    ; Found! Store device address and configure
    mov byte [i2c_dev_addr], dil

    ; Power the device ON first, then RESET (I2C-HID spec order).
    call i2c_hid_set_power_on

    ; Send reset command (also consumes the reset-response report)
    call i2c_hid_reset

    ; Read HID report descriptor (for smart parsing)
    call i2c_hid_read_report_desc

    pop rcx
    mov eax, 1
    jmp .addr_ret

.next_addr:
    pop rcx
    inc ecx
    jmp .try_addr

.addr_fail:
    xor eax, eax

.addr_ret:
    pop r14
    pop rdi
    pop rcx
    ret

; ============================================================================
; i2c_init_controller - Initialize DesignWare I2C controller
; RSI = controller base address, EDI = 7-bit device address
; Returns: EAX = 1 success, 0 fail
; ============================================================================
i2c_init_controller:
    push rcx

    ; §8: gate the init-path register window before the first [rsi+off] store.
    I2C_MMIO_ASSERT rsi, MMIO_I2C_WINDOW

    ; Disable controller first
    mov dword [rsi + DW_IC_ENABLE], 0

    ; Wait for disabled (activity bit clear)
    mov ecx, 5000
.wait_dis:
    mov eax, [rsi + DW_IC_ENABLE_STATUS]
    test eax, 1                 ; IC_EN bit
    jz .dis_ok
    dec ecx
    jnz .wait_dis
    xor eax, eax
    pop rcx
    ret
.dis_ok:

    ; Preserve firmware IC_CON speed/timing bits - UEFI already set correct
    ; values for this platform's I2C clock. Only enforce master mode flags.
    mov eax, [rsi + DW_IC_CON]
    or eax, IC_CON_MASTER_MODE | IC_CON_RESTART_EN | IC_CON_SLAVE_DISABLE
    mov [rsi + DW_IC_CON], eax

    ; Set target address
    mov [rsi + DW_IC_TAR], edi

    ; Do NOT overwrite SCL HCNT/LCNT/SDA_HOLD - firmware values are correct
    ; for this platform's FCH I2C clock (varies: 100/133/150MHz by platform)

    ; Mask all interrupts (we poll)
    mov dword [rsi + DW_IC_INTR_MASK], 0

    ; Set RX threshold to 0 (notify on any byte)
    mov dword [rsi + DW_IC_RX_TL], 0

    ; Cache FIFO depths. IC_COMP_PARAM_1 encodes depth as N-1; some cores
    ; leave the register unimplemented, so keep conservative 16-byte defaults.
    mov eax, [rsi + DW_IC_COMP_PARAM_1]
    test eax, eax
    jz .fifo_depths_done
    cmp eax, 0xFFFFFFFF
    je .fifo_depths_done
    mov ecx, eax
    shr ecx, 16
    and ecx, 0xFF
    jz .fifo_rx
    inc ecx
    cmp ecx, 64
    ja .fifo_rx
    mov [i2c_tx_fifo_depth], cl
.fifo_rx:
    mov ecx, eax
    shr ecx, 8
    and ecx, 0xFF
    jz .fifo_depths_done
    inc ecx
    cmp ecx, 64
    ja .fifo_depths_done
    mov [i2c_rx_fifo_depth], cl
.fifo_depths_done:

    ; Clear any pending interrupts/aborts
    mov eax, [rsi + DW_IC_CLR_INTR]
    mov eax, [rsi + DW_IC_CLR_TX_ABRT]

    ; Enable controller
    mov dword [rsi + DW_IC_ENABLE], 1

    ; Wait for enabled
    mov ecx, 5000
.wait_en:
    mov eax, [rsi + DW_IC_ENABLE_STATUS]
    test eax, 1
    jnz .en_ok
    dec ecx
    jnz .wait_en
    xor eax, eax
    pop rcx
    ret
.en_ok:

    mov eax, 1
    pop rcx
    ret

; ============================================================================
; i2c_write_byte / i2c_write_byte_stop - Write to I2C bus
; ============================================================================
i2c_write_byte:
    movzx eax, al
    mov [rsi + DW_IC_DATA_CMD], eax
    ret

i2c_write_byte_stop:
    movzx eax, al
    or eax, IC_CMD_STOP
    mov [rsi + DW_IC_DATA_CMD], eax
    ret

; ============================================================================
; i2c_wait_tx_empty - Wait for TX FIFO empty
; Returns CF=0 ok, CF=1 timeout
; ============================================================================
i2c_wait_tx_empty:
    push rcx
    mov ecx, 100000
.loop:
    mov eax, [rsi + DW_IC_STATUS]
    test eax, IC_STATUS_TFE
    jnz .ok
    ; Check for abort
    mov eax, [rsi + DW_IC_RAW_INTR_STAT]
    test eax, (1 << 6)         ; TX_ABRT
    jnz .abort
    dec ecx
    jnz .loop
    pop rcx
    stc
    ret
.abort:
    mov eax, [rsi + DW_IC_CLR_TX_ABRT]
    pop rcx
    stc
    ret
.ok:
    pop rcx
    clc
    ret

; ============================================================================
; i2c_wait_rx_avail - Wait for N bytes in RX FIFO
; ECX = count to wait for
; Returns CF=0 ok, CF=1 timeout
; ============================================================================
i2c_wait_rx_avail:
    push rcx
    push rdx
    mov edx, ecx               ; Save wanted count
    mov ecx, 100000
.loop:
    mov eax, [rsi + DW_IC_RXFLR]
    cmp eax, edx
    jge .ok
    ; Check abort
    mov eax, [rsi + DW_IC_RAW_INTR_STAT]
    test eax, (1 << 6)
    jnz .abort
    dec ecx
    jnz .loop
    pop rdx
    pop rcx
    stc
    ret
.abort:
    mov eax, [rsi + DW_IC_CLR_TX_ABRT]
    pop rdx
    pop rcx
    stc
    ret
.ok:
    pop rdx
    pop rcx
    clc
    ret

; ============================================================================
; i2c_flush_rx - Drain all bytes from RX FIFO
; ============================================================================
i2c_flush_rx:
    push rcx
    mov ecx, 256
.loop:
    mov eax, [rsi + DW_IC_RXFLR]
    test eax, eax
    jz .done
    mov eax, [rsi + DW_IC_DATA_CMD]
    dec ecx
    jnz .loop
.done:
    pop rcx
    ret
