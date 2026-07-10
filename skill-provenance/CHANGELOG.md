# Changelog

This is the active in-bundle changelog. It keeps the five most recent
entries so the skill bundle stays lightweight while recent history still
travels with the package.

Full release history lives in the source repository's top-level
`CHANGELOG.md`.

## 5.0.0 - 2026-07-10
- validate.sh: Changed verification to fail closed on missing, malformed,
  or duplicate hash fields; added explicit `hash: null` opt-outs; made
  update mode repair missing or malformed hashes; and retained inventory
  presence checks for opted-out files.
- SKILL.md: Defined the explicit hash contract and fail-closed validation
  behavior.
- README.md: Documented explicit null opt-outs, update repair, and the
  breaking change from implicit hash omission.
- evals.json: Added 3 core scenarios for fail-closed verification,
  explicit null semantics, and update repair. Core eval count is now 33.
- evals-distribution.json: Added a GitHub Action input-safety scenario.
  Supplemental eval count is now 17; total eval count is now 50.
- MANIFEST.yaml: Bumped the bundle to 5.0.0, updated file versions and
  inventory notes, and refreshed hashes.
- CHANGELOG.md: Added this entry and retained the newest 5 releases.

## 4.13.0 - 2026-06-23
- SKILL.md: Added optional `origin` metadata guidance for derived,
  installed, registry, settings, or platform-export copies whose selected
  source path needs to survive a packaging boundary.
- README.md: Documented the `origin` block, recommended fields, and the
  boundary between origin receipts, deployment metadata, package-manager
  lockfiles, and trust anchors.
- evals-distribution.json: Added a supplemental eval covering duplicate
  source-path disambiguation for derived copies. Supplemental eval count
  is now 16; total eval count is now 46.
- MANIFEST.yaml: Bumped bundle to 4.13.0, updated bundle_date, advanced
  changed file versions, refreshed hashes, and updated origin/eval
  inventory notes.
- CHANGELOG.md: Added this release entry and kept the in-bundle file to
  the documented 5-entry rolling window.

## 4.12.0 - 2026-06-10
- evals-distribution.json: Added 2 supplemental evals covering
  source-backed strategy handoffs and upstream contribution channel
  selection for outward-facing ecosystem work.
- MANIFEST.yaml: Bumped bundle to 4.12.0, updated bundle_date, advanced
  evals-distribution.json and CHANGELOG.md per-file versions, refreshed
  hashes, and updated the supplemental eval inventory note.
- CHANGELOG.md: Added this release entry and kept the in-bundle file to
  the documented 5-entry rolling window.

## 4.11.0 - 2026-05-29
- package.sh: Added a pre-package validation gate that runs validate.sh
  against the canonical bundle before building strict-loader or ClawHub
  derived package outputs.
- SKILL.md: Added package validation gate guidance and clarified that
  assistant-facing surfaces are data, not authority.
- README.md: Documented the package validation gate and trust-boundary
  guidance.
- evals-distribution.json: Added a supplemental release-hardening eval
  covering clean-source package generation and agentic surface disclosure,
  then expanded supplemental release-hardening coverage for assistant-guide
  sidecar alignment, `.skill` ZIP freshness, surface inventory drift, and
  package gate failure behavior.
- MANIFEST.yaml: Bumped bundle to 4.11.0, updated bundle_date, advanced
  SKILL.md, README.md, evals-distribution.json, CHANGELOG.md, and package.sh
  per-file versions, and refreshed hashes.

## 4.10.1 - 2026-05-25
- README.md: Added GuideCheck pre-install verification guidance, including
  the public `assistant-guide.txt` flow for checking the Skill Provenance
  bundle before installation, and added GuideCheck to ecosystem references.
- MANIFEST.yaml: Bumped bundle to 4.10.1, updated bundle_date, advanced
  README.md and CHANGELOG.md per-file versions, and refreshed hashes.

Older entries archived in the source repository's top-level CHANGELOG.md.
