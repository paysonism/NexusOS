$c = New-Object System.Net.Sockets.TcpClient
$c.Connect('127.0.0.1', 5555)
$s = $c.GetStream()
$s.ReadTimeout = 5000
$buf = New-Object byte[] 16384
$out = ''
$deadline = (Get-Date).AddSeconds(12)
while ((Get-Date) -lt $deadline) {
  if ($s.DataAvailable) {
    $n = $s.Read($buf, 0, 16384)
    if ($n -gt 0) {
      $out += [System.Text.Encoding]::ASCII.GetString($buf, 0, $n)
    }
  } else {
    Start-Sleep -Milliseconds 100
  }
}
$c.Close()
[Console]::Out.Write($out)
