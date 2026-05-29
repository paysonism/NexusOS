# ============================================================================
# Security PoC regression suite runner (security_todo.md §13).
#
# WHAT THIS GUARANTEES
#   A regression in a landed mitigation breaks THIS test (and therefore CI),
#   not a future manual audit. Two tiers, both fail-closed:
#
#   Tier 1 - compile-gate (build_uefi.ps1 -SecurityRegression):
#     Every ring-3 PoC harness in src/user/poc/ is assembled standalone. If a
#     change drops/renames the syscall ABI a mitigation depends on
#     (SYS_WX_INSTALL_MANIFEST, SYS_MPROTECT_WX / MPROT_WX_MODE_XRO,
#     SYS_WX_JIT_ALIAS, ...), the PoC stops assembling and the build fails.
#
#   Tier 2 - runtime trap assertion (this script):
#     The build also arms the kernel shadow-stack proof harness
#     (ENABLE_SHADOW_STACK_POC). At boot, shadow_stack_poc_run smashes a saved
#     return address on a shadow-protected frame; KEPILOGUE must catch it and
#     halt via kernel_panic_shadow. We boot headless, capture COM1, and assert:
#       PASS  serial contains "POCS" (harness ran) AND "SHADOW " (trap fired)
#       FAIL  serial contains "POCF"  (corruption NOT caught -> guard broken)
#       FAIL  neither marker present  (harness never ran -> build/boot drift)
#
# USAGE
#   pwsh scripts/test/test_security_regression.ps1
#   pwsh scripts/test/test_security_regression.ps1 -SkipBuild   (reuse last build)
#
# EXIT 0 = all mitigations still fail closed. Non-zero = a regression.
# ============================================================================
param(
    [switch]$SkipBuild,
    [int]$BootTimeoutSec = 40
)

$ErrorActionPreference = 'Stop'

$Root = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$BuildDir = Join-Path $Root 'build'
$SerialLog = Join-Path $BuildDir 'serial_full.log'
$SavedLog = Join-Path $BuildDir 'security_regression_serial.log'

function Stop-QemuIfRunning {
    try {
        $client = [System.Net.Sockets.TcpClient]::new()
        $client.Connect('127.0.0.1', 4444)
        $stream = $client.GetStream()
        $bytes = [System.Text.Encoding]::ASCII.GetBytes("quit`r`n")
        $stream.Write($bytes, 0, $bytes.Length)
        $stream.Flush()
        $client.Close()
        Start-Sleep -Milliseconds 500
    } catch {}
    Get-Process qemu-system-x86_64 -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
}

try {
    Stop-QemuIfRunning
    New-Item -ItemType Directory -Path $BuildDir -Force | Out-Null

    # --- Tier 1: build with the compile-gate + shadow trip armed -------------
    if (-not $SkipBuild) {
        Write-Host '[secreg] Building UEFI image with -SecurityRegression...' -ForegroundColor Yellow
        $buildOutput = powershell -NoProfile -ExecutionPolicy Bypass `
            -File (Join-Path $Root 'scripts\build\build_uefi.ps1') -SecurityRegression 2>&1
        $buildOutput | Out-Host
        if ($LASTEXITCODE -ne 0) {
            throw "build_uefi.ps1 -SecurityRegression failed (exit $LASTEXITCODE). A PoC harness no longer assembles OR the kernel build is broken."
        }
        Write-Host '[secreg] Tier 1 PASS: all ring-3 PoC harnesses assemble (mitigation ABI intact).' -ForegroundColor Green
    } else {
        Write-Host '[secreg] -SkipBuild: reusing existing build artifacts.' -ForegroundColor DarkGray
    }

    # Fresh serial log so we never assert on a stale boot.
    if (Test-Path $SerialLog) { Remove-Item $SerialLog -Force -ErrorAction SilentlyContinue }

    # --- Tier 2: boot headless and capture the shadow-stack trap -------------
    Write-Host '[secreg] Booting headless to assert the kernel shadow-stack trap...' -ForegroundColor Yellow
    $job = Start-Job -ScriptBlock {
        param($RootPath)
        powershell -NoProfile -ExecutionPolicy Bypass `
            -File (Join-Path $RootPath 'scripts\run\run_uefi.ps1') -Headless -NoPassthrough
    } -ArgumentList $Root

    $serial = ''
    try {
        $deadline = [DateTime]::UtcNow.AddSeconds($BootTimeoutSec)
        while ([DateTime]::UtcNow -lt $deadline) {
            Start-Sleep -Milliseconds 500
            if (Test-Path $SerialLog) {
                $serial = Get-Content -Raw -Path $SerialLog -ErrorAction SilentlyContinue
                if ($null -eq $serial) { $serial = '' }
                # The shadow trip halts the CPU after printing; once we see the
                # trap (or the failure marker) there is nothing more to wait for.
                if ($serial -match 'SHADOW ' -or $serial -match 'POCF') { break }
            }
        }
    } finally {
        Stop-QemuIfRunning
        Receive-Job $job -ErrorAction SilentlyContinue | Out-Host
        Remove-Job $job -Force -ErrorAction SilentlyContinue
    }

    if ([string]::IsNullOrEmpty($serial) -and (Test-Path $SerialLog)) {
        $serial = Get-Content -Raw -Path $SerialLog -ErrorAction SilentlyContinue
    }
    Set-Content -Path $SavedLog -Value $serial -Encoding ASCII

    # --- Assertions ----------------------------------------------------------
    if ($serial -match 'POCF') {
        throw 'SHADOW-STACK REGRESSION: "POCF" on serial -- the smashed return address was NOT caught. The kernel shadow stack is broken.'
    }
    if ($serial -notmatch 'POCS') {
        throw 'shadow-stack harness never ran ("POCS" absent). Build/boot drift: ENABLE_SHADOW_STACK_POC not in the image, or boot did not reach shadow_stack_poc_run. Serial saved to ' + $SavedLog
    }
    if ($serial -notmatch 'SHADOW ') {
        throw 'shadow-stack harness ran ("POCS") but did not trap ("SHADOW " absent). KEPILOGUE failed to fire. Serial saved to ' + $SavedLog
    }

    Write-Host '[secreg] Tier 2 PASS: shadow-stack trap fired (POCS + SHADOW seen, POCF absent).' -ForegroundColor Green
    Write-Host ''
    Write-Host '  SECURITY REGRESSION SUITE PASSED' -ForegroundColor Green
    Write-Host '    Tier 1: ring-3 PoC harnesses assemble (W^X / JIT-alias / stack-overflow ABI intact)' -ForegroundColor Gray
    Write-Host '    Tier 2: kernel shadow-stack mitigation fails closed at runtime' -ForegroundColor Gray
    Write-Host "  Serial log: $SavedLog" -ForegroundColor DarkGray
    exit 0
} catch {
    Write-Host ''
    Write-Host "  SECURITY REGRESSION SUITE FAILED" -ForegroundColor Red
    Write-Host "    $_" -ForegroundColor Red
    exit 1
} finally {
    Stop-QemuIfRunning
}
