# Skill Provenance

A metaskill for version tracking across Agent Skills sessions, surfaces, and platforms. This is a skill bundle project, not a library.

Canonical site: https://skillprovenance.dev/ | Repo: snapsynapse/skill-provenance (public, MIT). Ships as a Claude Code plugin and as a standalone `.skill` upload. Zero external dependencies by design (bash + shasum/sha256sum + awk + zip only).

## Key files

- `skill-provenance/SKILL.md` -- the skill definition (what agents read)
- `skill-provenance/MANIFEST.yaml` -- file inventory with roles, versions, SHA-256 hashes
- `skill-provenance/CHANGELOG.md` -- rolling recent history (last 5 entries)
- `skill-provenance/evals.json` -- 50 core evaluation scenarios
- `skill-provenance/evals-distribution.json` -- 21 supplemental distribution evals
- `skill-provenance/validate.sh` -- local hash verification script
- `skill-provenance/package.sh` -- derived copy generator (strict/ClawHub)
- `skill-provenance/references/standalone-verification.md` -- no-plugin verify/bootstrap path
- `verify.sh` -- standalone wrapper pinned to the canonical validator
- `action.yml` -- GitHub Actions Marketplace wrapper for bundle validation
- `action-validate.sh` -- the action's entry point (inputs by environment, path after `--`)
- `scripts/adversarial-agent-evals.sh` -- manual model-run adversarial evals graded by canary files
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

The five focused skills extract specific workflows from the monolithic SKILL.md.
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
6. Run `./.github/scripts/release-surface-check.sh` to confirm eval-count declarations, the standalone validator pin, GuideCheck sidecar metadata, the README changed-bundle trial output (tag, digests, counts, exit codes), and the `.skill` ZIP all match the current source. A release that changes `SKILL.md`, the file count, or `bundle_version` must refresh the README trial block from a real run.

## CI

`.github/workflows/validate.yml` runs on push/PR to `main`. The job named `validate` is a required check in the `main` ruleset, so never rename or matrix it; `validate-macos` (Bash 3.2) and `shellcheck` are separate jobs. The `validate` job verifies bundle hashes via the repo's own `action.yml`, test-builds the strict and ClawHub packages, and runs `release-surface-check.sh`, `action-security-check.sh`, `test-validate.sh`, and `test-standalone-verify.sh`. All are bash scripts under `.github/scripts/` and `skill-provenance/`.

## Current state (as of 2026-11-22 release)

- Stable public bundle release is `7.1.0`, the validator hardening release
  from the 2026-11-22 audit: `--strict` fails on `hash: null`,
  `--expect-manifest-sha256` binds a run to an out-of-band manifest digest,
  empty or option-shaped paths and a symlinked manifest are errors, manifest
  text is escaped in output, and the action gained `strict`,
  `expected-manifest-sha256`, and a `manifest-sha256` output. 7.0.2 (tag only,
  no GitHub release) made agents use a trusted validator and bound
  `verify.sh` to release tags.
  Since 7.0.0 the manifest inventory is complete: files beneath the bundle
  root that MANIFEST.yaml does not list fail verification unless
  `--allow-unlisted` is given.
- Validation fails closed on unsafe or ambiguous paths, duplicates, missing
  inventories, symlink components, and unlisted entries. Packaging revalidates through the
  same policy at each derived-package boundary.
- The stable action reference is `snapsynapse/skill-provenance@v7.1.0`. GitHub Agent
  Skill validation, exact-tag preview, and discovery search all pass.
- Roadmap priorities are portfolio dogfooding, Agent Skill publication,
  evidence-led interop, and later optional signatures.
