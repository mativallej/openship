#!/usr/bin/env bash
# OpenShip — hermetic smoke tests. No network, no touching your real config or
# vault: everything runs in temp dirs via OPENSHIP_CONFIG. Run: tests/run.sh
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
OS="$ROOT/bin/openship"
PASS=0; FAIL=0

ok()   { PASS=$((PASS+1)); printf '  \033[32m✓\033[0m %s\n' "$1"; }
bad()  { FAIL=$((FAIL+1)); printf '  \033[31m✗\033[0m %s\n' "$1"; [ -n "${2:-}" ] && printf '      %s\n' "$2"; }
has()  { case "$1" in *"$2"*) return 0;; *) return 1;; esac; }
assert_has()   { if has "$1" "$2"; then ok "$3"; else bad "$3" "expected to contain: $2"; fi; }
assert_eq()    { if [ "$1" = "$2" ]; then ok "$3"; else bad "$3" "got '$1' want '$2'"; fi; }

# --- sandbox ---
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
mkdir -p "$T/log"
cat > "$T/config.sh" <<EOF
OPENSHIP_LOG_DIR="$T/log"
OPENSHIP_NTFY_TOPIC=""
OPENSHIP_SOUND_DONE=""
OPENSHIP_SOUND_INPUT=""
OPENSHIP_MIN_SECONDS=0
OPENSHIP_BRIEFING_DAYS=7
OPENSHIP_NAME="Ada"
OPENSHIP_USER="ada"
EOF
export OPENSHIP_CONFIG="$T/config.sh"
DAY="$(date +%Y-%m-%d)"

printf '\n\033[1m⛵ OpenShip tests\033[0m\n\n'

# --- project detection ---
repo="$T/acme"; mkdir -p "$repo"; ( cd "$repo" && git init -q && git config user.email t@t && git config user.name t )
assert_eq "$("$OS" project "$repo")" "acme" "project = repo folder name"
printf 'Widgets\n' > "$repo/.openship"
assert_eq "$("$OS" project "$repo")" "Widgets" ".openship file overrides name"
assert_eq "$(OPENSHIP_PROJECT=Env "$OS" project "$repo")" "Env" "OPENSHIP_PROJECT env wins"

# --- capture + dedup ---
"$OS" capture demo "did a thing" >/dev/null
"$OS" capture demo "did a thing" >/dev/null   # dupe
"$OS" capture demo "did another" >/dev/null
assert_eq "$(grep -c '^- ' "$T/log/.inbox/demo.md")" "2" "capture dedups same note, keeps distinct"

# --- idea ---
"$OS" idea "a spark" >/dev/null
assert_has "$("$OS" ideas 5)" "a spark" "idea captured + listed"

# --- upsert + read ---
printf '### Added\n- alpha\n' | "$OS" upsert demo "$DAY" >/dev/null
assert_has "$("$OS" read demo all)" "alpha" "upsert writes a section, read shows it"
printf '### Added\n- beta\n' | "$OS" upsert demo "$DAY" >/dev/null   # same date replaces
OUT="$("$OS" read demo all)"
if has "$OUT" "beta" && ! has "$OUT" "alpha"; then ok "same-date upsert replaces (no dupe date)"; else bad "same-date upsert replaces" "$OUT"; fi

# --- summary ---
printf 'the state of demo' | "$OS" summary demo >/dev/null
assert_has "$(cat "$T/log/.summary/demo.md")" "state of demo" "summary saved"

# --- briefing: greeting + initial + project ---
BR="$(OPENSHIP_PROJECT=demo "$OS" briefing "$repo")"
assert_has "$BR" "Welcome back, Ada" "briefing greets by name"
assert_has "$BR" "@ada · demo"       "briefing subtitle = @user · project"
assert_has "$BR" "│ A │"             "briefing mascot carries the initial"
assert_has "$BR" "update(s)"          "compact briefing shows a one-line digest"
BRF="$(OPENSHIP_PROJECT=demo "$OS" briefing "$repo" --full)"
assert_has "$BRF" "Summary"           "--full expands the summary"

# --- claude adapter installer: hermetic, preserves + idempotent ---
export CLAUDE_CONFIG_DIR="$T/claude"; mkdir -p "$CLAUDE_CONFIG_DIR"
echo '{"hooks":{"Stop":[{"hooks":[{"type":"command","command":"/keep/me.sh"}]}]}}' > "$CLAUDE_CONFIG_DIR/settings.json"
if command -v jq >/dev/null 2>&1; then
  bash "$ROOT/adapters/claude-code/install.sh" >/dev/null 2>&1
  N1="$(jq '.hooks.Stop|length' "$CLAUDE_CONFIG_DIR/settings.json")"
  bash "$ROOT/adapters/claude-code/install.sh" >/dev/null 2>&1
  N2="$(jq '.hooks.Stop|length' "$CLAUDE_CONFIG_DIR/settings.json")"
  KEPT="$(jq -r '[.hooks.Stop[].hooks[].command]|index("/keep/me.sh")!=null' "$CLAUDE_CONFIG_DIR/settings.json")"
  assert_eq "$KEPT" "true" "installer preserves existing hooks"
  assert_eq "$N1"   "$N2"  "installer is idempotent (no dup on rerun)"
  EVT="$(jq -r '.hooks|keys|sort|join(",")' "$CLAUDE_CONFIG_DIR/settings.json")"
  assert_has "$EVT" "SessionStart" "installer wires SessionStart"
else
  printf '  \033[33m—\033[0m jq not found, skipping installer tests\n'
fi

# --- summary ---
printf '\n'
if [ "$FAIL" -eq 0 ]; then printf '\033[32m⛵ all %d passed\033[0m\n\n' "$PASS"; exit 0
else printf '\033[31m%d failed\033[0m, %d passed\n\n' "$FAIL" "$PASS"; exit 1; fi
