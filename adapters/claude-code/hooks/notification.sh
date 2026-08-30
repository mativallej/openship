#!/usr/bin/env bash
# OpenShip — Claude Code Notification hook: ping when Claude needs your input.
CORE="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../../../core" && pwd)"
. "$CORE/lib.sh"
INPUT="$(cat 2>/dev/null)"
MSG="$(printf '%s' "$INPUT" | jq -r '.message // empty' 2>/dev/null)"
[ -z "$MSG" ] && MSG="Claude is waiting for you"
PROJECT="$(openship_project "$PWD")"
"$CORE/notify.sh" input "⏳ Needs you · $PROJECT" "" "$(printf '%s' "$MSG" | openship_clean)"
printf '{}\n'
