$c=[System.Net.Sockets.TcpClient]::new(); $c.Connect('127.0.0.1',5555)
$s=$c.GetStream(); $b=New-Object byte[] 65536; $sb=New-Object System.Text.StringBuilder
Write-Host "*** TYPE INTO NOTEPAD NOW *** capturing 6s..." -ForegroundColor Yellow
$end=[DateTime]::UtcNow.AddMilliseconds(6000)
while([DateTime]::UtcNow -lt $end){
  while($s.DataAvailable){$n=$s.Read($b,0,$b.Length); if($n -le 0){break}; [void]$sb.Append([System.Text.Encoding]::ASCII.GetString($b,0,$n))}
  Start-Sleep -Milliseconds 50
}
$c.Close()
Set-Content -Path build/typing_serial.log -Value $sb.ToString() -Encoding ASCII
