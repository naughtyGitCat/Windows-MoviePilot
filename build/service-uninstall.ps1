# MoviePilot-V2 Windows service remover
# Invoked by Inno Setup [UninstallRun] section before files are deleted.

param(
    [string]$InstallDir = $PSScriptRoot,
    [string]$ServiceName = "MoviePilot-V2"
)

$ErrorActionPreference = "Continue"

$svc = Get-Service $ServiceName -ErrorAction SilentlyContinue
if (-not $svc) {
    Write-Host "Service '$ServiceName' not present, nothing to do."
    exit 0
}

$nssm = Join-Path $InstallDir "nssm.exe"
if (-not (Test-Path $nssm)) {
    # Fall back to sc.exe if nssm.exe is gone (shouldn't happen during normal uninstall)
    Write-Host "nssm.exe missing; falling back to sc.exe"
    & sc.exe stop $ServiceName 2>&1 | Out-Null
    Start-Sleep 3
    & sc.exe delete $ServiceName 2>&1 | Out-Null
    exit 0
}

Write-Host "Stopping service '$ServiceName'..."
& $nssm stop $ServiceName 2>&1 | Out-Null
Start-Sleep 3

Write-Host "Removing service '$ServiceName'..."
& $nssm remove $ServiceName confirm 2>&1 | Out-Null

# Kill any orphan python that might still be holding port 3000 / 3111 (legacy)
Get-NetTCPConnection -State Listen -LocalPort 3000,3111 -ErrorAction SilentlyContinue | ForEach-Object {
    Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue
}

Write-Host "Service removed."
exit 0
