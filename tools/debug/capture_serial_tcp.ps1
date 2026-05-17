param([int]$WaitSec = 6, [int]$ReadMs = 2000)
Start-Sleep $WaitSec
$c = [System.Net.Sockets.TcpClient]::new('127.0.0.1', 5555)
$c.ReceiveTimeout = $ReadMs
$s = $c.GetStream()
$b = New-Object byte[] 131072
$n = 0
try {
    while (($r = $s.Read($b, $n, 131072 - $n)) -gt 0) { $n += $r }
} catch {}
$c.Close()
[System.Text.Encoding]::ASCII.GetString($b, 0, $n)
