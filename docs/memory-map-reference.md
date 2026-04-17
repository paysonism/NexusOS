# NexusOS Memory Map Reference

This document collects the fixed-address regions and major in-memory ownership
rules used across boot, kernel, drivers, GUI, and ring 3.

Primary source: `C:\Users\user\Documents\new\src\include\constants.inc`

## Low Memory and Boot Handoff

| Address | Meaning | Owner |
|---|---|---|
| `0x7E00` | Stage-2 load address | `src/boot/stage2.asm` |
| `0x1FF0` | E820 entry count | `src/boot/stage2.asm` |
| `0x2000` | E820 memory map | `src/boot/stage2.asm` |
| `0x9000` | VBE/GOP framebuffer info block | `src/boot/vesa.asm`, `src/boot/uefi_loader.asm` |
| `0x9100` | Saved boot drive byte | BIOS boot path |
| `0x70000` | Page-table base | `src/boot/paging.asm` |

## Kernel Core

| Address | Meaning | Owner |
|---|---|---|
| `0x100000` | Kernel load address | bootloaders + `src/kernel/core/entry.asm` |
| `0x200000` | Kernel stack top and IDT base region | `src/kernel/core/entry.asm`, `src/kernel/core/idt.asm`, `src/kernel/core/tss.asm` |
| `0x210000` | Kernel data / heap start | shared kernel region |
| `0x300000` | Physical-page bitmap | `src/kernel/core/memory.asm` |

## Graphics and Windowing

| Address | Meaning | Owner |
|---|---|---|
| `0x400000` | Display backbuffer | `src/kernel/drivers/display.asm`, `src/kernel/gui/render.asm` |
| `0x700000` | Cursor background-save area | `src/kernel/gui/cursor.asm` |
| `0x710000` | Window pool base | `src/kernel/gui/window.asm` |
| `0x720000` | Event-buffer region | shared GUI/input region |
| `0xA00000` | Saved backbuffer / drag/restore region | `src/kernel/gui/render.asm` |

## Ring-3 App Arenas and Runtime

| Address | Meaning | Owner |
|---|---|---|
| `0x800000` | App slot arena base | `src/kernel/proc/usermode.asm`, `src/kernel/gui/window.asm` |
| `0x800000 + slot * 0x10000` | Per-slot app arena | `src/kernel/proc/usermode.asm` |
| `0xC00000` | Kernel-only syscall-stack region | `src/kernel/proc/usermode.asm`, `src/kernel/proc/syscall.asm` |

### App slot rules

- Each slot is `APP_SLOT_SIZE = 0x10000` bytes.
- The slot stores:
  - user code/data
  - a shadow window struct near the end of the slot
  - per-slot callback-local state
- `WIN_OFF_APPDATA` points at the slot base for a window.

## USB / XHCI Fixed Region

These addresses are reserved by the USB stack and should not be repurposed
without auditing `src/kernel/drivers/xhci.asm`, `src/kernel/drivers/usb_hid.asm`,
and `src/kernel/drivers/hid_parser.asm`.

| Address | Meaning |
|---|---|
| `0x900000` | XHCI DCBAA |
| `0x910000` | XHCI command ring |
| `0x920000` | XHCI ERST |
| `0x930000` | XHCI event ring |
| `0x940000` | XHCI scratchpad region |
| `0x950000` | XHCI device context slot 1 |
| `0x960000` | XHCI input context |
| `0x970000` | XHCI control ring |
| `0x980000` | XHCI interrupt ring |
| `0x990000` | XHCI control-buffer region |
| `0x9A0000` | XHCI mouse buffer slot 1 |
| `0x9B0000` | XHCI device context slot 2 |
| `0x9C0000` | XHCI interrupt ring slot 2 |
| `0x9D0000` | XHCI mouse buffer slot 2 |
| `0x9E0000` | XHCI control ring slot 2 |
| `0x9F0000` | End of XHCI reserved region |

## FAT16 Driver Scratch Regions

These addresses are owned by `src/kernel/fs/fat16.asm`.

| Address | Meaning |
|---|---|
| `0xD00000` | FAT16 sector buffer |
| `0xD01000` | FAT table cache |
| `0xD11000` | root/current directory cache |
| `0xD21000` | file read buffer |
| `0xD31000` | directory cache |

## Shared Scratch Buffers Used By Built-in Apps

These constants are exposed in `src/user/lib/nexus_window.inc` and are
currently allowed by syscall validation because the built-in apps use them.

| Address | Meaning | Current use |
|---|---|---|
| `0x950000` | app BMP file scratch | BMP viewer path in `src/user/apps/shell.inc` |
| `0x990000` | paint canvas buffer | Paint app in `src/user/apps/paint.inc` |

These are not ideal long-term boundaries. They are documented here so they are
visible during future hardening work.

## Screen and UI Constants

Important global geometry constants:

- `SCREEN_WIDTH = 1024`
- `SCREEN_HEIGHT = 768`
- `SCREEN_BPP = 32`
- `SCREEN_PITCH = 4096`
- `TASKBAR_HEIGHT = 36`
- `TITLEBAR_HEIGHT = 24`
- `BORDER_WIDTH = 2`

## Ownership Rules

- If an address is in a fixed reserved region, treat the owning subsystem as
  authoritative.
- Do not add new fixed buffers casually; prefer extending the owning
  subsystem’s documented region or moving data into per-slot/per-object storage.
- When moving any fixed address, update:
  - `constants.inc`
  - subsystem code
  - syscall validation exceptions
  - this document
