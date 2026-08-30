# OpenShip — Codex adapter

OpenShip is agent-agnostic: the core engine is identical, only the wiring differs.
For [Codex](https://github.com/openai/codex):

- **`notify.sh`** — a Codex *notify program*. On a completed turn it captures the
  turn summary to the ship-log inbox and sends a notification.
- **`AGENTS.md.snippet`** — drop this into your project's `AGENTS.md` (or
  `~/.codex/AGENTS.md`) so Codex knows how to curate the log and capture ideas via
  the `openship` CLI.

Install (or via `openship init`):

```bash
bash adapters/codex/install.sh
```

It adds the notify program to `~/.codex/config.toml` (only when there's no existing
`notify` key) and points you at the AGENTS.md snippet.
