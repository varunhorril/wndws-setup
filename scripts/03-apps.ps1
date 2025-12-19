Write-Host "📦 03: Installing Chocolatey & GUI Apps..." -ForegroundColor Yellow

$configUrl = "https://raw.githubusercontent.com/varunhorril/wndws-setup/main/config/apps.json"

# 1. Fetch JSON (Using Invoke-RestMethod for simplicity)
try {
    $appConfig = Invoke-RestMethod -Uri $configUrl -ErrorAction Stop
    $chocoList = $appConfig.chocolatey
    Write-Host "✅ Manifest loaded. Preparing to install $($chocoList.Count) apps." -ForegroundColor Green
} catch {
    Write-Host "❌ CRITICAL: Failed to load apps.json" -ForegroundColor Red
    throw $_
}

# 2. Chocolatey Setup
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "✨ Installing Chocolatey..." -ForegroundColor Gray
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    
    # Refresh Path immediately so 'choco' command is recognized in THIS script
    $env:Path += ";C:\ProgramData\chocolatey\bin"
}

# 3. Install Choco Apps
foreach ($app in $chocoList) {
    Write-Host "🚀 [Processing]: $app" -ForegroundColor Cyan
    
    # Check if already installed to avoid redundant work
    if (!(choco list --local-only | Select-String $app)) {
        # IMPORTANT: We removed --skip-automation-scripts to ensure shortcuts are created
        choco install $app -y --no-progress --limit-output
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✅ $app installed successfully." -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  $app might have had an issue (Exit Code: $LASTEXITCODE)." -ForegroundColor Yellow
        }
    } else {
        Write-Host "   ⏭️  $app is already installed. Skipping." -ForegroundColor Gray
    }
}

# 4. Edge Eviction
$vivaldiPath = "${env:ProgramFiles}\Vivaldi\Application\vivaldi.exe"
if (Test-Path $vivaldiPath) {
    Write-Host "🗑️  Vivaldi verified. Evicting Microsoft Edge..." -ForegroundColor Red
    $edgeInstaller = Get-Item "C:\Program Files (x86)\Microsoft\Edge\Application\*\Installer\setup.exe" -ErrorAction SilentlyContinue
    if ($edgeInstaller) {
        Start-Process $edgeInstaller.FullName -ArgumentList "--uninstall --system-level --force-uninstall" -Wait
    }
}