---
name: analyze-data
description: Use to compile, merge, compare, deduplicate, reconcile, clean, filter, pivot or summarize data (spreadsheets, CSV exports, lists, ticket exports, survey results).
---

# Working with data

Tools: `fda-python` with **duckdb** (SQL straight over CSV/XLSX/Parquet files) and **pandas** (reshaping).

```python
import duckdb, pandas as pd
con = duckdb.connect()
df = con.sql("SELECT plan, count(*) n, sum(mrr) mrr FROM read_csv_auto('export.csv') GROUP BY 1 ORDER BY 3 DESC").df()
xl = pd.read_excel("crm.xlsx", sheet_name=None)          # every sheet
```

## Matching and deduplicating

Normalize keys before comparing: trim, lowercase, remove accents (`unidecode`), standard phone/email
formats, strip company suffixes ("Inc", "Ltda") when matching names. For fuzzy matches use `rapidfuzz`
(`process.extractOne`, `fuzz.token_sort_ratio`) with a threshold you state (e.g. ≥ 90), and list borderline
matches for a human to confirm instead of merging them silently.

## Verify (always)

- Row counts in and out at each step; explain every row that disappears.
- Totals reconcile with the source (sum before = sum after, or explain the difference).
- Show 3–5 example rows of each outcome (matched / unmatched / duplicates) in the reply or a sheet.
- List assumptions ("treated blank region as Unknown", "dates read as day/month").
- Never change the original file; write results to a new one.

## Deliver

Headline numbers in the message (≤ 20-row table inline); full results as XLSX with one sheet per output
(`make-spreadsheet`); a chart if a trend or comparison matters (`chart`).
