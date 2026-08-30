#!/usr/bin/env bash
# OpenShip — Claude Code UserPromptSubmit hook: mark the turn start so the Stop
# hook can silence short tasks (duration gate).
S="$(cat 2>/dev/null | jq -r '.session_id // "default"' 2>/dev/null)"
[ -z "$S" ] && S="default"
date +%s > "/tmp/openship-turn-$S" 2>/dev/null
printf '{}\n'
