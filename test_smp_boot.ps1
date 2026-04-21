$ErrorActionPreference = 'Stop'

$Root = $PSScriptRoot
$LogPath = Join-Path $Root 'build\cache32_serial.log'

if (-not (Test-Path $LogPath)) {
    powershell -ExecutionPolicy Bypass -File (Join-Path $Root 'test_cache32_boot.ps1')
}

$serial = Get-Content -Path $LogPath -Raw
if ($serial -notlike '*SMP:*') {
    throw 'Missing SMP serial marker.'
}

$matches = [regex]::Matches($serial, 'SMP:([0-9A-F]{16})/([0-9A-F]{16})/([0-9A-F]{16})/([0-9A-F]{16})/([0-9A-F]{16})')
if ($matches.Count -eq 0) {
    throw 'Missing extended SMP counters.'
}

$last = $matches[$matches.Count - 1]
$detected = [Convert]::ToInt64($last.Groups[1].Value, 16)
$started = [Convert]::ToInt64($last.Groups[3].Value, 16)
$alive = [Convert]::ToInt64($last.Groups[4].Value, 16)

if ($detected -gt 1 -and $started -gt 1 -and $alive -le 1) {
    throw "AP startup inconsistent: started=$started alive=$alive."
}

Write-Host '[smp] PASS' -ForegroundColor Green
