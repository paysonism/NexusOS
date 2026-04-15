param(
    [int]$Ms = 1500
)

$ErrorActionPreference = 'Stop'

$c = [System.Net.Sockets.TcpClient]::new()
$c.Connect('127.0.0.1', 5555)
$s = $c.GetStream()
$buf = New-Object byte[] 65536
$enc = [System.Text.Encoding]::ASCII
$out = New-Object System.Text.StringBuilder
$deadline = [DateTime]::UtcNow.AddMilliseconds($Ms)

while ([DateTime]::UtcNow -lt $deadline) {
    while ($s.DataAvailable) {
        $n = $s.Read($buf, 0, $buf.Length)
        if ($n -le 0) { break }
        [void]$out.Append($enc.GetString($buf, 0, $n))
    }
    Start-Sleep -Milliseconds 50
}

$c.Close()
$out.ToString()
