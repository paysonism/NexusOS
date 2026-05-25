; ============================================================================
; NexusOS v3.0 - I2C HID Touchpad Driver (Complete)
;
; Supports:
;   - AMD FCH DesignWare I2C (fixed MMIO: FEDC2000-FEDC5000)
;   - Intel LPSS I2C (PCI BAR0, DesignWare compatible)
;   - Full HID report descriptor parsing (via hid_parser.asm)
;   - Absolute and relative touchpad modes
;   - Variable-length report reading
;   - Multi-touch contact tracking
;   - Gesture detection: tap-to-click, two-finger scroll
;   - Non-blocking state machine polling
;   - Error recovery with bus reset and re-init
;
; AMD FCH I2C controllers at FEDCX000 (X = 2,3,4,5 for I2C0-3)
; Intel LPSS I2C: PCI class 0x0C80, BAR0 = DesignWare I2C MMIO
; ============================================================================
bits 64

%include "constants.inc"
extern debug_print
extern pci_read_conf_dword

extern mouse_x, mouse_y, mouse_buttons, mouse_moved
extern mouse_scroll_y
extern scr_width, scr_height
extern tick_count

; HID parser
extern hid_parse_report_desc
extern hid_process_touchpad_report
extern hid_parsed_report_id, hid_parsed_has_report_id
extern hid_parsed_is_absolute, hid_parsed_report_bytes
extern hid_parsed_is_touchpad

; --- AMD DesignWare I2C register offsets ---
DW_IC_CON           equ 0x00    ; Control
DW_IC_TAR           equ 0x04    ; Target address
DW_IC_DATA_CMD      equ 0x10    ; Data / Command register
DW_IC_SS_SCL_HCNT   equ 0x14    ; Standard speed SCL high count
DW_IC_SS_SCL_LCNT   equ 0x18    ; Standard speed SCL low count
DW_IC_FS_SCL_HCNT   equ 0x1C    ; Fast speed SCL high count
DW_IC_FS_SCL_LCNT   equ 0x20    ; Fast speed SCL low count
DW_IC_INTR_STAT     equ 0x2C    ; Interrupt status
DW_IC_INTR_MASK     equ 0x30    ; Interrupt mask
DW_IC_RAW_INTR_STAT equ 0x34    ; Raw interrupt status
DW_IC_RX_TL         equ 0x38    ; RX FIFO threshold
DW_IC_TX_TL         equ 0x3C    ; TX FIFO threshold
DW_IC_CLR_INTR      equ 0x40    ; Clear interrupts
DW_IC_CLR_TX_ABRT   equ 0x54    ; Clear TX abort
DW_IC_ENABLE        equ 0x6C    ; Enable
DW_IC_STATUS        equ 0x70    ; Status
DW_IC_TXFLR         equ 0x74    ; TX FIFO level
DW_IC_RXFLR         equ 0x78    ; RX FIFO level
DW_IC_SDA_HOLD      equ 0x7C    ; SDA hold time
DW_IC_TX_ABRT_SRC   equ 0x80    ; TX abort source
DW_IC_ENABLE_STATUS equ 0x9C    ; Enable status
DW_IC_COMP_PARAM_1  equ 0xF4    ; Component parameters

; DW_IC_CON bits
IC_CON_MASTER_MODE  equ (1 << 0)
IC_CON_SPEED_STD    equ (1 << 1)  ; Standard (100kHz)
IC_CON_SPEED_FAST   equ (2 << 1)  ; Fast (400kHz)
IC_CON_10BIT_ADDR   equ (1 << 3)
IC_CON_RESTART_EN   equ (1 << 5)
IC_CON_SLAVE_DISABLE equ (1 << 6)

; DW_IC_STATUS bits
IC_STATUS_ACTIVITY  equ (1 << 0)
IC_STATUS_TFNF      equ (1 << 1)  ; TX FIFO not full
IC_STATUS_TFE       equ (1 << 2)  ; TX FIFO empty
IC_STATUS_RFNE      equ (1 << 3)  ; RX FIFO not empty

; DW_IC_DATA_CMD bits
IC_CMD_READ         equ (1 << 8)
IC_CMD_STOP         equ (1 << 9)
IC_CMD_RESTART      equ (1 << 10)

; Known AMD FCH I2C base addresses
I2C_BASE_0  equ 0xFEDC2000
I2C_BASE_1  equ 0xFEDC3000
I2C_BASE_2  equ 0xFEDC5000   ; was 0xFEDC4000 (nonexistent); real HW has 0xFEDC5000
I2C_BASE_3  equ 0xFEDC6000   ; was 0xFEDC5000; real HW also has 0xFEDC6000
I2C_BASE_4  equ 0xFEDC0000   ; additional block seen on Strix Point

; Touchpad HID addresses to probe
TP_ADDR_ELAN        equ 0x15
TP_ADDR_SYNAPTICS   equ 0x2C

section .text

global i2c_hid_init
global i2c_hid_poll

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
    cmp r13d, 5
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

    pop rcx
    ret

; ============================================================================
; i2c_hid_poll - Non-blocking touchpad poll (called from main loop)
;
; State machine (2 states - the input report is read in ONE I2C
; transaction, as the I2C-HID spec requires):
;   State 0: Address wInputRegister + queue the full report read burst
;            (RESTART..STOP), arm a deadline -> state=1
;   State 1: Wait until the whole burst is in the RX FIFO, then drain
;            and process it. On deadline timeout, recover -> state=0
; ============================================================================
i2c_hid_poll:
    cmp byte [i2c_hid_active], 1
    jne .poll_ret_noframe

    push rbx                    ; rbx is callee-saved; clobbered by xor ebx,ebx below

    cmp byte [i2c_poll_busy], 0
    jne .poll_ret_busy
    mov byte [i2c_poll_busy], 1

    mov rsi, [i2c_base_addr]
    inc dword [i2c_dbg_polls]           ; DEBUG: count poll entries

    ; Check for TX abort (non-blocking)
    mov eax, [rsi + DW_IC_RAW_INTR_STAT]
    test eax, (1 << 6)
    jz .no_abort
    inc dword [i2c_dbg_aborts]          ; DEBUG: count aborts
    mov eax, [rsi + DW_IC_TX_ABRT_SRC]  ; DEBUG: why did it abort?
    mov [i2c_dbg_abrt_src], eax
    mov eax, [rsi + DW_IC_CLR_TX_ABRT]
    inc dword [i2c_error_count]
    cmp dword [i2c_error_count], 50
    jge .do_bus_reset
    mov byte [i2c_poll_state], 0
    mov byte [i2c_poll_busy], 0
    pop rbx
    ret
.no_abort:

    movzx eax, byte [i2c_poll_state]
    cmp eax, 1
    je .state1

    ; === STATE 0: issue a single-transaction input-report read ===
    ; The I2C-HID spec requires the 2-byte length header AND the report
    ; payload to be read in ONE transaction (one START..STOP). Splitting
    ; it - read header, STOP, then a second read - makes the device treat
    ; the report as consumed; the second read returns an empty 0-length
    ; report. So queue the whole burst up front.
.state0:
    ; Drain any stale RX data
    mov eax, [rsi + DW_IC_RXFLR]
    test eax, eax
    jz .state0_no_drain
    call i2c_flush_rx
.state0_no_drain:
    ; Clear any stale abort
    mov eax, [rsi + DW_IC_CLR_TX_ABRT]

    ; Bytes to read = wMaxInputLength, clamped to our HID parser buffer. Do
    ; not clamp to RX FIFO depth: real touchpad reports often exceed 16 bytes.
    ; State 1 drains RX progressively while queueing more read commands.
    movzx ecx, word [i2c_max_input_len]
    cmp ecx, 8
    jae .ric_have
    mov ecx, 16                 ; missing/bogus descriptor value
.ric_have:
    cmp ecx, MOUSE_BUFFER_SIZE
    jbe .ric_min
    mov ecx, MOUSE_BUFFER_SIZE
.ric_min:
    cmp ecx, 8
    jae .ric_ok
    mov ecx, 8
.ric_ok:
    mov [i2c_read_count], cx

    ; Address the Input Register (2-byte LE write, no STOP -> RESTART read)
    movzx eax, word [i2c_hid_input_reg]
    call i2c_write_byte
    movzx eax, word [i2c_hid_input_reg]
    shr eax, 8
    call i2c_write_byte
    call i2c_wait_tx_empty
    jc .state0_recover

    mov word [i2c_read_queued], 0
    mov word [i2c_read_index], 0

    ; Deadline: if the burst has not fully arrived within ~10 PIT ticks
    ; (~100ms) the transaction aborted - recover instead of stalling.
    mov eax, [tick_count]
    add eax, 10
    mov [i2c_poll_deadline], eax

    mov byte [i2c_poll_state], 1
    jmp .state1

    ; Address phase failed before any read burst was armed.
.state0_recover:
    inc dword [i2c_error_count]
    mov eax, [rsi + DW_IC_CLR_TX_ABRT]
    call i2c_flush_rx
    mov byte [i2c_poll_state], 0
    mov byte [i2c_poll_busy], 0
    pop rbx
    ret

    ; === STATE 1: wait for the burst, then process it ===
.state1:
    ; Drain any bytes already delivered. RXFLR never exceeds the hardware FIFO
    ; depth, so waiting for RXFLR == whole report breaks on real touchpads.
.state1_drain:
    mov eax, [rsi + DW_IC_RXFLR]
    test eax, eax
    jz .state1_queue
    movzx ebx, word [i2c_read_index]
    movzx ecx, word [i2c_read_count]
    cmp ebx, ecx
    jae .state1_queue
    mov eax, [rsi + DW_IC_DATA_CMD]
    mov [i2c_report_buf + rbx], al
    inc ebx
    mov [i2c_read_index], bx
    jmp .state1_drain

.state1_queue:
    ; Queue more read commands while the TX FIFO has space.
    movzx ebx, word [i2c_read_queued]
    movzx ecx, word [i2c_read_count]
    cmp ebx, ecx
    jae .state1_check_done
    mov eax, [rsi + DW_IC_TXFLR]
    movzx edx, byte [i2c_tx_fifo_depth]
    test edx, edx
    jnz .tx_depth_ok
    mov edx, 16
.tx_depth_ok:
    cmp eax, edx
    jae .state1_check_done

    mov eax, IC_CMD_READ
    test ebx, ebx
    jnz .not_first_read
    or eax, IC_CMD_RESTART
.not_first_read:
    mov edx, ebx
    inc edx
    cmp dx, [i2c_read_count]
    jne .not_last_read
    or eax, IC_CMD_STOP
.not_last_read:
    mov [rsi + DW_IC_DATA_CMD], eax
    inc ebx
    mov [i2c_read_queued], bx
    jmp .state1_drain

.state1_check_done:
    movzx eax, word [i2c_read_index]
    movzx ecx, word [i2c_read_count]
    cmp eax, ecx
    jge .state1_ready

    ; Burst not fully in yet - check the deadline
    mov eax, [tick_count]
    cmp eax, [i2c_poll_deadline]
    jb .poll_ret                ; still within deadline, keep waiting
    ; Timed out - the transaction aborted. Recover for the next frame.
    inc dword [i2c_error_count]
    mov eax, [rsi + DW_IC_CLR_TX_ABRT]
    call i2c_flush_rx
    mov byte [i2c_poll_state], 0
    mov byte [i2c_poll_busy], 0
    pop rbx
    ret

.state1_ready:
    mov byte [i2c_poll_state], 0
    mov dword [i2c_error_count], 0  ; Reset error count on success

    ; --- DEBUG: capture raw report (count, length, first 8 bytes) ---
    inc dword [i2c_dbg_rpts]
    movzx eax, word [i2c_report_buf]
    mov [i2c_dbg_len], ax
    lea rdi, [i2c_report_buf]
    lea rax, [i2c_dbg_bytes]
    mov ecx, 8
.dbg_cap:
    mov dl, [rdi]
    mov [rax], dl
    inc rdi
    inc rax
    dec ecx
    jnz .dbg_cap
    ; --- end debug ---

    ; Parse the report. Bytes [0:1] are the length header. The real
    ; report may be longer than our 32-byte burst, so clamp the data
    ; length to what we actually read.
    lea rdi, [i2c_report_buf]
    movzx ecx, word [rdi]       ; packet length from header
    movzx eax, word [i2c_read_count]
    cmp ecx, eax
    jbe .len_in_range
    mov ecx, eax
.len_in_range:
    sub ecx, 2                   ; data length after header
    cmp ecx, 1
    jl .poll_ret                 ; No useful data (idle / empty report)
    add rdi, 2                   ; skip length header

    ; Check if we have parsed report descriptor
    cmp byte [i2c_use_parsed], 1
    je .use_parsed_report

    ; === Fallback: legacy 6-byte fixed-format report ===
    ; [ReportID] [Buttons] [Xlow] [Xhi] [Ylow] [Yhi]
    movzx eax, byte [rdi]       ; Report ID
    inc rdi
    dec ecx

    movzx eax, byte [rdi]       ; Buttons
    and al, 0x07
    mov [mouse_buttons], al

    ; X delta (16-bit signed LE)
    movzx eax, byte [rdi + 1]
    movzx ebx, byte [rdi + 2]
    shl ebx, 8
    or eax, ebx
    movsx eax, ax
    sar eax, 1                   ; sensitivity scaling
    add [mouse_x], eax

    ; Y delta (16-bit signed LE)
    movzx eax, byte [rdi + 3]
    movzx ebx, byte [rdi + 4]
    shl ebx, 8
    or eax, ebx
    movsx eax, ax
    sar eax, 1
    add [mouse_y], eax

    ; Scroll wheel byte (byte 5, 8-bit signed, optional)
    cmp ecx, 6
    jl .no_legacy_scroll
    movsx eax, byte [rdi + 5]
    test eax, eax
    jz .no_legacy_scroll
    mov [mouse_scroll_y], eax
.no_legacy_scroll:

    ; Clamp
    jmp .poll_clamp

.use_parsed_report:
    ; Skip report ID byte if present
    push rcx
    cmp byte [hid_parsed_has_report_id], 1
    jne .no_skip_id
    mov al, [rdi]
    cmp al, [hid_parsed_report_id]
    jne .parsed_report_id_mismatch
    inc rdi
    dec ecx
.no_skip_id:

    ; Use parsed layout to process report
    mov rsi, rdi                 ; report data pointer
    ; ECX = data length
    call hid_process_touchpad_report
    pop rcx
    mov byte [mouse_moved], 1   ; mark moved so cursor updates
    jmp .poll_ret

.parsed_report_id_mismatch:
    pop rcx
    jmp .poll_ret

.poll_clamp:
    ; Clamp coordinates
    cmp dword [mouse_x], 0
    jge .cx_ok
    mov dword [mouse_x], 0
.cx_ok:
    mov eax, [scr_width]
    dec eax
    cmp [mouse_x], eax
    jle .cx_max_ok
    mov [mouse_x], eax
.cx_max_ok:
    cmp dword [mouse_y], 0
    jge .cy_ok
    mov dword [mouse_y], 0
.cy_ok:
    mov eax, [scr_height]
    dec eax
    cmp [mouse_y], eax
    jle .cy_max_ok
    mov [mouse_y], eax
.cy_max_ok:
    mov byte [mouse_moved], 1

.poll_ret:
    mov byte [i2c_poll_busy], 0
    pop rbx
.poll_ret_noframe:
    ret

.poll_ret_busy:
    pop rbx
    ret

.do_bus_reset:
    call i2c_hid_bus_reset
    mov byte [i2c_poll_busy], 0
    pop rbx
    ret

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

; ============================================================================
; Data Section
; ============================================================================
section .data

; AMD FCH I2C base addresses - all blocks seen on Strix Point real hardware
; Order: higher indices first (I2CD = instance 3 likely at 0xFEDC5000 or 0xFEDC6000)
i2c_amd_bases:
    dq I2C_BASE_2               ; 0xFEDC5000 - most likely I2CD on Strix Point
    dq I2C_BASE_3               ; 0xFEDC6000 - fallback I2CD candidate
    dq I2C_BASE_1               ; 0xFEDC3000 - I2CB
    dq I2C_BASE_0               ; 0xFEDC2000 - I2CA
    dq I2C_BASE_4               ; 0xFEDC0000 - additional FCH block

; Touchpad I2C addresses to probe (most-common first)
i2c_tp_addrs:
    db 0x15             ; ELAN primary (Acer Nitro / AMD Ryzen)
    db 0x17             ; ELAN variant (Nitro V16 AI / Strix Point)
    db 0x2C             ; Synaptics / ALPS
    db 0x38             ; ELAN variant
    db 0x10             ; ELAN alt
    db 0x14             ; Goodix
    db 0x5D             ; Goodix alternate
    db 0x2A             ; Synaptics secondary
    db 0x3C             ; ALPS I2C-HID
    db 0x20             ; Pixart
    db 0x34             ; FocalTech
    db 0x16             ; ELAN variant 2
    db 0x2D             ; Synaptics variant
I2C_TP_ADDR_COUNT   equ ($ - i2c_tp_addrs)

; I2C-HID descriptor register candidates. The register that holds the HID
; descriptor is vendor-specific (ACPI _DSM provides it on a real OS).
; 0x0020 = Synaptics (this laptop's SYNA1B92), 0x0001 = ELAN and most others.
i2c_desc_reg_cands:
    dw 0x0020
    dw 0x0001
I2C_DESC_REG_COUNT  equ (($ - i2c_desc_reg_cands) / 2)

; I2C-HID state
global i2c_hid_active
i2c_hid_active:     db 0
i2c_dev_addr:       db 0
i2c_poll_state:     db 0        ; 0=issue read burst, 1=wait+process burst
i2c_is_intel:       db 0        ; 1 if controller found via PCI (Intel LPSS)
i2c_use_parsed:     db 0        ; 1 if HID report descriptor was parsed successfully
i2c_base_addr:      dq 0
i2c_hid_desc_len:   dw 0
i2c_hid_desc_reg:   dw 0x0020      ; HID descriptor register that worked
i2c_error_count:    dd 0        ; consecutive error counter for bus reset
i2c_read_count:     dw 0        ; bytes to read in the current input-report burst
i2c_read_queued:    dw 0        ; read commands queued for the current burst
i2c_read_index:     dw 0        ; bytes drained into i2c_report_buf
i2c_poll_deadline:  dd 0        ; tick_count deadline for the current burst
i2c_poll_busy:      db 0        ; prevents IRQ/main-loop reentry
i2c_tx_fifo_depth:  db 16       ; decoded from DW_IC_COMP_PARAM_1 when available
i2c_rx_fifo_depth:  db 16       ; decoded from DW_IC_COMP_PARAM_1 when available

; DEBUG: raw touchpad report capture
i2c_dbg_rpts:       dd 0        ; count of input reports processed
i2c_dbg_len:        dw 0        ; length of last report
i2c_dbg_bytes:      times 8 db 0 ; first 8 bytes of last report
i2c_dbg_polls:      dd 0        ; poll entries
i2c_dbg_aborts:     dd 0        ; TX aborts seen by poll
i2c_dbg_abrt_src:   dd 0        ; last DW_IC_TX_ABRT_SRC value
i2c_dbg_init_code:  db 0        ; init/probe progress: 0x80=active, 0xE*=probe fail

; I2C-HID register addresses (from HID descriptor, with defaults)
i2c_hid_cmd_reg:    dw 0x0005
i2c_hid_input_reg:  dw 0x0003
i2c_hid_data_reg:   dw 0x0007
i2c_max_input_len:  dw 64       ; wMaxInputLength from descriptor

; Report descriptor info
i2c_report_desc_len:    dw 0    ; wReportDescLength
i2c_report_desc_reg:    dw 0    ; wReportDescRegister
i2c_rdesc_read_len:     dw 0    ; actual bytes to read

; Buffers
i2c_desc_buf:       times 32 db 0   ; Raw HID descriptor (30 bytes)
i2c_report_buf:     times 256 db 0  ; Input report buffer (variable length)

I2C_RDESC_BUF_SIZE  equ 1024
i2c_rdesc_buf:      times I2C_RDESC_BUF_SIZE db 0  ; Report descriptor buffer

; Strings
szI2cScan       db "I2C: Scanning AMD+Intel...", 0
szI2cProbing    db "I2C: Probing Controller...", 0
szI2cIntel      db "I2C: Scanning Intel LPSS PCI...", 0
szI2cIntelFound db "I2C: Intel LPSS Found!", 0
szI2cSuccess    db "I2C: Touchpad Found!", 0
szI2cFail       db "I2C: Not Found.", 0
