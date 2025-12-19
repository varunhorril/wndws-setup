Write-Host "🛠️  04: Setting up Scoop..." -ForegroundColor Yellow

# 1. Fetch JSON
try {
    $appConfig = Invoke-RestMethod -Uri "https://raw.githubusercontent.com/varunhorril/wndws-setup/main/config/apps.json" -ErrorAction SilentlyContinue
} catch { return }

# 2. Scoop Installation
if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "✨ Installing Scoop..."
    # We use -ErrorAction SilentlyContinue here to prevent the 'Critical Error' in main.ps1
    Set-ExecutionPolicy ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    $null = iex (Invoke-RestMethod 'https://get.scoop.sh') -ErrorAction SilentlyContinue
}

# 3. Direct Path Execution
$scoopCmd = "$env:USERPROFILE\scoop\shims\scoop.cmd"

if (Test-Path $scoopCmd) {
    Write-Host " 🪣 Adding Extras..."
    & $scoopCmd bucket add extras 2>$null
    
    foreach ($app in $appConfig.scoop) {
        Write-Host " [🔧] $app"
        & $scoopCmd install $app 2>$null
    }
}