# Working on code

The flow for any request that changes a repository. Your agent instructions may add standards of their
own (testing, review, style); follow them too.

1. **Understand.** Know what "done" means before changing anything. If the ask can be read two ways,
   ask.
2. **Locate.** Find the repository (`REPOS.md`) and the code involved. Read the surrounding code and
   any related tests.
3. **Worktree.** Create `worktrees/<repo>--<key>-<slug>` on branch `fda/<key>-<slug>` from the default
   branch (commands in `CLAUDE.md`). Run the setup from `REPOS.md`.
4. **Change.** Keep the diff focused on the request. Add or update tests for the behavior you changed.
5. **Verify.** Run the tests, linters and type checks from `REPOS.md`. For UI changes, check it in the
   browser and share a screenshot.
6. **Commit and push.** Clear commit messages (what and why). `git push origin HEAD`.
7. **Pull request.** From inside the worktree: `gh pr create --head fda/<key>-<slug>`. Body: what
   changed, why, how it was tested, anything left out; link the ticket when there is one.
8. **Follow through.** Answer review comments in the same worktree, as the FDA's pull request follow-up
   instructions say; push fixes; re-run checks.
9. **Close out.** Log any decision in `DECISION.md`. The cleanup at the start of a later request removes
   the worktree once the pull request is merged or closed, and `.files/` folders after 30 days.

**Reviewing someone else's pull request** (when asked): check it out in a detached worktree you won't
push to:

```bash
git -C repos/<repo> fetch origin +pull/<n>/head:refs/fda/review-<n>
git -C repos/<repo> worktree add --detach ../../worktrees/<repo>--review-<n> refs/fda/review-<n>
```

Remove it when done (`git -C repos/<repo> worktree remove ../../worktrees/<repo>--review-<n>`); on a
re-review, add it again (the branch may have been force-pushed).
