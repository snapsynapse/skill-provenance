# Skill Provenance

A metaskill for version tracking across Agent Skills sessions, surfaces, and platforms. This is a skill bundle project, not a library.

Canonical site: https://skillprovenance.dev/ | Repo: snapsynapse/skill-provenance (public, MIT). Ships as a Claude Code plugin and as a standalone `.skill` upload. Zero external dependencies by design (bash + shasum/sha256sum + awk + zip only).

## Key files

- `skill-provenance/SKILL.md` -- the skill definition (what agents read)
- `skill-provenance/MANIFEST.yaml` -- file inventory with roles, versions, SHA-256 hashes
- `skill-provenance/CHANGELOG.md` -- rolling recent history (last 5 entries)
- `skill-provenance/evals.json` -- 35 core evaluation scenarios
- `skill-provenance/evals-distribution.json` -- 17 supplemental distribution evals
- `skill-provenance/validate.sh` -- local hash verification script
- `skill-provenance/package.sh` -- derived copy generator (strict/ClawHub)
- `action.yml` -- GitHub Actions Marketplace wrapper for bundle validation
- `CHANGELOG.md` -- full append-only repo history
- `AGENTS.md` -- detailed guide for agents working on this repo

## Claude Code plugin

This repo doubles as a Claude Code plugin. The plugin structure:

- `.claude-plugin/plugin.json` -- plugin manifest (name, version, metadata)
- `.claude-plugin/marketplace.json` -- marketplace listing for self-hosted install
- `skills/open/SKILL.md` -- `/skill-provenance:open` (verify bundle on session start)
- `skills/close/SKILL.md` -- `/skill-provenance:close` (update versions on session end)
- `skills/handoff/SKILL.md` -- `/skill-provenance:handoff` (generate handoff note)
- `skills/bootstrap/SKILL.md` -- `/skill-provenance:bootstrap` (version an unversioned bundle)
- `skills/skill-provenance` -- symlink to `skill-provenance/` for the monolithic skill

The four focused skills extract specific workflows from the monolithic SKILL.md.
The symlink preserves `/skill-provenance:skill-provenance` as the full monolithic skill.

Test locally: `claude --plugin-dir .`

## Commands

```bash
./skill-provenance/validate.sh            # verify all hashes match manifest
./skill-provenance/validate.sh --update   # recompute hashes after edits
./skill-provenance/package.sh strict      # generate strict-platform copy
./skill-provenance/package.sh clawhub     # generate ClawHub upload copy
./skill-provenance/package.sh all         # generate both
```

## Conventions

- No external dependencies. Scripts use only bash, shasum/sha256sum, awk, and zip.
- The `skill-provenance/` directory is the single source of truth. Everything else is derived.
- MANIFEST.yaml is not self-listed. It tracks other files but does not contain its own hash.
- Per-file versions are integers counting revisions. Bundle version (`bundle_version`) is semver.
- Canonical SKILL.md uses `frontmatter_mode: metadata`. Strict-platform copies strip the metadata block.
- Root `CHANGELOG.md` is append-only. In-bundle `CHANGELOG.md` keeps the newest 5 entries.

## After editing bundle files

1. Bump per-file `version` in MANIFEST.yaml for changed files
2. Run `./skill-provenance/validate.sh --update` to recompute hashes
3. Bump `bundle_version` (semver) and `bundle_date` in MANIFEST.yaml
4. Update both changelogs (in-bundle keeps 5 entries, root is append-only)
5. Rebuild the `.skill` ZIP:
   ```bash
   rm -f skill-provenance.skill
   zip -r skill-provenance.skill skill-provenance/
   ```
6. Run `./.github/scripts/release-surface-check.sh` to confirm eval-count declarations, GuideCheck sidecar metadata, and the `.skill` ZIP all match the current source.

## CI

`.github/workflows/validate.yml` runs on push/PR to `main`: verifies bundle hashes via the repo's own `action.yml`, test-builds the strict and ClawHub packages, runs `release-surface-check.sh`, `action-security-check.sh`, and `test-validate.sh`. All are bash scripts under `.github/scripts/` and `skill-provenance/`.

## Current state (as of 2026-07-10 assessment)

- Bundle version `5.0.0` (see `skill-provenance/MANIFEST.yaml`), released 2026-07-10.
- Working tree clean, `main` up to date with `origin/main`, no open branches with unmerged work besides an already-merged `codex/mitigate-review-findings`.
- Latest work hardened manifest validation (fail-closed on missing/malformed/duplicate hashes) and fixed action input transport (env var instead of Bash string interpolation) — both are security-hygiene fixes, not new features.
- Roadmap (`ROADMAP.md`) lists a plugin v0.2.0 in progress (five focused skills: open/validate/close/handoff/bootstrap) plus deferred/not-yet-committed ideas: standalone `bin/` CLI, multi-bundle workspace support, MCP server, and an auto-hash PostToolUse hook (explicitly deferred pending a design that avoids silent manifest churn).
