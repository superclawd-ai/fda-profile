#!/usr/bin/env bash
# Operator check: are the FDA's tools installed, current, and working from inside an agent turn's
# sandbox? Run it on the FDA's machine as the FDA's user, after scripts/install-deps.sh.
#   scripts/doctor.sh [capability...]
# It runs fda-doctor through scripts/sandbox-exec.sh, which mirrors the FDA daemon's sandbox.
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
deps="$here/deps"
H=$HOME
P=/opt/fda-tools

have=$(basename "$(readlink "$P/current" 2>/dev/null)" 2>/dev/null || true)
want=$(cat "$deps/versions.env" "$deps/apt.txt" "$deps/requirements.lock" "$deps/package.json" \
  "$deps/package-lock.json" "$deps/doctor.sh" | sha256sum | cut -c1-12)
if [ "$have" = "$want" ]; then
  echo "ok: the installed tools match deps/ ($have)"
else
  echo "out of date: installed '${have:-nothing}', deps/ is $want. Run scripts/install-deps.sh"
fi

# No keyboard input for the checks (from a terminal, ffmpeg would otherwise wait for it and hang).
"$here/scripts/sandbox-exec.sh" -- /opt/fda-tools/bin/fda-doctor "$@" </dev/null
rc=$?
df -h / | tail -1 | awk '{print "disk free: " $4}'
free -h | awk '/Mem/ {print "memory available: " $7}'
if swapon --show --noheadings | grep -q .; then
  swap=$(swapon --show --noheadings --bytes | awk '{s+=$3; u+=$4} END {printf "%.0f GB, %.1f GB in use", s/1024/1024/1024, u/1024/1024/1024}')
  persistent=$(awk '$3 == "swap" && $1 !~ /^#/' /etc/fstab | grep -q . && echo "kept after reboot" || echo "NOT in /etc/fstab: lost on reboot")
  echo "swap: $swap ($persistent; swappiness $(cat /proc/sys/vm/swappiness), 10 expected)"
  echo "      lots in use most of the time means the machine needs more RAM, not more swap"
else
  echo "swap: NONE. Run scripts/install-deps.sh (it adds 4 GB): without swap, heavy requests can get killed"
  rc=1
fi
exit $rc
