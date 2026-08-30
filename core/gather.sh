#!/usr/bin/env bash
# OpenShip — gather the raw material of a day so a model can curate it into
# Added / Modified / Removed. Universal signal is git; the inbox adds whatever
# the agent captured during the day. Usage: gather.sh <project> [repo] [date]
. "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/lib.sh"

PROJ="$1"; REPO="${2:-$PWD}"; DAY="${3:-$(openship_today)}"
LOGDIR="$OPENSHIP_LOG_DIR"

echo "PROJECT: $PROJ"
echo "DATE:    $DAY"
echo "REPO:    $REPO"
echo

echo "== captured raw notes (inbox) =="
grep "^- $DAY" "$LOGDIR/.inbox/$PROJ.md" 2>/dev/null || echo "(none)"
echo

echo "== commits today, with A/M/D files =="
if git -C "$REPO" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  out="$(git -C "$REPO" log --since="$DAY 00:00:00" --until="$DAY 23:59:59" \
        --pretty=format:'### %h — %s' --name-status 2>/dev/null)"
  [ -n "$out" ] && echo "$out" || echo "(no commits today)"
else
  echo "(not a git repo: $REPO)"
fi
echo

echo "== uncommitted changes (current state) =="
if git -C "$REPO" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git -C "$REPO" status --porcelain 2>/dev/null | head -40
  [ -z "$(git -C "$REPO" status --porcelain 2>/dev/null)" ] && echo "(clean)"
fi
exit 0
