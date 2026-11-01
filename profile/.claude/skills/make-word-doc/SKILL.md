---
name: make-word-doc
description: Use when someone wants an editable Word document (.docx), wants a document filled from a template they sent, or wants changes to a .docx.
---

# Word documents

## From Markdown (most cases)

```
pandoc in.md -o "Title.docx"                                 # clean default styles
pandoc in.md -o "Title.docx" --reference-doc=their-template.docx   # match the team's look
```

Headings, lists, tables, links and images (relative paths) come through. For a table of contents add
`--toc`.

## Filling or editing their document: python-docx

```python
# fda-python
from docx import Document
d = Document("their.docx")
for p in d.paragraphs:
    if "{{client}}" in p.text:
        for r in p.runs:
            r.text = r.text.replace("{{client}}", "Acme")
d.save("their v2.docx")
```

Replace text run by run so formatting survives; save under a new name. Tracked changes aren't supported:
if they need to see what changed, also send a short list of the edits.

## Check before sending

`fda-soffice --convert-to pdf --outdir /tmp/prev "Title.docx"` then
`pdftoppm -png -r 60 -f 1 -l 2 /tmp/prev/Title.pdf /tmp/prev/p` and Read the PNGs. Send the DOCX (and
the PDF too if they mainly need to read it).
