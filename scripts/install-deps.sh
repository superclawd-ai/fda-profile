#!/usr/bin/env bash
# Install the tools the FDA's skills need: apt packages, plus /opt/fda-tools (a pinned Python with the
# skills' packages, headless Chromium, Mermaid, wrappers and fda-doctor). Everything lands where an
# agent turn can use it: the FDA's sandbox shows /usr and /opt read-only and nothing can be installed
# during a turn.
#
#   scripts/install-deps.sh
#
# Run it on the FDA's machine as the FDA's user (it calls sudo; use a terminal if sudo asks for a
# password). Once per machine, and again after anything in deps/ changes. Safe to re-run, also while the
# FDA is working: each set of tools is built in its own folder and switched in at the end.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
deps="$here/deps"
PREFIX=/opt/fda-tools
CACHE=/var/cache/fda-tools

log() { printf '\n==> %s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

[ $# -eq 0 ] || die "usage: $(basename "$0") (no options)"
[ "$(id -u)" -ne 0 ] || die "run as the FDA's user, not root (the script calls sudo itself)"
. /etc/os-release
case "$VERSION_ID" in 24.04 | 26.04) ;; *) warn "untested Ubuntu $VERSION_ID" ;; esac
# shellcheck source=/dev/null
. "$deps/versions.env"

manifest_hash() {
  cat "$deps/versions.env" "$deps/apt.txt" "$deps/requirements.lock" "$deps/package.json" \
    "$deps/package-lock.json" "$deps/doctor.sh" | sha256sum | cut -c1-12
}
hash="$(manifest_hash)"
rel="$PREFIX/releases/$hash"
# Passwordless sudo works without a terminal; otherwise ask for the password once.
sudo -n true 2>/dev/null || sudo -v || die "sudo is required (apt and /opt)"

log "apt packages"
mapfile -t pkgs < <(awk -v rel="@$VERSION_ID" '
  { sub(/#.*/, "") } NF == 0 { next }
  { ok = 1; for (i = 2; i <= NF; i++) if ($i ~ /^@[0-9]/ && $i != rel) ok = 0 }
  ok { print $1 }' "$deps/apt.txt")
sudo apt-get update -qq
missing=()
for p in "${pkgs[@]}"; do apt-cache show "$p" >/dev/null 2>&1 || missing+=("$p"); done
[ ${#missing[@]} -eq 0 ] || die "not available on Ubuntu $VERSION_ID: ${missing[*]} (fix deps/apt.txt)"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends "${pkgs[@]}" >/dev/null
log "font cache (system-wide, so turns don't rebuild it)"
sudo fc-cache -f >/dev/null

# Swap: FDA machines have little RAM (8 GB) and Chromium, LibreOffice and parallel requests share it.
# Without swap one heavy request can get processes killed. Created once (4 GB), kept across reboots.
log "swap"
if swapon --show --noheadings | grep -q .; then
  echo "swap already on: $(swapon --show --noheadings --bytes | awk '{s+=$3} END {printf "%.0f GB", s/1024/1024/1024}')"
else
  [ -e /swapfile ] || { sudo fallocate -l 4G /swapfile || sudo dd if=/dev/zero of=/swapfile bs=1M count=4096 status=none; }
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile >/dev/null
  sudo swapon /swapfile
  echo "created a 4 GB swapfile"
fi
if [ -f /swapfile ] && ! grep -q '^/swapfile ' /etc/fstab; then
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab >/dev/null
  echo "swapfile added to /etc/fstab (kept after reboots)"
fi
# Keep work in RAM and use swap only under real memory pressure (Ubuntu's default, 60, swaps early).
if [ "$(cat /proc/sys/vm/swappiness)" != 10 ] || [ ! -f /etc/sysctl.d/99-fda-swap.conf ]; then
  echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-fda-swap.conf >/dev/null
  sudo sysctl -q -p /etc/sysctl.d/99-fda-swap.conf
  echo "swap used only under memory pressure (vm.swappiness=10)"
fi

log "uv $UV_VERSION"
arch=$(uname -m)
case $arch in
  x86_64) sum=$UV_SHA256_X86_64 ;;
  aarch64) sum=$UV_SHA256_AARCH64 ;;
  *) die "unsupported architecture $arch" ;;
esac
UV="$PREFIX/uv/bin/uv"
if [ "$("$UV" --version 2>/dev/null | awk '{print $2}')" != "$UV_VERSION" ]; then
  t=$(mktemp -d)
  f="uv-$arch-unknown-linux-gnu.tar.gz"
  curl -fsSL -o "$t/$f" "https://github.com/astral-sh/uv/releases/download/$UV_VERSION/$f"
  echo "$sum  $t/$f" | sha256sum -c - >/dev/null || die "uv checksum mismatch"
  tar -xzf "$t/$f" -C "$t"
  sudo install -D -m 755 "$t/uv-$arch-unknown-linux-gnu/uv" "$UV"
  rm -rf "$t"
fi

# The FDA daemon's node (nvm or /usr): from its systemd unit, else PATH, else the newest nvm node.
node=$(systemctl show -p ExecStart --value superclawd-fda 2>/dev/null | sed -n 's/.*path=\([^ ;]*\).*/\1/p')
[ -x "${node:-}" ] || node=$(command -v node || true)
[ -x "${node:-}" ] || node=$(ls -d "$HOME"/.nvm/versions/node/*/bin/node 2>/dev/null | sort -V | tail -1)
[ -x "${node:-}" ] || die "no node found (install the FDA first)"
nodebin=$(dirname "$node")
log "node $("$node" -v) at $nodebin"

if [ -f "$rel/.complete" ]; then
  log "tools $hash already built"
else
  log "building tools $hash"
  sudo rm -rf "$rel"
  sudo install -d -m 755 "$rel/bin" "$rel/share/doctor" "$rel/node" "$CACHE"
  uvenv=(env UV_PYTHON_INSTALL_DIR="$PREFIX/python" UV_CACHE_DIR="$CACHE/uv" UV_LINK_MODE=copy)
  sudo "${uvenv[@]}" "$UV" venv -q --python "$PYTHON_VERSION" --python-preference only-managed "$rel/venv"
  sudo "${uvenv[@]}" "$UV" pip sync -q --python "$rel/venv/bin/python" --require-hashes "$deps/requirements.lock"

  log "headless Chromium (and the libraries it needs)"
  sudo env PLAYWRIGHT_BROWSERS_PATH="$PREFIX/ms-playwright" "$rel/venv/bin/python" -m playwright install \
    --with-deps --only-shell chromium >/dev/null
  shell=$(ls -d "$PREFIX"/ms-playwright/chromium_headless_shell-*/chrome-*/chrome-headless-shell | sort -V | tail -1)
  [ -x "$shell" ] || die "chromium headless shell not found after install"

  log "npm tools"
  sudo cp "$deps/package.json" "$deps/package-lock.json" "$rel/node/"
  # Public registry only, ignoring any .npmrc on this machine (tokens, private scopes).
  npmrc=$(mktemp) npmrc_global=$(mktemp)
  # Retries: package downloads can be slow or reset on small VPSes.
  for attempt in 1 2 3; do
    if sudo env PATH="$nodebin:/usr/bin:/bin" PUPPETEER_SKIP_DOWNLOAD=1 npm_config_cache="$CACHE/npm" \
      npm_config_userconfig="$npmrc" npm_config_globalconfig="$npmrc_global" \
      npm_config_registry=https://registry.npmjs.org/ npm_config_fetch_retries=5 npm_config_fetch_timeout=120000 \
      "$nodebin/npm" ci --prefix "$rel/node" --omit=dev --no-audit --no-fund --loglevel=error >/dev/null; then
      break
    fi
    [ "$attempt" -lt 3 ] || die "npm install failed 3 times (network?); re-run the script"
    warn "npm install failed (attempt $attempt); retrying"
    sleep 10
  done
  rm -f "$npmrc" "$npmrc_global"

  log "wrappers"
  # Chrome's own sandbox can't start inside the FDA's sandbox (Ubuntu restricts user namespaces):
  # --no-sandbox; the FDA's sandbox is the isolation.
  printf '{"executablePath":"%s","headless":"shell","args":["--no-sandbox","--disable-gpu"]}\n' "$shell" |
    sudo tee "$rel/puppeteer.json" >/dev/null
  wrapper() { sudo tee "$rel/bin/$1" >/dev/null && sudo chmod 755 "$rel/bin/$1"; }
  # Caches go to the request's /tmp, not the sandbox's in-memory $HOME.
  caches='export XDG_CACHE_HOME="${TMPDIR:-/tmp}/.cache" XDG_CONFIG_HOME="${TMPDIR:-/tmp}/.config" MPLCONFIGDIR="${TMPDIR:-/tmp}/.mpl"'
  wrapper python <<EOF
#!/bin/sh
$caches
export PLAYWRIGHT_BROWSERS_PATH=$PREFIX/ms-playwright MPLBACKEND=Agg PYTHONNOUSERSITE=1
exec $rel/venv/bin/python "\$@"
EOF
  # Chrome logs harmless D-Bus/GPU noise (no desktop session in the sandbox): filter those lines out.
  wrapper chrome <<EOF
#!/bin/bash
$caches
export DBUS_SESSION_BUS_ADDRESS=disabled:
exec $shell --headless --no-sandbox --disable-gpu --hide-scrollbars --log-level=3 "\$@" \
  2> >(grep -vE 'dbus/|vaapi_wrapper|InitializeSandbox|Fontconfig' >&2)
EOF
  wrapper mmdc <<EOF
#!/bin/sh
$caches
PATH="$nodebin:\$PATH"
exec $rel/node/node_modules/.bin/mmdc -p $rel/puppeteer.json "\$@"
EOF
  wrapper im <<'EOF'
#!/bin/sh
if command -v magick >/dev/null; then exec magick "$@"; else exec convert "$@"; fi
EOF
  wrapper soffice <<'EOF'
#!/bin/sh
# LibreOffice needs a writable profile: one per call, in the request's /tmp. The profile is seeded to
# always recalculate formulas when loading Excel/ODF files (by default it keeps the stored, often stale,
# values), so converting a spreadsheet gives the real numbers.
prof="${TMPDIR:-/tmp}/lo-profile-$$"
mkdir -p "$prof/user"
cat >"$prof/user/registrymodifications.xcu" <<'XCU'
<?xml version="1.0" encoding="UTF-8"?>
<oor:items xmlns:oor="http://openoffice.org/2001/registry" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<item oor:path="/org.openoffice.Office.Calc/Formula/Load"><prop oor:name="OOXMLRecalcMode" oor:op="fuse"><value>0</value></prop></item>
<item oor:path="/org.openoffice.Office.Calc/Formula/Load"><prop oor:name="ODFRecalcMode" oor:op="fuse"><value>0</value></prop></item>
</oor:items>
XCU
soffice -env:UserInstallation="file://$prof" --headless --norestore "$@"
rc=$?
rm -rf "$prof"
exit $rc
EOF
  sudo install -m 755 "$deps/doctor.sh" "$rel/bin/fda-doctor"

  log "doctor fixtures"
  sudo "$rel/bin/python" - "$rel/share/doctor" <<'PY'
import sys
from PIL import Image, ImageDraw, ImageFont
from weasyprint import HTML
d = sys.argv[1]
HTML(string="<p>FDA doctor hello</p>").write_pdf(f"{d}/hello.pdf")
im = Image.new("L", (640, 140), 255)
f = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 72)
ImageDraw.Draw(im).text((20, 25), "FDA 4217", font=f, fill=0)
im.save(f"{d}/ocr.png")
PY
  printf 'hash=%s\nbuilt=%s\nubuntu=%s\nnode=%s\npython=%s\n' "$hash" "$(date -Is)" "$VERSION_ID" \
    "$("$node" -v)" "$("$rel/venv/bin/python" -V)" | sudo tee "$rel/MANIFEST" >/dev/null
  sudo touch "$rel/.complete"
fi

log "activate $hash"
sudo ln -sfn "releases/$hash" "$PREFIX/current.new" && sudo mv -T "$PREFIX/current.new" "$PREFIX/current"
sudo ln -sfn current/bin "$PREFIX/bin.new" && sudo mv -T "$PREFIX/bin.new" "$PREFIX/bin"
for n in python:fda-python fda-doctor:fda-doctor chrome:fda-chrome soffice:fda-soffice mmdc:fda-mmdc; do
  sudo ln -sfn "$PREFIX/bin/${n%%:*}" "/usr/local/bin/${n##*:}"
done
# Keep the previous release for a quick rollback; delete older ones.
for old in $(ls -1t "$PREFIX/releases" | tail -n +3); do
  [ "$old" = "$hash" ] || sudo rm -rf "${PREFIX:?}/releases/$old"
done
sudo chown -R root:root "$PREFIX"
log "done. Check it from inside the FDA's sandbox: scripts/doctor.sh"
