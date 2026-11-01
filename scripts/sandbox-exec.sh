#!/usr/bin/env bash
# Run a command the way an FDA agent turn runs it: inside the same sandbox (root read-only, an empty $HOME
# with the daemon's read-only allowlist, its own /tmp), with the turn's PATH. For checking tools and
# skills on an FDA machine; run it as the FDA's user.
#   scripts/sandbox-exec.sh [--cwd DIR] -- COMMAND [ARGS...]
# --cwd DIR: the working directory, bound read-write (default: a new empty temp folder), like a work folder.
# Mirrors apps/fda server/runner/sandbox.ts buildJailArgs and runner/turn.ts buildEnv.
set -uo pipefail
H=$HOME
cwd=""
while [ $# -gt 0 ]; do
  case $1 in
    --cwd) cwd=$(cd "$2" && pwd -P); shift 2 ;;
    --) shift; break ;;
    *) break ;;
  esac
done
[ $# -gt 0 ] || { echo "usage: $(basename "$0") [--cwd DIR] -- COMMAND [ARGS...]" >&2; exit 2; }
command -v bwrap >/dev/null || { echo "bwrap is missing: the FDA's sandbox can't run (apt install bubblewrap)" >&2; exit 1; }

envf=$H/.superclawd/fda/env
unit_path=$(systemctl show -p Environment --value superclawd-fda 2>/dev/null | tr ' ' '\n' | sed -n 's/^PATH=//p')
file_path=$(sed -n 's/^PATH=//p' "$envf" 2>/dev/null | tail -1) # the env file overrides the unit
extra_ro=$(sed -n 's/^FDA_SANDBOX_RO=//p' "$envf" 2>/dev/null | tail -1 | tr ',:' '  ')
node=$(systemctl show -p ExecStart --value superclawd-fda 2>/dev/null | sed -n 's/.*path=\([^ ;]*\).*/\1/p')

s=$(mktemp -d)
mkdir -p "$s/cwd" "$s/tmp"
trap 'rm -rf "$s"' EXIT
[ -n "$cwd" ] || cwd="$s/cwd"
a=(--die-with-parent --unshare-pid --unshare-ipc --ro-bind / / --dev /dev --proc /proc)
for d in /run/user /var/log /etc/ssh/ssh_config.d; do [ -e "$d" ] && a+=(--tmpfs "$d"); done
a+=(--bind "$s/tmp" /tmp --tmpfs "$H")
ro=("$H/.local/bin" "$H/.local/share/claude" "$H/.superclawd/config.json" "$H/.gitconfig" "$H/.config/git"
  "$H/.config/gh" "$H/.ssh" "$H/.cache/ms-playwright")
if [[ "${node:-}" == "$H"/* ]]; then ro=("$(dirname "$(dirname "$node")")" "${ro[@]}"); fi
for x in $extra_ro; do ro+=("${x/#\~/$H}"); done
for p in "${ro[@]}"; do a+=(--ro-bind-try "$p" "$p"); done
a+=(--bind "$cwd" "$cwd" --chdir "$cwd")

env -i HOME="$H" USER="$USER" LANG="${LANG:-C.UTF-8}" TMPDIR=/tmp \
  PATH="$H/.local/bin:${file_path:-${unit_path:-/usr/local/bin:/usr/bin:/bin}}" \
  bwrap "${a[@]}" -- "$@"
