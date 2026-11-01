---
name: make-spreadsheet
description: Use when the deliverable is an Excel file or CSV (a compiled list, comparison, export, tracker, budget, report data), or when editing a spreadsheet someone sent.
---

# Making spreadsheets

## New file: XlsxWriter via pandas

```python
# fda-python
import pandas as pd
with pd.ExcelWriter(out, engine="xlsxwriter") as xw:
    df.to_excel(xw, sheet_name="Data", index=False)
    wb, ws = xw.book, xw.sheets["Data"]
    rows, cols = df.shape
    ws.add_table(0, 0, rows, cols - 1, {"columns": [{"header": c} for c in df.columns],
                                         "style": "Table Style Medium 2"})
    ws.freeze_panes(1, 0)
    for i, c in enumerate(df.columns):            # fit widths (cap at 60)
        ws.set_column(i, i, min(60, max(len(str(c)), df[c].astype(str).str.len().max()) + 2))
    money = wb.add_format({"num_format": "#,##0.00"})   # apply to amount columns: ws.set_column(i, i, w, money)
```

- One sheet per topic; add a **Notes** sheet: what it is, sources (with links and dates), assumptions,
  date generated.
- Real formulas for totals so people can extend them, **with the value you computed in pandas** as the
  stored result, so previews (Slack, phones, Google) show the right number before Excel recalculates:
  `ws.write_formula(rows + 1, j, "=SUM(C2:C99)", money, value=float(df["MRR"].sum()))`.
- Dates as real dates with a date format; percentages as numbers with `0.0%`.
- Don't merge cells in data areas, don't color-code meaning without a legend.

## Editing a file someone sent: openpyxl

`openpyxl.load_workbook(path)` keeps their formatting; write to a new file name (`… v2.xlsx`), never over
the original. Avoid touching sheets you weren't asked to change.

## CSV

Only when they'll import it somewhere: `df.to_csv(out, index=False, encoding="utf-8-sig")` (the BOM makes
Excel show accents correctly).

## Check before sending

XlsxWriter and openpyxl don't calculate formulas. Recalculate with LibreOffice (it recomputes every
formula on load) and compare with your own numbers:

```
fda-soffice --convert-to xlsx --outdir /tmp/recalc "file.xlsx"
fda-python -c "import openpyxl; wb=openpyxl.load_workbook('/tmp/recalc/file.xlsx', data_only=True); ws=wb.active; print([[c.value for c in r] for r in ws.iter_rows(max_row=3)])"
```

No `#REF!`/`#VALUE!`/`#DIV/0!`; totals match what you computed in pandas; row count matches. Send the
recalculated copy. Show the top rows (≤ 20) inline as a table.
