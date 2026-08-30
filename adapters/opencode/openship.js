// OpenShip — OpenCode plugin.
//
// Wires OpenShip into OpenCode: when a turn finishes (`session.idle`) it sends a
// notification and best-effort captures the turn summary to the ship-log inbox.
// The reliable part is the notification; the inbox capture is enrichment and
// degrades gracefully (curation still works from git via `openship gather`).
//
// Install: copy to ~/.config/opencode/plugins/openship.js (global) or a
// project's .opencode/plugins/. Requires the `openship` CLI on your PATH.
export const OpenShip = async ({ client, $, directory, worktree }) => {
  const cwd = worktree || directory || process.cwd()
  let project = "unknown"
  try {
    const p = (await $`openship project ${cwd}`.text()).trim()
    if (p) project = p
  } catch {}

  return {
    event: async ({ event }) => {
      if (event?.type !== "session.idle") return

      // best-effort: use the last assistant message as the inbox note
      let note = ""
      try {
        const id = event.properties?.sessionID ?? event.sessionID
        if (id && client?.session?.messages) {
          const res = await client.session.messages({ path: { id } })
          const list = res?.data ?? res ?? []
          const last = [...list].reverse().find(
            (m) => (m.role ?? m.info?.role) === "assistant"
          )
          note = (last?.summary ?? last?.title ?? "").toString().trim()
        }
      } catch {}

      if (note) {
        try { await $`openship capture ${project} ${note}`.quiet() } catch {}
      }
      const title = `✅ Done · ${project}`
      try {
        await $`openship notify done ${title} ${note} ${"Finished the task"}`.quiet()
      } catch {}
    },
  }
}
