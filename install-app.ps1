# Orbicus Workspace Desktop PowerShell Installer
$ErrorActionPreference = "Stop"

$Version = "v1.0.1"
$Repo = "Jafar-Sabaouni/orbicus-releases"
$File = "Orbicus-1.0.1-Setup.exe"
$Url = "https://github.com/$Repo/releases/download/$Version/$File"

$TempPath = Join-Path $env:TEMP $File

Write-Host "==> Downloading Orbicus Workspace ($Version)..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $Url -OutFile $TempPath -UseBasicParsing

Write-Host "==> Launching installer..." -ForegroundColor Cyan
Start-Process -FilePath $TempPath -Wait

Remove-Item -Path $TempPath -Force -ErrorAction SilentlyContinue

Write-Host "==> Orbicus Workspace installation complete!" -ForegroundColor Green
