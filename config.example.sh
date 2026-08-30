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

# Optional ASCII banner shown at the top of the session briefing (path to a
# text file). Leave empty for no banner.
OPENSHIP_BANNER=""

# How many days back the session briefing shows from the ship log.
OPENSHIP_BRIEFING_DAYS=7
