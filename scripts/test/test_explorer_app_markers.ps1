$ErrorActionPreference = 'Stop'

$Root = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$BuildDir = Join-Path $Root 'build'
$LogPath = Join-Path $BuildDir 'explorer_app_serial.log'
$SerialHost = '127.0.0.1'
$SerialPort = 5555

function Stop-QemuIfRunning {
    Get-Process qemu-system-x86_64 -ErrorAction SilentlyContinue | Stop-Process -Force
}

function Read-Serial {
    param([byte[]]$CommandBytes = @(), [int]$CaptureMs = 10000)

    $deadline = [DateTime]::UtcNow.AddMilliseconds(8000)
    $client = $null
    while ([DateTime]::UtcNow -lt $deadline) {
        try {
            $client = [System.Net.Sockets.TcpClient]::new()
            $client.Connect($SerialHost, $SerialPort)
            break
        } catch {
            Start-Sleep -Milliseconds 100
        }
    }
    if (-not $client -or -not $client.Connected) { throw 'serial connect failed' }

    $stream = $client.GetStream()
    if ($CommandBytes.Count -gt 0) {
        Start-Sleep -Milliseconds 8000
        $stream.Write($CommandBytes, 0, $CommandBytes.Count)
        $stream.Flush()
    }
    $buf = New-Object byte[] 65536
    $enc = [System.Text.Encoding]::ASCII
    $out = New-Object System.Text.StringBuilder
    $end = [DateTime]::UtcNow.AddMilliseconds($CaptureMs)
    while ([DateTime]::UtcNow -lt $end) {
        while ($stream.DataAvailable) {
            $n = $stream.Read($buf, 0, $buf.Length)
            if ($n -le 0) { break }
            [void]$out.Append($enc.GetString($buf, 0, $n))
        }
        Start-Sleep -Milliseconds 50
    }
    $client.Close()
    return $out.ToString()
}

try {
    Stop-QemuIfRunning
    New-Item -ItemType Directory -Path $BuildDir -Force | Out-Null
    Write-Host '[explorer] Building UEFI image...' -ForegroundColor Yellow
    powershell -ExecutionPolicy Bypass -File (Join-Path $Root 'scripts\build\build_uefi.ps1') | Out-Host

    Write-Host '[explorer] Booting UEFI and launching Explorer through serial...' -ForegroundColor Yellow
    $job = Start-Job -ScriptBlock {
        param($RootPath)
        powershell -ExecutionPolicy Bypass -File (Join-Path $RootPath 'scripts\run\run_uefi.ps1') -Headless
    } -ArgumentList $Root

    try {
        $serial = Read-Serial -CommandBytes ([byte[]]@(0x01, [byte][char]'2')) -CaptureMs 12000
    } finally {
        Stop-QemuIfRunning
        Receive-Job $job -ErrorAction SilentlyContinue | Out-Host
        Remove-Job $job -Force -ErrorAction SilentlyContinue
    }

    Set-Content -Path $LogPath -Value $serial -Encoding ASCII
    foreach ($marker in @('L0000000000000002', 'U', '@')) {
        if ($serial -notlike "*$marker*") { throw "Missing Explorer L3 marker: $marker" }
    }
    if ($serial -notmatch 'R[0-9A-Fa-f]{16}') {
        throw 'Missing Explorer L3 return marker'
    }
    if ($serial -match 'X000000000000000(6|E)') {
        throw 'Explorer path hit a ring-3 exception during launch/callback'
    }
    Write-Host '[explorer] PASS' -ForegroundColor Green
    Write-Host "Serial log saved to $LogPath"
} finally {
    Stop-QemuIfRunning
}
