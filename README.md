# claude-memory-sync

Back up and sync [Claude Code](https://claude.com/claude-code) project memory with git, so it survives a
dead laptop and follows you to a new machine.

Claude Code keeps each project's memory in `~/.claude/projects/<slug>/memory/`, where `<slug>` is the
project's absolute path with `/` replaced by `-`. That folder is local only. This repo moves it into git
and leaves a symlink behind, so Claude reads and writes memory exactly as before.

| File | What it does |
|---|---|
| `projects.txt` | The projects to sync, one path per line, relative to `$HOME` |
| `link.sh` | Moves each project's memory into this repo and symlinks it back. Safe to re-run |
| `sync.sh` | Commits, pulls and pushes changes. Run by Claude Code hooks; logs to `~/.claude/memory-sync.log` |

## Setup

1. **Create your own copy as a private repo** — "Use this template" on GitHub, visibility **Private**.
   Memory holds whatever Claude learned about your projects: names, decisions, internal details.
2. Clone it to `~/claude-memory` (or anywhere — adjust the hook paths below).
3. Add your projects to `projects.txt`, close any Claude sessions in them, and run `./link.sh`.
4. Add the hooks to `~/.claude/settings.json`, merged with anything already there:

```json
{
  "hooks": {
    "SessionStart": [
      { "hooks": [{ "type": "command", "command": "$HOME/claude-memory/sync.sh", "async": true, "timeout": 60 }] }
    ],
    "SessionEnd": [
      { "hooks": [{ "type": "command", "command": "$HOME/claude-memory/sync.sh", "timeout": 30 }] }
    ]
  }
}
```

Changes are pushed when a session ends (`/exit`, Ctrl+C/D, `/clear`). If a session dies without ending
cleanly, the next session start picks the changes up.

## Add a project

Close any Claude session in it, add its path to `projects.txt`, run `./link.sh`. Works whether or not the
project has any memory yet.

## Restore on a new machine

Clone your copy and run `./link.sh`. Paths are relative to `$HOME`, so a different username is fine. If a
project now lives at a different path, update its line in `projects.txt` first.

## Limits

- Each project's memory folder is named after the project's folder, so two projects with the same folder
  name (`~/work/api` and `~/personal/api`) can't both be synced. `link.sh` stops and says so.
- If two machines edit the same memory file before syncing, the pull is aborted and the push fails —
  check the log and resolve it with git by hand.
- macOS and Linux. Needs `bash` and `git`, nothing else.
