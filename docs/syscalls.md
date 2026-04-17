# NexusOS Syscall ABI

This is the current ring-3 syscall surface exported by
`C:\Users\user\Documents\new\src\kernel\proc\syscall.asm` and wrapped by
`C:\Users\user\Documents\new\src\include\syscall_user.inc`.

## Calling convention

Use the x86-64 `syscall` instruction.

- `RAX`: syscall number
- `RDI`: arg0
- `RSI`: arg1
- `RDX`: arg2
- `R10`: arg3
- `R8`: arg4
- `R9`: arg5
- Return value: `RAX` when the syscall returns one

User apps should normally call the wrapper macros from
`C:\Users\user\Documents\new\src\include\syscall_user.inc` or the convenience
include `C:\Users\user\Documents\new\src\user\lib\nexus_app.inc`.

For the built-in apps and future external apps, the kernel now treats these
address classes differently:

- App slot arena: `APP_DATA_ADDR + slot * APP_SLOT_SIZE`
- Built-in user blob: `app_blob_start .. app_blob_end`
- Shared media scratch buffers used by the current built-ins:
  `APP_BMP_FILE_BUF` and `APP_PAINT_CANVAS_BUF`

Rejected pointer-bearing syscalls now return `-1` in `RAX`.

## Syscall table

`0` `SYS_PRINT`
- Args: `RDI = pointer to NUL-terminated string`
- Effect: print debug text
- Returns: `0` on success, `-1` on validation failure
- Validation: string must live in the app slot arena or built-in user blob

`1` `SYS_EXIT`
- Args: none
- Effect: return from usermode
- Returns: `0`

`2` `SYS_GUI_RECT`
- Args: `RDI=x`, `RSI=y`, `RDX=w`, `R10=h`, `R8=color`
- Effect: draw rectangle
- Returns: `0`

`3` `SYS_GUI_TEXT`
- Args: `RDI=x`, `RSI=y`, `RDX=string_ptr`, `R10=color`, `R8=scale_or_flags`
- Effect: draw text
- Returns: `0` on success, `-1` on validation failure
- Validation: string must live in the app slot arena or built-in user blob

`4` `SYS_FS_COUNT`
- Args: none
- Returns: file count in `RAX`

`5` `SYS_FS_ENTRY`
- Args: `RDI=index`
- Returns: opaque FAT16 entry handle in `RAX`

`6` `SYS_FS_CHDIR`
- Args: `RDI=directory_cluster_or_handle`
- Effect: change current directory
- Returns: filesystem result in `RAX`

`7` `SYS_WM_CREATE`
- Args: `RDI=x`, `RSI=y`, `RDX=w`, `R10=h`, `R8=title_ptr`, `R9=draw_handler`
- Returns: window id in `RAX`
- Validation: title must be an app-owned string; draw handler must be null or
  an app-owned code pointer

`8` `SYS_FS_READ`
- Args: `RDI=entry`, `RSI=buffer`, `RDX=buffer_size`
- Returns: bytes read in `RAX`
- Validation: `RDI` must be an opaque FAT16 entry handle from `SYS_FS_ENTRY`;
  destination buffer must live in app-owned memory or the shared media buffers

`9` `SYS_WM_HANDLERS`
- Args: `RDI=window_id`, `RSI=click_handler`, `RDX=key_handler`
- Returns: `0` on success, `-1` on validation failure
- Security rules:
- the kernel rejects `window_id >= MAX_WINDOWS` with an unsigned bounds check
- the kernel only accepts handler installs on active windows
- handler pointers must be null or app-owned code pointers

`10` `SYS_APP_DONE`
- Args: none
- Effect: explicit return path from ring-3 app trampoline

`11` `SYS_FS_FORMAT_NAME`
- Args: `RDI=src_ptr`, `RSI=dst_ptr`
- Effect: format a FAT16 name
- Returns: `0` on success, `-1` on validation failure
- Validation: source must be an opaque FAT16 entry handle; destination must be
  an app-owned writable buffer

`12` `SYS_APP_LAUNCH`
- Args: `RDI=entry_or_app_id`
- Returns: launcher-specific result in `RAX`

`13` `SYS_FS_WRITE`
- Args: `RDI=entry`, `RSI=buffer`, `RDX=buffer_size`
- Returns: bytes written in `RAX`
- Validation: filename buffer must be an app-owned 11-byte FAT16 name; source
  buffer must live in app-owned memory or the shared media buffers

`14` `SYS_FS_SYNC_ROOT`
- Args: none
- Effect: flush FAT16 root state
- Returns: `0`

`15` `SYS_WM_CLOSE`
- Args: `RDI=window_id`
- Security rule: the kernel uses an unsigned bounds check, so negative ids do
  not underflow into the window pool
- Returns: `0`

`16` `SYS_DISPLAY_SET_MODE`
- Args: `RDI=width`, `RSI=height`, `RDX=bpp_or_mode`
- Returns: mode-switch result in `RAX`

`17` `SYS_CURSOR_INIT`
- Args: none
- Effect: initialize cursor state
- Returns: `0`

## Current hardening notes

- Syscall 9 no longer accepts out-of-range window ids and no longer installs
  handlers on inactive slots.
- Pointer-taking syscalls validate app-owned strings, buffers, callback
  pointers, and opaque FAT16 handles before calling kernel helpers.
- Window close uses unsigned validation for the same reason.
- The usermode callback return path depends on the runtime layout in
  `src/kernel/proc/usermode.asm`; if `L3_RT_SIZE` changes, keep the allocation
  in sync.

## Authoring rules for user apps

- Keep callback code under `src/user`.
- Include `nexus_app.inc` for the stable wrapper surface.
- Include `nexus_window.inc` when app code needs window offsets or app ids.
- Treat every kernel-facing pointer as privileged: only pass app-owned buffers
  and app-owned strings.
- Treat FAT16 entry pointers as opaque handles. They are kernel objects, not
  user-owned memory.
- Return from callbacks with `ret` unless you intentionally end the callback
  via `SYS_APP_DONE`.
