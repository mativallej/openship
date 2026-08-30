#!/usr/bin/env bash
# OpenShip — capture or list ideas. Ideas are spontaneous (unlike ship-log
# entries, which bind to work events), so they are captured explicitly and
# tagged with the current project. Usage:
#   idea.sh "an idea"        capture it
#   idea.sh --list [n]       list the last n ideas (default 15)
. "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/lib.sh"

IDEAS="$OPENSHIP_LOG_DIR/ideas.md"

if [ "$1" = "--list" ] || [ "$1" = "-l" ]; then
  N="${2:-15}"
  [ -f "$IDEAS" ] || { echo "(no ideas yet)"; exit 0; }
  grep '^- ' "$IDEAS" | tail -"$N"
  exit 0
fi

TEXT="$*"
[ -n "$TEXT" ] || { echo 'usage: idea.sh "your idea"  |  idea.sh --list [n]'; exit 1; }
TEXT="$(printf '%s' "$TEXT" | openship_clean)"
PROJ="$(openship_project)"

mkdir -p "$OPENSHIP_LOG_DIR" 2>/dev/null
[ -f "$IDEAS" ] || printf '# Ideas\n\n' > "$IDEAS"
printf -- '- %s %s — %s _(%s)_\n' "$(openship_today)" "$(date +%H:%M)" "$TEXT" "$PROJ" >> "$IDEAS"
echo "idea saved to $IDEAS"
