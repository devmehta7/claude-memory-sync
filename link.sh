#!/bin/bash
# Symlink each project's Claude Code memory dir into this repo, per projects.txt.
# Safe to re-run. On a new machine, run it once after cloning.
repo="$(cd "$(dirname "$0")" && pwd)"
entries=$(grep -v '^\s*\(#\|$\)' "$repo/projects.txt")
[ -z "$entries" ] && { echo "projects.txt has no projects yet"; exit 0; }

dups=$(echo "$entries" | while read -r p; do basename "$p"; done | sort | uniq -d)
if [ -n "$dups" ]; then
  echo "Two projects share a folder name ($dups). Each project's memory lives in a folder named after it, so rename one." >&2
  exit 1
fi

echo "$entries" | while read -r path; do
  dest="$repo/$(basename "$path")"
  src="$HOME/.claude/projects/$(echo "$HOME/$path" | tr / -)/memory"
  if [ -L "$src" ]; then
    echo "ok      $path"
    continue
  fi
  if [ -d "$src" ]; then
    if [ -e "$dest" ]; then
      echo "SKIP    $path — both $src and $dest exist; merge by hand" >&2
      continue
    fi
    mv "$src" "$dest"
  fi
  mkdir -p "$dest" "$(dirname "$src")"
  ln -s "$dest" "$src"
  echo "linked  $path"
done
