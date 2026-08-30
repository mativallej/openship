#!/usr/bin/env bash
# OpenShip — read the curated ship log. Prints the "## <date>" sections newer
# than a cutoff. Usage:
#   read.sh                     all projects, last OPENSHIP_BRIEFING_DAYS days
#   read.sh <project>           that project, last 7 days
#   read.sh <project> <days>    N-day window
#   read.sh <project> all       full history
#   read.sh all <days|all>
. "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/lib.sh"

PROJ="${1:-all}"; DAYS="${2:-7}"
LOGDIR="$OPENSHIP_LOG_DIR"
[ -d "$LOGDIR" ] || { echo "(no ship log yet)"; exit 0; }

if [ "$DAYS" = "all" ]; then
  CUT="0000-00-00"
else
  CUT="$(date -v-"${DAYS}"d +%Y-%m-%d 2>/dev/null)"
  [ -z "$CUT" ] && CUT="$(date -d "-${DAYS} days" +%Y-%m-%d 2>/dev/null)"
fi

extract() { awk -v c="$CUT" '
  /^## [0-9]{4}-[0-9]{2}-[0-9]{2}/ { keep = (substr($0,4,10) >= c) }
  /^# / && $0 !~ /^## / { next }
  keep { print }
'; }

emit() {
  local f="$1" out
  [ -f "$f" ] || return 0
  out="$(extract < "$f")"
  [ -n "$out" ] && printf '# %s\n%s\n\n' "$(basename "$f" .md)" "$out"
}

if [ "$PROJ" != "all" ]; then
  emit "$LOGDIR/$PROJ.md"
else
  for f in "$LOGDIR"/*.md; do
    [ -e "$f" ] || continue
    [ "$(basename "$f")" = "ideas.md" ] && continue   # ideas are not a changelog
    emit "$f"
  done
fi
