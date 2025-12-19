# 🚀 wndws-setup

A modular, manifest-driven "Infrastructure as Code" project to automate Windows deployment. This repo transforms a bloated, telemetry-heavy Windows install into a clean, private, dark-themed workstation.

## 🏗️ Architecture
This setup is decoupled for maximum flexibility:
- **`main.ps1`**: Downloads and executes scripts directly from GitHub memory.
- **`config/apps.json`**: The Source of Truth. Update this file to change which apps get installed.
- **`scripts/`**: Modular logic for Debloating, UI Tweaks, and Package Management.


## 🛠️ Features
- **Privacy First:** Kills Advertising ID, Location services, and Telemetry.
- **Clean UI:** Sets **Dark Mode**, shrinks Search to an icon, and removes Lockscreen widgets.
- **Web-Free Start:** Disables Bing/Web results in the Start Menu—local files only.
- **Decoupled Apps:** Uses **Chocolatey** for GUI apps and **Scoop** for Dev tools.
- **OneDrive/Edge Purge:** Uninstalls OneDrive and evicts Microsoft Edge once Vivaldi is detected.

## 🚀 Execution
To set up a new machine, open **PowerShell as Administrator** and paste the following command. 

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
iex ((New-Object System.Net.WebClient).DownloadString('[https://raw.githubusercontent.com/YOUR_USERNAME/wndws-setup/main/main.ps1](https://raw.githubusercontent.com/varunhorril/wndws-setup/main/main.ps1)'))