param(
    [ValidateSet('Default', 'Cache32Max')]
    [string]$PerfProfile = 'Default',
    [string]$GuestMemory,
    [switch]$Headless
)

$ErrorActionPreference = 'SilentlyContinue'
$Root = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$QEMU = 'C:\Program Files\qemu\qemu-system-x86_64.exe'
$BUILD = Join-Path $Root 'build'
$SERIAL = 'tcp:127.0.0.1:5555,server=on,wait=off'
$SERIAL_HOST = '127.0.0.1'
$SERIAL_PORT = 5555

# Kill existing
Get-Process qemu-system-x86_64 -ErrorAction SilentlyContinue | Stop-Process -Force

Start-Sleep -Seconds 1

# Cache32Max constrains the *allocator* to CACHE32_RAM_LIMIT (32 MiB) in
# software; it is NOT a QEMU RAM size. The kernel's static memory layout
# (wallpaper caches at 0x3000000, BACK_BUFFER_SAVE_ADDR at 0x4C00000, ...)
# reaches ~76 MiB, so the guest must still be given enough physical RAM to
# load. 36M is far too small - the kernel never loads and the firmware
# faults with #UD. 256M is comfortably above the kernel's footprint plus
# OVMF overhead.
if (-not $GuestMemory) {
    $GuestMemory = if ($PerfProfile -eq 'Cache32Max') { '256M' } else { '512M' }
}

Write-Host "Launching NexusOS UEFI with XHCI+HID ($PerfProfile, $GuestMemory RAM)..." -ForegroundColor Cyan

$qemuArgs = @(
    '-bios', "$BUILD\OVMF.fd",
    '-drive', "file=$BUILD\data.img,format=raw,if=ide,index=0,media=disk",
    '-drive', "format=raw,file=fat:rw:$BUILD\esp,if=ide,index=1,media=disk",
    '-m', $GuestMemory,
    '-vga', 'std'
)
if ($PerfProfile -eq 'Cache32Max') {
    $qemuArgs += @('-smp', '8,sockets=1,cores=8,threads=1')
}
$displayArg = if ($Headless) { 'none' } else { 'gtk,grab-on-hover=on,show-cursor=on,window-close=on' }
$qemuArgs += @(
    '-display', $displayArg,
    '-device', 'qemu-xhci,id=xhci0',
    '-device', 'usb-mouse,bus=xhci0.0,port=1',
    '-device', 'usb-kbd,bus=xhci0.0,port=2',
    '-serial', $SERIAL,
    '-no-reboot',
    '-monitor', 'telnet:127.0.0.1:4444,server,nowait',
    '-name', 'NexusOS_UEFI'
)

$proc = Start-Process -FilePath $QEMU -ArgumentList $qemuArgs -PassThru

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
