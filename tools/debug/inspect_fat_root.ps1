$Root = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$b = [System.IO.File]::ReadAllBytes((Join-Path $Root 'build\data.img'))
# rootDirOff = 320*512 (partStart) + 1*512 (reserved) + 2*FAT_size*512
# FAT_size: BPB at part start + 22; let's just compute manually from BPB
$bpb = 320 * 512
$bytesPerSect = [int]$b[$bpb+11] -bor ([int]$b[$bpb+12] -shl 8)
$reserved = [int]$b[$bpb+14] -bor ([int]$b[$bpb+15] -shl 8)
$numFats = [int]$b[$bpb+16]
$fatSz = [int]$b[$bpb+22] -bor ([int]$b[$bpb+23] -shl 8)
$rootOff = [int]$bpb + ($reserved + $numFats * $fatSz) * $bytesPerSect
Write-Host ("bpb=$bpb bytesPerSect=$bytesPerSect reserved=$reserved numFats=$numFats fatSz=$fatSz rootOff=" + ('{0:X}' -f $rootOff))
Write-Host "rootDirOff=$('{0:X}' -f $rootOff)"
for ($i = 0; $i -lt 8; $i++) {
    $o = $rootOff + $i * 32
    $name = [System.Text.Encoding]::ASCII.GetString($b, $o, 11)
    $attr = '{0:X2}' -f $b[$o+11]
    $byte0 = '{0:X2}' -f $b[$o]
    Write-Host ("entry " + $i + ": '" + $name + "' attr=" + $attr + " first=" + $byte0)
}
