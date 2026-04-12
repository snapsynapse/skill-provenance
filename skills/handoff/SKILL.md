---
description: >
  Generate a handoff note summarizing skill project state for a future
  session or collaborator. Use when crossing a non-persistent boundary
  (e.g., Chat upload), ending a session that made significant decisions,
  or when the user explicitly asks for a handoff note. Triggers on:
  "generate a handoff", "write a handoff note", "summarize for next
  session", "prepare handoff", "what should the next session know".
---

# Skill Provenance: Handoff

Generate a structured handoff note that captures project state for the
next session or a collaborator picking up the work.

## When to use

Run `/skill-provenance:handoff` when:
- Crossing a non-persistent boundary (e.g., uploading to Claude Chat where
  filesystem state won't carry over).
- The session made significant decisions not yet reflected in files.
- The user explicitly asks for a handoff note.
- A collaborator or future session needs context beyond what the manifest
  and changelog provide.

**When NOT to use:** In filesystem-native environments (Claude Code, IDE)
with a current manifest, changelog, and git history, a handoff note is
usually unnecessary. The manifest and changelog are the handoff.

## Protocol

1. **Read current state.** Load `MANIFEST.yaml` and `CHANGELOG.md` to
   understand the bundle's current version and recent history.

2. **Generate the handoff note** with these sections:

   - **Current bundle version** — name and semver from the manifest.
   - **What was accomplished this session** — summarize the work done,
     not just files changed.
   - **What is stale and needs attention** — files flagged as behind or
     not updated this session.
   - **What the next session should do first** — concrete first action,
     not vague guidance.
   - **Decisions made but not yet reflected in files** — architecture
     choices, deferred items, scope decisions that someone reading only
     the code wouldn't know about.
   - **Per-file change summaries** — for each file modified this session,
     a brief description of what changed (section added, field removed,
     logic rewritten). More granular than the changelog entry; helps the
     next session verify work without re-reading every file.

3. **Replace, don't accumulate.** A new handoff note replaces the previous
   one. Previous handoffs live in changelog history. Don't maintain a chain
   of handoff files.

4. **Placement.** Write the handoff note as a markdown file in the bundle
   directory (e.g., `HANDOFF.md`). Track it in the manifest with
   `role: handoff` if the user wants it to persist across sessions.

## Conventions referenced

- Handoff notes are **optional convenience artifacts**, not required by
  the spec.
- The manifest and changelog are always the authoritative record. The
  handoff note provides context and intent that structured metadata cannot.
- In environments with persistent filesystems and git, prefer the manifest
  and changelog over handoff notes.

For the full spec: https://skillprovenance.dev
