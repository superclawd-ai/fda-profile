---
name: self-review
description: Use before pushing a change for review: review your own diff like a strict senior reviewer (correctness, complexity, design, security, compatibility, tests), then write the pull request description from the template.
---

# Self-review

## How

1. `git fetch origin` then `git diff origin/<default-branch>...HEAD --stat` and read **every** file's diff
   completely, plus the code around each change.
2. Tick each acceptance criterion against the diff.
3. Check the sensitive paths: `git diff origin/<default-branch>...HEAD --stat -- '*test*' '*spec*'
   '*.snap' '*lock*' '*migration*' '.github/*'`: every change there is intended and explained.
4. Secrets and junk: no `.env`, keys, tokens, personal data, build output or debug code in the diff.
5. If you can, ask a fresh subagent to review only the diff and the criteria (not your reasoning) for
   blocking issues; check its findings yourself.
6. Fix what you found, re-run the checks, repeat until you'd approve it.

## Checklist

- **Correctness**: every criterion met; edge cases handled; errors handled or propagated, never
  swallowed; no leftover debug code or TODO without a ticket.
- **Complexity**: no nested loops over collections that can grow (use a map/set lookup); no query or
  HTTP call inside a loop (N+1: batch or join); limits/pagination on unbounded reads; indexes for new
  query filters.
- **Data structures**: set for membership, map for lookups, the right DB types and constraints.
- **Design**: single responsibility; short functions named for intent; no duplicated logic that must stay
  in sync; patterns or abstractions only when they remove duplication or a conditional you have *now*
  (no speculative layers); the repository's existing patterns over textbook ones.
- **Readability**: names say what, comments say why, no dead code.
- **Security**: parameterized queries (no string-built SQL, shell or HTML); authorization (and tenant
  scope) on every new endpoint or action; input validated; no secrets or personal data in code, logs or
  tests; new dependencies maintained, licensed, approved.
- **Performance and concurrency**: hot paths, memory on large inputs, check-then-act races, transactions
  around multi-writes, idempotent retries, timeouts on external calls.
- **Compatibility**: schema/API/event changes additive; consumers still work; migrations reversible or
  the rollback documented.
- **Observability**: useful logs/metrics on new failure paths, at the right level.
- **Docs**: README, API docs, changelog, env var docs updated.
- **Tests**: would fail if the code were removed; assert behavior.
- **Hygiene**: focused diff, no unrelated formatting churn, no generated files unless the repo commits
  them.

## Pull request description

```
## What and why
<1–3 plain sentences. Closes/links <ticket>.>

## Acceptance criteria
| Criterion | Change | Test |
|---|---|---|

## How it was tested
- Ran: <commands> on <commit> → <results> (baseline before the change: <results>)
- Regression: failed before the fix (<failing line>), passes after
- Manual: <steps and result>
- Not verified: <what and why, or "nothing">

## Risks
<impact · likelihood · mitigation for each; "none identified" only after the consumer search>
Consumers checked: <what you searched and found>

## Rollout and rollback
<flag? migration order? rollback = revert / down-migration / data repair>

## Screenshots
<UI changes: before/after, desktop and mobile>

## Follow-ups
<out-of-scope issues, sibling bugs, tech debt>
```
