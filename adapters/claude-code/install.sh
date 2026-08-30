#!/usr/bin/env bash
# OpenShip — Claude Code adapter installer. Installs the ship-log skill and the
# /idea command, and merges the hooks into ~/.claude/settings.json WITHOUT
# clobbering existing hooks. Idempotent.
HERE="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SETTINGS="$CLAUDE_DIR/settings.json"
HOOKS="$HERE/hooks"

command -v jq >/dev/null 2>&1 || { echo "  ✗ jq is required (brew install jq / apt install jq)"; exit 1; }
mkdir -p "$CLAUDE_DIR/skills" "$CLAUDE_DIR/commands" 2>/dev/null

# skill + slash command
rm -rf "$CLAUDE_DIR/skills/ship-log" 2>/dev/null
cp -R "$HERE/skills/ship-log" "$CLAUDE_DIR/skills/ship-log"
cp "$HERE/commands/idea.md" "$CLAUDE_DIR/commands/idea.md"
echo "  ✓ installed skill 'ship-log' and command '/idea'"

[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"

add_hook() { # add_hook <event> <matcher|""> <command>
  local event="$1" matcher="$2" cmd="$3" tmp; tmp="$(mktemp)"
  jq --arg event "$event" --arg matcher "$matcher" --arg cmd "$cmd" '
    .hooks //= {} | .hooks[$event] //= []
    | if ([.hooks[$event][].hooks[]?.command] | index($cmd)) then .
      else .hooks[$event] += [
        if $matcher == "" then {hooks:[{type:"command",command:$cmd}]}
        else {matcher:$matcher, hooks:[{type:"command",command:$cmd}]} end
      ] end
  ' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
}

add_hook SessionStart "startup|resume" "$HOOKS/session-start.sh"
add_hook Stop            ""             "$HOOKS/stop.sh"
add_hook Notification    ""             "$HOOKS/notification.sh"
add_hook UserPromptSubmit ""            "$HOOKS/user-prompt-submit.sh"
echo "  ✓ wired hooks into $SETTINGS (existing hooks preserved)"
