# Changelog

This is the active in-bundle changelog. It keeps the five most recent
entries so the skill bundle stays lightweight while recent history still
travels with the package.

Full release history lives in the source repository's top-level
`CHANGELOG.md`.

## 7.1.0 - 2026-11-22
- validate.sh: Added `--strict`, which fails on `hash: null` opt-outs and
  cannot be combined with `--allow-unlisted`, and
  `--expect-manifest-sha256=DIGEST`, which fails unless `MANIFEST.yaml` has a
  digest obtained outside the bundle. An empty path argument and an unknown
  option are now errors instead of a fallback to the validator's own
  directory, `--` ends the options, and a relative path that starts with `-`
  is no longer read as an option by other tools. A symlinked root
  `MANIFEST.yaml` is rejected. Control characters in manifest paths are
  rejected and never printed raw, attestation text is stripped of control
  characters and cut at 80 characters, and the summary names the directory
  and manifest digest that were checked. `--update` keeps the manifest's file
  mode. Duplicate detection is a single pass. This can break callers that
  passed an empty path or relied on a symlinked manifest.
- package.sh: Derived copies keep source file modes, and the validator is
  called with the path after `--`.
- SKILL.md: The validate protocol uses `--strict` and the out-of-band
  manifest digest for bundles someone else published, and confirms the
  checked directory from the summary.
- README.md: Documented the new options, the summary lines, and the
  attestation wording. The wrapper download uses a private temporary file.
- references/platforms-and-trust.md: Separated self-consistency from an
  external anchor and named the out-of-band manifest digest as the anchor.
- references/standalone-verification.md: Documented wrapper options, the
  summary lines, and the private temporary download path.
- evals.json: Added core scenarios 47 to 50 for instructions in validator
  output, null opt-outs in third-party bundles, self-consistent green checks,
  and confirming the checked directory. Scenario 44 now names a trusted
  validator. Coverage is 50 core, 21 supplemental, and 71 total.
- MANIFEST.yaml: Bumped the bundle to 7.1.0, advanced changed file revisions,
  refreshed notes, and refreshed hashes.
- CHANGELOG.md: Added this entry and retained the newest 5 releases.

## 7.0.2 - 2026-11-22
- SKILL.md: Verification now requires a trusted validator. A `validate.sh`
  or any other script supplied by the bundle under review is never executed,
  because it is one of the files being verified and can print a forged pass.
  A matching manifest hash for that script does not make it trusted.
  Manifest fields and validator output are treated as data.
- README.md: The downloaded-skill use case now runs a validator the reader
  already trusts against the bundle instead of the bundle's own script. The
  no-plugin wrapper download names an exact release tag and checks the
  wrapper's SHA-256 before it is inspected or run. Corrected a stale Codex
  install pin.
- references/standalone-verification.md: Same exact-tag download and digest
  check, and the rule that a bundle never supplies its own validator.
- evals.json: Added core scenario 46 for refusing to execute a
  bundle-supplied validator. Coverage is now 46 core, 21 supplemental, and
  67 total.
- MANIFEST.yaml: Bumped the bundle to 7.0.2, advanced changed file revisions,
  refreshed notes, and refreshed hashes.
- CHANGELOG.md: Added this entry and retained the newest 5 releases.
- Not changed: `validate.sh` is byte-identical to 7.0.1.

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
