---
name: debugging
description: Use when something is broken or someone asks what happened: a bug report, an error or stack trace, a failing test, "it used to work", an outage or disruption, wrong data, or flaky CI. Find the evidence, reproduce, find the root cause, fix it with a regression test, and check for the same bug elsewhere.
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

## Where the evidence comes from

Use only the sources the team gave you: the tools your agent instructions and `CONTEXT.md` say you can
read (and that are actually connected in this session), the repositories, and anything people send in
the thread. **Never assume a tool exists because teams usually have one.** The kinds of evidence, and
what to take from each:

| Evidence | What to look for |
|---|---|
| Error reports / stack traces | First and last occurrence, count, how many users, release/version, the deepest frame in your code, the inputs or breadcrumbs before it |
| Logs | Filter by request/trace id, user or record id and the time window; the first error, then what preceded it |
| Metrics / dashboards | When the error rate, latency, traffic or queue depth changed, and whether that lines up with a change |
| Traces | Which span got slow or failed, and what it called |
| What changed | Merged pull requests and commits (`git log --merges --since=…` on the default branch), releases, configuration, flags, migrations, dependency bumps, data imports |
| Data | Read-only queries on the records involved (a replica when one exists), limited and without personal data in the output |
| What people send | Screenshots, exported logs or CSVs, example ids, times: read them (`read-documents`) and say what they show |

No access to a source you need: say so in one line, work from the code, the git history and what people
send, and ask for the **specific** piece in plain words ("the time it started and two example order
numbers", "a screenshot of the error"). Name the access that would help in `update_progress` for the
operator.

**Investigating "what happened?"**: pin down scope first (since when, who is affected, is it still
happening), build a timeline in one time zone, put every change from around the start on it, and look
for the one that explains every symptom (and the absence of others). Confirm it by reproducing it in a
test against the code that was live then. Report it with `incident-report`.

PR / message: the root cause in one plain sentence, the evidence (before/after), and the blast radius.

## Production incidents

Read-only: logs, dashboards, read replicas, limited queries. Never write, update or delete production
data, restart services, change config or flip flags without explicit approval from the owner named in
`CONTEXT.md`. Tell the requester the impact and status in plain words first, propose the fastest safe
mitigation (revert, flag off) before the perfect fix, and keep them updated.
