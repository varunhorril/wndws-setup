# --- 1. ELEVATION CHECK ---
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "⚠️  Administrative privileges required. Relaunching..." -ForegroundColor Yellow
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# --- 2. CONFIGURATION ---
# 🚨 REPLACE $githubUser WITH YOUR ACTUAL GITHUB USERNAME IF FORKED
$githubUser = "varunhorril"
$repoName   = "wndws-setup"
$branch     = "main"
$baseUrl    = "https://raw.githubusercontent.com/$githubUser/$repoName/$branch/scripts"

$scripts = @(
    "01-decrapify.ps1", 
    "02-tweaks.ps1", 
    "03-apps.ps1"
)

# --- 3. WELCOME MESSAGE ---
Clear-Host
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "🛡️  WNDWS-SETUP: REPRODUCIBLE WORKSTATION DEPLOYMENT" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "Windows is currently a mess of tracking and bloat." -ForegroundColor White
Write-Host "This script will purge the junk and install your 'apps.json' stack." -ForegroundColor White
Write-Host ""

# --- 4. EXECUTION LOOP ---
foreach ($script in $scripts) {
    $scriptUrl = "$baseUrl/$script"
    
    Write-Host "📡 Downloading and executing: [$script]..." -ForegroundColor Gray
    try {
        # Fetch the script content as a string
        $code = Invoke-RestMethod -Uri $scriptUrl -ErrorAction Stop
        
        # Execute the string in the current scope
        Invoke-Expression $code
        
        Write-Host "✅ $script completed successfully." -ForegroundColor Green
        Write-Host "----------------------------------------------------------------" -ForegroundColor Gray
    }
    catch {
        Write-Host "❌ CRITICAL ERROR: Could not run $script." -ForegroundColor Red
        Write-Host "Check your GitHub URL: $scriptUrl" -ForegroundColor Red
        Write-Host "Stopping deployment to prevent partial setup." -ForegroundColor Red
        break
    }
}

# --- 5. FINALIZATION ---
Write-Host ""
Write-Host "✨ SETUP FINISHED." -ForegroundColor Magenta
Write-Host "🔄 A system restart is highly recommended to apply all registry changes." -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan