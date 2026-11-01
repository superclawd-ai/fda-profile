"""Collect logo candidates for a company (no API keys needed) and render them to PNG.

usage: fda-python logo.py --name "Company" [--domain example.com] [--github org] --out DIR
"""
import argparse
import json
import pathlib
import re
import subprocess
import urllib.parse

import httpx
from selectolax.lexbor import LexborHTMLParser as HTMLParser

UA = "SuperClawd-FDA/1.0 (logo lookup; https://superclawd.com)"
ap = argparse.ArgumentParser()
ap.add_argument("--name", required=True)
ap.add_argument("--domain")
ap.add_argument("--github")
ap.add_argument("--out", required=True)
a = ap.parse_args()
out = pathlib.Path(a.out)
out.mkdir(parents=True, exist_ok=True)
c = httpx.Client(headers={"User-Agent": UA}, follow_redirects=True, timeout=20)
found = []


def slug(s):
    return re.sub(r"[^a-z0-9]+", "-", s.lower()).strip("-")[:60]


def save(label, data, ext, source):
    if not data or len(data) < 200:
        return
    f = out / f"{len(found) + 1:02d}-{slug(label)}.{ext}"
    f.write_bytes(data)
    png = f
    if ext == "svg":
        png = f.with_suffix(".png")
        r = subprocess.run(["rsvg-convert", "-w", "1024", "-b", "none", str(f), "-o", str(png)],
                           capture_output=True)
        if r.returncode != 0:
            png = None
    size = ""
    if png and png.exists():
        r = subprocess.run(["magick", "identify", "-format", "%wx%h", f"{png}[0]"], capture_output=True, text=True)
        size = r.stdout.strip()
    found.append({"file": str(f), "png": str(png) if png else "", "size": size, "source": source})


def get(url):
    try:
        r = c.get(url)
        if r.status_code == 200:
            return r
    except httpx.HTTPError:
        pass
    return None


def ext_of(url, ctype):
    if "svg" in (ctype or "") or url.lower().split("?")[0].endswith(".svg"):
        return "svg"
    for e in ("png", "webp", "jpg", "jpeg", "gif", "ico"):
        if e in (ctype or "") or url.lower().split("?")[0].endswith("." + e):
            return "jpg" if e == "jpeg" else e
    return "png"


def host(u):
    return urllib.parse.urlparse(u if "://" in u else "https://" + u).hostname or ""


# 1. Wikidata (P154 logo image), matched by official website (P856) when a domain is given.
r = get("https://www.wikidata.org/w/api.php?" + urllib.parse.urlencode(
    {"action": "wbsearchentities", "search": a.name, "language": "en", "type": "item", "limit": 7, "format": "json"}))
ids = [x["id"] for x in r.json().get("search", [])] if r else []
if ids:
    r = get("https://www.wikidata.org/w/api.php?" + urllib.parse.urlencode(
        {"action": "wbgetentities", "ids": "|".join(ids), "props": "claims|labels", "languages": "en", "format": "json"}))
    ents = r.json().get("entities", {}) if r else {}
    ranked = []
    for i, q in enumerate(ids):
        cl = ents.get(q, {}).get("claims", {})
        logos = [s["mainsnak"]["datavalue"]["value"] for s in cl.get("P154", []) if "datavalue" in s["mainsnak"]]
        sites = [s["mainsnak"]["datavalue"]["value"] for s in cl.get("P856", []) if "datavalue" in s["mainsnak"]]
        match = bool(a.domain) and any(host(s).removeprefix("www.").endswith(a.domain.removeprefix("www.")) for s in sites)
        if logos:
            ranked.append((not match, i, q, logos[-1]))
    for _, _, q, fname in sorted(ranked)[:2]:
        fr = get("https://commons.wikimedia.org/wiki/Special:FilePath/" + urllib.parse.quote(fname.replace(" ", "_")))
        if fr:
            save(f"wikidata-{q}", fr.content, ext_of(fname, fr.headers.get("content-type")),
                 f"Wikimedia Commons ({fname}, Wikidata {q})")

# 2. The company's website.
if a.domain:
    base = "https://" + a.domain.removeprefix("https://").strip("/")
    r = get(base)
    if r:
        doc = HTMLParser(r.text)
        urls = []
        for n in doc.css("link[rel]"):
            rel = (n.attributes.get("rel") or "").lower()
            if "icon" in rel or "apple-touch" in rel or "mask-icon" in rel:
                urls.append(("site-icon", n.attributes.get("href")))
        for n in doc.css("meta[property='og:image'], meta[name='og:image']"):
            urls.append(("site-og-image", n.attributes.get("content")))
        for n in doc.css("img")[:200]:
            blob = " ".join(str(n.attributes.get(k) or "") for k in ("src", "alt", "class", "id")).lower()
            if ("logo" in blob or a.name.lower() in (n.attributes.get("alt") or "").lower()) and \
                    sum(1 for x in urls if x[0] == "site-img") < 4:
                urls.append(("site-img", n.attributes.get("src") or n.attributes.get("data-src")))
        for i, n in enumerate(doc.css("header svg, a[href='/'] svg, [class*=logo] svg, [id*=logo] svg")[:3]):
            svg = n.html
            if "xmlns" not in svg:
                svg = svg.replace("<svg", '<svg xmlns="http://www.w3.org/2000/svg"', 1)
            save(f"site-inline-svg-{i + 1}", svg.encode(), "svg", f"inline SVG on {base}")
        seen = set()
        for label, u in urls:
            if not u or u.startswith("data:"):
                continue
            u = urllib.parse.urljoin(str(r.url), u)
            if u in seen:
                continue
            seen.add(u)
            fr = get(u)
            if fr:
                save(label, fr.content, ext_of(u, fr.headers.get("content-type")), u)

# 3. Simple Icons and GitHub.
fr = get(f"https://cdn.simpleicons.org/{re.sub(r'[^a-z0-9]', '', a.name.lower())}")
if fr and "svg" in fr.headers.get("content-type", ""):
    save("simpleicons", fr.content, "svg", "Simple Icons (single-color glyph)")
gh = a.github or (a.domain or "").split(".")[0] or slug(a.name)
fr = get(f"https://github.com/{gh}.png?size=460")
if fr and "image" in fr.headers.get("content-type", ""):
    save(f"github-{gh}", fr.content, "png", f"GitHub avatar of {gh} (check it's really them)")

for f in found:
    f["kind"] = "vector" if f["file"].endswith(".svg") else "raster"
found.sort(key=lambda f: f["kind"] != "vector")  # vector first (stable: keeps source order)
print(f"{'#':<3} {'kind':<7} {'size':<11} {'png to look at':<60} source")
for i, f in enumerate(found, 1):
    size = f["size"] or "?"
    if f["kind"] == "raster":
        size += " real"  # never enlarge these
    print(f"{i:<3} {f['kind']:<7} {size:<16} {f['png'] or f['file']:<55} {f['source']}")
(out / "candidates.json").write_text(json.dumps(found, indent=2))
if not found:
    print("no candidates found")
