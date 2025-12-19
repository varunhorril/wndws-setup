Write-Host "📦 03: Downloading app manifest..." -ForegroundColor Yellow

$configUrl = "https://raw.githubusercontent.com/varunhorril/wndws-setup/main/config/apps.json"

try {
    $appConfig = Invoke-RestMethod -Uri $configUrl -ErrorAction Stop
    Write-Host "✅ Manifest loaded." -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to download apps.json from $configUrl" -ForegroundColor Red
    throw "ManifestDownloadFailed"
}

# --- Function to force refresh Environment Variables ---
function Refresh-SessionPath {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# --- 1. Chocolatey Setup ---
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "✨ Installing Chocolatey..." -ForegroundColor Gray
    Set-ExecutionPolicy Bypass -Scope Process -Force
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Refresh-SessionPath
}

# --- 2. Scoop Setup ---
if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "✨ Installing Scoop..." -ForegroundColor Gray
    # Scoop prefers non-admin for install, but since we are admin, we force it
    Set-ExecutionPolicy ExecutionPolicy RemoteSigned -Scope CurrentUser
    iex (Invoke-RestMethod 'https://get.scoop.sh')
    
    # CRITICAL: Manually add Scoop shims to the current session path so the next command works
    $scoopShimPath = "$env:USERPROFILE\scoop\shims"
    if ($env:Path -notlike "*$scoopShimPath*") {
        $env:Path += ";$scoopShimPath"
    }
}

# --- 3. Configure Scoop ---
Write-Host " 🪣 Adding Scoop 'extras' bucket..."
# We use 'Invoke-Expression' with the full path to ensure it's found
& "$env:USERPROFILE\scoop\shims\scoop.cmd" bucket add extras 2>$null

# --- 4. Install Chocolatey Apps ---
Write-Host "🚚 Installing Chocolatey Apps..." -ForegroundColor Cyan
foreach ($app in $appConfig.chocolatey) {
    Write-Host " [+] Installing $app..."
    choco install $app -y --no-progress --skip-automation-scripts
}

# --- 5. Install Scoop Apps ---
Write-Host "🛠️  Installing Scoop Apps..." -ForegroundColor Cyan
foreach ($app in $appConfig.scoop) {
    Write-Host " [🔧] Installing $app..."
    & "$env:USERPROFILE\scoop\shims\scoop.cmd" install $app
}

# --- 6. Edge Eviction ---
# We do this at the very end to ensure Vivaldi is actually ready
if (Get-Command vivaldi -ErrorAction SilentlyContinue) {
    Write-Host "🗑️  Vivaldi is ready. Evicting Microsoft Edge..." -ForegroundColor Red
    $edgeInstaller = Get-Item "C:\Program Files (x86)\Microsoft\Edge\Application\*\Installer\setup.exe" -ErrorAction SilentlyContinue
    if ($edgeInstaller) {
        Start-Process $edgeInstaller.FullName -ArgumentList "--uninstall --system-level --force-uninstall" -Wait
    } else {
        Write-Host " ℹ️  Edge installer not found in standard path. Skipping eviction." -ForegroundColor Gray
    }
}