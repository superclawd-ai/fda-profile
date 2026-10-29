# Triage a support request

1. **Read it twice.** What is the person trying to do, what happened, what did they expect?
2. **Urgent?** Data loss, security, payments, production down, many customers affected: escalate now
   (`escalate-to-engineering.md`, urgent path) and say so in the thread. Then keep investigating.
3. **Classify:**
   - **How-to question** → answer from the docs, the product or the code; link the doc page.
   - **Known issue** (found in `kb/`) → reply with the known cause and fix or workaround; update the
     entry's "Last confirmed".
   - **Possible bug** → `reproduce-and-diagnose.md`.
   - **Account, billing, refund, exception** → not yours to decide: route to the person in
     `CONTEXT.md` with a summary.
   - **Feature request** → summarize the need (not just the asked-for solution) and pass it to the
     product contact in `CONTEXT.md`.
4. **Missing information?** Ask for exactly what you need in one message (steps, account or workspace
   id, time, screenshot, error text), not a questionnaire.
5. **Say what's next.** Every reply ends with the next step and who owns it.
