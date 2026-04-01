#!/usr/bin/env python3
"""
DPP Viewer — local HTTP server + CORS proxy.

Serves basyx-dpp-viewer static files and proxies /proxy/* to
aasenv.iotdemozone.com, injecting Access-Control-Allow-Origin so the
browser does not block BaSyx API responses.

Usage:
    python3 dpp_proxy.py [port]    # default 8099

Then open: http://localhost:8099/
"""
import http.server, urllib.request, ssl, os, sys

ROOT  = os.path.dirname(os.path.abspath(__file__))
BASYX = 'https://aasenv.iotdemozone.com'
AUTH  = 'Basic YWRtaW46YzQ5azRtMjU='
PORT  = int(sys.argv[1]) if len(sys.argv) > 1 else 8099

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *a, **kw):
        super().__init__(*a, directory=ROOT, **kw)

    def do_GET(self):
        if self.path.startswith('/proxy/'):
            self._proxy()
        else:
            super().do_GET()

    def do_OPTIONS(self):
        self.send_response(204)
        self._cors()
        self.end_headers()

    def _cors(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Authorization, Content-Type')

    def _proxy(self):
        target = BASYX + self.path[len('/proxy'):]
        try:
            req = urllib.request.Request(target)
            req.add_header('Authorization', AUTH)
            with urllib.request.urlopen(req, context=ssl.create_default_context(), timeout=15) as r:
                body = r.read()
                self.send_response(200)
                self.send_header('Content-Type', r.headers.get('Content-Type', 'application/json'))
                self._cors()
                self.send_header('Content-Length', str(len(body)))
                self.end_headers()
                self.wfile.write(body)
        except urllib.error.HTTPError as e:
            body = e.read()
            self.send_response(e.code)
            self._cors()
            self.send_header('Content-Length', str(len(body)))
            self.end_headers()
            self.wfile.write(body)
        except Exception as e:
            msg = str(e).encode()
            self.send_response(502)
            self._cors()
            self.send_header('Content-Length', str(len(msg)))
            self.end_headers()
            self.wfile.write(msg)

    def log_message(self, fmt, *args):
        print(f"  {self.address_string()}  {fmt % args}")

if __name__ == '__main__':
    os.chdir(ROOT)
    httpd = http.server.HTTPServer(('', PORT), Handler)
    print(f"\nDPP Viewer  →  http://localhost:{PORT}/")
    print(f"Proxying    →  {BASYX}")
    print(f"Press Ctrl+C to stop\n")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nStopped.")
