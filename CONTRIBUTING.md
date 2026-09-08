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
   - Add a new top entry to `skill-provenance/CHANGELOG.md` describing what changed.
   - Mirror the same release entry into root `CHANGELOG.md`, which is the full archive.
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

## Hosted-site Siteline assessment

For changes to the hosted site or its machine-readable surfaces, assess the canonical site at https://skillprovenance.dev/ with Siteline before delivery review and after an authorized deployment. Retrieve an existing result when appropriate; respect scan limits and cached-result timestamps.

- Retain the result ID, scan timestamp, scanner and rubric versions, grade, score, findings, and repository commit. A shareable result requires confirmed storage.
- Reconcile every finding against current source, generated output, and deployed evidence. Classify it as confirmed target work, scanner defect, deployment drift, stale or unreproduced, or informational. Record evidence and rationale for exceptions.
- Resolve confirmed defects that affect the site's promised agent tasks before declaring acceptance. Do not add irrelevant APIs, feeds, contact forms, or commerce features merely to raise the grade.
- Keep SNAP grades and passive standards panels separate from full GuideCheck, Graceful Boundaries, accessibility, or other applicable conformance checks. A high grade does not replace those checks.
- Local candidate checks do not establish live acceptance. After deployment, verify the intended bytes and reconcile a scan of those deployed surfaces; a cached scan of earlier content remains historical evidence.
