# 🚀 wndws-setup

A reproducible, automated environment for Windows. This script transforms a fresh Windows install into a clean, private, dark-themed workstation.

## ⚠️ What this does
- **Privacy:** Disables Advertising ID, Location, and telemetry.
- **UI:** Enforces Dark Mode, shrinks Search to an icon, and clears Lockscreen junk.
- **Bloatware:** Evicts OneDrive and removes pre-installed "crapware."
- **Apps:** Installs a full stack via Chocolatey and Scoop.
- **Eviction:** Deletes Microsoft Edge once Vivaldi is confirmed.

## 🚀 Usage
Open PowerShell as **Administrator** and run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
iex ((New-Object System.Net.WebClient).DownloadString('[https://raw.githubusercontent.com/varunhorril/wndws-setup/main/main.ps1](https://raw.githubusercontent.com/YOUR_USERNAME/wndws-setup/main/main.ps1)'))
