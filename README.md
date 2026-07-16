# ⚡ CEKRAM - Universal Super RAM Monitor & Auto-Purge

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Multi-Language: ID/EN](https://img.shields.io/badge/Language-ID%20|%20EN-00bcd4.svg)](#-automatic-language-detection)
[![Platform Compatibility](https://img.shields.io/badge/Platform-Windows%20|%20Linux%20|%20macOS-4caf50.svg)](#-platform-compatibility-matrix)
[![CI Pipeline](https://github.com/flessan/cekram/actions/workflows/ci.yml/badge.svg)](https://github.com/flessan/cekram/actions/workflows/ci.yml)
[![Release Pipeline](https://github.com/flessan/cekram/actions/workflows/release.yml/badge.svg)](https://github.com/flessan/cekram/actions/workflows/release.yml)
[![Prometheus Metrics](https://img.shields.io/badge/Prometheus-Exposed%20%2Fmetrics-E6522C.svg)](#-prometheus-metrics)

> **"SUPER MONITOR - ACER TRAVELMATE & UNIVERSAL SYSTEM MONITOR"**  
> Lightweight, zero-dependency, cross-platform RAM monitor with **Auto-Purge** capabilities (`EmptyWorkingSet` on Windows, `/proc/sys/vm/drop_caches` on Linux, and `purge` on macOS). Available in **Full Edition** (with Web UI, HTTP Server, Themes, and REST API) and **CekRAM Lite** (ultra-fast, minimal overhead, zero dependencies).

---

* [🇮🇩 **Baca Dokumentasi Bahasa Indonesia (`README.id.md`)**](./README.id.md)

---

## 📋 Table of Contents
- [🚀 Quick Start (One-Liners)](#-quick-start-one-liners)
- [🏎️ CekRAM Lite vs Full Edition Comparison](#-cekram-lite-vs-full-edition-comparison)
- [⚙️ Configuration File Support](#-configuration-file-support)
- [🌐 Automatic Language Detection](#-automatic-language-detection)
- [🛡️ Exit Codes & JSON Output](#-exit-codes--json-output)
- [🎨 Terminal Themes & Watch Mode](#-terminal-themes--watch-mode)
- [🖥️ REST API & Prometheus Metrics](#-rest-api--prometheus-metrics)
- [🐳 Docker Usage](#-docker-usage)
- [📊 Benchmark Command](#-benchmark-command)
- [📥 One-Click Installers & Build Matrix](#-one-click-installers--build-matrix)
- [❓ FAQ & Troubleshooting](#-faq--troubleshooting)

---

## 🚀 Quick Start (One-Liners)

### 🐧 Linux & macOS via cURL (POSIX Shell)
```bash
# Full Edition (Interactive loop or watch mode)
curl -fsSL https://raw.githubusercontent.com/flessan/cekram/main/cekram.sh | bash -s -- --theme nerd --watch

# CekRAM Lite (Ultra-fast minimal output)
curl -fsSL https://raw.githubusercontent.com/flessan/cekram/main/cekram-lite.sh | bash
```

### 🪟 Windows via PowerShell (`irm | iex`)
```powershell
# Run Full Edition online
irm https://raw.githubusercontent.com/flessan/cekram/main/cekram.ps1 | iex

# Run CekRAM Lite online
irm https://raw.githubusercontent.com/flessan/cekram/main/cekram-lite.ps1 | iex
```

### 🐍 Python (`pip`) or 📦 Node.js (`npx`) or 🏎️ Go (`go run`)
```bash
# Python CLI / Web Server
python3 -m pip install git+https://github.com/flessan/cekram.git#subdirectory=python
cekram --theme nerd --watch
cekram --server --port 8080

# Node.js CLI via npx
npx github:flessan/cekram --json --oneshot

# Go Native Execution
go run github.com/flessan/cekram/go@latest --threshold=85
```

---

## 🏎️ CekRAM Lite vs Full Edition Comparison

**CekRAM Lite** (`cekram-lite`) is designed for maximum performance, minimal memory footprint, and high-frequency automation (cron jobs, CI/CD, embedded devices, and VPS containers).

```text
TOTAL RAM : 16384 MB
USED RAM  : 6144 MB
FREE RAM  : 10240 MB
USAGE     : 37%
STATUS    : SAFE
```

### Feature & Performance Matrix

| Feature | CekRAM Full | CekRAM Lite | Web Dashboard |
| :--- | :---: | :---: | :---: |
| **Startup Latency** | **Fast** (~25ms Shell / ~3ms Go) | **Ultra Fast** (~5ms Shell / ~0.8ms Go) | N/A |
| **Peak Memory Usage** | **Low** (~3.2MB Shell / ~4.5MB Go) | **Extremely Low** (~1.1MB Shell / ~1.8MB Go) | N/A |
| **Auto Purge (`drop_caches`/`EmptyWorkingSet`)** | ✅ | ✅ | ✅ (Via `/api/purge`) |
| **JSON Output Mode (`--json`)** | ✅ | ✅ | ✅ (`/api/status`) |
| **Watch Mode (`--watch`)** | ✅ | ✅ | ✅ (Auto-refresh UI) |
| **Multi-Language (`ID` / `EN`)** | ✅ | ✅ | ✅ |
| **Dry Run Mode (`--dry-run`)** | ✅ | ✅ | ✅ |
| **Terminal Themes (`classic`/`minimal`/`nerd`)** | ✅ | ❌ (Pure Text) | ❌ (CSS Dark Theme) |
| **Desktop Notifications & Logging** | ✅ | ❌ | ❌ |
| **REST API Server & Prometheus (`/metrics`)** | ✅ (`--server`) | ❌ | ✅ |
| **Docker Container Profiles** | ✅ | ❌ | ✅ |

> **Recommendation**: Use **CekRAM Lite** (`cekram-lite.sh`, `cekram-lite.bat`, `cekram-lite.ps1`, or `go/lite/main.go`) for cron jobs, CI/CD checks, and resource-constrained environments. Use **CekRAM Full** (`cekram.sh`, `cekram.ps1`, Python/Node CLIs) for rich terminal monitors and online web dashboards.

---

## ⚙️ Configuration File Support

CekRAM automatically checks for a configuration file in your home directory:
- **Linux / macOS**: `~/.cekram.yaml` or `~/.cekram.json`
- **Windows**: `%USERPROFILE%\.cekram.yaml` or `%USERPROFILE%\.cekram.json`

### Example `~/.cekram.yaml`:
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
*Note: CLI flags (`--threshold 90`) always override configuration values.*

---

## 🌐 Automatic Language Detection

CekRAM intelligently inspects system locale (`$LC_ALL`, `$LC_MESSAGES`, `$LANG`, and Windows user default UI language):
- If the system locale starts with `id` (`id_ID`, `id-ID`), CekRAM defaults to **Bahasa Indonesia (`id`)**.
- Otherwise, it defaults to **English (`en`)**.
- Override anytime with `--lang id` or `--lang en` (`-l en`).

---

## 🛡️ Exit Codes & JSON Output

CekRAM uses standardized, predictable exit codes suitable for automated scripting and alerting:
- **`0` (OK)** : RAM usage is within safe bounds (`< 60%`).
- **`1` (Warning)** : RAM usage is elevated (`>= 60%` and `< threshold`).
- **`2` (Critical)** : RAM usage reached or exceeded the configured `--threshold`.
- **`3` (Purge Failed)** : Memory purge was attempted but encountered a permission or system error.

### JSON Mode (`cekram --json`)
Run any CekRAM or CekRAM Lite implementation with `--json` (`-j`) for pure machine-readable output:
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

## 🎨 Terminal Themes & Watch Mode

### Terminal Themes (`--theme <theme>`)
- **`classic`** : Standard box header (`=== SUPER MONITOR ===`) + clear status list.
- **`minimal`** : Compact single-line summary (`[*] RAM: 236 MB / 3939 MB (5.99%) | Free: 3703 MB | Status: safe`).
- **`nerd`** : Cyberpunk/Nerd font styling with progress bars (`󰍛 RAM: 4.95% [██░░░░░░░░] ⚡ SAFE :3`).

### Watch Mode (`cekram watch` or `--watch`)
Instead of printing new lines indefinitely, `watch` mode dynamically refreshes the terminal screen in place (`\033[H\033[2J`), creating a live dashboard directly inside your terminal!

---

## 🖥️ REST API & Prometheus Metrics

Launch the built-in HTTP server:
```bash
cekram --server --port 8080 --lang en
```
### Supported REST Endpoints:
- **`GET /api/status?lang=en`** : Returns real-time JSON metrics, threshold status, and localization dictionary.
- **`GET /api/history`** : Returns a sliding timestamped window of past memory checks (ring buffer).
- **`POST /api/purge`** (and `GET /api/purge`) : Executes immediate `EmptyWorkingSet` or `drop_caches` and returns result details.
- **`GET /api/config`** : Returns active system configurations (`threshold`, `interval`, etc.).
- **`POST /api/config`** : Updates configuration parameters dynamically via JSON body (`{"threshold": 85, "theme": "nerd"}`).

### Prometheus Metrics (`GET /metrics`)
Exposes standard Prometheus open-metrics format for Grafana dashboards:
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

## 🐳 Docker Usage

Run CekRAM inside a Docker container:
```bash
# Interactive Monitor
docker run --rm -it flessan/cekram --lang=en --theme nerd --watch

# Launch Web Dashboard Server
docker run -d -p 8080:8080 flessan/cekram --server --port 8080 --lang=en
```

---

## 📊 Benchmark Command

Measure startup latency, memory footprint, and overhead across implementations right from your terminal:
```bash
cekram benchmark
# Or in shell:
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

## 📥 One-Click Installers & Build Matrix

### One-Click Global Installers
- **Linux / macOS**:
  ```bash
  curl -fsSL https://raw.githubusercontent.com/flessan/cekram/main/install.sh | bash
  ```
- **Windows (PowerShell)**:
  ```powershell
  irm https://raw.githubusercontent.com/flessan/cekram/main/install.ps1 | iex
  ```

### Local Build (`make build`)
You can compile all cross-platform binaries, zip files, tarballs, and `SBOM.json` right on your machine:
```bash
make build
```

### 📂 Repository Structure & Automated Release Pipelines
```text
cekram/
├── README.md               # Comprehensive English documentation
├── README.id.md            # Dokumentasi lengkap Bahasa Indonesia
├── LICENSE                 # MIT License
├── Makefile                # Cross-platform build & test automation (`make test`, `make build`)
├── build_releases.sh       # Release artifact packager (`.tar.gz`, `.zip`, `SHA256SUMS`, `SBOM.json`)
├── cekram.bat              # Universal Windows Batch script (psapi.dll integration)
├── cekram.ps1              # Native Windows PowerShell script with colored UI & themes
├── cekram.sh               # POSIX Shell script (Linux, macOS, Termux, BSD)
├── cekram-lite.bat         # CekRAM Lite - Ultra-fast minimal Windows Batch script
├── cekram-lite.ps1         # CekRAM Lite - Ultra-fast minimal Windows PowerShell script
├── cekram-lite.sh          # CekRAM Lite - Ultra-fast minimal POSIX Shell script
├── github-workflows-templates/ # CI/CD & Automated Release workflows (`ci.yml`, `release.yml`, `codeql.yml`)
├── install.sh              # One-click global installer for Linux & macOS
├── install.ps1             # One-click global installer for Windows
├── python/                 # Python package (`cekram` CLI, `cekram.server`, and tests)
├── node/                   # Node.js module (`npx cekram`)
├── go/                     # Go module (`go run main.go` & `go/lite/main.go`)
├── docker/                 # Docker and docker-compose configurations
└── web/                    # Single-Page Web Dashboard (`index.html`, `style.css`, `app.js`)
```
> **GitHub Actions CI/CD Note**: To enable automatic GitHub Release pipelines, CI testing, and CodeQL security scanning in your fork without token scope errors, copy the files from `github-workflows-templates/` into `.github/workflows/`.

---

## ❓ FAQ & Troubleshooting

### Q1: Why does Auto-Purge require `sudo` / `root` on Linux & macOS?
Dropping kernel pagecaches (`echo 3 > /proc/sys/vm/drop_caches` on Linux or `purge` on macOS) requires root privileges because it modifies kernel-level memory management. If run as a regular user without passwordless `sudo`, CekRAM safely executes `sync` to flush file buffers to disk without crashing.

### Q2: How does `EmptyWorkingSet` work on Windows without Administrator rights?
On Windows, `psapi.dll`'s `EmptyWorkingSet` flushes the physical memory pages assigned to running processes back to the system virtual working pool. Standard users can flush their own user-owned processes, while elevated (Admin) instances can flush system-wide processes.

### Q3: How do I test what Auto-Purge will do without modifying memory?
Pass the `--dry-run` (`-d`) flag to any CekRAM script or API endpoint. It will simulate all threshold triggers and print what actions would have been taken (`[DRY-RUN] Would run sync && drop_caches`).

---

## 📜 License

Distributed under the **MIT License**. See `LICENSE` for details.

*Created with ❤️ by **flessan** and CekRAM Contributors.*
