---
name: test-plan
description: Use to write a test plan for a feature or release, to test a change or a pull request by hand (exploratory testing in the browser), or to write a bug report that engineering can act on.
---

# Test plans and bug reports

## Test plan

```markdown
# Test plan: <feature> (<build/PR/version>, <date>)
**Scope:** what's tested; **out of scope:** what isn't, and why.
**Environments:** URL, browsers and devices, accounts and roles, test data.
**Risks:** where bugs are most likely or most costly (money, data, permissions, migrations).
| # | Case | Steps | Expected | Priority |
```

Cover, as applicable: the main flow; each acceptance criterion; validation (empty, too long, wrong
format, special characters, emoji, other languages); boundaries (0, 1, max, max+1); permissions (each
role, logged out, someone else's data); state (refresh, back button, two tabs, double click, slow or
offline network); time (time zones, daylight saving, month and year ends); mobile size; accessibility
basics (keyboard only, labels, contrast); and what changed around it (regressions).

## Exploratory testing

Time-box it (30–60 minutes per area), with a charter ("explore checkout with discount codes to find
pricing mistakes"). Take notes as you go; screenshot anything odd (`showcase-prototype` has the browser
helpers); record what you covered, so the report says what was *not* tested.

## Bug report

```markdown
**Title:** <area>: <what goes wrong> (not "bug in checkout")
**Steps to reproduce:** numbered, from a clean state, with the exact data used.
**Expected:** … **Actual:** … (quote error messages exactly)
**Environment:** URL, build/version, browser/device, account role.
**Frequency:** always / N of M tries. **Severity:** who is affected and how badly.
**Evidence:** screenshot or short recording, console or network errors if visible.
**Suggested priority:** … because …
```

One bug per report. Search for an existing one first and add to it instead.

## Verdict for a release or PR

Lead with it: "ready", "ready with known issues: …", "not ready: N blockers", or "couldn't test: why".
Then the table of cases run with pass/fail, the bugs filed (linked) and what wasn't covered.
