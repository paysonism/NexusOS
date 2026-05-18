; ============================================================================
; NexusOS v3.0 - Application Framework + Built-in Apps
; Split into per-app/source includes to keep userland code maintainable while
; preserving the monolithic kernel build.
; ============================================================================

%include "trace.inc"

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

; Redirect direct kernel render calls to local syscall wrappers so that
; when the blob is copied to a user slot and runs in Ring 3, all relative
; calls stay within the blob (correct rel32) and use the syscall ABI.
%define render_rect  app_sys_render_rect
%define render_text  app_sys_render_text

global app_blob_start
app_blob_start:
; 16-byte sentinel so a post-build extraction can locate this blob inside
; kernel.bin without needing NASM symbol maps.
db 0x4E, 0x58, 0x41, 0x50, 0x50, 0x42, 0x4C, 0x4F    ; "NXAPPBLO"
db 0x42, 0x53, 0x54, 0x52, 0x54, 0xDE, 0xAD, 0xBE    ; "BSTRT" + 0xDEADBE
global app_l3_done_trampoline
app_l3_done_trampoline:
    mov eax, 10
    syscall
    ud2
%include "src/user/apps/common.inc"
; state.inc must come BEFORE any large code blob: every symbol it defines
; (notepad_buf, np_line_len, …) is accessed slot-relative as
; `slot_base + (sym - app_blob_start)`, so the offset MUST fit within
; APP_SLOT_SIZE (1 MB) AND L3_APP_BLOB_COPY_CAP. Pushed below the >1 MB of
; generated NexusHL code it overflows the slot and every notepad ends up
; aliasing into the next slot's memory.
%include "src/user/apps/state.inc"
%include "src/user/apps/launch.inc"
; explorer.inc deleted — Explorer is now a pure-NexusHL app built by
; build_nxh.ps1 and included via build/nxh/generated_apps.inc below.
%include "src/user/apps/terminal.inc"
%define DISABLE_FN_RUNTIME_TRACE
%include "build/nxh/generated_apps.inc"
%undef DISABLE_FN_RUNTIME_TRACE
; about.inc deleted — About is now a pure-NexusHL app built by build_nxh.ps1
; and included via build/nxh/generated_apps.inc above.
%include "src/user/apps/shell.inc"
; paint.inc deleted — Paint is now a pure-NexusHL app built by build_nxh.ps1
; and included via build/nxh/generated_apps.inc above.
%include "src/user/apps/security_probe.inc"
; End sentinel (16 bytes, distinct from start marker).
db 0x4E, 0x58, 0x41, 0x50, 0x50, 0x42, 0x4C, 0x4F    ; "NXAPPBLO"
db 0x42, 0x45, 0x4E, 0x44, 0x21, 0xCA, 0xFE, 0xBE    ; "BEND!" + 0xCAFEBE
global app_blob_end
app_blob_end:
section .text
