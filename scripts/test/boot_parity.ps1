# ============================================================================
# boot_parity.ps1 - Fast byte-parity harness for boot artifacts
# ----------------------------------------------------------------------------
# Re-assembles ONLY the boot artifacts (UEFI loader BOOTX64.EFI, BIOS mbr.bin,
# stage2.bin) and compares their SHA256 against a recorded baseline. This is
# the safety net for Phase 1 "Excellent" maintainability refactors: renaming a
# magic literal to a named constant with the same value MUST emit identical
# bytes. Run BEFORE a refactor with -Record to capture the baseline, then run
# AFTER (no flag) to verify byte-identity.
#
#   Record baseline:  pwsh scripts/test/boot_parity.ps1 -Record
#   Verify parity:    pwsh scripts/test/boot_parity.ps1
#
# cwd MUST be the repo root (root-relative %includes in uefi_loader.asm).
# This does NOT build the kernel; for full behavior parity use build_uefi.ps1.
# ============================================================================
param([switch]$Record)

$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $Root   # uefi_loader.asm uses root-relative %includes
$NASM = 'C:\Tools\nasm-2.16.03\nasm.exe'
$SRC = [string](Join-Path $Root 'src')
$INC = [string](Join-Path $SRC 'include')
$BUILD = Join-Path $Root 'build'
$OUT = Join-Path $BUILD 'parity'
$BASELINE = Join-Path $OUT 'baseline.sha256'
if (-not (Test-Path $OUT)) { New-Item -ItemType Directory -Path $OUT | Out-Null }

# Assemble the three boot artifacts into the parity scratch dir. stderr (NASM
# warnings) is written to a temp file so the PowerShell native-stderr wrapper
# does not abort under -ErrorAction Stop.
function Invoke-Nasm($srcFile, $outfile) {
    # NOTE: PowerShell variables are case-insensitive, so a param named $src
    # would alias the script-level $SRC. Use $srcFile.
    $incArg = ($INC -replace '\\','/') + '/'
    $bootArg = ((Join-Path $SRC 'boot') -replace '\\','/') + '/'
    $nasmArgs = @('-f','bin','-o',$outfile,'-I',$incArg,'-I',$bootArg,$srcFile)
    $saved = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $stderr = (& $NASM @nasmArgs 2>&1) |
        Where-Object { $_ -is [System.Management.Automation.ErrorRecord] }
    $code = $LASTEXITCODE
    $ErrorActionPreference = $saved
    $real = $stderr | Where-Object { "$_" -notmatch 'warning' }
    if ($code -ne 0) {
        Write-Host "  NASM FAILED ($srcFile):" -ForegroundColor Red
        $real | ForEach-Object { Write-Host "    $_" -ForegroundColor Red }
        exit 1
    }
}

$efi = Join-Path $OUT 'BOOTX64.EFI'
$mbr = Join-Path $OUT 'mbr.bin'
$stage2 = Join-Path $OUT 'stage2.bin'

Invoke-Nasm (Join-Path $SRC 'boot\uefi_loader.asm') $efi
Invoke-Nasm (Join-Path $SRC 'boot\mbr.asm')         $mbr
Invoke-Nasm (Join-Path $SRC 'boot\stage2.asm')      $stage2

$artifacts = @{ 'BOOTX64.EFI' = $efi; 'mbr.bin' = $mbr; 'stage2.bin' = $stage2 }
$hashes = [ordered]@{}
foreach ($name in $artifacts.Keys | Sort-Object) {
    $hashes[$name] = (Get-FileHash $artifacts[$name] -Algorithm SHA256).Hash.ToLower()
}

if ($Record) {
    $hashes.GetEnumerator() | ForEach-Object { "$($_.Value)  $($_.Key)" } | Set-Content -Encoding ascii $BASELINE
    Write-Host "Baseline recorded -> $BASELINE" -ForegroundColor Green
    Get-Content $BASELINE | ForEach-Object { Write-Host "  $_" }
    exit 0
}

if (-not (Test-Path $BASELINE)) {
    Write-Host "No baseline. Run with -Record first." -ForegroundColor Red
    exit 1
}

$base = @{}
Get-Content $BASELINE | ForEach-Object {
    $p = $_ -split '\s+', 2
    if ($p.Length -eq 2) { $base[$p[1].Trim()] = $p[0].Trim() }
}

$fail = $false
foreach ($name in $hashes.Keys) {
    if ($base[$name] -eq $hashes[$name]) {
        Write-Host "  OK  $name  $($hashes[$name])" -ForegroundColor Green
    } else {
        $fail = $true
        Write-Host "  DIFF $name" -ForegroundColor Red
        Write-Host "    baseline: $($base[$name])" -ForegroundColor Red
        Write-Host "    current:  $($hashes[$name])" -ForegroundColor Red
    }
}
if ($fail) { Write-Host "PARITY FAIL" -ForegroundColor Red; exit 1 }
Write-Host "PARITY OK (byte-identical)" -ForegroundColor Green
