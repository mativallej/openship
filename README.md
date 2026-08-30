# OpenShip

[![X (formerly Twitter) Follow](https://img.shields.io/twitter/follow/mativallej_?style=social)](https://x.com/mativallej_)
[![GitHub top language](https://img.shields.io/github/languages/top/mativallej/openship?color=1081c2)](https://github.com/mativallej/openship/search?l=shell)
![License](https://img.shields.io/github/license/mativallej/openship?label=license&logo=github&color=f80&logoColor=fff)
![Forks](https://img.shields.io/github/forks/mativallej/openship.svg)
![Stars](https://img.shields.io/github/stars/mativallej/openship.svg)
![Watchers](https://img.shields.io/github/watchers/mativallej/openship.svg)

> A git-native, agent-agnostic **ship log** for your work: capture what you shipped and why — at a keystroke — curate it into an OpenSpec-style changelog, get a "welcome back" briefing every session, and never lose context again. Pure shell + git + markdown. Works with Claude Code, Codex, and opencode.

```
👋 tegu-landing
   🌿 Branch: main  ·  Uncommitted: 2 file(s)
   🎯 Last: Wired ntfy push into the notify hook
   📅 Last 7 days
     2026-08-29
       Added: phone-push notifications; /idea capture
       Modified: project name now stable across git worktrees
   📋 Summary
   The notification layer moved from macOS-only to cross-platform …
```

## Introduction

**OpenShip** is the "internal OpenSpec" a lot of people end up building by hand: a
structured, living record of what you actually shipped — not raw `git log` noise,
and not screen-recording — kept per project and surfaced when you need it.

It has three pillars, all driven by one CLI (`openship`) and a small, config-driven
engine:

- **Ship Log** — an OpenSpec-style changelog (`## date` → `### Added / Modified /
  Removed`), curated semantically by your AI tool from the day's git activity plus
  whatever got captured while you worked.
- **Session Briefing** — a "welcome back" printed at the start of each session:
  branch, uncommitted count, last task, the last N days of the log, and a prose
  summary.
- **Notifications** — a desktop banner, a sound, and an optional phone push when a
  task finishes or when the agent needs your input.

It's **agent-agnostic on purpose.** The engine is pure shell + git + markdown and
knows nothing about any AI tool. Each agent gets a thin *adapter* that wires the
engine into its hooks. Claude Code, Codex, and opencode ship in the box; adding another is a
folder.

## Key Features

- **Git-native** — the universal signal is your commits and diffs, so it works in
  any repo, in any language, across every git worktree of a project.
- **Curated, not raw** — a model turns the day's changes into meaningful
  Added/Modified/Removed bullets. Signal over noise; never an unread `git log`.
- **Agent-agnostic** — a portable core plus per-agent adapters (Claude Code, Codex).
  The hand-off point is a plain-markdown inbox, so anything can feed it.
- **Console onboarding** — `openship init` interviews you and configures everything,
  then wires up your AI tool. No files to hand-edit.
- **Local-first** — your log is markdown on your disk. Point it at an Obsidian vault
  if you want it next to your notes.
- **`/idea` capture** — a spontaneous-idea inbox alongside the ship log.
- **MIT licensed** — small, self-contained scripts you can read in one sitting.

## Quick Start (Recommended)

### Prerequisites

- `bash`, `git`, and [`jq`](https://jqlang.github.io/jq/) (`brew install jq` / `apt install jq`).
- An AI coding tool: [Claude Code](https://claude.com/claude-code), [Codex](https://github.com/openai/codex), or [opencode](https://opencode.ai).
- macOS or Linux. Phone push is optional via [ntfy.sh](https://ntfy.sh).

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/mativallej/openship.git
   cd openship
   ```

2. **Run the installer**
   ```bash
   ./install.sh
   ```
   This makes the scripts executable and launches `openship init`, which interviews
   you (where the log lives, phone push, sounds, duration gate, briefing window),
   writes `~/.config/openship/config.sh`, puts `openship` on your PATH, and wires up
   your chosen AI tool.

3. **Use it**
   ```bash
   openship briefing            # the welcome-back for the current repo
   openship idea "a thought"    # capture an idea
   openship read                # read the last 7 days across projects
   ```
   In Claude Code, the hooks fire automatically: you get a briefing on session
   start, a notification (and an inbox capture) when a task finishes, and a `/idea`
   command. Ask it to *"ship log"* to curate the day.

## Alternative Setup (Manual, no wizard)

You don't need the wizard — everything is plain files.

1. **Clone** (same as above) and add `bin/` to your PATH.
2. **Configure**: `cp config.example.sh ~/.config/openship/config.sh` and edit it.
3. **Wire up your agent**: `bash adapters/claude-code/install.sh` (or
   `bash adapters/codex/install.sh`).

## Detailed Setup (Developers)

### Tech Stack

- **Pure POSIX-ish bash** — no runtime, no dependencies to build.
- **git** — the source of truth for "what changed".
- **jq** — JSON parsing for agent hook payloads.
- **markdown** — the storage format (readable, diffable, Obsidian-friendly).

### Project Structure

```
openship/
├── bin/openship                # the CLI — agent-agnostic entry point
├── core/                       # the engine: pure shell + git + markdown
│   ├── lib.sh                  # config loading + helpers (project name, etc.)
│   ├── init.sh                 # interactive onboarding (openship init)
│   ├── project.sh              # stable project name across git worktrees
│   ├── gather.sh  read.sh      # collect raw material · read the curated log
│   ├── upsert.sh  summary.sh   # write a section · write the prose summary
│   ├── capture.sh  idea.sh     # inbox capture · idea capture
│   ├── notify.sh  briefing.sh  # notifications · welcome-back briefing
├── prompts/curate.md           # the portable curation prompt
├── adapters/
│   ├── claude-code/            # hooks + ship-log skill + /idea command + installer
│   ├── codex/                  # notify program + AGENTS.md snippet + installer
│   └── opencode/               # session.idle plugin + installer
├── config.example.sh
└── install.sh                  # bootstrap → openship init
```

### Customization

Everything is config, loaded from `~/.config/openship/config.sh` (or `$OPENSHIP_CONFIG`).

| Variable | Default | What it does |
| --- | --- | --- |
| `OPENSHIP_LOG_DIR` | `~/.openship` | Where the log lives. Point at an Obsidian vault to keep it with your notes. |
| `OPENSHIP_MIN_SECONDS` | `60` | Duration gate — only notify for tasks longer than this. |
| `OPENSHIP_NTFY_TOPIC` | *(empty)* | ntfy.sh topic for phone push. Empty disables push. |
| `OPENSHIP_SOUND_DONE` | macOS Glass | Sound on task done (path; empty disables). |
| `OPENSHIP_SOUND_INPUT` | macOS Funk | Sound when input is needed. |
| `OPENSHIP_NAME` | *(auto)* | Your name, used for the briefing title "Welcome back, <name>" (auto-detected from git during `init`). |
| `OPENSHIP_USER` | *(auto)* | Your GitHub username / handle, shown as the briefing subtitle "@user · project" (auto-detected via `gh`/git during `init`). Also renders as an ASCII banner (figlet) or plain `@handle`. |
| `OPENSHIP_BANNER` | *(empty)* | Path to a custom ASCII banner file. Takes precedence over the `OPENSHIP_USER` banner. |
| `OPENSHIP_BRIEFING_DAYS` | `7` | How far back the briefing reads. |
| `OPENSHIP_PROJECT` | *(auto)* | Override the auto-detected project name for the current dir. |

**Per-repo name:** drop a `.openship` file at the repo root containing a single line —
the project name — to override auto-detection for that repo. Useful when the folder
name isn't what you call the project (precedence: `OPENSHIP_PROJECT` env > `.openship`
file > repo folder name).

## Data Model

The log is markdown under `OPENSHIP_LOG_DIR`. No database, no config server.

| Path | Contents |
| --- | --- |
| `<project>.md` | The curated changelog — `## YYYY-MM-DD` sections with `### Added / Modified / Removed`, newest on top. |
| `.inbox/<project>.md` | Raw captured notes (timestamped one-liners) awaiting curation. The agent-agnostic hand-off point. |
| `.summary/<project>.md` | A 1–2 paragraph prose summary, shown in the briefing. |
| `ideas.md` | Spontaneous ideas, timestamped and tagged with the project they came from. |

A **project** is keyed by the *stable* repo name (the main worktree's folder), so
every git worktree and branch writes to the same log.

## Architecture Overview

### Core + adapters

The **core** (`core/`) is a set of small shell scripts over git and markdown. It
never assumes which AI tool is driving. Each **adapter** (`adapters/<agent>/`) wires
the core into one agent's lifecycle.

### The inbox is the hand-off

While you work, an adapter drops raw notes into `.inbox/<project>.md` — for Claude
Code, the `Stop` hook captures the turn's `aiTitle`; for Codex, the `notify` program
captures the turn summary. Curation (`openship gather` → model → `openship upsert`)
reads the inbox plus git and produces the changelog. Because the hand-off is plain
markdown, **anything** can feed it — another agent, a CI job, or you by hand.

### Why git as the signal

Every agent and every edit produces git changes. Building on git (not on transcripts
or screen recordings) is what makes OpenShip portable, private, and cross-language.

## Design Principles

1. **Signal over noise.** Capture is intentional; the log is curated. No unread dumps.
2. **Meaning, not pixels.** OpenShip records *what changed and why*, not screenshots.
3. **Agent-agnostic.** The core is portable; agents are adapters. No lock-in.
4. **Local-first.** Your data is markdown on your disk, yours to sync or delete.
5. **Small and legible.** Plain shell you can read and audit in one sitting.

## Usage

### The CLI

```
openship init                    interactive setup
openship briefing [cwd]          print the welcome-back briefing
openship gather <proj> [repo]    collect today's raw material to curate
openship curate                  print the curation prompt
openship upsert <proj> <date>    write a curated section (body on stdin)
openship summary <proj>          write the prose summary (body on stdin)
openship read [proj] [days]      read the curated log (days number or "all")
openship capture <proj> <txt>    append a raw note to the inbox
openship idea "<txt>"            capture a spontaneous idea
openship ideas [n]               list recent ideas
openship notify <done|input> <title> <subtitle> <message>
openship project [cwd]           print the stable project name
openship test                    run the hermetic smoke test suite
```

### Claude Code

The adapter installs a `ship-log` skill (ask *"ship log"* / *"close the day"* to
curate), an `/idea` command, and four hooks: `SessionStart` (briefing), `Stop`
(capture + notify), `Notification` (input needed), and `UserPromptSubmit` (duration
gate). Hooks are merged into `~/.claude/settings.json` without touching your existing ones.

### Codex

The adapter registers a `notify` program (capture + notify on turn complete) and
gives you an `AGENTS.md` snippet so Codex can curate the log and capture ideas via
the same `openship` CLI.

### OpenCode

The adapter installs a plugin (`~/.config/opencode/plugins/openship.js`) that runs
on `session.idle`: it notifies and best-effort captures the finished turn to the
inbox via the `openship` CLI. Curation always works from git even without the
capture. Curate and capture ideas with the same CLI: `openship gather`, `openship
idea`.

## Contributing

Contributions are welcome. Run the test suite before opening a PR:

```bash
openship test        # or: bash tests/run.sh
```

The tests are hermetic (temp config + dirs, no network, no touching your real
state), so they're safe to run anywhere.

- **New agent adapters** — the core is agent-agnostic; a new adapter is a folder
  under `adapters/` that wires the CLI into that tool's lifecycle. PRs welcome.
- **Cross-platform notifications** — the notify layer is best-effort on Linux; PRs
  improving `notify-send`/sound coverage are welcome.

## Contact

Built by Matías Vallejos.

- Website: [matiasvallejos.com](https://matiasvallejos.com)
- X: [@mativallej_](https://x.com/mativallej_)
- GitHub: [@mativallej](https://github.com/mativallej)

## License

[MIT](LICENSE).

## Inspiration

[OpenSpec](https://github.com/Fission-AI/OpenSpec) brought spec-driven, structured
change tracking to AI coding — but scoped to a single repo and to code. OpenShip
takes the same "Added / Modified / Removed" DNA and makes it a **general, agent-
agnostic ship log**: any project, any medium you can capture, surfaced when you sit
back down. Build in public works best when the record outlives the session.
