# OpenShip — OpenCode adapter

OpenShip is agent-agnostic: the core engine is identical, only the wiring differs.
For [OpenCode](https://opencode.ai):

- **`openship.js`** — an OpenCode *plugin*. It subscribes to `session.idle` (a
  finished turn) and, via the `openship` CLI, sends a notification and best-effort
  captures the turn summary to the ship-log inbox.

Install (or via `openship init`):

```bash
bash adapters/opencode/install.sh
```

It copies the plugin to `~/.config/opencode/plugins/openship.js`. Make sure the
`openship` CLI is on your PATH (the wizard offers to symlink it).

The notification is the guaranteed part; the inbox capture is enrichment. Even
without it, `openship gather` reconstructs the day from git, so curation always
works.
