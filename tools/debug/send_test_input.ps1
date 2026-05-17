Start-Sleep -Seconds 6
$c = New-Object System.Net.Sockets.TcpClient('127.0.0.1',5555)
$s = $c.GetStream()
$s.Write([byte[]]@(0x01,0x34),0,2)
Start-Sleep -Milliseconds 1000
$s.Write([byte[]]@(0x61),0,1)
Start-Sleep -Milliseconds 2000
$buf = New-Object byte[] 16384
$total = ''
while ($s.DataAvailable) {
  $n = $s.Read($buf,0,16384)
  $total += [System.Text.Encoding]::ASCII.GetString($buf,0,$n)
}
$c.Close()
$total | Out-File -Encoding ascii _test_output.txt
