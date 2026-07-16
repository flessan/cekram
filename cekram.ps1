# ==============================================================================
# CekRAM - Universal Super RAM Monitor & Auto-Purge (PowerShell Edition)
# Repository: https://github.com/flessan/cekram
# Run online: irm https://raw.githubusercontent.com/flessan/cekram/main/cekram.ps1 | iex
# ==============================================================================

param(
    [string]$Lang = "id",
    [int]$Threshold = 80,
    [int]$Interval = 5,
    [switch]$OneShot,
    [switch]$PurgeNow,
    [switch]$Help
)

if ($Help) {
    Write-Host "==============================================================================" -ForegroundColor Cyan
    Write-Host "CekRAM - Universal RAM Monitor & Auto-Purge (PowerShell Edition)" -ForegroundColor Cyan
    Write-Host "==============================================================================" -ForegroundColor Cyan
    Write-Host "Usage: .\cekram.ps1 [-Lang id|en] [-Threshold 80] [-Interval 5] [-OneShot]"
    Write-Host "Options:"
    Write-Host "  -Lang <id|en>      Language selection (default: id)"
    Write-Host "  -Threshold <int>   RAM usage percentage threshold to trigger purge (default: 80)"
    Write-Host "  -Interval <int>    Refresh interval in seconds (default: 5)"
    Write-Host "  -OneShot           Run once and exit without looping"
    Write-Host "  -PurgeNow          Trigger memory purge immediately and exit"
    Write-Host "  -Help              Show this help menu"
    Write-Host "==============================================================================" -ForegroundColor Cyan
    exit 0
}

# Add MemUtil type for EmptyWorkingSet
$code = @'
using System;
using System.Runtime.InteropServices;
public static class MemUtil {
    [DllImport("psapi.dll")]
    public static extern bool EmptyWorkingSet(IntPtr hProcess);
}
'@

if (-not ([System.Management.Automation.PSTypeName]'MemUtil').Type) {
    Add-Type -TypeDefinition $code -PassThru | Out-Null
}

function Invoke-RAMPurge {
    param([string]$MessageDone)
    Get-Process | ForEach-Object {
        try {
            [MemUtil]::EmptyWorkingSet($_.Handle) | Out-Null
        } catch {
            # Ignore access denied errors for system protected processes
        }
    }
    if ($MessageDone) {
        Write-Host "  $MessageDone" -ForegroundColor Green
    }
}

if ($PurgeNow) {
    if ($Lang -eq "en") {
        Write-Host "[!] Purging working set for all processes..." -ForegroundColor Yellow
        Invoke-RAMPurge -MessageDone "[+] Done! Memory working set cleared."
    } else {
        Write-Host "[!] Membersihkan working set RAM semua proses..." -ForegroundColor Yellow
        Invoke-RAMPurge -MessageDone "[+] Selesai! RAM sudah diplongkan."
    }
    exit 0
}

# Localization strings
$i18n = @{
    id = @{
        Title   = "SUPER MONITOR - CEKRAM [ID]"
        Total   = "TOTAL RAM   "
        Used    = "RAM TERPAKAI"
        Free    = "RAM BEBAS   "
        Percent = "PERSENTASE  "
        Status  = "STATUS      "
        Safe    = "Aman Sentosa :3"
        Alert   = "[!] RAM SESAK! Menjalankan Auto-Purge..."
        Done    = "[+] Selesai! RAM sudah diplongkan."
        Stop    = "[ Tekan Ctrl+C buat berhenti ]"
    }
    en = @{
        Title   = "SUPER MONITOR - CEKRAM [EN]"
        Total   = "TOTAL RAM   "
        Used    = "USED RAM    "
        Free    = "FREE RAM    "
        Percent = "PERCENTAGE  "
        Status  = "STATUS      "
        Safe    = "Safe & Sound :3"
        Alert   = "[!] HIGH MEMORY USAGE! Running Auto-Purge..."
        Done    = "[+] Done! Memory working set cleared."
        Stop    = "[ Press Ctrl+C to stop ]"
    }
}

$str = if ($i18n.ContainsKey($Lang.ToLower())) { $i18n[$Lang.ToLower()] } else { $i18n["id"] }

do {
    Clear-Host
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "        $($str.Title)" -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Cyan

    $os = Get-CimInstance Win32_OperatingSystem
    $totalMB = [math]::Round($os.TotalVisibleMemorySize / 1024, 0)
    $freeMB  = [math]::Round($os.FreePhysicalMemory / 1024, 0)
    $usedMB  = $totalMB - $freeMB
    $percent = [math]::Round(($usedMB / $totalMB) * 100, 2)

    Write-Host "  $($str.Total) : $totalMB MB"
    Write-Host "  $($str.Used) : $usedMB MB" -ForegroundColor ($percent -gt $Threshold ? "Red" : "White")
    Write-Host "  $($str.Free) : $freeMB MB"
    Write-Host "  $($str.Percent) : [$percent %]" -ForegroundColor ($percent -gt $Threshold ? "Red" : "Green")
    Write-Host "--------------------------------------------------" -ForegroundColor DarkGray

    if ($percent -gt $Threshold) {
        Write-Host "  $($str.Alert)" -ForegroundColor Yellow
        Invoke-RAMPurge -MessageDone $str.Done
    } else {
        Write-Host "  $($str.Status) : $($str.Safe)" -ForegroundColor Green
    }

    Write-Host "--------------------------------------------------" -ForegroundColor DarkGray

    if ($OneShot) { break }

    Write-Host "  $($str.Stop)" -ForegroundColor DarkGray
    Start-Sleep -Seconds $Interval
} while ($true)
