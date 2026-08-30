#!/usr/bin/env bash
# OpenShip — append a raw ship-log entry to a project's inbox (agent-agnostic).
# Any driver can call this — a Claude Code hook, a Codex notify program, the CLI,
# or you by hand. The curator turns the inbox into Added/Modified/Removed later.
# Usage: capture.sh <project> <text...>
. "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/lib.sh"

PROJ="$1"; shift 2>/dev/null || true; TEXT="$*"
[ -n "$PROJ" ] && [ -n "$TEXT" ] || { echo "usage: capture.sh <project> <text>"; exit 1; }
TEXT="$(printf '%s' "$TEXT" | openship_clean)"

INBOX="$OPENSHIP_LOG_DIR/.inbox"; mkdir -p "$INBOX" 2>/dev/null
F="$INBOX/$PROJ.md"
# dedup: don't repeat the same note in the file
grep -qF "— $TEXT" "$F" 2>/dev/null || \
  printf -- '- %s %s — %s\n' "$(openship_today)" "$(date +%H:%M)" "$TEXT" >> "$F"
