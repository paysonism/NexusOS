; ============================================================================
; NexusOS v3.0 - Application Framework + Built-in Apps
; Split into per-app/source includes to keep userland code maintainable while
; preserving the monolithic kernel build.
; ============================================================================

; Neutralize extern/global so this file assembles both inside the monolithic
; kernel build AND as a standalone flat binary (APPS.BIN).
%ifmacro extern 1-*
%unmacro extern 1-*
%endif
%macro extern 1-*
%endmacro
%ifmacro global 1-*
%unmacro global 1-*
%endif
%macro global 1-*
%endmacro

%include "src/user/apps/common.inc"

global app_blob_start
app_blob_start:
; 16-byte sentinel so a post-build extraction can locate this blob inside
; kernel.bin without needing NASM symbol maps.
db 0x4E, 0x58, 0x41, 0x50, 0x50, 0x42, 0x4C, 0x4F    ; "NXAPPBLO"
db 0x42, 0x53, 0x54, 0x52, 0x54, 0xDE, 0xAD, 0xBE    ; "BSTRT" + 0xDEADBE
%include "src/user/apps/launch.inc"
%include "src/user/apps/explorer.inc"
%include "src/user/apps/terminal.inc"
%include "src/user/apps/notepad.inc"
%include "src/user/apps/settings.inc"
%include "src/user/apps/about.inc"
%include "src/user/apps/shell.inc"
%include "src/user/apps/paint.inc"
%include "src/user/apps/state.inc"
; End sentinel (16 bytes, distinct from start marker).
db 0x4E, 0x58, 0x41, 0x50, 0x50, 0x42, 0x4C, 0x4F    ; "NXAPPBLO"
db 0x42, 0x45, 0x4E, 0x44, 0x21, 0xCA, 0xFE, 0xBE    ; "BEND!" + 0xCAFEBE
global app_blob_end
app_blob_end:
section .text
