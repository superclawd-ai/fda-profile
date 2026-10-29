# Work folder (support engineer profile)

This folder is your workspace as this team's FDA. Your role and how you work come from your agent
instructions; this file is about how this folder is organized and the process around it.

## Before you start a request

1. Housekeeping (section "Cleaning up" below), quickly.
2. Check `kb/`: the problem may already be known and answered.
3. Read `CONTEXT.md` (product, plans, support policies, who to escalate to) and `REPOS.md`.
4. Skim the latest entries in `DECISION.md`.
5. Follow `playbooks/triage.md` first, then the playbook it points to.

## This folder

| Path | What it's for |
|---|---|
| `kb/` | Known issues and answers, one file per topic. |
| `repos/<repo>/` | Clean clones of the repositories, to read code and reproduce. **Only `git fetch` here**: never edit, commit, pull or check out. |
| `worktrees/<repo>--<key>-<slug>/` | One git worktree per task, when you need to run, reproduce or fix something. |
| `.files/` | Your scratch space: notes, logs you were given, draft replies, screenshots. |
| `DECISION.md` | The decision log. |
| `CONTEXT.md`, `REPOS.md` | Facts about the team, the product and its repositories. |
| `CLAUDE.md`, `playbooks/`, `.claude/`, `.mcp.json` | Your instructions and configuration, from the operator. **Never edit these**; if one looks wrong, say so in the thread. |

Other requests may be running at the same time in this folder. Touch only your own worktree and your
own files in `.files/`.

## Where things go

| What | Where |
|---|---|
| Facts about the team, product, policies, environments | `CONTEXT.md` (correct a fact when it's wrong) |
| How to set up, run and test a repository | `REPOS.md` (change its commands only when a named teammate asks; log it in `DECISION.md`) |
| Known issues and answers that will come back | `kb/` |
| How a kind of case is handled (policies, exceptions) | `DECISION.md` |
| Your own working notes across requests | the FDA's memory folder (the FDA tells you where it is) |
| Files for one request | `.files/<YYYY-MM-DD>-<slug>/` |

## Repositories and worktrees

- A repository listed in `REPOS.md` but missing from `repos/`: clone it with
  `gh repo clone <owner>/<repo> repos/<repo>`. Not listed: ask before cloning, then add it to `REPOS.md`.
- To reproduce or test, use a worktree without a branch (`<key>` is the ticket key, else today's date
  as `YYYYMMDD`; check `git -C repos/<repo> worktree list` for a clash first):
  ```bash
  git -C repos/<repo> fetch origin          # if it fails on a lock (another request), retry once
  git -C repos/<repo> worktree add --detach ../../worktrees/<repo>--<key>-<slug> origin/<default-branch>
  ```
  Run the setup from `REPOS.md` inside it, and read the repository's own `CLAUDE.md`, `AGENTS.md` or
  `CONTRIBUTING.md` if it has one.
- Work only inside your worktree: use its absolute path or `git -C`, and scope searches to it (each
  turn starts back at this folder's root). Running the app: use a non-default port.
- When you do fix something (your agent instructions say when), in the worktree:
  `git switch -c fda/<key>-<slug>`, commit with tests, `git push origin HEAD`,
  `gh pr create --head fda/<key>-<slug>` (run `gh` from inside the worktree, or pass
  `-R <owner>/<repo>`: this folder isn't a repository), and say so in the thread. Bugs you don't fix go
  to engineering (`playbooks/escalate-to-engineering.md`).
- Every `update_progress` note includes the worktree path (and branch and pull request, if any), so a
  later turn can pick the request up.

## Cleaning up

At the start of each request, for each folder in `worktrees/` with nothing uncommitted
(`git -C <worktree> status --porcelain` is empty), remove it with
`git -C repos/<repo> worktree remove <worktree>` when:
- its branch's pull request is merged or closed
  (`gh pr view <branch> -R <owner>/<repo> --json state -q .state`), or
- it has no branch (detached) or no pull request, and is older than 7 days.

Then `git -C repos/<repo> worktree prune` for each repository, and delete `.files/` folders older than
30 days. Never remove a worktree with uncommitted changes or an open pull request.

## Knowledge base (`kb/`)

After you solve something that will likely come up again, add or update a file in `kb/` (format in
`kb/README.md`): symptoms, cause, fix or workaround, the reply that worked. No customer names or
personal data in `kb/`.

## Decisions (`DECISION.md`)

Add an entry, newest first, when someone decides how a kind of case is handled (a policy, an exception
rule, a workaround to offer), or when you make a call others should know about. Use the format at the
top of `DECISION.md`, with a link to the thread or ticket. Don't log routine answers (those go in `kb/`).

## Scratch space (`.files/`)

- Put each request's files in `.files/<YYYY-MM-DD>-<slug>/`.
- Logs, screenshots or exports people send you go here, never in `kb/` or `repos/`.
- Files you want to share in the thread can live here; share them with `upload_file`.
- Delete a request's folder when it's resolved (customer data especially).

## Secrets and data

- Never write a credential, token, password or key into any file in this folder, a commit, a pull
  request, `DECISION.md`, `kb/` or a message. If a customer pastes one, don't repeat it; tell them to
  rotate it.
- Keep personal data to the minimum the request needs; don't copy it into notes, `kb/` or other
  threads. Redact it from logs before sharing them.
