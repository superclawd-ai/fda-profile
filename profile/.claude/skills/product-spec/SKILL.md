---
name: product-spec
description: Use to write a product spec, PRD, one-pager or feature brief, to synthesize customer feedback or research into themes, or to compare competitors' features for a product decision.
---

# Product specs and feedback

## Spec / one-pager

```markdown
# <Feature>: spec (<date>, status: draft)
**Problem:** who has it, when, how often, with evidence (quotes, counts, tickets: linked).
**Goal and success measure:** what changes for users and how we'll know (a metric and a target).
**Proposal:** what we'll build, in user terms; a mockup when it helps (`showcase-prototype`).
**User stories / flows:** the main path and the important edge cases.
**Acceptance criteria:** testable checklist.
**Out of scope:** what this deliberately doesn't do.
**Alternatives considered:** and why not.
**Risks and dependencies:** technical, legal, support, pricing; who needs to be involved.
**Open questions:** each with an owner.
**Rollout:** flag, beta group, announcement, docs.
```

Keep it to what a decision needs; link details instead of pasting them. Mark assumptions as assumptions.

**Deliver it** as an editable Word document (`make-word-doc`, named `<Feature> spec (<date>).docx`) with
the recommendation, the trade-off and the decisions needed summarized in the thread: at most the 3–5
decisions that block progress, the rest stay in the document's open questions. Never attach a
`.md` file.

## Feedback synthesis

1. Collect the sources (threads, tickets, survey exports, call notes) and say what's in and out (dates,
   channels).
2. Tag each item with a theme; merge duplicates; count unique customers per theme, not mentions.
3. For each theme: the problem in users' words (2–3 short quotes, anonymized), how many and which
   segments, what they're trying to do, current workarounds.
4. Rank by reach × pain, and say what the data can't tell (who didn't answer, small samples).
5. Deliver: the top themes as a short table in the thread, the full tagged list as a spreadsheet.

Don't turn requests into solutions too early: "customers asked for X" is a hint about a problem, not a
spec.

## Competitor feature comparison

Rows are jobs users need done, not feature names; cells say how each product handles it, from their
public docs (linked and dated). End with what it means for our decision.
