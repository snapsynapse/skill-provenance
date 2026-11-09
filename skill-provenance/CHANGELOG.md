# Changelog

This is the active in-bundle changelog. It keeps the five most recent
entries so the skill bundle stays lightweight while recent history still
travels with the package.

Full release history lives in the source repository's top-level
`CHANGELOG.md`.

## 7.0.1 - 2026-11-08
- references/platforms-and-trust.md: Stated that a matching
  `bundle_version` does not show that two copies have the same contents, and
  that `validate.sh --update` is an author tool for recording a reviewed edit,
  not a way to make someone else's mismatched bundle pass.
- evals.json: Added core scenarios for comparing copies that share a version
  label and for refusing to refresh hashes to clear a downloaded bundle's
  mismatch. Coverage is now 45 core, 21 supplemental, and 66 total.
- MANIFEST.yaml: Bumped the bundle to 7.0.1, advanced changed file revisions,
  refreshed notes, and refreshed hashes.
- CHANGELOG.md: Added this entry and retained the newest 5 releases.

## 7.0.0 - 2026-09-23
- validate.sh: The files inventory is now complete. After checking listed
  files, the validator walks the bundle root in pure Bash and reports every
  unlisted file, symlink, or special file as `UNLISTED`. Unlisted entries fail
  verification (exit 1) unless `--allow-unlisted` is given, which reports them
  as warnings without verifying them. Only the root MANIFEST.yaml is exempt.
  Unlisted symlinks are never followed, control characters in reported names
  are escaped, unreadable directories fail closed, and update mode never adds
  unlisted files. Summaries now include an unlisted count. This is a breaking
  change: bundles that previously passed with extra files now fail.
- SKILL.md: Stated the complete-inventory rule, corrected the completeness
  claim, and added unlisted-entry checks to the validate, open, package, and
  close protocols.
- README.md: Documented unlisted-entry reporting, `--allow-unlisted`, update
  behavior for new files, revised exit semantics, and sample output.
- references/platforms-and-trust.md: Stated what a verified manifest shows
  about added files.
- evals.json: Added a core scenario for unlisted-file inventory failure.
  Coverage is now 43 core, 21 supplemental, and 64 total.
- MANIFEST.yaml: Bumped the bundle to 7.0.0, advanced changed file revisions,
  refreshed notes, and refreshed hashes.
- CHANGELOG.md: Added this entry and retained the newest 5 releases.

## 6.3.0 - 2026-09-05
- evals.json: Added a core scenario that separates verified adoption from
  distribution, interest, owner confirmation, and unknown evidence.
- evals-distribution.json: Added three supplemental scenarios covering release
  artifact subject classification, truthful citation metadata before a DOI
  exists, and per-control OpenSSF Scorecard evidence discipline, and required
  archive checks to reject unexpected non-bundle files. Coverage is now 42
  core, 21 supplemental, and 63 total.
- MANIFEST.yaml: Bumped the bundle to 6.3.0, advanced changed file revisions,
  refreshed eval inventory notes, and refreshed hashes.
- CHANGELOG.md: Added this entry and retained the newest 5 releases.

## 6.2.0 - 2026-08-28
- SKILL.md: Added direct routing for no-plugin verification and portable
  bootstrap work while keeping the canonical workflow concise.
- README.md: Added the pinned standalone verifier, bootstrap path, corrected
  stable-release language, exact bundle-versus-GuideCheck tag guidance, and a
  dated adoption-evidence observation with its measurement boundary.
- references/standalone-verification.md: Added inspect-before-run verification
  instructions, validator-pin trust boundaries, exit semantics, and a
  model-agnostic bootstrap prompt that preserves initialization decisions.
- evals.json and evals-distribution.json: Added two core scenarios for
  canonical-parser pinning and safe standalone bootstrap behavior plus one
  supplemental scenario for release tag-family separation, and migrated two
  older scenarios from retired handoffs to durable evidence and roadmap
  sources. Coverage is now 41 core, 18 supplemental, and 59 total.
- MANIFEST.yaml: Bumped the bundle to 6.2.0, advanced changed file revisions,
  inventoried the new reference, refreshed hashes, and recorded release
  validation.
- CHANGELOG.md: Added this entry and retained the newest 5 releases.

## 6.1.0 - 2026-08-20
- SKILL.md: Front-loaded concrete Agent Skill bundle triggers, added the MIT
  license field, and moved detailed packaging and platform guidance into
  direct load-on-demand references. The always-loaded body is now below 500
  lines without removing the operational protocol.
- agents/openai.yaml: Added OpenAI display, trigger, brand, default-prompt, and
  implicit-invocation metadata.
- references/packaging-and-changelog.md: Added the detailed archive,
  exact-inventory, and changelog rules moved out of SKILL.md.
- references/platforms-and-trust.md: Added canonical and derived state,
  ecosystem relationship, platform, and trust-boundary guidance moved out of
  SKILL.md.
- README.md: Added pinned GitHub CLI installation guidance and documented the
  OpenAI metadata surfaces without claiming marketplace publication.
- evals.json and evals-distribution.json: Unchanged because the versioning,
  validation, packaging, and trust contracts remain semantically unchanged.
- MANIFEST.yaml: Bumped the bundle to 6.1.0, advanced changed file versions,
  added new files to inventory, and refreshed hashes.
- CHANGELOG.md: Added this entry and retained the newest 5 releases.

Older entries archived in the source repository's top-level CHANGELOG.md.
