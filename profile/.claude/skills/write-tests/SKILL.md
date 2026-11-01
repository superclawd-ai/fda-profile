---
name: write-tests
description: Use when adding or changing code that needs tests, writing a regression test for a bug, choosing unit vs integration vs end-to-end tests, fixing flaky tests, or when tests can't run in this environment.
---

# Writing tests

- **Test behavior, not implementation.** Assert on outputs, state changes and calls across a boundary. A
  refactor that keeps behavior must not break the test. No assertions on private methods or call order
  unless the order is the contract.
- **Level**: unit for logic and branches; integration for every boundary you own that changes (DB query,
  HTTP handler → DB, queue handler, serialization; use the repo's test DB/containers if `REPOS.md` has
  them); end-to-end only for a critical path the repo already covers that way. Default: unit tests for the
  logic plus one integration test per new or changed boundary.
- **Every test must fail without your change.** Prove it: run it against the code before your change
  (stash or revert the fix) and record the failure, then the pass. A test that never failed proves
  nothing.
- **Bug fixes**: write the regression test first, see it fail for the right reason, then fix. Put both
  outputs in the PR ("before: expected 0, got -150 · after: pass").

## Edge cases (go through them, test what applies)

empty / null / missing · one vs many, duplicates · boundaries (0, -1, max, off-by-one, pagination edges) ·
Unicode, whitespace, case · time zones, DST, month end, leap day · large inputs (they expose complexity) ·
invalid input and the error path · permissions (other user, other tenant, anonymous) · retries and double
submits (idempotency) · a dependency failing halfway.

## Reliable tests

Freeze or inject the clock (no `sleep`: poll with a timeout) · seed randomness · no real network (stub at
the HTTP boundary) · no dependence on order or shared state · unique ports and temp folders · run new
tests 3 times before pushing. Test data: the repo's factories/fixtures, minimal and explicit; never
production data or real personal data. Mock only what you don't own, at the boundary (third-party APIs,
clock, email); don't mock the thing under test.

## Coverage

Every new branch and error path is exercised; if the repo has a coverage tool, check the changed lines.
No percentage chasing, no assertion-free tests. **Never delete, skip or loosen an existing test or
assertion to get green**; if one is truly obsolete, say why in the PR.

## When tests can't run here

Missing service, secret or data: run everything that can run, write the tests anyway, verify by hand
where possible, and say in the PR and to the requester exactly what wasn't run and why (name the missing
piece for the operator in `update_progress`). Never say "tested" about something you didn't run.
