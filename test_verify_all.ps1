$ErrorActionPreference = 'Stop'

$Root = $PSScriptRoot

function Invoke-Step {
    param(
        [string]$Name,
        [scriptblock]$Action,
        [switch]$RequireCleanOutput
    )

    Write-Host "[verify] $Name" -ForegroundColor Yellow
    $output = & $Action 2>&1
    if ($output) {
        $output | Out-Host
    }
    if ($LASTEXITCODE -ne 0) {
        throw "$Name failed with exit code $LASTEXITCODE"
    }
    if ($RequireCleanOutput) {
        $joined = ($output | Out-String)
        if ($joined -match '(?im)\bwarning:|\berror:') {
            throw "$Name emitted assembler warnings or errors."
        }
    }
    Write-Host "[verify] $Name OK" -ForegroundColor Green
}

Invoke-Step 'Source guards' {
    powershell -ExecutionPolicy Bypass -File (Join-Path $Root 'test_source_guards.ps1')
}

Invoke-Step 'BIOS build' -RequireCleanOutput {
    powershell -ExecutionPolicy Bypass -File (Join-Path $Root 'build_bios.ps1')
}

Invoke-Step 'BIOS release build' -RequireCleanOutput {
    powershell -ExecutionPolicy Bypass -File (Join-Path $Root 'build_bios.ps1') -Release
}

Invoke-Step 'UEFI build' -RequireCleanOutput {
    powershell -ExecutionPolicy Bypass -File (Join-Path $Root 'build_uefi.ps1')
}

Invoke-Step 'UEFI release build' -RequireCleanOutput {
    powershell -ExecutionPolicy Bypass -File (Join-Path $Root 'build_uefi.ps1') -Release
}

Invoke-Step 'UEFI smoke boot' {
    powershell -ExecutionPolicy Bypass -File (Join-Path $Root 'test_smoke_uefi.ps1')
}

Write-Host '[verify] PASS' -ForegroundColor Green
