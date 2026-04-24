# NexusOS v3.0

A 64-bit operating system written entirely in x86-64 assembly, with a
graphical desktop, a ring-3 callback path for built-in apps, and a source tree
organized to keep boot code, kernel code, and user-facing code clearly
separated.

## Prerequisites

| Tool | Version | Path |
|------|---------|------|
| [NASM](https://nasm.us/) | 2.16+ | `C:\Tools\nasm-2.16.03\nasm.exe` |
| [QEMU](https://www.qemu.org/download/) | Any recent | `C:\Program Files\qemu\` |
| OVMF firmware | Required for UEFI | Place `OVMF.fd` in `build\` |

## Build

### UEFI

```powershell
.\build_uefi.ps1
```

Outputs:

- `build\esp\EFI\BOOT\BOOTX64.EFI`
- `build\esp\EFI\BOOT\KERNEL.BIN`
- `build\data.img`

### BIOS

```powershell
.\build_bios.ps1
```

Outputs:

- `build\mbr.bin`
- `build\stage2.bin`
- `build\kernel.bin`
- `build\NexusOS.img`

## Verification

Use this before and after structural changes:

```powershell
.\test_verify_all.ps1
```

That runs:

- BIOS build
- UEFI build
- UEFI smoke boot with serial capture

UEFI smoke output is written to `build\smoke_uefi_serial.log`.

## Run

### UEFI

```powershell
.\run_uefi.ps1
```

This launches QEMU with:

- OVMF firmware
- 512 MB RAM by default (`.\run_uefi.ps1 -GuestMemory 256M` to override)
- standard VGA
- xHCI USB controller with mouse and keyboard
- serial on `tcp:127.0.0.1:5555`
- QEMU monitor on `telnet://127.0.0.1:4444`

Cache-first performance profile:

```powershell
.\build_uefi.ps1 -PerfProfile Cache32Max
.\run_uefi.ps1 -PerfProfile Cache32Max
```

This uses the 8-core QEMU topology. BIOS uses the strict 32 MB guest target;
UEFI uses a 36 MB OVMF floor while keeping the same kernel profile. See
`docs\cache32max-performance.md`.

### BIOS

```powershell
.\run_bios.ps1
```

BIOS also defaults to 512 MB RAM. Use `.\run_bios.ps1 -GuestMemory 256M`
to override.

## Source Layout

```text
src/
  boot/         BIOS MBR, Stage 2, UEFI loader, paging, early boot helpers
  include/      shared headers, constants, macros, syscall wrappers
  kernel/
    core/       entry, init flow, IDT/ISR, memory, PIC/PIT, TSS
    arch/       ACPI, APIC, IOAPIC, MADT, RSDP, AML parsing
    proc/       process, usermode trampoline, syscall boundary
    fs/         FAT16
    drivers/    hardware drivers
    gui/        kernel-resident WM, render, desktop, cursor, taskbar
    lib/        kernel helper libraries
  user/
    apps.asm    built-in ring-3 app code
    lib/        app-side include surface
    templates/  starter callback templates
    poc/        regression probes and security tests

docs/
  reference-index.md
  source-layout.md
  syscalls.md
  app-authoring.md
  architecture.md
  app-loader-format.md
  boot-reference.md
  usermode-reference.md
  kernel-function-reference.md
  memory-map-reference.md
  data-layout-reference.md
  state-machine-reference.md

build_uefi.ps1
build_bios.ps1
run_uefi.ps1
run_bios.ps1
test_smoke_uefi.ps1
test_verify_all.ps1
```

## App Development

The repo now has a small userland-facing include surface:

- `src/user/lib/nexus_app.inc`
- `src/user/templates/hello_callback.asm`

For the current syscall and callback ABI, see:

- `docs/syscalls.md`
- `docs/reference-index.md`
- `docs/app-authoring.md`
- `docs/source-layout.md`
- `docs/architecture.md`
- `docs/app-loader-format.md`
- `docs/boot-reference.md`
- `docs/usermode-reference.md`
- `docs/kernel-function-reference.md`
- `docs/memory-map-reference.md`
- `docs/data-layout-reference.md`
- `docs/state-machine-reference.md`

## Notes

- Built-in apps still ship inside the monolithic kernel image today.
- The source tree is arranged so future independently built user apps can move
  out cleanly.
- Security hardening for the old syscall 9 window-handler exploit path is in
  place and covered by the current tree organization and verification flow.
