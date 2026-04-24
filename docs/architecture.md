# NexusOS Architecture

This is the current high-level flow through the OS, written for maintainers who
need to change code without losing track of responsibility boundaries.

## Boot to desktop

1. `src/boot`
   BIOS stage files or the UEFI loader enter 64-bit mode, prepare paging, and
   transfer control to the kernel load address.
2. `src/kernel/core`
   Entry, interrupt tables, timers, memory setup, and top-level kernel init.
3. `src/kernel/arch`
   Platform discovery and interrupt-controller setup through ACPI/APIC/IOAPIC.
4. `src/kernel/drivers`
   Hardware-facing devices: display, input, storage, USB, PCI, battery, and
   supporting HID layers.
5. `src/kernel/fs`
   FAT16 cache, directory enumeration, reads, writes, and directory switching.
6. `src/kernel/gui`
   Desktop, taskbar, renderer, cursor, and the kernel-resident window manager.
7. `src/kernel/proc`
   Ring-3 callback trampoline, syscall boundary, and process/runtime state.
8. `src/user`
   Built-in user-facing apps and usermode helpers.

## Ring boundaries

### Ring 0

- All code under `src/kernel`
- Owns hardware, global memory, filesystem caches, and live window structs
- Calls into usermode only through the `call_app_l3` trampoline

### Ring 3

- User callbacks and app-facing helpers under `src/user`
- Runs with the syscall ABI documented in `docs/syscalls.md`
- Receives a shadow window struct, not the live kernel window object

## Current user callback path

1. A kernel window stores callback targets.
2. `src/kernel/gui/window.asm` detects draw/click/key events.
3. The kernel calls `call_app_l3` in `src/kernel/proc/usermode.asm`.
4. The trampoline picks the app slot, mirrors window state into the slot arena,
   and returns to ring 3 with the callback arguments.
5. User code runs and issues syscalls back through
   `src/kernel/proc/syscall.asm`.
6. `SYS_APP_DONE` returns through `call_app_l3_return`.

## Design rules

- Keep hardware policy in `src/kernel/drivers`, not in user apps.
- Keep pointer validation at the syscall boundary, not in scattered helpers.
- Keep built-in app code under `src/user`, even while it is still linked into
  the monolithic kernel image.
- Prefer adding a new subdirectory over dumping new features into an existing
  catch-all file.
