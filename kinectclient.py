import base64
import hashlib
import hmac
import json
import os
import secrets
import time
from collections import defaultdict, deque
from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional, Tuple

from flask import Flask, Response, jsonify, request, session

app = Flask(__name__)
app.secret_key = os.environ.get("APP_SECRET_KEY", secrets.token_hex(32))

MAX_HISTORY = 50
NONCE_TTL_SECONDS = 120
SESSION_COOKIE_NAME = "fp_session"

# In production, move this to Redis / DB.
request_history: Dict[str, deque] = defaultdict(lambda: deque(maxlen=MAX_HISTORY))
issued_nonces: Dict[str, Dict[str, Any]] = {}

HTML = r"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Defensive Client Integrity Demo</title>
<style>
body{background:#0d1117;color:#e6edf3;font:14px/1.45 ui-monospace,monospace;margin:0}
.wrap{max-width:1100px;margin:0 auto;padding:20px}
.card{background:#161b22;border:1px solid #30363d;border-radius:12px;padding:14px;margin-bottom:14px}
h1{font-size:22px;margin:0 0 8px} .muted{color:#8b949e}
button{background:#21262d;color:#e6edf3;border:1px solid #30363d;border-radius:8px;padding:10px 12px;cursor:pointer}
pre{white-space:pre-wrap;word-break:break-word}
</style>
</head>
<body>
<div class="wrap">
  <h1>Defensive client integrity demo</h1>
  <div class="muted">Passive browser claims plus server-side consistency checks and signed challenge.</div>

  <div class="card">
    <button id="run">collect</button>
  </div>

  <div class="card">
    <strong>Result</strong>
    <pre id="out">idle</pre>
  </div>
</div>

<script>
async function sha256Hex(s) {
  const buf = new TextEncoder().encode(s);
  const hash = await crypto.subtle.digest("SHA-256", buf);
  return Array.from(new Uint8Array(hash)).map(b => b.toString(16).padStart(2, "0")).join("");
}

function safe(fn, fallback=null) { try { return fn(); } catch { return fallback; } }

async function getUAData() {
  if (!navigator.userAgentData) return null;
  const out = {
    brands: navigator.userAgentData.brands || null,
    mobile: navigator.userAgentData.mobile,
    platform: navigator.userAgentData.platform || null
  };
  try {
    Object.assign(out, await navigator.userAgentData.getHighEntropyValues([
      "architecture","bitness","formFactors","model","platformVersion","uaFullVersion","fullVersionList","wow64"
    ]));
  } catch (e) {
    out.error = String(e && e.message || e);
  }
  return out;
}

async function getCanvasHash() {
  const c = document.createElement("canvas");
  c.width = 320; c.height = 90;
  const ctx = c.getContext("2d", { willReadFrequently: true });
  ctx.fillStyle = "#f60"; ctx.fillRect(10, 10, 100, 50);
  ctx.fillStyle = "#069"; ctx.font = "16px Arial";
  ctx.fillText("defensive-integrity-demo Ω🙂", 12, 40);
  const data = c.toDataURL();
  return await sha256Hex(data);
}

function getWebGL() {
  const canvas = document.createElement("canvas");
  const gl = canvas.getContext("webgl2") || canvas.getContext("webgl") || canvas.getContext("experimental-webgl");
  if (!gl) return null;
  const dbg = gl.getExtension("WEBGL_debug_renderer_info");
  return {
    version: safe(() => gl.getParameter(gl.VERSION)),
    shadingLanguageVersion: safe(() => gl.getParameter(gl.SHADING_LANGUAGE_VERSION)),
    vendor: dbg ? safe(() => gl.getParameter(dbg.UNMASKED_VENDOR_WEBGL)) : null,
    renderer: dbg ? safe(() => gl.getParameter(dbg.UNMASKED_RENDERER_WEBGL)) : null,
    maxTextureSize: safe(() => gl.getParameter(gl.MAX_TEXTURE_SIZE)),
    extensions: safe(() => (gl.getSupportedExtensions() || []).slice().sort(), [])
  };
}

async function getAudioHash() {
  const AC = window.OfflineAudioContext || window.webkitOfflineAudioContext;
  if (!AC) return null;
  try {
    const ctx = new AC(1, 44100, 44100);
    const osc = ctx.createOscillator();
    const comp = ctx.createDynamicsCompressor();
    osc.type = "triangle";
    osc.frequency.value = 10000;
    osc.connect(comp); comp.connect(ctx.destination); osc.start(0);
    const buf = await ctx.startRendering();
    const data = buf.getChannelData(0);
    let s = "";
    for (let i = 4000; i < 4300; i++) s += data[i].toFixed(8) + ",";
    return await sha256Hex(s);
  } catch (e) {
    return "error:" + String(e && e.message || e);
  }
}

function getBasic() {
  return {
    userAgent: navigator.userAgent || null,
    platform: navigator.platform || null,
    vendor: navigator.vendor || null,
    language: navigator.language || null,
    languages: navigator.languages || null,
    timezone: Intl.DateTimeFormat().resolvedOptions().timeZone || null,
    timezoneOffset: new Date().getTimezoneOffset(),
    screen: {
      width: screen.width, height: screen.height,
      availWidth: screen.availWidth, availHeight: screen.availHeight,
      colorDepth: screen.colorDepth, pixelDepth: screen.pixelDepth
    },
    viewport: {
      width: innerWidth, height: innerHeight,
      outerWidth: outerWidth, outerHeight: outerHeight,
      devicePixelRatio: devicePixelRatio || 1
    },
    hardwareConcurrency: navigator.hardwareConcurrency ?? null,
    deviceMemory: navigator.deviceMemory ?? null,
    maxTouchPoints: navigator.maxTouchPoints ?? null,
    webdriver: navigator.webdriver ?? null,
    cookieEnabled: navigator.cookieEnabled ?? null,
    pdfViewerEnabled: navigator.pdfViewerEnabled ?? null,
  };
}

async function getPermissions() {
  if (!navigator.permissions?.query) return null;
  const names = ["geolocation","notifications","camera","microphone","clipboard-read","clipboard-write"];
  const out = {};
  for (const name of names) {
    try { out[name] = (await navigator.permissions.query({ name })).state; } catch {}
  }
  return out;
}

function getFeatureGraph() {
  return {
    webgpu: !!navigator.gpu,
    webgl2: !!document.createElement("canvas").getContext("webgl2"),
    offscreenCanvas: "OffscreenCanvas" in window,
    audioContext: !!(window.AudioContext || window.webkitAudioContext || window.OfflineAudioContext || window.webkitOfflineAudioContext),
    webRTC: !!(window.RTCPeerConnection || window.webkitRTCPeerConnection || window.mozRTCPeerConnection),
    serviceWorker: "serviceWorker" in navigator,
    indexedDB: "indexedDB" in window,
    localStorage: "localStorage" in window,
    sessionStorage: "sessionStorage" in window,
    mediaCapabilities: "mediaCapabilities" in navigator
  };
}

async function collectClientClaims() {
  const [uaData, canvasHash, audioHash, permissions] = await Promise.all([
    getUAData(), getCanvasHash(), getAudioHash(), getPermissions()
  ]);
  return {
    basic: getBasic(),
    uaData,
    canvasHash,
    audioHash,
    webgl: getWebGL(),
    featureGraph: getFeatureGraph(),
    permissions
  };
}

async function run() {
  const out = document.getElementById("out");
  out.textContent = "collecting...";

  const nonceRes = await fetch("/challenge", { method: "POST" });
  const nonceObj = await nonceRes.json();

  const claims = await collectClientClaims();
  claims.challenge = {
    nonce: nonceObj.nonce,
    nonceSig: nonceObj.nonce_sig
  };

  const res = await fetch("/collect", {
    method: "POST",
    headers: {"Content-Type":"application/json"},
    body: JSON.stringify(claims)
  });
  const data = await res.json();
  out.textContent = JSON.stringify(data, null, 2);
}

document.getElementById("run").onclick = run;
</script>
</body>
</html>
"""

def stable_json(obj: Any) -> str:
    return json.dumps(obj, sort_keys=True, separators=(",", ":"), ensure_ascii=False)

def sha256_hex(s: str) -> str:
    return hashlib.sha256(s.encode("utf-8")).hexdigest()

def sign_value(value: str) -> str:
    key = app.secret_key.encode("utf-8")
    mac = hmac.new(key, value.encode("utf-8"), hashlib.sha256).digest()
    return base64.urlsafe_b64encode(mac).decode("ascii").rstrip("=")

def verify_sig(value: str, sig: str) -> bool:
    expected = sign_value(value)
    return hmac.compare_digest(expected, sig)

def get_client_ip() -> str:
    xff = request.headers.get("X-Forwarded-For", "")
    if xff:
        return xff.split(",")[0].strip()
    return request.remote_addr or "unknown"

def now_ts() -> int:
    return int(time.time())

def ensure_session_id() -> str:
    if SESSION_COOKIE_NAME not in session:
        session[SESSION_COOKIE_NAME] = secrets.token_hex(16)
    return session[SESSION_COOKIE_NAME]

@dataclass
class ScoreResult:
    score: int = 0
    flags: List[str] = field(default_factory=list)
    evidence: Dict[str, Any] = field(default_factory=dict)

def parse_accept_language(value: Optional[str]) -> List[str]:
    if not value:
        return []
    langs = []
    for part in value.split(","):
        lang = part.split(";")[0].strip().lower()
        if lang:
            langs.append(lang)
    return langs

def score_client_server_consistency(client: Dict[str, Any], server: Dict[str, Any], history: deque) -> ScoreResult:
    r = ScoreResult()

    basic = client.get("basic") or {}
    ua_data = client.get("uaData") or {}
    webgl = client.get("webgl") or {}
    challenge = client.get("challenge") or {}

    ua_client = str(basic.get("userAgent") or "")
    ua_server = str(server["headers"].get("user_agent") or "")
    platform = str(basic.get("platform") or "").lower()
    max_touch = int(basic.get("maxTouchPoints") or 0)
    langs_client = [str(x).lower() for x in (basic.get("languages") or [])]
    accept_langs = parse_accept_language(server["headers"].get("accept_language"))
    sec_ch_platform = str(server["headers"].get("sec_ch_ua_platform") or "").strip('"').lower()
    ua_ch_platform = str(ua_data.get("platform") or "").lower()

    if challenge.get("nonce") and challenge.get("nonceSig"):
        nonce = challenge["nonce"]
        sig = challenge["nonceSig"]
        rec = issued_nonces.get(nonce)
        if not rec or rec["expires_at"] < now_ts():
            r.score += 35
            r.flags.append("missing_or_expired_nonce")
        elif not verify_sig(nonce, sig):
            r.score += 50
            r.flags.append("bad_nonce_signature")
        elif rec["session_id"] != server["session_id"]:
            r.score += 50
            r.flags.append("nonce_session_mismatch")
    else:
        r.score += 35
        r.flags.append("challenge_missing")

    if ua_client and ua_server and ua_client != ua_server:
        r.score += 25
        r.flags.append("user_agent_mismatch")

    if accept_langs and langs_client:
        a = accept_langs[0].split("-")[0]
        b = langs_client[0].split("-")[0]
        if a != b:
            r.score += 10
            r.flags.append("language_mismatch")

    if sec_ch_platform:
        if sec_ch_platform.startswith("windows") and "win" not in platform:
            r.score += 18
            r.flags.append("sec_ch_platform_vs_platform_mismatch")
        elif sec_ch_platform.startswith("mac") and "mac" not in platform:
            r.score += 18
            r.flags.append("sec_ch_platform_vs_platform_mismatch")
        elif sec_ch_platform.startswith("android") and "android" not in platform:
            r.score += 18
            r.flags.append("sec_ch_platform_vs_platform_mismatch")
        elif sec_ch_platform.startswith("ios") and "iphone" not in platform and "ipad" not in platform:
            r.score += 18
            r.flags.append("sec_ch_platform_vs_platform_mismatch")

    if ua_ch_platform and platform and ua_ch_platform[:3] not in platform:
        r.score += 10
        r.flags.append("ua_ch_platform_mismatch")

    ua_low = ua_client.lower()
    if any(x in ua_low for x in ["iphone", "ipad", "android"]) and max_touch == 0:
        r.score += 15
        r.flags.append("mobile_ua_zero_touch")

    dpr = basic.get("viewport", {}).get("devicePixelRatio")
    if isinstance(dpr, (int, float)) and dpr > 10:
        r.score += 10
        r.flags.append("odd_dpr")

    mem = basic.get("deviceMemory")
    if mem is not None and mem not in [0.25, 0.5, 1, 2, 4, 8, 16, 32, 64]:
        r.score += 8
        r.flags.append("odd_device_memory")

    cores = basic.get("hardwareConcurrency")
    if isinstance(cores, int) and (cores < 1 or cores > 256):
        r.score += 8
        r.flags.append("odd_hardware_concurrency")

    if basic.get("webdriver") is True:
        r.score += 25
        r.flags.append("webdriver_true")

    if client.get("canvasHash") in [None, ""]:
        r.score += 12
        r.flags.append("missing_canvas_hash")

    if client.get("audioHash") in [None, ""]:
        r.score += 8
        r.flags.append("missing_audio_hash")

    if webgl and not webgl.get("renderer"):
        r.score += 8
        r.flags.append("webgl_renderer_missing")

    # Inter-request drift
    if history:
        prev = history[-1]
        prev_client = prev.get("client", {})
        prev_basic = prev_client.get("basic", {})
        drift_fields = []

        for field in ["userAgent", "platform", "language", "timezone"]:
            if prev_basic.get(field) != basic.get(field):
                drift_fields.append(field)

        if prev_client.get("canvasHash") != client.get("canvasHash"):
            drift_fields.append("canvasHash")
        if prev_client.get("audioHash") != client.get("audioHash"):
            drift_fields.append("audioHash")

        prev_webgl = prev_client.get("webgl") or {}
        if prev_webgl.get("renderer") != webgl.get("renderer"):
            drift_fields.append("webgl.renderer")

        if drift_fields:
            r.score += min(25, 5 * len(drift_fields))
            r.flags.append("inter_request_drift")
            r.evidence["drift_fields"] = drift_fields

    r.evidence["server_claims"] = {
        "user_agent": ua_server,
        "accept_language": server["headers"].get("accept_language"),
        "sec_ch_ua": server["headers"].get("sec_ch_ua"),
        "sec_ch_ua_platform": server["headers"].get("sec_ch_ua_platform"),
        "ip": server["ip"],
    }
    return r

def classify_risk(score: int) -> str:
    if score >= 70:
        return "high"
    if score >= 30:
        return "medium"
    return "low"

def build_server_observation() -> Dict[str, Any]:
    return {
        "ts": now_ts(),
        "ip": get_client_ip(),
        "method": request.method,
        "scheme": request.scheme,
        "path": request.path,
        "session_id": ensure_session_id(),
        "headers": {
            "user_agent": request.headers.get("User-Agent"),
            "accept": request.headers.get("Accept"),
            "accept_language": request.headers.get("Accept-Language"),
            "accept_encoding": request.headers.get("Accept-Encoding"),
            "sec_ch_ua": request.headers.get("Sec-CH-UA"),
            "sec_ch_ua_mobile": request.headers.get("Sec-CH-UA-Mobile"),
            "sec_ch_ua_platform": request.headers.get("Sec-CH-UA-Platform"),
            "sec_fetch_site": request.headers.get("Sec-Fetch-Site"),
            "sec_fetch_mode": request.headers.get("Sec-Fetch-Mode"),
            "sec_fetch_dest": request.headers.get("Sec-Fetch-Dest"),
            "upgrade_insecure_requests": request.headers.get("Upgrade-Insecure-Requests"),
        }
    }

def build_verifiable_claim_hash(client: Dict[str, Any], server: Dict[str, Any]) -> str:
    subset = {
        "client": {
            "basic": client.get("basic"),
            "uaData": client.get("uaData"),
            "canvasHash": client.get("canvasHash"),
            "audioHash": client.get("audioHash"),
            "webgl": client.get("webgl"),
            "featureGraph": client.get("featureGraph"),
            "permissions": client.get("permissions"),
        },
        "server": {
            "user_agent": server["headers"].get("user_agent"),
            "accept_language": server["headers"].get("accept_language"),
            "sec_ch_ua": server["headers"].get("sec_ch_ua"),
            "sec_ch_ua_platform": server["headers"].get("sec_ch_ua_platform"),
            "ip": server["ip"],
        }
    }
    return sha256_hex(stable_json(subset))

# Hooks only. Fill these with real verification in production.
def verify_apple_app_attest(attestation_object_b64: str, key_id: str, challenge: str) -> Tuple[bool, str]:
    # Real implementation needs Apple chain / CBOR / nonce verification server-side.
    # Use Apple's documented flow, not this placeholder.
    return False, "not_implemented"

def verify_play_integrity(integrity_token: str) -> Tuple[bool, str]:
    # Real implementation needs Google server-side verification / decode of returned verdict.
    return False, "not_implemented"

@app.after_request
def add_headers(resp):
    resp.headers["Cache-Control"] = "no-store, no-cache, must-revalidate, max-age=0"
    resp.headers["Pragma"] = "no-cache"
    resp.headers["Expires"] = "0"
    return resp

@app.route("/", methods=["GET"])
def index():
    ensure_session_id()
    return Response(HTML, mimetype="text/html")

@app.route("/challenge", methods=["POST"])
def challenge():
    session_id = ensure_session_id()
    nonce = secrets.token_urlsafe(24)
    nonce_sig = sign_value(nonce)
    issued_nonces[nonce] = {
        "session_id": session_id,
        "issued_at": now_ts(),
        "expires_at": now_ts() + NONCE_TTL_SECONDS,
    }
    return jsonify({
        "nonce": nonce,
        "nonce_sig": nonce_sig,
        "expires_in": NONCE_TTL_SECONDS,
    })

@app.route("/collect", methods=["POST"])
def collect():
    client = request.get_json(silent=True) or {}
    server = build_server_observation()
    sid = server["session_id"]
    history = request_history[sid]

    score_result = score_client_server_consistency(client, server, history)
    risk = classify_risk(score_result.score)
    claim_hash = build_verifiable_claim_hash(client, server)

    # Optional attestation inputs from caller
    attest = client.get("attestation") or {}
    attestation_results = {}

    if attest.get("apple_app_attest_object") and attest.get("apple_key_id") and attest.get("challenge"):
        ok, detail = verify_apple_app_attest(
            attest["apple_app_attest_object"],
            attest["apple_key_id"],
            attest["challenge"],
        )
        attestation_results["apple_app_attest"] = {"ok": ok, "detail": detail}

    if attest.get("play_integrity_token"):
        ok, detail = verify_play_integrity(attest["play_integrity_token"])
        attestation_results["play_integrity"] = {"ok": ok, "detail": detail}

    event = {
        "ts": server["ts"],
        "client": client,
        "server": server,
        "risk_score": score_result.score,
        "risk_level": risk,
        "flags": score_result.flags,
        "evidence": score_result.evidence,
        "claim_hash": claim_hash,
        "attestation": attestation_results,
    }
    history.append(event)

    return jsonify(event)

@app.route("/history", methods=["GET"])
def history():
    sid = ensure_session_id()
    return jsonify(list(request_history[sid]))

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80, debug=False)