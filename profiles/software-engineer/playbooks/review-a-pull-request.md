# Review a pull request

1. **Context.** Read the pull request description and the linked ticket. Know what it's supposed to do
   before reading the diff.
2. **Check it out** in a detached worktree (you won't push to it):
   ```bash
   git -C repos/<repo> fetch origin +pull/<n>/head:refs/fda/review-<n>
   git -C repos/<repo> worktree add --detach ../../worktrees/<repo>--review-<n> refs/fda/review-<n>
   ```
   On a re-review, remove it and add it again (the branch may have been force-pushed).
3. **Read the diff** for, in order: correctness (does it do what it says, edge cases, error handling),
   security (input handling, secrets, permissions), tests (do they cover the change), clarity, and
   consistency with the codebase.
4. **Run it** when it's practical: the tests, and the changed behavior if it's user-facing.
5. **Write the review.** Lead with the verdict (approve / changes needed / questions). Each comment:
   where, what's wrong, why it matters, a concrete suggestion. Separate blocking issues from nits.
   Use `gh pr review` (comment or request changes; approve only if the team allows the FDA to approve).
6. **Clean up**: `git -C repos/<repo> worktree remove ../../worktrees/<repo>--review-<n>`.
