# Working on code

Any request that changes a repository follows the **`software-delivery`** skill: understand → plan →
start (worktree) → build → verify → self-review → pull request → CI → review and merge → close out, with
a gate at each step and an evidence-based Definition of Done. It routes bugs (`debugging`), spikes
(`spike`), plans (`tech-plan`), tests (`write-tests`), self-review and the PR description
(`self-review`) and reviews of other people's pull requests (`review-pull-request`).

The worktree commands are in `CLAUDE.md` → "Repositories and worktrees". In short:

```bash
git -C repos/<repo> fetch origin
git -C repos/<repo> worktree add --no-track -b fda/<key>-<slug> ../../worktrees/<repo>--<key>-<slug> origin/<default-branch>
# … work, test, commit (stage files by name) …
git push origin HEAD          # from inside the worktree
gh pr create                  # from inside the worktree
```

Team specifics (lanes, reviewers, who merges, release) are in `CONTEXT.md` → "How we ship code".
