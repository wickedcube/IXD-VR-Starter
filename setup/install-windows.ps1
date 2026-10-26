# Installs Git and GitHub Desktop on Windows. Safe to run more than once.
# Use install-windows.bat to run this by double-clicking.
$ErrorActionPreference = 'Continue'
Write-Host "== IXD VR Starter: Windows setup ==" -ForegroundColor Cyan
Write-Host ""

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "[!] winget was not found. Install 'App Installer' from the Microsoft Store, or install these by hand:" -ForegroundColor Yellow
    Write-Host "    Git:            https://git-scm.com/download/win"
    Write-Host "    GitHub Desktop: https://desktop.github.com"
    Write-Host "    Unity Hub:      https://unity.com/download"
    exit 1
}

function Install-App($id, $name) {
    winget list --id $id -e --accept-source-agreements 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[ok] $name is already installed."
        return
    }
    Write-Host "Installing $name..."
    winget install --id $id -e --silent --accept-source-agreements --accept-package-agreements
    if ($LASTEXITCODE -eq 0) { Write-Host "[ok] $name installed." }
    else { Write-Host "[!] $name did not install. Try again, or install it by hand." -ForegroundColor Yellow }
}

Install-App 'Git.Git' 'Git'
Install-App 'GitHub.GitHubDesktop' 'GitHub Desktop'
Install-App 'Unity.UnityHub' 'Unity Hub'

Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Restart your computer (or at least sign out and in) so Git is found everywhere."
Write-Host "  2. Open GitHub Desktop and sign in with your GitHub account."
Write-Host "  3. Clone your project repo (File > Clone repository)."
Write-Host "  4. Open the folder in Unity Hub, then use the Team menu in Unity to save your work."
