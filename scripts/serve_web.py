#!/usr/bin/env python3
"""Serve the checked-in Flutter Web bundle locally. Python 3 only."""
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import argparse

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--port', type=int, default=8080)
parser.add_argument('--host', default='127.0.0.1', help='Use a LAN interface only on a trusted network.')
args = parser.parse_args()
root = Path(__file__).resolve().parents[1] / 'web_preview'
if not (root / 'index.html').exists():
    parser.error('web_preview/index.html is missing. Rebuild/copy the Flutter Web output first.')
server = ThreadingHTTPServer((args.host, args.port), partial(SimpleHTTPRequestHandler, directory=str(root)))
print(f'FADDAN demo: http://{args.host}:{args.port}  (Ctrl+C to stop)', flush=True)
try:
    server.serve_forever()
except KeyboardInterrupt:
    print('\nStopped.')
finally:
    server.server_close()
