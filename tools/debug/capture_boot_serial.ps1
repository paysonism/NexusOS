$ErrorActionPreference='Stop'
$Root = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$BuildDir = Join-Path $Root 'build'
Get-Process qemu-system-x86_64 -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Milliseconds 500
$job = Start-Job { powershell -ExecutionPolicy Bypass -File (Join-Path $using:PSScriptRoot 'run_uefi_sdl.ps1') }
Start-Sleep -Seconds 2
$c=[System.Net.Sockets.TcpClient]::new()
for ($i=0; $i -lt 30 -and -not $c.Connected; $i++) { try { $c.Connect('127.0.0.1',5555) } catch { Start-Sleep -Milliseconds 200 } }
$s=$c.GetStream(); $b=New-Object byte[] 65536; $sb=New-Object System.Text.StringBuilder
$end=[DateTime]::UtcNow.AddMilliseconds(8000)
while([DateTime]::UtcNow -lt $end){ while($s.DataAvailable){$n=$s.Read($b,0,$b.Length); if($n -le 0){break}; [void]$sb.Append([System.Text.Encoding]::ASCII.GetString($b,0,$n))}; Start-Sleep -Milliseconds 50 }
$c.Close()
Set-Content -Path (Join-Path $BuildDir 'boot_capture.log') -Value $sb.ToString() -Encoding ASCII
Remove-Job $job -Force -ErrorAction SilentlyContinue
"captured: $($sb.Length) bytes"
