#!/usr/bin/env bash
# OpenShip — send a notification. Cross-platform best-effort: macOS
# (terminal-notifier or osascript), Linux (notify-send), plus phone push (ntfy).
# Usage: notify.sh <done|input> <title> <subtitle> <message>
. "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/lib.sh"

KIND="${1:-done}"; TITLE="${2:-OpenShip}"; SUBTITLE="${3:-}"; MESSAGE="${4:-}"

case "$KIND" in
  input) SOUND="$OPENSHIP_SOUND_INPUT"; TAG="hourglass_flowing_sand"; PRIO="high" ;;
  *)     SOUND="$OPENSHIP_SOUND_DONE";  TAG="white_check_mark";       PRIO="default" ;;
esac

# --- desktop banner ---
if command -v terminal-notifier >/dev/null 2>&1; then
  terminal-notifier -title "$TITLE" -subtitle "$SUBTITLE" -message "$MESSAGE" >/dev/null 2>&1
elif command -v osascript >/dev/null 2>&1; then
  osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\" subtitle \"$SUBTITLE\"" >/dev/null 2>&1
elif command -v notify-send >/dev/null 2>&1; then
  notify-send "${TITLE}${SUBTITLE:+ — $SUBTITLE}" "$MESSAGE" >/dev/null 2>&1
fi

# --- sound (fire-and-forget) ---
if [ -n "$SOUND" ] && [ -f "$SOUND" ]; then
  if command -v afplay >/dev/null 2>&1; then afplay "$SOUND" >/dev/null 2>&1 &
  elif command -v paplay >/dev/null 2>&1; then paplay "$SOUND" >/dev/null 2>&1 &
  elif command -v aplay >/dev/null 2>&1; then aplay "$SOUND" >/dev/null 2>&1 &
  fi
fi

# --- phone push (ntfy) ---
if [ -n "$OPENSHIP_NTFY_TOPIC" ] && command -v curl >/dev/null 2>&1; then
  curl -s --max-time 5 \
    -H "Title: $TITLE" \
    -H "Tags: $TAG" \
    -H "Priority: $PRIO" \
    -d "${SUBTITLE:+$SUBTITLE — }$MESSAGE" \
    "https://ntfy.sh/$OPENSHIP_NTFY_TOPIC" >/dev/null 2>&1
fi
exit 0
