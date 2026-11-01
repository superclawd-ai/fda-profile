---
name: tools-on-this-machine
description: Use when you need to know which tools exist for documents, images, charts, diagrams, OCR, data or browser work on this machine, or when a tool fails or seems missing. Lists the tools, how to call them, and the fallbacks.
---

# Tools on this machine

Everything below is preinstalled. **You can't install anything** (no package managers, no downloads of tools): if a tool
is missing, use the fallback, keep going, and note what's missing in `update_progress` for the operator.
Never ask the requester to install or configure anything.

Check what works right now: `fda-doctor` (all, ~20 s) or `fda-doctor pdf chart` (just those).

| Need | Call | Notes |
|---|---|---|
| Python with data/doc/image packages | `fda-python` | pandas, duckdb, openpyxl, xlsxwriter, matplotlib, python-docx, python-pptx, pypdf, pdfplumber, weasyprint, Pillow, cairosvg, httpx, trafilatura, selectolax, bs4, rapidfuzz, playwright, dateutil, holidays, icalendar, pint, babel. Never use `python3`/`pip` for this. |
| SVG → PNG | `rsvg-convert` | `resvg` as a second opinion |
| Headless browser (screenshots, HTML → PNG/PDF) | `fda-chrome` | or Playwright from `fda-python` (Chromium is preconfigured) |
| PDF read / split / merge / to images | `pdftotext`, `pdfplumber`, `qpdf`, `pdftoppm` | |
| OCR | `tesseract` (eng, por, spa), `ocrmypdf` | |
| Word/Excel/PowerPoint → PDF, formula recalc | `fda-soffice` | slow first call (~10 s) |
| Markdown ↔ DOCX/HTML | `pandoc` | |
| Diagrams | `dot` (Graphviz), `fda-mmdc` (Mermaid) | |
| Images | `magick` (ImageMagick 7), `pngquant`, `optipng`, `gifsicle`, `cwebp`, `heif-dec` | |
| Video / GIF | `ffmpeg` | |
| QR codes | `qrencode`, `zbarimg` (to check) | |
| Web | WebSearch / WebFetch, `curl`, httpx | the FDA browser tools for JavaScript-heavy or signed-in sites |

Fonts: Inter (default for anything you design), IBM Plex, Noto (incl. CJK and color emoji), Liberation
(stand-ins for Arial/Times/Courier), DejaVu.

Where files go: work in `.files/<YYYY-MM-DD>-<slug>/` (see `deliver-files`); temporary junk in `/tmp`.
