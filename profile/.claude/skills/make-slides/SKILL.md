---
name: make-slides
description: Use when asked for a slide deck or presentation (pitch, update, training, report readout), or to edit a .pptx someone sent.
---

# Slide decks

Write an outline as JSON, build it with the helper, look at it, send the PPTX plus a PDF copy.

```
fda-python .claude/skills/make-slides/slides.py outline.json "Q3 Review.pptx" --pdf
```

`outline.json`:

```json
{"title": "Q3 Review", "subtitle": "Sales team · November 2026", "accent": "2457D6",
 "slides": [
   {"type": "section", "title": "Where we are"},
   {"title": "Revenue grew 18%", "bullets": ["New logos: 42", "Churn down to 2.1%", "APAC doubled"]},
   {"title": "Pipeline by stage", "image": "chart.png", "notes": "Speaker notes here"},
   {"title": "By region", "table": [["Region", "Q2", "Q3"], ["EMEA", "1.2M", "1.4M"], ["APAC", "0.4M", "0.8M"]]},
   {"title": "Two options", "columns": [["Option A", "Fast", "Cheap"], ["Option B", "Robust", "Costly"]]}
 ]}
```

Slide kinds: title (automatic first slide), `section`, bullets, `image` (+ optional `caption`), `table`
(first row = header), `columns` (2 lists, first item = heading). Every slide may have `notes`.

## Rules for good decks

- One idea per slide; the title states the takeaway ("Revenue grew 18%", not "Revenue").
- ≤ 5 bullets, ≤ 12 words each. Numbers on slides come from your verified data.
- Charts as PNG from the `chart` skill (with an empty `--title ""`: the slide title already says it);
  diagrams from `diagram`.
- Tables on slides: ≤ 6 rows and ≤ 5 columns; more goes in an attached spreadsheet.
- Their template: if they sent a .pptx, pass `--template their.pptx` (uses its layouts and theme).

## Check before sending

`--pdf` also writes a PDF (via LibreOffice). Render pages to PNG
(`pdftoppm -png -r 50 deck.pdf /tmp/s`) and Read a few: text overflowing boxes, tiny tables, images
covering titles. Fix the outline and rebuild.
