Write-Host "📦 03: Installing Chocolatey & GUI Apps..." -ForegroundColor Yellow

$configUrl = "https://raw.githubusercontent.com/varunhorril/wndws-setup/main/config/apps.json"
$appConfig = Invoke-RestMethod -Uri $configUrl

# --- 1. Chocolatey Setup ---
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "✨ Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# --- 2. Install Choco Apps ---
foreach ($app in $appConfig.chocolatey) {
    Write-Host " [+] $app"
    choco install $app -y --no-progress --skip-automation-scripts
}

# --- 3. Edge Eviction ---
$vivaldiPath = "${env:ProgramFiles}\Vivaldi\Application\vivaldi.exe"
if (Test-Path $vivaldiPath) {
    Write-Host "🗑️  Evicting Edge..." -ForegroundColor Red
    $edgeInstaller = Get-Item "C:\Program Files (x86)\Microsoft\Edge\Application\*\Installer\setup.exe" -ErrorAction SilentlyContinue
    if ($edgeInstaller) {
        Start-Process $edgeInstaller.FullName -ArgumentList "--uninstall --system-level --force-uninstall" -Wait
    }
}