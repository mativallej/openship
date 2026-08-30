#!/usr/bin/env bash
# OpenShip — shared library: config loading + helpers. Sourced by every core
# script. Agent-agnostic: pure shell + git + markdown, no assumptions about
# which AI tool (Claude Code, Codex, ...) is driving.

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

# Repo root, resolved from this file's location.
_OPENSHIP_LIB="${BASH_SOURCE[0]:-$0}"
OPENSHIP_HOME="$(cd "$(dirname "$_OPENSHIP_LIB")/.." && pwd)"
export OPENSHIP_HOME

# Load config: first that exists wins — explicit > user > repo default.
for _c in "${OPENSHIP_CONFIG:-}" "$HOME/.config/openship/config.sh" "$OPENSHIP_HOME/config.sh"; do
  if [ -n "$_c" ] && [ -f "$_c" ]; then . "$_c"; break; fi
done

# Defaults (only set if the config didn't).
: "${OPENSHIP_LOG_DIR:=$HOME/.openship}"
: "${OPENSHIP_MIN_SECONDS:=60}"
: "${OPENSHIP_NTFY_TOPIC:=}"
: "${OPENSHIP_SOUND_DONE:=/System/Library/Sounds/Glass.aiff}"
: "${OPENSHIP_SOUND_INPUT:=/System/Library/Sounds/Funk.aiff}"
: "${OPENSHIP_BANNER:=}"
: "${OPENSHIP_BRIEFING_DAYS:=7}"
: "${OPENSHIP_NAME:=}"
: "${OPENSHIP_USER:=}"
export OPENSHIP_LOG_DIR OPENSHIP_MIN_SECONDS OPENSHIP_NTFY_TOPIC \
       OPENSHIP_SOUND_DONE OPENSHIP_SOUND_INPUT OPENSHIP_BANNER OPENSHIP_BRIEFING_DAYS \
       OPENSHIP_NAME OPENSHIP_USER

# Stable project name across git worktrees. The identity is the MAIN worktree's
# folder name (derived from the shared git dir), so every worktree/branch of a
# repo writes to the same log. Override with OPENSHIP_PROJECT, or fall back to
# the cwd basename when not in a git repo.
openship_project() {
  local cwd="${1:-$PWD}" common root
  if [ -n "${OPENSHIP_PROJECT:-}" ]; then printf '%s\n' "$OPENSHIP_PROJECT"; return 0; fi
  common="$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)"
  if [ -z "$common" ]; then
    common="$(git -C "$cwd" rev-parse --git-common-dir 2>/dev/null)"
    [ -n "$common" ] && common="$(cd "$cwd" 2>/dev/null && cd "$common" 2>/dev/null && pwd)"
  fi
  if [ -n "$common" ]; then
    root="$(dirname "$common")"
    # per-repo override: a `.openship` file at the repo root names the project
    # (handy when the folder name isn't what you call the project).
    if [ -f "$root/.openship" ]; then
      local n; n="$(head -1 "$root/.openship" 2>/dev/null | tr -d '[:space:]')"
      [ -n "$n" ] && { printf '%s\n' "$n"; return 0; }
    fi
    basename "$root"
  else
    basename "$cwd"
  fi
}

# Collapse to a single trimmed line, capped length.
openship_clean() { tr '\n' ' ' | tr -s ' ' | sed 's/^ *//;s/ *$//' | cut -c1-200; }

# Today's date, override with OPENSHIP_DATE (handy for tests).
openship_today() { printf '%s\n' "${OPENSHIP_DATE:-$(date +%Y-%m-%d)}"; }
