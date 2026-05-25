$ErrorActionPreference = 'Stop'

$Root = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$BuildDir = Join-Path $Root 'build'
$LogPath = Join-Path $BuildDir 'cache32_serial.log'
$SerialHost = '127.0.0.1'
$SerialPort = 5555

function Stop-QemuIfRunning {
    Get-Process qemu-system-x86_64 -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
}

function Read-Serial {
    param(
        [int]$ConnectTimeoutMs = 8000,
        [int]$CaptureMs = 14000,
        [byte[]]$CommandBytes = @()
    )

    $deadline = [DateTime]::UtcNow.AddMilliseconds($ConnectTimeoutMs)
    $client = $null
    while (-not $client -and [DateTime]::UtcNow -lt $deadline) {
        try {
            $candidate = [System.Net.Sockets.TcpClient]::new()
            $candidate.Connect($SerialHost, $SerialPort)
            $client = $candidate
        }
        catch {
            if ($candidate) { $candidate.Dispose() }
            Start-Sleep -Milliseconds 100
        }
    }
    if (-not $client) {
        throw "Unable to connect to serial on $SerialHost`:$SerialPort"
    }

    try {
        $stream = $client.GetStream()
        if ($CommandBytes.Count -gt 0) {
            Start-Sleep -Milliseconds 6000
            $stream.Write($CommandBytes, 0, $CommandBytes.Count)
        }

        $buffer = New-Object byte[] 65536
        $encoding = [System.Text.Encoding]::ASCII
        $builder = New-Object System.Text.StringBuilder
        $captureDeadline = [DateTime]::UtcNow.AddMilliseconds($CaptureMs)
        while ([DateTime]::UtcNow -lt $captureDeadline) {
            while ($stream.DataAvailable) {
                $count = $stream.Read($buffer, 0, $buffer.Length)
                if ($count -le 0) { break }
                [void]$builder.Append($encoding.GetString($buffer, 0, $count))
            }
            Start-Sleep -Milliseconds 50
        }
        return $builder.ToString()
    }
    finally {
        $client.Close()
    }
}

try {
    Stop-QemuIfRunning
    New-Item -ItemType Directory -Path $BuildDir -Force | Out-Null

    Write-Host '[cache32] Building BIOS Cache32Max image...' -ForegroundColor Yellow
    powershell -ExecutionPolicy Bypass -File (Join-Path $Root 'scripts\build\build_bios.ps1') -PerfProfile Cache32Max

    Write-Host '[cache32] Booting strict 32MB / 8-core BIOS QEMU profile...' -ForegroundColor Yellow
    $bootJob = Start-Job -ScriptBlock {
        param($RootPath)
        powershell -ExecutionPolicy Bypass -File (Join-Path $RootPath 'scripts\run\run_bios.ps1') -PerfProfile Cache32Max -Headless -SerialTcp
    } -ArgumentList $Root

    try {
        $serial = Read-Serial -CommandBytes ([byte[]]@(0x01,0x70,0x01,0x6D,0x01,0x73,0x01,0x62))
    }
    finally {
        Stop-QemuIfRunning
        Wait-Job $bootJob | Out-Null
        Receive-Job $bootJob | Out-Host
        Remove-Job $bootJob
    }

    Set-Content -Path $LogPath -Value $serial

    $markers = @('CPU:', 'CACHE:', 'FREQ:', 'MEMCAP:', 'SMP:', 'BENCH:')
    $missing = @()
    foreach ($marker in $markers) {
        if ($serial -notlike "*$marker*") { $missing += $marker }
    }
    if ($missing.Count -gt 0) {
        Write-Host '[cache32] FAILED' -ForegroundColor Red
        Write-Host "Serial log saved to $LogPath" -ForegroundColor DarkYellow
        Write-Host 'Missing markers:' -ForegroundColor DarkYellow
        foreach ($marker in $missing) { Write-Host "  - $marker" -ForegroundColor DarkYellow }
        exit 1
    }

    Write-Host '[cache32] PASS' -ForegroundColor Green
    Write-Host "Serial log saved to $LogPath" -ForegroundColor Gray
}
finally {
    Stop-QemuIfRunning
}
