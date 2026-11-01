#!/usr/bin/env bash
# Check the profile has the required files and valid JSON. Exit 1 on any problem.
set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dir="$here/profile/"
required_files=(CLAUDE.md CONTEXT.md REPOS.md DECISION.md .mcp.json bin/cleanup.sh)
required_dirs=(playbooks .files repos worktrees)
fail=0

json_ok() {
  if command -v python3 >/dev/null; then
    python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$1" 2>/dev/null
  elif command -v node >/dev/null; then
    node -e 'JSON.parse(require("fs").readFileSync(process.argv[1],"utf8"))' "$1" 2>/dev/null
  else
    echo "validate.sh needs python3 or node to check JSON" >&2
    exit 1
  fi
}

for f in "${required_files[@]}"; do
  [ -f "$dir$f" ] || { echo "missing profile/$f"; fail=1; }
done
for d in "${required_dirs[@]}"; do
  [ -d "$dir$d" ] || { echo "missing profile/$d/"; fail=1; }
done
for d in .files repos worktrees; do
  [ -f "$dir$d/.gitkeep" ] || { echo "profile/$d/ needs a .gitkeep"; fail=1; }
done
[ -x "${dir}bin/cleanup.sh" ] || { echo "profile/bin/cleanup.sh must be executable"; fail=1; }
for f in .mcp.json; do
  [ -f "$dir$f" ] && ! json_ok "$dir$f" && { echo "profile/$f is not valid JSON"; fail=1; }
done
grep -q '"mcpServers"' "$dir.mcp.json" 2>/dev/null || { echo "profile/.mcp.json needs an mcpServers key"; fail=1; }
if grep -Eiq '"[^"]*(token|secret|password|api[_-]?key)[^"]*"[[:space:]]*:[[:space:]]*"[^$"][^"]*"' "$dir.mcp.json" 2>/dev/null; then
  echo "profile/.mcp.json looks like it holds a literal secret (use \${VAR})"; fail=1
fi
ls "$dir"playbooks/*.md >/dev/null 2>&1 || { echo "profile/playbooks/ has no .md file"; fail=1; }

# Skills: each folder has a SKILL.md whose front matter names it and says when to use it.
skills="${dir}.claude/skills"
[ -d "$skills" ] || { echo "missing profile/.claude/skills/"; fail=1; }
for s in "$skills"/*/; do
  n=$(basename "$s")
  f="$s/SKILL.md"
  [ -f "$f" ] || { echo "skill $n has no SKILL.md"; fail=1; continue; }
  head -1 "$f" | grep -q '^---$' || { echo "skill $n: SKILL.md must start with front matter (---)"; fail=1; }
  grep -q "^name: $n\$" "$f" || { echo "skill $n: front matter needs 'name: $n'"; fail=1; }
  grep -Eq '^description: .{40,}' "$f" || { echo "skill $n: front matter needs a description saying when to use it"; fail=1; }
  if grep -Eq '(^|[^-])\b(pip3? install|npm i(nstall)? -g|apt(-get)? install|npx )' "$f"; then
    echo "skill $n: tells the agent to install something (turns can't; add it to deps/)"; fail=1
  fi
done

# Tools: the manifest and its locks.
deps="$here/deps"
for f in apt.txt versions.env requirements.in requirements.lock package.json package-lock.json doctor.sh; do
  [ -f "$deps/$f" ] || { echo "missing deps/$f"; fail=1; }
done
[ "$deps/requirements.lock" -nt "$deps/requirements.in" ] || { echo "deps/requirements.lock is older than requirements.in: re-lock (see README)"; fail=1; }
grep -q -- '--hash=sha256:' "$deps/requirements.lock" 2>/dev/null || { echo "deps/requirements.lock has no hashes"; fail=1; }
if grep -o '"resolved": "https://[^/]*' "$deps/package-lock.json" 2>/dev/null | grep -v 'registry.npmjs.org' | grep -q .; then
  echo "deps/package-lock.json resolves packages outside registry.npmjs.org (re-lock with an empty .npmrc)"; fail=1
fi
for f in scripts/install.sh scripts/install-deps.sh scripts/doctor.sh scripts/sandbox-exec.sh deps/doctor.sh; do
  [ -x "$here/$f" ] || { echo "$f must be executable"; fail=1; }
  bash -n "$here/$f" 2>/dev/null || { echo "$f has a syntax error"; fail=1; }
done

[ $fail -eq 0 ] && echo "Profile OK"
exit $fail
