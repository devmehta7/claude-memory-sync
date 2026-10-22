#!/bin/bash
# Commit and push memory changes. Run by Claude Code hooks at session start and end.
{
  cd "$(dirname "$0")" || exit 0
  git add -A
  git diff --cached --quiet || git commit -q -m "sync memory $(date '+%Y-%m-%d %H:%M')"
  git rev-parse -q --verify '@{u}' >/dev/null || exit 0   # no remote yet
  [ -n "$(git log '@{u}..' --oneline)" ] && git push -q
} >> "$HOME/.claude/memory-sync.log" 2>&1
exit 0
