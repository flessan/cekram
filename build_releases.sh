#!/usr/bin/env bash
# ==============================================================================
# Local Release Artifact Builder for CekRAM
# Usage: ./build_releases.sh [VERSION_TAG]
# ==============================================================================

set -e

VERSION="${1:-v1.1.0}"
DIST_DIR="dist"

echo "=================================================="
echo " Building CekRAM Cross-Platform Release Artifacts"
echo " Version: $VERSION"
echo "=================================================="

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

# Check if go is installed
if command -v go >/dev/null 2>&1; then
    PLATFORMS="linux/amd64 linux/arm64 darwin/amd64 darwin/arm64 windows/amd64 windows/arm64"
    for PLAT in $PLATFORMS; do
        GOOS=${PLAT%/*}
        GOARCH=${PLAT#*/}
        EXT=""
        [[ "$GOOS" == "windows" ]] && EXT=".exe"
        
        echo "[*] Compiling Go binaries for $GOOS/$GOARCH..."
        CGO_ENABLED=0 GOOS=$GOOS GOARCH=$GOARCH go build -ldflags="-s -w" -o "$DIST_DIR/cekram-${GOOS}-${GOARCH}${EXT}" ./go/main.go 2>/dev/null || true
        CGO_ENABLED=0 GOOS=$GOOS GOARCH=$GOARCH go build -ldflags="-s -w" -o "$DIST_DIR/cekram-lite-${GOOS}-${GOARCH}${EXT}" ./go/lite/main.go 2>/dev/null || true
    done
fi

# Package scripts and archives
echo "[*] Creating tarballs and zip archives..."
tar -czf "$DIST_DIR/cekram-scripts-universal.tar.gz" cekram.sh cekram.bat cekram.ps1 cekram-lite.sh cekram-lite.bat cekram-lite.ps1

cd "$DIST_DIR"
if command -v sha256sum >/dev/null 2>&1; then
    sha256sum * > SHA256SUMS
elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 * > SHA256SUMS
fi

cat <<EOF > SBOM.json
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.4",
  "version": 1,
  "metadata": {
    "timestamp": "$(date -u +'%Y-%m-%dT%H:%M:%SZ')",
    "component": { "type": "application", "name": "cekram", "version": "$VERSION" }
  },
  "components": [
    { "type": "application", "name": "cekram-full", "description": "Universal Super RAM Monitor & Auto-Purge" },
    { "type": "application", "name": "cekram-lite", "description": "Ultra-Fast Minimal Memory Monitor Lite Edition" }
  ]
}
EOF

cd ..
echo "[+] Successfully generated artifacts inside $DIST_DIR/"
ls -lh "$DIST_DIR/"
