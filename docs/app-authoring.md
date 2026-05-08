# NexusOS App Authoring

This repo still ships built-in apps inside the monolithic kernel image, but
NexusHL is now the supported SDK path for app code that should be maintained
above raw assembly. The source tree treats user-facing code as a separate layer
under `C:\Users\user\Documents\new\src\user`.

## What belongs in `src/user`

- Built-in ring-3 app logic
- callback implementations for draw, click, and key handling
- user-facing experiments and regression probes
- small app-side helper includes and templates

## Minimum app surface

For new SDK-authored apps, start from:

- `C:\Users\user\Documents\new\src\user\nexushl\lib\core.nxh`
- `C:\Users\user\Documents\new\src\user\nexushl\apps\hello.nxh`
- `C:\Users\user\Documents\new\build_nxh.ps1`

`build_nxh.ps1` compiles all `.nxh` apps and generates
`C:\Users\user\Documents\new\build\nxh\generated_apps.inc`, which is included
by `src/user/apps.asm`.

For raw assembly app work, start from:

- `C:\Users\user\Documents\new\src\user\lib\nexus_app.inc`
- `C:\Users\user\Documents\new\src\user\lib\nexus_fs.inc`
- `C:\Users\user\Documents\new\src\user\lib\nexus_window.inc`
- `C:\Users\user\Documents\new\src\user\templates\hello_callback.asm`

`nexus_app.inc` gives you:

- shared constants
- syscall wrapper macros
- filesystem helper wiring
- the callback ABI notes in one place

`nexus_fs.inc` gives you:

- FAT16 directory-entry offsets safe for user apps to inspect
- `NFS_NAME83` / `nfs_name83` for converting typed names into the 11-byte,
  space-padded FAT 8.3 format used by create, rename, and mkdir syscalls

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

## Filesystem ABI

User apps should use the syscall surface rather than direct kernel FAT16 calls.
The supported operations are:

| Operation | Call |
|---|---|
| Count visible entries | `SYS_FS_COUNT` |
| Fetch entry handle/copy | `SYS_FS_ENTRY index` |
| Read file data | `SYS_FS_READ entry, buffer, buffer_size` |
| Write or create file | `SYS_FS_WRITE name83, buffer, byte_count` |
| Create directory | `SYS_FS_MKDIR name83` |
| Rename entry | `SYS_FS_RENAME entry, name83` |
| Delete file or empty directory | `SYS_FS_DELETE entry` |
| Change directory | `SYS_FS_CHDIR cluster_or_0` |

Directory entries returned by `SYS_FS_ENTRY` are opaque handles backed by a
slot-local copy. Apps can inspect the copied 32-byte entry for display, but
metadata changes must go through `SYS_FS_DELETE`, `SYS_FS_RENAME`, or
`SYS_FS_MKDIR` so the kernel updates the real current-directory cache and disk
state.

Example name conversion:

```asm
lea rdi, [name83_buf]
lea rsi, [typed_name]
call nfs_name83
SYS_FS_MKDIR name83_buf
```

Current FAT16 limits still apply: names are 8.3, entry handles are valid only
for the current directory view, and delete intentionally rejects non-empty
directories.

## Recommended workflow

1. Add or edit app code under `src/user`.
2. Keep kernel-facing interfaces behind wrapper includes instead of hardcoding
   raw syscall numbers in app files.
3. Run `powershell -ExecutionPolicy Bypass -File .\test_verify_all.ps1`
4. If the smoke gate fails, inspect
   `C:\Users\user\Documents\new\build\smoke_uefi_serial.log`

## Design Rule

Even before apps become independently loadable binaries, write them as if they
already are:

- no direct references to kernel-only files
- no reliance on kernel virtual addresses
- no raw pokes into internal window-pool layout
- keep app-side helpers inside `src/user`

That keeps the path open for a future external app packer without another big
tree rewrite.

For the proposed external binary format and loader contract, see
`C:\Users\user\Documents\new\docs\app-loader-format.md`.
