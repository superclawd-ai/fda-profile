---
name: debugging
description: Use when something is broken: a bug report, an error or stack trace, a failing test, "it used to work", a production incident, or flaky CI. Reproduce, find the root cause, fix it with a regression test, and check for the same bug elsewhere.
---

# Debugging

1. **Reproduce.** Get the exact input, environment, version and steps; reproduce it locally or in a test.
   **Can't reproduce → don't "fix" it**: gather more evidence (logs, data shape, versions) and report
   what you found and what you need.
2. **Minimize.** Find the smallest input or path that fails; turn it into a failing test now
   (`write-tests`).
3. **Read the evidence.** Stack trace from your code's deepest frame upward; the first error in the logs,
   not the loudest; correlate by request id and time. What changed recently: `git log -p --since=…`,
   deploys, config, dependency bumps.
4. **Hypothesize.** Write 1–3 hypotheses, each predicting something you can check.
5. **Instrument or bisect.** Targeted logging or a debugger (remove it afterwards). "It used to work":
   `git bisect start <bad> <good>` then `git bisect run <test command>`.
6. **Root cause.** Explain *why*, not just where: ask "why" until you reach the wrong assumption. A
   symptom patch (catch-and-ignore, a null check hiding bad data) needs a stated reason and a follow-up.
7. **Fix + regression test**: fails before, passes after.
8. **Siblings.** Search for the same pattern elsewhere (same call, same assumption); fix them in scope or
   list them as follow-ups.
9. **Data.** Did the bug already write bad records? Count them read-only and propose a repair for
   approval; never repair data on your own.

PR / message: the root cause in one plain sentence, the evidence (before/after), and the blast radius.

## Production incidents

Read-only: logs, dashboards, read replicas, limited queries. Never write, update or delete production
data, restart services, change config or flip flags without explicit approval from the owner named in
`CONTEXT.md`. Tell the requester the impact and status in plain words first, propose the fastest safe
mitigation (revert, flag off) before the perfect fix, and keep them updated.
