# Agents Guide

Instructions for AI agents (Claude, Codex, Gemini CLI, etc.) working on this repository. This metaskill is also published to [ClawHub](https://clawhub.com) for discovery by OpenClaw agents.


## Repository structure

```
skill-provenance/                ← Canonical source bundle (DO NOT rename)
├── SKILL.md                     ← Agent-facing skill definition
├── README.md                    ← Human-facing user guide (has internal version header)
├── MANIFEST.yaml                ← File inventory: roles, versions, SHA-256 hashes
├── CHANGELOG.md                 ← Append-only change history
├── evals.json                   ← 13 evaluation scenarios
└── validate.sh                  ← Bash script for local hash verification
skill-provenance.skill           ← Claude Settings ZIP (rebuilt from the directory)
```

The `skill-provenance/` directory is the single source of truth. The `.skill` file is a packaging wrapper.


## Before making changes

1. Read `skill-provenance/MANIFEST.yaml` to understand the current bundle state.
2. Run `./skill-provenance/validate.sh` to confirm all hashes are clean.
3. Read `skill-provenance/CHANGELOG.md` for recent context.


## After making changes

1. Bump per-file `version` integers in `MANIFEST.yaml` for every file you changed.
2. Recompute hashes: run `./skill-provenance/validate.sh --update`.
3. Bump `bundle_version` (semver) in `MANIFEST.yaml`:
   - PATCH for docs, typos, non-functional changes.
   - MINOR for new features, new files, capability additions.
   - MAJOR for breaking changes to the versioning model or spec.
4. Update `bundle_date` to today.
5. Append an entry to `CHANGELOG.md` at the top. Name every file that changed and describe what changed in each.
6. Rebuild the `.skill` ZIP if bundle contents changed:
   ```bash
   rm -f skill-provenance.skill
   zip -r skill-provenance.skill skill-provenance/
   ```


## Key rules

- **MANIFEST.yaml is not self-listed.** It tracks other files but does not contain its own hash. Do not add it to the `files:` list.
- **SKILL.md uses minimal frontmatter** (`name` and `description` only). Do not add `metadata`, `version`, or other fields to SKILL.md frontmatter — version info lives in MANIFEST.yaml.
- **Per-file versions are integers.** They count revisions to that specific file. The bundle version (`bundle_version`) is semver.
- **Paths in MANIFEST.yaml are relative** to the bundle root (`skill-provenance/`). No absolute paths.
- **CHANGELOG.md is append-only.** New entries go at the top. Never edit or remove existing entries.
- **validate.sh must stay zero-dependency.** Only `bash`, `shasum`/`sha256sum`, and `awk`. No Python, Node, or external tools.


## Files outside the bundle

These repo-level files are not tracked in MANIFEST.yaml:

- `README.md` (root) — GitHub landing page, not part of the skill bundle.
- `AGENTS.md` — This file.
- `CONTRIBUTING.md` — Contribution guide.
- `.github/` — Issue templates, CI workflows.
- `LICENSE` — MIT license.
- `.gitignore` — Git exclusions.

Changes to these files do not require a bundle version bump unless they also change files inside `skill-provenance/`.


## Testing changes

Run validation after any edit to bundle files:

```bash
cd skill-provenance
./validate.sh          # Verify hashes match manifest
./validate.sh --update # Recompute hashes after edits
```

Exit code 0 means clean. Exit code 1 means mismatches or missing files. Exit code 2 means MANIFEST.yaml not found.
