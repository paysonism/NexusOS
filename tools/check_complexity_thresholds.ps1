$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $PSScriptRoot
$Dashboard = Join-Path $Root 'build\reports\complexity-dashboard.md'
if (-not (Test-Path $Dashboard)) {
    powershell -ExecutionPolicy Bypass -File (Join-Path $Root 'tools\complexity_dashboard.ps1') | Out-Host
}

$text = Get-Content -Path $Dashboard -Raw
$large = [regex]::Matches($text, '- `([^`]+)` - ([0-9]+) lines') | ForEach-Object {
    [pscustomobject]@{ File = $_.Groups[1].Value; Lines = [int]$_.Groups[2].Value }
}

$critical = $large | Where-Object {
    $_.File -like 'src\kernel\proc\*' -or
    $_.File -like 'src\kernel\fs\*' -or
    $_.File -like 'src\kernel\gui\*'
}

foreach ($item in $critical) {
    Write-Host ("[complexity] WARN {0}: {1} lines; split candidate requires full verify." -f $item.File, $item.Lines)
}

Write-Host '[complexity] PASS'
