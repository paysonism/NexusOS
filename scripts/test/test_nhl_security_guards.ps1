$ErrorActionPreference = 'Stop'

$Root = Resolve-Path (Join-Path $PSScriptRoot '..\..')

$NoAsmGuard = Join-Path $Root 'tools\security\check_no_asm.ps1'
$PrivacyGuard = Join-Path $Root 'tools\security\check_release_privacy.ps1'
$BuildIntegrityGuard = Join-Path $Root 'tools\security\check_build_integrity.ps1'
$PresubmitGuard = Join-Path $Root 'tools\security\check_nhl_presubmit.ps1'
$FixtureGuard = Join-Path $Root 'scripts\test\test_nhl_security_fixtures.ps1'
$InvariantGuard = Join-Path $Root 'scripts\test\test_nhl_invariants.ps1'
$MetaTest = Join-Path $Root 'scripts\test\test_enforcement_meta.ps1'
$Compiler = Join-Path $Root 'src\user\nexushl\compiler\nxhc.py'
$LibDir = Join-Path $Root 'src\user\nexushl\lib'
$SecurityModuleDir = Join-Path $Root 'src\tools\security'

$ExpectedSecurityModules = @(
    'compatibility_check.nxh',
    'fme_memory_encryption_check.nxh',
    'invariant_check.nxh',
    'no_asm_guard.nxh',
    'policy_graph_check.nxh',
    'release_privacy_guard.nxh',
    'revocation_check.nxh',
    'schema_canonical_check.nxh',
    'signed_artifact_check.nxh',
    'signed_envelope.nxh',
    'threshold_check.nxh'
)

if (-not (Test-Path -LiteralPath $NoAsmGuard)) {
    throw "Missing NHL no-ASM guard: $NoAsmGuard"
}
if (-not (Test-Path -LiteralPath $PrivacyGuard)) {
    throw "Missing release privacy guard: $PrivacyGuard"
}
if (-not (Test-Path -LiteralPath $BuildIntegrityGuard)) {
    throw "Missing build-graph integrity guard: $BuildIntegrityGuard"
}
if (-not (Test-Path -LiteralPath $PresubmitGuard)) {
    throw "Missing NHL presubmit guard: $PresubmitGuard"
}
if (-not (Test-Path -LiteralPath $FixtureGuard)) {
    throw "Missing NHL security fixture guard: $FixtureGuard"
}
if (-not (Test-Path -LiteralPath $MetaTest)) {
    throw "Missing enforcement meta-test: $MetaTest"
}
if (-not (Test-Path -LiteralPath $InvariantGuard)) {
    throw "Missing NHL invariant guard: $InvariantGuard"
}
if (-not (Test-Path -LiteralPath $Compiler)) {
    throw "Missing NexusHL compiler: $Compiler"
}
if (-not (Test-Path -LiteralPath $LibDir -PathType Container)) {
    throw "Missing NexusHL library directory: $LibDir"
}
if (-not (Test-Path -LiteralPath $SecurityModuleDir -PathType Container)) {
    throw "Missing NHL security module directory: $SecurityModuleDir"
}

Write-Host '[nhl-security] === Bootstrap host-scanning guards ===' -ForegroundColor Cyan

Write-Host '[nhl-security] Checking release privacy...' -ForegroundColor Yellow
& powershell -NoProfile -ExecutionPolicy Bypass -File $PrivacyGuard
if ($LASTEXITCODE -ne 0) {
    throw 'Release privacy guard failed.'
}

Write-Host '[nhl-security] Checking NHL no-ASM trusted path...' -ForegroundColor Yellow
& powershell -NoProfile -ExecutionPolicy Bypass -File $NoAsmGuard
if ($LASTEXITCODE -ne 0) {
    throw 'NHL no-ASM guard failed.'
}

Write-Host '[nhl-security] Checking legacy assembly inventory (no new .asm/.inc)...' -ForegroundColor Yellow
& powershell -NoProfile -ExecutionPolicy Bypass -File $NoAsmGuard -InventoryGuard
if ($LASTEXITCODE -ne 0) {
    throw 'Legacy assembly inventory guard failed (new or stale .asm/.inc).'
}

Write-Host '[nhl-security] Checking build-graph integrity (legacy vs new-architecture)...' -ForegroundColor Yellow
& powershell -NoProfile -ExecutionPolicy Bypass -File $BuildIntegrityGuard
if ($LASTEXITCODE -ne 0) {
    throw 'Build-graph integrity guard failed (asm/include/nasm leak, generated-as-source, or deprecated import).'
}

Write-Host '[nhl-security] Checking NHL source presubmit rules...' -ForegroundColor Yellow
& powershell -NoProfile -ExecutionPolicy Bypass -File $PresubmitGuard
if ($LASTEXITCODE -ne 0) {
    throw 'NHL presubmit guard failed (raw emitter, inc-public-api, intrinsic, threat-note, release-logging, or raw-user-data).'
}

$missingModules = @()
foreach ($moduleName in $ExpectedSecurityModules) {
    $modulePath = Join-Path $SecurityModuleDir $moduleName
    if (-not (Test-Path -LiteralPath $modulePath -PathType Leaf)) {
        $missingModules += $moduleName
    }
}
if ($missingModules.Count -gt 0) {
    throw "Missing expected NHL security module(s): $($missingModules -join ', ')"
}

$securityModules = @(Get-ChildItem -LiteralPath $SecurityModuleDir -Filter '*.nxh' -File | Sort-Object Name)
if ($securityModules.Count -eq 0) {
    throw "No NHL security policy modules found in $SecurityModuleDir"
}

Write-Host '[nhl-security] === NHL policy-module verification ===' -ForegroundColor Cyan
Write-Host "[nhl-security] Compiling $($securityModules.Count) NHL security module(s) with --target kernel --forbid-asm --deny-unsafe" -ForegroundColor Yellow

$OutDir = Join-Path ([System.IO.Path]::GetTempPath()) ('nhl-security-modules-' + [System.Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
try {
    foreach ($module in $securityModules) {
        $outPath = Join-Path $OutDir ([System.IO.Path]::ChangeExtension($module.Name, '.asm'))
        Write-Host "[nhl-security] compile policy module $($module.Name)" -ForegroundColor Yellow
        & python $Compiler $module.FullName -o $outPath -L $LibDir --embed --target kernel --forbid-asm --deny-unsafe
        if ($LASTEXITCODE -ne 0) {
            throw "NHL policy module compile failed: $($module.Name)"
        }
    }
}
finally {
    if (Test-Path -LiteralPath $OutDir) {
        Remove-Item -LiteralPath $OutDir -Recurse -Force
    }
}

Write-Host '[nhl-security] === NHL checker fixture verification ===' -ForegroundColor Cyan
& powershell -NoProfile -ExecutionPolicy Bypass -File $FixtureGuard
if ($LASTEXITCODE -ne 0) {
    throw 'NHL security fixture guard failed.'
}

Write-Host '[nhl-security] === seL4 validity invariant verification ===' -ForegroundColor Cyan
& powershell -NoProfile -ExecutionPolicy Bypass -File $InvariantGuard
if ($LASTEXITCODE -ne 0) {
    throw 'NHL invariant guard failed.'
}

Write-Host '[nhl-security] === Enforcement meta-tests (the guards have negative tests) ===' -ForegroundColor Cyan
& powershell -NoProfile -ExecutionPolicy Bypass -File $MetaTest
if ($LASTEXITCODE -ne 0) {
    throw 'Enforcement meta-tests failed.'
}

Write-Host '[nhl-security] PASS' -ForegroundColor Green
