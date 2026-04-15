param(
    [switch]$Build
)

$ErrorActionPreference = 'Stop'
$QEMU = 'C:\Program Files\qemu\qemu-system-x86_64.exe'
$BUILD_DIR = Join-Path $PSScriptRoot 'build'
$OVMF = Join-Path $BUILD_DIR 'OVMF.fd'
$ESP = Join-Path $BUILD_DIR 'esp'
$DATA = Join-Path $BUILD_DIR 'data.img'
$SERIAL_HOST = '127.0.0.1'
$SERIAL_PORT = 5555

if ($Build) {
    & (Join-Path $PSScriptRoot 'build_uefi.ps1')
    if ($LASTEXITCODE -ne 0) {
        throw 'build_uefi.ps1 failed.'
    }
}

Get-Process qemu-system-x86_64 -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 1

$proc = Start-Process -FilePath $QEMU -ArgumentList @(
    '-bios', $OVMF,
    '-drive', "file=fat:rw:$ESP",
    '-drive', "file=$DATA,format=raw,media=disk",
    '-m', '512M',
    '-vga', 'std',
    '-device', 'qemu-xhci,id=xhci0',
    '-device', 'usb-mouse,bus=xhci0.0',
    '-serial', "tcp:$SERIAL_HOST`:$SERIAL_PORT,server=on,wait=off",
    '-no-reboot',
    '-display', 'none',
    '-name', 'NexusOS_UEFI_serial_test'
) -PassThru

try {
    Start-Sleep -Seconds 8

    $client = [System.Net.Sockets.TcpClient]::new()
    $client.Connect($SERIAL_HOST, $SERIAL_PORT)
    $stream = $client.GetStream()
    $enc = [System.Text.Encoding]::ASCII
    $buf = New-Object byte[] 65536

    function Read-Serial([System.Net.Sockets.NetworkStream]$Stream, [byte[]]$Buffer, [System.Text.Encoding]$Encoding, [int]$Ms) {
        $deadline = [DateTime]::UtcNow.AddMilliseconds($Ms)
        $sb = New-Object System.Text.StringBuilder
        while ([DateTime]::UtcNow -lt $deadline) {
            while ($Stream.DataAvailable) {
                $n = $Stream.Read($Buffer, 0, $Buffer.Length)
                if ($n -gt 0) {
                    [void]$sb.Append($Encoding.GetString($Buffer, 0, $n))
                }
            }
            Start-Sleep -Milliseconds 50
        }
        $sb.ToString()
    }

    function Send-Bytes([System.Net.Sockets.NetworkStream]$Stream, [byte[]]$Bytes) {
        $Stream.Write($Bytes, 0, $Bytes.Length)
        $Stream.Flush()
    }

    [void](Read-Serial $stream $buf $enc 500)

    Send-Bytes $stream ([byte[]](0x01, [byte][char]'3'))
    Start-Sleep -Milliseconds 300
    Send-Bytes $stream ($enc.GetBytes('hx7') + [byte]13)
    Start-Sleep -Milliseconds 700

    $out = Read-Serial $stream $buf $enc 2000
    $client.Close()

    $expected = @(
        '0000000001006800', # h
        '0000000001007800', # x
        '0000000001003700', # 7
        '0000000001000D00'  # Enter
    )

    $missing = @()
    foreach ($pattern in $expected) {
        if ($out -notmatch [regex]::Escape($pattern)) {
            $missing += $pattern
        }
    }

    if ($missing.Count -gt 0) {
        Write-Host 'Serial typing test failed.' -ForegroundColor Red
        Write-Host "Missing event patterns: $($missing -join ', ')" -ForegroundColor Yellow
        Write-Host $out
        exit 1
    }

    Write-Host 'Serial typing test passed.' -ForegroundColor Green
    Write-Host 'Observed injected key events:' -ForegroundColor Cyan
    foreach ($pattern in $expected) {
        Write-Host "  $pattern"
    }
}
finally {
    if ($proc -and -not $proc.HasExited) {
        Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
    }
}
