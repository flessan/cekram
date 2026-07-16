# ⚡ CEKRAM - Super Monitor & Auto-Purge RAM Universal

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Multi-Language: ID/EN](https://img.shields.io/badge/Language-ID%20|%20EN-00bcd4.svg)](#-deteksi-bahasa-otomatis)
[![Platform Compatibility](https://img.shields.io/badge/Platform-Windows%20|%20Linux%20|%20macOS-4caf50.svg)](./README.md)
[![CI Pipeline](https://github.com/flessan/cekram/actions/workflows/ci.yml/badge.svg)](https://github.com/flessan/cekram/actions/workflows/ci.yml)
[![Release Pipeline](https://github.com/flessan/cekram/actions/workflows/release.yml/badge.svg)](https://github.com/flessan/cekram/actions/workflows/release.yml)
[![Prometheus Metrics](https://img.shields.io/badge/Prometheus-Exposed%20%2Fmetrics-E6522C.svg)](#-rest-api--prometheus-metrics)

> **"SUPER MONITOR - ACER TRAVELMATE & UNIVERSAL SYSTEM MONITOR"**  
> Monitor RAM super ringan, tanpa dependensi ribet, dan lintas platform dengan fitur **Auto-Purge** (`EmptyWorkingSet` di Windows, `/proc/sys/vm/drop_caches` di Linux, dan `purge` di macOS). Tersedia dalam **Edisi Full** (dengan Web UI, HTTP Server, Tema, dan REST API) serta **CekRAM Lite** (edisi ultra-cepat, minimal overhead, tanpa dependensi).

---

* [🇬🇧 **Read English Documentation (`README.md`)**](./README.md)

---

## 📋 Daftar Isi
- [🚀 Cara Cepat (One-Liners)](#-cara-cepat-one-liners)
- [🏎️ Perbandingan CekRAM Lite vs Edisi Full](#-perbandingan-cekram-lite-vs-edisi-full)
- [⚙️ Dukungan File Konfigurasi](#-dukungan-file-konfigurasi)
- [🌐 Deteksi Bahasa Otomatis](#-deteksi-bahasa-otomatis)
- [🛡️ Kode Keluar (Exit Codes) & Output JSON](#-kode-keluar-exit-codes--output-json)
- [🎨 Tema Terminal & Mode Watch](#-tema-terminal--mode-watch)
- [🖥️ REST API & Prometheus Metrics](#-rest-api--prometheus-metrics)
- [🐳 Penggunaan Docker](#-penggunaan-docker)
- [📊 Perintah Benchmark](#-perintah-benchmark)
- [❓ FAQ & Troubleshooting](#-faq--troubleshooting)

---

## 🚀 Cara Cepat (One-Liners)

### 🐧 Linux & macOS via cURL (POSIX Shell)
```bash
# Edisi Full (Mode interaktif atau watch)
curl -fsSL https://raw.githubusercontent.com/flessan/cekram/main/cekram.sh | bash -s -- --theme nerd --watch

# CekRAM Lite (Edisi ultra-cepat & minimalis)
curl -fsSL https://raw.githubusercontent.com/flessan/cekram/main/cekram-lite.sh | bash -s -- --lang=id
```

### 🪟 Windows via PowerShell (`irm | iex`)
```powershell
# Jalankan Edisi Full secara online
irm https://raw.githubusercontent.com/flessan/cekram/main/cekram.ps1 | iex

# Jalankan CekRAM Lite secara online
irm https://raw.githubusercontent.com/flessan/cekram/main/cekram-lite.ps1 | iex
```

### 🐍 Python (`pip`) atau 📦 Node.js (`npx`) atau 🏎️ Go (`go run`)
```bash
# Python CLI / Web Server
python3 -m pip install git+https://github.com/flessan/cekram.git#subdirectory=python
cekram --theme nerd --watch --lang id
cekram --server --port 8080 --lang id

# Node.js CLI via npx
npx github:flessan/cekram --json --oneshot --lang id

# Go Native Execution
go run github.com/flessan/cekram/go@latest --threshold=85 --lang=id
```

---

## 🏎️ Perbandingan CekRAM Lite vs Edisi Full

**CekRAM Lite** (`cekram-lite`) dirancang khusus untuk kecepatan maksimal, penggunaan memori super minim, dan otomatisasi tinggi (cron jobs, CI/CD, perangkat embedded, dan container VPS).

```text
TOTAL RAM : 16384 MB
RAM TERPAKAI : 6144 MB
RAM BEBAS : 10240 MB
PERSENTASE : 37%
STATUS    : AMAN
```

### Tabel Perbandingan Fitur & Performa

| Fitur | CekRAM Full | CekRAM Lite | Web Dashboard |
| :--- | :---: | :---: | :---: |
| **Waktu Startup / Latensi** | **Cepat** (~25ms Shell / ~3ms Go) | **Ultra Cepat** (~5ms Shell / ~0.8ms Go) | N/A |
| **Penggunaan Memori Maksimal** | **Rendah** (~3.2MB Shell / ~4.5MB Go) | **Sangat Rendah** (~1.1MB Shell / ~1.8MB Go) | N/A |
| **Auto Purge (`drop_caches`/`EmptyWorkingSet`)** | ✅ | ✅ | ✅ (Via `/api/purge`) |
| **Mode Output JSON (`--json`)** | ✅ | ✅ | ✅ (`/api/status`) |
| **Mode Watch (`--watch`)** | ✅ | ✅ | ✅ (Refresh UI Otomatis) |
| **Multi-Bahasa (`ID` / `EN`)** | ✅ | ✅ | ✅ |
| **Mode Dry Run (`--dry-run`)** | ✅ | ✅ | ✅ |
| **Tema Terminal (`classic`/`minimal`/`nerd`)** | ✅ | ❌ (Teks Murni) | ❌ (Tema Gelap CSS) |
| **Notifikasi Desktop & Logging** | ✅ | ❌ | ❌ |
| **Server REST API & Prometheus (`/metrics`)** | ✅ (`--server`) | ❌ | ✅ |
| **Profil Container Docker** | ✅ | ❌ | ✅ |

> **Rekomendasi**: Gunakan **CekRAM Lite** (`cekram-lite.sh`, `cekram-lite.bat`, `cekram-lite.ps1`, atau `go/lite/main.go`) untuk pembuatan script, cron job, pipa CI/CD, dan lingkungan dengan sumber daya terbatas. Gunakan **CekRAM Full** (`cekram.sh`, `cekram.ps1`, Python/Node CLI) untuk tampilan pemantauan terminal yang interaktif atau Web Dashboard.

---

## ⚙️ Dukungan File Konfigurasi

CekRAM secara otomatis mendeteksi file konfigurasi di direktori home pengguna:
- **Linux / macOS**: `~/.cekram.yaml` atau `~/.cekram.json`
- **Windows**: `%USERPROFILE%\.cekram.yaml` atau `%USERPROFILE%\.cekram.json`

### Contoh `~/.cekram.yaml`:
```yaml
language: id
threshold: 85
interval: 3
auto_purge: true
theme: nerd
log: /var/log/cekram_memory.log
notify: true
watch: true
dry_run: false
port: 8080
```
*Catatan: Argumen CLI (`--threshold 90`) selalu diprioritaskan di atas nilai dalam file konfigurasi.*

---

## 🌐 Deteksi Bahasa Otomatis

CekRAM secara cerdas memeriksa lokalitas sistem (`$LC_ALL`, `$LC_MESSAGES`, `$LANG`, dan lokalitas Windows):
- Jika lokalitas sistem dimulai dengan `id` (`id_ID`, `id-ID`), CekRAM otomatis menggunakan **Bahasa Indonesia (`id`)**.
- Jika tidak, CekRAM menggunakan **Bahasa Inggris (`en`)**.
- Bisa diganti kapan saja menggunakan flag `--lang id` atau `--lang en` (`-l id`).

---

## 🛡️ Kode Keluar (Exit Codes) & Output JSON

CekRAM menggunakan kode keluar (exit codes) terstandarisasi yang sangat berguna untuk script otomatis:
- **`0` (OK)** : RAM dalam kondisi aman (`< 60%`).
- **`1` (Warning)** : Penggunaan RAM mulai tinggi (`>= 60%` dan `< threshold`).
- **`2` (Critical)** : Penggunaan RAM mencapai atau melampaui batas `--threshold`.
- **`3` (Purge Gagal)** : Pembersihan RAM dijalankan namun mengalami kendala izin atau sistem.

### Mode JSON (`cekram --json`)
Jalankan CekRAM atau CekRAM Lite dengan `--json` (`-j`) untuk output format mesin yang bersih:
```bash
cekram --oneshot --json
```
```json
{
  "total_ram_mb": 16384,
  "used_ram_mb": 8241,
  "free_ram_mb": 8143,
  "usage_percent": 50,
  "status": "safe"
}
```

---

## 🎨 Tema Terminal & Mode Watch

### Tema Terminal (`--theme <theme>`)
- **`classic`** : Header kotak klasik (`=== SUPER MONITOR ===`) + daftar status lengkap.
- **`minimal`** : Ringkasan satu baris yang padat (`[*] RAM: 236 MB / 3939 MB (5.99%) | Free: 3703 MB | Status: safe`).
- **`nerd`** : Gaya Cyberpunk/Nerd font dengan bar persentase visual (`󰍛 RAM: 4.95% [██░░░░░░░░] ⚡ SAFE :3`).

### Mode Watch (`cekram watch` atau `--watch`)
Berbeda dengan output biasa yang mencetak baris baru secara terus-menerus, mode `watch` memperbarui layar terminal di tempat (`\033[H\033[2J`), menciptakan dashboard live langsung di terminal kamu!

---

## 🖥️ REST API & Prometheus Metrics

Jalankan server HTTP bawaan:
```bash
cekram --server --port 8080 --lang id
```
### Endpoint REST yang Didukung:
- **`GET /api/status?lang=id`** : Data statistik aktual dalam JSON beserta teks status.
- **`GET /api/history`** : Riwayat pemantauan memori dari waktu ke waktu (sliding ring buffer).
- **`POST /api/purge`** (dan `GET /api/purge`) : Menjalankan langsung `EmptyWorkingSet` atau `drop_caches` dan mengembalikan detail hasil.
- **`GET /api/config`** : Menampilkan konfigurasi yang sedang aktif (`threshold`, `interval`, dll.).
- **`POST /api/config`** : Memperbarui parameter konfigurasi secara langsung melalui body JSON (`{"threshold": 85, "theme": "nerd"}`).

### Prometheus Metrics (`GET /metrics`)
Menyediakan metrik standar Prometheus untuk integrasi dengan Grafana:
```text
# HELP cekram_memory_total_bytes Total physical RAM in bytes
# TYPE cekram_memory_total_bytes gauge
cekram_memory_total_bytes 17179869184
# HELP cekram_memory_used_bytes Used physical RAM in bytes
# TYPE cekram_memory_used_bytes gauge
cekram_memory_used_bytes 8641413120
# HELP cekram_memory_available_bytes Free/Available physical RAM in bytes
# TYPE cekram_memory_available_bytes gauge
cekram_memory_available_bytes 8538456064
# HELP cekram_memory_usage_percent RAM usage percentage
# TYPE cekram_memory_usage_percent gauge
cekram_memory_usage_percent 50.3
```

---

## 📊 Perintah Benchmark

Ukur langsung perbandingan latensi startup dan penggunaan memori antara CekRAM Full dan Lite:
```bash
cekram benchmark
# Atau di shell:
./cekram.sh benchmark
```
```text
============================================================
 🏎️ CekRAM Benchmark: Full vs Lite Edition
============================================================
Feature / Metric         | CekRAM Full      | CekRAM Lite     
------------------------------------------------------------
Startup / Scan Latency   | ~25 ms           | ~5 ms
Peak Memory Usage        | ~3.2 MB          | ~1.1 MB
Web Dashboard & API      | Supported (✅)   | None (❌)
JSON Output & Watch      | Supported (✅)   | Supported (✅)
============================================================
```

---

## ❓ FAQ & Troubleshooting

### Q1: Mengapa Auto-Purge membutuhkan `sudo` / `root` di Linux & macOS?
Membersihkan cache tingkat kernel (`echo 3 > /proc/sys/vm/drop_caches` di Linux atau `purge` di macOS) memerlukan hak akses root karena menyangkut manajemen memori sistem OS. Jika dijalankan tanpa hak akses sudo, CekRAM tetap aman menjalankan `sync` untuk menyinkronkan buffer file ke disk tanpa error.

### Q2: Bagaimana cara kerja `EmptyWorkingSet` di Windows tanpa hak Administrator?
Di Windows, `psapi.dll`'s `EmptyWorkingSet` mengembalikan halaman memori fisik proses yang sedang berjalan ke kumpulan memori virtual sistem. Pengguna biasa bisa membersihkan proses milik akun mereka sendiri, sementara instance Administrator dapat membersihkan seluruh proses sistem.

### Q3: Bagaimana cara menguji pembersihan RAM tanpa mengubah status sistem?
Gunakan flag `--dry-run` (`-d`). CekRAM akan menyimulasikan seluruh pengecekan batas sesak dan menampilkan tindakan apa yang seharusnya dijalankan (`[DRY-RUN] Would run sync && drop_caches`) tanpa menjalankan perintah penghapusan cache sesungguhnya.

---

## 📜 Lisensi

Didistribusikan di bawah **MIT License**. Lihat `LICENSE` untuk informasi lebih lanjut.

*Dibuat dengan ❤️ oleh **flessan** dan Kontributor CekRAM.*
