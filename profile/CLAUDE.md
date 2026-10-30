# Work folder

This folder is your workspace as this team's SuperClawd FDA. **Your agent instructions define your
role, standards and preferences**; this file is how this folder works. Where your agent instructions
differ from this file, follow them, except for the rules in "Repositories and worktrees", "Cleaning up",
"Files you never edit" and "Secrets and data", which always apply.

## Before you start a request

1. Housekeeping ("Cleaning up" below), quickly.
2. Read `CONTEXT.md` (the team, the product, who decides what) and, for anything involving code,
   `REPOS.md` (the repositories, their setup and test commands).
3. Skim the latest entries in `DECISION.md`: earlier decisions still apply unless someone reverses them.
4. If a playbook in `playbooks/` covers the request, follow it.

## This folder

| Path | What it's for |
|---|---|
| `CONTEXT.md` | Facts about the team, the product, people, environments, conventions. |
| `REPOS.md` | The repositories: where they live, how to set up, run and test them. |
| `DECISION.md` | The decision log. |
| `playbooks/` | Step-by-step procedures for recurring work. |
| `repos/<repo>/` | A clean clone of each repository. **Only `git fetch` here**: never edit, commit, pull or check out. |
| `worktrees/<repo>--<key>-<slug>/` | One git worktree per request that touches code. |
| `.files/` | Your scratch space: notes, drafts, files people send you, exports, screenshots. |

Other requests may be running at the same time in this folder. Touch only your own worktree and your
own files in `.files/`.

## Where things go

| What | Where |
|---|---|
| Facts about the team, product, environments | `CONTEXT.md` (correct a fact when it's wrong) |
| How to set up, run and test a repository | `REPOS.md` (change its commands only when a named teammate asks; log it in `DECISION.md`) |
| Decisions and their reasons | `DECISION.md` |
| Your own working notes across requests | the FDA's memory folder (the FDA tells you where it is) |
| Files for one request | `.files/<YYYY-MM-DD>-<slug>/` |

## Repositories and worktrees

- A repository listed in `REPOS.md` but missing from `repos/`: clone it with
  `gh repo clone <owner>/<repo> repos/<repo>`. Not listed: ask before cloning, then add it to `REPOS.md`.
- Never work in `repos/` directly. Pick `<key>` (the ticket key, else today's date as `YYYYMMDD`) and a
  short `<slug>`, check `git -C repos/<repo> worktree list` for a clash, then fetch
  (`git -C repos/<repo> fetch origin`; if it fails on a lock, another request is fetching: retry once):
  - **To change code** (a branch you'll push):
    `git -C repos/<repo> worktree add --no-track -b fda/<key>-<slug> ../../worktrees/<repo>--<key>-<slug> origin/<default-branch>`
  - **To read, run or reproduce only** (no branch):
    `git -C repos/<repo> worktree add --detach ../../worktrees/<repo>--<key>-<slug> origin/<default-branch>`
    (start a branch later with `git switch -c fda/<key>-<slug>` if it turns into a change).
- In a new worktree, run the setup from `REPOS.md` and read the repository's own `CLAUDE.md`,
  `AGENTS.md` or `CONTRIBUTING.md` if it has one.
- Work only inside your worktree: use its absolute path or `git -C`, and scope searches to it (each
  turn starts back at this folder's root). Running an app or dev server: use a non-default port.
- Push with `git push origin HEAD`. Run `gh` from inside your worktree, or pass `-R <owner>/<repo>`:
  this folder isn't a repository. `playbooks/working-on-code.md` has the full flow.
- Every `update_progress` note includes the worktree path (and branch and pull request, if any), so a
  later turn can pick the request up. Continuing a request: reuse its worktree.

## Cleaning up

At the start of each request, for each folder in `worktrees/` with nothing uncommitted
(`git -C <worktree> status --porcelain` is empty), remove it with
`git -C repos/<repo> worktree remove <worktree>` when:
- its branch's pull request is merged or closed
  (`gh pr view <branch> -R <owner>/<repo> --json state -q .state`), or
- it has no branch (detached) or no pull request, and is older than 7 days.

Then `git -C repos/<repo> worktree prune` for each repository, and delete `.files/` folders older than
30 days. Never remove a worktree with uncommitted changes or an open pull request.

## Files you never edit

`CLAUDE.md`, `playbooks/`, `.claude/` and `.mcp.json` are your instructions and configuration, set by
the people who run this FDA. If one looks wrong, say so in the thread.

## Decisions (`DECISION.md`)

Add an entry, newest first, when someone decides something with lasting effect (scope, an approach, a
policy, an exception), or when you make a non-obvious choice others should know about later. Use the
format at the top of `DECISION.md`, a few lines each, with a link to the thread, ticket or pull request.
Don't log routine work.

## Scratch space (`.files/`)

- Put each request's files in `.files/<YYYY-MM-DD>-<slug>/`, including files people send you.
- Files you want to share in the thread can live here; share them with `upload_file`.
- Delete a request's folder when it's done unless someone may need the files again.

## Secrets and data

- Never write a credential, token, password or key into any file in this folder, a commit, a pull
  request, `DECISION.md` or a message. If you come across one, don't repeat it: say where it is and
  suggest rotating it.
- Keep personal and customer data to the minimum a request needs; don't copy it into notes, other
  files or other threads. Redact it from logs before sharing them.
