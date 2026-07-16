# -*- coding: utf-8 -*-
"""
Lightweight zero-dependency HTTP server, REST API & Prometheus metrics for CekRAM.
Supports:
  - GET /api/status
  - GET /api/history
  - POST /api/purge
  - GET /api/config
  - POST /api/config
  - GET /metrics (Prometheus)
"""

import os
import time
import json
import socketserver
from http.server import SimpleHTTPRequestHandler
from typing import List, Dict, Any
from .monitor import get_ram_metrics, purge_memory
from .i18n import get_string, STRINGS
from .config import load_config

# Global history ring buffer for /api/history
METRICS_HISTORY: List[Dict[str, Any]] = []
MAX_HISTORY_LEN = 100
CURRENT_CONFIG = load_config()


def record_metrics(metrics: Dict[str, Any]):
    entry = {
        "timestamp": int(time.time()),
        "time_str": time.strftime("%H:%M:%S"),
        "metrics": metrics
    }
    METRICS_HISTORY.append(entry)
    if len(METRICS_HISTORY) > MAX_HISTORY_LEN:
        METRICS_HISTORY.pop(0)


class CekRAMHTTPRequestHandler(SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path.startswith("/api/status"):
            lang = CURRENT_CONFIG.get("language", "id")
            if "lang=" in self.path:
                lang = self.path.split("lang=")[1].split("&")[0]

            metrics = get_ram_metrics()
            record_metrics(metrics)
            threshold = CURRENT_CONFIG.get("threshold", 80)
            status_word = "critical" if metrics["percent"] >= threshold else ("warning" if metrics["percent"] >= 60 else "safe")
            status_text = get_string("status_alert", lang) if status_word == "critical" else get_string("status_safe", lang)

            response = {
                "status": status_word,
                "lang": lang,
                "metrics": metrics,
                "status_text": status_text,
                "i18n": STRINGS.get(lang.lower(), STRINGS["id"]),
                "config": CURRENT_CONFIG
            }
            self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(json.dumps(response).encode("utf-8"))
            return

        elif self.path.startswith("/api/history"):
            metrics = get_ram_metrics()
            record_metrics(metrics)
            response = {
                "status": "ok",
                "count": len(METRICS_HISTORY),
                "history": METRICS_HISTORY
            }
            self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(json.dumps(response).encode("utf-8"))
            return

        elif self.path.startswith("/api/config"):
            self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(json.dumps({"status": "ok", "config": CURRENT_CONFIG}).encode("utf-8"))
            return

        elif self.path.startswith("/api/purge"):
            dry_run = CURRENT_CONFIG.get("dry_run", False)
            if "dry_run=true" in self.path.lower():
                dry_run = True
            res = purge_memory(dry_run=dry_run)
            response = {
                "status": "purged",
                "success": res.get("success", True),
                "detail": res.get("detail", "RAM working set / cache dropped."),
                "dry_run": dry_run
            }
            self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(json.dumps(response).encode("utf-8"))
            return

        elif self.path.startswith("/metrics"):
            metrics = get_ram_metrics()
            total_bytes = metrics["total_mb"] * 1024 * 1024
            used_bytes = metrics["used_mb"] * 1024 * 1024
            free_bytes = metrics["free_mb"] * 1024 * 1024
            prom_text = f"""# HELP cekram_memory_total_bytes Total physical RAM in bytes
# TYPE cekram_memory_total_bytes gauge
cekram_memory_total_bytes {total_bytes}
# HELP cekram_memory_used_bytes Used physical RAM in bytes
# TYPE cekram_memory_used_bytes gauge
cekram_memory_used_bytes {used_bytes}
# HELP cekram_memory_available_bytes Free/Available physical RAM in bytes
# TYPE cekram_memory_available_bytes gauge
cekram_memory_available_bytes {free_bytes}
# HELP cekram_memory_usage_percent RAM usage percentage
# TYPE cekram_memory_usage_percent gauge
cekram_memory_usage_percent {metrics["percent"]}
"""
            self.send_response(200)
            self.send_header("Content-Type", "text/plain; version=0.0.4; charset=utf-8")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(prom_text.encode("utf-8"))
            return

        # Serve web dashboard files
        web_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "web"))
        if not os.path.exists(web_dir):
            web_dir = os.path.abspath(os.path.join(os.getcwd(), "web"))

        if os.path.exists(web_dir):
            if self.path == "/" or self.path == "":
                self.path = "/index.html"
            clean_path = self.path.lstrip("/")
            file_path = os.path.join(web_dir, clean_path)
            if os.path.exists(file_path) and os.path.isfile(file_path):
                self.send_response(200)
                if file_path.endswith(".html"):
                    self.send_header("Content-Type", "text/html; charset=utf-8")
                elif file_path.endswith(".css"):
                    self.send_header("Content-Type", "text/css; charset=utf-8")
                elif file_path.endswith(".js"):
                    self.send_header("Content-Type", "application/javascript; charset=utf-8")
                self.end_headers()
                with open(file_path, "rb") as f:
                    self.wfile.write(f.read())
                return

        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.end_headers()
        self.wfile.write(b"<h1>CekRAM Web Server Running</h1><p>Visit /api/status for JSON metrics or /metrics for Prometheus.</p>")

    def do_POST(self):
        if self.path.startswith("/api/purge"):
            dry_run = CURRENT_CONFIG.get("dry_run", False)
            res = purge_memory(dry_run=dry_run)
            response = {
                "status": "purged",
                "success": res.get("success", True),
                "detail": res.get("detail", "RAM working set / cache dropped."),
                "dry_run": dry_run
            }
            self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(json.dumps(response).encode("utf-8"))
            return

        elif self.path.startswith("/api/config"):
            try:
                content_length = int(self.headers.get("Content-Length", 0))
                post_data = self.rfile.read(content_length).decode("utf-8") if content_length > 0 else "{}"
                updates = json.loads(post_data)
                for k, v in updates.items():
                    CURRENT_CONFIG[k] = v
                self.send_response(200)
                self.send_header("Content-Type", "application/json; charset=utf-8")
                self.send_header("Access-Control-Allow-Origin", "*")
                self.end_headers()
                self.wfile.write(json.dumps({"status": "updated", "config": CURRENT_CONFIG}).encode("utf-8"))
            except Exception as e:
                self.send_response(400)
                self.send_header("Content-Type", "application/json; charset=utf-8")
                self.end_headers()
                self.wfile.write(json.dumps({"status": "error", "message": str(e)}).encode("utf-8"))
            return

        self.send_response(404)
        self.end_headers()


def run_server(port: int = 8080, lang: str = "id"):
    CURRENT_CONFIG["port"] = port
    CURRENT_CONFIG["language"] = lang
    print("=" * 50)
    print(f" CekRAM Web Dashboard, REST API & Prometheus Server ({lang.upper()})")
    print(f" Listening on http://localhost:{port}")
    print("=" * 50)
    with socketserver.TCPServer(("", port), CekRAMHTTPRequestHandler) as httpd:
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n[+] Shutting down server.")


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="CekRAM Web Server")
    parser.add_argument("--port", "-p", type=int, default=8080, help="Port to listen on")
    parser.add_argument("--lang", "-l", choices=["id", "en"], default="id", help="Language selection")
    args = parser.parse_args()
    run_server(port=args.port, lang=args.lang)
