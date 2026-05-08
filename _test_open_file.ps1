$ErrorActionPreference = 'Stop'
$Root = $PSScriptRoot
$BuildDir = Join-Path $Root 'build'
$LogPath = Join-Path $BuildDir 'open_file_serial.log'
$SerialHost = '127.0.0.1'
$SerialPort = 5555

Get-Process qemu-system-x86_64 -EA SilentlyContinue | Stop-Process -Force
Start-Sleep 1

$job = Start-Job -ScriptBlock {
    param($r)
    powershell -ExecutionPolicy Bypass -File (Join-Path $r 'run_uefi.ps1') -Headless
} -ArgumentList $Root

$deadline = [DateTime]::UtcNow.AddSeconds(15)
$client = $null
while ([DateTime]::UtcNow -lt $deadline) {
    try { $client = [System.Net.Sockets.TcpClient]::new(); $client.Connect($SerialHost,$SerialPort); break } catch { Start-Sleep -Milliseconds 200 }
}
if (-not $client.Connected) { throw 'serial connect failed' }
$stream = $client.GetStream()

# Wait for boot to settle
Start-Sleep -Seconds 8

# 1) Launch explorer (0x01 '2')
$stream.Write([byte[]]@(0x01, [byte][char]'2'), 0, 2); $stream.Flush()
Start-Sleep -Seconds 3

# 2) Send Enter (CR=13) to open default selected entry
$stream.Write([byte[]]@(13), 0, 1); $stream.Flush()
Start-Sleep -Seconds 4

# Capture
$buf = New-Object byte[] 131072
$out = New-Object System.Text.StringBuilder
$end = [DateTime]::UtcNow.AddMilliseconds(2000)
while ([DateTime]::UtcNow -lt $end) {
    while ($stream.DataAvailable) {
        $n = $stream.Read($buf,0,$buf.Length)
        if ($n -le 0) { break }
        [void]$out.Append([System.Text.Encoding]::ASCII.GetString($buf,0,$n))
    }
    Start-Sleep -Milliseconds 50
}
$client.Close()
Get-Process qemu-system-x86_64 -EA SilentlyContinue | Stop-Process -Force
Remove-Job $job -Force -EA SilentlyContinue

$serial = $out.ToString()
Set-Content -Path $LogPath -Value $serial -Encoding ASCII
Write-Host "===CAPTURED $($serial.Length) bytes==="
Write-Host $serial
Write-Host "===CHECK==="
$expl = $serial -match 'L0000000000000002'
$np   = $serial -match 'L0000000000000004'
$xexc = $serial -match 'X000000000000000(6|E)'
Write-Host "explorer-launch: $expl"
Write-Host "notepad-launch:  $np"
Write-Host "ring3-exception: $xexc"
if ($expl -and $np -and -not $xexc) { Write-Host 'PASS' -ForegroundColor Green } else { Write-Host 'FAIL' -ForegroundColor Red }
