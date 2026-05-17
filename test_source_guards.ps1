$ErrorActionPreference = 'Stop'

$Root = $PSScriptRoot

function Assert-Match {
    param(
        [string]$Path,
        [string]$Pattern,
        [string]$Message
    )

    $content = Get-Content -Path $Path -Raw
    if ($content -notmatch $Pattern) {
        throw $Message
    }
}

function Assert-NotMatch {
    param(
        [string]$Path,
        [string]$Pattern,
        [string]$Message
    )

    $content = Get-Content -Path $Path -Raw
    if ($content -match $Pattern) {
        throw $Message
    }
}

$syscallPath = Join-Path $Root 'src\kernel\proc\syscall.asm'
$syscallValidationPath = Join-Path $Root 'src\kernel\proc\syscall_validation.inc'
$syscallUserPath = Join-Path $Root 'src\include\syscall_user.inc'
$displayPath = Join-Path $Root 'src\kernel\drivers\display.asm'
$usermodePath = Join-Path $Root 'src\kernel\proc\usermode.asm'
$windowPath = Join-Path $Root 'src\kernel\gui\window.asm'
$corePath = Join-Path $Root 'src\kernel\core\main.asm'
$appsPath = Join-Path $Root 'build\nxh\explorer.asm'
$wrapperPath = Join-Path $Root 'src\user\apps.asm'
$launchPath = Join-Path $Root 'src\user\apps\launch.inc'
$pagingPath = Join-Path $Root 'src\boot\paging.asm'
$userWindowPath = Join-Path $Root 'src\user\lib\nexus_window.inc'
$paintPath = Join-Path $Root 'src\user\apps\paint.inc'
$nxhBuildPath = Join-Path $Root 'build_nxh.ps1'
$nxhNotepadPath = Join-Path $Root 'src\user\nexushl\apps\notepad.nxh'

Write-Host '[guards] Checking user/kernel structure...' -ForegroundColor Yellow
Assert-Match $wrapperPath 'src/user/apps/common\.inc' 'apps.asm must include the split user app tree.'
Assert-Match $wrapperPath 'build/nxh/generated_apps\.inc' 'apps.asm must include NexusHL generated app output.'
Assert-NotMatch $wrapperPath 'src/user/apps/notepad\.inc' 'Notepad must ship through the NexusHL SDK path, not the old hand-written include.'
Assert-Match $wrapperPath 'app_blob_start:' 'apps.asm must expose app_blob_start for syscall validation.'
Assert-Match $wrapperPath 'app_blob_end:' 'apps.asm must expose app_blob_end for syscall validation.'
Assert-Match $pagingPath 'mov eax, PAGE_PRESENT \| PAGE_WRITABLE \| PAGE_LARGE' 'Paging must map kernel memory supervisor-only by default.'
Assert-Match $pagingPath 'or eax, PAGE_USER' 'Paging must explicitly mark only the user app arena as user-accessible.'

Write-Host '[guards] Checking syscall hardening...' -ForegroundColor Yellow
Assert-Match $syscallPath 'syscall_validation\.inc' 'syscall.asm must include the syscall validation owner file.'
Assert-Match $syscallPath '\.sc_print:[\s\S]*call sc_validate_user_cstring' 'SYS_PRINT must validate user strings.'
Assert-Match $syscallPath '\.sc_gui_text:[\s\S]*call sc_validate_user_cstring' 'SYS_GUI_TEXT must validate user strings.'
Assert-Match $syscallPath '\.sc_wm_create:[\s\S]*call sc_validate_callback_target' 'SYS_WM_CREATE must validate callback targets.'
Assert-Match $syscallPath '\.sc_fs_read:[\s\S]*call sc_validate_dir_entry_handle' 'SYS_FS_READ must validate directory-entry handles.'
Assert-Match $syscallPath '\.sc_fs_write:[\s\S]*call sc_validate_user_io_range' 'SYS_FS_WRITE must validate user buffers.'
Assert-Match $syscallPath '\.sc_fs_delete:[\s\S]*call sc_validate_dir_entry_handle[\s\S]*call sc_dir_entry_handle_to_kernel[\s\S]*call fat16_delete_entry' 'SYS_FS_DELETE must validate opaque handles and mutate the kernel FAT16 cache.'
Assert-Match $syscallPath '\.sc_fs_rename:[\s\S]*call sc_validate_dir_entry_handle[\s\S]*call sc_validate_user_range[\s\S]*call fat16_rename_entry' 'SYS_FS_RENAME must validate handles and the 11-byte user name.'
Assert-Match $syscallPath '\.sc_fs_mkdir:[\s\S]*call sc_validate_user_range[\s\S]*call fat16_mkdir' 'SYS_FS_MKDIR must validate the 11-byte user name.'
Assert-Match $syscallPath '\.sc_app_open:[\s\S]*call sc_validate_user_cstring[\s\S]*call kernel_open_app_command' 'SYS_APP_OPEN must validate the user command string before launching apps.'
Assert-Match $syscallUserPath '%macro SYS_APP_OPEN 1[\s\S]*mov rax, 23[\s\S]*syscall' 'SYS_APP_OPEN user wrapper must call syscall 23.'
Assert-Match $syscallPath 'SC_VALIDATE_FRAME_OFF equ 64[\s\S]*\[rsp \+ SC_VALIDATE_FRAME_OFF \+ ALL_RDI\]' 'Table-driven syscall validation must read arg0 from the saved RDI slot through the helper call frame.'
Assert-Match $syscallPath '\.sc_wm_handlers:[\s\S]*cmp rdi, MAX_WINDOWS[\s\S]*jae \.sc_wm_handlers_reject' 'SYS_WM_HANDLERS must reject out-of-range window ids.'
Assert-Match $syscallPath '\.sc_wm_handlers:[\s\S]*call sc_validate_callback_target' 'SYS_WM_HANDLERS must validate handler targets.'
Assert-Match $syscallPath '\.sc_display_set_mode:[\s\S]*BOOT_BACK_BUFFER_SIZE / 4[\s\S]*\.sc_display_set_mode_reject' 'SYS_DISPLAY_SET_MODE must reject modes that exceed the boot back buffer.'
Assert-NotMatch $syscallPath 'APP_BMP_FILE_BUF|APP_CANVAS_BUF' 'Kernel syscall validation must not whitelist shared global app scratch buffers anymore.'
Assert-Match $syscallValidationPath 'sc_validate_user_range:[\s\S]*app_blob_base_v[\s\S]*app_blob_end_v' 'User range validation must allow current slot and built-in user blob.'
Assert-Match $syscallValidationPath 'sc_validate_dir_entry_handle:[\s\S]*L3_DIR_ENTRY_CACHE_OFF[\s\S]*DIR_ENTRY_SIZE' 'Directory entry handles must stay slot-local and aligned.'
Assert-Match $syscallValidationPath 'sc_validate_callback_target:[\s\S]*call sc_validate_user_range' 'Callback targets must validate through user range validation.'
Assert-Match $displayPath '(display_set_mode:|FN_BEGIN display_set_mode)[\s\S]*BOOT_BACK_BUFFER_SIZE / 4[\s\S]*\.set_fail' 'display_set_mode must reject modes that exceed the boot back buffer.'
Assert-Match (Join-Path $Root 'src\kernel\fs\fat16.asm') 'fat16_mkdir[\s\S]*call fat16_flush_fats[\s\S]*call fat16_flush_current_dir' 'FAT16 mkdir must create persistent directories through FAT and directory flushes.'
Assert-Match (Join-Path $Root 'src\kernel\fs\fat16.asm') 'fat16_delete_entry[\s\S]*call fat16_flush_fats[\s\S]*call fat16_flush_current_dir' 'FAT16 delete must persist FAT and directory changes.'
Assert-Match (Join-Path $Root 'src\kernel\fs\fat16.asm') 'fat16_rename_entry[\s\S]*call fat16_flush_current_dir' 'FAT16 rename must persist directory metadata.'

Write-Host '[guards] Checking L3 callback isolation...' -ForegroundColor Yellow
Assert-Match $usermodePath '(call_app_l3:|FN_DECL call_app_l3)[\s\S]*call l3_runtime_ptr[\s\S]*mov \[r12 \+ L3_RT_KERNEL_RSP\], rsp' 'L3 callbacks must save kernel return state in slot-local runtime storage.'
Assert-Match $usermodePath '(call_app_l3:|FN_DECL call_app_l3)[\s\S]*call l3_install_app_done_trampoline[\s\S]*iretq' 'L3 callbacks must enter ring 3 through the app-done trampoline and iretq.'
Assert-Match $usermodePath '(call_app_l3_return:|FN_DECL call_app_l3_return)[\s\S]*call l3_runtime_ptr[\s\S]*mov rsp, \[r12 \+ L3_RT_KERNEL_RSP\]' 'L3 return must restore kernel stack from slot-local runtime storage.'
Assert-Match $syscallPath '(syscall_entry:|FN_(BEGIN|DECL) syscall_entry)[\s\S]*mov \[rbx \+ L3_RT_USER_RIP\], rcx[\s\S]*mov \[rbx \+ L3_RT_USER_RSP\], rdx' 'Syscall entry must save user RIP/RSP in slot-local runtime storage.'
Assert-Match $syscallPath '(syscall_entry:|FN_(BEGIN|DECL) syscall_entry)[\s\S]*lea rdx, \[rel l3_syscall_stacks\][\s\S]*mov rsp, rax' 'Syscall entry must switch to a slot-local kernel syscall stack before dispatch.'

Write-Host '[guards] Checking window bounds fix...' -ForegroundColor Yellow
Assert-Match $windowPath '(wm_close_window:|FN_BEGIN wm_close_window)[\s\S]*cmp rdi, MAX_WINDOWS[\s\S]*jae \.close_ret' 'wm_close_window must use an unsigned bounds check.'
Assert-Match $windowPath 'wm_close_window[\s\S]*call wm_focus_top_active[\s\S]*wm_focus_top_active:' 'Closing the focused window must transfer focus to another active visible window.'
Assert-Match $windowPath 'wm_click_focus_before[\s\S]*call call_app_l3[\s\S]*cmp rax, \[wm_click_focus_before\][\s\S]*\.click_preserve_focus' 'Window click callbacks that launch/focus another window must not be overwritten by post-callback focus restore.'
Assert-Match $launchPath 'kernel_open_file_in_notepad:[\s\S]*WIN_OFF_X\], 560[\s\S]*WIN_OFF_Y' 'Notepad windows opened from Explorer must leave the Explorer list visible for more file opens.'
Assert-Match $corePath 'FN_BEGIN process_mouse[\s\S]*call mouse_check_moved[\s\S]*cmp al, \[process_mouse_last_buttons\][\s\S]*mov \[process_mouse_last_buttons\], dl' 'Mouse processing must notice button-only changes so release events clear held-click state.'
Assert-Match $corePath '\.pk_key_lclick:[\s\S]*call wm_handle_mouse_event[\s\S]*\.pk_kc_handled:[\s\S]*mov byte \[mouse_buttons\], 0[\s\S]*xor edx, edx[\s\S]*call wm_handle_mouse_event' 'Keyboard/serial left-click must send both mouse down and mouse up so later Explorer clicks are not treated as a held button.'

Write-Host '[guards] Checking Explorer Enter stack fix...' -ForegroundColor Yellow
Assert-NotMatch $appsPath 'app_explorer_key:[\s\S]*?\.exp_key_enter:[\s\S]*?push rax[\s\S]*?\.exp_key_done:' 'Explorer Enter path must not push an unmatched rax before the shared epilogue.'

Write-Host '[guards] Checking slot-local app buffers...' -ForegroundColor Yellow
Assert-Match $userWindowPath 'APP_SLOT_BMP_FILE_OFF' 'User app constants must expose slot-local BMP storage.'
Assert-Match $userWindowPath 'APP_SLOT_PAINT_CANVAS_OFF' 'User app constants must expose slot-local paint canvas storage.'
Assert-NotMatch $userWindowPath 'APP_BMP_FILE_BUF|APP_PAINT_CANVAS_BUF' 'User app constants must not expose shared global scratch buffers.'
Assert-NotMatch $paintPath 'PAINT_CANVAS_BUF|0x930000' 'Paint app must not use shared global media buffers.'

Write-Host '[guards] Checking NexusHL SDK wiring...' -ForegroundColor Yellow
Assert-Match $nxhBuildPath 'generated_apps\.inc' 'NexusHL build must generate the app include consumed by apps.asm.'
Assert-Match $nxhBuildPath 'manifest\.json' 'NexusHL build must publish an SDK manifest.'
Assert-Match $launchPath 'app_hl_notepad_draw' 'Notepad launch must install the NexusHL draw callback.'
Assert-Match $launchPath 'app_hl_notepad_click' 'Notepad launch must install the NexusHL click callback.'
Assert-Match $launchPath 'app_hl_notepad_key' 'Notepad launch must install the NexusHL key callback.'
Assert-Match $launchPath 'app_hl_explorer_draw' 'Explorer launch must install the NexusHL draw callback.'
Assert-Match $launchPath 'app_hl_explorer_click' 'Explorer launch must install the NexusHL click callback.'
Assert-Match $launchPath 'app_hl_explorer_key' 'Explorer launch must install the NexusHL key callback.'
Assert-Match $nxhNotepadPath 'WM passes coordinates relative to the client area' 'NexusHL Notepad must document the WM client-coordinate ABI.'

Write-Host '[guards] PASS' -ForegroundColor Green
