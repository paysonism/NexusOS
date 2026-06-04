$ErrorActionPreference = 'Stop'

# seL4 validity track runner. Validates the machine-checkable invariant files,
# asserts every referenced predicate exists as a global in the NHL invariant
# kernel, and compiles that kernel --forbid-asm --deny-unsafe.

$Root = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$Compiler = Join-Path $Root 'src\user\nexushl\compiler\nxhc.py'
$LibDir = Join-Path $Root 'src\user\nexushl\lib'
$Module = Join-Path $Root 'src\tools\security\invariant_check.nxh'
$InvariantDir = Join-Path $Root 'tests\security\invariants'

foreach ($p in @($Compiler, $Module)) {
    if (-not (Test-Path -LiteralPath $p -PathType Leaf)) { throw "Missing required file: $p" }
}
if (-not (Test-Path -LiteralPath $LibDir -PathType Container)) {
    throw "Missing NexusHL library directory: $LibDir"
}
if (-not (Test-Path -LiteralPath $InvariantDir -PathType Container)) {
    throw "Missing invariant directory: $InvariantDir"
}

function Read-KeyValueFile {
    param([string]$Path)
    $map = @{}
    $lineNo = 0
    foreach ($line in Get-Content -LiteralPath $Path) {
        $lineNo++
        $trim = $line.Trim()
        if ($trim.Length -eq 0 -or $trim.StartsWith('#')) { continue }
        $parts = $trim.Split('=', 2)
        if ($parts.Count -ne 2 -or [string]::IsNullOrWhiteSpace($parts[0])) {
            throw "${Path}:$lineNo invalid line: $line"
        }
        $key = $parts[0].Trim()
        if ($map.ContainsKey($key)) { throw "${Path}:$lineNo duplicate key: $key" }
        $map[$key] = $parts[1].Trim()
    }
    return $map
}

# Collect the predicate names exported by the invariant kernel.
$exported = New-Object 'System.Collections.Generic.HashSet[string]'
foreach ($line in Get-Content -LiteralPath $Module) {
    $m = [regex]::Match($line.Trim(), '^global\s+([A-Za-z_][A-Za-z0-9_]*)\s*;')
    if ($m.Success) { [void]$exported.Add($m.Groups[1].Value) }
}
if ($exported.Count -eq 0) { throw "No exported predicates found in $Module" }

$invariants = @(Get-ChildItem -LiteralPath $InvariantDir -Recurse -File -Filter '*.invariant' | Sort-Object FullName)
if ($invariants.Count -eq 0) { throw "No invariant files found under $InvariantDir" }

Write-Host "[nhl-invariants] Validating $($invariants.Count) invariant(s)..." -ForegroundColor Yellow
$ids = New-Object 'System.Collections.Generic.HashSet[string]'
$validStatus = @('modeled', 'tested', 'proven')
foreach ($inv in $invariants) {
    $data = Read-KeyValueFile -Path $inv.FullName
    foreach ($required in @('invariant', 'title', 'statement', 'compromised', 'denied_authority', 'predicate', 'status')) {
        if (-not $data.ContainsKey($required) -or [string]::IsNullOrWhiteSpace($data[$required])) {
            throw "$($inv.FullName) missing required key: $required"
        }
    }
    if (-not $ids.Add($data['invariant'])) {
        throw "$($inv.FullName) duplicate invariant id: $($data['invariant'])"
    }
    if ($validStatus -notcontains $data['status']) {
        throw "$($inv.FullName) status must be one of $($validStatus -join ', '); got: $($data['status'])"
    }
    if (-not $exported.Contains($data['predicate'])) {
        throw "$($inv.FullName) references predicate '$($data['predicate'])' not exported by invariant_check.nxh"
    }
    Write-Host "[nhl-invariants]   $($data['invariant']) -> $($data['predicate']) [$($data['status'])]"
}

$OutDir = Join-Path ([System.IO.Path]::GetTempPath()) ('nhl-invariants-' + [System.Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
try {
    $outPath = Join-Path $OutDir 'invariant_check.asm'
    Write-Host '[nhl-invariants] compile invariant_check.nxh --forbid-asm --deny-unsafe' -ForegroundColor Yellow
    & python $Compiler $Module -o $outPath -L $LibDir --embed --target kernel --forbid-asm --deny-unsafe
    if ($LASTEXITCODE -ne 0) { throw 'invariant_check.nxh compile failed.' }
}
finally {
    if (Test-Path -LiteralPath $OutDir) { Remove-Item -LiteralPath $OutDir -Recurse -Force }
}

Write-Host '[nhl-invariants] PASS' -ForegroundColor Green
