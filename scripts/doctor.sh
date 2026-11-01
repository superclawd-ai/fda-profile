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
  "$deps/package-lock.json" "$deps/doctor.sh" "$here/scripts/install-deps.sh" | sha256sum | cut -c1-12)
if [ "$have" = "$want" ]; then
  echo "ok: the installed tools match deps/ ($have)"
else
  echo "out of date: installed '${have:-nothing}', deps/ is $want. Run scripts/install-deps.sh"
fi

"$here/scripts/sandbox-exec.sh" -- /opt/fda-tools/bin/fda-doctor "$@"
rc=$?
df -h / | tail -1 | awk '{print "disk free: " $4}'
free -h | awk '/Mem/ {print "memory available: " $7}'
swapon --show | grep -q . || echo "note: no swap (Chromium, LibreOffice and parallel requests share the RAM)"
exit $rc
