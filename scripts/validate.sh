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

[ $fail -eq 0 ] && echo "Profile OK"
exit $fail
