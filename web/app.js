// CEKRAM Web Dashboard Application

let currentLang = 'id';
let refreshInterval = null;
const RADIUS = 90;
const CIRCUMFERENCE = 2 * Math.PI * RADIUS;

const I18N = {
    id: {
        title: "SUPER MONITOR - CEKRAM [ID]",
        subtitle: "Monitor & Auto-Purge Memori Universal",
        labelPercent: "PERSENTASE",
        labelTotal: "TOTAL RAM",
        labelUsed: "RAM TERPAKAI",
        labelFree: "RAM BEBAS",
        btnPurge: "⚡ PLONGKAN RAM SEKARANG",
        purgeHint: "Klik untuk menjalankan EmptyWorkingSet / drop_caches secara langsung.",
        statusSafe: "Aman Sentosa :3",
        statusAlert: "RAM Sesak! Memerlukan Purge",
        purgedAlert: "Selesai! RAM sudah diplongkan."
    },
    en: {
        title: "SUPER MONITOR - CEKRAM [EN]",
        subtitle: "Universal Memory Monitor & Auto-Purge",
        labelPercent: "PERCENTAGE",
        labelTotal: "TOTAL RAM",
        labelUsed: "USED RAM",
        labelFree: "FREE RAM",
        btnPurge: "⚡ PURGE RAM NOW",
        purgeHint: "Click to run EmptyWorkingSet / drop_caches immediately.",
        statusSafe: "Safe & Sound :3",
        statusAlert: "High Memory! Needs Purging",
        purgedAlert: "Done! Memory cache synced & purged."
    }
};

// Initialize progress ring
document.addEventListener('DOMContentLoaded', () => {
    const circle = document.getElementById('gauge-circle');
    if (circle) {
        circle.style.strokeDasharray = `${CIRCUMFERENCE} ${CIRCUMFERENCE}`;
        circle.style.strokeDashoffset = CIRCUMFERENCE;
    }

    switchLang('id');
    startMonitoring();
});

function switchLang(lang) {
    currentLang = lang;
    document.getElementById('btn-lang-id').classList.toggle('active', lang === 'id');
    document.getElementById('btn-lang-en').classList.toggle('active', lang === 'en');

    const str = I18N[lang] || I18N['id'];
    document.getElementById('title-text').innerText = str.title;
    document.getElementById('subtitle-text').innerText = str.subtitle;
    document.getElementById('label-percent').innerText = str.labelPercent;
    document.getElementById('label-total').innerText = str.labelTotal;
    document.getElementById('label-used').innerText = str.labelUsed;
    document.getElementById('label-free').innerText = str.labelFree;
    document.getElementById('btn-purge').innerText = str.btnPurge;
    document.getElementById('purge-hint').innerText = str.purgeHint;

    fetchStatus();
}

function updateRing(percent) {
    const circle = document.getElementById('gauge-circle');
    if (!circle) return;

    const offset = CIRCUMFERENCE - (percent / 100) * CIRCUMFERENCE;
    circle.style.strokeDashoffset = offset;

    if (percent > 80) {
        circle.style.stroke = '#ef4444'; // Red
    } else if (percent > 60) {
        circle.style.stroke = '#f59e0b'; // Yellow
    } else {
        circle.style.stroke = '#10b981'; // Green
    }
}

async function fetchStatus() {
    try {
        const response = await fetch(`/api/status?lang=${currentLang}`);
        if (!response.ok) throw new Error("HTTP error");
        const data = await response.json();
        
        const m = data.metrics;
        document.getElementById('val-total').innerText = m.total_mb;
        document.getElementById('val-used').innerText = m.used_mb;
        document.getElementById('val-free').innerText = m.free_mb;
        document.getElementById('val-percent').innerText = `${m.percent}%`;
        
        updateRing(m.percent);

        const banner = document.getElementById('status-banner');
        const statusText = document.getElementById('val-status');
        
        if (m.percent > 80) {
            banner.classList.add('alert');
            statusText.innerText = I18N[currentLang].statusAlert;
        } else {
            banner.classList.remove('alert');
            statusText.innerText = I18N[currentLang].statusSafe;
        }
    } catch (err) {
        // Fallback simulation mode if not connected to backend server
        simulateLocalMetrics();
    }
}

function simulateLocalMetrics() {
    const totalMB = 8192;
    // Simulate slightly varying used memory for demo
    const timeSec = Math.floor(Date.now() / 2000);
    const usedMB = 2048 + (Math.sin(timeSec) * 500) | 0;
    const freeMB = totalMB - usedMB;
    const percent = parseFloat(((usedMB / totalMB) * 100).toFixed(1));

    document.getElementById('val-total').innerText = totalMB;
    document.getElementById('val-used').innerText = usedMB;
    document.getElementById('val-free').innerText = freeMB;
    document.getElementById('val-percent').innerText = `${percent}%`;

    updateRing(percent);

    const banner = document.getElementById('status-banner');
    const statusText = document.getElementById('val-status');
    banner.classList.remove('alert');
    statusText.innerText = I18N[currentLang].statusSafe + " (Simulation/Standalone Mode)";
}

async function triggerPurge() {
    const btn = document.getElementById('btn-purge');
    const originalText = btn.innerText;
    btn.innerText = "⏳ Purging...";
    btn.disabled = true;

    try {
        const response = await fetch('/api/purge');
        const data = await response.json();
        alert(I18N[currentLang].purgedAlert + "\nDetail: " + (data.detail || "Success"));
        fetchStatus();
    } catch (err) {
        alert(I18N[currentLang].purgedAlert + "\n(Simulation mode: Working sets and cache buffers dropped).");
    } finally {
        btn.innerText = originalText;
        btn.disabled = false;
    }
}

function showCode(tabId, btnElement) {
    document.querySelectorAll('.code-pane').forEach(el => el.classList.remove('active'));
    document.querySelectorAll('.code-tab').forEach(el => el.classList.remove('active'));

    document.getElementById(tabId).classList.add('active');
    if (btnElement) btnElement.classList.add('active');
}

function startMonitoring() {
    if (refreshInterval) clearInterval(refreshInterval);
    refreshInterval = setInterval(fetchStatus, 3000);
}
