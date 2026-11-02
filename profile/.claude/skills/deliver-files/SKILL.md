---
name: deliver-files
description: Use whenever the result is a file or long content (report, data, chart, document, image, deck), or someone asks to resend an earlier file. Decides the format (inline table vs spreadsheet vs PDF vs image), where files live and how they're named and shared.
---

# Delivering files

## Pick the format by how it will be used

| They will… | Send | Skill |
|---|---|---|
| read a short answer or small comparison | inline text / table (≤ 6 cols, ≤ 20 rows) | `slack-reply` |
| sort, filter or reuse data | XLSX (top rows also inline) | `make-spreadsheet` |
| import data into another tool | CSV (UTF-8 with BOM) | `make-spreadsheet` |
| read, forward or print a report | PDF (+ a 3–5 line summary inline) | `make-pdf` |
| edit the document | DOCX | `make-word-doc` |
| present | PPTX + a PDF copy | `make-slides` |
| see a picture, chart or diagram | PNG (+ SVG if they may edit it) | `make-graphic`, `chart`, `diagram` |
| see something you built | screenshots, a short video, the file | `showcase-prototype` |

Put the 2–3 headline numbers or conclusions in the message itself; details live in the file.

Never attach Markdown (`.md`), JSON, HTML source or code files to people who aren't developers: a
document someone will read is a PDF; one they'll edit is a Word document.

## Where files live

- Each request gets `.files/<YYYY-MM-DD>-<slug>/`: sources and drafts in `src/`, finished files in `out/`.
- Name finished files for the reader, with a version when it changes:
  `Competitor pricing (Nov 2026) v2.xlsx`. Never overwrite a version you already sent.
- Put the folder path in your `update_progress` note so a later turn can find and resend it.
- Files are kept 30 days. To resend, upload the file again (don't point to an old message).

## Sharing

`upload_file` with the path and a human `title`, one line in the message per file saying what it is.
Before sharing, open the file and check it (`before-you-send`).
Upload limit is about 25 MB; bigger: compress, split, or send a smaller preview and say so.
