$ErrorActionPreference = 'Stop'

$Root = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$Compiler = Join-Path $Root 'src\user\nexushl\compiler\nxhc.py'
$LibDir = Join-Path $Root 'src\user\nexushl\lib'
$OutDir = Join-Path $Root 'build\nxh\tests'

New-Item -ItemType Directory -Path $OutDir -Force | Out-Null

Write-Host '[nxhc-security] compile zero-asm kernel intrinsic fixture' -ForegroundColor Yellow
python $Compiler `
    (Join-Path $Root 'tests\nxh_kernel\noasm_intrinsics.nxh') `
    -o (Join-Path $OutDir 'noasm_intrinsics.asm') `
    -L $LibDir --target kernel --embed --forbid-asm
if ($LASTEXITCODE -ne 0) {
    throw 'zero-asm kernel intrinsic fixture failed to compile'
}

Write-Host '[nxhc-security] compile guarded boot layout fixture' -ForegroundColor Yellow
python $Compiler `
    (Join-Path $Root 'tests\nxh_boot\boot_layout.nxh') `
    -o (Join-Path $OutDir 'boot_layout.asm') `
    -L $LibDir --target boot --embed
if ($LASTEXITCODE -ne 0) {
    throw 'boot layout fixture failed to compile'
}

$bootAsm = Get-Content -Path (Join-Path $OutDir 'boot_layout.asm') -Raw
if ($bootAsm -notmatch 'bits 16' -or $bootAsm -notmatch 'org 0x7C00') {
    throw 'boot layout fixture did not emit expected bits/org directives'
}

Write-Host '[nxhc-security] compile structured boot function fixture' -ForegroundColor Yellow
python $Compiler `
    (Join-Path $Root 'tests\nxh_boot\boot_fn.nxh') `
    -o (Join-Path $OutDir 'boot_fn.asm') `
    -L $LibDir --target boot --embed
if ($LASTEXITCODE -ne 0) {
    throw 'structured boot function fixture failed to compile'
}

# Regression (PR #22 review): a multi-register boot call (ah/al/bx ...) must
# stage every argument before writing any target register, so a register set
# early (ah) can't be clobbered by a later arg's accumulator load. After the
# fix the targets are popped in reverse, so ah is written on the line directly
# before the BIOS call. If the inline-write bug returns, a `mov ax, <imm>` for a
# later arg lands between the ah write and the call and this match fails.
Write-Host '[nxhc-security] boot regcall stages args without clobber (ah preserved)' -ForegroundColor Yellow
$bootFnAsm = Get-Content -Path (Join-Path $OutDir 'boot_fn.asm') -Raw
if ($bootFnAsm -notmatch '(?m)^\s*mov ah, \w+\s*\r?\n\s*call bios_teletype\b') {
    throw 'boot regcall regression: AH is not set immediately before the BIOS call (argument staging clobber)'
}

$Nasm = 'C:\Tools\nasm-2.16.03\nasm.exe'
if (-not (Test-Path $Nasm)) {
    $cmd = Get-Command nasm -ErrorAction SilentlyContinue
    if ($cmd) { $Nasm = $cmd.Source }
}
if (Test-Path $Nasm) {
    & $Nasm -f bin -o (Join-Path $OutDir 'boot_fn.bin') (Join-Path $OutDir 'boot_fn.asm')
    if ($LASTEXITCODE -ne 0) {
        throw 'structured boot function fixture failed to assemble with NASM'
    }

    Write-Host '[nxhc-security] compile and assemble exact boot sector fixture' -ForegroundColor Yellow
    python $Compiler `
        (Join-Path $Root 'tests\nxh_boot\boot_sector.nxh') `
        -o (Join-Path $OutDir 'boot_sector.asm') `
        -L $LibDir --target boot --embed
    if ($LASTEXITCODE -ne 0) {
        throw 'boot sector fixture failed to compile'
    }
    & $Nasm -f bin -o (Join-Path $OutDir 'boot_sector.bin') (Join-Path $OutDir 'boot_sector.asm')
    if ($LASTEXITCODE -ne 0) {
        throw 'boot sector fixture failed to assemble with NASM'
    }
    $sector = [System.IO.File]::ReadAllBytes((Join-Path $OutDir 'boot_sector.bin'))
    if ($sector.Length -ne 512) {
        throw "boot sector fixture size was $($sector.Length), expected 512"
    }
    if ($sector[510] -ne 0x55 -or $sector[511] -ne 0xAA) {
        throw 'boot sector fixture did not end with 55 AA signature'
    }

    Write-Host '[nxhc-security] compile + assemble A20 port-IO boot leaf (zero-asm migration)' -ForegroundColor Yellow
    python $Compiler `
        (Join-Path $Root 'tests\nxh_boot\a20_wait.nxh') `
        -o (Join-Path $OutDir 'a20_wait.asm') `
        -L $LibDir --target boot --forbid-asm
    if ($LASTEXITCODE -ne 0) {
        throw 'a20_wait boot leaf failed to compile under --forbid-asm'
    }
    & $Nasm -f bin -o (Join-Path $OutDir 'a20_wait.bin') (Join-Path $OutDir 'a20_wait.asm')
    if ($LASTEXITCODE -ne 0) {
        throw 'a20_wait boot leaf failed to assemble with NASM'
    }
    # It is a declared I/O boundary (unsafe boot_io) -> --deny-unsafe must reject.
    $OldEAP = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    python $Compiler `
        (Join-Path $Root 'tests\nxh_boot\a20_wait.nxh') `
        -o (Join-Path $OutDir 'a20_wait_deny.asm') `
        -L $LibDir --target boot --deny-unsafe *> $null
    $A20DenyExit = $LASTEXITCODE
    $ErrorActionPreference = $OldEAP
    if ($A20DenyExit -eq 0) {
        throw '--deny-unsafe accepted the a20_wait I/O boundary module'
    }
} else {
    Write-Host '[nxhc-security] NASM not found; skipped boot_fn assembly check' -ForegroundColor DarkYellow
}

Write-Host '[nxhc-security] reject inline asm under --forbid-asm' -ForegroundColor Yellow
$OldErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
python $Compiler `
    (Join-Path $Root 'tests\nxh_kernel\asm_forbidden.nxh') `
    -o (Join-Path $OutDir 'asm_forbidden.asm') `
    -L $LibDir --target kernel --embed --forbid-asm *> $null
$RejectForbidAsmExit = $LASTEXITCODE
$ErrorActionPreference = $OldErrorActionPreference
if ($RejectForbidAsmExit -eq 0) {
    throw '--forbid-asm accepted an inline asm block'
}

Write-Host '[nxhc-security] reject inline asm under --target boot' -ForegroundColor Yellow
$OldErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
python $Compiler `
    (Join-Path $Root 'tests\nxh_kernel\asm_forbidden.nxh') `
    -o (Join-Path $OutDir 'asm_forbidden_boot.asm') `
    -L $LibDir --target boot --embed *> $null
$RejectBootAsmExit = $LASTEXITCODE
$ErrorActionPreference = $OldErrorActionPreference
if ($RejectBootAsmExit -eq 0) {
    throw '--target boot accepted an inline asm block'
}

Write-Host '[nxhc-security] reject boot unsafe operation without capability' -ForegroundColor Yellow
$OldErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
python $Compiler `
    (Join-Path $Root 'tests\nxh_boot\boot_unsafe_forbidden.nxh') `
    -o (Join-Path $OutDir 'boot_unsafe_forbidden.asm') `
    -L $LibDir --target boot --embed *> $null
$RejectBootUnsafeExit = $LASTEXITCODE
$ErrorActionPreference = $OldErrorActionPreference
if ($RejectBootUnsafeExit -eq 0) {
    throw '--target boot accepted intn() without unsafe boot_int'
}

Write-Host '[nxhc-security] reject declared unsafe under --deny-unsafe' -ForegroundColor Yellow
$OldErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
python $Compiler `
    (Join-Path $Root 'tests\nxh_boot\boot_unsafe_decl.nxh') `
    -o (Join-Path $OutDir 'boot_unsafe_decl.asm') `
    -L $LibDir --target boot --embed --deny-unsafe *> $null
$RejectDenyUnsafeExit = $LASTEXITCODE
$ErrorActionPreference = $OldErrorActionPreference
if ($RejectDenyUnsafeExit -eq 0) {
    throw '--deny-unsafe accepted unsafe capability declarations'
}

Write-Host '[nxhc-security] PASS' -ForegroundColor Green
