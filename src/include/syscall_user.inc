%ifndef SYSCALL_USER_INC
%define SYSCALL_USER_INC

; ============================================================================
; NexusOS v3.0 - Usermode Syscall Wrappers
; ============================================================================

%macro SYS_PRINT 1
    mov rax, 0
    mov rdi, %1
    syscall
%endmacro

%macro SYS_EXIT 0
    mov rax, 1
    syscall
%endmacro

%macro SYS_GUI_RECT 5
    mov rax, 2
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    mov r10, %4
    mov r8, %5
    syscall
%endmacro

%macro SYS_GUI_TEXT 5
    mov rax, 3
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    mov r10, %4
    mov r8, %5
    syscall
%endmacro

%macro SYS_FS_COUNT 0
    mov rax, 4
    syscall
%endmacro

%macro SYS_FS_ENTRY 1
    mov rax, 5
    mov rdi, %1
    syscall
%endmacro

%macro SYS_APP_DONE 0
    mov rax, 10
    syscall
%endmacro

%macro SYS_FS_CHDIR 1
    mov rax, 6
    mov rdi, %1
    syscall
%endmacro

%macro SYS_WM_CREATE 6
    mov rax, 7
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    mov r10, %4
    mov r8, %5
    mov r9, %6
    syscall
%endmacro

%macro SYS_FS_READ 3
    mov rax, 8
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    syscall
%endmacro

%macro SYS_WM_HANDLERS 3
    mov rax, 9
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    syscall
%endmacro

%macro SYS_FS_FORMAT_NAME 2
    mov rax, 11
    mov rdi, %1
    mov rsi, %2
    syscall
%endmacro

%macro SYS_APP_LAUNCH 1
    mov rax, 12
    mov rdi, %1
    syscall
%endmacro

%macro SYS_FS_WRITE 3
    mov rax, 13
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    syscall
%endmacro

%macro SYS_FS_SYNC_ROOT 0
    mov rax, 14
    syscall
%endmacro

%macro SYS_WM_CLOSE 1
    mov rax, 15
    mov rdi, %1
    syscall
%endmacro

%macro SYS_DISPLAY_SET_MODE 3
    mov rax, 16
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    syscall
%endmacro

%macro SYS_CURSOR_INIT 0
    mov rax, 17
    syscall
%endmacro

%macro SYS_TICKS 0
    mov rax, 18
    syscall
%endmacro

%macro SYS_FS_DELETE 1
    mov rax, 19
    mov rdi, %1
    syscall
%endmacro

%macro SYS_FS_RENAME 2
    mov rax, 20
    mov rdi, %1
    mov rsi, %2
    syscall
%endmacro

%macro SYS_FS_MKDIR 1
    mov rax, 21
    mov rdi, %1
    syscall
%endmacro

; SYS_OPEN_FILE_NP(dir_entry_handle) — kernel-side: launch notepad and load file
;   rdi = slot-cached dir entry pointer (from SYS_FS_ENTRY)
;   returns rax = notepad window id, or -1
%macro SYS_OPEN_FILE_NP 1
    mov rax, 22
    mov rdi, %1
    syscall
%endmacro

; SYS_APP_OPEN(command_line)
;   command_line format: "app" or "app param1,param2"
;   returns rax = launched window id, or -1
%macro SYS_APP_OPEN 1
    mov rax, 23
    mov rdi, %1
    syscall
%endmacro

; SYS_DISPLAY_FLAGS()
;   returns bit0=VSync, bit1=FPS overlay, bit2=Stretch.
;   Stretch is plumbed today; display_flip will honor it once the
;   compositor scaler lands. Persisting it through this syscall lets
;   Settings expose the toggle ahead of the scaler work.
%macro SYS_DISPLAY_FLAGS 0
    mov rax, 24
    syscall
%endmacro

; SYS_DISPLAY_SET_FLAGS(flags)
;   bit0=VSync, bit1=FPS overlay, bit2=Stretch. See SYS_DISPLAY_FLAGS.
%macro SYS_DISPLAY_SET_FLAGS 1
    mov rax, 25
    mov rdi, %1
    syscall
%endmacro

; SYS_DESKTOP_BG()
;   returns current desktop background theme id:
;     0=liquid metal, 1=glass ribbons, 2=frosted bloom
%macro SYS_DESKTOP_BG 0
    mov rax, 26
    syscall
%endmacro

; SYS_DESKTOP_SET_BG(theme)
;   theme: 0=liquid metal, 1=glass ribbons, 2=frosted bloom
%macro SYS_DESKTOP_SET_BG 1
    mov rax, 27
    mov rdi, %1
    syscall
%endmacro

; SYS_DISPLAY_NATIVE()
;   returns the monitor's native (boot-time) framebuffer dimensions packed
;   as: width in bits[31:0], height in bits[63:32]. This is the size the
;   UEFI loader picked from GOP — display_set_mode can change scr_width /
;   scr_height after boot, but the value returned here never moves, so it
;   is the right thing to offer as "Use native resolution".
%macro SYS_DISPLAY_NATIVE 0
    mov rax, 28
    syscall
%endmacro

; SYS_DISPLAY_SIZE()
;   returns the current desktop size, same packing as SYS_DISPLAY_NATIVE.
;   Drifts when display_set_mode succeeds; reads should be per-draw.
%macro SYS_DISPLAY_SIZE 0
    mov rax, 29
    syscall
%endmacro

; SYS_XML_PARSE(buf, len) -> rax = 1 ok, 0 err
%macro SYS_XML_PARSE 2
    mov rax, 30
    mov rdi, %1
    mov rsi, %2
    syscall
%endmacro

%macro SYS_XML_ROOT 0
    mov rax, 31
    syscall
%endmacro

%macro SYS_XML_TAG 1
    mov rax, 32
    mov rdi, %1
    syscall
%endmacro

%macro SYS_XML_TAG_NAME 3
    mov rax, 33
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    syscall
%endmacro

%macro SYS_XML_FIRST_CHILD 1
    mov rax, 34
    mov rdi, %1
    syscall
%endmacro

%macro SYS_XML_NEXT_SIBLING 1
    mov rax, 35
    mov rdi, %1
    syscall
%endmacro

%macro SYS_XML_PARENT 1
    mov rax, 36
    mov rdi, %1
    syscall
%endmacro

%macro SYS_XML_ATTR 5
    mov rax, 37
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    mov r10, %4
    mov r8,  %5
    syscall
%endmacro

%macro SYS_XML_TEXT 3
    mov rax, 38
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    syscall
%endmacro

%macro SYS_XML_FREE 0
    mov rax, 39
    syscall
%endmacro

; SYS_DRAW_LINE(x0,y0,x1,y1,color)
%macro SYS_DRAW_LINE 5
    mov rax, 40
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    mov r10, %4
    mov r8,  %5
    syscall
%endmacro

; SYS_FILL_CIRCLE(cx,cy,r,color)
%macro SYS_FILL_CIRCLE 4
    mov rax, 41
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    mov r10, %4
    syscall
%endmacro

; SYS_FILL_TRIANGLE(coords_ptr, color) — coords_ptr -> 6 int32 [x0,y0,x1,y1,x2,y2]
%macro SYS_FILL_TRIANGLE 2
    mov rax, 42
    mov rdi, %1
    mov rsi, %2
    syscall
%endmacro

; SYS_XML_LAST_ERROR() -> rax bits[31:0]=error, bits[63:32]=byte offset
%macro SYS_XML_LAST_ERROR 0
    mov rax, 43
    syscall
%endmacro

; SYS_XML_NODE_COUNT() -> rax = total parsed DOM nodes
%macro SYS_XML_NODE_COUNT 0
    mov rax, 44
    syscall
%endmacro

; SYS_BLEND_PIXEL(x, y, argb)
%macro SYS_BLEND_PIXEL 3
    mov rax, 45
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    syscall
%endmacro

; SYS_BLEND_SPAN(x, y, len, argb)
%macro SYS_BLEND_SPAN 4
    mov rax, 46
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    mov r10, %4
    syscall
%endmacro

; SYS_XML_TEXT_RUNS(node) -> rax = mixed-content text run count
%macro SYS_XML_TEXT_RUNS 1
    mov rax, 47
    mov rdi, %1
    syscall
%endmacro

; SYS_XML_TEXT_RUN(node, index, out, max) -> rax = bytes copied
%macro SYS_XML_TEXT_RUN 4
    mov rax, 48
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    mov r10, %4
    syscall
%endmacro

; SYS_XML_NAMESPACE(node, prefix, prefix_len, out, max) -> rax = URI length
%macro SYS_XML_NAMESPACE 5
    mov rax, 49
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    mov r10, %4
    mov r8,  %5
    syscall
%endmacro

; SYS_XML_NODE_NAMESPACE(node, out, max) -> rax = URI length
%macro SYS_XML_NODE_NAMESPACE 3
    mov rax, 50
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    syscall
%endmacro

; SYS_XML_ENTITY_VALUE(name, name_len, out, max) -> rax = bytes copied
%macro SYS_XML_ENTITY_VALUE 4
    mov rax, 51
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    mov r10, %4
    syscall
%endmacro

; SYS_BLEND_SPAN_ARGB(x, y, len, buf)
%macro SYS_BLEND_SPAN_ARGB 4
    mov rax, 52
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    mov r10, %4
    syscall
%endmacro

; SYS_BLEND_SPAN_ARGB_SCREEN(x, y, len, buf)
%macro SYS_BLEND_SPAN_ARGB_SCREEN 4
    mov rax, 53
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    mov r10, %4
    syscall
%endmacro

; SYS_BLEND_SPAN_ARGB_MULTIPLY(x, y, len, buf)
%macro SYS_BLEND_SPAN_ARGB_MULTIPLY 4
    mov rax, 54
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    mov r10, %4
    syscall
%endmacro

; SYS_SYSINFO(selector, arg)
%macro SYS_SYSINFO 2
    mov rax, 55
    mov rdi, %1
    mov rsi, %2
    syscall
%endmacro

; SYS_NET_PING4(ip)
;   ip = A.B.C.D packed into a 32-bit scalar (8.8.8.8 => 0x08080808)
;   returns approximate RTT in ms, or -1 after a 2s timeout/failure.
%macro SYS_NET_PING4 1
    mov rax, 56
    mov rdi, %1
    syscall
%endmacro

; SYS_NET_TCP_CONNECT4(ip, dst_port, src_port)
;   ip = A.B.C.D packed into a 32-bit scalar
;   returns 1 if a TCP SYN was sent, 0 on network failure, -2 if busy.
%macro SYS_NET_TCP_CONNECT4 3
    mov rax, 60
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    syscall
%endmacro

; SYS_NET_DNS_A(hostname)
;   hostname = app-owned C-string such as "example.com"
;   returns IPv4 A.B.C.D packed into a 32-bit scalar, 0 on lookup failure,
;   -1 for invalid arguments, or -2 if another DNS query is in flight.
%macro SYS_NET_DNS_A 1
    mov rax, 61
    mov rdi, %1
    syscall
%endmacro

; SYS_NET_PING4_TICK(ip)
;   Async, non-blocking ICMP echo. Call repeatedly each frame until the
;   return value is non-zero. The kernel runs the ARP+ICMP state machine
;   one short step per call, so the GUI keeps drawing in between.
;   returns:
;     > 0  -> RTT in microseconds (one echo completed)
;     0    -> still in flight, call again next frame
;     -1   -> timeout / no link / send failed
;     -2   -> a ping with a different target is still in flight
%macro SYS_NET_PING4_TICK 1
    mov rax, 62
    mov rdi, %1
    syscall
%endmacro

; SYS_DESKTOP_BG_BUSY()
;   returns 1 while a selected wallpaper is invalid, rendering, or waiting to
;   be presented; 0 once the finished cache has been shown.
%macro SYS_DESKTOP_BG_BUSY 0
    mov rax, 63
    syscall
%endmacro

; SYS_OPEN_FILE_MEDIA(dir_entry_handle) — kernel-side: launch Media Player
;   and load the file's bytes into the new window's slot at
;   APP_SLOT_BMP_FILE_OFF. The Media Player draw fn (app_media_draw) probes
;   the file's magic on every frame and dispatches to the matching codec.
;   rdi = slot-cached dir entry pointer (from SYS_FS_ENTRY)
;   returns rax = media window id, or -1
%macro SYS_OPEN_FILE_MEDIA 1
    mov rax, 64
    mov rdi, %1
    syscall
%endmacro

; SYS_WM_SET_USER_ARG(win_id, value)
;   Writes a 64-bit opaque value into the target window's WIN_OFF_USER_ARG
;   field. Used by a window's *creator* to pass a small bit of context to a
;   freshly created window whose drawfn will run in a different app slot
;   (e.g. Explorer → Properties window: pass the file-row index).
%macro SYS_WM_SET_USER_ARG 2
    mov rax, 65
    mov rdi, %1
    mov rsi, %2
    syscall
%endmacro

%endif
