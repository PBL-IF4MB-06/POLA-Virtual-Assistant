#!/usr/bin/env python3
"""Serve POLA download website + proxy AI backend API."""
from __future__ import annotations

import http.server
import os
import socketserver
import sys
import urllib.error
import urllib.request

BACKEND = os.environ.get("POLA_BACKEND_PROXY", "http://127.0.0.1:8787").rstrip("/")
SITE_ROOT = os.environ.get("POLA_SITE_ROOT", ".")
PORT = int(sys.argv[1] if len(sys.argv) > 1 else "8080")


class SiteHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=SITE_ROOT, **kwargs)

    def log_message(self, fmt, *args):
        print(f"[{self.address_string()}] {fmt % args}")

    def end_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(204)
        self.end_headers()

    def do_GET(self):
        path = self.path.split("?", 1)[0]
        if path == "/health":
            self._proxy("GET")
            return
        if path == "/app":
            self.send_response(301)
            self.send_header("Location", "/app/")
            self.end_headers()
            return
        super().do_GET()

    def do_POST(self):
        if self.path.split("?", 1)[0] == "/v1/chat":
            self._proxy("POST")
            return
        self.send_error(404)

    def _proxy(self, method: str):
        url = BACKEND + self.path
        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length) if length else None
        req = urllib.request.Request(url, data=body, method=method)
        content_type = self.headers.get("Content-Type")
        if content_type:
            req.add_header("Content-Type", content_type)
        try:
            with urllib.request.urlopen(req, timeout=90) as resp:
                data = resp.read()
                self.send_response(resp.status)
                ct = resp.headers.get("Content-Type", "application/json")
                self.send_header("Content-Type", ct)
                self.send_header("Content-Length", str(len(data)))
                self.end_headers()
                self.wfile.write(data)
        except urllib.error.HTTPError as e:
            data = e.read()
            self.send_response(e.code)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(data)))
            self.end_headers()
            self.wfile.write(data)
        except Exception as e:
            msg = (
                '{"error":"Backend AI offline. Jalankan npm start di folder server.",'
                f'"detail":"{e}"}}'
            ).encode("utf-8")
            self.send_response(502)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(msg)))
            self.end_headers()
            self.wfile.write(msg)


class ThreadingServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
    allow_reuse_address = True
    daemon_threads = True


if __name__ == "__main__":
    os.chdir(SITE_ROOT)
    with ThreadingServer(("0.0.0.0", PORT), SiteHandler) as httpd:
        print(f"POLA website: {SITE_ROOT}")
        print(f"API proxy -> {BACKEND} on http://0.0.0.0:{PORT}")
        httpd.serve_forever()
