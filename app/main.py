#!/usr/bin/env python3

import html
import json
import os
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

PORT = int(os.environ.get("APP_PORT", "8080"))


def _db_password():
    """Read the DB password from the mounted secret file, or an env var."""
    path = os.environ.get("DB_PASSWORD_FILE")
    if path and os.path.exists(path):
        with open(path, encoding="utf-8") as fh:
            return fh.read().strip()
    return os.environ.get("DB_PASSWORD")


def db_config():
    return {
        "host": os.environ.get("DB_HOST", "127.0.0.1"),
        "port": int(os.environ.get("DB_PORT", "5432")),
        "dbname": os.environ.get("DB_NAME", "postgres"),
        "user": os.environ.get("DB_USER", "app_user"),
    }


def check_db():
    """Attempt a connection and a trivial query; report the outcome."""
    cfg = db_config()
    result = {"configured": True, "ok": False, "message": "", "version": None,
              "latency_ms": None, **cfg}

    password = _db_password()
    if not password:
        result["message"] = "No DB password available (DB_PASSWORD_FILE/DB_PASSWORD unset)."
        return result

    try:
        import psycopg  # imported lazily so the server still starts without it
    except ImportError:
        result["message"] = "psycopg driver not installed."
        return result

    start = time.monotonic()
    try:
        with psycopg.connect(connect_timeout=3, password=password, **cfg) as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT version()")
                result["version"] = cur.fetchone()[0]
        result["ok"] = True
        result["message"] = "Connected successfully."
    except Exception as exc:  # noqa: BLE001 - report any driver/network error
        result["message"] = f"{type(exc).__name__}: {exc}"
    finally:
        result["latency_ms"] = round((time.monotonic() - start) * 1000, 1)
    return result


def report_html():
    db = check_db()
    ok = db["ok"]
    color = "#1a7f37" if ok else "#cf222e"
    badge = "CONNECTED" if ok else "NOT CONNECTED"
    rows = {
        "Host": f'{db["host"]}:{db["port"]}',
        "Database": db["dbname"],
        "Latency": f'{db["latency_ms"]} ms' if db["latency_ms"] is not None else "-",
        "Server version": db["version"] or "-",
        "Detail": db["message"],
    }
    trs = "".join(
        f"<tr><th>{html.escape(k)}</th><td>{html.escape(str(v))}</td></tr>"
        for k, v in rows.items()
    )
    pod = os.environ.get("HOSTNAME", "unknown")
    return f"""<!doctype html>
<html><head><meta charset="utf-8"><title>customer-app</title>
<style>
 body{{font-family:system-ui,sans-serif;margin:2rem;color:#1f2328}}
 .badge{{display:inline-block;padding:.25rem .75rem;border-radius:1rem;
   color:#fff;background:{color};font-weight:600}}
 table{{border-collapse:collapse;margin-top:1rem}}
 th,td{{border:1px solid #d0d7de;padding:.4rem .8rem;text-align:left}}
 th{{background:#f6f8fa}} code{{background:#f6f8fa;padding:.1rem .3rem;border-radius:4px}}
</style></head><body>
 <h1>customer-app</h1>
 <p>Database status: <span class="badge">{badge}</span></p>
 <table>{trs}</table>
 <p>Served by pod <code>{html.escape(pod)}</code>.</p>
 <p>Echo any request at <code>/echo</code> (or any other path).</p>
</body></html>"""


class Handler(BaseHTTPRequestHandler):
    server_version = "customer-app/1.0"

    def _send(self, code, body, content_type="text/plain; charset=utf-8"):
        data = body.encode("utf-8") if isinstance(body, str) else body
        self.send_response(code)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        if self.command != "HEAD":
            self.wfile.write(data)

    def _echo(self):
        length = int(self.headers.get("Content-Length", 0) or 0)
        body = self.rfile.read(length).decode("utf-8", "replace") if length else ""
        payload = {
            "method": self.command,
            "path": self.path,
            "headers": dict(self.headers.items()),
            "body": body,
        }
        self._send(200, json.dumps(payload, indent=2) + "\n",
                   "application/json; charset=utf-8")

    def _route(self):
        route = self.path.split("?", 1)[0]
        if route == "/healthz":
            self._send(200, "ok\n")
        elif route == "/" and self.command == "GET":
            self._send(200, report_html(), "text/html; charset=utf-8")
        else:
            self._echo()

    # All verbs funnel through the router.
    do_GET = do_POST = do_PUT = do_DELETE = do_PATCH = do_HEAD = _route

    def log_message(self, fmt, *args):  # concise access log to stdout
        print(f"{self.command} {self.path} -> {args[1] if len(args) > 1 else ''}")


def main():
    server = ThreadingHTTPServer(("0.0.0.0", PORT), Handler)
    print(f"customer-app listening on :{PORT}")
    server.serve_forever()


if __name__ == "__main__":
    main()
