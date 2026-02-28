# Contributing

Issues and PRs welcome.


## Compatibility reports

The most valuable contribution right now is testing the skill on platforms other than Claude. If you test on Gemini CLI, Codex, Copilot, Cursor, or any other agentskills.io-compatible platform, open an issue using the **Compatibility Report** template with:

- Platform and version
- Model used
- What worked
- What didn't
- Any workarounds applied


## Making changes

1. Fork the repo and create a branch.
2. Make your changes. If you modify files inside `skill-provenance/`, follow the versioning protocol:
   - Update per-file `version` integers in `MANIFEST.yaml` for changed files.
   - Run `./skill-provenance/validate.sh --update` to recompute hashes.
   - Add a `CHANGELOG.md` entry describing what changed.
   - Bump `bundle_version` in `MANIFEST.yaml` (PATCH for fixes, MINOR for features, MAJOR for breaking changes).
3. Run `./skill-provenance/validate.sh` to confirm everything is clean.
4. Open a PR with a clear description of what changed and why.


## What doesn't need the versioning protocol

Changes to repo-level files that aren't part of the skill bundle (root `README.md`, `AGENTS.md`, `CONTRIBUTING.md`, `.github/`, `LICENSE`) don't require manifest updates or version bumps.


## Code style

- SKILL.md and README.md: wrap prose at ~80 characters.
- YAML: 2-space indent.
- Bash: `set -euo pipefail`, zero external dependencies.
- JSON: 2-space indent.
