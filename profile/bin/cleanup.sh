#!/usr/bin/env bash
# Remove finished worktrees and old scratch folders. Safe to run any time; run it at the start of every
# request. A worktree is removed only when it has nothing uncommitted AND either its branch's pull request
# is merged or closed, or it has no branch / no pull request and is older than 7 days. Removing a worktree
# never deletes its branch or commits.
set -uo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit 1
now=$(date +%s)

age_days() { # mtime age of a path in days (Linux and macOS)
  local m
  m=$(stat -c %Y "$1" 2>/dev/null || stat -f %m "$1")
  echo $(( (now - m) / 86400 ))
}

for wt in worktrees/*/; do
  [ -d "$wt" ] || continue
  wt="${wt%/}"
  name="$(basename "$wt")"
  repo="${name%%--*}"
  [ -d "repos/$repo/.git" ] || { echo "keep $name (no repos/$repo)"; continue; }
  if [ -n "$(git -C "$wt" status --porcelain 2>/dev/null)" ]; then
    echo "keep $name (uncommitted changes)"
    continue
  fi
  branch="$(git -C "$wt" symbolic-ref --quiet --short HEAD 2>/dev/null || true)"
  old=no
  [ "$(age_days "$wt")" -ge 7 ] && old=yes
  remove=no
  if [ -n "$branch" ]; then
    slug="$(git -C "repos/$repo" remote get-url origin 2>/dev/null | sed -E 's#\.git$##; s#^.*github\.com[:/]##')"
    state="$(gh pr view "$branch" -R "$slug" --json state -q .state 2>/dev/null || echo NONE)"
    case "$state" in
      MERGED|CLOSED) remove=yes ;;
      NONE) [ "$old" = yes ] && remove=yes ;;
    esac
    why="branch $branch, pull request: $state"
  else
    [ "$old" = yes ] && remove=yes
    why="detached"
  fi
  if [ "$remove" = yes ]; then
    git -C "repos/$repo" worktree remove "$root/$wt" && echo "removed $name ($why)"
  else
    echo "keep $name ($why)"
  fi
done

for r in repos/*/; do
  [ -d "$r.git" ] && git -C "$r" worktree prune
done

if [ -d .files ]; then
  find .files -mindepth 1 -maxdepth 1 -type d -mtime +30 -print -exec rm -rf {} + 2>/dev/null |
    sed 's/^/removed /'
fi
exit 0
