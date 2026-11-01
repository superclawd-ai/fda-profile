"""Markdown or HTML -> PDF with the default report style (WeasyPrint).

usage: fda-python .claude/skills/make-pdf/md2pdf.py IN.(md|html) OUT.pdf [--title T] [--subtitle S] [--css extra.css]
Relative images/links resolve from the input file's folder.
"""
import argparse
import html
import pathlib
import re

import markdown
from weasyprint import CSS, HTML

here = pathlib.Path(__file__).resolve().parent
ap = argparse.ArgumentParser()
ap.add_argument("src")
ap.add_argument("out")
ap.add_argument("--title")
ap.add_argument("--subtitle")
ap.add_argument("--css", action="append", default=[])
a = ap.parse_args()

src = pathlib.Path(a.src).resolve()
text = src.read_text(encoding="utf-8")
if src.suffix.lower() in (".md", ".markdown", ".txt"):
    body = markdown.markdown(text, extensions=["tables", "fenced_code", "sane_lists", "toc", "attr_list"])
    # Right-align cells that are just numbers/amounts/percentages.
    body = re.sub(r"<td>(\s*[-+]?[$€£R]?\s?[\d.,]+\s?(%|k|M|bn)?\s*)</td>", r'<td class="num">\1</td>', body)
    head = ""
    if a.title:
        head += f"<h1>{html.escape(a.title)}</h1>"
        if a.subtitle:
            head += f'<p class="subtitle">{html.escape(a.subtitle)}</p>'
    doc = f'<!doctype html><html><head><meta charset="utf-8"><title>{html.escape(a.title or src.stem)}</title></head><body>{head}{body}</body></html>'
else:
    doc = text
sheets = [CSS(filename=str(here / "report.css"))] + [CSS(filename=c) for c in a.css]
HTML(string=doc, base_url=str(src.parent)).write_pdf(a.out, stylesheets=sheets)
print(f"wrote {a.out}")
