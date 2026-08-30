#!/usr/bin/env bash
# OpenShip — OpenCode adapter installer. Installs the plugin globally so it runs
# in every OpenCode session.
HERE="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
DEST="$HOME/.config/opencode/plugins"
mkdir -p "$DEST" 2>/dev/null
cp "$HERE/openship.js" "$DEST/openship.js"
echo "  ✓ installed OpenCode plugin to $DEST/openship.js"
echo "  ℹ Make sure 'openship' is on your PATH (openship init offers to symlink it)."
