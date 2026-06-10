; ============================================================================
; Data Section
; ============================================================================
section .data

; AMD FCH I2C base addresses - the four real DesignWare blocks from the DSDT.
; Touchpad lives on I2CD (FEDC5000), so probe it first; the rest are fallbacks
; for other boards. FEDC6000/FEDC0000 were removed - they do not exist on HW
; and probing absent MMIO reads garbage. Keep I2C_AMD_BASE_COUNT in sync.
i2c_amd_bases:
    dq I2C_BASE_D               ; 0xFEDC5000 - I2CD <- touchpad (SYNA1B92 @ 0x2C)
    dq I2C_BASE_C               ; 0xFEDC4000 - I2CC
    dq I2C_BASE_B               ; 0xFEDC3000 - I2CB
    dq I2C_BASE_A               ; 0xFEDC2000 - I2CA
I2C_AMD_BASE_COUNT  equ (($ - i2c_amd_bases) / 8)

; Touchpad I2C addresses to probe (most-common first)
i2c_tp_addrs:
    db 0x2C             ; Synaptics SYNA1B92 (THIS laptop - DSDT-confirmed) / ALPS
    db 0x15             ; ELAN primary (Acer Nitro / AMD Ryzen)
    db 0x17             ; ELAN variant (Nitro V16 AI / Strix Point)
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

; TSC-spin deadline + per-report latency stamp
i2c_spin_tsc_deadline: dq 0    ; TSC deadline for the in-spin busy-wait
i2c_last_report_tsc:   dq 0    ; TSC at which the previous report was processed

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
