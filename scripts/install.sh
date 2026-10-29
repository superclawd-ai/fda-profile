#!/usr/bin/env bash
# Install an FDA profile into a work directory.
#   scripts/install.sh <profile> <destination>
#   e.g. scripts/install.sh software-engineer ~/work/jim
# Copies the profile (empty repos/, worktrees/, .files/), never overwrites an existing folder.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
  echo "usage: $(basename "$0") <profile> <destination>" >&2
  echo "profiles: $(ls "$here/profiles" | tr '\n' ' ')" >&2
  exit 2
}

[ $# -eq 2 ] || usage
profile="$1"
dest="${2/#\~/$HOME}"

[[ "$profile" =~ ^[a-z][a-z0-9-]*$ ]] || { echo "invalid profile name: $profile" >&2; usage; }
src="$here/profiles/$profile"
[ -d "$src" ] || { echo "no such profile: $profile" >&2; usage; }
if [ -e "$dest" ]; then
  echo "$dest already exists; pick a new folder (nothing was changed)" >&2
  exit 1
fi

# Resolve to an absolute path (the parent is created first) before checking where it is.
mkdir -p "$(dirname "$dest")"
dest="$(cd "$(dirname "$dest")" && pwd -P)/$(basename "$dest")"
home="$(cd "$HOME" && pwd -P)"

case "$dest" in
  "$home"/*) ;;
  *) echo "warning: $dest is outside $HOME; the FDA only accepts a working directory inside home" >&2 ;;
esac
case "${dest#"$home"/}" in
  .*|*/.*) echo "warning: $dest is inside a hidden folder; the FDA won't accept it as a working directory" >&2 ;;
esac

cp -R "$src" "$dest"
# Client content starts empty: drop the placeholders that keep the folders in git.
find "$dest" -name .gitkeep -delete
chmod 700 "$dest"

echo "Installed $profile in $dest"
echo "Next: fill in $dest/CONTEXT.md and $dest/REPOS.md, then set the FDA's working directory to $dest."
