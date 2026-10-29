# FDA profiles

Ready-made work directories for SuperClawd FDAs (forward deployed agents). A profile is the folder an
FDA works in: it tells the agent who it is, where things live, how to work, and where to record what
it decides. Install one per FDA, fill in the client's details, point the FDA at it.

| Profile | For |
|---|---|
| [`software_engineer`](profiles/software_engineer) | Builds and fixes things: tickets, bugs, features, reviews, pull requests |
| [`support_engineer`](profiles/support_engineer) | Answers and investigates support questions: triage, reproduce, explain, escalate |

## What's in a profile

```
profiles/<profile>/
├── CLAUDE.md          # the agent's instructions for this role and this folder (Claude Code loads it)
├── CONTEXT.md         # the client: product, people, environments, links (filled in at onboarding)
├── REPOS.md           # the repositories the FDA works on: URL, default branch, setup, tests
├── DECISION.md        # decision log: what was decided, why, by whom (newest first)
├── playbooks/         # step-by-step procedures for recurring work
├── kb/                # (support_engineer) known issues and answers
├── .mcp.json          # extra MCP servers for this FDA (empty by default)
├── .claude/
│   └── settings.json  # Claude Code project settings (lets the servers in .mcp.json load)
├── .files/            # the agent's scratch space (temporary files, drafts, exports)
├── repos/             # clean clones of the repositories in REPOS.md (one folder per repo)
└── worktrees/         # one git worktree per task, so parallel requests never collide
```

`repos/`, `worktrees/` and `.files/` ship empty: their contents are the client's and never come back
to this repository.

## Install a profile on an FDA

On the FDA machine, as the FDA's user:

```bash
git clone https://github.com/superclawd-ai/fda-profiles.git ~/fda-profiles   # or git pull
~/fda-profiles/scripts/install.sh software_engineer ~/work/jim
```

Then:

1. Fill in `CONTEXT.md` and `REPOS.md` in `~/work/jim` (the client, the repositories).
2. In the FDA admin, set the **working directory** to `~/work/jim`.
3. Optional: clone the repositories now (`gh repo clone <owner>/<repo> ~/work/jim/repos/<repo>`);
   otherwise the agent clones them from `REPOS.md` the first time it needs them.
4. Optional: add MCP servers to `.mcp.json` (see below).

`install.sh` copies the profile; it never overwrites an existing folder. The installed copy is the
client's from then on: it is not a git checkout of this repository, so nothing the FDA writes (decisions,
client details, code) can be pushed here by mistake. To pick up a newer profile later, compare and copy
by hand (or install to a new folder and move the client files over).

**Never `git init` the installed folder**: the FDA would then treat it as a single repository (one
worktree per request of the folder itself) instead of a folder of repositories.

### Why it works this way

- The FDA runs every request with this folder as its working directory. Because the folder itself isn't
  a git repository, the FDA treats it as a folder of repositories: requests start here, and the agent
  makes its own worktree under `worktrees/` per task (`CLAUDE.md` says how).
- Claude Code loads `CLAUDE.md` and `.claude/settings.json` from the working directory on every normal
  turn (not on plan-only turns; see "Known gaps").
- Inside the FDA's sandbox the working directory is writable and everything else in `$HOME` is not,
  so all of the agent's files live here. Files here (including `.files/`) can be shared with
  `upload_file`; `.env`-style files and keys can't.
- The working directory must be inside the FDA user's home and not inside a hidden folder.

## MCP servers (`.mcp.json`)

Empty by default. Add servers the role needs, in Claude Code's format:

```json
{
  "mcpServers": {
    "context7": { "type": "http", "url": "https://mcp.context7.com/mcp" }
  }
}
```

- `.claude/settings.json` sets `enableAllProjectMcpServers`, so servers here should load without a
  prompt. Verify it on the first install: the server must show up in the turn's MCP servers.
- **Never a literal secret in this file**: it sits in a folder the agent can read and write. A server
  that needs a token can reference it as `${VAR}`; agent sessions get an allowlisted environment, so
  pass the variable through the FDA's environment file with `FDA_ENV_PASSTHROUGH=VAR` (`GH_TOKEN` is
  already passed when the FDA has a GitHub token). Anything a tool can use, the agent can read: give
  servers narrowly scoped, revocable tokens only.
- Every server is code or a service the agent sends data to: add only what you'd trust with the
  client's code and messages.

## Known gaps (FDA side, to fix in the FDA daemon)

- **Nested repositories' git config isn't write-protected.** The FDA's sandbox makes `.git/config` and
  `.git/hooks` read-only for repositories at the working directory or one level below it; `repos/<repo>`
  is two levels down, so a turn could plant a git hook there. Until the daemon also covers
  `repos/*/.git`, this is an open risk (a prompt-injected turn could plant a hook that runs in a later
  request). The profiles already work with the protection on (`--no-track`, `git push origin HEAD`).
- **Plan-only turns don't load the profile.** They start Claude Code with user settings only, so a
  planning turn doesn't see `CLAUDE.md`. Fix: the daemon tells planning turns to read it first.
- **No automatic cleanup in folder mode.** The daemon cleans the worktrees it creates itself, not the
  agent's `worktrees/`. The profiles have the agent clean up finished worktrees and old `.files/`
  folders at the start of each task.

## Add a profile

1. Copy the closest profile: `cp -R profiles/software_engineer profiles/<new_name>` (snake_case).
2. Rewrite `CLAUDE.md` for the role (keep the shared sections: folder layout, worktrees, decisions,
   scratch space, secrets), and adjust the playbooks.
3. Run `scripts/validate.sh`.
4. Add it to the table above.

See [`CLAUDE.md`](CLAUDE.md) for the rules when editing profiles.
