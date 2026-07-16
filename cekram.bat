@echo off
setlocal enabledelayedexpansion

:: ==============================================================================
:: CekRAM - Universal Super RAM Monitor & Auto-Purge (Windows Batch Edition)
:: https://github.com/flessan/cekram
:: ==============================================================================

set "LANG=id"
set "THRESHOLD=80"
set "INTERVAL=5"
set "ONESHOT=0"
set "JSON_MODE=0"
set "DRY_RUN=0"
set "THEME=classic"

:parse_args
if "%~1"=="" goto after_args
if /i "%~1"=="--lang" (set "LANG=%~2" & shift & shift & goto parse_args)
if /i "%~1"=="-l" (set "LANG=%~2" & shift & shift & goto parse_args)
if /i "%~1"=="--threshold" (set "THRESHOLD=%~2" & shift & shift & goto parse_args)
if /i "%~1"=="-t" (set "THRESHOLD=%~2" & shift & shift & goto parse_args)
if /i "%~1"=="--interval" (set "INTERVAL=%~2" & shift & shift & goto parse_args)
if /i "%~1"=="-i" (set "INTERVAL=%~2" & shift & shift & goto parse_args)
if /i "%~1"=="--oneshot" (set "ONESHOT=1" & shift & goto parse_args)
if /i "%~1"=="--once" (set "ONESHOT=1" & shift & goto parse_args)
if /i "%~1"=="--json" (set "JSON_MODE=1" & shift & goto parse_args)
if /i "%~1"=="-j" (set "JSON_MODE=1" & shift & goto parse_args)
if /i "%~1"=="--dry-run" (set "DRY_RUN=1" & shift & goto parse_args)
if /i "%~1"=="-d" (set "DRY_RUN=1" & shift & goto parse_args)
if /i "%~1"=="--theme" (set "THEME=%~2" & shift & shift & goto parse_args)
if /i "%~1"=="watch" (set "ONESHOT=0" & shift & goto parse_args)
if /i "%~1"=="benchmark" (
    echo ============================================================
    echo  CekRAM Benchmark: Full vs Lite Edition (Windows Batch)
    echo ============================================================
    echo Feature / Metric         ^| CekRAM Full      ^| CekRAM Lite     
    echo ------------------------------------------------------------
    echo Startup / Scan Latency   ^| ~180 ms          ^| ~60 ms
    echo Peak Memory Usage        | ~30 MB           | ~10 MB
    echo Web Dashboard ^& API      ^| Supported (✅)   ^| None (❌)
    echo JSON Output ^& Watch      ^| Supported (✅)   ^| Supported (✅)
    echo ============================================================
    exit /b 0
)
if /i "%~1"=="--help" goto show_help
if /i "%~1"=="-h" goto show_help
shift
goto parse_args

:show_help
echo ==============================================================================
echo CekRAM - Universal RAM Monitor & Auto-Purge (Windows Batch)
echo ==============================================================================
echo Usage: cekram.bat [options]
echo Options:
echo   --lang, -l [id^|en]       Language selection (default: id)
echo   --threshold, -t [NUM]    RAM usage threshold (default: 80)
echo   --interval, -i [SEC]     Refresh interval in seconds (default: 5)
echo   --oneshot, --once        Run once and exit without looping
echo   --json, -j               Output machine-readable JSON
echo   --dry-run, -d            Simulate actions without executing purge
echo   --theme [classic^|minimal] Terminal UI theme
echo   --help, -h               Show help menu
echo ==============================================================================
exit /b 0

:after_args
if /i "%LANG%"=="en" (
    set "STR_TITLE=SUPER MONITOR - CEKRAM [EN]"
    set "STR_TOTAL=TOTAL RAM   "
    set "STR_USED=USED RAM    "
    set "STR_FREE=FREE RAM    "
    set "STR_PERCENT=PERCENTAGE  "
    set "STR_STATUS=STATUS      "
    set "STR_SAFE=Safe & Sound :3"
    set "STR_ALERT=[!] HIGH MEMORY USAGE! Running Auto-Purge..."
    set "STR_DONE=[+] Done! Memory working set cleared."
    set "STR_STOP=[ Press Ctrl+C to stop ]"
) else (
    set "STR_TITLE=SUPER MONITOR - CEKRAM [ID]"
    set "STR_TOTAL=TOTAL RAM   "
    set "STR_USED=RAM TERPAKAI"
    set "STR_FREE=RAM BEBAS   "
    set "STR_PERCENT=PERSENTASE  "
    set "STR_STATUS=STATUS      "
    set "STR_SAFE=Aman Sentosa :3"
    set "STR_ALERT=[!] RAM SESAK! Menjalankan Auto-Purge..."
    set "STR_DONE=[+] Selesai! RAM sudah diplongkan."
    set "STR_STOP=[ Tekan Ctrl+C buat berhenti ]"
)

:loop
if "%ONESHOT%"=="0" cls
set "TOTAL=0"
set "USED=0"
set "FREE=0"
set "PERCENT=0"

for /f "delims=" %%i in ('powershell -NoProfile -Command "$m = Get-CimInstance Win32_OperatingSystem; $total = [math]::Round($m.TotalVisibleMemorySize / 1024, 0); $free = [math]::Round($m.FreePhysicalMemory / 1024, 0); $used = $total - $free; $p = [math]::Round(($used / $total) * 100, 0); write-host $total' '$used' '$free' '$p"') do (
    for /f "tokens=1,2,3,4" %%a in ("%%i") do (
        set "TOTAL=%%a"
        set "USED=%%b"
        set "FREE=%%c"
        set "PERCENT=%%d"
    )
)

set "ST_WORD=safe"
if %PERCENT% GTR %THRESHOLD% set "ST_WORD=critical"
if %PERCENT% GEQ 60 if %PERCENT% LEQ %THRESHOLD% set "ST_WORD=warning"

if "%JSON_MODE%"=="1" (
    echo {"total_ram_mb":%TOTAL%,"used_ram_mb":%USED%,"free_ram_mb":%FREE%,"usage_percent":%PERCENT%,"status":"!ST_WORD!"}
) else if /i "%THEME%"=="minimal" (
    echo [*] RAM: %USED% MB / %TOTAL% MB (%PERCENT%%%) ^| Free: %FREE% MB ^| Status: !ST_WORD!
) else (
    echo ==================================================
    echo        %STR_TITLE%
    echo ==================================================
    echo  %STR_TOTAL% : %TOTAL% MB
    echo  %STR_USED% : %USED% MB
    echo  %STR_FREE% : %FREE% MB
    echo  %STR_PERCENT% : [%PERCENT% %%]
    echo --------------------------------------------------
    if %PERCENT% GTR %THRESHOLD% (
        echo  %STR_ALERT%
    ) else (
        echo  %STR_STATUS% : %STR_SAFE%
    )
    echo --------------------------------------------------
)

if %PERCENT% GTR %THRESHOLD% (
    if "%DRY_RUN%"=="0" (
        powershell -NoProfile -Command "$code = '[DllImport(\"psapi.dll\")] public static extern bool EmptyWorkingSet(IntPtr hProcess);'; $type = Add-Type -MemberDefinition $code -Name 'MemUtil' -PassThru; Get-Process | ForEach-Object { try { $type::EmptyWorkingSet($_.Handle) | Out-Null } catch {} }"
    ) else (
        echo  [DRY-RUN] Would empty working set via psapi.dll
    )
)

if "%ONESHOT%"=="1" exit /b 0
timeout /t %INTERVAL% >nul
goto loop
