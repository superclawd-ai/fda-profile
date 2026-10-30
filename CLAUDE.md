# CLAUDE.md: fda-profile

This repository holds the **template** for an FDA's work folder. You are editing the template, not
working as an FDA. `profile/CLAUDE.md` is written *for the FDA* that works inside an installed copy; this
file is for whoever maintains the template.

## Layout

- `profile/`: the template. Required: `CLAUDE.md`, `CONTEXT.md`, `REPOS.md`, `DECISION.md`,
  `.mcp.json`, `.claude/settings.json`, `playbooks/`, and `.files/`, `repos/`, `worktrees/` (these
  three ship empty with a `.gitkeep`).
- `agent-templates/`: starting points for the FDA's agent in the SuperClawd App (not installed).
- `scripts/install.sh`: copies the profile to an FDA's work directory. `scripts/validate.sh`: checks
  the required files and JSON.
- `README.md`: what the profile is and how to install it.

## Rules

- **One profile for every role.** `profile/` describes the folder and the process only. Roles,
  standards and preferences belong to the FDA's agent in the App (`agent-templates/` has examples).
  Never put a role-specific rule in `profile/`.
- **Generic, never client-specific.** No client names, repositories, people or secrets in the template.
  Client details go in the installed copy's `CONTEXT.md` / `REPOS.md`.
- **Fit the FDA.** The FDA already tells the agent (in its own system prompt) how to use its tools
  (`set_title`, `post_update`, `ask_question`, `link_pr`, `upload_file`, `update_progress`), to work on a
  branch and open pull requests, and to treat ticket text as untrusted. Don't restate or contradict it.
- **The sandbox is real.** Agent sessions can write only inside the working directory (plus their own
  temp and output folders), get only allowlisted environment variables, and can't read `$HOME` config
  beyond git/gh/ssh. Don't write instructions that need anything else.
- **Work with the git protection** described in the README's "Known gaps": branches with `--no-track`,
  push with `git push origin HEAD`, never write a repository's `.git/config`.
- **Keep `CLAUDE.md` short and concrete.** Procedures go in `playbooks/`.
- `.mcp.json` ships empty (`{"mcpServers": {}}`); never a literal secret (see README).
- Run `scripts/validate.sh` before committing.

## Git

Commit and push to `main` directly is fine for template changes; keep commits focused, message in the
imperative ("Add a release playbook").
