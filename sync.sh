#!/bin/bash
# Commit and push memory changes. Run by Claude Code hooks at session start and end.
# If changes still haven't reached the remote, prints a warning for Claude Code to show.
cd "$(dirname "$0")" || exit 0
{
  git add -A
  git diff --cached --quiet || git commit -q -m "sync memory $(date '+%Y-%m-%d %H:%M')"
  git rev-parse -q --verify '@{u}' && [ -n "$(git log '@{u}..' --oneline)" ] && git push -q
} >> "$HOME/.claude/memory-sync.log" 2>&1

if ! git rev-parse -q --verify '@{u}' >/dev/null; then
  msg="no remote set, so memory is only committed locally"
elif [ "$(git rev-list --count '@{u}..')" -gt 0 ]; then
  msg="push failed, see ~/.claude/memory-sync.log"
else
  exit 0
fi
printf '{"systemMessage": "claude-memory-sync: %s"}\n' "$msg"
