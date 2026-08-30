#!/usr/bin/env bash
# OpenShip — bootstrap. Makes the scripts executable, then runs the interactive
# setup (openship init).
HERE="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

chmod +x "$HERE/bin/openship" \
         "$HERE/core/"*.sh \
         "$HERE/adapters/claude-code/hooks/"*.sh \
         "$HERE/adapters/claude-code/install.sh" \
         "$HERE/adapters/codex/notify.sh" \
         "$HERE/adapters/codex/install.sh" 2>/dev/null

exec "$HERE/bin/openship" init
