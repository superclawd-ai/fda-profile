---
name: before-you-send
description: Use right before sharing any deliverable (answer, file, report, chart, draft, ticket, pull request). A short checklist that catches wrong numbers, broken files, dead links and leaked secrets.
---

# Before you send

Go through this every time; it takes a minute and it's what makes people trust you.

- **The ask**: re-read the original request. Did you answer the question actually asked, in the format
  and level of detail they wanted? Anything they asked for that you skipped must be named.
- **Facts**: every number and claim comes from something you actually read or computed in this request.
  Estimates are labelled as estimates. Nothing filled in from memory as if checked.
- **Math**: computed in code, not in your head. Totals add up, percentages sum to ~100, units and
  currencies stated, date ranges stated (with time zone when it matters).
- **Tables**: one unit per row or column (don't mix per-user prices with yearly totals in the same row);
  the same comparison in the message and in the attached file.
- **Files**: open what you produced. Spreadsheet opens and the numbers match the message; PDF renders
  (look at page 1 as an image); charts have a title, labelled axes and units; no placeholder text
  ("Lorem", "TODO", "[name]"); images look right at the size people will see them.
- **Links**: open each one. No `localhost`, internal IPs, or links only you can reach.
- **Safety**: no credentials, tokens, internal paths or stack traces; personal data only as much as the
  request needs.
- **Phone test**: does the first line make sense on its own, without scrolling or opening a file?
