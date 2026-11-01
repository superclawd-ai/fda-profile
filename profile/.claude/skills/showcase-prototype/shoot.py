"""Screenshot (desktop + mobile) and optionally record a short video/GIF of a page.

usage: fda-python shoot.py (FILE.html | DIR | http(s)://URL) --out DIR [--name NAME] [--full-page]
                 [--video] [--click CSS ...] [--highlight CSS ...] [--wait MS]
Local files are served over http on a free port (so relative assets and fetch() work).
"""
import argparse
import functools
import http.server
import pathlib
import shutil
import socketserver
import subprocess
import tempfile
import threading

from playwright.sync_api import sync_playwright

ap = argparse.ArgumentParser()
ap.add_argument("target")
ap.add_argument("--out", required=True)
ap.add_argument("--name", default="Preview")
ap.add_argument("--full-page", action="store_true")
ap.add_argument("--video", action="store_true")
ap.add_argument("--click", action="append", default=[])
ap.add_argument("--highlight", action="append", default=[], help="draw numbered boxes around these elements")
ap.add_argument("--wait", type=int, default=800)
a = ap.parse_args()

out = pathlib.Path(a.out)
out.mkdir(parents=True, exist_ok=True)
server = None
url = a.target
if not url.startswith(("http://", "https://")):
    p = pathlib.Path(a.target).resolve()
    root, page = (p, "") if p.is_dir() else (p.parent, p.name)

    class Quiet(http.server.SimpleHTTPRequestHandler):
        def log_message(self, *args):
            pass

    server = socketserver.TCPServer(("127.0.0.1", 0), functools.partial(Quiet, directory=str(root)))
    threading.Thread(target=server.serve_forever, daemon=True).start()
    url = f"http://127.0.0.1:{server.server_address[1]}/{page}"

written = []
with sync_playwright() as pw:
    b = pw.chromium.launch(args=["--no-sandbox"])
    for label, opts in [("desktop", {"viewport": {"width": 1280, "height": 800}}),
                        ("mobile", {"viewport": {"width": 390, "height": 844}, "device_scale_factor": 2,
                                    "is_mobile": True, "has_touch": True})]:
        ctx = b.new_context(**opts)
        pg = ctx.new_page()
        pg.goto(url, wait_until="networkidle")
        pg.wait_for_timeout(a.wait)
        f = out / f"{a.name} - {label}.png"
        pg.screenshot(path=str(f), full_page=a.full_page)
        written.append(f)
        if a.highlight and label == "desktop":
            missing = pg.evaluate("""(sels) => sels.map((sel, i) => {
                const el = document.querySelector(sel); if (!el) return sel;
                const r = el.getBoundingClientRect(), pad = 8;
                const box = document.createElement('div');
                box.style.cssText = `position:absolute;z-index:2147483647;pointer-events:none;border:4px solid #E5383B;border-radius:10px;
                  left:${r.left + scrollX - pad}px;top:${r.top + scrollY - pad}px;width:${r.width + 2*pad}px;height:${r.height + 2*pad}px`;
                const n = document.createElement('div');
                n.textContent = i + 1;
                n.style.cssText = `position:absolute;left:-18px;top:-18px;width:32px;height:32px;border-radius:16px;background:#E5383B;
                  color:#fff;font:700 18px/32px Inter,sans-serif;text-align:center`;
                box.appendChild(n); document.body.appendChild(box); return null;
            }).filter(Boolean)""", a.highlight)
            if missing:
                print(f"not found on the page: {', '.join(missing)}")
            f = out / f"{a.name} - annotated.png"
            pg.screenshot(path=str(f), full_page=a.full_page)
            written.append(f)
        ctx.close()
    if a.video:
        vd = pathlib.Path(tempfile.mkdtemp())
        ctx = b.new_context(viewport={"width": 1280, "height": 800}, record_video_dir=str(vd),
                            record_video_size={"width": 1280, "height": 800})
        pg = ctx.new_page()
        pg.goto(url, wait_until="networkidle")
        pg.wait_for_timeout(1200)
        for sel in a.click:
            pg.click(sel)
            pg.wait_for_timeout(1200)
        height = pg.evaluate("document.body.scrollHeight")
        y = 0
        while y < height - 800:
            y += 300
            pg.mouse.wheel(0, 300)
            pg.wait_for_timeout(350)
        pg.wait_for_timeout(800)
        pg.evaluate("window.scrollTo({top: 0, behavior: 'smooth'})")
        pg.wait_for_timeout(1000)
        ctx.close()
        webm = next(vd.glob("*.webm"))
        mp4 = out / f"{a.name}.mp4"
        gif = out / f"{a.name}.gif"
        subprocess.run(["ffmpeg", "-loglevel", "error", "-y", "-i", str(webm), "-vf", "scale=960:-2",
                        "-c:v", "libx264", "-pix_fmt", "yuv420p", "-movflags", "+faststart", "-crf", "28",
                        "-an", str(mp4)], check=True)
        subprocess.run(["ffmpeg", "-loglevel", "error", "-y", "-i", str(webm), "-vf",
                        "fps=8,scale=640:-1:flags=lanczos,split[a][b];[a]palettegen=max_colors=96[p];[b][p]paletteuse",
                        str(gif)], check=True)
        written += [mp4, gif]
        shutil.rmtree(vd, ignore_errors=True)
    b.close()
if server:
    server.shutdown()
for f in written:
    print(f"wrote {f} ({f.stat().st_size // 1024} KB)")
