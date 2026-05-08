$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $PSScriptRoot
$KernelBuild = Join-Path $Root 'src\kernel\kernel_build.asm'
$OutDir = Join-Path $Root 'build\reports'
$OutPath = Join-Path $OutDir 'source-map.md'
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$includeLines = Select-String -Path $KernelBuild -Pattern '^\s*%include\s+"([^"]+)"'
$includes = foreach ($m in $includeLines) {
    [pscustomobject]@{ Line = $m.LineNumber; Path = $m.Matches[0].Groups[1].Value }
}

$asmFiles = Get-ChildItem -Path (Join-Path $Root 'src') -Recurse -File -Include *.asm,*.inc |
    Where-Object { $_.FullName -notmatch '\\\.claude\\' }

$globals = foreach ($f in $asmFiles) {
    Select-String -Path $f.FullName -Pattern '^\s*global\s+(.+)$' | ForEach-Object {
        foreach ($name in ($_.Matches[0].Groups[1].Value -split ',')) {
            $trim = $name.Trim()
            if ($trim) {
                [pscustomobject]@{ File = $_.Path.Substring($Root.Length + 1); Line = $_.LineNumber; Name = $trim }
            }
        }
    }
}

$fixed = foreach ($f in $asmFiles) {
    Select-String -Path $f.FullName -Pattern '(?<![A-Za-z0-9_])0x[0-9A-Fa-f]{5,}' | ForEach-Object {
        [pscustomobject]@{ File = $_.Path.Substring($Root.Length + 1); Line = $_.LineNumber; Text = $_.Line.Trim() }
    }
}

$md = New-Object System.Collections.Generic.List[string]
$md.Add('# Generated Source Map')
$md.Add('')
$md.Add('Generated from `src/kernel/kernel_build.asm` and live source scans.')
$md.Add('')
$md.Add('## Kernel Include Order')
foreach ($i in $includes) { $md.Add(('- line {0}: `{1}`' -f $i.Line, $i.Path)) }
$md.Add('')
$md.Add('## Exported Labels')
foreach ($g in ($globals | Sort-Object File,Line,Name)) { $md.Add(('- `{0}` - `{1}:{2}`' -f $g.Name, $g.File, $g.Line)) }
$md.Add('')
$md.Add('## Fixed Address References')
foreach ($x in ($fixed | Sort-Object File,Line)) { $md.Add(('- `{0}:{1}` - `{2}`' -f $x.File, $x.Line, $x.Text)) }

Set-Content -Path $OutPath -Value $md -Encoding ASCII
Write-Host "source map: $OutPath"
