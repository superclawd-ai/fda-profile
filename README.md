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
├── .mcp.json          # extra MCP servers for this FDA (empty by default)
├── .claude/
│   └── settings.json  # Claude Code project settings (lets the servers in .mcp.json load)
├── .files/            # scratch space (temporary files, drafts, files people send)
├── repos/             # clean clones of the repositories in REPOS.md
└── worktrees/         # one git worktree per request, so parallel requests never collide
```

`repos/`, `worktrees/` and `.files/` ship empty: their contents are the client's and never come back
here.

`agent-templates/` (not installed) has starting points for the App agent: `software-engineer.md` and
`support-engineer.md`. Copy one into the FDA's Primary agent and adapt it, or write your own.

## Install on an FDA

On the FDA machine, as the FDA's user:

```bash
git clone https://github.com/superclawd-ai/fda-profile.git ~/fda-profile   # or git pull
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
- Claude Code loads `CLAUDE.md` and `.claude/settings.json` from the working directory on every normal
  turn (not on plan-only turns; see "Known gaps").
- Inside the FDA's sandbox the working directory is writable and everything else in `$HOME` is not, so
  all of the FDA's files live here. Files here (including `.files/`) can be shared with `upload_file`;
  `.env`-style files and keys can't.
- The working directory must be inside the FDA user's home and not inside a hidden folder.

## MCP servers (`.mcp.json`)

Empty by default. Add servers in Claude Code's format:

```json
{
  "mcpServers": {
    "context7": { "type": "http", "url": "https://mcp.context7.com/mcp" }
  }
}
```

- `.claude/settings.json` sets `enableAllProjectMcpServers`, so servers here should load without a
  prompt. Verify it on the first install: the server must show up in the turn's MCP servers.
- **Never a literal secret in this file**: it sits in a folder the FDA can read and write. A server that
  needs a token can reference it as `${VAR}`; agent sessions get an allowlisted environment, so pass the
  variable through the FDA's environment file with `FDA_ENV_PASSTHROUGH=VAR` (`GH_TOKEN` is already
  passed when the FDA has a GitHub token). Anything a tool can use, the FDA can read: give servers
  narrowly scoped, revocable tokens only.
- Every server is code or a service the FDA sends data to: add only what you'd trust with the client's
  code and messages.

## Known gaps (FDA side, to fix in the FDA daemon)

- **Nested repositories' git config isn't write-protected.** The FDA's sandbox makes `.git/config` and
  `.git/hooks` read-only for repositories at the working directory or one level below it; `repos/<repo>`
  is two levels down, so a turn could plant a git hook there. Until the daemon also covers
  `repos/*/.git`, this is an open risk (a prompt-injected turn could plant a hook that runs in a later
  request). The profile already works with the protection on (`--no-track`, `git push origin HEAD`).
- **Plan-only turns don't load the profile.** They start Claude Code with user settings only, so a
  planning turn doesn't see `CLAUDE.md`. Fix: the daemon tells planning turns to read it first.
- **No automatic cleanup in folder mode.** The daemon cleans the worktrees it creates itself, not the
  FDA's `worktrees/`. The profile has the FDA clean up finished worktrees and old `.files/` folders at
  the start of each request.

See [`CLAUDE.md`](CLAUDE.md) for the rules when editing the profile.
