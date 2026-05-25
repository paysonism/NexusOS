$ErrorActionPreference = 'Stop'

$Root = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$BuildDir = Join-Path $Root 'build'
$LogPath = Join-Path $BuildDir 'security_probe_serial.log'
$SerialHost = '127.0.0.1'
$SerialPort = 5555

function Stop-QemuIfRunning {
    try {
        $client = [System.Net.Sockets.TcpClient]::new()
        $client.Connect('127.0.0.1', 4444)
        $stream = $client.GetStream()
        $bytes = [System.Text.Encoding]::ASCII.GetBytes("quit`r`n")
        $stream.Write($bytes, 0, $bytes.Length)
        $stream.Flush()
        $client.Close()
        Start-Sleep -Milliseconds 500
    } catch {}
    Get-Process qemu-system-x86_64 -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
}

function Assert-Text {
    param(
        [string]$Name,
        [string]$Path,
        [string]$Pattern
    )
    $text = Get-Content -Raw -Path (Join-Path $Root $Path)
    if ($text -notmatch $Pattern) {
        throw "Static guard failed for $Name in $Path"
    }
    Write-Host "[security] $Name PASS" -ForegroundColor Green
}

function Read-SerialProbe {
    param([byte[]]$CommandBytes, [int]$CaptureMs = 18000)

    $deadline = [DateTime]::UtcNow.AddMilliseconds(10000)
    $client = $null
    while ([DateTime]::UtcNow -lt $deadline) {
        try {
            $client = [System.Net.Sockets.TcpClient]::new()
            $client.Connect($SerialHost, $SerialPort)
            break
        } catch {
            if ($client) { $client.Dispose() }
            Start-Sleep -Milliseconds 100
        }
    }
    if (-not $client -or -not $client.Connected) {
        throw "serial connect failed on $SerialHost`:$SerialPort"
    }

    try {
        $stream = $client.GetStream()
        $buf = New-Object byte[] 65536
        $enc = [System.Text.Encoding]::ASCII
        $out = New-Object System.Text.StringBuilder

        Start-Sleep -Milliseconds 8000
        $stream.Write($CommandBytes, 0, $CommandBytes.Count)
        $stream.Flush()

        $end = [DateTime]::UtcNow.AddMilliseconds($CaptureMs)
        while ([DateTime]::UtcNow -lt $end) {
            while ($stream.DataAvailable) {
                $n = $stream.Read($buf, 0, $buf.Length)
                if ($n -le 0) { break }
                [void]$out.Append($enc.GetString($buf, 0, $n))
            }
            Start-Sleep -Milliseconds 50
        }
        return $out.ToString()
    } finally {
        $client.Close()
    }
}

try {
    Stop-QemuIfRunning
    New-Item -ItemType Directory -Path $BuildDir -Force | Out-Null

    Write-Host '[security] Building UEFI image with Security Probe app...' -ForegroundColor Yellow
    $buildOutput = powershell -ExecutionPolicy Bypass -File (Join-Path $Root 'scripts\build\build_uefi.ps1') 2>&1
    $buildOutput | Out-Host
    if ($LASTEXITCODE -ne 0) {
        throw "build_uefi.ps1 failed with exit code $LASTEXITCODE"
    }

    $appsBin = Join-Path $BuildDir 'esp\EFI\BOOT\APPS.BIN'
    $appsText = [System.Text.Encoding]::ASCII.GetString([System.IO.File]::ReadAllBytes($appsBin))
    if ($appsText -notlike '*Security Probe*') {
        throw 'Security Probe marker missing from compiled APPS.BIN'
    }
    Write-Host '[security] Compiled app present in APPS.BIN PASS' -ForegroundColor Green

    Assert-Text 'F1 app blob copy cap is guarded' 'src\kernel\proc\usermode.asm' 'L3_APP_BLOB_COPY_CAP\s+equ\s+L3_SHADOW_WIN_OFF[\s\S]*?%error[\s\S]*?cmp\s+rcx,\s*L3_APP_BLOB_COPY_CAP[\s\S]*?rep\s+movsb'
    Assert-Text 'F2 FAT16 read uses scratch copy' 'src\kernel\fs\fat16.asm' '(fat16_read_file:|FN_BEGIN\s+fat16_read_file)[\s\S]*?mov\s+rsi,\s*FAT16_FILE_BUF[\s\S]*?rep\s+movsb'
    Assert-Text 'F3 FAT16 write pads final partial cluster' 'src\kernel\fs\fat16.asm' 'wf_write_partial_cluster:[\s\S]*?mov\s+rdi,\s*FAT16_FILE_BUF[\s\S]*?rep\s+stosb[\s\S]*?rep\s+movsb[\s\S]*?call\s+ata_write_sectors'
    Assert-Text 'F4 HID parser guards multi-byte item reads' 'src\kernel\drivers\hid_parser.asm' 'lea\s+rax,\s*\[rsi \+ 4\][\s\S]*?cmp\s+rax,\s*rbp[\s\S]*?movzx\s+eax,\s*byte\s+\[rsi \+ 3\][\s\S]*?lea\s+rax,\s*\[rsi \+ 2\][\s\S]*?\.skip_long_item:'
    Assert-Text 'F5 HID extraction enforces report length' 'src\kernel\drivers\hid_parser.asm' '(hid_extract_field_checked:|FN_BEGIN\s+hid_extract_field_checked)[\s\S]*?cmp\s+r8d,\s*1[\s\S]*?cmp\s+r8d,\s*32[\s\S]*?cmp\s+edx,\s*eax[\s\S]*?(hid_process_touchpad_report:|FN_BEGIN\s+hid_process_touchpad_report)[\s\S]*?mov\s+r13d,\s*ecx[\s\S]*?call\s+hid_extract_field_checked'
    Assert-Text 'F6 USB descriptor parser validates lengths' 'src\kernel\drivers\usb_hid.asm' 'usb_find_endpoint:[\s\S]*?cmp\s+byte\s+\[rsi\],\s*4[\s\S]*?cmp\s+eax,\s*2[\s\S]*?cmp\s+r8d,\s*ecx[\s\S]*?\.check_interface:[\s\S]*?cmp\s+byte\s+\[rsi \+ rdx\],\s*8[\s\S]*?\.check_endpoint:[\s\S]*?cmp\s+byte\s+\[rsi \+ rdx\],\s*7'
    Assert-Text 'F7 syscall close checks slot ownership' 'src\kernel\proc\syscall.asm' '\.sc_wm_close:[\s\S]*?cmp\s+rdi,\s*MAX_WINDOWS[\s\S]*?WIN_OFF_APPDATA[\s\S]*?jne\s+\.sc_wm_close_reject'

    Write-Host '[security] Booting UEFI and launching app ID 8...' -ForegroundColor Yellow
    $job = Start-Job -ScriptBlock {
        param($RootPath)
        powershell -ExecutionPolicy Bypass -File (Join-Path $RootPath 'scripts\run\run_uefi.ps1') -Headless -NoPassthrough -SerialTcp
    } -ArgumentList $Root

    try {
        $serial = Read-SerialProbe -CommandBytes ([byte[]]@(0x01, [byte][char]'8'))
    } finally {
        Stop-QemuIfRunning
        Receive-Job $job -ErrorAction SilentlyContinue | Out-Host
        Remove-Job $job -Force -ErrorAction SilentlyContinue
    }

    Set-Content -Path $LogPath -Value $serial -Encoding ASCII

    $required = [ordered]@{
        'N0000000000000080' = 'SEC-PROBE-BEGIN'
        'N00000000000000F2' = 'SEC-F2-READ-OVERWRITE-NOT-SEEN'
        'N00000000000000F7' = 'SEC-F7-FOREIGN-CLOSE-REJECTED'
    }
    foreach ($marker in $required.Keys) {
        if ($serial -notlike "*$marker*") {
            throw "Missing runtime marker: $($required[$marker]) / $marker"
        }
        Write-Host "[security] $($required[$marker]) PASS" -ForegroundColor Green
    }

    $forbidden = [ordered]@{
        'N0000000000000082' = 'SEC-F2-READ-OVERWRITE-P1'
        'N0000000000000083' = 'SEC-F3-WRITE-OVERREAD-P1'
        'N0000000000000087' = 'SEC-F7-FOREIGN-CLOSE-P2'
    }
    foreach ($marker in $forbidden.Keys) {
        if ($serial -like "*$marker*") {
            throw "Vulnerable marker still present: $($forbidden[$marker]) / $marker"
        }
        Write-Host "[security] $($forbidden[$marker]) absent PASS" -ForegroundColor Green
    }

    Write-Host '[security] PATCHED FINDINGS' -ForegroundColor Cyan
    Write-Host '  F1 PASS static: APPS.BIN copy is capped below the shadow/window/stack area'
    Write-Host '  F2 PASS runtime: fs_read did not overwrite bytes outside requested length'
    if ($serial -like '*N00000000000000F3*') {
        Write-Host '[security] SEC-F3-WRITE-OVERREAD-NOT-SEEN PASS' -ForegroundColor Green
    } elseif ($serial -like '*N00000000000000E9*') {
        Write-Host '[security] SEC-F3-WRITE-REJECTED-BEFORE-FAT16 PASS' -ForegroundColor Green
    } else {
        throw 'Missing F3 patched marker: expected padded write result (F3) or syscall rejection (E9)'
    }

    Write-Host '  F3 PASS static/runtime: fat16_write_file pads partial clusters from scratch; syscall may still reject first'
    Write-Host '  F4 PASS static: HID descriptor parser guards item payload reads'
    Write-Host '  F5 PASS static: HID report extraction checks report length and field size'
    Write-Host '  F6 PASS static: USB config parser rejects malformed descriptor lengths'
    Write-Host '  F7 PASS runtime: foreign window close is rejected'
    Write-Host "Serial log saved to $LogPath"
} finally {
    Stop-QemuIfRunning
}
