; ============================================================================
; NexusOS v3.0 - System Constants
; ============================================================================

%include "boot_memory.inc"

; --- Memory Layout ---
; Cache32Max speed tiers:
; - L1-hot: IRQ/syscall/scheduler/input flags/per-core state.
; - L2-warm: HID parser, window metadata, font/text primitives, FAT metadata.
; - L3/LLC GUI: framebuffer composition buffers in 4MB..16MB.
; - RAM-cold: app arenas, device DMA rings, filesystem staging, debug data.
; Core physical addresses live in boot_memory.inc.
; IDT is 256*16 = 4KB. If stack grows down from 2MB, IDT at 2MB grows up?
; IDT structure is fixed size.
; If Stack Top is 0x200000, IDT at 0x200000 overlaps stack top!
; Stack grows DOWN. IDT grows UP (fixed size).
; If IDT is at 0x200000, it occupies 0x200000 to 0x201000.
; If Stack starts at 0x200000, a push writes to 0x1FFFF8.
; So they don't overlap. This is safe.

%ifdef NEXUS_CACHE32_MAX
CACHE32_RAM_LIMIT   equ 0x2000000    ; 32MB strict profile cap
SYSTEM_RESERVED_END equ 0x5600000    ; Allocator starts above wallpaper/drag caches
SMP_CORE_STATE_ADDR equ 0xC40000     ; Cacheline-aligned per-core records
SMP_CORE_STACK_BASE equ 0xC50000     ; AP stacks grow down from here
SMP_MAX_CORES       equ 8
SMP_CORE_STATE_SIZE equ 64
SMP_CORE_STACK_SIZE equ 0x4000
%else
SMP_CORE_STATE_ADDR equ 0xC40000
SMP_MAX_CORES       equ 1
SMP_CORE_STATE_SIZE equ 64
SYSTEM_RESERVED_END equ 0x5600000    ; Allocator starts above wallpaper/drag caches
%endif

; --- Stage 2 disk layout ---
STAGE2_SECTORS      equ 63           ; Sectors 1-63
KERNEL_START_SECTOR equ 64           ; Kernel starts at sector 64
KERNEL_SECTORS      equ 4096         ; 2MB max BIOS-loaded kernel
FAT16_PART_LBA      equ (KERNEL_START_SECTOR + KERNEL_SECTORS)

; --- Screen ---
SCREEN_WIDTH        equ 1024
SCREEN_HEIGHT       equ 768
SCREEN_BPP          equ 32
SCREEN_PITCH        equ (SCREEN_WIDTH * 4)   ; 4096 bytes per scanline
FRAMEBUFFER_SIZE    equ (SCREEN_WIDTH * SCREEN_HEIGHT * 4)  ; 3145728 = ~3MB


; VBE info offsets live in boot_memory.inc.

; --- Colors (32-bit 0x00RRGGBB, stored as BGRX in memory) ---
; NexusOS design-system light palette semantic tokens.
COLOR_BG_BASE       equ 0x00F5F6FA   ; #F5F6FA
COLOR_SURFACE_1     equ 0x00FFFFFF   ; #FFFFFF
COLOR_SURFACE_2     equ 0x00ECEFF4   ; #ECEFF4
COLOR_BORDER        equ 0x00D8DDE3   ; #D8DDE3
COLOR_BORDER_STRONG equ 0x00C4CBD3   ; #C4CBD3
COLOR_TEXT_PRIMARY  equ 0x000F141E   ; #0F141E
COLOR_TEXT_SECONDARY equ 0x004B5563  ; #4B5563
COLOR_TEXT_TERTIARY equ 0x008A939F   ; #8A939F
COLOR_ACCENT_LIGHT  equ 0x004C8BFF   ; #4C8BFF
COLOR_ACCENT        equ 0x002A6FFF   ; #2A6FFF
COLOR_ACCENT_DARK   equ 0x001A55D6   ; #1A55D6
COLOR_CYAN          equ 0x0036C0E0   ; #36C0E0
COLOR_CYAN_DARK     equ 0x001291B0   ; #1291B0
COLOR_ERROR         equ 0x00E5474D   ; #E5474D
COLOR_WARNING       equ 0x00F7B52C   ; #F7B52C
COLOR_SUCCESS       equ 0x002EB56E   ; #2EB56E

COLOR_BLACK         equ 0x00000000
COLOR_WHITE         equ 0x00FFFFFF
COLOR_DESKTOP_BG    equ COLOR_BG_BASE
COLOR_TASKBAR_BG    equ COLOR_SURFACE_2
COLOR_TASKBAR_TOP   equ COLOR_SURFACE_1
COLOR_CHROME_FACE   equ COLOR_SURFACE_2
COLOR_SURFACE       equ COLOR_SURFACE_1
COLOR_SUNKEN        equ COLOR_SURFACE_2
COLOR_BEVEL_LT      equ COLOR_SURFACE_1
COLOR_BEVEL_DK      equ COLOR_BORDER_STRONG
COLOR_BEVEL_XDK     equ COLOR_BORDER
COLOR_TITLEBAR      equ COLOR_ACCENT
COLOR_TITLEBAR_UNF  equ COLOR_BORDER_STRONG
COLOR_WINDOW_BG     equ COLOR_SURFACE_1
COLOR_WINDOW_BORDER equ COLOR_BORDER
COLOR_CLOSE_BTN     equ COLOR_ERROR
COLOR_CLOSE_HOVER   equ 0x00F2666C
COLOR_MIN_BTN       equ COLOR_SURFACE_2
COLOR_TEXT_WHITE     equ COLOR_WHITE
COLOR_TEXT_BLACK     equ COLOR_TEXT_PRIMARY
COLOR_TEXT_GRAY      equ COLOR_TEXT_SECONDARY
COLOR_TEXT_TITLE     equ COLOR_WHITE
COLOR_HIGHLIGHT      equ COLOR_ACCENT
COLOR_CURSOR         equ COLOR_TEXT_PRIMARY
COLOR_START_BTN      equ COLOR_SURFACE_1
COLOR_START_HOVER    equ COLOR_SURFACE_2

; --- Window Manager ---
MAX_WINDOWS         equ 8
WINDOW_STRUCT_SIZE  equ 256          ; Bytes per window struct
L3_USER_STACK_SIZE  equ 16384        ; 16 KB user stack per L3 window callback context
L3_SYSCALL_STACK_SIZE equ 4096       ; 4 KB syscall stack per L3 context
TITLEBAR_HEIGHT     equ 24
BORDER_WIDTH        equ 2
CLOSE_BTN_SIZE      equ 18
MIN_BTN_SIZE        equ 18
MIN_WINDOW_W        equ 200
MIN_WINDOW_H        equ 100

; --- Taskbar ---
; Only size constants live here. Y positions and right-anchored X
; positions depend on the current screen size and are kept in runtime
; globals owned by display.asm (scr_taskbar_y, scr_clock_x, ...). The
; kernel recomputes them in display_recompute_layout() whenever a mode
; change happens, so the taskbar follows the active resolution.
TASKBAR_HEIGHT      equ 36
START_BTN_W         equ 70
START_BTN_H         equ 28
START_BTN_X         equ 4
CLOCK_WIDTH         equ 64

; --- Keyboard ---
KB_BUFFER_SIZE      equ 64

; --- Mouse ---
MOUSE_BUFFER_SIZE   equ 64
CURSOR_WIDTH        equ 12
CURSOR_HEIGHT       equ 19

; --- PIT ---
PIT_FREQUENCY       equ 100          ; 100Hz = 10ms per tick
PIT_DIVISOR         equ 11932        ; 1193182 / 100

; --- PIC vectors ---
IRQ_BASE_MASTER     equ 32
IRQ_BASE_SLAVE      equ 40
IRQ_TIMER           equ 32           ; IRQ0 -> vector 32
IRQ_KEYBOARD        equ 33           ; IRQ1 -> vector 33
IRQ_CASCADE         equ 34           ; IRQ2 -> vector 34
IRQ_MOUSE           equ 44           ; IRQ12 -> vector 44

; --- Font ---
FONT_WIDTH          equ 8
FONT_HEIGHT         equ 16
FONT_FIRST_CHAR     equ 32           ; Space
FONT_LAST_CHAR      equ 126          ; Tilde
FONT_NUM_CHARS      equ 95           ; 126 - 32 + 1

; --- Window flags ---
WF_VISIBLE          equ 0x01
WF_FOCUSED          equ 0x02
WF_DRAGGING         equ 0x04
WF_MINIMIZED        equ 0x08
WF_ACTIVE           equ 0x10         ; Slot is in use

; --- Mouse event types ---
MEVT_MOVE           equ 1
MEVT_LCLICK         equ 2
MEVT_RCLICK         equ 3
MEVT_LRELEASE       equ 4
MEVT_RRELEASE       equ 5

; --- Key modifier flags ---
KMOD_SHIFT          equ 0x01
KMOD_CTRL           equ 0x02
KMOD_ALT            equ 0x04

; --- Virtual Key Codes (ASCII byte in kb_buffer for non-printable keys) ---
KEY_F1              equ 0xF1
KEY_F2              equ 0xF2
KEY_F3              equ 0xF3
KEY_F4              equ 0xF4
KEY_F5              equ 0xF5
KEY_F6              equ 0xF6
KEY_F7              equ 0xF7
KEY_F8              equ 0xF8
KEY_F9              equ 0xF9
KEY_F10             equ 0xFA
KEY_F11             equ 0xFB
KEY_F12             equ 0xFC

; --- USB/XHCI Memory Layout ---
%ifdef NEXUS_CACHE32_MAX
XHCI_DCBAA_ADDR     equ 0x1700000    ; Cold DMA region outside GUI/app arenas
XHCI_CMD_RING_ADDR  equ 0x1710000
XHCI_ERST_ADDR      equ 0x1720000
XHCI_EVT_RING_ADDR  equ 0x1730000
XHCI_SCRATCH_ADDR   equ 0x1740000
XHCI_DEV_CTX_ADDR   equ 0x1750000
XHCI_INPUT_CTX_ADDR equ 0x1760000
XHCI_CTRL_RING_ADDR equ 0x1770000
XHCI_INT_RING_ADDR  equ 0x1780000
XHCI_CTRL_BUF_ADDR  equ 0x1790000
XHCI_MOUSE_BUF_ADDR equ 0x17A0000
XHCI_DEV_CTX2_ADDR  equ 0x17B0000
XHCI_INT_RING2_ADDR equ 0x17C0000
XHCI_MOUSE_BUF2_ADDR equ 0x17D0000
XHCI_CTRL_RING2_ADDR equ 0x17E0000
XHCI_MEM_END        equ 0x17F0000
%else
XHCI_DCBAA_ADDR     equ 0x1700000    ; Device Context Base Address Array
XHCI_CMD_RING_ADDR  equ 0x1710000    ; Command Ring (4096 TRBs)
XHCI_ERST_ADDR      equ 0x1720000    ; Event Ring Segment Table
XHCI_EVT_RING_ADDR  equ 0x1730000    ; Event Ring (4096 TRBs)
XHCI_SCRATCH_ADDR   equ 0x1740000    ; Scratchpad array + buffers
XHCI_DEV_CTX_ADDR   equ 0x1750000    ; Output Device Context (slot 1)
XHCI_INPUT_CTX_ADDR equ 0x1760000    ; Input Context
XHCI_CTRL_RING_ADDR equ 0x1770000    ; Control EP0 Transfer Ring
XHCI_INT_RING_ADDR  equ 0x1780000    ; Interrupt IN Transfer Ring
XHCI_CTRL_BUF_ADDR  equ 0x1790000    ; Control transfer data buffers
XHCI_MOUSE_BUF_ADDR equ 0x17A0000    ; Mouse interrupt data buffers (slot 1)
; Slot 2 device support
XHCI_DEV_CTX2_ADDR  equ 0x17B0000    ; Output Device Context (slot 2)
XHCI_INT_RING2_ADDR equ 0x17C0000    ; Interrupt IN Transfer Ring (slot 2)
XHCI_MOUSE_BUF2_ADDR equ 0x17D0000   ; Mouse interrupt data buffers (slot 2)
XHCI_CTRL_RING2_ADDR equ 0x17E0000   ; Control EP0 Transfer Ring (slot 2)
XHCI_MEM_END        equ 0x17F0000    ; End of XHCI memory region
%endif

; --- XHCI Capability Register Offsets (from MMIO base) ---
XHCI_CAP_CAPLENGTH  equ 0x00
XHCI_CAP_HCSPARAMS1 equ 0x04
XHCI_CAP_HCSPARAMS2 equ 0x08
XHCI_CAP_HCCPARAMS1 equ 0x10
XHCI_CAP_DBOFF      equ 0x14
XHCI_CAP_RTSOFF     equ 0x18

; --- XHCI Operational Register Offsets (from OpBase) ---
XHCI_OP_USBCMD      equ 0x00
XHCI_OP_USBSTS      equ 0x04
XHCI_OP_PAGESIZE     equ 0x08
XHCI_OP_DNCTRL      equ 0x14
XHCI_OP_CRCR_LO     equ 0x18
XHCI_OP_CRCR_HI     equ 0x1C
XHCI_OP_DCBAAP_LO   equ 0x30
XHCI_OP_DCBAAP_HI   equ 0x34
XHCI_OP_CONFIG      equ 0x38

; --- XHCI Port Register Offsets (from OpBase + 0x400) ---
XHCI_PORTSC         equ 0x00
XHCI_PORT_REG_SIZE  equ 0x10         ; 16 bytes per port

; --- XHCI Runtime Register Offsets (from RtBase) ---
XHCI_RT_IR0_IMAN    equ 0x20
XHCI_RT_IR0_IMOD    equ 0x24
XHCI_RT_IR0_ERSTSZ  equ 0x28
XHCI_RT_IR0_ERSTBA_LO equ 0x30
XHCI_RT_IR0_ERSTBA_HI equ 0x34
XHCI_RT_IR0_ERDP_LO equ 0x38
XHCI_RT_IR0_ERDP_HI equ 0x3C

; --- USBCMD bits ---
XHCI_CMD_RS         equ (1 << 0)     ; Run/Stop
XHCI_CMD_HCRST      equ (1 << 1)     ; Host Controller Reset
XHCI_CMD_INTE       equ (1 << 2)     ; Interrupter Enable

; --- USBSTS bits ---
XHCI_STS_HCH        equ (1 << 0)     ; HC Halted
XHCI_STS_CNR        equ (1 << 11)    ; Controller Not Ready

; --- PORTSC bits ---
XHCI_PORTSC_CCS     equ (1 << 0)     ; Current Connect Status
XHCI_PORTSC_PED     equ (1 << 1)     ; Port Enabled/Disabled
XHCI_PORTSC_PR      equ (1 << 4)     ; Port Reset
XHCI_PORTSC_PLS_SHIFT equ 5          ; Port Link State shift
XHCI_PORTSC_PP      equ (1 << 9)     ; Port Power
XHCI_PORTSC_SPEED_SHIFT equ 10       ; Port Speed shift
XHCI_PORTSC_CSC     equ (1 << 17)    ; Connect Status Change
XHCI_PORTSC_PRC     equ (1 << 21)    ; Port Reset Change
; Bits that are RW1CS (write 1 to clear) - must preserve when writing other bits
XHCI_PORTSC_CHANGE_BITS equ ((1<<17)|(1<<18)|(1<<20)|(1<<21)|(1<<22)|(1<<23))

; --- TRB Types (shifted into bits 15:10 of dword 3) ---
TRB_NORMAL           equ (1 << 10)
TRB_SETUP            equ (2 << 10)
TRB_DATA             equ (3 << 10)
TRB_STATUS           equ (4 << 10)
TRB_LINK             equ (6 << 10)
TRB_ENABLE_SLOT      equ (9 << 10)
TRB_ADDRESS_DEV      equ (11 << 10)
TRB_CONFIG_EP        equ (12 << 10)
TRB_EVAL_CTX         equ (13 << 10)
TRB_TRANSFER_EVT     equ (32 << 10)
TRB_CMD_COMPLETION   equ (33 << 10)
TRB_PORT_STATUS_CHG  equ (34 << 10)

; --- TRB Flag Bits (dword 3) ---
TRB_CYCLE            equ (1 << 0)     ; Cycle bit
TRB_TC               equ (1 << 1)     ; Toggle Cycle (Link TRB)
TRB_IOC              equ (1 << 5)     ; Interrupt On Completion
TRB_IDT              equ (1 << 6)     ; Immediate Data
TRB_BSR              equ (1 << 9)     ; Block Set Address Request

; --- TRB Setup stage Transfer Type (bits 17:16 of dword 3) ---
TRB_TRT_NO_DATA      equ (0 << 16)
TRB_TRT_OUT          equ (2 << 16)
TRB_TRT_IN           equ (3 << 16)

; --- TRB Data stage Direction (bit 16 of dword 3) ---
TRB_DIR_OUT          equ (0 << 16)
TRB_DIR_IN           equ (1 << 16)

; --- Ring sizes ---
XHCI_RING_SIZE       equ 4096         ; TRBs per ring (64KB)
XHCI_TRB_SIZE        equ 16           ; Bytes per TRB

; --- USB Standard Request Codes ---
USB_REQ_GET_DESC     equ 0x06
USB_REQ_SET_CONFIG   equ 0x09
USB_REQ_SET_IFACE    equ 0x0B

; --- USB HID Request Codes ---
USB_HID_SET_PROTOCOL equ 0x0B

; --- USB Descriptor Types ---
USB_DESC_DEVICE      equ 0x01
USB_DESC_CONFIG      equ 0x02
USB_DESC_INTERFACE   equ 0x04
USB_DESC_ENDPOINT    equ 0x05
USB_DESC_HID         equ 0x21

; --- USB Endpoint Types ---
USB_EP_CONTROL       equ 0
USB_EP_ISOCH         equ 1
USB_EP_BULK          equ 2
USB_EP_INTERRUPT     equ 3

; --- XHCI Endpoint Types (for Endpoint Context) ---
XHCI_EP_NOT_VALID    equ 0
XHCI_EP_ISOCH_OUT    equ 1
XHCI_EP_BULK_OUT     equ 2
XHCI_EP_INT_OUT      equ 3
XHCI_EP_CONTROL      equ 4
XHCI_EP_ISOCH_IN     equ 5
XHCI_EP_BULK_IN      equ 6
XHCI_EP_INT_IN       equ 7

; --- XHCI Port Speeds ---
XHCI_SPEED_FULL      equ 1
XHCI_SPEED_LOW       equ 2
XHCI_SPEED_HIGH      equ 3
XHCI_SPEED_SUPER     equ 4
