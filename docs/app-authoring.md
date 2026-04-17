# NexusOS App Authoring

This repo is still shipping built-in apps inside the monolithic kernel image,
but the source tree now treats user-facing code as a separate layer under
`C:\Users\user\Documents\new\src\user`.

## What belongs in `src/user`

- Built-in ring-3 app logic
- callback implementations for draw, click, and key handling
- user-facing experiments and regression probes
- small app-side helper includes and templates

## Minimum app surface

Start from:

- `C:\Users\user\Documents\new\src\user\lib\nexus_app.inc`
- `C:\Users\user\Documents\new\src\user\lib\nexus_window.inc`
- `C:\Users\user\Documents\new\src\user\templates\hello_callback.asm`

`nexus_app.inc` gives you:

- shared constants
- syscall wrapper macros
- the callback ABI notes in one place

`nexus_window.inc` gives you:

- window-struct offsets used by current callbacks
- built-in app ids
- shared scratch-buffer constants used by the current built-ins

## Callback ABI

Handlers run in ring 3 through the trampoline in
`C:\Users\user\Documents\new\src\kernel\proc\usermode.asm`.

- Draw handler:
  `RDI` points to the shadow window struct in the app slot arena.
- Click handler:
  `RDI` is the shadow window pointer, `RSI` is mouse X, `RDX` is mouse Y.
- Key handler:
  `RDI` is the shadow window pointer, `RSI` is the key value.

The window pointer is a shadow copy, not the live kernel window object. That is
intentional. User apps should treat it as read-mostly metadata and avoid
assuming kernel-only fields are writable.

## Recommended workflow

1. Add or edit app code under `src/user`.
2. Keep kernel-facing interfaces behind wrapper includes instead of hardcoding
   raw syscall numbers in app files.
3. Run `powershell -ExecutionPolicy Bypass -File .\test_verify_all.ps1`
4. If the smoke gate fails, inspect
   `C:\Users\user\Documents\new\build\smoke_uefi_serial.log`

## Near-term design rule

Even before apps become independently loadable binaries, write them as if they
already are:

- no direct references to kernel-only files
- no reliance on kernel virtual addresses
- no raw pokes into internal window-pool layout
- keep app-side helpers inside `src/user`

That keeps the path open for a future assembly-based HLL or app packer without
another big tree rewrite.

For the proposed external binary format and loader contract, see
`C:\Users\user\Documents\new\docs\app-loader-format.md`.
