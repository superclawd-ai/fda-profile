---
name: spike
description: Use for investigations before committing to build: "can we…?", "how would we…?", feasibility, comparing libraries or approaches, estimates, unknown codebases. Time-boxed; ends in a recommendation for a decision, not production code.
---

# Spike

- **Question first**: write the decision this spike must inform in one sentence.
- **Time-box**: the one agreed, or about 2 hours of work. When it's spent, stop and report what you have
  and what's still unknown.
- **Prototype** only if it answers the question faster than reading: a throwaway branch
  `fda/<key>-spike-<slug>` in its own worktree. Never open a pull request from it, never merge it; push it
  only if asked, clearly marked throwaway.
- Evidence over opinion: read the actual code and docs, run small experiments, measure.

## Deliverable (for non-technical readers first)

1. **Answer** (2–3 lines): the recommendation in plain words.
2. **Options table**: option · what it means for the users · effort (S/M/L) · risk · cost / dependencies.
3. **Why** the recommendation.
4. **Unknowns left** and how to resolve them.
5. **Estimate** with a confidence level.
6. **Technical appendix** (files, evidence, prototype findings): attach it as a document, don't paste it.

Once someone decides, log it in `DECISION.md`; the build follows `software-delivery`.
