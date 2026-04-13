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
