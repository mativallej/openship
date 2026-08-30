---
name: ship-log
description: Curate today's shipped work into a per-project changelog (OpenSpec-style Added/Modified/Removed), or show recent work. Use when the user says "ship log", "worklog", "what did I ship", "document today", "close the day", or "what did I do this week".
---

# Ship Log — a living changelog per project

Document work per project as a living changelog (OpenSpec logic: `### Added /
### Modified / ### Removed`, `## YYYY-MM-DD` sections, newest on top), powered by
the `openship` CLI.

## CURATE (default) — document today

When the user asks to document/curate/"close the day", or runs `/ship-log`:

1. **Project name** (stable across git worktrees): `openship project`
2. **Gather the raw material**: `openship gather <project>`
   → captured inbox notes + today's commits with A/M/D files + uncommitted changes.
3. **Summarize SEMANTICALLY** — the "what", not the files — into up to three
   lists: **Added / Modified / Removed**. Short bullets, real numbers or none,
   omit an empty list, group files into the idea they represent (don't list 8
   files, say what was achieved). Full rules: `openship curate`.
4. **Write the section** (body = the `###` lines and bullets, on stdin):
   `printf '%s\n' "$BODY" | openship upsert <project> <YYYY-MM-DD>`
5. **Refresh the prose summary** (1–2 paragraphs on the project's state, shown in
   the briefing): read it all with `openship read <project> all`, then
   `printf '%s' "$SUMMARY" | openship summary <project>`
6. **Confirm** what got documented.

## SHOW — read what was done

`openship read <project|all> <days|all>`  — e.g. `openship read` (all, 7 days),
`openship read tegu 30`, `openship read all all`.

## Notes
- This log feeds the **session briefing** (shows the last N days on session start).
- Never invent work: if `gather` returns nothing, say so and write nothing.
- One project = one `<project>.md`, keyed by the STABLE repo name (`openship
  project`), so every worktree/branch writes to the same log.
- Spontaneous ideas (not tied to a work event) go to `openship idea "..."`.
