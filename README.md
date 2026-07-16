# ⚡ CEKRAM - Universal Super RAM Monitor & Auto-Purge

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Multi-Language: ID/EN](https://img.shields.io/badge/Language-ID%20|%20EN-00bcd4.svg)](#multi-language-support)
[![Platform: Windows | Linux | macOS](https://img.shields.io/badge/Platform-Windows%20|%20Linux%20|%20macOS-4caf50.svg)](#supported-platforms)
[![Web Dashboard](https://img.shields.io/badge/Dashboard-Live%20Web%20UI-ff9800.svg)](#-web-dashboard--api)

> **"SUPER MONITOR - ACER TRAVELMATE & UNIVERSAL SYSTEM MONITOR"**  
> Lightweight, zero-dependency, cross-platform RAM monitor with **Auto-Purge** capabilities (`EmptyWorkingSet` on Windows, `/proc/sys/vm/drop_caches` on Linux, and `purge` on macOS). Run instantly via **cURL**, **PowerShell**, **Batch**, **Python**, **Node.js**, **Go**, **Docker**, or as a live **Web Dashboard**!

---

* [🇮🇩 **Baca Dokumentasi Bahasa Indonesia (`README.id.md`)**](./README.id.md)

---

## 🚀 Quick Start (Run Anywhere via One-Liners)

### 🐧 Linux & macOS (POSIX Shell via cURL)
Run directly in your terminal without installing anything locally:
```bash
# Default (Indonesian ID)
curl -fsSL https://raw.githubusercontent.com/flessan/cekram/main/cekram.sh | bash

# Run with English UI, 80% Threshold, and 3-second refresh interval
curl -fsSL https://raw.githubusercontent.com/flessan/cekram/main/cekram.sh | bash -s -- --lang=en --threshold=80 --interval=3
```

### 🪟 Windows (PowerShell)
Run directly in PowerShell:
```powershell
# Default (Indonesian ID)
irm https://raw.githubusercontent.com/flessan/cekram/main/cekram.ps1 | iex

# Run with English UI and custom threshold
& { $(irm https://raw.githubusercontent.com/flessan/cekram/main/cekram.ps1) } -Lang en -Threshold 80 -Interval 3
```

### 🪟 Windows (Batch / `.bat`)
Download and run the classic Windows Batch script (`cekram.bat`):
```cmd
cekram.bat --lang en --threshold 80
```

### 🐍 Python (CLI or Built-in Web Server)
Run directly via Python or install globally via `pip`:
```bash
# Install via pip
python3 -m pip install git+https://github.com/flessan/cekram.git#subdirectory=python

# Run CLI monitor
cekram --lang en --threshold 80

# Launch the live Web Dashboard Server on port 8080!
cekram --server --port 8080 --lang en
```

### 📦 Node.js (`npx`)
Run directly via `npx` (zero local installation needed):
```bash
npx github:flessan/cekram --lang=en --threshold=80
```

### 🏎️ Go (`go run`)
Run natively via Go compiler:
```bash
go run github.com/flessan/cekram/go@latest --lang=en
```

### 🐳 Docker & Docker Compose
Run inside a sandboxed container:
```bash
# Interactive CLI Monitor
docker run --rm -it flessan/cekram --lang=en

# Or run the Web Dashboard
docker run -d -p 8080:8080 flessan/cekram --server --port 8080 --lang=en
```

---

## ✨ Key Features & How Auto-Purge Works

When RAM usage exceeds the configured threshold (default `80%`), **CekRAM** automatically triggers native OS memory cleanup routines without disrupting running applications:

1. **Windows (`EmptyWorkingSet`)**:
   - Dynamically loads `psapi.dll` (`EmptyWorkingSet`) to iterate through running process handles and flush inactive memory working sets back to the system buffer.
2. **Linux (`/proc/sys/vm/drop_caches`)**:
   - Accurately calculates `MemAvailable` vs `MemTotal` from `/proc/meminfo`. When triggered, runs `sync` and writes `3` to `/proc/sys/vm/drop_caches` (via root/sudo) to reclaim pagecaches, dentries, and inodes.
3. **macOS (`purge`)**:
   - Evaluates active vs free virtual memory pages and invokes `sync` and system `purge`.

### 🗣️ Bilingual UI (`ID` / `EN`)
- **Indonesian (`id`)**:  
  `STATUS : Aman Sentosa :3` | `[!] RAM SESAK! Menjalankan Auto-Purge... [+] Selesai! RAM sudah diplongkan.`
- **English (`en`)**:  
  `STATUS : Safe & Sound :3` | `[!] HIGH MEMORY USAGE! Running Auto-Purge... [+] Done! Memory cache synced & purged.`

---

## 📥 One-Click Global Installers

Want `cekram` available everywhere (`cekram --help`) across your terminal?

#### Linux & macOS (`/usr/local/bin/cekram`)
```bash
curl -fsSL https://raw.githubusercontent.com/flessan/cekram/main/install.sh | bash
```

#### Windows (`$HOME\AppData\Local\Programs\CekRAM`)
```powershell
irm https://raw.githubusercontent.com/flessan/cekram/main/install.ps1 | iex
```

---

## 📊 CLI Options & Arguments

All implementations (`cekram.sh`, `cekram.bat`, `cekram.ps1`, `python/`, `node/`, `go/`) share consistent options:

| Flag / Option | Alias | Default | Description |
| :--- | :---: | :---: | :--- |
| `--lang <id\|en>` | `-l` | `id` | Language selection (`id` for Indonesian, `en` for English) |
| `--threshold <NUM>` | `-t` | `80` | Percentage threshold (`0-100`) to trigger Auto-Purge |
| `--interval <SEC>` | `-i` | `5` | Refresh interval in seconds |
| `--oneshot` | `-o` / `--once` | `false` | Run once, display metrics, and exit immediately |
| `--purge-now` | - | `false` | Trigger immediate memory purge and exit |
| `--server` *(Python)* | `-s` | `false` | Launch live HTTP Web Dashboard server |
| `--port <NUM>` *(Python)* | `-p` | `8080` | Port for Web Dashboard server |
| `--help` | `-h` | - | Show usage and options |

---

## 🖥️ Web Dashboard & REST API

Launch the standalone web server:
```bash
python3 -m cekram.server --port 8080 --lang en
```
Open `http://localhost:8080` in your web browser:
- **Real-Time Progress Ring**: Visual indicator that turns green (< 60%), yellow (60-80%), or red (> 80%).
- **Interactive Purge Button**: Click `⚡ PURGE RAM NOW` to trigger remote working set / cache cleanup.
- **JSON REST Endpoints**:
  - `GET /api/status?lang=en` : Returns current memory statistics and localization JSON.
  - `GET /api/purge` : Executes memory cleanup and returns result status.

---

## 🛠️ Repository Structure

```text
cekram/
├── README.md               # Comprehensive English documentation
├── README.id.md            # Dokumentasi lengkap Bahasa Indonesia
├── LICENSE                 # MIT License
├── cekram.bat              # Universal Windows Batch script (PowerShell psapi.dll integration)
├── cekram.ps1              # Native Windows PowerShell script with colored UI
├── cekram.sh               # POSIX Shell script (Linux, macOS, Termux, BSD)
├── install.sh              # One-click global installer for Linux & macOS
├── install.ps1             # One-click global installer for Windows
├── python/                 # Python package (`cekram` CLI & `cekram.server`)
├── node/                   # Node.js module (`npx cekram`)
├── go/                     # Go module (`go run main.go`)
├── docker/                 # Docker and docker-compose configurations
└── web/                    # Single-Page Web Dashboard (`index.html`, `style.css`, `app.js`)
```

---

## 📜 License

Distributed under the **MIT License**. See `LICENSE` for details.

*Created with ❤️ by **flessan** and CekRAM Contributors.*
