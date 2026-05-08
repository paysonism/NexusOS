import asyncio
import json
import os
import ssl
import struct
import sys
import threading
import time

import numpy as np
from aiohttp import web, WSMsgType

try:
    from pykinect2 import PyKinectV2, PyKinectRuntime
except ImportError:
    print("ERROR: pip install pykinect2")
    sys.exit(1)

HOST = "0.0.0.0"
PORT = 8080

CERT_FILE = "cert.pem"
KEY_FILE = "key.pem"

SKIP = 1
DEPTH_W, DEPTH_H = 512, 424
COLOR_W, COLOR_H = 1920, 1080

ROW_IDX = (np.arange(DEPTH_H) * COLOR_H / DEPTH_H).astype(int)
COL_IDX = (np.arange(DEPTH_W) * COLOR_W / DEPTH_W).astype(int)

_lock = threading.Lock()
_depth_frame = None
_color_frame = None

clients = set()
latest_pose = None
controller_id = None
map_mode_global = False

def build_ssl_context():
    if not (os.path.exists(CERT_FILE) and os.path.exists(KEY_FILE)):
        raise RuntimeError("Missing cert.pem / key.pem")
    ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    ctx.load_cert_chain(CERT_FILE, KEY_FILE)
    return ctx

def kinect_thread():
    global _depth_frame, _color_frame

    kinect = PyKinectRuntime.PyKinectRuntime(
        PyKinectV2.FrameSourceTypes_Depth | PyKinectV2.FrameSourceTypes_Color
    )
    print("Kinect v2 opened.")

    while True:
        got_depth = kinect.has_new_depth_frame()
        got_color = kinect.has_new_color_frame()

        if got_depth:
            d = kinect.get_last_depth_frame()
            d_img = d.reshape(DEPTH_H, DEPTH_W).astype(np.uint16)

            if got_color:
                c = kinect.get_last_color_frame()
                c_img = c.reshape(COLOR_H, COLOR_W, 4)
                c_small = c_img[np.ix_(ROW_IDX, COL_IDX)][:, :, 2::-1].astype(np.uint8)
            else:
                c_small = np.zeros((DEPTH_H, DEPTH_W, 3), np.uint8)

            with _lock:
                _depth_frame = d_img
                _color_frame = c_small

        time.sleep(0.005)

async def index(request):
    return web.FileResponse("./kinect_viewer.html")

async def static_file(request):
    path = request.match_info["path"]
    return web.FileResponse(os.path.join(".", path))

async def broadcast_json(obj):
    if not clients:
        return
    msg = json.dumps(obj)
    dead = []
    for ws in list(clients):
        try:
            await ws.send_str(msg)
        except Exception:
            dead.append(ws)
    for ws in dead:
        clients.discard(ws)

async def frame_broadcaster(app):
    global _depth_frame, _color_frame
    last_sig = None

    while True:
        await asyncio.sleep(0.01)

        with _lock:
            if _depth_frame is None or _color_frame is None:
                continue
            d = _depth_frame.copy()
            c = _color_frame.copy()

        sig = (int(d[0, 0]), int(d[DEPTH_H // 2, DEPTH_W // 2]))
        if sig == last_sig:
            continue
        last_sig = sig

        ds = np.ascontiguousarray(d[::SKIP, ::SKIP], np.uint16)
        cs = np.ascontiguousarray(c[::SKIP, ::SKIP], np.uint8)
        h, w = ds.shape
        frame = struct.pack("<HH", w, h) + ds.tobytes() + cs.tobytes()

        dead = []
        for ws in list(clients):
            try:
                await ws.send_bytes(frame)
            except Exception:
                dead.append(ws)
        for ws in dead:
            clients.discard(ws)

async def ws_handler(request):
    global latest_pose, controller_id, map_mode_global

    ws = web.WebSocketResponse(max_msg_size=2**23)
    await ws.prepare(request)

    client_id = f"{id(ws)}"
    clients.add(ws)

    try:
        await ws.send_str(json.dumps({
            "type": "hello",
            "id": client_id,
            "controllerId": controller_id,
            "mapMode": map_mode_global,
            "pose": latest_pose
        }))

        async for msg in ws:
            if msg.type == WSMsgType.TEXT:
                try:
                    data = json.loads(msg.data)
                except Exception:
                    continue

                t = data.get("type")

                if t == "register":
                    await ws.send_str(json.dumps({
                        "type": "hello",
                        "id": client_id,
                        "controllerId": controller_id,
                        "mapMode": map_mode_global,
                        "pose": latest_pose
                    }))

                elif t == "pose":
                    q = data.get("q")
                    if (
                        isinstance(q, list)
                        and len(q) == 4
                        and all(isinstance(v, (int, float)) for v in q)
                    ):
                        controller_id = client_id
                        map_mode_global = bool(data.get("mapMode", map_mode_global))
                        latest_pose = {
                            "q": [float(q[0]), float(q[1]), float(q[2]), float(q[3])],
                            "mapMode": map_mode_global,
                            "ts": time.time(),
                            "controllerId": controller_id
                        }
                        await broadcast_json({
                            "type": "pose",
                            "q": latest_pose["q"],
                            "mapMode": map_mode_global,
                            "controllerId": controller_id
                        })

                elif t == "mapMode":
                    map_mode_global = bool(data.get("value", False))
                    await broadcast_json({
                        "type": "mapMode",
                        "value": map_mode_global,
                        "controllerId": controller_id
                    })

                elif t == "clearMap":
                    await broadcast_json({
                        "type": "clearMap",
                        "controllerId": controller_id
                    })

            elif msg.type == WSMsgType.ERROR:
                break

    finally:
        clients.discard(ws)
        if controller_id == client_id:
            controller_id = None

    return ws

async def on_startup(app):
    app["frame_task"] = asyncio.create_task(frame_broadcaster(app))

async def on_cleanup(app):
    task = app.get("frame_task")
    if task:
        task.cancel()
        try:
            await task
        except asyncio.CancelledError:
            pass

def main():
    if not (os.path.exists(CERT_FILE) and os.path.exists(KEY_FILE)):
        print("Missing cert.pem and key.pem")
        sys.exit(1)

    threading.Thread(target=kinect_thread, daemon=True).start()

    app = web.Application(client_max_size=2**24)
    app.router.add_get("/", index)
    app.router.add_get("/ws", ws_handler)
    app.router.add_get("/{path:.*}", static_file)
    app.on_startup.append(on_startup)
    app.on_cleanup.append(on_cleanup)

    ssl_context = build_ssl_context()

    print("Open:")
    print("https://localhost:8080")
    print("https://127.0.0.1:8080")
    print("https://192.168.6.143:8080")

    web.run_app(
        app,
        host=HOST,
        port=PORT,
        ssl_context=ssl_context
    )

if __name__ == "__main__":
    main()