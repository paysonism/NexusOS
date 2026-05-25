# NexusOS Media Formats

This document defines the native image and video container formats used by
NexusOS, and the dispatch model used by the Media Player app and the
`media.nxh` library so that adding a new codec is a one-row change.

## Design goals

- **Direct blit.** Pixel payloads are 32 bpp BGRA so the kernel renderer can
  copy a scanline straight to `bb_addr` without per-pixel decode.
- **Fixed header.** Every codec starts with a 32-bit little-endian magic at
  offset 0 so probing is one `dword` compare.
- **Same shape as existing assets.** Icons (`.NIC`) and the boot animation
  (`.NBA`) already follow these rules; the Media Player just exposes them as
  user-openable file types instead of build-time `incbin`s.
- **Extensible.** Adding a format = append one row to the codec dispatch
  table in `src/kernel/gui/media_viewer.asm` and (for header parsing in
  user-mode tools) one row to the table in `src/user/nexushl/lib/media.nxh`.

## NIC1 — NexusOS Image (static)

Used today by `src/resources/design-system/icons/*.nic` and by Media Player
for any single-frame image.

| Offset | Size | Field        | Notes                                      |
|-------:|-----:|--------------|--------------------------------------------|
| 0      | 4    | magic        | `'NIC1'` = `0x3143494E` little-endian      |
| 4      | 2    | width        | uint16, pixels                             |
| 6      | 2    | height       | uint16, pixels                             |
| 8      | 1    | bpp          | 32 (only supported value)                  |
| 9      | 7    | reserved     | zero-filled                                |
| 16     | w·h·4| pixels       | row-major top-down BGRA, alpha 0 = skip    |

Renderer: see `nx_media_blit_nic` (kernel) and `nx_icon_blit` (existing
binary-alpha blitter that this reuses).

## NBA1 — NexusOS Animation (video)

Used today by `/BOOTANIM.NBA`. Frame sequence, no audio. Frames are
top-down BGRA, identical pitch to NIC1.

| Offset | Size       | Field        | Notes                              |
|-------:|-----------:|--------------|------------------------------------|
| 0      | 4          | magic        | `'NBA1'` = `0x3141424E`           |
| 4      | 4          | width        | uint32 pixels                      |
| 8      | 4          | height       | uint32 pixels                      |
| 12     | 4          | frame_count  | uint32                             |
| 16     | 4          | fps          | uint32                             |
| 20     | w·h·4·N    | frames       | concatenated BGRA frames           |

Playback is driven by the global `tick_count` (100 Hz PIT). Frame index is
`(tick_count − play_start_tick) · fps / 100` modulo `frame_count` when
looping. Pause toggles `play_start_tick`/freezes `play_frame`.

## BMP fallback

The legacy `.BMP` 24bpp viewer lives in the same dispatch table for
back-compat. New native assets should use `NIC1` so the row-by-row
swap-and-pad work isn't repeated every redraw.

## Adding a new codec

1. **Pick a magic.** 4 ASCII bytes, suffix the format version (`NIM2`,
   `NRI1`, …).
2. **Document the layout here** under a new heading.
3. **Add the kernel blitter.** Write `nx_media_blit_<fmt>` in
   `src/kernel/gui/media_viewer.asm` matching the calling convention:
   - RDI = file buffer
   - RSI = window struct pointer
   - Renders pixels via direct `[bb_addr + y·pitch + x·4]` writes.
4. **Register the codec.** Append `dq <magic>, nx_media_blit_<fmt>` to
   `nx_media_codec_table` and bump `nx_media_codec_count`.
5. **Route the extension.** Add a 3-byte compare in `app_open_file`
   (`src/user/apps/launch.inc`) that jumps to
   `app_open_file_in_media`.
6. **(Optional)** Add a parser row to the user-mode table in
   `src/user/nexushl/lib/media.nxh` so `media.nxh` clients (e.g. an
   explorer thumbnail strip) can read header fields without involving the
   kernel renderer.

No other file should need editing.
