#!/usr/bin/env bash
# ==============================================================================
# CekRAM Installer for Linux, macOS & Termux
# Usage: curl -fsSL https://raw.githubusercontent.com/flessan/cekram/main/install.sh | bash
# ==============================================================================

set -e

REPO_URL="https://raw.githubusercontent.com/flessan/cekram/main"
INSTALL_DIR="/usr/local/bin"

if [[ $EUID -ne 0 ]]; then
    if command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
        SUDO="sudo"
    elif [[ -w "/usr/local/bin" ]]; then
        SUDO=""
    else
        INSTALL_DIR="$HOME/.local/bin"
        mkdir -p "$INSTALL_DIR"
        SUDO=""
    fi
else
    SUDO=""
fi

echo "=================================================="
echo "          Installing CekRAM CLI..."
echo "=================================================="

# Download cekram.sh
if command -v curl >/dev/null 2>&1; then
    $SUDO curl -fsSL "$REPO_URL/cekram.sh" -o "$INSTALL_DIR/cekram"
elif command -v wget >/dev/null 2>&1; then
    $SUDO wget -qO "$INSTALL_DIR/cekram" "$REPO_URL/cekram.sh"
else
    echo "[!] Error: Neither curl nor wget found. Please install curl or wget first."
    exit 1
fi

$SUDO chmod +x "$INSTALL_DIR/cekram"

echo "[+] Successfully installed CekRAM to: $INSTALL_DIR/cekram"
echo ""
echo "Try running:"
echo "  cekram --lang id --threshold 80"
echo "  cekram --lang en --oneshot"
echo "=================================================="
