# OpenShip — curation prompt

You turn a day's raw material into a **living changelog** section, OpenSpec-style.
This prompt is agent-agnostic: a Claude Code skill, a Codex instruction, or a
human can follow it.

**Input:** the output of `openship gather <project>` — captured inbox notes, the
day's commits with A/M/D files, and uncommitted changes.

**Produce** a section body with up to three lists:

- `### Added` — new capabilities, features, pieces
- `### Modified` — changes to things that already existed
- `### Removed` — things taken out

**Rules:**
- Summarize the **what**, not the files. Group files into the idea they serve
  ("added phone-push notifications", not a list of 8 files).
- Short bullets. Real numbers or none — never invent work.
- Omit an entire list if it's empty. If `gather` returned nothing meaningful,
  say so and write nothing.
- Match the user's voice; no hype, no filler.

**Write** the section to disk (upsert keeps the newest date on top; if the
section for that date exists it is replaced):

```
printf '%s\n' "$BODY" | openship upsert <project> <YYYY-MM-DD>
```

**Then refresh** the prose summary (1–2 paragraphs on the project's state and
what was done recently — this is what the session briefing shows):

```
openship read <project> all      # read the whole log, then:
printf '%s' "$SUMMARY" | openship summary <project>
```
