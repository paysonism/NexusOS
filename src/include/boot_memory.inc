%ifndef BOOT_MEMORY_INC
%define BOOT_MEMORY_INC

; NexusOS boot memory contract.
; Keep loader, paging, and kernel users on one map while relocation work lands.

STAGE2_LOAD_ADDR    equ 0x7E00
E820_COUNT_ADDR     equ 0x1FF0
E820_MAP_ADDR       equ 0x2000
VBE_INFO_ADDR       equ 0x9000
BOOT_DRIVE_ADDR     equ 0x9100
PAGE_TABLE_ADDR     equ 0x70000
SMP_TRAMPOLINE_ADDR equ 0x8000
KERNEL_LOAD_ADDR    equ 0x100000
KERNEL_STACK_TOP    equ 0xC00000
IDT_ADDR            equ 0xC10000
KERNEL_DATA_ADDR    equ 0xC20000
PAGE_BITMAP_ADDR    equ 0xE00000
PAGE_BITMAP_SIZE    equ 0x100000

; --- Framebuffer / GUI back buffer ---------------------------------------
; The kernel renders into a back buffer that the compositor flips to the
; physical framebuffer. The back buffer is sized for the maximum
; *logical* desktop we support; smaller modes use only the top-left.
;
;   MAX_FB_WIDTH x MAX_FB_HEIGHT x 4 (bpp) must fit in BOOT_BACK_BUFFER_SIZE.
;   Today: 1920 x 1200 x 4 = 9_216_000 bytes -> round up to 0x900000 (9 MiB).
;
; Any caller setting a new mode (display_set_mode syscall) is validated
; against BOOT_BACK_BUFFER_SIZE / 4 pixels; bumping the constants below
; automatically widens the syscall acceptance range.
MAX_FB_WIDTH          equ 1920
MAX_FB_HEIGHT         equ 1200
BACK_BUFFER_ADDR      equ 0x1000000              ; 16 MiB
BOOT_BACK_BUFFER_SIZE equ 0x900000               ; 9 MiB (>= WUXGA*4)
WALLPAPER_CACHE_BYTES equ BOOT_BACK_BUFFER_SIZE
WALLPAPER_CACHE0_ADDR equ 0x3000000              ; liquid metal SVG wallpaper cache
WALLPAPER_CACHE1_ADDR equ (WALLPAPER_CACHE0_ADDR + WALLPAPER_CACHE_BYTES)
WALLPAPER_CACHE2_ADDR equ (WALLPAPER_CACHE1_ADDR + WALLPAPER_CACHE_BYTES)
WALLPAPER_CACHE_ADDR  equ WALLPAPER_CACHE0_ADDR  ; legacy alias for cache users
BACK_BUFFER_SAVE_ADDR equ (WALLPAPER_CACHE2_ADDR + WALLPAPER_CACHE_BYTES + 0x100000)
CURSOR_BG_ADDR        equ 0x2400000              ; save buffer + 10 MiB pad
WINDOW_POOL_ADDR      equ 0x2410000
EVENT_BUFFER_ADDR     equ 0x2420000

; --- Userland app arenas ------------------------------------------------
; APP_DATA_ADDR must be 2 MiB aligned because paging.asm derives the
; user PDE index as (APP_DATA_ADDR / 0x200000). Each slot is 1 MiB and we
; reserve MAX_WINDOWS (=8) slots; APPS_BLOB and L3 stacks live above.
APP_DATA_ADDR         equ 0x2600000              ; 38 MiB, 2 MiB aligned
APP_SLOT_SIZE         equ 0x100000
APPS_BLOB_ADDR        equ 0x2E00000              ; APP_DATA_ADDR + 8 slots
APPS_BLOB_MAX_SIZE    equ 0x100000
L3_SYSCALL_STACK_ADDR equ 0x2F00000

; App arena 4KB page tables. The arena is split into 4KB pages (one PT per
; covered PDE) so the kernel can mark only the running slot's pages USER and
; enforce W^X per page. 4 PTs cover the 8 MiB arena (0x75000..0x78FFF).
APP_ARENA_PT_BASE     equ 0x75000
ARENA_SLOT_PAGES      equ (APP_SLOT_SIZE / 0x1000) ; 256 4KB pages per slot

GUI_LLC_ARENA_START equ BACK_BUFFER_ADDR
GUI_LLC_ARENA_END   equ APP_DATA_ADDR

VBE_FB_ADDR_OFF     equ 0x00
VBE_WIDTH_OFF       equ 0x08
VBE_HEIGHT_OFF      equ 0x0C
VBE_PITCH_OFF       equ 0x10
VBE_BPP_OFF         equ 0x14
VBE_SPP_OFF         equ 0x18
VBE_APPS_BASE_OFF   equ 0x20
VBE_APPS_SIZE_OFF   equ 0x28
VBE_BACKBUF_OFF     equ 0x30
VBE_BACKBUF_SIZE_OFF equ 0x38
VBE_APP_ARENA_BASE_OFF equ 0x40
VBE_APP_ARENA_SIZE_OFF equ 0x48

%endif
