# ==============================================================================
# CekRAM Installer for Windows (PowerShell)
# Usage: irm https://raw.githubusercontent.com/flessan/cekram/main/install.ps1 | iex
# ==============================================================================

$ErrorActionPreference = 'Stop'
$RepoUrl = "https://raw.githubusercontent.com/flessan/cekram/main"
$InstallDir = "$HOME\AppData\Local\Programs\CekRAM"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "          Installing CekRAM CLI for Windows..." -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

if (-not (Test-Path -Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
}

Write-Host "[*] Downloading cekram.bat and cekram.ps1..." -ForegroundColor Yellow
Invoke-WebRequest -Uri "$RepoUrl/cekram.bat" -OutFile "$InstallDir\cekram.bat" -UseBasicParsing
Invoke-WebRequest -Uri "$RepoUrl/cekram.ps1" -OutFile "$InstallDir\cekram.ps1" -UseBasicParsing

# Add to PATH if not already present
$UserPath = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::User)
if ($UserPath -notlike "*$InstallDir*") {
    Write-Host "[*] Adding $InstallDir to User PATH..." -ForegroundColor Yellow
    [Environment]::SetEnvironmentVariable("PATH", "$UserPath;$InstallDir", [EnvironmentVariableTarget]::User)
    $env:PATH = "$env:PATH;$InstallDir"
}

Write-Host "[+] Successfully installed CekRAM to: $InstallDir" -ForegroundColor Green
Write-Host ""
Write-Host "Try running in PowerShell or CMD:" -ForegroundColor White
Write-Host "  cekram --lang id --threshold 80" -ForegroundColor Cyan
Write-Host "  cekram.ps1 -Lang en -OneShot" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
