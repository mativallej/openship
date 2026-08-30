#!/usr/bin/env bash
# OpenShip — Claude Code Stop hook: capture the finished task to the ship-log
# inbox and, past the duration gate, notify. The Claude-specific bit is reading
# the aiTitle from the transcript; everything else is core (agent-agnostic).
CORE="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../../../core" && pwd)"
. "$CORE/lib.sh"

INPUT="$(cat 2>/dev/null)"
SID="$(printf '%s' "$INPUT" | jq -r '.session_id // "default"' 2>/dev/null)"
TRANSCRIPT="$(printf '%s' "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null)"
PROJECT="$(openship_project "$PWD")"

TASK=""
if [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ]; then
  TASK="$(jq -r 'select(.type=="ai-title") | .aiTitle' "$TRANSCRIPT" 2>/dev/null | tail -1)"
fi
[ -z "$TASK" ] && { printf '{}\n'; exit 0; }   # nothing meaningful to log
TASK="$(printf '%s' "$TASK" | openship_clean)"

# duration gate: skip short turns (start marked by user-prompt-submit.sh)
STARTFILE="/tmp/openship-turn-$SID"
if [ -f "$STARTFILE" ]; then
  START="$(cat "$STARTFILE" 2>/dev/null)"; rm -f "$STARTFILE" 2>/dev/null
  if [ -n "$START" ] && [ "$(( $(date +%s) - START ))" -lt "$OPENSHIP_MIN_SECONDS" ]; then
    printf '{}\n'; exit 0
  fi
fi

"$CORE/capture.sh" "$PROJECT" "$TASK"
"$CORE/notify.sh" done "✅ Done · $PROJECT" "$TASK" "Finished the task"
printf '{}\n'
