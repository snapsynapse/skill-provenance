# Skill Provenance

A metaskill for version tracking across Agent Skills sessions, surfaces, and platforms. This is a skill bundle project, not a library.

## Key files

- `skill-provenance/SKILL.md` -- the skill definition (what agents read)
- `skill-provenance/MANIFEST.yaml` -- file inventory with roles, versions, SHA-256 hashes
- `skill-provenance/CHANGELOG.md` -- rolling recent history (last 5 entries)
- `skill-provenance/evals.json` -- 22 core evaluation scenarios
- `skill-provenance/evals-distribution.json` -- 4 supplemental distribution evals
- `skill-provenance/validate.sh` -- local hash verification script
- `skill-provenance/package.sh` -- derived copy generator (strict/ClawHub)
- `CHANGELOG.md` -- full append-only repo history
- `AGENTS.md` -- detailed guide for agents working on this repo

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
   cd skill-provenance && zip -r ../skill-provenance.skill . -x '.*'
   ```
