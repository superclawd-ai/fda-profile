"""Find freely licensed photos on Wikimedia Commons (no key) and download them with attribution.

usage: fda-python find_photo.py "golden retriever beach" --out DIR [--n 4] [--width 1080] [--commercial]
--commercial keeps only licenses that allow commercial use (CC0, public domain, CC BY, CC BY-SA).
Writes the images plus credits.txt (the attribution line to post with each one).
"""
import argparse
import pathlib
import re

import httpx

ap = argparse.ArgumentParser()
ap.add_argument("query")
ap.add_argument("--out", required=True)
ap.add_argument("--n", type=int, default=4)
ap.add_argument("--width", type=int, default=1080)
ap.add_argument("--commercial", action="store_true")
a = ap.parse_args()
out = pathlib.Path(a.out)
out.mkdir(parents=True, exist_ok=True)
c = httpx.Client(headers={"User-Agent": "SuperClawd-FDA/1.0 (https://superclawd.com; support@superclawd.com)"}, timeout=30, follow_redirects=True)
r = c.get("https://commons.wikimedia.org/w/api.php", params={
    "action": "query", "generator": "search", "gsrnamespace": 6, "gsrsearch": f"{a.query} filetype:bitmap",
    "gsrlimit": 30, "prop": "imageinfo", "iiprop": "url|extmetadata|size", "iiurlwidth": a.width, "format": "json"})
pages = sorted(r.json().get("query", {}).get("pages", {}).values(), key=lambda p: p.get("index", 0))


def clean(s):
    return re.sub(r"\s+", " ", re.sub(r"<[^>]+>", "", s or "")).strip()


ok = re.compile(r"^(CC0|Public domain|PD|CC BY(-SA)? [0-9.]+)", re.I)
credits, n = [], 0
for p in pages:
    ii = (p.get("imageinfo") or [{}])[0]
    m = ii.get("extmetadata", {})
    lic = clean(m.get("LicenseShortName", {}).get("value"))
    if not lic or (a.commercial and not ok.match(lic)) or "NC" in lic or "ND" in lic:
        continue
    if ii.get("width", 0) < 800:
        continue
    url = ii.get("thumburl") or ii.get("url")
    img = c.get(url)
    if img.status_code != 200:
        continue
    n += 1
    name = re.sub(r"[^A-Za-z0-9]+", "-", p["title"].removeprefix("File:").rsplit(".", 1)[0]).strip("-")[:60]
    f = out / f"{n:02d}-{name}.jpg"
    f.write_bytes(img.content)
    artist = clean(m.get("Artist", {}).get("value")) or "unknown author"
    page = ii.get("descriptionurl", "")
    line = f'"{p["title"].removeprefix("File:")}" by {artist}, {lic}, via Wikimedia Commons ({page})'
    credits.append(f"{f.name}: {line}")
    print(f"{f}  |  {lic}  |  {artist}")
    if n >= a.n:
        break
(out / "credits.txt").write_text("\n".join(credits) + "\n")
print(f"{n} photos; attribution lines in {out / 'credits.txt'}" if n else "no suitable photos found")
