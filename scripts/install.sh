#!/usr/bin/env bash
# Install the FDA profile into a work directory.
#   scripts/install.sh <destination>
#   e.g. scripts/install.sh ~/work/jim
# Copies profile/ (empty repos/, worktrees/, .files/), never overwrites an existing folder.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

[ $# -eq 1 ] || { echo "usage: $(basename "$0") <destination>" >&2; exit 2; }
dest="${1/#\~/$HOME}"

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

cp -R "$here/profile" "$dest"
# Client content starts empty: drop the placeholders that keep the folders in git.
find "$dest" -name .gitkeep -delete
chmod 700 "$dest"

echo "Installed the FDA profile in $dest"
echo "Next: fill in $dest/CONTEXT.md and $dest/REPOS.md, create the FDA's agent in the SuperClawd App,"
echo "then set the FDA's working directory to $dest."
