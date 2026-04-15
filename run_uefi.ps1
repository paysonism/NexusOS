$ErrorActionPreference = 'SilentlyContinue'
$QEMU = 'C:\Program Files\qemu\qemu-system-x86_64.exe'
$BUILD = Join-Path $PSScriptRoot 'build'
$SERIAL = 'tcp:127.0.0.1:5555,server=on,wait=off'
$SERIAL_HOST = '127.0.0.1'
$SERIAL_PORT = 5555

# Kill existing
Get-Process qemu-system-x86_64 -ErrorAction SilentlyContinue | Stop-Process -Force

Start-Sleep -Seconds 1

Write-Host "Launching NexusOS UEFI with XHCI+HID..." -ForegroundColor Cyan

$proc = Start-Process -FilePath $QEMU -ArgumentList @(
    '-bios', "$BUILD\OVMF.fd",
    '-drive', "format=raw,file=fat:rw:$BUILD\esp",
    '-drive', "file=$BUILD\data.img,format=raw,media=disk",
    '-m', '512M',
    '-vga', 'std',
    '-display', 'gtk,grab-on-hover=on,show-cursor=on,window-close=on',
    '-device', 'qemu-xhci,id=xhci0',
    '-device', 'usb-mouse,bus=xhci0.0,port=1',
    '-device', 'usb-kbd,bus=xhci0.0,port=2',
    '-serial', $SERIAL,
    '-no-reboot',
    '-monitor', 'telnet:127.0.0.1:4444,server,nowait',
    '-name', 'NexusOS_UEFI'
 ) -PassThru

Start-Sleep -Milliseconds 800
if ($proc.HasExited) {
    Write-Host "QEMU exited early." -ForegroundColor Red
    exit 1
}

$ready = $false
for ($i = 0; $i -lt 20; $i++) {
    try {
        $client = [System.Net.Sockets.TcpClient]::new()
        $client.Connect($SERIAL_HOST, $SERIAL_PORT)
        $client.Close()
        $ready = $true
        break
    } catch {
        Start-Sleep -Milliseconds 250
    }
}

if (-not $ready) {
    Write-Host "QEMU running, serial not ready." -ForegroundColor Yellow
    exit 2
}

Write-Host "VM running, serial ready on $SERIAL_HOST`:$SERIAL_PORT" -ForegroundColor Green
