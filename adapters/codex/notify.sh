#!/usr/bin/env bash
# OpenShip — Codex notify program. Codex invokes it with a single JSON argument
# describing the event. On a completed turn we capture the summary to the
# ship-log inbox and send a notification. Configure in ~/.codex/config.toml:
#   notify = ["/absolute/path/to/openship/adapters/codex/notify.sh"]
CORE="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../../core" && pwd)"
. "$CORE/lib.sh"

JSON="${1:-}"
[ -n "$JSON" ] || exit 0
TYPE="$(printf '%s' "$JSON" | jq -r '.type // empty' 2>/dev/null)"
MSG="$(printf '%s' "$JSON" | jq -r '."last-assistant-message" // .message // empty' 2>/dev/null)"
PROJECT="$(openship_project "$PWD")"

case "$TYPE" in
  agent-turn-complete|turn-complete)
    MSG="$(printf '%s' "$MSG" | openship_clean)"
    [ -n "$MSG" ] && "$CORE/capture.sh" "$PROJECT" "$MSG"
    "$CORE/notify.sh" done "✅ Done · $PROJECT" "$MSG" "Finished the task"
    ;;
  *) : ;;
esac
exit 0
