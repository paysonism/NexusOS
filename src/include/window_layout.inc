%ifndef WINDOW_LAYOUT_INC
%define WINDOW_LAYOUT_INC

; Window structure layout (256 bytes per window, qword fields):
;   0: ID          8: X           16: Y          24: Width
;  32: Height     40: Flags       48: Title (64 bytes inline)
; 112: draw_fn   120: key_fn     128: click_fn   136: app_data
; 144: drag_fn   152: right_click_fn

WIN_OFF_ID      equ 0
WIN_OFF_X       equ 8
WIN_OFF_Y       equ 16
WIN_OFF_W       equ 24
WIN_OFF_H       equ 32
WIN_OFF_FLAGS   equ 40
WIN_OFF_TITLE   equ 48
WIN_OFF_DRAWFN  equ 112
WIN_OFF_KEYFN   equ 120
WIN_OFF_CLICKFN equ 128
WIN_OFF_APPDATA equ 136
WIN_OFF_DRAGFN  equ 144
WIN_OFF_RCLICKFN equ 152
; 8-byte opaque value the owning app can stash via SYS_WM_SET_USER_ARG and
; read back from its drawfn/clickfn (which receive `win` as a pointer to the
; struct). Lets a creator pass small context to a freshly-created window
; whose drawfn runs in a *different* app slot.
WIN_OFF_USER_ARG equ 160

%endif
