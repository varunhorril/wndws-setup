Write-Host "🧹 01: Cleaning out the crap..." -ForegroundColor Yellow

# Kill OneDrive process
Write-Host " 🔪 Terminating OneDrive process..."
taskkill /f /im OneDrive.exe 2>$null

# Uninstall OneDrive
Write-Host " ☁️  Executing OneDrive Uninstaller..."
$osbit = (Get-WmiObject -Class win32_operatingsystem | Select-Object -ExpandProperty OSArchitecture)
$uninstallPath = if ($osbit -eq "64-bit") { "$env:SystemRoot\SysWOW64\OneDriveSetup.exe" } else { "$env:SystemRoot\System32\OneDriveSetup.exe" }

if (Test-Path $uninstallPath) {
    try {
        Start-Process $uninstallPath -ArgumentList "/uninstall" -Wait -NoNewWindow -ErrorAction SilentlyContinue
    } catch {
        Write-Host " ⚠️  OneDrive uninstall command issued, but reported a non-critical exit error." -ForegroundColor Gray
    }
}

# Remove Advertising & Location
Write-Host " 🚫 Disabling Tracking & Location..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0 -ErrorAction SilentlyContinue
$locPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors"
if (!(Test-Path $locPath)) { New-Item -Path $locPath -Force | Out-Null }
Set-ItemProperty -Path $locPath -Name "DisableLocation" -Value 1 -ErrorAction SilentlyContinue

Write-Host "✅ OneDrive evicted. Location tracking cut."