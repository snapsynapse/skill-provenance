# Changelog

This is the active in-bundle changelog. It keeps the five most recent
entries so the skill bundle stays lightweight while recent history still
travels with the package.

Full release history lives in the source repository's top-level
`CHANGELOG.md`.

## 4.10.1 - 2026-05-25
- README.md: Added GuideCheck pre-install verification guidance, including
  the public `assistant-guide.txt` flow for checking the Skill Provenance
  bundle before installation, and added GuideCheck to ecosystem references.
- MANIFEST.yaml: Bumped bundle to 4.10.1, updated bundle_date, advanced
  README.md and CHANGELOG.md per-file versions, and refreshed hashes.

## 4.10.0 — 2026-05-19
- SKILL.md: Added validate-only protocol guidance and clarified how
  Skill Provenance complements source, registry, package-manager, and
  platform versioning.
- README.md: Reframed the guide around portable author-side provenance,
  added a "Why this still exists" section, documented the validate command,
  added complementary-tool guidance, and clarified the trust model.
- evals.json: Added 4 core evals covering validate-only behavior,
  complementary-tool positioning, integrity versus trust-anchor language,
  and derived-copy validation.
- MANIFEST.yaml: Bumped bundle to 4.10.0, updated bundle_date, advanced
  changed file versions, refreshed hashes, and updated eval inventory notes.

## 4.9.1 — 2026-04-23
- evals-distribution.json: Added 4 supplemental repo-integrity evals for
  rolling changelog enforcement, declared eval-count verification,
  repo-doc inventory drift checks, and release metadata alignment.
- MANIFEST.yaml: Bumped bundle to 4.9.1, updated bundle_date, advanced
  evals-distribution.json and CHANGELOG.md per-file versions, and
  refreshed the supplemental eval inventory note.
- CHANGELOG.md: Added this release entry and restored the in-bundle file
  to the documented 5-entry rolling window.

## 4.9.0 — 2026-04-08
- README.md (bundle): Added two use case walkthroughs — verifying a
  downloaded/untrusted bundle, and sharing a skill across a team.
- evals.json: Added 4 new evals (22 → 26 core, 30 total): Settings UI
  .skill ZIP round-trip, Copilot/VS Code bootstrap, Cursor bootstrap,
  Cowork filesystem persistence.
- MANIFEST.yaml: Updated Gemini CLI and Perplexity Computer from
  partial to pass. Bumped per-file versions for README.md, evals.json,
  SKILL.md, and CHANGELOG.md.
- SKILL.md: Version bump only (v15 → v16). No definition changes.
- Plugin system: Added marketplace.json so `claude plugin marketplace
  add` and `claude plugin install` commands work end-to-end. Added
  explicit skills path to plugin.json.
- GitHub Pages: Added skillprovenance.dev landing page with trust/
  integrity narrative, credibility signals, and install instructions
  for Claude Code, Settings UI, ClawHub, Codex, and Gemini CLI.
- README.md (root): Reframed to lead with trust and integrity
  verification. Added audience hooks, Integrity column to comparison
  table, ProSkills.md and ClawHub installs badges.

## 4.8.0 — 2026-03-23
- Added Claude Code plugin infrastructure: `.claude-plugin/plugin.json`
  manifest and `skills/skill-provenance` symlink so the repo doubles as a
  Claude Code plugin without restructuring the existing bundle.
- README.md (root): Added Claude Code plugin install as the first quick
  install method. Updated example version from 4.2.1 to 4.7.3. Added
  `.claude-plugin/` and `skills/` to repo structure diagram.
- SKILL.md: Version bump only (v14 → v15). No definition changes.
- .gitignore: Added `archive/` to exclusions. Historical material remains
  on disk and in git history but no longer ships with the repo.
- MANIFEST.yaml: Bumped bundle to 4.8.0, advanced per-file revisions.

Older entries archived in the source repository's top-level CHANGELOG.md.
