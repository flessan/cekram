# -*- coding: utf-8 -*-
"""
Lightweight zero-dependency HTTP server & REST API for CekRAM Web Dashboard.
Usage: python3 -m cekram.server --port 8080 --lang id
"""

import os
import json
import socketserver
from http.server import SimpleHTTPRequestHandler
from .monitor import get_ram_metrics, purge_memory
from .i18n import get_string, STRINGS


class CekRAMHTTPRequestHandler(SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path.startswith("/api/status"):
            # Parse lang param if present
            lang = "id"
            if "lang=" in self.path:
                lang = self.path.split("lang=")[1].split("&")[0]
            
            metrics = get_ram_metrics()
            status_text = get_string("status_alert", lang) if metrics["percent"] > 80 else get_string("status_safe", lang)
            response = {
                "status": "ok",
                "lang": lang,
                "metrics": metrics,
                "status_text": status_text,
                "i18n": STRINGS.get(lang.lower(), STRINGS["id"])
            }
            self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(json.dumps(response).encode("utf-8"))
            return

        elif self.path.startswith("/api/purge"):
            res = purge_memory()
            response = {
                "status": "purged",
                "success": res.get("success", True),
                "detail": res.get("detail", "RAM working set / cache dropped.")
            }
            self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(json.dumps(response).encode("utf-8"))
            return

        # Serve web dashboard files
        web_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "web"))
        if not os.path.exists(web_dir):
            # Try cwd web folder
            web_dir = os.path.abspath(os.path.join(os.getcwd(), "web"))

        if os.path.exists(web_dir):
            if self.path == "/" or self.path == "":
                self.path = "/index.html"
            # Translate path to web directory
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

        # Fallback inline HTML if web folder not found
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.end_headers()
        self.wfile.write(b"<h1>CekRAM Web Server Running</h1><p>Visit /api/status for JSON metrics.</p>")


def run_server(port: int = 8080, lang: str = "id"):
    print("=" * 50)
    print(f" CekRAM Web Dashboard & REST API Server ({lang.upper()})")
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
