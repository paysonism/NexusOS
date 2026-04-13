"""
mitmproxy intercept script
Only logs URLs and API routes found embedded inside response/request bodies.
Skips filenames (paths ending in file extensions).
Usage: mitmdump -s intercept.py
Output: intercept_log.txt
"""

import re
import json
from datetime import datetime
from mitmproxy import http

LOG_FILE = "intercept_log.txt"

# Full URLs embedded in text
URL_RE = re.compile(r'https?://[^\s\'"<>{}\[\]\\,)(]+', re.IGNORECASE)

# Routes assigned to known keys in JS/JSON (path, url, endpoint, href, action, etc.)
ROUTE_RE = re.compile(
    r'(?:path|url|route|endpoint|href|action|redirect|location|navigate|to|from)\s*[:=]\s*[\'"`](/[^\s\'"<>`\n]+)',
    re.IGNORECASE
)

# fetch/axios/XHR style calls
FETCH_RE = re.compile(
    r'(?:fetch|get|post|put|patch|delete|request|axios|xhr\.open)\s*\(\s*[\'"`]([^\'"`\n]+)[\'"`]',
    re.IGNORECASE
)

# File extensions to ignore as routes (filenames, not routes)
FILE_EXT_RE = re.compile(
    r'\.(js|jsx|ts|tsx|css|scss|less|html|htm|png|jpg|jpeg|gif|svg|ico|woff|woff2|ttf|eot|map|json|txt|pdf|zip|gz|br|webp|avif|mp4|mp3|wav|ogg)(\?[^\s\'"]*)?$',
    re.IGNORECASE
)

_log = None

def get_log():
    global _log
    if _log is None:
        _log = open(LOG_FILE, "a", encoding="utf-8", buffering=1)
    return _log

def log(text: str):
    ts = datetime.now().strftime("%H:%M:%S.%f")[:-3]
    line = f"[{ts}] {text}"
    print(line)
    get_log().write(line + "\n")

def is_filename(path: str) -> bool:
    return bool(FILE_EXT_RE.search(path.split("?")[0]))

def extract_embedded(text: str) -> list[tuple[str, str]]:
    found = []
    seen = set()

    def add(kind, val):
        val = val.rstrip(".,;)'\"")
        if val not in seen and len(val) > 1:
            seen.add(val)
            found.append((kind, val))

    for m in URL_RE.finditer(text):
        url = m.group(0).rstrip(".,;)'\"")
        if not is_filename(url):
            add("LINK", url)

    for m in ROUTE_RE.finditer(text):
        path = m.group(1)
        if not is_filename(path):
            add("ROUTE", path)

    for m in FETCH_RE.finditer(text):
        val = m.group(1)
        if val.startswith("http"):
            if not is_filename(val):
                add("LINK", val)
        elif val.startswith("/"):
            if not is_filename(val):
                add("ROUTE", val)

    return found

def scan_and_log(label: str, body: bytes, ct: str):
    if not body:
        return []
    # only scan text-based content
    ct = ct.lower()
    if not any(x in ct for x in ("json", "javascript", "html", "xml", "text", "form")):
        return []
    try:
        text = body.decode("utf-8", errors="replace")
    except Exception:
        return []
    return extract_embedded(text)


def request(flow: http.HTTPFlow):
    req = flow.request
    ct = req.headers.get("content-type", "")
    hits = scan_and_log("REQ", req.content, ct)
    if hits:
        log(f"REQ  {req.method}  {req.pretty_url}")
        for kind, val in hits:
            log(f"  {kind}: {val}")


def response(flow: http.HTTPFlow):
    req = flow.request
    resp = flow.response
    ct = resp.headers.get("content-type", "")
    hits = scan_and_log("RES", resp.content, ct)
    if hits:
        log(f"RES  {resp.status_code}  {req.method}  {req.pretty_url}")
        for kind, val in hits:
            log(f"  {kind}: {val}")
