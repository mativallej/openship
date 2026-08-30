#!/usr/bin/env bash
# OpenShip — insert or replace the "## <date>" section in <project>.md, keeping
# the newest section on top. The section body (the "### Added" lines and their
# bullets) comes on stdin. Usage: cat body | upsert.sh <project> <date YYYY-MM-DD>
. "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/lib.sh"

PROJ="$1"; DATE="$2"
[ -n "$PROJ" ] && [ -n "$DATE" ] || { echo "usage: upsert.sh <project> <date>"; exit 1; }

LOGDIR="$OPENSHIP_LOG_DIR"; mkdir -p "$LOGDIR" 2>/dev/null
F="$LOGDIR/$PROJ.md"
BODY="$(cat)"

# everything except the old title and the same-date section
REST=""
if [ -f "$F" ]; then
  REST="$(awk -v date="$DATE" '
    /^# / && $0 !~ /^## / { next }
    /^## [0-9]{4}-[0-9]{2}-[0-9]{2}/ { skip = (substr($0,4,10)==date) ? 1 : 0 }
    !skip { print }
  ' "$F" | awk 'NF{f=1} f')"
fi

{
  printf '# Ship Log — %s\n\n' "$PROJ"
  printf '## %s\n%s\n' "$DATE" "$BODY"
  [ -n "$REST" ] && { printf '\n'; printf '%s\n' "$REST"; }
} > "$F"

echo "updated: $F  (section ## $DATE)"
