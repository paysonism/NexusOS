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
New-Item -Path $OUT_DIR -ItemType Directory -Force | Out-Null

Write-Host ''
Write-Host '  NexusHL Build' -ForegroundColor Cyan
Write-Host '  =============' -ForegroundColor Cyan

$count = 0
Get-ChildItem -Path $APP_DIR -Filter '*.nxh' | ForEach-Object {
    $in = $_.FullName
    $name = [IO.Path]::GetFileNameWithoutExtension($_.Name)
    $asm = Join-Path $OUT_DIR ($name + '.asm')
    Write-Host "  compile $name.nxh -> $name.asm" -ForegroundColor Yellow
    & $PY $COMPILER $in -o $asm -L $LIB_DIR --prefix $name
    if ($LASTEXITCODE -ne 0) { Write-Host '    FAILED compile' -ForegroundColor Red; exit 1 }

    if ($Verify) {
        $obj = Join-Path $OUT_DIR ($name + '.bin')
        & $NASM -f elf64 -o $obj $asm
        if ($LASTEXITCODE -ne 0) { Write-Host '    FAILED nasm verify' -ForegroundColor Red; exit 1 }
        $sz = (Get-Item $obj).Length
        Write-Host "    OK nasm verify ($sz bytes)" -ForegroundColor Green
    }
    $count++
}

Write-Host "  Built $count unit(s)." -ForegroundColor Green
