$ErrorActionPreference = 'SilentlyContinue'
$Root = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$BuildDir = Join-Path $Root 'build'
Get-Process qemu-system-x86_64 | Stop-Process -Force
Start-Sleep 1
$p = Start-Process -FilePath 'C:\Program Files\qemu\qemu-system-x86_64.exe' -ArgumentList @(
 '-bios',"$BuildDir/OVMF.fd",
 '-drive',"format=raw,file=fat:rw:$BuildDir/esp",
 '-drive',"file=$BuildDir/data.img,format=raw,media=disk",
 '-m','512M','-vga','std','-display','none',
 '-device','qemu-xhci,id=xhci0',
 '-device','usb-mouse,bus=xhci0.0,port=1',
 '-device','usb-kbd,bus=xhci0.0,port=2',
 '-serial',"file:$BuildDir/serial.log",
 '-no-reboot') -PassThru
Start-Sleep 20
Stop-Process -Id $p.Id -Force
