# Investigate a bug

1. **Pin down the report.** What happened, what was expected, where (environment, URL, version),
   since when, for whom. Ask for what's missing (steps, screenshot, error text) before digging deep.
2. **Reproduce.** In a fresh worktree on the default branch (`--detach` until you start a fix),
   reproduce it locally or with a failing test. Note the exact steps in `.files/<date>-<slug>/notes.md`.
3. **Narrow down.** Read the code path; check recent changes (`git log -p` on the files involved,
   recent merged pull requests). Bisect if it's a regression and the range is known.
4. **Root cause.** State it in one or two lines, with the file and line. Share it in the thread
   with `post_update`, even before a fix, and record it with `update_progress`.
5. **Fix or report.**
   - Clear, contained fix: follow `ship-a-change.md` (in the same worktree: `git switch -c
     fda/<key>-<slug>`), starting with a test that fails without the fix.
   - Risky, large, or in an area you were told to avoid: post the root cause, the proposed fix and the
     risk, and ask how to proceed.
6. **Can't reproduce?** Say what you tried, what you ruled out, and what information would help.
   Don't guess at a fix.
