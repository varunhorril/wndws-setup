Write-Host "🧹 01: Cleaning out the crap..." -ForegroundColor Yellow

# Kill and Uninstall OneDrive
taskkill /f /im OneDrive.exe 2>$null
$osbit = (Get-WmiObject -Class win32_operatingsystem | Select-Object -ExpandProperty OSArchitecture)
$uninstallPath = if ($osbit -eq "64-bit") { "$env:SystemRoot\SysWOW64\OneDriveSetup.exe" } else { "$env:SystemRoot\System32\OneDriveSetup.exe" }
Start-Process $uninstallPath -ArgumentList "/uninstall" -Wait

# Remove Advertising & Location
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0
$locPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors"
if (!(Test-Path $locPath)) { New-Item -Path $locPath -Force }
Set-ItemProperty -Path $locPath -Name "DisableLocation" -Value 1

Write-Host "☁️  OneDrive evicted. Location tracking cut."