# CekRAM Universal Makefile
.PHONY: test build install clean benchmark help

help:
	@echo "CekRAM Makefile Targets:"
	@echo "  make test       - Run all test suites (Python, Node, Shell)"
	@echo "  make build      - Build local release artifacts"
	@echo "  make benchmark  - Run startup & memory benchmarks across Full vs Lite"
	@echo "  make install    - Run local installer script"
	@echo "  make clean      - Remove build artifacts and logs"

test:
	@echo "[*] Running Shell Tests..."
	@bash -n cekram.sh && bash -n cekram-lite.sh && ./cekram.sh --oneshot --json && ./cekram-lite.sh --json
	@echo "[*] Running Python Tests..."
	@cd python && PYTHONPATH=. python3 -m unittest discover tests/ -v
	@echo "[*] Running Node Tests..."
	@cd node && npm test && node bin/cekram.js --oneshot --json

build:
	@chmod +x build_releases.sh && ./build_releases.sh

benchmark:
	@./cekram.sh benchmark
	@cd python && PYTHONPATH=. python3 -m cekram.cli benchmark

install:
	@chmod +x install.sh && ./install.sh

clean:
	@rm -rf dist/ *.log *.tar.gz *.zip python/*.egg-info python/build/ python/dist/
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
