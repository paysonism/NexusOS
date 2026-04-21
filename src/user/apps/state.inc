section .data

; --- Window titles ---
szExplorerTitle db "File Explorer", 0
szTermTitle     db "Terminal", 0
szNotepadTitle  db "Notepad", 0
szSettingsTitle db "Settings", 0
szAboutTitle    db "About NexusOS", 0

; --- Explorer strings ---
szPathRoot      db "C:\", 0
szPathDocs      db "C:\Documents", 0
szPathPics      db "C:\Pictures", 0
szPathSys       db "C:\System", 0
szColName       db "Name", 0
szColSize       db "Size", 0
szDirLabel      db "<DIR>", 0
szStatusReady   db "Ready", 0

; --- Context menu strings ---
szCtxOpen       db "Open", 0
szCtxRename     db "Rename", 0
szCtxNewFolder  db "New Folder", 0
szCtxProperties db "Properties", 0
szRenameLabel   db "Rename:", 0
szNewFolderLabel db "New Folder:", 0
szNewFolderDone db "Folder Created!", 0

; --- Properties window strings ---
szPropTitle     db "Properties", 0
szPropName      db "Name:", 0
szPropType      db "Type:", 0
szPropSize      db "Size:", 0
szPropLoc       db "Path:", 0
szPropTypeFile  db "File", 0
szPropTypeDir   db "Folder", 0
szPropSizeDir   db "--", 0

prop_entry_ptr  dq 0            ; pointer to VFS entry being viewed

; --- Virtual Filesystem ---
; Each entry: 24 bytes name (null-padded) + 1 byte type (0=dir,1=file) + 7 bytes size string
; VFS_ENTRY_SIZE = 32

; Root directory (6 entries)
vfs_root:
    db "Documents",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0   ; 24 bytes name
    db 0                                              ; type=dir
    db 0,0,0,0,0,0,0                                 ; size (unused for dir)
    db "Pictures",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0   ; 24 bytes
    db 0
    db 0,0,0,0,0,0,0
    db "System",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; 24 bytes
    db 0
    db 0,0,0,0,0,0,0
    db "readme.txt",0,0,0,0,0,0,0,0,0,0,0,0,0,0     ; 24 bytes
    db 1                                              ; type=file
    db "1.2 KB",0                                     ; 7 bytes size
    db "config.sys",0,0,0,0,0,0,0,0,0,0,0,0,0,0     ; 24 bytes
    db 1
    db "256 B",0,0                                    ; 7 bytes
    db "nexus.log",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0    ; 24 bytes
    db 1
    db "4.8 KB",0                                     ; 7 bytes

; Documents subdirectory (4 entries)
vfs_docs:
    db "..",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  ; 24 bytes - go up
    db 0
    db 0,0,0,0,0,0,0
    db "notes.txt",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0    ; 24 bytes
    db 1
    db "3.1 KB",0
    db "todo.txt",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0   ; 24 bytes
    db 1
    db "512 B",0,0
    db "report.doc",0,0,0,0,0,0,0,0,0,0,0,0,0,0     ; 24 bytes
    db 1
    db "12 KB",0,0

; Pictures subdirectory (3 entries)
vfs_pics:
    db "..",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0
    db 0,0,0,0,0,0,0
    db "wallpaper.bmp",0,0,0,0,0,0,0,0,0,0,0         ; 24 bytes
    db 1
    db "2.3 MB",0
    db "photo.bmp",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0    ; 24 bytes
    db 1
    db "1.1 MB",0

; System subdirectory (4 entries)
vfs_sys:
    db "..",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0
    db 0,0,0,0,0,0,0
    db "kernel.bin",0,0,0,0,0,0,0,0,0,0,0,0,0,0     ; 24 bytes
    db 1
    db "64 KB",0,0
    db "boot.cfg",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0   ; 24 bytes
    db 1
    db "128 B",0,0
    db "drivers.sys",0,0,0,0,0,0,0,0,0,0,0,0,0      ; 24 bytes
    db 1
    db "32 KB",0,0

; --- Explorer state ---
explorer_sel    dd 0
explorer_dir    dd 0
explorer_cur_entry dq 0          ; temp: current dir entry pointer during draw
explorer_cur_idx   dd 0          ; temp: current draw index

; File open state
np_open_entry   dq 0             ; FAT16 dir entry of last opened file

; Context menu state
ctx_menu_visible db 0
ctx_menu_x      dd 0
ctx_menu_y      dd 0

; Rename mode state
exp_rename_active  db 0
exp_rename_cursor  dd 0

; New folder mode state
exp_newfolder_active  db 0
exp_newfolder_cursor  dd 0
exp_newfolder_done_msg db 0
term_ls_buf      times 512 db 0
term_debug_buf   times 1024 db 0
term_echo_buf    times 128 db 0

; --- Terminal strings ---
szTermWelcome   db "NexusOS Terminal v3.0", 0
szTermVer       db "Type 'help' for commands", 0
szTermHelpHint  db "----------------------------", 0
szTermPrompt    db "C:\> ", 0
szCursor        db "_", 0
szCmdUnknown    db "  Unknown command. Type help.", 0
szCmdHelpOut    db "  help cd dir ver cls debug restart exit", 0
szCmdVerOut     db "  NexusOS v3.0 (x86-64)", 0
szCmdDirOut     db "  Documents  Pictures  System", 0
szCmdCdErr      db "  Directory not found.", 0
szEmptyDir      db "(empty)", 0
szCmdCd         db "cd ", 0
szCmdDir        db "dir", 0
szCmdLs         db "ls", 0
szPathSub       db "C:\...", 0
szBackBtn       db "[Up]", 0

; Terminal state
term_cursor     dd 0
term_hist_count dd 0
term_draw_lines dd 0
term_hist_ptrs: times TERM_MAX_HIST dq 0

; --- Notepad strings ---
szNoteMenuFile  db "File", 0
szNoteMenuEdit  db "Edit", 0
szNotePlaceholder db "Start typing...", 0
szFileNew       db "New", 0
szFileSave      db "Save", 0
szFileClose     db "Close", 0
szEditSelAll    db "Select All", 0
szEditClear     db "Clear All", 0
szFileContent   db "Sample file content.", 0
szSaveAsTitle   db "Save As", 0
szSaveAsFilename db "Filename:", 0
szSaveAsHint    db "Enter=Save  Esc=Cancel", 0

; Notepad state
np_cursor_row   dd 0
np_cursor_col   dd 0
np_num_lines    dd 1
np_scroll_top   dd 0
np_menu_open    db 0            ; 0=closed, 1=File, 2=Edit
np_has_saved    db 0            ; 1 if file has been saved
np_save_done_msg db 0           ; 1 = show "Saved!" overlay
np_save_dialog  db 0            ; 1 = save-as dialog is showing
np_saveas_cursor dd 0
np_saved_num_lines dd 0
np_save_total_bytes dd 0

; BMP viewer state
bmp_width       dd 0
bmp_height      dd 0
bmp_data_offset dd 0
bmp_bpp         dd 0
szSavedMsg      db "Saved!", 0
szL3DrawOk      db "L3 draw ok", 0
szL3ClickOk     db "L3 click ok", 0
szL3KeyOk       db "L3 key ok", 0
szL3T0          db "L3T0", 0
szL3T4          db "L3T4", 0
szL3T5          db "L3T5", 0
szL3T6          db "L3T6", 0
szL3T8          db "L3T8", 0
szL3T11         db "L3T11", 0
szL3T13         db "L3T13", 0
szL3T14         db "L3T14", 0
szL3T7          db "L3T7", 0
szL3T9          db "L3T9", 0
szL3T12         db "L3T12", 0
szL3T15         db "L3T15", 0
szL3T16         db "L3T16", 0
szL3T17         db "L3T17", 0
szL3WndTitle    db "L3TEST", 0
szL3Tmp83       db "L3TEST  TXT"
szL3TmpData     db "L3OK"

; --- Settings strings ---
szSetDisplay    db "Display", 0
szSetRes        db "Resolution:", 0
szSetBpp        db "Color Depth: 32-bit", 0
szSetMemory     db "Memory", 0
szSetMem512     db "Total RAM: 512 MB", 0
szSetKernel     db "Kernel", 0
szSetArch       db "Architecture: x86-64", 0
szSetBoot       db "Boot Mode: BIOS (Legacy)", 0
szSetVSync      db "VSync", 0
szSetFPS        db "Show FPS", 0
szRes800        db "800x600", 0
szRes1024       db "1024x768", 0
szRes1280       db "1280x720", 0
szRes1920       db "1920x1080", 0

extern vsync_enabled
extern fps_show
extern display_set_mode
extern cursor_init
extern scr_width
extern scr_height


; --- About strings ---
szIconN         db "N", 0
szAboutName     db "NexusOS", 0
szAboutVer      db "Version 3.0", 0
szAboutArch     db "x86-64 Assembly Kernel", 0
szAboutDesc     db "A graphical desktop OS", 0
szAboutCopy     db "(c) 2026 NexusOS Project", 0

; Paint strings
szPaintTitle db "Paint", 0
paint_filename_83 db "PAINT   BMP"
paint_palette_colors:
    dd 0xFF000000 ; Black
    dd 0xFFFFFFFF ; White
    dd 0xFFFF0000 ; Red
    dd 0xFF00FF00 ; Green
    dd 0xFF0000FF ; Blue
    dd 0xFFFFFF00 ; Yellow
    dd 0xFF00FFFF ; Cyan
    dd 0xFFFF00FF ; Magenta

; Paint state
paint_save_active db 0
paint_save_buf times 16 db 0
paint_save_len dd 0
szExtBmp db ".BMP", 0
paint_color dd 0xFF000000
paint_brush_size dd 2

; Terminal command strings
szCmdHelp db "help", 0
szCmdVer  db "ver", 0
szCmdCls  db "cls", 0
szCmdTime db "time", 0
szCmdEcho db "echo", 0
szCmdClear db "clear", 0
szCmdExit db "exit", 0
szCmdPwd  db "pwd", 0
szCmdDate db "date", 0
szCmdDebug db "debug", 0
szCmdXDebug db "xdebug", 0
szCmdRestart db "restart", 0
szCmdReboot db "reboot", 0
szCmdUsb db "usb", 0
szCmdMouse db "mouse", 0
szCmdTouchpad db "touchpad", 0
szCmdIdebug db "idebug", 0

section .text
align 8
term_input:        times 64 db 0
notepad_buf:       times NP_BUF_SIZE db 0
np_line_len:       times (NP_MAX_LINES*4) db 0
np_saved_content:  times NP_BUF_SIZE db 0
np_saved_line_len: times (NP_MAX_LINES*4) db 0
fat16_name_buf:    times 16 db 0
fat16_size_buf:    times 20 db 0
exp_rename_buf:    times 24 db 0
exp_newfolder_buf: times 24 db 0
np_saveas_buf:     times 24 db 0
np_saveas_83:      times 12 db 0
section .text
