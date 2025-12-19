Write-Host "🌒 02: Painting it Black and fixing the UI..." -ForegroundColor Yellow

# Dark Mode
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0

# Search: Icon Only + No Web Search
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 1
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxWebIndex" -Value 0

# Lockscreen junk
$lockPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"
if (!(Test-Path $lockPath)) { New-Item -Path $lockPath -Force }
Set-ItemProperty -Path $lockPath -Name "LockScreenWidgetsEnabled" -Value 0

Write-Host "🔍 Search iconified. Bing Search banned. Dark Mode engaged."