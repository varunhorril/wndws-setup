Write-Host "📦 03: Downloading app manifest from the repo..." -ForegroundColor Yellow

# Define the URL for your config file
$configUrl = "https://raw.githubusercontent.com/varunhorril/wndws-setup/main/config/apps.json"

# Fetch and Parse JSON
try {
    $appConfig = Invoke-RestMethod -Uri $configUrl
    Write-Host "✅ Manifest loaded successfully." -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to download app manifest. Check your URL!" -ForegroundColor Red
    return
}

# --- Package Manager Checks ---
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "✨ Installing Chocolatey..."
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "✨ Installing Scoop..."
    Set-ExecutionPolicy ExecutionPolicy RemoteSigned -Scope CurrentUser
    iex (Invoke-RestMethod 'https://get.scoop.sh')
    scoop bucket add extras
}

# --- Install Chocolatey Apps ---
Write-Host "🚚 Delivering Chocolatey Packages..." -ForegroundColor Gray
foreach ($app in $appConfig.chocolatey) { 
    Write-Host " ➕ Installing $app..."
    choco install $app -y --no-progress 
}

# --- Install Scoop Apps ---
Write-Host "🛠️  Setting up Scoop Tools..." -ForegroundColor Gray
foreach ($app in $appConfig.scoop) { 
    Write-Host " 🔧 Installing $app..."
    scoop install $app 
}

# --- Final Edge Eviction ---
if (Get-Command vivaldi -ErrorAction SilentlyContinue) {
    Write-Host "🗑️  Vivaldi confirmed. Evicting Microsoft Edge..." -ForegroundColor Red
    $edgePath = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\*\Installer\setup.exe"
    Get-Item $edgePath | ForEach-Object {
        Start-Process $_.FullName -ArgumentList "--uninstall --system-level --force-uninstall" -Wait
    }
}