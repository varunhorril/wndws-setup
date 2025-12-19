Write-Host "🛠️  04: Setting up Scoop & Dev Tools..." -ForegroundColor Yellow

$configUrl = "https://raw.githubusercontent.com/varunhorril/wndws-setup/main/config/apps.json"
$appConfig = Invoke-RestMethod -Uri $configUrl

# --- 1. Scoop Setup ---
if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "✨ Installing Scoop..."
    Set-ExecutionPolicy ExecutionPolicy RemoteSigned -Scope CurrentUser
    # We use a try/catch here so that even if Scoop fails, it doesn't "crash" the shell
    try {
        iex (Invoke-RestMethod 'https://get.scoop.sh')
    } catch {
        Write-Host "⚠️  Scoop installer had an issue, but we will try to proceed." -ForegroundColor Gray
    }
}

# --- 2. Force Path for this session ---
$scoopCmd = "$env:USERPROFILE\scoop\shims\scoop.cmd"

# --- 3. Install Scoop Apps ---
if (Test-Path $scoopCmd) {
    Write-Host " 🪣 Adding Scoop 'extras' bucket..."
    & $scoopCmd bucket add extras 2>$null

    foreach ($app in $appConfig.scoop) {
        Write-Host " [🔧] $app"
        & $scoopCmd install $app
    }
} else {
    Write-Host "❌ Scoop was not found at $scoopCmd. Skipping dev tools." -ForegroundColor Red
}