---
description: >
  Verify a skill bundle's integrity when opening a project. Use when loading
  a skill project directory and you need to check file completeness, verify
  SHA-256 hashes against MANIFEST.yaml, detect stale files, review recent
  changes, or understand what state the bundle is in before starting work.
  Triggers on: "open this skill", "verify the bundle", "check what changed",
  "is everything up to date", "load this project".
---

# Skill Provenance: Open

Verify a skill bundle when opening a session. This ensures you start from
a known-good state before making any changes.

## When to use

Run `/skill-provenance:open` at the start of any session where you'll work
on a skill bundle — a directory containing `SKILL.md` and optionally
`MANIFEST.yaml`, `CHANGELOG.md`, evals, scripts, and other tracked files.

## Protocol

1. **Read MANIFEST.yaml first.** It is the single source of truth for what
   the bundle contains. If no manifest exists, tell the user and suggest
   running `/skill-provenance:bootstrap` instead.

2. **Verify all listed files are present.** Report any files listed in the
   manifest but missing from disk.

3. **Verify hashes.** For each file with a `hash` field, compute
   `sha256sum` and compare. Flag mismatches. If `validate.sh` exists in
   the bundle, mention that the user can also run it directly for faster
   local verification.

4. **Read CHANGELOG.md.** Summarize the most recent 2-3 entries so the
   user knows what changed recently.

5. **Check for staleness.** Compare per-file `version` fields against
   `bundle_version`. If any versioned file has a version that appears
   behind the bundle version, or if the changelog mentions files that
   were "not updated" in a recent entry, flag them and ask whether they
   need attention this session.

6. **Check deployment drift.** If the manifest has a `deployments` section,
   note any deployed copies whose version appears behind the current
   bundle version. Don't alarm — just surface the information.

7. **Resolve conflicts if found.** If a file's internal version header
   disagrees with the manifest's version for that file, or two files
   claim different bundle versions:
   - Present the specific discrepancy to the user.
   - Show what each version claims via its `change_summary`.
   - Default recommendation: trust the most recent `version_date`.
   - **Always ask the user for explicit confirmation.** Never silently
     resolve a version conflict.

8. **Report.** Give the user a concise summary:
   - Bundle name and version
   - File count: present / expected
   - Hash check: pass / N mismatches
   - Stale files (if any)
   - Deployment drift (if any)
   - Recommended first action for this session

## Conventions referenced

This skill follows the Skill Provenance open standard. Key conventions:

- **Version identity lives inside files** (via YAML frontmatter `metadata`
  block) and in `MANIFEST.yaml`, never in filenames.
- **MANIFEST.yaml is not self-listed.** It tracks other files but does not
  contain its own hash.
- **Per-file versions are integers** counting revisions. Bundle version
  (`bundle_version`) is semver.
- **Hashes are SHA-256** of file contents, computed on save, verified on load.

For the full spec: https://skillprovenance.dev
