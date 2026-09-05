# Changelog

This is the active in-bundle changelog. It keeps the five most recent
entries so the skill bundle stays lightweight while recent history still
travels with the package.

Full release history lives in the source repository's top-level
`CHANGELOG.md`.

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

## 6.0.0 - 2026-07-21
- validate.sh: Added a constrained file-inventory grammar and fail-closed
  rejection for absolute or non-normalized paths, parent traversal,
  ambiguous YAML path syntax, duplicate paths, malformed inventory
  indentation, missing inventories, and symlinks in any path component. Update
  mode no longer partially rewrites structurally invalid manifests. Verify
  summaries no longer call explicitly opted-out files hash-verified. Array
  iteration remains compatible with macOS system Bash 3.2 under nounset.
  Malformed attestation records are now reported without counting as current
  evidence or changing integrity exit codes.
- package.sh: Revalidates the canonical source at each derived-package
  boundary and delegates derived hash updates back to validate.sh, removing
  its duplicate hash-rewrite implementation.
- SKILL.md: Defined the normative inventory grammar, filesystem boundary,
  symlink policy, exact package inventory, evidence-based staleness rule,
  attestation record contract, package delegation, and internal version header.
- README.md: Documented accepted path syntax, rejected path states, update
  behavior, exact archive-to-manifest agreement, malformed attestation
  warnings, package-boundary validation, and internal version header.
- evals.json: Added 4 core scenarios covering unsafe or ambiguous paths,
  duplicates, symlinks, files-section scoping, and malformed attestations;
  corrected stale version-domain and partial-package assumptions; refreshed
  Gemini and Copilot compatibility guidance. Core eval count is now 39.
- evals-distribution.json: Added package-boundary coverage and merged the
  redundant dirty-source package eval into its canonical-source gate.
  Supplemental eval count is now 17; total eval count is now 56.
- MANIFEST.yaml: Bumped the bundle to 6.0.0, advanced changed file versions,
  refreshed hashes and inventory notes, and recorded release validation.
- CHANGELOG.md: Added this entry and retained the newest 5 releases.

## 5.1.0 - 2026-07-16
- MANIFEST.yaml: Added optional `validated_against` attestation block.
  Entries bind a validation event (harness, model, date, result, method)
  to the exact bundle_version they validated — distinct from
  `compatibility.tested_on` design-time claims and from integrity hashes.
  Recorded the first entry for this release.
- validate.sh: Added informational attestation reporting after hash
  results: ATTEST lines for entries matching the current bundle_version,
  and a stale flag when none match. Exit codes are unchanged by
  attestation state — integrity gates, attestation informs.
- SKILL.md: Added `validated_against` to the manifest schema example and
  a rules paragraph on the attestation/integrity boundary.
- README.md: Added the "Attestation: validated_against" section covering
  the two-guarantee distinction and stale semantics.
- evals.json: Added 2 core scenarios covering attestation reporting and
  stale-attestation semantics. Core eval count is now 35; total is 52.
- MANIFEST.yaml: Bumped bundle to 5.1.0, advanced changed file versions,
  refreshed hashes and inventory notes.
- CHANGELOG.md: Added this entry and retained the newest 5 releases.

Older entries archived in the source repository's top-level CHANGELOG.md.
