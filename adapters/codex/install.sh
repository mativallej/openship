#!/usr/bin/env bash
# OpenShip — Codex adapter installer. Registers the notify program in
# ~/.codex/config.toml (only if there's no 'notify' key yet) and points you at
# the AGENTS.md snippet for ship-log curation.
HERE="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
CFG="$HOME/.codex/config.toml"
NOTIFY="$HERE/notify.sh"
mkdir -p "$HOME/.codex" 2>/dev/null
[ -f "$CFG" ] || : > "$CFG"

if grep -q "$NOTIFY" "$CFG" 2>/dev/null; then
  echo "  ✓ Codex notify already configured"
elif grep -qE '^[[:space:]]*notify[[:space:]]*=' "$CFG" 2>/dev/null; then
  echo "  ℹ ~/.codex/config.toml already has a 'notify' key — add OpenShip manually:"
  echo "      notify = [\"$NOTIFY\"]"
else
  printf '\nnotify = ["%s"]\n' "$NOTIFY" >> "$CFG"
  echo "  ✓ added notify program to $CFG"
fi
echo "  ℹ For ship-log curation in Codex, append the snippet from:"
echo "      $HERE/AGENTS.md.snippet"
echo "    to your project's AGENTS.md (or ~/.codex/AGENTS.md)."
