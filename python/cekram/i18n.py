# -*- coding: utf-8 -*-
"""
Localization strings for CekRAM (ID/EN).
"""

STRINGS = {
    "id": {
        "title": "SUPER MONITOR - CEKRAM [ID]",
        "subtitle": "Monitor & Auto-Purge Memori Universal",
        "total": "TOTAL RAM   ",
        "used": "RAM TERPAKAI",
        "free": "RAM BEBAS   ",
        "percent": "PERSENTASE  ",
        "status": "STATUS      ",
        "safe": "Aman Sentosa :3",
        "alert": "[!] RAM SESAK! Menjalankan Auto-Purge...",
        "done": "[+] Selesai! RAM sudah diplongkan.",
        "noroot": "[i] Sync selesai (untuk drop cache penuh, jalankan via root/sudo).",
        "stop": "[ Tekan Ctrl+C buat berhenti ]",
        "purge_btn": "PLONGKAN RAM SEKARANG",
        "status_safe": "Aman Sentosa :3",
        "status_alert": "RAM Sesak! Memerlukan Purge",
    },
    "en": {
        "title": "SUPER MONITOR - CEKRAM [EN]",
        "subtitle": "Universal Memory Monitor & Auto-Purge",
        "total": "TOTAL RAM   ",
        "used": "USED RAM    ",
        "free": "FREE RAM    ",
        "percent": "PERCENTAGE  ",
        "status": "STATUS      ",
        "safe": "Safe & Sound :3",
        "alert": "[!] HIGH MEMORY USAGE! Running Auto-Purge...",
        "done": "[+] Done! Memory cache synced & purged.",
        "noroot": "[i] Sync performed (for full pagecache drop run with root/sudo).",
        "stop": "[ Press Ctrl+C to stop ]",
        "purge_btn": "PURGE RAM NOW",
        "status_safe": "Safe & Sound :3",
        "status_alert": "High Memory! Needs Purging",
    }
}

def get_string(key: str, lang: str = "id") -> str:
    lang = lang.lower() if lang.lower() in STRINGS else "id"
    return STRINGS[lang].get(key, str(key))
