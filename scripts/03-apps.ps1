Write-Host "📦 03: Downloading app manifest..." -ForegroundColor Yellow

$configUrl = "https://raw.githubusercontent.com/varunhorril/wndws-setup/main/config/apps.json"

try {
    $appConfig = Invoke-RestMethod -Uri $configUrl -ErrorAction Stop
    Write-Host "✅ Manifest loaded successfully." -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to download apps.json from $configUrl" -ForegroundColor Red
    throw "ManifestDownloadFailed"
}

# --- 1. Chocolatey Setup & Apps ---
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "✨ Installing Chocolatey..." -ForegroundColor Gray
    Set-ExecutionPolicy Bypass -Scope Process -Force
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

Write-Host "🚚 Installing Chocolatey Apps..." -ForegroundColor Cyan
foreach ($app in $appConfig.chocolatey) {
    Write-Host " [+] $app"
    choco install $app -y --no-progress --skip-automation-scripts
}

# --- 2. Scoop Setup (Done AFTER Choco Apps to provide a 'buffer') ---
if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "✨ Installing Scoop..." -ForegroundColor Gray
    Set-ExecutionPolicy ExecutionPolicy RemoteSigned -Scope CurrentUser
    iex (Invoke-RestMethod 'https://get.scoop.sh')
}

# Define the absolute path to scoop.cmd to bypass Path issues
$scoopCmd = "$env:USERPROFILE\scoop\shims\scoop.cmd"

Write-Host " 🪣 Adding Scoop 'extras' bucket..."
& $scoopCmd bucket add extras 2>$null

Write-Host "🛠️  Installing Scoop Apps..." -ForegroundColor Cyan
foreach ($app in $appConfig.scoop) {
    Write-Host " [🔧] $app"
    & $scoopCmd install $app
}

# --- 3. Edge Eviction ---
# We check for Vivaldi using the full path in case the 'Get-Command' hasn't updated
$vivaldiPath = "${env:ProgramFiles}\Vivaldi\Application\vivaldi.exe"
if (Test-Path $vivaldiPath) {
    Write-Host "🗑️  Vivaldi verified at $vivaldiPath. Evicting Edge..." -ForegroundColor Red
    $edgeInstaller = Get-Item "C:\Program Files (x86)\Microsoft\Edge\Application\*\Installer\setup.exe" -ErrorAction SilentlyContinue
    if ($edgeInstaller) {
        Start-Process $edgeInstaller.FullName -ArgumentList "--uninstall --system-level --force-uninstall" -Wait
    }
} else {
    Write-Host "⚠️  Vivaldi not found. Edge will stay for now." -ForegroundColor Yellow
}