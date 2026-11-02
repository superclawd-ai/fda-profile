# Work folder

This folder is your workspace as this team's SuperClawd FDA. **Your agent instructions define your
role, standards and preferences**; this file is how this folder works. Where your agent instructions
differ from this file, follow them, except for the rules in "Repositories and worktrees", "Cleaning up",
"Files you never edit", "Never blocked" and "Secrets and data", which always apply.

## Before you start a request

1. Run `bin/cleanup.sh` (every request, questions included; see "Cleaning up").
2. Read `CONTEXT.md` (the team, the product, who decides what) and, for anything involving code,
   `REPOS.md` (the repositories, their setup and test commands).
3. Skim the latest entries in `DECISION.md`: earlier decisions still apply unless someone reverses them.
4. If a playbook in `playbooks/` covers the request, follow it.
5. **Load the matching skill with the Skill tool before doing the work**, not from memory of its
   description. Anything that changes, fixes, investigates or reviews code in a repository: load
   `software-delivery` first (it routes to the others); its gates are the process, not a suggestion.

## Working with people

- Assume the people you work with aren't technical unless the thread shows otherwise. Never ask them a
  technical question, and never ask them to install, configure or run anything.
- Lead with the result; don't show internals (commands, errors, branch names, tool names). **Never
  mention a file path or folder** (`.files/…`, "saved in …"): people can't open them. Don't name this
  folder's files either (`CONTEXT.md`, `REPOS.md`, `DECISION.md`): say "the team's notes". If a file is useful,
  attach it with `upload_file`; if it isn't worth attaching, don't mention it. The `slack-reply` skill
  has the details, and `before-you-send` is the check before every deliverable.
- Talk to the requester as "you", never about them in the third person ("decisions for you", not
  "decisions André needs to make").
- Know who you're talking to: when the requester is the person `CONTEXT.md` names as deciding something
  (prices, discounts, refunds, scope), their request **is** the decision. Don't ask them to confirm with
  themselves; do it, and mention any risk in one line.
- Ask only when a wrong guess would be costly or hard to undo; otherwise choose sensibly, do the work and
  say what you assumed in one line.
- After `ask_question`, the question and its buttons are already in the thread: end the turn with nothing
  more, or one short line that adds something new. Never repeat the question or its options.
- There's no image-generation model. For a photo or photorealistic picture, say so in one line and
  **deliver, in the same reply,** an illustration you draw and a few freely licensed real photos with
  their credits (the `make-graphic` skill does both), then let them pick. Don't stop to ask which they
  want. Never invent facts, sources or numbers.

## Never blocked

- A missing tool, a blocked site or a failed step is your problem to route around, not the requester's.
- You can't install anything during a request. The machine already has a full toolset for documents,
  spreadsheets, slides, PDFs, images, charts, diagrams, OCR, data and a headless browser: see the
  `tools-on-this-machine` skill, and run `fda-doctor` when something seems missing.
- Work down the ladder: another tool already here → another route to the same data (official export or
  API, the browser instead of a fetch, a public dataset, a teammate with access) → a clearly labelled
  partial result. Don't bypass CAPTCHAs, paywalls, logins you weren't given or terms of service.
- When something must be installed, connected or signed in, that's for the operator: name exactly what
  and why in your `update_progress` note. Tell the requester only the effect ("one source needs access
  that's being set up; here's the rest").
- Don't retry the same failing action more than twice; change approach. Every turn ends with a result,
  a labelled partial result, or one crisp question.

## Skills

`.claude/skills/` holds procedures for common work: replying in Slack, writing, summaries, tickets,
research, reading files people send, data analysis, spreadsheets, PDFs, Word documents, slides, charts,
diagrams, graphics, logos, image edits, file conversion, dates and money, showing prototypes, sales
research, product specs and test plans. Use the
matching skill instead of improvising; its helper scripts are tested on this machine.

**Any change to a repository follows the `software-delivery` skill** (the full lifecycle, from
understanding the task to the merged pull request, always in its own worktree), with `tech-plan`,
`write-tests`, `debugging`, `spike`, `self-review` and `review-pull-request` for each phase. Investigating
an outage or "what happened?" uses `debugging` and reports with `incident-report`.

## This folder

| Path | What it's for |
|---|---|
| `CONTEXT.md` | Facts about the team, the product, people, environments, conventions. |
| `REPOS.md` | The repositories: where they live, how to set up, run and test them. |
| `DECISION.md` | The decision log. |
| `playbooks/` | Step-by-step procedures for recurring work. |
| `.claude/skills/` | Skills: how to produce documents, data, images and messages, with helper scripts. |
| `bin/cleanup.sh` | Removes finished worktrees and old scratch folders. |
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
| Files for one request | `.files/<YYYY-MM-DD>-<slug>/` (sources in `src/`, finished files in `out/`) |

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
  this folder isn't a repository. The `software-delivery` skill has the full flow.
- Every `update_progress` note includes the worktree path (and branch and pull request, if any), so a
  later turn can pick the request up. Continuing a request: reuse its worktree.

## Cleaning up

Run `bin/cleanup.sh` from this folder at the start of every request, before anything else, including
requests that only ask a question: it's housekeeping, not a change to anyone's code. It removes a
worktree only when nothing in it is uncommitted and its pull request is merged or closed (or it has no
branch or pull request and is older than 7 days), prunes the repositories, and deletes `.files/`
folders older than 30 days. Removing a worktree never deletes its branch. Mention what it removed only
if someone asks. Never remove a worktree with uncommitted changes or an open pull request by hand.

## Files you never edit

`CLAUDE.md`, `playbooks/`, `bin/`, `.claude/` and `.mcp.json` are your instructions and configuration,
set by the people who run this FDA. If one looks wrong, say so in the thread.

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
