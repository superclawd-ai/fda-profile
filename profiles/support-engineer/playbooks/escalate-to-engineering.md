# Escalate to engineering

Engineering should be able to start fixing from your report alone, without asking anything back.

1. **Where:** the channel or tracker project in `CONTEXT.md` ("Bugs", or "Urgent" for production
   issues). GitHub Issues: `gh issue create --repo <owner>/<repo>` with the report as the body. Another
   tracker: its MCP tools if this FDA has them. Otherwise post the report in the thread and tag the
   person named in `CONTEXT.md`.
2. **The report:**
   ```
   Title: <what breaks, where> (e.g. "Invoice PDF fails for accounts with a long company name")
   Severity: <from CONTEXT.md> · Customers affected: <count or "one so far">
   Steps to reproduce: 1. … 2. … 3. …
   Expected: …
   Actual: … (error text, screenshot)
   Environment: production / staging, version, browser if relevant
   Cause (if found): <file:line and one line of explanation>, or "not found yet"
   Workaround: <what customers can do meanwhile>, or "none"
   Customer thread: <link>
   ```
3. **No personal data** in the report beyond an account id when needed.
4. **Close the loop:** tell the requester it's escalated and where; when engineering ships a fix,
   update the `kb/` entry and tell the requester (or draft the customer reply).
