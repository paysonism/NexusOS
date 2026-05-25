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
CURSOR_BG_ADDR        equ 0x2400000              ; save buffer + 10 MiB pad
WINDOW_POOL_ADDR      equ 0x2410000
EVENT_BUFFER_ADDR     equ 0x2420000

; --- Userland app arenas ------------------------------------------------
; APP_DATA_ADDR must be 2 MiB aligned because paging.asm derives the
; user PDE index as (APP_DATA_ADDR / 0x200000). Each slot is 2 MiB so the
; generated NexusHL app blob, including the full SVG wallpaper renderer, fits
; below the per-slot shadow window/stack.
APP_SLOT_COUNT         equ 12
APP_DATA_ADDR         equ 0x2600000              ; 38 MiB, 2 MiB aligned
APP_SLOT_SIZE         equ 0x200000
APPS_BLOB_ADDR        equ (APP_DATA_ADDR + APP_SLOT_SIZE * APP_SLOT_COUNT)
APPS_BLOB_MAX_SIZE    equ 0x200000
L3_SYSCALL_STACK_ADDR equ (APPS_BLOB_ADDR + APPS_BLOB_MAX_SIZE)

WALLPAPER_CACHE_BYTES equ BOOT_BACK_BUFFER_SIZE
WALLPAPER_CACHE0_ADDR equ (L3_SYSCALL_STACK_ADDR + 0x200000)
WALLPAPER_CACHE1_ADDR equ (WALLPAPER_CACHE0_ADDR + WALLPAPER_CACHE_BYTES)
WALLPAPER_CACHE2_ADDR equ (WALLPAPER_CACHE1_ADDR + WALLPAPER_CACHE_BYTES)
WALLPAPER_CACHE_ADDR  equ WALLPAPER_CACHE0_ADDR  ; legacy alias for cache users
BACK_BUFFER_SAVE_ADDR equ (WALLPAPER_CACHE2_ADDR + WALLPAPER_CACHE_BYTES + 0x100000)

; App arena 4KB page tables. The arena is split into 4KB pages (one PT per
; covered PDE) so the kernel can mark only the running slot's pages USER and
; enforce W^X per page. 8 PTs cover the 16 MiB arena (0x75000..0x7CFFF).
APP_ARENA_PT_BASE     equ 0x75000
ARENA_SLOT_PAGES      equ (APP_SLOT_SIZE / 0x1000) ; 512 4KB pages per slot

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

; --- FAT16 ramdisk (DATA.IMG) ---------------------------------------------
; The kernel's FAT16 driver runs on top of an LBA-addressed block device.
; On QEMU we attach build/data.img as an IDE drive; on real hardware
; (NVMe-only laptops, USB-boot) there is no legacy IDE controller, so the
; UEFI loader instead loads \EFI\BOOT\DATA.IMG into RAM and writes its
; base/size here. ata.asm consults ramdisk.asm first; if an LBA falls
; inside the registered region the read/write is satisfied from RAM,
; otherwise it falls through to ATA PIO. Both paths see the same FAT16
; volume and the rest of the kernel is unaware of the source.
;
; Size: bumped here if build/data.img outgrows the limit. The loader
; rejects images larger than DATA_IMG_MAX_SIZE; the kernel only ever
; reads up to the registered size (so a smaller actual file is fine).
VBE_RAMDISK_BASE_OFF   equ 0x50
VBE_RAMDISK_SIZE_OFF   equ 0x58
DATA_IMG_MAX_SIZE      equ 0x1000000   ; 16 MiB cap

; --- Persistent storage backing (Phase 1 contract) ------------------------
; The UEFI loader, while firmware services are still available, resolves
; the physical disk LBA extents of \EFI\BOOT\DATA.IMG and records them
; here so the kernel can flush dirty ramdisk pages back to the same on-disk
; bytes after ExitBootServices. Without this contract, real-hardware FS
; writes are session-only (see src/kernel/drivers/ramdisk.asm header).
;
; Storage class tells the kernel which driver to dispatch the flush to:
;   0 = none (session-only, current behavior)
;   1 = NVMe        (src/kernel/drivers/nvme.asm - Phase 2)
;   2 = USB-MSC     (src/kernel/drivers/usb_msc.asm - Phase 3)
;   3 = legacy ATA  (existing ata.asm - QEMU only)
;
; Extent table format: array of {u64 start_lba, u32 sector_count, u32 _pad}
; written to STORAGE_EXTENTS_ADDR by the loader. Cap = STORAGE_EXTENTS_MAX
; entries (FAT32 fragmentation on a fresh ESP rarely exceeds a handful).
VBE_STORAGE_CLASS_OFF   equ 0x60   ; u8 (above values)
VBE_STORAGE_LUN_OFF     equ 0x61   ; u8 (NVMe NSID or USB LUN)
VBE_STORAGE_BLKSIZE_OFF equ 0x62   ; u16 (logical block size, usually 512)
VBE_STORAGE_EXT_CNT_OFF equ 0x64   ; u32 (number of extents written)
VBE_STORAGE_EXT_PTR_OFF equ 0x68   ; u64 (physical pointer to extent array)

STORAGE_EXTENTS_ADDR    equ 0x9200   ; 4 KiB scratch for extent table
STORAGE_EXTENTS_MAX     equ 256      ; max extents (256 * 16B = 4 KiB)
STORAGE_EXTENT_SIZE     equ 16       ; bytes per extent entry

%endif
