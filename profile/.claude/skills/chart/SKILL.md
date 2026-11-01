---
name: chart
description: Use when asked for a chart or graph (bar, line, pie, scatter, stacked, trend) from numbers, a spreadsheet or an analysis, or when a report or slide needs one.
---

# Charts

Use the helper for common charts (consistent, clean style), matplotlib directly for anything custom.

```
fda-python .claude/skills/chart/chart.py bar data.csv "Signups by month.png" \
    --x month --y signups --title "Signups grew 40% since June" --ylabel Signups
# kinds: bar, barh, line, area, pie, scatter, stacked (several --y)
# input: CSV or XLSX (--sheet NAME); --y can repeat for several series; --pct / --money formats the axis
```

Custom charts: `fda-python` with `import matplotlib.pyplot as plt; plt.style.use(".claude/skills/chart/fda.mplstyle")`,
then `plt.savefig(out, dpi=200, bbox_inches="tight")`.

## Rules for a good chart

- The **title states the takeaway** ("Signups grew 40% since June"), not "Signups".
- Pick the form by question: change over time → line; compare categories → bar (horizontal if labels are
  long, sorted by value); parts of a whole with ≤ 5 parts → pie, otherwise stacked bar; relationship →
  scatter.
- Label axes with units; start bar axes at zero; no 3D, no dual axes unless essential.
- ≤ 6 colors; highlight the one series that matters, grey the rest.
- Add a source line under the chart when the data came from somewhere specific (`--source "…"`).

## Check

Read the PNG: labels overlapping, cut off, unreadable small text, wrong numbers. Numbers on the chart
must match the data you report in the message.
