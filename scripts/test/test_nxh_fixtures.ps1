$ErrorActionPreference = 'Stop'

$Root = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$Compiler = Join-Path $Root 'src\user\nexushl\compiler\nxhc.py'
$LibDir = Join-Path $Root 'src\user\nexushl\lib'
$TestDir = Join-Path $Root 'tests\nxh'
$OutDir = Join-Path $Root 'build\nxh\tests'

New-Item -ItemType Directory -Path $OutDir -Force | Out-Null

Get-ChildItem -Path $TestDir -Filter '*.nxh' | ForEach-Object {
    $name = [IO.Path]::GetFileNameWithoutExtension($_.Name)
    $out = Join-Path $OutDir ($name + '.asm')
    Write-Host "[nxh-fixture] compile $($_.Name)" -ForegroundColor Yellow
    python $Compiler $_.FullName -o $out -L $LibDir --prefix "test_$name" --embed --emit-sigs
    if ($LASTEXITCODE -ne 0) {
        throw "NexusHL fixture compile failed: $($_.Name)"
    }
}

Write-Host '[nxh-fixture] PASS' -ForegroundColor Green
