# FDA profile

The work folder template for SuperClawd FDAs (forward deployed agents). One profile, for any role: it
sets up how an FDA's folder works (repositories, worktrees, decisions, client facts, cleanup). **Who the
FDA is and what it does** (its role, standards and preferences) comes from its agent in the SuperClawd
App, which whoever runs the FDA writes.

## Layers

| Layer | Where it comes from | What it says |
|---|---|---|
| Agent | The FDA's Primary agent in the SuperClawd App (plus the workspace's skills, guardrails, memories) | The role, standards and preferences: software engineer, support, anything |
| FDA instructions | The FDA daemon, on every request | How to work as an FDA (Slack and ticket tools, pull requests, questions) |
| Work folder | This profile's `CLAUDE.md`, installed on the FDA (Claude Code loads it) | How the folder is organized and the process around it |

Where the agent and the folder's `CLAUDE.md` differ, the agent wins, except for the folder's rules on
repositories and worktrees, cleanup, files it never edits, and secrets.

## What's in the profile

```
profile/
├── CLAUDE.md          # how this folder works (Claude Code loads it)
├── CONTEXT.md         # the client: product, people, environments, conventions (filled in at onboarding)
├── REPOS.md           # the repositories: URL, default branch, setup, tests
├── DECISION.md        # decision log: what was decided, why, by whom (newest first)
├── playbooks/         # procedures (working-on-code.md; add the client's own)
├── bin/cleanup.sh     # removes finished worktrees and old scratch folders (run at every request start)
├── .claude/skills/    # skills: documents, data, images, research, writing, Slack replies (see below)
├── .mcp.json          # extra MCP servers for this FDA (empty by default)
├── .files/            # scratch space (temporary files, drafts, files people send)
├── repos/             # clean clones of the repositories in REPOS.md
└── worktrees/         # one git worktree per request, so parallel requests never collide
```

`repos/`, `worktrees/` and `.files/` ship empty: their contents are the client's and never come back
here.

`agent-templates/` (not installed) has starting points for the App agent: `general-assistant.md`, `software-engineer.md`, `code-reviewer.md`, `support-engineer.md`,
`sales.md`, `business-operations.md`, `devops-sre.md`, `data-analyst.md`, `product-manager.md`, `qa-engineer.md`,
`marketing.md` and `executive-assistant.md`. Copy one into the FDA's Primary agent and adapt it, or write your own.

## Install on an FDA

On the FDA machine, as the FDA's user:

```bash
git clone https://github.com/superclawd-ai/fda-profile.git ~/fda-profile   # or git pull
~/fda-profile/scripts/install-deps.sh    # the tools the skills need (sudo; ~10 min the first time)
~/fda-profile/scripts/doctor.sh          # every capability checked inside the FDA's sandbox
~/fda-profile/scripts/install.sh ~/work/jim
```

Then:

1. Fill in `CONTEXT.md` and `REPOS.md` in `~/work/jim`.
2. In the client's SuperClawd workspace, create the FDA's **Primary agent** (role and preferences; an
   `agent-templates/` file is a good start) and pick it in the FDA admin.
3. In the FDA admin, set the **working directory** to `~/work/jim`.
4. Optional: clone the repositories now (`gh repo clone <owner>/<repo> ~/work/jim/repos/<repo>`);
   otherwise the FDA clones them from `REPOS.md` the first time it needs them.
5. Optional: add MCP servers to `.mcp.json` (see below).

`install.sh` copies the profile and never overwrites an existing folder. The installed copy is the
client's from then on: it is not a git checkout of this repository, so nothing the FDA writes can be
pushed here by mistake. To pick up a newer profile, compare and copy by hand.

**Never `git init` the installed folder**: the FDA would then treat it as a single repository instead
of a folder of repositories.

### Why it works this way

- The FDA runs every request with this folder as its working directory. Because the folder itself isn't
  a git repository, the FDA treats it as a folder of repositories: requests start here, and the FDA
  makes its own worktree under `worktrees/` per request (`CLAUDE.md` says how).
- Claude Code loads `CLAUDE.md` from the working directory on every normal turn (planning turns don't load it, but the FDA tells them to read it first).
- Inside the FDA's sandbox the working directory is writable and everything else in `$HOME` is not, so
  all of the FDA's files live here. Files here (including `.files/`) can be shared with `upload_file`;
  `.env`-style files and keys can't.
- The working directory must be inside the FDA user's home and not inside a hidden folder.

## Skills (`.claude/skills/`)

Claude Code loads the skills from the working directory. They're generic (any role, any client) and
tell the agent how to produce finished work with the tools on the machine, for people who aren't
technical:

| Area | Skills |
|---|---|
| Talking to people | `slack-reply`, `before-you-send`, `writing`, `summarize`, `tickets` |
| Files and documents | `deliver-files`, `make-pdf`, `make-spreadsheet`, `make-word-doc`, `make-slides`, `convert-files`, `read-documents` |
| Data and research | `analyze-data`, `web-research`, `dates-money-units` |
| Visuals | `chart`, `diagram`, `make-graphic`, `company-logo`, `edit-image`, `showcase-prototype` |
| The machine | `tools-on-this-machine` (what's installed, `fda-doctor`, fallbacks) |

Some skills ship helper scripts (`md2pdf.py`, `slides.py`, `chart.py`, `logo.py`, `shoot.py`); they run
with `fda-python` and are tested inside the FDA's sandbox.

## Tools (`deps/`, `scripts/install-deps.sh`)

An agent turn can't install anything (its sandbox shows the system read-only), so every tool a skill uses
is installed once per machine:

- `deps/apt.txt`: system packages (rsvg, ImageMagick, poppler, qpdf, Tesseract, ocrmypdf, pandoc,
  LibreOffice headless, Graphviz, ffmpeg, QR, fonts).
- `deps/requirements.in` → `deps/requirements.lock`: Python packages, hash-pinned, in a venv on a pinned
  Python (uv) under `/opt/fda-tools`, independent of the system Python and the FDA's Node.
- `deps/package.json` + lock: npm tools (Mermaid), plus Playwright's headless Chromium.
- Entry points on the turn's PATH: `fda-python`, `fda-chrome`, `fda-soffice`, `fda-mmdc`, `fda-doctor`.

`scripts/install-deps.sh` is idempotent: re-run it after `deps/` changes or an Ubuntu upgrade. It also
makes sure the machine has swap (adds a 4 GB swapfile, kept across reboots, when there's none) used only under
memory pressure (`vm.swappiness=10`): with 8 GB of RAM, Chromium, LibreOffice and parallel requests otherwise
risk getting processes killed. `doctor.sh` shows how much swap is in use: if it's a lot most of the time, the
machine needs more RAM (or a Server image instead of Desktop), not more swap. Each
version is built in its own folder and switched in at the end, so it's safe while the FDA is working.
`scripts/doctor.sh` runs `fda-doctor` inside the same sandbox as a turn (`scripts/sandbox-exec.sh` runs
any command that way, handy to debug a skill). The agent runs `fda-doctor` itself when a tool fails.

Re-locking after editing `deps/requirements.in` or `deps/package.json` (on a maintainer's machine):

```bash
uv pip compile deps/requirements.in --universal --python-version 3.13 --generate-hashes --no-header -o deps/requirements.lock
: > /tmp/empty.npmrc && (cd deps && npm install --package-lock-only --ignore-scripts --userconfig /tmp/empty.npmrc --registry https://registry.npmjs.org/)
```

Footprint: about 2.5 GB of disk. Chromium and LibreOffice each use a few hundred MB of RAM while
running; on 8 GB machines add swap.

## MCP servers (`.mcp.json`)

Empty by default. Add servers in Claude Code's format; the FDA's turns load them (needs FDA 0.1.12 and
superclawd 0.1.97 or later):

```json
{
  "mcpServers": {
    "context7": { "type": "http", "url": "https://mcp.context7.com/mcp" }
  }
}
```

- **Never a literal secret in this file**: it sits in a folder the FDA can read and write. A server that
  needs a token can reference it as `${VAR}`; agent sessions get an allowlisted environment, so pass the
  variable through the FDA's environment file with `FDA_ENV_PASSTHROUGH=VAR` (`GH_TOKEN` is already
  passed when the FDA has a GitHub token). Anything a tool can use, the FDA can read: give servers
  narrowly scoped, revocable tokens only. Credentialed servers can also live in the SuperClawd App's MCP
  settings (encrypted).
- Server names `fda`, `fda-browser`, `fda-calendar`, `core` and `superclawd` are reserved and ignored.
- Every server is code or a service the FDA sends data to: add only what you'd trust with the client's
  code and messages.

## Requirements and notes

- **FDA 0.1.12 and superclawd 0.1.97 or later.** Earlier versions don't load `.mcp.json` servers into
  the FDA's turns, don't write-protect the git config and hooks of `repos/<repo>` (two levels down), and
  don't point planning turns at `CLAUDE.md`. Verified on a real FDA (2026-10-30).
- **Cleanup in folder mode is the profile's job.** The daemon cleans the worktrees it creates itself, not
  the FDA's `worktrees/`; `bin/cleanup.sh` does it, and the FDA runs it at the start of each request.

See [`CLAUDE.md`](CLAUDE.md) for the rules when editing the profile.
