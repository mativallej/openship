# OpenShip — Claude Code adapter

Wires OpenShip into Claude Code:

| Piece | Claude Code hook | What it does |
|-------|------------------|--------------|
| `hooks/session-start.sh` | `SessionStart` (startup\|resume) | emits the welcome-back **briefing** as a systemMessage |
| `hooks/stop.sh` | `Stop` | captures the finished task's `aiTitle` to the ship-log inbox + notifies (past the duration gate) |
| `hooks/notification.sh` | `Notification` | pings when Claude needs your input |
| `hooks/user-prompt-submit.sh` | `UserPromptSubmit` | marks turn start (for the duration gate) |
| `skills/ship-log` | skill | curate the day into Added/Modified/Removed |
| `commands/idea.md` | `/idea` | capture a spontaneous idea |

Install (usually via `openship init`, or directly):

```bash
bash adapters/claude-code/install.sh
```

It installs the skill + command and **merges** the hooks into
`~/.claude/settings.json` without touching your existing hooks. Re-running is safe.
