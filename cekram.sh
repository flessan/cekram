#!/usr/bin/env bash
# ==============================================================================
# CekRAM - Universal Super RAM Monitor & Auto-Purge (POSIX Shell Edition)
# Repository: https://github.com/flessan/cekram
# Run online: curl -fsSL https://raw.githubusercontent.com/flessan/cekram/main/cekram.sh | bash -s -- --lang=id
# ==============================================================================

set -e

# Default values
LANG_SEL="id"
THRESHOLD=80
INTERVAL=5
ONESHOT=0
PURGE_NOW=0

# Parse CLI arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --lang=*|-l=*)
            LANG_SEL="${1#*=}"
            shift
            ;;
        --lang|-l)
            LANG_SEL="$2"
            shift 2
            ;;
        --threshold=*|-t=*)
            THRESHOLD="${1#*=}"
            shift
            ;;
        --threshold|-t)
            THRESHOLD="$2"
            shift 2
            ;;
        --interval=*|-i=*)
            INTERVAL="${1#*=}"
            shift
            ;;
        --interval|-i)
            INTERVAL="$2"
            shift 2
            ;;
        --oneshot|--once|-o)
            ONESHOT=1
            shift
            ;;
        --purge-now)
            PURGE_NOW=1
            shift
            ;;
        --help|-h)
            echo "=============================================================================="
            echo "CekRAM - Universal RAM Monitor & Auto-Purge (POSIX Shell Edition)"
            echo "=============================================================================="
            echo "Usage: cekram.sh [options]"
            echo "Options:"
            echo "  --lang, -l [id|en]      Language selection (default: id)"
            echo "  --threshold, -t [NUM]   RAM usage percentage threshold to trigger purge (default: 80)"
            echo "  --interval, -i [SEC]    Refresh interval in seconds (default: 5)"
            echo "  --oneshot, --once, -o   Run once and exit immediately without looping"
            echo "  --purge-now             Trigger memory cache drop / sync immediately and exit"
            echo "  --help, -h              Show this help menu"
            echo "=============================================================================="
            exit 0
            ;;
        *)
            echo "Unknown argument: $1. Use --help for usage."
            exit 1
            ;;
    esac
done

# Localization setup
if [[ "${LANG_SEL,,}" == "en" ]]; then
    STR_TITLE="SUPER MONITOR - CEKRAM [EN]"
    STR_TOTAL="TOTAL RAM   "
    STR_USED="USED RAM    "
    STR_FREE="FREE RAM    "
    STR_PERCENT="PERCENTAGE  "
    STR_STATUS="STATUS      "
    STR_SAFE="Safe & Sound :3"
    STR_ALERT="[!] HIGH MEMORY USAGE! Running Auto-Purge..."
    STR_DONE="[+] Done! Memory cache synced & purged."
    STR_NOROOT="[i] Sync performed (for full pagecache drop run with root/sudo)."
    STR_STOP="[ Press Ctrl+C to stop ]"
else
    STR_TITLE="SUPER MONITOR - CEKRAM [ID]"
    STR_TOTAL="TOTAL RAM   "
    STR_USED="RAM TERPAKAI"
    STR_FREE="RAM BEBAS   "
    STR_PERCENT="PERSENTASE  "
    STR_STATUS="STATUS      "
    STR_SAFE="Aman Sentosa :3"
    STR_ALERT="[!] RAM SESAK! Menjalankan Auto-Purge..."
    STR_DONE="[+] Selesai! RAM sudah diplongkan."
    STR_NOROOT="[i] Sync selesai (untuk drop cache penuh, jalankan via root/sudo)."
    STR_STOP="[ Tekan Ctrl+C buat berhenti ]"
fi

# Detect OS & Get Memory
get_ram_info() {
    local os_name
    os_name="$(uname -s)"
    
    if [[ "$os_name" == "Linux" ]]; then
        if command -v free >/dev/null 2>&1; then
            # Use free -m
            local mem_line
            mem_line=$(free -m | grep -iE '^Mem:|^Memori:')
            TOTAL_MB=$(echo "$mem_line" | awk '{print $2}')
            USED_MB=$(echo "$mem_line" | awk '{print $3}')
            FREE_MB=$(echo "$mem_line" | awk '{print $4+$6}') # Free + Buffer/Cache available
            if [[ -n $(echo "$mem_line" | awk '{print $7}') ]]; then
                # If available column exists, calculate exact used vs total
                local avail_mb
                avail_mb=$(echo "$mem_line" | awk '{print $7}')
                USED_MB=$((TOTAL_MB - avail_mb))
                FREE_MB=$avail_mb
            fi
        elif [[ -f /proc/meminfo ]]; then
            # Fallback to /proc/meminfo
            local total_kb avail_kb
            total_kb=$(grep -i '^MemTotal:' /proc/meminfo | awk '{print $2}')
            avail_kb=$(grep -i '^MemAvailable:' /proc/meminfo | awk '{print $2}')
            if [[ -z "$avail_kb" ]]; then
                local free_kb buffers_kb cached_kb
                free_kb=$(grep -i '^MemFree:' /proc/meminfo | awk '{print $2}')
                buffers_kb=$(grep -i '^Buffers:' /proc/meminfo | awk '{print $2}')
                cached_kb=$(grep -i '^Cached:' /proc/meminfo | awk '{print $2}')
                avail_kb=$((free_kb + buffers_kb + cached_kb))
            fi
            TOTAL_MB=$((total_kb / 1024))
            FREE_MB=$((avail_kb / 1024))
            USED_MB=$((TOTAL_MB - FREE_MB))
        fi
    elif [[ "$os_name" == "Darwin" ]]; then
        # macOS
        local total_bytes page_size pages_free pages_active pages_inactive pages_speculative
        total_bytes=$(sysctl -n hw.memsize 2>/dev/null || echo "8589934592")
        TOTAL_MB=$((total_bytes / 1024 / 1024))
        
        page_size=$(vm_stat | grep "page size of" | awk '{print $8}' | tr -d '.')
        [[ -z "$page_size" ]] && page_size=4096
        
        pages_free=$(vm_stat | grep "Pages free:" | awk '{print $3}' | tr -d '.')
        pages_inactive=$(vm_stat | grep "Pages inactive:" | awk '{print $3}' | tr -d '.')
        pages_speculative=$(vm_stat | grep "Pages speculative:" | awk '{print $3}' | tr -d '.' || echo 0)
        
        [[ -z "$pages_free" ]] && pages_free=0
        [[ -z "$pages_inactive" ]] && pages_inactive=0
        [[ -z "$pages_speculative" ]] && pages_speculative=0
        
        local free_bytes
        free_bytes=$(( (pages_free + pages_inactive + pages_speculative) * page_size ))
        FREE_MB=$((free_bytes / 1024 / 1024))
        USED_MB=$((TOTAL_MB - FREE_MB))
    else
        # Fallback for unknown POSIX OS
        TOTAL_MB=4096
        USED_MB=2048
        FREE_MB=2048
    fi

    # Ensure integer math doesn't crash if zero
    [[ -z "$TOTAL_MB" || "$TOTAL_MB" -eq 0 ]] && TOTAL_MB=1
    [[ -z "$USED_MB" ]] && USED_MB=0
    [[ -z "$FREE_MB" ]] && FREE_MB=0

    # Calculate percentage
    PERCENT=$(( (USED_MB * 100) / TOTAL_MB ))
}

do_purge() {
    # Run sync across all systems
    sync 2>/dev/null || true
    
    local os_name
    os_name="$(uname -s)"
    
    if [[ "$os_name" == "Linux" ]]; then
        if [[ $EUID -eq 0 ]]; then
            echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true
            echo "  $STR_DONE"
        elif command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
            sudo sh -c 'sync && echo 3 > /proc/sys/vm/drop_caches' 2>/dev/null || true
            echo "  $STR_DONE"
        else
            echo "  $STR_NOROOT"
        fi
    elif [[ "$os_name" == "Darwin" ]]; then
        if [[ $EUID -eq 0 ]] || (command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null); then
            sudo purge 2>/dev/null || true
            echo "  $STR_DONE"
        else
            echo "  $STR_NOROOT"
        fi
    else
        echo "  $STR_DONE"
    fi
}

if [[ "$PURGE_NOW" -eq 1 ]]; then
    echo "$STR_ALERT"
    do_purge
    exit 0
fi

while true; do
    clear 2>/dev/null || true
    echo "=================================================="
    echo "        $STR_TITLE"
    echo "=================================================="
    
    get_ram_info
    
    echo "  $STR_TOTAL : ${TOTAL_MB} MB"
    echo "  $STR_USED : ${USED_MB} MB"
    echo "  $STR_FREE : ${FREE_MB} MB"
    echo "  $STR_PERCENT : [${PERCENT} %]"
    echo "--------------------------------------------------"
    
    if [[ "$PERCENT" -gt "$THRESHOLD" ]]; then
        echo "  $STR_ALERT"
        do_purge
    else
        echo "  $STR_STATUS : $STR_SAFE"
    fi
    echo "--------------------------------------------------"
    
    if [[ "$ONESHOT" -eq 1 ]]; then
        break
    fi
    
    echo "  $STR_STOP"
    sleep "$INTERVAL"
done
