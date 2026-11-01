---
name: convert-files
description: Use for any file format conversion: Word/Excel/PowerPoint to PDF, Markdown to Word, PDF to images or text, images to PDF, merging or splitting PDFs, audio/video formats, making scans searchable.
---

# Converting files

| From → to | Command |
|---|---|
| DOCX/XLSX/PPTX/ODT → PDF | `fda-soffice --convert-to pdf --outdir out/ "in.docx"` |
| DOC/XLS/PPT (old) → new | `fda-soffice --convert-to docx|xlsx|pptx --outdir out/ in.doc` |
| Markdown/HTML ↔ DOCX | `pandoc in.md -o out.docx` · `pandoc in.docx -t gfm -o out.md` |
| Markdown/HTML → PDF | `make-pdf` skill |
| PDF → text / images | `pdftotext -layout in.pdf out.txt` · `pdftoppm -png -r 150 in.pdf page` |
| Images → PDF | `img2pdf a.jpg b.png -o out.pdf` |
| Merge / split PDFs | `qpdf --empty --pages a.pdf b.pdf -- out.pdf` · `qpdf in.pdf --pages . 1-3 -- part.pdf` |
| Scan → searchable PDF | `ocrmypdf --skip-text in.pdf out.pdf` |
| Image formats | `magick in.webp out.png` · HEIC `heif-dec in.heic out.jpg` |
| Audio/video | `ffmpeg -i in.mov -c:v libx264 -crf 23 -c:a aac out.mp4` · audio `ffmpeg -i in.m4a out.mp3` |
| CSV ↔ XLSX | pandas (`read_csv` / `to_excel`) |

Check the result: page/sheet count matches, look at a page or two as images, file opens. Keep the
original name with the new extension unless they asked otherwise.
