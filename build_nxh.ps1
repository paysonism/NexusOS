# NexusHL build hook.
# Compiles every *.nxh under src/user/nexushl/apps to build/nxh/*.asm.
# Does NOT touch the kernel build. Integration into apps.asm is an explicit
# opt-in step handled by whoever wants to wire a HL app into the image.

param(
    [switch]$Verify = $true
)

$ErrorActionPreference = 'Stop'

$NASM = 'C:\Tools\nasm-2.16.03\nasm.exe'
$PY   = 'python'
$ROOT = $PSScriptRoot
$COMPILER = Join-Path $ROOT 'src\user\nexushl\compiler\nxhc.py'
$APP_DIR  = Join-Path $ROOT 'src\user\nexushl\apps'
$LIB_DIR  = Join-Path $ROOT 'src\user\nexushl\lib'
$OUT_DIR  = Join-Path $ROOT 'build\nxh'
$ManifestPath = Join-Path $OUT_DIR 'manifest.json'
$IncludePath  = Join-Path $OUT_DIR 'generated_apps.inc'
New-Item -Path $OUT_DIR -ItemType Directory -Force | Out-Null

Write-Host ''
Write-Host '  NexusHL Build' -ForegroundColor Cyan
Write-Host '  =============' -ForegroundColor Cyan

$count = 0
$manifestApps = @()
$includeLines = @(
    '; NexusHL generated app include - do not edit by hand',
    '; Produced by build_nxh.ps1 before kernel assembly.'
)
Get-ChildItem -Path $APP_DIR -Filter '*.nxh' | ForEach-Object {
    $in = $_.FullName
    $name = [IO.Path]::GetFileNameWithoutExtension($_.Name)
    $asm = Join-Path $OUT_DIR ($name + '.asm')
    Write-Host "  compile $name.nxh -> $name.asm" -ForegroundColor Yellow
    # Embed mode: strips bits/default/section so the output can be %include'd
    # directly from apps.asm without fighting the kernel's section layout.
    & $PY $COMPILER $in -o $asm -L $LIB_DIR --prefix $name --embed --emit-sigs
    if ($LASTEXITCODE -ne 0) { Write-Host '    FAILED compile' -ForegroundColor Red; exit 1 }
    $sz = (Get-Item $asm).Length
    Write-Host "    OK ($sz bytes .asm)" -ForegroundColor Green
    $prefix = "app_hl_$name"
    $manifestApps += [pscustomobject]@{
        name = $name
        source = ("src/user/nexushl/apps/{0}.nxh" -f $name)
        asm = ("build/nxh/{0}.asm" -f $name)
        prefix = $prefix
        draw = ("{0}_draw" -f $prefix)
        click = ("{0}_click" -f $prefix)
        key = ("{0}_key" -f $prefix)
    }
    $includeLines += ('%include "build/nxh/{0}.asm"' -f $name)
    $count++
}

$manifest = [pscustomobject]@{
    sdk = 'NexusHL'
    generatedBy = 'build_nxh.ps1'
    apps = $manifestApps
}
$ascii = [System.Text.Encoding]::ASCII
[System.IO.File]::WriteAllBytes($ManifestPath, $ascii.GetBytes((($manifest | ConvertTo-Json -Depth 5) + [Environment]::NewLine)))
[System.IO.File]::WriteAllBytes($IncludePath, $ascii.GetBytes((($includeLines -join [Environment]::NewLine) + [Environment]::NewLine)))

Write-Host "  Built $count unit(s)." -ForegroundColor Green
Write-Host "  SDK manifest: $ManifestPath" -ForegroundColor DarkGray
Write-Host "  SDK include:  $IncludePath" -ForegroundColor DarkGray

$RegistryTool = Join-Path $ROOT 'tools\build_sig_registry.py'
if (Test-Path $RegistryTool) {
    & $PY $RegistryTool
    if ($LASTEXITCODE -ne 0) { Write-Host '  FAILED signature registry' -ForegroundColor Red; exit 1 }
    Write-Host "  Signature registry: $(Join-Path $ROOT 'build\sig_registry.json')" -ForegroundColor DarkGray
}

$CoverageTool = Join-Path $ROOT 'tools\check_coverage.py'
if (Test-Path $CoverageTool) {
    & $PY $CoverageTool
    if ($LASTEXITCODE -ne 0) { Write-Host '  FAILED signature coverage' -ForegroundColor Red; exit 1 }
}
