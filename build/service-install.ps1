# MoviePilot-V2 Windows service installer
# Invoked by Inno Setup [Run] section, or manually:
#   powershell -ExecutionPolicy Bypass -File service-install.ps1 -InstallDir "C:\Program Files (x86)\MoviePilot"

param(
    [string]$InstallDir = $PSScriptRoot,
    [string]$ServiceName = "MoviePilot-V2"
)

$ErrorActionPreference = "Continue"

$nssm     = Join-Path $InstallDir "nssm.exe"
$python   = Join-Path $InstallDir "Python3.11\python.exe"
$mpDir    = Join-Path $InstallDir "MoviePilot"
$frontend = Join-Path $InstallDir "MoviePilot-Frontend"
$logDir   = Join-Path $InstallDir "service-logs"

if (-not (Test-Path $nssm))   { Write-Error "nssm.exe not found at $nssm";   exit 1 }
if (-not (Test-Path $python)) { Write-Error "python.exe not found at $python"; exit 1 }
if (-not (Test-Path $mpDir))  { Write-Error "MoviePilot dir not found at $mpDir"; exit 1 }

# Stop and remove existing service if present (idempotent re-install)
$existing = Get-Service $ServiceName -ErrorAction SilentlyContinue
if ($existing) {
    Write-Host "Stopping existing service..."
    & $nssm stop $ServiceName 2>&1 | Out-Null
    Start-Sleep 3
    & $nssm remove $ServiceName confirm 2>&1 | Out-Null
    Start-Sleep 1
}

# Free ports if any orphan still holds them (3111 is legacy port from pre-2.10.x forks)
Get-NetTCPConnection -State Listen -LocalPort 3000,3111 -ErrorAction SilentlyContinue | ForEach-Object {
    Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue
}

if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
$stdoutLog = Join-Path $logDir "stdout.log"
$stderrLog = Join-Path $logDir "stderr.log"

Write-Host "Installing service '$ServiceName'..."
& $nssm install $ServiceName $python "app\main.py"
& $nssm set $ServiceName AppDirectory $mpDir
& $nssm set $ServiceName AppEnvironmentExtra "MOVIEPILOT_SERVE_FRONTEND=true" "FRONTEND_PATH=$frontend" "PYTHONUNBUFFERED=1"
& $nssm set $ServiceName Start SERVICE_AUTO_START
& $nssm set $ServiceName AppStdout $stdoutLog
& $nssm set $ServiceName AppStderr $stderrLog
& $nssm set $ServiceName AppRotateFiles 1
& $nssm set $ServiceName AppRotateOnline 1
& $nssm set $ServiceName AppRotateBytes 10485760
& $nssm set $ServiceName AppExit Default Restart
& $nssm set $ServiceName AppRestartDelay 5000
& $nssm set $ServiceName DisplayName "MoviePilot V2 (FastAPI)"
& $nssm set $ServiceName Description "MoviePilot media management server (FastAPI mode, no Nginx)"

Write-Host "Starting service..."
& $nssm start $ServiceName

Start-Sleep 5
$svc = Get-Service $ServiceName -ErrorAction SilentlyContinue
if ($svc -and $svc.Status -eq "Running") {
    Write-Host "Service '$ServiceName' is running. Open http://127.0.0.1:3000 to access."
    exit 0
} else {
    Write-Warning "Service installed but did not start cleanly. Check logs at $logDir"
    exit 1
}
