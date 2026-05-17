param(
    [string]$Text,
    [string]$Control,
    [switch]$Enter,
    [string]$HostName = '127.0.0.1',
    [int]$Port = 5555
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrEmpty($Text) -and [string]::IsNullOrEmpty($Control)) {
    throw 'Provide -Text and/or -Control.'
}

$bytes = New-Object 'System.Collections.Generic.List[byte]'
$enc = [System.Text.Encoding]::ASCII

if ($Control) {
    $bytes.Add(0x01)
    foreach ($b in $enc.GetBytes($Control)) {
        $bytes.Add($b)
    }
}

if ($Text) {
    foreach ($b in $enc.GetBytes($Text)) {
        $bytes.Add($b)
    }
}

if ($Enter) {
    $bytes.Add(13)
}

$c = [System.Net.Sockets.TcpClient]::new()
$c.Connect($HostName, $Port)
$s = $c.GetStream()
$payload = $bytes.ToArray()
$s.Write($payload, 0, $payload.Length)
$s.Flush()
Start-Sleep -Milliseconds 200
$c.Close()
