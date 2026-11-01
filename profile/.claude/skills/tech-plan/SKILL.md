---
name: tech-plan
description: Use to plan a code change before building it: acceptance criteria, approach and alternatives, files, data/schema/API impact and every consumer, compatibility and migration, tests, risks, rollout and rollback. Also decides when the plan needs the requester's approval.
---

# Technical plan

## Does it need approval?

**Always** (`propose_plan`, then end the turn) when any of these apply:
schema or data migration/backfill · public API, event or contract change · a new dependency or service ·
deleting code, data or endpoints · security, auth, money or personal data · more than ~3 areas or more
than ~a day of work · two reasonable approaches with different trade-offs · unclear criteria.

Otherwise follow the team's plan setting (you're told in your instructions when every change needs a
plan); small, clear changes just get a short plan in your notes and the PR's "Approach".

## The plan (one screen)

Start with **two plain-language lines** for the requester: what you'll do and what it changes for them.
Then:

- **Problem**: what's wrong or missing, for whom; ticket link.
- **Acceptance criteria**: numbered, testable.
- **Approach**: steps, each mapped to the criteria.
- **Alternatives**: 1–2 rejected, with why (always consider "smaller change / do nothing").
- **Files / areas**: what changes and why.
- **Data / schema / API impact and consumers.** Find every consumer before promising compatibility:
  - `grep -rn` across all of `repos/` for the table, column, field, endpoint path, event name, env var,
    flag key;
  - OpenAPI / GraphQL / protobuf schemas and generated clients; ORM models and serializers;
  - migration history; queue/topic producers and consumers; cron jobs and scripts; mobile clients (they
    can't upgrade in sync); flag config;
  - consumers you can't see (other teams, customers' integrations): name them as a risk.
- **Compatibility and migration** (expand / contract): add first (nullable column, new field, new
  endpoint version) → code reads and writes both → backfill in batches (idempotent, resumable) → switch
  reads → remove the old in a later PR. Never rename or drop in one step. Note locks on big tables.
- **Tests**: which unit / integration / e2e tests, which existing suites to run.
- **Risks**: each with impact, likelihood and mitigation (flag, guard, batches, monitoring).
- **Rollout / rollback**: behind a flag or direct; rollback = revert, or a down-migration / data repair
  (say when a plain revert isn't safe).
- **Size**: S (< ½ day), M (≤ 2 days), L (split it into smaller PRs; propose the split).

## Plan approval and changes

Approved plans are the contract: if the work turns out materially different (scope, risk, approach),
stop and re-propose instead of drifting. Log decisions with lasting effect in `DECISION.md`.
