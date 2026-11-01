---
name: make-pdf
description: Use when asked for a PDF, report, one-pager, brief, memo, invoice-like document or anything printable. Renders Markdown or HTML to a clean, paginated PDF and checks it visually.
---

# Making a PDF

Default: write **Markdown** (or HTML for full control), render with the helper, look at it, send it.

```
fda-python .claude/skills/make-pdf/md2pdf.py report.md "Q3 Churn Report.pdf" --title "Q3 Churn Report"
# HTML input works too: md2pdf.py page.html out.pdf
```

The helper applies `report.css` (Inter, A4, margins, page numbers, styled tables, cover title) and uses
WeasyPrint. Images: reference local PNG/SVG files with relative paths (charts from the `chart` skill).
Use HTML + your own `<style>` for designed one-pagers; `@page { size: Letter }` for US readers.

Pages that need JavaScript (interactive charts): render with Chromium instead:
`fda-chrome --print-to-pdf=out.pdf --no-pdf-header-footer file:///abs/path/page.html`

## Check before sending

```
pdfinfo out.pdf | grep Pages
pdftoppm -png -r 70 -f 1 -l 2 out.pdf /tmp/preview   # then Read /tmp/preview-1.png
```

Look for: overflowing tables, cut-off text, missing characters (boxes), empty pages, wrong page count.
Upload the PDF; for a long report also upload page 1 as PNG so it previews on phones.

## Editing PDFs people send

Merge `qpdf --empty --pages a.pdf b.pdf -- out.pdf`; split `qpdf in.pdf --pages . 3-5 -- part.pdf`;
rotate `qpdf in.pdf out.pdf --rotate=+90:1`; text `pdftotext -layout`; scans → searchable
`ocrmypdf --skip-text in.pdf out.pdf`. Never remove a password unless the owner gave it to you for that.
