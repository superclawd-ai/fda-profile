---
name: diagram
description: Use for flowcharts, process maps, architecture or system diagrams, sequence diagrams, org charts, timelines, Gantt charts, mind maps and decision trees.
---

# Diagrams

## Mermaid (flowcharts, sequences, timelines, Gantt, mind maps)

Write a `.mmd` file, render:

```
fda-mmdc -i flow.mmd -o flow.png -s 2 -b white          # PNG, 2x
fda-mmdc -i flow.mmd -o flow.svg                         # editable SVG
```

Keep labels short; `flowchart LR` for wide processes, `TD` for tall; ≤ 15 nodes per diagram (split
bigger ones); use subgraphs for groups. Quote labels with special characters: `A["Pay (card)"]`.

## Graphviz (org charts, trees, architecture with many links)

```
dot -Tpng -Gdpi=200 org.dot -o org.png        # or -Tsvg
```

Defaults that look good: `graph [rankdir=TB, fontname="Inter", nodesep=0.4];
node [shape=box, style="rounded,filled", fillcolor="#F3F4F6", color="#D1D5DB", fontname="Inter"];
edge [color="#9CA3AF"];`

## Check

Read the PNG: overlapping labels, unreadable small text, arrows crossing everything. Simplify or split
before sending. Attach the PNG; if they may edit it, also attach the SVG (opens in any browser and in
design tools). Never point to where files are saved.
If `fda-mmdc` fails, render the same structure with Graphviz.
