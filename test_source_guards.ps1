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
$windowPath = Join-Path $Root 'src\kernel\gui\window.asm'
$appsPath = Join-Path $Root 'src\user\apps\explorer.inc'
$wrapperPath = Join-Path $Root 'src\user\apps.asm'
$pagingPath = Join-Path $Root 'src\boot\paging.asm'
$userWindowPath = Join-Path $Root 'src\user\lib\nexus_window.inc'
$paintPath = Join-Path $Root 'src\user\apps\paint.inc'

Write-Host '[guards] Checking user/kernel structure...' -ForegroundColor Yellow
Assert-Match $wrapperPath 'src/user/apps/common\.inc' 'apps.asm must include the split user app tree.'
Assert-Match $wrapperPath 'app_blob_start:' 'apps.asm must expose app_blob_start for syscall validation.'
Assert-Match $wrapperPath 'app_blob_end:' 'apps.asm must expose app_blob_end for syscall validation.'
Assert-Match $pagingPath 'mov eax, PAGE_PRESENT \| PAGE_WRITABLE \| PAGE_LARGE' 'Paging must map kernel memory supervisor-only by default.'
Assert-Match $pagingPath 'or eax, PAGE_USER' 'Paging must explicitly mark only the user app arena as user-accessible.'

Write-Host '[guards] Checking syscall hardening...' -ForegroundColor Yellow
Assert-Match $syscallPath '\.sc_print:[\s\S]*call sc_validate_user_cstring' 'SYS_PRINT must validate user strings.'
Assert-Match $syscallPath '\.sc_gui_text:[\s\S]*call sc_validate_user_cstring' 'SYS_GUI_TEXT must validate user strings.'
Assert-Match $syscallPath '\.sc_wm_create:[\s\S]*call sc_validate_callback_target' 'SYS_WM_CREATE must validate callback targets.'
Assert-Match $syscallPath '\.sc_fs_read:[\s\S]*call sc_validate_dir_entry_handle' 'SYS_FS_READ must validate directory-entry handles.'
Assert-Match $syscallPath '\.sc_fs_write:[\s\S]*call sc_validate_user_io_range' 'SYS_FS_WRITE must validate user buffers.'
Assert-Match $syscallPath '\.sc_wm_handlers:[\s\S]*cmp rdi, MAX_WINDOWS[\s\S]*jae \.sc_wm_handlers_reject' 'SYS_WM_HANDLERS must reject out-of-range window ids.'
Assert-Match $syscallPath '\.sc_wm_handlers:[\s\S]*call sc_validate_callback_target' 'SYS_WM_HANDLERS must validate handler targets.'
Assert-NotMatch $syscallPath 'APP_BMP_FILE_BUF|APP_CANVAS_BUF' 'Kernel syscall validation must not whitelist shared global app scratch buffers anymore.'

Write-Host '[guards] Checking window bounds fix...' -ForegroundColor Yellow
Assert-Match $windowPath 'wm_close_window:[\s\S]*cmp rdi, MAX_WINDOWS[\s\S]*jae \.close_ret' 'wm_close_window must use an unsigned bounds check.'

Write-Host '[guards] Checking Explorer Enter stack fix...' -ForegroundColor Yellow
Assert-NotMatch $appsPath 'app_explorer_key:[\s\S]*?\.exp_key_enter:[\s\S]*?push rax[\s\S]*?\.exp_key_done:' 'Explorer Enter path must not push an unmatched rax before the shared epilogue.'

Write-Host '[guards] Checking slot-local app buffers...' -ForegroundColor Yellow
Assert-Match $userWindowPath 'APP_SLOT_BMP_FILE_OFF' 'User app constants must expose slot-local BMP storage.'
Assert-Match $userWindowPath 'APP_SLOT_PAINT_CANVAS_OFF' 'User app constants must expose slot-local paint canvas storage.'
Assert-NotMatch $userWindowPath 'APP_BMP_FILE_BUF|APP_PAINT_CANVAS_BUF' 'User app constants must not expose shared global scratch buffers.'
Assert-NotMatch $paintPath 'PAINT_CANVAS_BUF|0x930000' 'Paint app must not use shared global media buffers.'

Write-Host '[guards] PASS' -ForegroundColor Green
