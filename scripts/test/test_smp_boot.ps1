$ErrorActionPreference = 'Stop'

$Root = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$LogPath = Join-Path $Root 'build\cache32_serial.log'

Remove-Item -Path $LogPath -Force -ErrorAction SilentlyContinue
powershell -ExecutionPolicy Bypass -File (Join-Path $Root 'scripts\test\test_cache32_boot.ps1')
if ($LASTEXITCODE -ne 0) {
    throw "Cache32Max boot log refresh failed with exit code $LASTEXITCODE."
}
if (-not (Test-Path $LogPath)) {
    throw 'Cache32Max boot log refresh did not create cache32_serial.log.'
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
$target = [Convert]::ToInt64($last.Groups[2].Value, 16)
$started = [Convert]::ToInt64($last.Groups[3].Value, 16)
$alive = [Convert]::ToInt64($last.Groups[4].Value, 16)

if ($target -gt 1 -and ($started -le 1 -or $alive -le 1)) {
    throw "AP startup did not start QEMU APs: target=$target started=$started alive=$alive."
}

Write-Host '[smp] PASS' -ForegroundColor Green
