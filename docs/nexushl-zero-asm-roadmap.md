# NexusHL Zero-Asm Roadmap

Goal: all maintained OS code should be expressible in NexusHL/NexusHLK without
source-level `asm {}` escape blocks.

## Non-negotiable Rules

- New migrated modules should compile with `nxhc.py --forbid-asm`.
- Security-critical modules should also compile with `--deny-unsafe` unless
  they are a deliberately audited hardware/boot boundary.
- Boot-target modules compile with `--target boot`, which forbids inline asm by
  default.
- Privileged operations must be named intrinsics, not arbitrary text. Examples:
  `write_cr0`, `write_cr4`, `lgdt`, `lidt`, `ltr`, `intn`, `inb`, and `outb`.
- Dangerous primitives require explicit source declarations such as
  `unsafe boot_int;`, `unsafe boot_io;`, `unsafe kernel_priv;`, or
  `unsafe raw_mem;`. `--deny-unsafe` rejects those declarations.
- Unsupported execution modes must fail closed. The boot target now emits
  structured 16/32/64-bit functions for the safe subset covered by tests.

## Progress

- 2026-06-03: First production-representative **boot** leaf migrated —
  `src/boot/nxh/a20_wait.nxh` (A20 port-I/O: 8042 polls + fast-A20 enable).
  Compiles under `--target boot --forbid-asm`, rejected by `--deny-unsafe`
  (declared `unsafe boot_io` I/O boundary), NASM-assembles. Gated in
  `scripts/test/test_nxhc_security.ps1`. Not yet wired into the live boot
  (rest of `a20.asm` needs segment-override memory access). The live UEFI
  loader + BIOS path also had every in-code magic literal named into
  `src/include/uefi_abi.inc` + `bios_boot.inc` (byte-identical; see
  `docs/maintainability-todo.md` §2 note 3). Full module-by-module conversion
  order and the compiler-feature ladder are in `docs/nexushl-boot-conversion.md`.

## Compiler Track

1. Keep `--forbid-asm` green for all new NexusHLK modules.
2. Replace existing asm-shim clusters with explicit-register functions and
   named intrinsics.
3. Grow first-class boot codegen beyond the current safe subset:
   far mode-switch paths, PE/COFF headers, relocation tables, disk-address
   packet declarations, and richer typed data records.
4. Convert boot files module-by-module with byte or deterministic serial parity
   tests before deleting the source assembly.
5. Make `--forbid-asm` the default for `--target kernel` after legacy modules
   have migrated. Keep an explicit legacy escape flag only for archaeology.

## Verification Track

- Compile gates:
  `scripts/test/test_nxhc_security.ps1` covers zero-asm enforcement, boot layout
  emission, low-level intrinsic compilation, structured real-mode functions,
  unsafe-capability rejection, and a NASM-assembled 512-byte boot sector ending
  in `55 AA`.
- Migration gates:
  each converted module should have either byte-identical output where layout is
  fixed, or deterministic serial behavior comparison where instruction identity
  is intentionally allowed to change.
- Security review:
  new intrinsics must be narrow, argument-checked, target-gated, and documented
  here before use in production boot/kernel modules.
