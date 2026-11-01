---
name: incident-report
description: Use when someone asks what happened during an outage, disruption, spike of errors, wrong data, failed job or customer-facing problem, or asks for an incident report, post-mortem or status update on one. Produces a plain-language report (impact, timeline, cause, confidence, follow-ups) from the investigation done with `debugging`.
---

# Incident report

The investigation itself follows `debugging` (read-only on production). This skill is how you report
it: people need to know **what happened, who was affected, whether it's over, and what happens next**,
in words they can act on.

## While it's still happening: status updates

Post short updates in the thread, each standing on its own:

> **Status:** investigating / cause found / mitigated / resolved · **Impact:** who and what is affected,
> since when · **Next:** what you're doing now and when the next update comes.

Mitigation first (revert, turn a flag off, pause a job), the perfect fix later. Anything that touches
production needs approval from the owner named in `CONTEXT.md`: propose it, don't do it.

## The report

Write it once the cause is known (or the investigation is stuck). Lead with the summary; a reader who
stops after it must still know what matters.

```markdown
# Incident: <what users experienced, in their words> (<date>)

**Summary.** 2–4 sentences: what happened, to whom, for how long, the cause in one plain sentence, and
whether it's resolved.

| | |
|---|---|
| Status | resolved / mitigated / ongoing |
| Impact | who and how many (orders, users, requests, money), or "unknown" and why |
| Started / detected / resolved | times with time zone (UTC and the team's) |
| Severity | the team's scale if `CONTEXT.md` has one, else low / medium / high and why |

## Timeline
Times in one time zone. Include when it started (from evidence, not from when someone noticed), when it
was detected and how, every change made, and when it ended.

## What happened
The chain from cause to symptom, plain words first, technical detail after. Name the change, setting or
data that triggered it.

## Evidence
What each conclusion rests on: the log lines, error counts, commits, queries, screenshots (attached or
linked, never file paths). Mark each conclusion **confirmed** (reproduced or proven), **likely**
(consistent with all evidence, not proven) or **unknown**.

## Impact detail
The numbers and how you counted them (read-only). Records the problem wrote that still need repair:
how many, and the proposed repair (not done; needs approval).

## What we don't know yet
Open questions and what would answer them.

## Follow-ups
| Action | Why | Suggested owner | Status |
|---|---|---|---|
Fix with regression test, monitoring or alert that would have caught it earlier, data repair, sibling
risks found elsewhere. Suggest owners; don't assign people.
```

## Rules

- **Blameless.** Describe systems, changes and decisions, never people's mistakes. "A change on
  14 Nov set the value in dollars instead of cents", not "X broke it".
- **Facts vs guesses.** Every claim is confirmed, likely or unknown; never present a hypothesis as the
  cause. Impact you couldn't measure is "unknown", not a guess.
- **Evidence you were given.** Use the sources the team gave you (your agent instructions and
  `CONTEXT.md` say which tools you can read) and anything people send in the thread (screenshots,
  exports, log excerpts). Never assume access to a tool nobody mentioned. Missing evidence: ask for the
  specific piece in plain words ("the time it started and one example order number").
- **Personal and customer data:** counts and anonymized examples only; redact emails, names, card or
  account numbers and tokens from anything quoted.
- **Read-only.** Investigating never changes production data, configuration or services. The fix goes
  through `software-delivery` like any change.

## Delivering it

- Slack: the summary and status table as the message (`slack-reply`), with the follow-ups as a short
  list. A full report longer than a screen: also attach it as a PDF (`make-pdf`) or Word document
  (`make-word-doc`) named `incident-<yyyy-mm-dd>-<topic>`.
- Offer to file the follow-ups as tickets (`tickets`); file them only if asked.
- Record the incident in `DECISION.md` only if it led to a lasting decision.
- Check it with `before-you-send` (numbers add up, times have a zone, nothing sensitive quoted).
