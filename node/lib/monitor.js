// CekRAM cross-platform memory monitor for Node.js
const os = require('os');
const { execSync } = require('child_process');
const fs = require('fs');

function getMetrics() {
    const totalMB = Math.round(os.totalmem() / (1024 * 1024));
    let freeMB = Math.round(os.freemem() / (1024 * 1024));
    
    // On Linux, os.freemem() returns MemFree which is much smaller than MemAvailable.
    // Let's check /proc/meminfo if available for exact accurate usage!
    if (os.platform() === 'linux' && fs.existsSync('/proc/meminfo')) {
        try {
            const content = fs.readFileSync('/proc/meminfo', 'utf8');
            const lines = content.split('\n');
            let memTotal = 0;
            let memAvailable = 0;
            for (const line of lines) {
                if (line.startsWith('MemTotal:')) {
                    memTotal = parseInt(line.split(/\s+/)[1], 10);
                } else if (line.startsWith('MemAvailable:')) {
                    memAvailable = parseInt(line.split(/\s+/)[1], 10);
                }
            }
            if (memTotal && memAvailable) {
                const total = Math.round(memTotal / 1024);
                const avail = Math.round(memAvailable / 1024);
                const used = total - avail;
                const percent = Number(((used / total) * 100).toFixed(2));
                return { totalMB: total, usedMB: used, freeMB: avail, percent };
            }
        } catch (err) {
            // fallback
        }
    }

    const usedMB = totalMB - freeMB;
    const percent = totalMB > 0 ? Number(((usedMB / totalMB) * 100).toFixed(2)) : 0;
    return { totalMB, usedMB, freeMB, percent };
}

function purgeMemory() {
    const platform = os.platform();
    try {
        if (platform === 'win32') {
            // Windows PowerShell EmptyWorkingSet
            execSync(`powershell -NoProfile -Command "$code = '[DllImport(\\"psapi.dll\\")] public static extern bool EmptyWorkingSet(IntPtr hProcess);'; $type = Add-Type -MemberDefinition $code -Name 'MemUtil' -PassThru; Get-Process | ForEach-Object { try { $type::EmptyWorkingSet($_.Handle) | Out-Null } catch {} }"`, { stdio: 'ignore' });
            return { success: true, detail: "Working sets flushed via PowerShell." };
        } else if (platform === 'linux') {
            try { execSync('sync', { stdio: 'ignore' }); } catch (e) {}
            if (process.getuid && process.getuid() === 0) {
                fs.writeFileSync('/proc/sys/vm/drop_caches', '3\n');
                return { success: true, detail: "Pagecaches dropped via /proc/sys/vm/drop_caches." };
            } else {
                try {
                    execSync('sudo -n sh -c "sync && echo 3 > /proc/sys/vm/drop_caches"', { stdio: 'ignore' });
                    return { success: true, detail: "Pagecaches dropped via sudo." };
                } catch (e) {
                    return { success: true, detail: "Sync performed. Run as root/sudo to drop full system cache." };
                }
            }
        } else if (platform === 'darwin') {
            try { execSync('sync', { stdio: 'ignore' }); } catch (e) {}
            if (process.getuid && process.getuid() === 0) {
                execSync('purge', { stdio: 'ignore' });
            } else {
                try { execSync('sudo -n purge', { stdio: 'ignore' }); } catch (e) {}
            }
            return { success: true, detail: "macOS sync/purge executed." };
        }
    } catch (err) {
        return { success: false, detail: err.message };
    }
    return { success: true, detail: "Sync performed." };
}

module.exports = { getMetrics, purgeMemory };
