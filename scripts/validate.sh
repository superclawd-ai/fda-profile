#!/usr/bin/env bash
# Check every profile has the required files and valid JSON. Exit 1 on any problem.
set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
required_files=(CLAUDE.md CONTEXT.md REPOS.md DECISION.md .mcp.json .claude/settings.json)
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

for dir in "$here"/profiles/*/; do
  name="$(basename "$dir")"
  [[ "$name" =~ ^[a-z][a-z0-9-]*$ ]] || { echo "$name: name must be kebab-case (lowercase, dashes)"; fail=1; }
  for f in "${required_files[@]}"; do
    [ -f "$dir$f" ] || { echo "$name: missing $f"; fail=1; }
  done
  for d in "${required_dirs[@]}"; do
    [ -d "$dir$d" ] || { echo "$name: missing $d/"; fail=1; }
  done
  for d in .files repos worktrees; do
    [ -f "$dir$d/.gitkeep" ] || { echo "$name: $d/ needs a .gitkeep"; fail=1; }
  done
  for f in .mcp.json .claude/settings.json; do
    [ -f "$dir$f" ] && ! json_ok "$dir$f" && { echo "$name: $f is not valid JSON"; fail=1; }
  done
  grep -q '"mcpServers"' "$dir.mcp.json" 2>/dev/null || { echo "$name: .mcp.json needs an mcpServers key"; fail=1; }
  if grep -Eiq '"[^"]*(token|secret|password|api[_-]?key)[^"]*"[[:space:]]*:[[:space:]]*"[^$"][^"]*"' "$dir.mcp.json" 2>/dev/null; then
    echo "$name: .mcp.json looks like it holds a literal secret (use \${VAR})"; fail=1
  fi
  ls "$dir"playbooks/*.md >/dev/null 2>&1 || { echo "$name: playbooks/ has no .md file"; fail=1; }
done

[ $fail -eq 0 ] && echo "All profiles OK"
exit $fail
