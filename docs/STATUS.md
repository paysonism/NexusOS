# NexusOS — Project Status

_Last updated: 2026-05-25_

This document is the formal source of truth for project status,
milestones in flight, and what is parked vs. active. Memory files
under `~/.claude/projects/.../memory/` index into here; do not
duplicate detail there.

---

## TL;DR

NexusOS boots cleanly on the target hardware (Acer Nitro V16 AI,
AMD Strix Point) under both BIOS and UEFI, runs a graphical desktop,
handles USB/I2C/PS-2 input, has working FAT16 ramdisk and
networking, and pushes pixels to the GOP framebuffer with WC-mapped
write-combining for ~10× faster flips than the original UC path.

The next focus area is **moving rendering off the CPU.** All current
drawing is CPU writes into the framebuffer. The DMUB/DCN firmware
side-quest (which would have unlocked backlight and panel power, but
*not* 3D acceleration) is parked at Phase 1; the work-in-progress
sits on `dev` and can be resumed if backlight becomes a priority.

---

## Milestones — done

| Area | What works | Landed |
|---|---|---|
| Boot (BIOS) | MBR → Stage2 → kernel @ 0x100000, unreal-mode bulk load | 2026-02-15 |
| Boot (UEFI) | BOOTX64.EFI → KERNEL.BIN, CR4/EFER sanitized, 1GB-page identity map to 512GB | 2026-02-15 |
| Display | GOP framebuffer scanout, backbuffer + flip, fonts, window manager | 2026-02 |
| Input (PS/2) | Keyboard with F1-F12 + key repeat, 5-button Intellimouse | 2026-02-23 |
| Input (USB) | xHCI HID, USB keyboard + mouse + multi-device, slot routing | 2026-02-24 |
| Input (I2C HID) | Touchpad with palm rejection, pinch-to-zoom, 3-finger swipe | 2026-02-23 |
| Filesystem | FAT16 ramdisk, real-HW DATA.IMG via UEFI loader shim | 2026-02 |
| Networking | RTL8156 USB 2.5GbE on real hardware | 2026-05-21 |
| FB performance | WC mapping via PAT slot 1, AP PAT propagated (~10× flips) | 2026-05-25 |
| NexusHL apps | Compiler + SVG2 subset (text, clip, gradients), 4 apps shipping | 2026-05-16 |
| GFX11 W2 H/I/J | SMU mailbox via NBIO SMN, GFXHUB ctx-0 PT enabled, CP GFX ring programmed (gated, real-HW verified) | 2026-05-26 |

Detail on individual fixes lives in `git log`; the audit sweep is
catalogued in `docs/audit-checklist.md`.

---

## Active focus: GPU-accelerated rendering

**Goal:** stop being CPU-bound for redraws. Today every visible
pixel is `rep movsq` from a backbuffer into the framebuffer, on the
BSP, on every flip.

Three tiers of work, ordered by effort and risk:

### Tier 1 — Faster CPU paths (1-3 weeks, low risk)
- SSE2/AVX2 memcpy for `display_flip` (currently scalar `movsq`).
- Dirty-rect tracking so we don't blit the whole screen each frame.
  Window manager already knows which windows moved.
- Offload `display_flip` to an AP core (SMP path is up; PAT already
  propagates). BSP returns to interactive work while the AP blits.

Expected: 2–5× on top of the WC win we already have. No new
firmware, no new microcontrollers, no PSP front-door.

### Tier 2 — DCN flip queue (4-8 weeks, medium risk)
- Page-flip via the display controller instead of CPU copy. Still
  the display block (not GFX), but takes the CPU off the critical
  path entirely.
- Requires programming a small subset of DCN HUBP / OPP / MPC
  registers and double-buffering the scanout pointer.
- DOES interact with DMUB for power transitions — Tier 2 is the
  most likely reason to un-park DMUB.

### Tier 3 — GFX11 (GC 11.5) bring-up (months, high risk)
- This is what "actual iGPU rendering" requires.
- Stack: PSP front-door → GMC/MMHUB page tables → MEC/RLC firmware
  load → CP ring queues (GFX, compute, SDMA) → MES scheduler → PM4
  packet emission → optional userspace stack.
- Not scoped or started. Cost is large; absent a userspace 3D layer
  we'd still be hand-writing PM4 packets to draw triangles.

**No decision yet on which tier to pursue first.** Tier 1 is the
clear next move unless the user has a specific reason to skip ahead.

---

## Parked

### DMUB / DCN firmware bring-up
**Where:** branch `dev`, latest commit `334e84f` (DMUB: ship
DCN3.5/3.1.4 firmware + read-only blob parser). Not merged to
master.

**State at park:**
- Phase 1 (read-only blob parse) shipped but reports `FW stat=01`
  ("not found") on hardware despite `DCN35DMC.BIN` being in
  `DATA.IMG` — fat16 init-order bug or root-cache miss, unresolved.
- CW4 mailbox programmed at VRAM `0x64000000`/`0x64002000`, rings
  alive, but firmware in deep IPS — `cmd stat=00000005` (sent +
  timeout, command never consumed). IPS-exit handshake via CW6
  shared_state not implemented.

**Why parked:** DMCUB is a power/PSR/backlight microcontroller. It
does not draw pixels. Even full Phase 2/3 success would not move
the project closer to "iGPU renders things." See
`memory/dmub_parked.md` for the resume plan.

**When to resume:** if backlight control, PSR, or panel hotplug
become priorities, or if Tier-2 DCN flip queue requires DMUB power
coordination.

### Battery / EC brightness probe
- Layout D AC verified, battery_init wiring fixed earlier in May.
- EC[0x2E] was identified as a candidate brightness register but
  not pursued — backlight on this panel appears to be DMUB-only.
- See `memory/amd_dcn_bar0_uc.md`.

---

## Architecture at a glance

```
Boot:    MBR (BIOS) | BOOTX64.EFI (UEFI)
            ↓
         KERNEL.BIN @ 0x100000
            ↓
Init:    GDT/IDT → paging → PIC/APIC → ACPI → SMP AP bring-up
            ↓
Drivers: GOP/VBE display → keyboard/mouse → xHCI/USB → I2C HID
         → PCI scan → ATA/ramdisk → FAT16 → networking (rtl8156)
            ↓
Userland: window manager, taskbar, NexusHL apps (.nxh)
```

- Kernel: 0x100000 (code+data), stack/IDT at 0x200000
- Page tables: 0x70000 (1GB pages on UEFI, 2MB on BIOS)
- Ramdisk / FAT16 cache: 0xD11000 (BIOS) / 0x1A11000 (UEFI)
- Framebuffer: GOP-supplied, mapped WC via PAT slot 1
- DMCUB FW buffer (parked): 0x7000000

Full source layout in `docs/source-layout.md`.

---

## Open invariants worth not forgetting

- All async polling that runs every frame must be non-blocking state
  machines, not busy waits. The original I2C HID poll cost 100ms/frame
  before this rule was enforced.
- CPU-loop timeouts on real Strix Point hardware fire ~5000× faster
  than QEMU. All timeouts should be PIT-tick based, never raw `ecx`
  counters. See xHCI fixes 2026-02-24.
- BAR0 MMIO must go through the explicit UC alias mapping — the GOP
  framebuffer is WC, and a stray read from a neighboring WC page
  hangs the AMD DCN.
- USB device protocol=0 mice are relative, not absolute. Treat them
  as such even if the HID parser doesn't fire.

---

## How to rebuild

```powershell
# UEFI (primary target)
powershell -ExecutionPolicy Bypass -File scripts\build\build_uefi.ps1

# BIOS (still maintained for QEMU CI smoke)
powershell -ExecutionPolicy Bypass -File scripts\build\build_bios.ps1

# Source guards + UEFI smoke
powershell -ExecutionPolicy Bypass -File scripts\test\test_source_guards.ps1
powershell -ExecutionPolicy Bypass -File scripts\test\test_smoke_uefi.ps1
```

Boot USB / ESP is `E:\`. Build copies artifacts to
`E:\EFI\BOOT\{BOOTX64.EFI, KERNEL.BIN, APPS.BIN, DATA.IMG}` and
`E:\data.img`.
