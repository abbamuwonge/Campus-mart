# CampusMart one-command startup
$ErrorActionPreference = "Stop"

$root = $PSScriptRoot
$adb = Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"
$python = Join-Path $root ".venv\Scripts\python.exe"
$backend = Join-Path $root "backend"

$phones = @(
    "126801548G014859",
    "R58WA12LD5L",
    "R58M96DPL4J"
)

if (!(Test-Path $adb)) {
    throw "ADB not found at: $adb. Check your Android SDK installation."
}
if (!(Test-Path $python)) {
    throw "Project virtual-environment Python not found at: $python"
}
if (!(Test-Path $backend)) {
    throw "Backend folder not found at: $backend"
}

Write-Host "`nStarting ADB..." -ForegroundColor Cyan
& $adb start-server
if ($LASTEXITCODE -ne 0) { throw "Could not start ADB." }

Write-Host "`nChecking saved CampusMart phones..." -ForegroundColor Cyan
$deviceOutput = & $adb devices

foreach ($phone in $phones) {
    if ($deviceOutput -match "(?m)^$([regex]::Escape($phone))\s+device$") {
        & $adb -s $phone reverse tcp:8000 tcp:8000
        if ($LASTEXITCODE -eq 0) {
            Write-Host "USB forwarding ready: $phone" -ForegroundColor Green
        } else {
            Write-Host "Could not configure forwarding: $phone" -ForegroundColor Red
        }
    } else {
        Write-Host "Not currently connected/authorized (will retry next time): $phone" -ForegroundColor Yellow
    }
}

Write-Host "`nStarting CampusMart backend on port 8000..." -ForegroundColor Cyan
Set-Location $backend
& $python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
