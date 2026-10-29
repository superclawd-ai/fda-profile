# Ship a change (feature, fix, ticket)

1. **Understand.** Restate the ask in one or two lines. If acceptance criteria are missing or the
   ask can be read two ways, ask before coding.
2. **Locate.** Find the repository (`REPOS.md`) and the code involved. Read the surrounding code and
   any related tests.
3. **Worktree.** Create `worktrees/<repo>--<key>-<slug>` on branch `fda/<key>-<slug>` from the
   default branch (commands in `CLAUDE.md`). Run the setup from `REPOS.md`.
4. **Plan** when the FDA's plan policy calls for it. A choice with lasting consequences: ask with
   `ask_question` before building it.
5. **Change.** Keep the diff focused on the task. Add or update tests for the behavior you changed.
6. **Verify.** Run tests, linters and type checks from `REPOS.md`. For UI changes, check it in the
   browser and share a screenshot.
7. **Commit and push.** Clear commit messages (what and why). `git push origin HEAD`.
8. **Pull request.** From inside the worktree: `gh pr create --head fda/<key>-<slug>`. Title: short and specific (the FDA's
   ticket rules set the format for tickets). Body: what changed, why, how it was tested, anything left
   out. Request the reviewers named in `CONTEXT.md` if the repository doesn't assign them.
9. **Follow through.** Answer review comments in the same worktree, as the FDA's pull request
   follow-up instructions say; push fixes; re-run checks.
10. **Close out.** Log any decision in `DECISION.md`. The cleanup at the start of a later task removes
    the worktree once the pull request is merged or closed, and `.files/` folders after 30 days.
