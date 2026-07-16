# ⚡ CEKRAM - Super Monitor & Auto-Purge RAM Universal

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Multi-Language: ID/EN](https://img.shields.io/badge/Language-ID%20|%20EN-00bcd4.svg)](./README.md)
[![Platform: Windows | Linux | macOS](https://img.shields.io/badge/Platform-Windows%20|%20Linux%20|%20macOS-4caf50.svg)](./README.md)
[![Web Dashboard](https://img.shields.io/badge/Dashboard-Live%20Web%20UI-ff9800.svg)](#-web-dashboard--api)

> **"SUPER MONITOR - ACER TRAVELMATE & UNIVERSAL SYSTEM MONITOR"**  
> Monitor RAM super ringan, tanpa dependensi ribet, dan lintas platform dengan fitur **Auto-Purge** (`EmptyWorkingSet` di Windows, `/proc/sys/vm/drop_caches` di Linux, dan `purge` di macOS). Bisa dijalankan langsung via **cURL**, **PowerShell**, **Batch**, **Python**, **Node.js**, **Go**, **Docker**, hingga **Web Dashboard interaktif**!

---

* [🇬🇧 **Read English Documentation (`README.md`)**](./README.md)

---

## 🚀 Cara Cepat (Jalankan Langsung via One-Liners)

### 🐧 Linux & macOS (POSIX Shell via cURL)
Jalankan langsung di terminal kamu tanpa perlu install manual:
```bash
# Default (Bahasa Indonesia ID)
curl -fsSL https://raw.githubusercontent.com/flessan/cekram/main/cekram.sh | bash

# Jalankan dengan Threshold 80% dan refresh tiap 3 detik
curl -fsSL https://raw.githubusercontent.com/flessan/cekram/main/cekram.sh | bash -s -- --lang=id --threshold=80 --interval=3
```

### 🪟 Windows (PowerShell)
Jalankan langsung via PowerShell:
```powershell
# Default (Bahasa Indonesia ID)
irm https://raw.githubusercontent.com/flessan/cekram/main/cekram.ps1 | iex

# Jalankan dengan parameter kustom
& { $(irm https://raw.githubusercontent.com/flessan/cekram/main/cekram.ps1) } -Lang id -Threshold 80 -Interval 3
```

### 🪟 Windows (Batch / `.bat`)
Unduh dan jalankan script Batch universal (`cekram.bat`):
```cmd
cekram.bat --lang id --threshold 80
```

### 🐍 Python (CLI atau Web Server)
Jalankan via Python atau install lewat `pip`:
```bash
# Install via pip
python3 -m pip install git+https://github.com/flessan/cekram.git#subdirectory=python

# Jalankan di terminal
cekram --lang id --threshold 80

# Atau buka Web Dashboard Server di port 8080!
cekram --server --port 8080 --lang id
```

### 📦 Node.js (`npx`)
Jalankan langsung via `npx` tanpa install global:
```bash
npx github:flessan/cekram --lang=id --threshold=80
```

### 🏎️ Go (`go run`)
Jalankan langsung lewat Go:
```bash
go run github.com/flessan/cekram/go@latest --lang=id
```

### 🐳 Docker & Docker Compose
Jalankan di dalam container:
```bash
# CLI Monitor Interaktif
docker run --rm -it flessan/cekram --lang=id

# Atau jalankan Web Dashboard
docker run -d -p 8080:8080 flessan/cekram --server --port 8080 --lang=id
```

---

## ✨ Fitur Utama & Cara Kerja Auto-Purge

Ketika penggunaan RAM melebihi batas (threshold, default `80%`), **CekRAM** otomatis menjalankan pembersihan memori tingkat sistem OS agar RAM kembali plong tanpa menutup aplikasi yang sedang aktif:

1. **Windows (`EmptyWorkingSet`)**:
   - Memanggil API `psapi.dll` (`EmptyWorkingSet`) via PowerShell/Batch/Python/Node/Go untuk mengosongkan working set RAM proses yang tidak aktif ke sistem buffer.
2. **Linux (`/proc/sys/vm/drop_caches`)**:
   - Menghitung akurat `MemAvailable` vs `MemTotal` dari `/proc/meminfo`. Jika sesak, menjalankan `sync` dan menulis `3` ke `/proc/sys/vm/drop_caches` (via root/sudo) untuk membersihkan pagecaches, dentries, dan inodes.
3. **macOS (`purge`)**:
   - Mengecek memori virtual dan menjalankan `sync` serta `purge`.

### 🗣️ Bahasa UI (`ID` / `EN`)
- **Indonesian (`id`)**:  
  `STATUS : Aman Sentosa :3` | `[!] RAM SESAK! Menjalankan Auto-Purge... [+] Selesai! RAM sudah diplongkan.`
- **English (`en`)**:  
  `STATUS : Safe & Sound :3` | `[!] HIGH MEMORY USAGE! Running Auto-Purge... [+] Done! Memory cache synced & purged.`

---

## 📥 Installer Satu Klik Global

Ingin perintah `cekram` bisa dijalankan dari direktori mana saja di terminal kamu?

#### Linux & macOS (`/usr/local/bin/cekram`)
```bash
curl -fsSL https://raw.githubusercontent.com/flessan/cekram/main/install.sh | bash
```

#### Windows (`$HOME\AppData\Local\Programs\CekRAM`)
```powershell
irm https://raw.githubusercontent.com/flessan/cekram/main/install.ps1 | iex
```

---

## 📊 Argumen & Opsi CLI

Semua implementasi (`cekram.sh`, `cekram.bat`, `cekram.ps1`, `python/`, `node/`, `go/`) menggunakan opsi yang sama dan mudah diingat:

| Opsi / Flag | Alias | Default | Deskripsi |
| :--- | :---: | :---: | :--- |
| `--lang <id\|en>` | `-l` | `id` | Pilihan bahasa (`id` untuk Indonesia, `en` untuk Inggris) |
| `--threshold <NUM>` | `-t` | `80` | Batas persentase (`0-100`) untuk menjalankan Auto-Purge |
| `--interval <SEC>` | `-i` | `5` | Jeda waktu pembaruan tampilan (dalam detik) |
| `--oneshot` | `-o` / `--once` | `false` | Jalankan sekali, tampilkan info RAM, lalu keluar |
| `--purge-now` | - | `false` | Langsung jalankan pembersihan RAM dan keluar |
| `--server` *(Python)* | `-s` | `false` | Jalankan server HTTP untuk Web Dashboard interaktif |
| `--port <NUM>` *(Python)* | `-p` | `8080` | Port untuk server Web Dashboard |
| `--help` | `-h` | - | Tampilkan bantuan |

---

## 🖥️ Web Dashboard & API

Jalankan web server lokal:
```bash
python3 -m cekram.server --port 8080 --lang id
```
Buka browser ke `http://localhost:8080`:
- **Gauge Ring Dinamis**: Indikator cincin persentase RAM yang berubah warna hijau (< 60%), kuning (60-80%), atau merah (> 80%).
- **Tombol Purge Interaktif**: Klik `⚡ PLONGKAN RAM SEKARANG` untuk mengosongkan working set langsung dari browser kamu!
- **REST API JSON**:
  - `GET /api/status?lang=id` : Mendapatkan data statistik RAM aktual dalam format JSON.
  - `GET /api/purge` : Menjalankan pembersihan RAM dan mengembalikan status JSON.

---

## 📜 Lisensi

Didistribusikan di bawah **MIT License**. Lihat `LICENSE` untuk informasi lebih lanjut.

*Dibuat dengan ❤️ oleh **flessan** dan Kontributor CekRAM.*
