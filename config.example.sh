# OpenShip config — copy to ~/.config/openship/config.sh and edit.
# Every value is optional; sensible defaults apply if you omit it.

# Where the log lives: the changelog <project>.md files plus .inbox/, .summary/
# and ideas.md. Point this at a folder you sync (e.g. an Obsidian vault) if you
# want your ship log to live next to your notes.
OPENSHIP_LOG_DIR="$HOME/.openship"

# Duration gate: only send a "done" notification for tasks that ran at least
# this many seconds. Keeps short turns quiet.
OPENSHIP_MIN_SECONDS=60

# ntfy.sh topic for phone push (leave empty to disable push). Pick a
# hard-to-guess topic and subscribe to it in the ntfy app on your phone.
OPENSHIP_NTFY_TOPIC=""

# Notification sounds. macOS paths shown; on Linux use a .wav/.oga path or
# leave empty to disable sound.
OPENSHIP_SOUND_DONE="/System/Library/Sounds/Glass.aiff"
OPENSHIP_SOUND_INPUT="/System/Library/Sounds/Funk.aiff"

# Your name, used for the "Welcome back, <name>" greeting (the briefing title).
# `openship init` defaults this from your git user.name.
OPENSHIP_NAME=""

# Your GitHub username / handle, shown as the briefing subtitle ("@<user> ·
# <project>"). If no banner file is set below, the briefing also renders
# "@<user>" as an ASCII banner (via figlet when available). `openship init`
# auto-detects this via `gh`.
OPENSHIP_USER=""

# Optional custom ASCII banner (path to a text file). Takes precedence over the
# auto banner from OPENSHIP_USER. Leave empty to use the handle-based one.
OPENSHIP_BANNER=""

# How many days back the session briefing shows from the ship log.
OPENSHIP_BRIEFING_DAYS=7

# Briefing verbosity: "compact" (default) shows a one-line digest of the last N
# days; "full" expands the changelog bullets and the prose summary. You can also
# force full on demand: `openship briefing --full`.
OPENSHIP_BRIEFING_DETAIL="compact"
