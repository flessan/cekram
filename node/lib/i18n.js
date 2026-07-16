// CekRAM i18n module for Node.js

const STRINGS = {
    id: {
        title: "SUPER MONITOR - CEKRAM [ID]",
        total: "TOTAL RAM   ",
        used: "RAM TERPAKAI",
        free: "RAM BEBAS   ",
        percent: "PERSENTASE  ",
        status: "STATUS      ",
        safe: "Aman Sentosa :3",
        alert: "[!] RAM SESAK! Menjalankan Auto-Purge...",
        done: "[+] Selesai! RAM sudah diplongkan.",
        stop: "[ Tekan Ctrl+C buat berhenti ]"
    },
    en: {
        title: "SUPER MONITOR - CEKRAM [EN]",
        total: "TOTAL RAM   ",
        used: "USED RAM    ",
        free: "FREE RAM    ",
        percent: "PERCENTAGE  ",
        status: "STATUS      ",
        safe: "Safe & Sound :3",
        alert: "[!] HIGH MEMORY USAGE! Running Auto-Purge...",
        done: "[+] Done! Memory cache synced & purged.",
        stop: "[ Press Ctrl+C to stop ]"
    }
};

function getString(key, lang = 'id') {
    const l = STRINGS[lang.toLowerCase()] ? lang.toLowerCase() : 'id';
    return STRINGS[l][key] || key;
}

module.exports = { getString, STRINGS };
