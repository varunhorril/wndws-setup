Write-Host "📦 03: Downloading app manifest..." -ForegroundColor Yellow

$configUrl = "https://raw.githubusercontent.com/varunhorril/wndws-setup/main/config/apps.json"

try {
    $appConfig = Invoke-RestMethod -Uri $configUrl -ErrorAction Stop
    Write-Host "✅ Manifest loaded." -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to download apps.json" -ForegroundColor Red
    throw $_ # This tells main.ps1 to stop
}

# --- Function to Refresh Path ---
function Refresh-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# --- 1. Chocolatey ---
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "✨ Installing Chocolatey..." -ForegroundColor Gray
    Set-ExecutionPolicy Bypass -Scope Process -Force
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Refresh-Path
}

# --- 2. Scoop ---
if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "✨ Installing Scoop..." -ForegroundColor Gray
    Set-ExecutionPolicy ExecutionPolicy RemoteSigned -Scope CurrentUser
    iex (Invoke-RestMethod 'https://get.scoop.sh')
    
    # Force Scoop into the current session path immediately
    $env:Path += ";$env:USERPROFILE\scoop\shims"
    Refresh-Path
}

# Important: Ensure extras bucket is added only if not already there
Write-Host " Adding Scoop 'extras' bucket..."
scoop bucket add extras 2>$null

# --- 3. Install Apps ---
Write-Host "🚚 Installing Chocolatey Apps..." -ForegroundColor Cyan
foreach ($app in $appConfig.chocolatey) {
    Write-Host " [+] $app"
    choco install $app -y --no-progress --skip-automation-scripts
}

Write-Host "🛠️  Installing Scoop Apps..." -ForegroundColor Cyan
foreach ($app in $appConfig.scoop) {
    Write-Host " [🔧] $app"
    scoop install $app
}

# --- 4. Edge Eviction ---
if (Get-Command vivaldi -ErrorAction SilentlyContinue) {
    Write-Host "🗑️  Vivaldi found. Evicting Edge..." -ForegroundColor Red
    $edgeInstaller = Get-Item "C:\Program Files (x86)\Microsoft\Edge\Application\*\Installer\setup.exe" -ErrorAction SilentlyContinue
    if ($edgeInstaller) {
        Start-Process $edgeInstaller.FullName -ArgumentList "--uninstall --system-level --force-uninstall" -Wait
    }
}