Write-Host "🛠️  04: Setting up Scoop & Dev Tools..." -ForegroundColor Yellow

$configUrl = "https://raw.githubusercontent.com/varunhorril/wndws-setup/main/config/apps.json"

# 1. Fetch JSON
try {
    $appConfig = Invoke-RestMethod -Uri $configUrl -ErrorAction Stop
    $scoopList = $appConfig.scoop
    Write-Host "✅ Manifest loaded. Preparing to install $($scoopList.Count) dev tools." -ForegroundColor Green
} catch {
    Write-Host "⚠️  Could not load apps.json for Scoop. Skipping." -ForegroundColor Yellow
    return # Exit this script but don't crash main.ps1
}

# 2. Scoop Installation
if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "✨ Installing Scoop..." -ForegroundColor Gray
    Set-ExecutionPolicy ExecutionPolicy RemoteSigned -Scope CurrentUser
    try {
        # Using -RunAsAdmin is usually not recommended for Scoop, 
        # but since we are already in an elevated shell, we proceed.
        $installScript = Invoke-RestMethod -Uri 'https://get.scoop.sh'
        Invoke-Expression $installScript
    } catch {
        Write-Host "❌ Scoop installation failed." -ForegroundColor Red
        return
    }
}

# 3. Define absolute path to bypass PATH latency
$scoopCmd = "$env:USERPROFILE\scoop\shims\scoop.cmd"

if (Test-Path $scoopCmd) {
    Write-Host " 🪣 Adding Scoop 'extras' bucket..."
    & $scoopCmd bucket add extras 2>$null

    # 4. Install Scoop Apps
    foreach ($app in $scoopList) {
        Write-Host "🚀 [Scoop]: $app" -ForegroundColor Cyan
        & $scoopCmd install $app
    }
} else {
    Write-Host "❌ Scoop executable not found at $scoopCmd. Path refresh required." -ForegroundColor Red
}