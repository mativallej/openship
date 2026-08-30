#!/usr/bin/env bash
# OpenShip — "welcome back" briefing for a project: branch, uncommitted count,
# recent commits, last captured task, the last N days of the ship log, the prose
# summary, and recent ideas. Prints plain text; an agent adapter wraps it (e.g.
# a Claude Code SessionStart hook emits it as a systemMessage). Usage:
#   briefing.sh [cwd]
. "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/lib.sh"

CWD="${1:-$PWD}"; cd "$CWD" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

PROJECT="$(openship_project "$CWD")"
BRANCH="$(git branch --show-current 2>/dev/null)"
DIRTY="$(git status --porcelain 2>/dev/null | grep -c . | tr -d ' ')"
COMMITS="$(git log --oneline -3 2>/dev/null | sed 's/^/       • /')"
LOGDIR="$OPENSHIP_LOG_DIR"

# banner: explicit file > figlet("@user") > plain "@user" > none
BANNER_TXT=""
if [ -n "$OPENSHIP_BANNER" ] && [ -f "$OPENSHIP_BANNER" ]; then
  BANNER_TXT="$(cat "$OPENSHIP_BANNER")"
elif [ -n "$OPENSHIP_USER" ]; then
  command -v figlet >/dev/null 2>&1 && BANNER_TXT="$(figlet -f small "@$OPENSHIP_USER" 2>/dev/null)"
  [ -z "$BANNER_TXT" ] && BANNER_TXT="@$OPENSHIP_USER"
fi
# greeting: title "Welcome back, NAME" + subtitle "@user · project"
if [ -n "$OPENSHIP_NAME" ]; then
  HEADER="👋 Welcome back, ${OPENSHIP_NAME}"$'\n'"   ${OPENSHIP_USER:+@$OPENSHIP_USER · }${PROJECT}"
else
  HEADER="👋 ${PROJECT}"
fi
if [ -n "$BANNER_TXT" ]; then
  B=$'\n'"$BANNER_TXT"$'\n\n'"$HEADER"
else
  B="$HEADER"
fi
B="$B"$'\n'"   🌿 Branch: ${BRANCH:-?}  ·  Uncommitted: ${DIRTY:-0} file(s)"

# last task = most recent inbox note (agent-agnostic)
LASTTASK="$(grep '^- ' "$LOGDIR/.inbox/$PROJECT.md" 2>/dev/null | tail -1 | sed -E 's/^- [0-9-]+ [0-9:]+ — //')"
[ -n "$LASTTASK" ] && B="$B"$'\n'"   🎯 Last: ${LASTTASK}"

[ -n "$COMMITS" ] && B="$B"$'\n'"   📝 Recent commits:"$'\n'"$COMMITS"

WEEK="$("$OPENSHIP_HOME/core/read.sh" "$PROJECT" "$OPENSHIP_BRIEFING_DAYS" 2>/dev/null | grep -vE '^# ' \
  | sed -E 's/^## (.*)/\1/; s/^### (.*)/  \1:/; s/^- /    • /' | sed '/^[[:space:]]*$/d')"
[ -n "$WEEK" ] && B="$B"$'\n'"   📅 Last ${OPENSHIP_BRIEFING_DAYS} days"$'\n'"$(printf '%s' "$WEEK" | head -16 | sed 's/^/   /')"

SUMMARY="$(cat "$LOGDIR/.summary/$PROJECT.md" 2>/dev/null)"
[ -n "$SUMMARY" ] && B="$B"$'\n'"   📋 Summary"$'\n'"$(printf '%s' "$SUMMARY" | fold -s -w 74 | sed 's/^/   /')"

IDEAS="$("$OPENSHIP_HOME/core/idea.sh" --list 3 2>/dev/null | grep '^- ' | sed -E 's/^- /    • /')"
[ -n "$IDEAS" ] && B="$B"$'\n'"   💡 Recent ideas"$'\n'"$IDEAS"

printf '%s\n' "$B"
