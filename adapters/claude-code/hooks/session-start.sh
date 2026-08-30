#!/usr/bin/env bash
# OpenShip — Claude Code SessionStart hook: emit the welcome-back briefing as a
# systemMessage. Wired for matcher "startup|resume".
CORE="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../../../core" && pwd)"
INPUT="$(cat 2>/dev/null)"
CWD="$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)"
[ -z "$CWD" ] && CWD="$PWD"
MSG="$("$CORE/briefing.sh" "$CWD" 2>/dev/null)"
if [ -n "$MSG" ]; then jq -n --arg m "$MSG" '{systemMessage:$m}'; else printf '{}\n'; fi
