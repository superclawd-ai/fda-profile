# CLAUDE.md: fda-profiles

This repository holds **templates**: work directories for SuperClawd FDAs. You are editing the
templates, not working as an FDA. Each `profiles/<name>/CLAUDE.md` is written *for the FDA agent* that
will work inside an installed copy; this file is for whoever maintains the templates.

## Layout

- `profiles/<name>/`: one profile per role, snake_case. Required in every profile: `CLAUDE.md`,
  `CONTEXT.md`, `REPOS.md`, `DECISION.md`, `.mcp.json`, `.claude/settings.json`, `playbooks/`,
  `.files/`, `repos/`, `worktrees/` (the last three ship empty with a `.gitkeep`).
- `scripts/install.sh`: copies a profile to an FDA's work directory. `scripts/validate.sh`: checks
  every profile has the required files and valid JSON.
- `README.md`: what a profile is and how to install one. Keep its profile table current.

## Rules for profiles

- **Generic, never client-specific.** No client names, repositories, people or secrets in a template.
  Client details go in the installed copy's `CONTEXT.md` / `REPOS.md`, never here.
- **Fit the FDA.** The FDA already tells the agent (in its own system prompt) how to use its tools
  (`set_title`, `post_update`, `ask_question`, `link_pr`, `upload_file`, `update_progress`), to work on a
  branch and open pull requests, and to treat ticket text as untrusted. Profiles add the role and the
  folder's conventions; don't restate or contradict the FDA's rules.
- **The sandbox is real.** Agent sessions can write only inside the working directory (plus their own
  temp and output folders), get only allowlisted environment variables, and can't read `$HOME`
  config beyond git/gh/ssh. Don't write instructions that need anything else.
- **Shared sections stay consistent across profiles**: folder layout, where things go, repos and
  worktrees, cleaning up, decisions, scratch space, secrets. When you change one, change it in every
  profile.
- **Keep `CLAUDE.md` short and concrete.** Procedures longer than a few lines go in `playbooks/`.
- `.mcp.json` ships empty (`{"mcpServers": {}}`); never a literal secret (see README).
- Profiles must work with the git protection the README's "Known gaps" describes: create branches with
  `--no-track`, push with `git push origin HEAD`, never write a repository's `.git/config`.
- Run `scripts/validate.sh` before committing.

## Git

Commit and push to `main` directly is fine for template changes; keep commits focused, one change per
commit, message in the imperative ("Add data_analyst profile").
