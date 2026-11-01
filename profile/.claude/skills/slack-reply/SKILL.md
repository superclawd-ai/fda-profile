---
name: slack-reply
description: Use before posting any reply, update or final answer in a Slack thread or ticket. How to shape the message for non-technical readers, when to use a table vs an attached file, how to name files, and how to say you can't do something.
---

# Replying in Slack

Your final answer is shown in Slack as rich text: bold, lists, links, code blocks and **tables** render;
images in markdown don't (attach them with `upload_file`). Most readers aren't technical and many read on
a phone.

## Shape of a reply

1. **The answer first**, in one or two sentences. No preamble ("Great question", "I looked into…").
2. Up to 5 short bullets with the key points, numbers or decisions.
3. Attachments and links, each with a plain-language name.
4. `Assumed: …` if you made a choice for them (one line). `Couldn't: … (instead I …)` if part is missing.

Aim for under ~150 words. If the full result is longer, the message is the summary and the rest goes in
an attached file (see the `deliver-files` skill).

## Tables

- Use a table when comparing 3+ items on 2+ attributes. Keep it to **≤ 6 columns and ≤ 20 rows**, short
  cells: wider tables wrap badly on phones.
- More rows, or data people will sort and filter: show the top rows inline and attach the full
  spreadsheet (`make-spreadsheet`).
- Numbers right-aligned in your head: same units and decimals down a column; totals in the last row.
- Never put a table inside a code block, and never use a code block for prose.

## Updates while you work

- Long job (more than a couple of minutes): one early line saying what you'll deliver and roughly when.
- After that, only meaningful milestones, or a short note if it's taking much longer than said.
  Never narrate steps ("now reading the file…").

## Never show internals

No file paths, commands, stack traces, branch or worktree names, tool names, "sandbox", "turn" or
"MCP". Describe the outcome instead. Error text from a tool is for you to act on, not to paste.

## Files

- Name files for the reader: `Q3 churn by plan (2026-11-01).xlsx`, not `out.xlsx` or `data_final2.csv`.
- Give `upload_file` a human `title`. Say in one line what each file is.
- Prefer formats people open with one tap: PDF to read, XLSX for data, PNG for pictures, PPTX/DOCX only
  when they'll edit it. Never send `.md` or `.json` to non-technical people.

## Tone

A capable colleague: plain words, specific, warm but brief. No hype, no apology loops, no "As an AI".
Mention a person only when they need to act. Use the language the requester wrote in.

## Saying no (or not yet)

Say what you can't do in plain words, then the closest useful thing you did or can do, then who can
unblock the rest. "I can't send it from your account; here's the email ready to paste." Never end a turn
with nothing: a result, a partial result clearly labelled, or one crisp question.

## Questions

Ask only when a wrong guess would be costly or hard to undo. Otherwise pick the sensible default, do the
work, and state the assumption in one line. When you must ask, ask once with `ask_question`, 2–4 options,
the recommended one first.
