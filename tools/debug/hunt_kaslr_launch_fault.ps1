param([int]$Iterations = 10)
# Boot KASLR-on repeatedly, launch Notepad over the COM1 automation channel
# (arm byte 0x01 then '4' = APP_NOTEPAD), and collect any recovered ring-0 fault
# (KREC line) whose CR2 is NOT the benign framebuffer present-path fault
# (0x808CA000). Those KRECs carry L=<slide-relative RIP> which maps 1:1 into
# build/kslroff.lst, pinpointing the missing-KASLR-fixup deref.
$ErrorActionPreference = 'SilentlyContinue'
$root = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$run  = Join-Path $root 'scripts\run\run_uefi.ps1'
$HOST_='127.0.0.1'; $PORT=5555
$hits = @()
for ($i=1; $i -le $Iterations; $i++) {
    Get-Process qemu-system-x86_64 -EA SilentlyContinue | Stop-Process -Force -EA SilentlyContinue
    Start-Sleep -Milliseconds 400
    & powershell -NoProfile -ExecutionPolicy Bypass -File $run -Headless -SerialTcp -NoPassthrough | Out-Null
    # connect
    $cli=$null
    for ($t=0;$t -lt 40;$t++){ try { $cli=[Net.Sockets.TcpClient]::new(); $cli.Connect($HOST_,$PORT); break } catch { $cli=$null; Start-Sleep -Milliseconds 250 } }
    if (-not $cli){ Write-Host "[$i] no serial"; continue }
    $s=$cli.GetStream(); $buf=New-Object byte[] 65536; $sb=New-Object Text.StringBuilder
    # let it boot
    $deadline=(Get-Date).AddSeconds(9)
    while((Get-Date) -lt $deadline){ try { while($s.DataAvailable){ $n=$s.Read($buf,0,$buf.Length); [void]$sb.Append([Text.Encoding]::ASCII.GetString($buf,0,$n)) } } catch {}; if($sb.ToString() -match 'BOOTTIME'){ break }; Start-Sleep -Milliseconds 150 }
    # launch notepad a few times (arm 0x01 + '4')
    foreach($k in 1..3){ $cmd=[byte[]](0x01,0x34); try{ $s.Write($cmd,0,2); $s.Flush() }catch{}; Start-Sleep -Milliseconds 700; try { while($s.DataAvailable){ $n=$s.Read($buf,0,$buf.Length); [void]$sb.Append([Text.Encoding]::ASCII.GetString($buf,0,$n)) } } catch {} }
    Start-Sleep -Milliseconds 600
    try { while($s.DataAvailable){ $n=$s.Read($buf,0,$buf.Length); [void]$sb.Append([Text.Encoding]::ASCII.GetString($buf,0,$n)) } } catch {}
    $cli.Close()
    $text=$sb.ToString()
    # KREC=<rip>L<linkrip>V<vec>E<err>C<cr2>
    $krec=[regex]::Matches($text,'KREC=([0-9A-F]{16})L([0-9A-F]{16})V([0-9A-F]{16})E([0-9A-F]{16})C([0-9A-F]{16})')
    $interesting=$false
    foreach($m in $krec){
        $cr2=$m.Groups[5].Value
        if($cr2 -ne '00000000808CA000'){
            $interesting=$true
            $hits += [pscustomobject]@{Iter=$i; RIP=$m.Groups[1].Value; LinkRIP=$m.Groups[2].Value; Vec=$m.Groups[3].Value; Err=$m.Groups[4].Value; CR2=$cr2}
        }
    }
    $alive=(Get-Process qemu-system-x86_64 -EA SilentlyContinue|Measure-Object).Count
    Write-Host ("[{0}] krec={1} interesting={2} qemuAlive={3}" -f $i,$krec.Count,$interesting,$alive)
}
Get-Process qemu-system-x86_64 -EA SilentlyContinue | Stop-Process -Force -EA SilentlyContinue
""
"=== NON-framebuffer recovered faults (missing-fixup candidates) ==="
if($hits.Count -eq 0){ "none captured in $Iterations boots" } else { $hits | Format-Table -AutoSize | Out-String }
