$ErrorActionPreference = 'Stop'

$Root = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$Compiler = Join-Path $Root 'src\user\nexushl\compiler\nxhc.py'
$LibDir = Join-Path $Root 'src\user\nexushl\lib'
$ModuleDir = Join-Path $Root 'src\tools\security'
$FixtureRoot = Join-Path $Root 'tests\security\fixtures'

$ExpectedCheckers = @(
    'signed_artifact_check',
    'signed_envelope',
    'policy_graph_check',
    'fme_memory_encryption_check',
    'threshold_check',
    'schema_canonical_check',
    'revocation_check',
    'compatibility_check'
)

function Read-Fixture {
    param([string]$Path)

    $map = @{}
    $lineNo = 0
    foreach ($line in Get-Content -LiteralPath $Path) {
        $lineNo++
        $trim = $line.Trim()
        if ($trim.Length -eq 0 -or $trim.StartsWith('#')) { continue }
        $parts = $trim.Split('=', 2)
        if ($parts.Count -ne 2 -or [string]::IsNullOrWhiteSpace($parts[0])) {
            throw "${Path}:$lineNo invalid fixture line: $line"
        }
        $key = $parts[0].Trim()
        if ($map.ContainsKey($key)) {
            throw "${Path}:$lineNo duplicate key: $key"
        }
        $map[$key] = $parts[1].Trim()
    }
    return $map
}

if (-not (Test-Path -LiteralPath $Compiler)) {
    throw "Missing NexusHL compiler: $Compiler"
}
if (-not (Test-Path -LiteralPath $LibDir -PathType Container)) {
    throw "Missing NexusHL library directory: $LibDir"
}
if (-not (Test-Path -LiteralPath $ModuleDir -PathType Container)) {
    throw "Missing NHL security module directory: $ModuleDir"
}
if (-not (Test-Path -LiteralPath $FixtureRoot -PathType Container)) {
    throw "Missing security fixture directory: $FixtureRoot"
}

$fixtures = @(Get-ChildItem -LiteralPath $FixtureRoot -Recurse -File -Filter '*.fixture' | Sort-Object FullName)
if ($fixtures.Count -eq 0) {
    throw "No security fixtures found under $FixtureRoot"
}

$seen = @{}
foreach ($checker in $ExpectedCheckers) {
    $seen[$checker] = @{ pass = 0; fail = 0 }
    $modulePath = Join-Path $ModuleDir "$checker.nxh"
    if (-not (Test-Path -LiteralPath $modulePath -PathType Leaf)) {
        throw "Missing NHL module for checker ${checker}: $modulePath"
    }
}

Write-Host "[nhl-security-fixtures] Validating $($fixtures.Count) fixture(s)..." -ForegroundColor Yellow
foreach ($fixture in $fixtures) {
    $data = Read-Fixture -Path $fixture.FullName
    foreach ($required in @('checker', 'expect', 'case')) {
        if (-not $data.ContainsKey($required) -or [string]::IsNullOrWhiteSpace($data[$required])) {
            throw "$($fixture.FullName) missing required key: $required"
        }
    }
    $checker = $data['checker']
    $expect = $data['expect']
    if (-not $seen.ContainsKey($checker)) {
        throw "$($fixture.FullName) references unknown checker: $checker"
    }
    if ($expect -ne 'pass' -and $expect -ne 'fail') {
        throw "$($fixture.FullName) expect must be pass or fail, got: $expect"
    }
    $seen[$checker][$expect]++
}

foreach ($checker in $ExpectedCheckers) {
    if ($seen[$checker]['pass'] -lt 1) {
        throw "Checker $checker has no pass fixture."
    }
    if ($seen[$checker]['fail'] -lt 1) {
        throw "Checker $checker has no fail fixture."
    }
}

$OutDir = Join-Path ([System.IO.Path]::GetTempPath()) ('nhl-security-fixtures-' + [System.Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
try {
    foreach ($checker in $ExpectedCheckers) {
        $modulePath = Join-Path $ModuleDir "$checker.nxh"
        $outPath = Join-Path $OutDir "$checker.asm"
        Write-Host "[nhl-security-fixtures] compile $checker.nxh" -ForegroundColor Yellow
        & python $Compiler $modulePath -o $outPath -L $LibDir --embed --target kernel --forbid-asm --deny-unsafe
        if ($LASTEXITCODE -ne 0) {
            throw "NHL checker compile failed: $checker"
        }
    }
}
finally {
    if (Test-Path -LiteralPath $OutDir) {
        Remove-Item -LiteralPath $OutDir -Recurse -Force
    }
}

Write-Host '[nhl-security-fixtures] PASS' -ForegroundColor Green
