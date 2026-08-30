#!/usr/bin/env bash
# OpenShip — save a project's prose summary (shown in the session briefing as
# "Summary"). Body comes on stdin. Usage: printf '%s' "$TEXT" | summary.sh <project>
. "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/lib.sh"

PROJ="$1"; [ -n "$PROJ" ] || { echo "usage: summary.sh <project>"; exit 1; }
mkdir -p "$OPENSHIP_LOG_DIR/.summary" 2>/dev/null
cat > "$OPENSHIP_LOG_DIR/.summary/$PROJ.md"
echo "summary updated: $OPENSHIP_LOG_DIR/.summary/$PROJ.md"
