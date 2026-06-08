$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $PSScriptRoot
$OutDir = Join-Path $Root 'build\reports'
$OutPath = Join-Path $OutDir 'complexity-dashboard.md'
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$files = Get-ChildItem -Path (Join-Path $Root 'src') -Recurse -File -Include *.asm,*.inc |
    Where-Object { $_.FullName -notmatch '\\\.claude\\' }

$large = foreach ($f in $files) {
    $count = (Get-Content -Path $f.FullName | Measure-Object -Line).Lines
    if ($count -gt 700) {
        [pscustomobject]@{ File = $f.FullName.Substring($Root.Length + 1); Lines = $count }
    }
}

$exports = foreach ($f in $files) {
    $n = (Select-String -Path $f.FullName -Pattern '^\s*global\s+' | Measure-Object).Count
    if ($n -gt 0) { [pscustomobject]@{ File = $f.FullName.Substring($Root.Length + 1); Count = $n } }
}

$fixed = foreach ($f in $files) {
    $n = (Select-String -Path $f.FullName -Pattern '(?<![A-Za-z0-9_])0x[0-9A-Fa-f]{5,}' | Measure-Object).Count
    if ($n -gt 0) { [pscustomobject]@{ File = $f.FullName.Substring($Root.Length + 1); Count = $n } }
}

$todo = foreach ($f in $files) {
    $n = (Select-String -Path $f.FullName -Pattern '\b(TODO|STUB|FIXME)\b' -CaseSensitive | Measure-Object).Count
    if ($n -gt 0) { [pscustomobject]@{ File = $f.FullName.Substring($Root.Length + 1); Count = $n } }
}

$md = New-Object System.Collections.Generic.List[string]
$md.Add('# Complexity Dashboard')
$md.Add('')
$md.Add('## Large Files Over 700 Lines')
foreach ($x in ($large | Sort-Object Lines -Descending)) { $md.Add(('- `{0}` - {1} lines' -f $x.File, $x.Lines)) }
$md.Add('')
$md.Add('## Public Label Counts')
foreach ($x in ($exports | Sort-Object Count -Descending)) { $md.Add(('- `{0}` - {1}' -f $x.File, $x.Count)) }
$md.Add('')
$md.Add('## Fixed Address Counts')
foreach ($x in ($fixed | Sort-Object Count -Descending)) { $md.Add(('- `{0}` - {1}' -f $x.File, $x.Count)) }
$md.Add('')
$md.Add('## TODO/STUB/FIXME Counts')
foreach ($x in ($todo | Sort-Object Count -Descending)) { $md.Add(('- `{0}` - {1}' -f $x.File, $x.Count)) }

Set-Content -Path $OutPath -Value $md -Encoding ASCII
Write-Host "dashboard: $OutPath"
