"""Clean charts from a CSV/XLSX in one command (style: fda.mplstyle).

usage: fda-python chart.py KIND DATA OUT.png --x COL --y COL [--y COL ...] [--title T] [--xlabel L]
                 [--ylabel L] [--sheet S] [--source TEXT] [--pct] [--money SYMBOL] [--sort] [--labels]
KIND: bar | barh | line | area | pie | scatter | stacked
"""
import argparse
import pathlib

import matplotlib.pyplot as plt
import matplotlib.ticker as mt
import pandas as pd

here = pathlib.Path(__file__).resolve().parent
ap = argparse.ArgumentParser()
ap.add_argument("kind", choices=["bar", "barh", "line", "area", "pie", "scatter", "stacked"])
ap.add_argument("data")
ap.add_argument("out")
ap.add_argument("--x", required=True)
ap.add_argument("--y", action="append", required=True)
ap.add_argument("--title", default="")
ap.add_argument("--xlabel")
ap.add_argument("--ylabel")
ap.add_argument("--sheet")
ap.add_argument("--source")
ap.add_argument("--pct", action="store_true", help="values are fractions (0.25) -> 25%")
ap.add_argument("--money", metavar="SYMBOL")
ap.add_argument("--sort", action="store_true", help="sort bars by value")
ap.add_argument("--labels", action="store_true", help="write values on bars")
a = ap.parse_args()

plt.style.use(str(here / "fda.mplstyle"))
p = pathlib.Path(a.data)
df = pd.read_excel(p, sheet_name=a.sheet or 0) if p.suffix.lower() in (".xlsx", ".xls") else pd.read_csv(p)
if a.sort and a.kind in ("bar", "barh"):
    df = df.sort_values(a.y[0], ascending=a.kind == "barh")
fig, ax = plt.subplots()
x = df[a.x]
# Dates read as month names for people ("Jan", or "Jan 2026" across years), not 2026-01.
if not pd.api.types.is_datetime64_any_dtype(x) and x.dtype == object:
    parsed = pd.to_datetime(x, errors="coerce", format="mixed")
    if parsed.notna().all() and not x.astype(str).str.fullmatch(r"[A-Za-z]{3,9}").all():
        x = parsed
if pd.api.types.is_datetime64_any_dtype(x):
    x = x.dt.strftime("%b" if x.dt.year.nunique() == 1 else "%b %Y")
if a.kind == "pie":
    ax.pie(df[a.y[0]], labels=x, autopct="%1.0f%%", startangle=90, counterclock=False,
           wedgeprops={"linewidth": 2, "edgecolor": "white"})
    ax.axis("equal")
    ax.grid(False)
elif a.kind == "scatter":
    ax.scatter(x, df[a.y[0]], s=36, alpha=0.8)
elif a.kind == "stacked":
    bottom = None
    for col in a.y:
        ax.bar(x.astype(str), df[col], bottom=bottom, label=col)
        bottom = df[col] if bottom is None else bottom + df[col]
elif a.kind in ("bar", "barh"):
    n = len(a.y)
    w = 0.8 / n
    for i, col in enumerate(a.y):
        pos = [j + (i - (n - 1) / 2) * w for j in range(len(df))]
        bars = (ax.barh if a.kind == "barh" else ax.bar)(pos, df[col], w, label=col)
        if a.labels:
            ax.bar_label(bars, padding=3, fontsize=9, color="#444")
    ticks = range(len(df))
    if a.kind == "barh":
        ax.set_yticks(ticks, x.astype(str))
        ax.grid(axis="x")
        ax.grid(axis="y", visible=False)
    else:
        ax.set_xticks(ticks, x.astype(str))
else:
    for col in a.y:
        if a.kind == "area":
            ax.fill_between(x, df[col], alpha=0.25)
        ax.plot(x, df[col], label=col)
if a.kind != "pie":
    axis = ax.xaxis if a.kind == "barh" else ax.yaxis
    if a.pct:
        axis.set_major_formatter(mt.PercentFormatter(1.0, decimals=1 if df[a.y].max().max() < 0.1 else 0))
    elif a.money:
        axis.set_major_formatter(mt.FuncFormatter(lambda v, _: f"{a.money}{v:,.0f}"))
    else:
        axis.set_major_formatter(mt.FuncFormatter(lambda v, _: f"{v:,.0f}" if abs(v) >= 1000 else f"{v:g}"))
    if a.xlabel or a.kind != "barh":
        ax.set_xlabel(a.xlabel or "")
    if a.ylabel:
        ax.set_ylabel(a.ylabel)
    if len(a.y) > 1:
        ax.legend(loc="upper left", bbox_to_anchor=(0, 1.02), ncols=min(len(a.y), 4))
    if a.kind not in ("barh",) and max((len(str(v)) for v in x), default=0) > 8:
        plt.setp(ax.get_xticklabels(), rotation=30, ha="right")
ax.set_title(a.title)
if a.source:
    fig.text(0.01, -0.02, f"Source: {a.source}", fontsize=9, color="#888", ha="left")
fig.savefig(a.out)
print(f"wrote {a.out}")
