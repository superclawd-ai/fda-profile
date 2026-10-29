# Reproduce and diagnose a problem

1. **Collect the facts** in `.files/<date>-<slug>/notes.md`: steps, environment, account/plan (no
   personal data beyond what's needed), time, error text, what changed recently.
2. **Reproduce** on staging or locally (a detached worktree from `repos/`, setup from `REPOS.md`),
   never by changing production data. Write down the exact steps that trigger it.
3. **Find the cause.** Follow the code path for the failing action; check recent changes to it
   (`git log` on the files, recently merged pull requests); look at logs if `CONTEXT.md` gives
   read-only access.
4. **Decide:**
   - **Expected behavior** → explain why it works this way and what the person can do instead.
   - **User error or configuration** → the steps to fix it.
   - **Bug** → `escalate-to-engineering.md` (or a small fix yourself only if the requester asked or
     it's trivial and safe; see `CLAUDE.md`).
5. **Report** in the thread: what you found, how you know (reproduced / seen in code / guess), the
   next step. Add a `kb/` entry if it will come back.
6. **Can't reproduce?** List what you tried and ruled out, and ask for the one or two details that
   would help most.
