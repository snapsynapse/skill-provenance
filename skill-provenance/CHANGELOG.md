# Changelog

This is the active in-bundle changelog. It keeps the five most recent
entries so the skill bundle stays lightweight while recent history still
travels with the package.

Full release history lives in the source repository's top-level
`CHANGELOG.md`.

## 4.7.2 — 2026-03-09
- SKILL.md: Updated changelog guidance to distinguish between the rolling
  in-bundle changelog and the full repo-level archive.
- README.md: Clarified that the bundle keeps recent changelog history
  while the source repository carries the full archive.
- CHANGELOG.md: Trimmed the in-bundle changelog to the five most recent
  entries and pointed readers to the root changelog for older history.
- MANIFEST.yaml: Bumped bundle to 4.7.2, updated changelog notes, and
  advanced file revisions for the changelog split model.

## 4.7.1 — 2026-03-09
- README.md: Changed derived package instructions to use an in-repo
  `build/` directory by default so strict-platform and ClawHub outputs
  are easier to find locally.
- package.sh: Changed default output locations from `/tmp` to
  `../build/{strict,clawhub}/` relative to the repo so generated
  artifacts stay visible in one place.
- MANIFEST.yaml: Bumped bundle to 4.7.1 and advanced file revisions for
  the updated README, changelog, and package helper.

## 4.7.0 — 2026-03-09
- SKILL.md: Replaced the stale minimal-mode guidance with a consistent
  three-state model: canonical source bundle, strict-platform install
  copy, and registry package. Trimmed packaging prose so the skill stays
  below the 500-line guidance.
- README.md: Updated install and publishing guidance to use the same
  three-state model. Added package helper usage for strict-platform and
  ClawHub outputs.
- evals-distribution.json: New supplemental eval suite covering derived
  strict-platform copies, ClawHub package preparation, publish
  confirmation, and registry-install versus canonical-bundle behavior.
- package.sh: New zero-dependency packaging helper that builds strict
  install copies and ClawHub upload packages from the canonical bundle.
- MANIFEST.yaml: Bumped bundle to 4.7.0, removed the premature
  `deployments.clawhub` record, added the new eval and script files, and
  updated compatibility metadata for derived package generation.

## 4.6.2 — 2026-03-09
- SKILL.md: Added `metadata` block to frontmatter with `author` and `source`
  fields for attribution. Added `## Origin` section at end of body. Both
  changes ensure provenance survives distribution under MIT-0 on ClawHub.
  Changed frontmatter_mode from minimal to metadata.
- README.md: Updated frontmatter_mode references to reflect change to
  metadata mode. Added ClawHub publishing workflow (folder prep, MANIFEST
  stripping, MIT-0 note). Added note that strict-platform users (Codex,
  Gemini CLI) should strip the metadata block before installing.
- MANIFEST.yaml: Bumped bundle to 4.6.2. Added `deployments.clawhub` entry.
  Updated frontmatter_mode to metadata. Advanced file revisions for SKILL.md,
  README.md, and CHANGELOG.md.

## 4.6.1 — 2026-03-07
- evals.json: Added eval 19 (deployment metadata redeploy event), eval 20
  (deployment metadata conflict), eval 21 (hash mismatch in an untrusted
  bundle), and eval 22 (packaged subset vs canonical bundle). Now 22 evals
  total.
- README.md (root): Updated the repo overview to reflect the new eval
  count.
- MANIFEST.yaml: Bumped bundle to 4.6.1, advanced the evals and changelog
  file revisions, and updated the eval inventory note.

## 4.6.0 — 2026-03-07
- SKILL.md: Added optional `deployments` manifest guidance for tracking
  installed or deployed copies across surfaces, extended the session
  protocol to flag deployment drift, documented `.agents/skills/` as an
  emerging neutral install path, and added a trust-and-audit section while
  keeping the skill under the 500-line guidance.
- README.md (bundle): Added 2026 ecosystem context, optional deployment
  metadata guidance, trust-and-audit guidance, `.agents/skills/` install
  note, and updated references for recent skill ecosystem developments.
- evals.json: Added eval 16 (deployment metadata drift), eval 17
  (multi-surface install targets), and eval 18 (trust/audit verification).
  Now 18 evals total.
- README.md (root): Added a 2026 relevance section, trust-and-audit
  framing, neutral install-path note, deployment metadata positioning, and
  updated the eval count.
- MANIFEST.yaml: Bumped bundle to 4.6.0, updated bundle description and
  capability metadata, advanced per-file revisions for changed bundle
  files, and updated the eval inventory note.
