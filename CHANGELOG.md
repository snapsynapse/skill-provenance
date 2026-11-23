# Full Changelog

This is the complete append-only release history for the `skill-provenance`
repository.

The in-bundle file at `skill-provenance/CHANGELOG.md` is the active changelog
that travels with the skill bundle and keeps only the five most recent entries
to limit package weight. Older history remains here in the repo root.

## guidecheck-1.4.0 - 2026-11-22 (assistant guide only)
Closes the last part of the audit's first High finding: the guide no longer
clones the default branch and runs whatever validator it finds there.
- .well-known/assistant-guide.txt and its root mirror: Guide 1.4.0 pins one
  release. `clone-bundle` clones tag `v7.1.0` instead of the default
  branch. A new read-only `check-release-commit` action prints the commit
  and the guide states the one it must be
  (`582876f7da65ece43f774f3947dbbe1cef457801`). `verify-integrity` declares
  `exec-sha256` for `validate.sh` and runs it with `--expect-manifest-sha256`,
  so the validator itself fails unless the manifest is the 7.1.0 one, which
  also rules out unhashed files. `applies-to` is now `skill-provenance 7.1.0`.
  The acceptance checklist, stop rules, task scope, and threat model say
  what is pinned.
- The guide and sidecar move from GuideCheck profile 0.3.0 to the current
  profile, 2.0.0, and `verifier-conformance` now names verifier
  `>=2.0.0, <3.0.0`. Under 2.0.0 the authority sentence "skip sandboxing"
  became "disable sandboxing": the 2.0.0 scanner only accepts a negated
  list whose items it recognizes, so it read the old sentence as an
  instruction to skip approval gates. The meaning is unchanged.
- GuideCheck reference verifier 2.0.0 result: Level 3. The one blocking
  finding is `anchor.independent.missing`: because the guide declares
  `manifest-url`, 2.0.0 also attempts Level 4, which needs the guide hash on
  an independent channel. Until that exists the verifier answers
  "Proceed? no". 1.3.0, under profile 0.3.0, was Level 2 with an
  unpinned-script finding.
- .well-known/assistant-guide-manifest.txt and its root mirror: guide
  version, digest, byte count, release URL, and release date for 1.4.0.
- .github/scripts/release-surface-check.sh: New `check_assistant_guide_pins`
  fails unless the guide clones an exact tag, `applies-to` names that tag,
  the stated commit is the one the tag names, and the `exec-sha256` and
  manifest digest match the files at that tag. It reports, without failing,
  when the guide pins an older release than the current bundle. It also
  fails when the guide and sidecar name different profile versions, and
  reports whether the DNS anchor at `_assistant-guide.skillprovenance.dev`
  exists and matches the guide hash.
- README.md, SECURITY.md, AGENTIC_SURFACES.md, ROADMAP.md, and
  docs/release-provenance.md: Describe what the guide pins.
- Not changed: the bundle, the validator, and the wrapper. Still open: the
  DNS TXT anchor for the guide hash, which can only be published once this
  guide is final. Every future bundle release now needs a matching guide
  release to move the pin, and every guide release needs the DNS record
  updated.

## 7.1.0 - 2026-11-22
Validator hardening release from the 2026-11-22 repository audit. It closes
the Medium and Low findings that sit in code, and adds the checks that keep
them closed.
- skill-provenance/validate.sh: Added `--strict` (fails on `hash: null`,
  cannot be combined with `--allow-unlisted`) and
  `--expect-manifest-sha256=DIGEST` (binds the run to a manifest digest
  obtained outside the bundle). An empty path argument and an unknown option
  are errors; before, an empty argument fell back to the validator's own
  directory and passed. `--` ends the options, and a relative path that
  starts with `-` is anchored so no tool reads it as an option. A symlinked
  root `MANIFEST.yaml` is rejected. Every control character in a manifest
  path is rejected and report text is escaped, so a manifest cannot erase or
  forge report lines on a terminal. Attestation text has control characters
  replaced and is cut at 80 characters, and the report says it is the
  publisher's unverified claim. The summary names the checked directory and
  the manifest SHA-256. `--update` keeps the manifest's mode instead of
  leaving 0600. Duplicate detection is one pass: a 4,000-entry manifest that
  took over a minute now finishes in seconds. Behavior change: callers that
  passed an empty path or used a symlinked manifest now fail.
- skill-provenance/package.sh: Derived copies keep source file modes; the
  validator is called with the path after `--`.
- action.yml and new action-validate.sh: The action runs a testable entry
  point. New inputs `strict` and `expected-manifest-sha256`, new output
  `manifest-sha256`. The bundle path is passed after `--`, so an empty or
  option-shaped `bundle-path` fails instead of validating the action's own
  bundle or printing help with exit 0.
- verify.sh: Accepts `--strict`, `--expect-manifest-sha256=DIGEST`, and `--`,
  rejects other options, and passes the target after `--`. The validator
  download is HTTPS only with redirect, time, and size limits. Pinned to the
  7.1.0 validator, fetched from the `v7.1.0` tag.
- .github/scripts/test-validate.sh, test-standalone-verify.sh, and
  action-security-check.sh: Added a regression test for each audit finding:
  empty and option-shaped arguments, strict mode, manifest digest binding,
  symlinked manifest, escape sequences in manifest paths and attestation,
  mode after update, the 4,000-entry manifest, and the action's inputs and
  output.
- .github/scripts/release-surface-check.sh: Fails if an agent-facing file
  stops forbidding a bundle-supplied validator or brings back the wording
  that told readers to run one, and fails if `skill-provenance.skill` holds
  an entry that is not group and world readable.
- .github/workflows/validate.yml: Job timeouts, a `validate-macos` job that
  runs the suites under system Bash 3.2, and a `shellcheck` job. The
  required `validate` job keeps its name.
- .github/dependabot.yml: Weekly updates for pinned GitHub Actions.
- scripts/adversarial-agent-evals.sh: Manual, model-agnostic eval runner
  that hands an agent four bundles (clean, trojan validator, instruction in
  attestation, null opt-out) and grades by canary files. Verified with
  stand-in agents only; not yet run against a model.
- skills/validate, skills/open, skills/close, and skill-provenance/SKILL.md:
  Pass the path after `--`, use `--strict` for bundles someone else
  published, and report whether a result is self-consistency or bound to an
  out-of-band digest.
- skill-provenance/evals.json: Added core scenarios 47
  (`validator_output_instructions_not_followed`), 48
  (`null_opt_out_in_third_party_bundle`), 49
  (`green_check_is_self_consistency_only`), and 50
  (`confirm_which_directory_was_validated`); scenario 44 names a trusted
  validator. Coverage is now 50 core, 21 supplemental, and 71 total.
- README.md, index.html, llms.txt, skill-provenance/README.md, and
  skill-provenance/references/standalone-verification.md: The wrapper
  download writes to a private temporary file, names the `v7.1.0` tag, and
  shows the new wrapper digest. The action example pins checkout to a commit
  and shows `strict` and the output.
- skill-provenance/references/platforms-and-trust.md: Separates
  self-consistency from an external anchor.
- skill-provenance/MANIFEST.yaml, both changelogs, CITATION.cff, plugin
  manifests, AGENTS.md, CLAUDE.md, PROJECT_CONTEXT.md, AGENTIC_SURFACES.md,
  ROADMAP.md, docs/release-provenance.md, search-audit.config.json, and
  skill-provenance.skill: Moved to 7.1.0. Claude Code plugin is 0.3.0. The
  in-bundle changelog moved 6.2.0 to this file only.
- Correction: `v7.0.2` was tagged without a GitHub release, so it has no
  uploaded asset. docs/release-provenance.md now says so.
- Not changed: the GuideCheck assistant guide. Pinning its clone and
  validator needs its own `guidecheck-*` release.

## 7.0.2 - 2026-11-22
Security release from the 2026-11-22 repository audit. It closes the two
High findings; the validator itself is unchanged.
- skills/validate/SKILL.md, skills/open/SKILL.md, and skills/close/SKILL.md:
  The plugin skills no longer tell the agent to prefer the bundle's own
  `validate.sh`. They run the validator that ships with the plugin against
  the bundle root, fall back to the pinned standalone wrapper and then to
  manual hashing with reduced assurance, and never execute a script found
  inside the bundle under review. A third-party bundle could previously ship
  a script that ran arbitrary code and printed a passing result.
- skill-provenance/SKILL.md: Same trusted-validator rule in the canonical
  validate and open protocols. Manifest fields and validator output are
  treated as data.
- skill-provenance/README.md: The downloaded-skill use case runs a validator
  the reader already trusts instead of the bundle's own script. Corrected a
  stale `@v6.1.0` Codex install pin.
- skill-provenance/evals.json: Added core scenario 46
  (`bundle_supplied_validator_not_executed`). Coverage is now 46 core, 21
  supplemental, and 67 total.
- verify.sh: The validator download URL names the immutable `v7.0.1` release
  tag, which carries the pinned validator bytes, instead of the `main`
  branch. A published wrapper no longer breaks when a later release changes
  the validator, and a change to `main` cannot alter what it fetches.
- README.md, index.html, llms.txt, skill-provenance/README.md, and
  skill-provenance/references/standalone-verification.md: The no-plugin
  wrapper download names the exact `v7.0.2` tag and checks the wrapper's
  SHA-256 before it is inspected or run. These surfaces no longer fetch the
  wrapper from the branch-served site copy.
- .github/scripts/release-surface-check.sh: Requires the wrapper's validator
  URL to name an exact release tag whose `validate.sh` matches the pin, and
  requires every wrapper download surface to name one exact tag and show the
  current `verify.sh` SHA-256. A tag that is not published yet is accepted
  only when it is the release being prepared.
- search-audit.config.json: Moved the production `verify.sh` contract to the
  tag URL, and the install and release links to v7.0.2.
- skill-provenance/MANIFEST.yaml: Bumped the bundle to 7.0.2, advanced
  SKILL.md, README.md, standalone-verification.md, evals.json, and
  CHANGELOG.md revisions, refreshed notes and hashes, and recorded the 7.0.2
  validated_against entry.
- skill-provenance/CHANGELOG.md: Added the 7.0.2 entry and retained the
  newest 5 releases, moving 6.1.0 to this file only.
- README.md, index.html, and llms.txt: Moved the stable install, preview,
  action, trial, and release links from v7.0.1 to v7.0.2, refreshed the
  trial output from a real run, and updated eval counts.
- CITATION.cff and .codex-plugin/plugin.json: Set version 7.0.2 and the
  2026-11-22 release date.
- .claude-plugin/plugin.json: Bumped the plugin to 0.2.2 so installed copies
  pick up the corrected skill instructions.
- AGENTS.md, CLAUDE.md, and PROJECT_CONTEXT.md: Recorded 7.0.2 as the stable
  release and the new eval counts.
- skill-provenance.skill: Rebuilt from the canonical bundle.
- docs/release-provenance.md: Recorded the v7.0.2 asset size and digest.
- Not changed: `skill-provenance/validate.sh` and the GuideCheck assistant
  guide. The guide still clones the default branch and runs that checkout's
  validator; pinning it needs its own GuideCheck release.
- SECURITY.md and ROADMAP.md: Recorded the trusted-validator rule, the new
  `main` branch ruleset, and the audit items still open.
- Repository setting, not a file: `main` gained a branch ruleset on
  2026-11-22 (pull request required, `validate` check required, signed
  commits required, force push and deletion blocked, no bypass actors).

## 2026-11-08 - Search-audit decoder fix (repo only)
- scripts/check-search.mjs and scripts/check-production-search.mjs:
  Re-vendored asset version 6 from the portfolio-search-indexing-audit skill
  (bundle 8, upstream commit f76bdef). `decode()` now decodes XML entities in
  a single pass, so `&amp;lt;` stays `&lt;` instead of becoming `<`. This
  resolves CodeQL `js/double-escaping` alerts 1 and 2. The repository search
  contract remains version 4.
- The hashed bundle is unchanged; no version bump.

## 7.0.1 - 2026-11-08
- skill-provenance/references/platforms-and-trust.md: Stated that a
  matching `bundle_version` does not show that two copies have the same
  contents, and that `validate.sh --update` is an author tool for recording a
  reviewed edit, not a way to make someone else's mismatched bundle pass.
- skill-provenance/evals.json: Added core scenarios 44
  (`same_version_label_changed_content`) and 45
  (`refuse_update_to_clear_mismatch`). Coverage is now 45 core, 21
  supplemental, and 66 total.
- skill-provenance/MANIFEST.yaml: Bumped the bundle to 7.0.1, advanced
  evals.json, platforms-and-trust.md, and CHANGELOG.md revisions, refreshed
  notes and hashes, and recorded the 7.0.1 validated_against entry for
  Anthropic Claude Code with claude-opus-5-5.
- skill-provenance/CHANGELOG.md: Added the 7.0.1 entry and retained the
  newest 5 releases, moving 6.0.0 to this file only.
- README.md, index.html, llms.txt, and search-audit.config.json: Moved the
  stable install, preview, action, trial, and release links from v7.0.0 to
  v7.0.1, and updated eval counts.
- CITATION.cff and .codex-plugin/plugin.json: Set version 7.0.1 and the
  2026-11-08 release date.
- AGENTS.md, CLAUDE.md, and PROJECT_CONTEXT.md: Recorded 7.0.1 as the stable
  release and the new eval counts.
- skill-provenance.skill: Rebuilt from the canonical bundle.
- .well-known/assistant-guide.txt and its root mirror: Released GuideCheck
  guide 1.3.0. It now applies to `skill-provenance >=7.0.0, <8.0.0` (1.2.0
  still declared `<7.0.0`) and treats unlisted entries as an incomplete
  check, matching 7.x validation. The sidecar manifest and its mirror carry
  the new version, digest, size, release URL, and release date.
- docs/release-provenance.md: Recorded the v7.0.1 asset size and digest and
  the guidecheck-1.3.0 assets.

## 2026-11-08 - Actions pinning and roadmap sync (repo only)
- .github/workflows/validate.yml and .github/workflows/production-search.yml:
  Pinned `actions/checkout` to commit
  11d5960a326750d5838078e36cf38b85af677262 (v4.4.0) instead of the mutable
  `v4` tag.
- ROADMAP.md: Marked Actions pinning done, leaving `main` branch governance
  as the open item. Reworded the signing entry to record that commits and
  bundle release tags are already SSH-signed; Zenodo and DOI remain open.
- The hashed bundle is unchanged; no version bump.

## 2026-11-08 - README changed-bundle trial and drift check (repo only)
- README.md: Opened with a runnable changed-bundle trial against v7.0.0
  (clean exit 0, changed `SKILL.md` with unchanged manifest exits 1 with
  `MISMATCH`), a guide to checking an existing bundle, and an exit-code
  table. Moved the tagline, adoption-report route, and dated 5.5 percent
  observation below it.
- .github/scripts/release-surface-check.sh: Added `check_readme_trial`,
  which re-runs the README trial against a temporary copy of the canonical
  bundle and fails when the displayed tag, version label, change command,
  output lines, digests, counts, or exit codes drift from the validator.
- AGENTS.md and CLAUDE.md: Recorded that bundle releases must refresh the
  README trial block from a real run.
- The hashed bundle is unchanged; no version bump.

## 2026-09-23 - 7.0.0 release surfaces
- skill-provenance/MANIFEST.yaml: Recorded the 7.0.0 validated_against
  entry for Anthropic Claude Code with claude-opus-5-5.
- README.md, index.html, llms.txt, and search-audit.config.json: Moved the
  stable install, preview, action, and release links from v6.3.0 to v7.0.0.
- CITATION.cff and .codex-plugin/plugin.json: Set version 7.0.0 and the
  2026-09-23 release date.
- CLAUDE.md, PROJECT_CONTEXT.md, and ROADMAP.md: Recorded 7.0.0 as the
  stable release and its breaking complete-inventory change.
- docs/release-provenance.md: Recorded the v7.0.0 release asset size and
  digest.
- docs/standards-integration-status.md: Marked 7.0.0 as released.
- skill-provenance.skill: Rebuilt from the canonical bundle.

## 2026-09-23 - Status note inventory correction (repo only)
- docs/standards-integration-status.md: Updated the minimal provenance
  contract. Unlisted files now fail verification as of bundle 7.0.0, so the
  note no longer records the validator as unable to detect additions; the
  2026-09-24 observation is kept as the history of the gap.

## Unreleased - 2026-09-23
- search-audit.config.json: Repinned the verify.sh search contract to the
  7.0.0 validator SHA-256. The stale pin failed the repository search check,
  the first CI step, after the 7.0.0 merge.
- .github/scripts/release-surface-check.sh: Required the search contract's
  verify.sh pin to match the current validator hash so the two pins cannot
  drift apart again.

## 7.0.0 - 2026-09-23
- skill-provenance/validate.sh: Closed the unlisted-file gap observed
  2026-09-24, where a bundle containing a file absent from MANIFEST.yaml still
  verified with exit 0. The validator now walks the bundle root in pure Bash
  and reports every unlisted file, symlink, or special file as `UNLISTED`.
  Unlisted entries fail verification (exit 1) unless `--allow-unlisted` is
  given, which reports them as warnings without verifying them. Only the root
  MANIFEST.yaml is exempt. Unlisted symlinks are never followed, control
  characters in reported names are escaped so filenames cannot forge report
  lines, unreadable directories fail closed, and update mode never adds
  unlisted files. Summaries now include an unlisted count. Breaking: bundles
  that previously passed with extra files now fail.
- .github/scripts/test-validate.sh: Added regression fixtures for root,
  nested, dotfile, nested-manifest, symlinked-directory, dangling-symlink,
  FIFO, forged-newline, and unreadable-directory entries, empty directories,
  `--allow-unlisted` in either argument position, and update mode refusing to
  rewrite or extend the manifest. Cleaned up earlier fixtures that now count
  as unlisted. Passes under Bash 5.3 and macOS system Bash 3.2.
- skill-provenance/SKILL.md, skill-provenance/README.md, and
  skill-provenance/references/platforms-and-trust.md: Corrected the
  completeness claim, stated the complete-inventory rule and its only
  exemption, and documented `--allow-unlisted`, new-file workflow, and exit
  semantics.
- skill-provenance/evals.json: Added a core scenario for unlisted-file
  inventory failure. Coverage is now 43 core, 21 supplemental, and 64 total.
- skill-provenance/MANIFEST.yaml and skill-provenance/CHANGELOG.md: Prepared
  bundle 7.0.0, advanced per-file versions, refreshed hashes and notes, and
  rolled the in-bundle history to the newest 5 entries.
- verify.sh: Repinned the standalone wrapper to the new validator SHA-256.
- skills/validate/SKILL.md, skills/open/SKILL.md, and skills/close/SKILL.md:
  Added unlisted-entry reporting and the list-before-update rule.
- README.md, AGENTS.md, SECURITY.md, and AGENTIC_SURFACES.md: Updated
  verification comments, exit semantics, in-scope threats, and surface trust
  boundaries for unlisted files.
- README.md, AGENTS.md, CLAUDE.md, PROJECT_CONTEXT.md, and index.html:
  Synchronized eval counts to 43 core and 64 total. Public install and
  release links remain on the published v6.3.0 release until 7.0.0 is tagged.
- skill-provenance.skill: Rebuilt from the canonical bundle.

## Unreleased - 2026-09-05
- README.md, index.html, llms.txt, search-audit.config.json, PROJECT_CONTEXT.md,
  CLAUDE.md, and ROADMAP.md: Synchronized stable install links, release state,
  GitHub Agent Skill discovery status, and post-release adoption work after
  v6.2.0 publication. The immutable v6.2.0 bundle and archive are unchanged.
- CITATION.cff, docs/adoption-evidence.md,
  .github/ISSUE_TEMPLATE/compatibility-report.yml, and README.md: Added
  citation metadata plus a reproducible compatibility and verified-adoption
  evidence path without treating distribution or interest as production use.
- docs/release-provenance.md, audits/openssf-scorecard-2026-09-05.json,
  PROJECT_CONTEXT.md, and ROADMAP.md: Classified release artifacts, recorded a
  read-only per-control trust baseline, and routed signing, attestations,
  governance, DOI publication, and OpenSSF programs to later gated work.
- .github/scripts/release-surface-check.sh and ROADMAP.md: Closed the observed
  release-check gap by requiring exact archive inventory agreement, including
  rejection of ignored operating-system metadata; the candidate archive was
  cleaned before release.

## 6.3.0 - 2026-09-05
- CITATION.cff, docs/adoption-evidence.md,
  .github/ISSUE_TEMPLATE/compatibility-report.yml, and README.md: Added
  citation metadata plus a reproducible compatibility and verified-adoption
  evidence path without treating distribution or interest as production use.
- docs/release-provenance.md, audits/openssf-scorecard-2026-09-05.json,
  PROJECT_CONTEXT.md, and ROADMAP.md: Classified release artifacts, recorded a
  read-only per-control trust baseline, and routed signing, attestations,
  governance, DOI publication, and OpenSSF programs to later gated work.
- .github/scripts/release-surface-check.sh: Required exact `.skill` archive
  inventory agreement so ignored or incidental files cannot pass the release
  gate merely because every required file is present.
- skill-provenance/evals.json: Added a core verified-adoption evidence
  scenario that keeps distribution, interest, private confirmation, and
  unknown evidence distinct.
- skill-provenance/evals-distribution.json: Added three supplemental scenarios
  for release artifact subjects, citation metadata without an unresolved DOI,
  and per-control Scorecard evidence discipline, and strengthened archive
  inventory evaluation to reject unexpected non-bundle files. Coverage is now
  42 core and 21 supplemental scenarios, 63 total.
- skill-provenance/MANIFEST.yaml and skill-provenance/CHANGELOG.md: Prepared
  bundle 6.3.0, advanced changed file revisions, refreshed hashes and rolling
  history, and retained the newest five portable release entries.
- README.md, AGENTS.md, CLAUDE.md, PROJECT_CONTEXT.md, index.html, llms.txt,
  sitemap.xml, search-audit.config.json, CITATION.cff, and
  .codex-plugin/plugin.json: Updated evaluation counts, version metadata,
  stable-release references, and dated search surfaces for 6.3.0.
- skill-provenance.skill: Rebuilt the Claude Settings ZIP from the canonical
  6.3.0 bundle.

## 6.2.0 - 2026-08-28
- skill-provenance/SKILL.md, skill-provenance/README.md, and
  skill-provenance/references/standalone-verification.md: Added no-plugin
  verification, a portable bootstrap path, validator-pin trust boundaries,
  exact bundle-versus-GuideCheck tag guidance, corrected stable-release
  language, and dated adoption evidence.
- verify.sh, .github/scripts/test-standalone-verify.sh,
  .github/scripts/release-surface-check.sh, and
  .github/workflows/validate.yml: Added a pinned canonical-validator wrapper,
  local and downloaded tamper rejection, exit-code and cleanup coverage,
  non-flaky archive inventory checks, release-surface enforcement, and CI
  execution.
- skill-provenance/evals.json and skill-provenance/evals-distribution.json:
  Added two core scenarios covering canonical parser pinning and bootstrap
  decision gates plus one supplemental scenario for release tag-family
  separation, and migrated two older scenarios from retired handoffs to
  durable evidence and roadmap sources. Coverage is now 41 core and 18
  supplemental scenarios, 59 total.
- docs/state-of-skill-versioning-2026.md, README.md, index.html, llms.txt,
  sitemap.xml, AGENTIC_SURFACES.md, PROJECT_CONTEXT.md, ROADMAP.md, AGENTS.md,
  and CLAUDE.md: Added the dated ecosystem observation and reproduction
  boundary, exposed the standalone path and GitHub Pages agent surfaces,
  corrected public-release truth and eval counts, documented source authority,
  and migrated durable roadmap and session state.
- search-audit.config.json and ops/search-indexing.md: Added the deployed
  standalone verifier, release tag-family copy, and agent-surface links to
  deterministic repository and production search contracts while preserving
  the historical console baseline.
- .codex-plugin/plugin.json: Advanced package metadata to 6.2.0 and disclosed
  standalone verification and bootstrap capability.
- skill-provenance/MANIFEST.yaml, skill-provenance/CHANGELOG.md, and
  skill-provenance.skill: Prepared bundle 6.2.0, advanced file revisions,
  refreshed hashes and rolling history, recorded validation, and rebuilt the
  derived archive.

## 6.1.0 - 2026-08-20
- skill-provenance/SKILL.md, skill-provenance/agents/openai.yaml,
  skill-provenance/references/packaging-and-changelog.md, and
  skill-provenance/references/platforms-and-trust.md: Improved concrete agent
  triggering, added OpenAI interface metadata, and moved deep package and
  platform guidance into direct references so the canonical body stays under
  500 lines.
- skill-provenance/README.md and root README.md: Added pinned GitHub CLI
  preview and Codex installation guidance, documented the Codex plugin
  package, and avoided claims of unpublished marketplace availability.
- skills/open/SKILL.md, skills/validate/SKILL.md, skills/close/SKILL.md,
  skills/handoff/SKILL.md, and skills/bootstrap/SKILL.md: Added the names and
  licenses required for GitHub Agent Skill publication validation while
  preserving existing Claude plugin command names.
- .codex-plugin/plugin.json and .claude-plugin/plugin.json: Added the Codex
  plugin package and advanced the Claude plugin patch version for synchronized
  discovery metadata.
- search-audit.config.json, scripts/check-search.mjs,
  scripts/check-production-search.mjs, ops/search-indexing.md,
  .github/workflows/validate.yml, and
  .github/workflows/production-search.yml: Added deterministic repository and
  manually triggered production search contracts plus the dated GSC action
  ledger.
- .well-known/assistant-guide.txt and its sidecar: Advanced the guide to 1.2.0,
  repaired its cloned-repository working directory, updated bundle
  applicability to 6.1.x, and refreshed its hash and planned immutable release
  metadata.
- index.html, sitemap.xml, AGENTIC_SURFACES.md, PROJECT_CONTEXT.md, CLAUDE.md,
  and ROADMAP.md: Updated public discovery copy, modified dates, surface
  disclosures, current state, and release sequencing.
- skill-provenance/MANIFEST.yaml, skill-provenance/CHANGELOG.md, and
  skill-provenance.skill: Prepared bundle 6.1.0, advanced file revisions,
  refreshed hashes and rolling history, and rebuilt the derived archive.
- skill-provenance/evals.json and skill-provenance/evals-distribution.json:
  Unchanged because the operational contracts remain semantically unchanged.

## 6.0.0 - 2026-07-21
- skill-provenance/validate.sh: Added a constrained, fail-closed inventory
  grammar; rejected absolute and non-normalized paths, parent traversal,
  ambiguous YAML path syntax, duplicate paths, malformed inventory
  indentation, missing inventories, and symlinks in any path component before
  filesystem reads. Prevented update mode from partially rewriting an
  invalid manifest and corrected success summaries so explicit null-hash
  opt-outs are not described as hash-verified. Added non-gating warnings for
  malformed attestation records and excluded them from current evidence.
- skill-provenance/package.sh: Revalidated the canonical source at every
  derived-package boundary and delegated derived hash updates to validate.sh,
  removing the duplicate hash-rewrite implementation.
- .github/scripts/test-validate.sh: Added executable regression fixtures for
  traversal, absolute paths, dot and empty components, backslashes, YAML
  quoting/comments/anchors/aliases/tags, malformed indentation, missing
  inventories, duplicate paths, symlinks, legitimate nested paths, parser
  section isolation, and macOS system Bash 3.2 compatibility.
- skill-provenance/SKILL.md, skill-provenance/README.md, SECURITY.md, and
  AGENTIC_SURFACES.md: Documented the manifest filesystem boundary, accepted
  grammar, exact package inventory, evidence-based staleness, malformed
  attestation semantics, package delegation, trust boundary, residual risks,
  and reconciled internal file-version headers with the manifest.
- skill-provenance/evals.json and skill-provenance/evals-distribution.json:
  Added 4 core scenarios, added and consolidated package-boundary coverage,
  corrected stale package and version-domain assumptions, and refreshed
  platform paths. Coverage is now 39 core and 17 supplemental, 56 total.
- skill-provenance/MANIFEST.yaml and skill-provenance/CHANGELOG.md: Prepared
  bundle 6.0.0, advanced per-file versions, refreshed hashes and rolling
  history, and recorded release validation.
- README.md, AGENTS.md, CLAUDE.md, PROJECT_CONTEXT.md, ROADMAP.md, index.html,
  and sitemap.xml: Updated release metadata, eval counts, current project
  state, roadmap priorities, action example, and public modified dates.
- skills/open/SKILL.md, skills/validate/SKILL.md,
  skills/bootstrap/SKILL.md, and skills/close/SKILL.md: Synchronized focused
  plugin workflows with constrained grammar, exact hash opt-outs,
  evidence-based staleness, derived strict packaging, and final validation.
- skill-provenance.skill: Rebuilt the Claude Settings ZIP from the canonical
  6.0.0 bundle.

## 5.1.0 - 2026-07-16
- skill-provenance/MANIFEST.yaml: Added optional `validated_against`
  attestation block. Entries bind a validation event (harness, model,
  date, result, method) to the exact bundle_version they validated —
  distinct from `compatibility.tested_on` design-time claims and from
  integrity hashes. Recorded the first entry for this release.
- skill-provenance/validate.sh: Added informational attestation reporting
  after hash results: ATTEST lines for entries matching the current
  bundle_version, and a stale flag when none match. Exit codes are
  unchanged by attestation state — integrity gates, attestation informs.
- skill-provenance/SKILL.md: Added `validated_against` to the manifest
  schema example and a rules paragraph on the attestation/integrity
  boundary.
- skill-provenance/README.md: Added the "Attestation: validated_against"
  section covering the two-guarantee distinction and stale semantics.
- skill-provenance/evals.json: Added 2 core scenarios covering attestation
  reporting and stale-attestation semantics. Core eval count is now 35;
  total is 52.
- .github/scripts/test-validate.sh: Added regression tests asserting that
  attestation state (matching, stale, or absent) never changes validate.sh
  exit codes and that ATTEST reporting renders in both cases.
- README.md, AGENTS.md, CLAUDE.md: Updated eval-count declarations to 35
  core / 52 total.
- skill-provenance/MANIFEST.yaml: Bumped bundle to 5.1.0, advanced changed
  file versions, refreshed hashes and inventory notes.

## 5.0.0 - 2026-07-10
- skill-provenance/validate.sh: Made manifest verification fail closed on
  missing, malformed, or duplicate hash fields; added explicit
  `hash: null` opt-outs; repaired missing or malformed hashes in update
  mode; and kept inventory checks active for opted-out files.
- action.yml: Transported caller-controlled `bundle-path` through an
  environment variable instead of interpolating it into Bash source.
- .github/scripts/action-security-check.sh,
  .github/scripts/test-validate.sh, .github/workflows/validate.yml: Added
  and enabled regression coverage for action input transport and validator
  hash-state behavior.
- skill-provenance/SKILL.md and skill-provenance/README.md: Defined and
  documented the explicit hash contract and breaking fail-closed behavior.
- skill-provenance/evals.json: Added 3 core security and recovery evals.
- skill-provenance/evals-distribution.json: Added a composite-action shell
  safety eval. Coverage is now 33 core and 17 supplemental, 50 total.
- skill-provenance/MANIFEST.yaml and skill-provenance/CHANGELOG.md: Bumped
  the canonical bundle to 5.0.0, advanced per-file versions, updated the
  rolling history, and refreshed inventory metadata.
- README.md, AGENTS.md, CLAUDE.md, AGENTIC_SURFACES.md, and index.html:
  Updated eval counts, executable-surface disclosure, release version, and
  public modified date.
- skill-provenance.skill: Rebuilt the Claude Settings ZIP from the
  canonical 5.0.0 bundle.

## 4.13.1 - 2026-06-23
- action.yml: Added a root GitHub Actions Marketplace composite action
  wrapper that runs `skill-provenance/validate.sh` against a configurable
  bundle path.
- .github/workflows/validate.yml: Switched the manifest validation step to
  use the local action so the Marketplace wrapper is exercised in CI.
- AGENTIC_SURFACES.md: Added the new GitHub Actions Marketplace surface
  and its trust boundary.
- README.md, AGENTS.md, CLAUDE.md: Documented the Marketplace action and
  updated repo inventories.
- Bundle unchanged: `skill-provenance/MANIFEST.yaml`,
  `skill-provenance/CHANGELOG.md`, and `skill-provenance.skill` remain at
  4.13.0 because this change only adds a repo-level GitHub Actions
  distribution surface.

## 4.13.0 - 2026-06-23
- skill-provenance/SKILL.md: Added optional `origin` metadata guidance for
  derived, installed, registry, settings, or platform-export copies whose
  selected source path needs to survive a packaging boundary.
- skill-provenance/README.md: Documented the `origin` block, recommended
  fields, and the boundary between origin receipts, deployment metadata,
  package-manager lockfiles, and trust anchors.
- skill-provenance/evals-distribution.json: Added a supplemental eval
  covering duplicate source-path disambiguation for derived copies.
  Supplemental eval count is now 16; total eval count is now 46.
- skill-provenance/CHANGELOG.md: Added this release entry and kept the
  in-bundle file to the documented 5-entry rolling window.
- skill-provenance/MANIFEST.yaml: Bumped bundle to 4.13.0, updated
  bundle_date, advanced changed file versions, refreshed hashes, and
  updated origin/eval inventory notes.
- README.md, AGENTS.md, CLAUDE.md: Updated declared supplemental and total
  eval counts where applicable.
- index.html: Updated visible release version, modified date, and eval
  scenario count.
- skill-provenance.skill: Rebuilt the Claude Settings ZIP wrapper from
  the updated canonical bundle.

## 4.12.0 - 2026-06-10
- skill-provenance/evals-distribution.json: Added 2 supplemental evals
  covering source-backed strategy handoffs and upstream contribution
  channel selection for outward-facing ecosystem work. Supplemental eval
  count is now 15; total eval count is now 45.
- skill-provenance/CHANGELOG.md: Added this release entry and kept the
  in-bundle file to the documented 5-entry rolling window.
- skill-provenance/MANIFEST.yaml: Bumped bundle to 4.12.0, updated
  bundle_date, advanced changed file versions, refreshed hashes, and
  updated the supplemental eval inventory note.
- README.md, AGENTS.md, CLAUDE.md: Updated declared supplemental and
  total eval counts where applicable.
- index.html: Updated visible release version, modified date, and eval
  scenario count.
- skill-provenance.skill: Rebuilt the Claude Settings ZIP wrapper from
  the updated canonical bundle.

## 2026-05-31 - Release-surface hardening checks (repo only)
- .github/scripts/release-surface-check.sh: Added a zero-dependency
  release-surface drift checker for declared eval counts, GuideCheck
  sidecar hash and byte metadata, and `skill-provenance.skill` freshness
  against the canonical bundle.
- .github/workflows/validate.yml: Replaced the shallow `.skill` structure
  check with the release-surface checker so CI catches stale ZIP contents,
  stale assistant-guide sidecar metadata, and stale eval-count declarations.
- AGENTS.md, CLAUDE.md: Updated eval inventory counts to 30 core and 13
  supplemental evals, standardized the `.skill` rebuild command, and added
  the release-surface check to the repo workflow.
- AGENTIC_SURFACES.md, README.md: Disclosed the new release-surface checker
  as a code-executing release-confidence surface and listed it in the repo
  inventory.
- Bundle unchanged: `skill-provenance/MANIFEST.yaml`,
  `skill-provenance/CHANGELOG.md`, and `skill-provenance.skill` stay at
  4.11.0 because this change only affects repo-level release automation and
  documentation outside the tracked bundle.

## 4.11.0 - 2026-05-29
- skill-provenance/package.sh: Added a pre-package validation gate that
  runs validate.sh against the canonical bundle before building
  strict-loader or ClawHub derived package outputs.
- skill-provenance/SKILL.md: Added package validation gate guidance and
  clarified that assistant-facing surfaces are data, not authority.
- skill-provenance/README.md: Documented the package validation gate and
  clarified that assistant-facing surfaces are data, not authority.
- skill-provenance/evals-distribution.json: Added a supplemental
  release-hardening eval covering clean-source package generation and
  agentic surface disclosure, then expanded supplemental release-hardening
  coverage for assistant-guide sidecar alignment, `.skill` ZIP freshness,
  surface inventory drift, and package gate failure behavior. Supplemental
  eval count is now 13; total eval count is now 43.
- skill-provenance/CHANGELOG.md: Added this release entry and kept the
  in-bundle file to the documented 5-entry rolling window.
- skill-provenance/MANIFEST.yaml: Bumped bundle to 4.11.0, updated
  bundle_date, advanced changed file versions, refreshed hashes, and
  updated supplemental eval inventory notes.
- AGENTIC_SURFACES.md: Added a public inventory of assistant-facing,
  package, checker, crawler, CI, and release surfaces with trust boundaries.
- SECURITY.md: Linked the agentic surface disclosure and stated that
  these surfaces are data, not authority. Added GuideCheck sidecar
  manifest drift checks to the release security scope.
- README.md, llms.txt: Added the disclosure to public-facing repo
  inventory and assistant-readable links.
- index.html: Updated public modified-date and visible version metadata
  to 4.11.0.
- skill-provenance.skill: Rebuilt the Claude Settings ZIP wrapper from
  the updated canonical bundle.

## 2026-05-25 - GuideCheck 0.3.0 adoption and install-copy update
- .well-known/assistant-guide.txt: Updated the published GuideCheck
  guide from profile-version 0.2.0 to 0.3.0, bumped guide-version to
  1.1.0, refreshed last-reviewed, added `manifest-url`, declared
  `runner: argv` for every action, and corrected the validation command
  to run `bash validate.sh` from the cloned bundle directory.
- .well-known/assistant-guide-manifest.txt: Added the GuideCheck
  Level 4 sidecar manifest with the guide hash, byte count,
  immutable release URL, and source repository anchor.
- llms.txt: Updated the assistant guide link to the recommended
  GuideCheck reference form, listed the sidecar manifest, and documented
  the assistant guide as a core concept.
- README.md, index.html: Updated install instructions and public-facing
  copy to point users to the GuideCheck pre-install integrity check before
  installing from public sources.
- SECURITY.md: Clarified that the GuideCheck assistant guide makes
  pre-install verification reviewable but does not certify safety or trust.
- skill-provenance/README.md: Added GuideCheck pre-install verification
  guidance and ecosystem reference.
- skill-provenance/CHANGELOG.md, skill-provenance/MANIFEST.yaml:
  Released bundle patch 4.10.1 for the in-bundle README documentation
  update and refreshed hashes.

## 2026-05-21 — GuideCheck standard adoption (site, no bundle change)
- .well-known/assistant-guide.txt: Added a Level 3 conforming
  `assistant-guide.txt` under the GuideCheck Human-Verifiable Assistant
  Guide profile (profile-version 0.2.0, guide-version 1.0.1). Bounded
  task: fetch the bundle and integrity-check it against MANIFEST.yaml.
  ASCII byte profile, 6878 bytes, two approval-gated action blocks.
  guide-version 1.0.0 verified at Level 2: a negated mention of a
  chained-guide phrase tripped the verifier prohibited-pattern check.
  1.0.1 drops that sentence; the no-chaining property holds by absence.
- index.html: Added a `<link rel="assistant-guide">` discovery aid to the
  document head.
- llms.txt: Listed the assistant guide under Links.
- Bundle unchanged: bundle_version stays 4.10.0, MANIFEST.yaml untouched.

## 4.10.0 — 2026-05-19
- skill-provenance/SKILL.md: Added validate-only protocol guidance and
  clarified how Skill Provenance complements source, registry,
  package-manager, and platform versioning.
- skill-provenance/README.md: Reframed the guide around portable
  author-side provenance, added a "Why this still exists" section,
  documented the validate command, added complementary-tool guidance, and
  clarified the trust model.
- skill-provenance/evals.json: Added 4 core evals covering validate-only
  behavior, complementary-tool positioning, integrity versus trust-anchor
  language, and derived-copy validation.
- skill-provenance/MANIFEST.yaml: Bumped bundle to 4.10.0, updated
  bundle_date, advanced changed file versions, refreshed hashes, and
  updated eval inventory notes.
- skill-provenance/CHANGELOG.md: Added this release entry and kept the
  in-bundle rolling changelog to the newest 5 entries.
- skills/validate/SKILL.md: Added a focused Claude Code plugin command for
  hash and inventory validation without open, close, or handoff behavior.
- .claude-plugin/plugin.json: Bumped plugin version to 0.2.0 and registered
  the validate command.
- README.md, index.html, llms.txt, ROADMAP.md, SECURITY.md: Updated public
  positioning around portable provenance, complementary ecosystem tools,
  validate command availability, and the integrity-check trust model.

## 4.9.1 — 2026-04-23
- evals-distribution.json: Added 4 supplemental repo-integrity evals for
  rolling changelog enforcement, declared eval-count verification,
  repo-doc inventory drift checks, and release metadata alignment.
- MANIFEST.yaml: Bumped bundle to 4.9.1, updated bundle_date, advanced
  evals-distribution.json and CHANGELOG.md per-file versions, and
  refreshed the supplemental eval inventory note.
- CHANGELOG.md (bundle): Added this release entry and restored the
  in-bundle file to the documented 5-entry rolling window.
- README.md (root): Corrected the repo structure and eval inventory
  counts from 30 total / 4 supplemental to 34 total / 8 supplemental.

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

## 4.7.3 — 2026-03-15
- SKILL.md: Added provenance fields (skill_bundle, file_role, version,
  version_date, previous_version, change_summary) to own metadata block
  so the skill exemplifies its own convention. Changed author from
  "Snap Synapse" to "Sam Rogers (snapsynapse.com)". Updated Origin section.
- MANIFEST.yaml: Bumped bundle to 4.7.3, advanced SKILL.md to v14 with
  updated hash and note.

## 4.7.2 — 2026-03-09
- SKILL.md: Updated changelog guidance to distinguish between the rolling
  in-bundle changelog and the full repo-level archive.
- README.md: Clarified that the bundle keeps recent changelog history
  while the source repository carries the full archive.
- CHANGELOG.md: Trimmed the in-bundle changelog to the five most recent
  entries and pointed readers to the root changelog for older history.
- MANIFEST.yaml: Bumped bundle to 4.7.2, updated changelog notes, and
  advanced file revisions for the changelog split model.
- AGENTS.md and CONTRIBUTING.md: Updated repo instructions to maintain a
  full root changelog plus a rolling in-bundle changelog.

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

## 4.5.1 — 2026-03-07
- SKILL.md: Rewrote the frontmatter description to include stronger
  discovery triggers (`MANIFEST.yaml`, `CHANGELOG.md`, hashes, stale
  evals, packaging) and condensed the cross-platform section so the skill
  stays under the 500-line guidance.
- README.md (bundle): Added `.zip` upload guidance for loaders that do not
  accept `.skill` files and documented Perplexity Computer as a tested
  loading path.
- README.md (root): Added a quick-install note explaining that `.skill`
  can be renamed to `.zip` for uploaders that only accept `.zip` or `.md`,
  and added Perplexity Computer to the platform support table.
- MANIFEST.yaml: Bumped bundle to 4.5.1, updated bundle date, and advanced
  per-file revisions for the changed bundle files. Added a Perplexity
  Computer compatibility test record.

## 4.5.0 — 2026-03-06
- SKILL.md: Added `dependencies` field to manifest spec with empty-list
  default and usage example. Renamed `frontmatter_mode: claude` to
  `frontmatter_mode: metadata` throughout spec and examples.
- README.md (bundle): Trimmed Gemini Gems workflow section from multi-page
  guide to single-paragraph note with eval reference. Added `skills-ref`
  validation tool mention to Agent Skills GitHub reference. Renamed
  `frontmatter_mode` references from `claude` to `metadata`.
- README.md (root): Added cross-surface fragmentation (API/Chat/Code
  skill isolation) to opening pitch paragraph.
- evals.json: Added eval 14 (API surface awareness — epoch-timestamp
  versioning, cross-surface isolation, manifest-to-API traceability) and
  eval 15 (dependencies field usage). Renamed `frontmatter_mode: claude`
  to `metadata` in evals 7 description and expectations. Now 15 evals.
- MANIFEST.yaml: Added `dependencies: []` field. Bumped bundle to 4.5.0.

## 4.4.0 — 2026-03-06
- SKILL.md: Updated frontmatter constraint table to distinguish Claude
  Chat/Settings from Claude Code (which supports extensions like
  disable-model-invocation, context, agent, hooks). Added Claude API
  and Agent SDK to cross-surface section documenting epoch-timestamp
  versioning and cross-surface fragmentation. Added note on 30+ agent
  adopters. Added metadata.version spec-standard note. Added progressive
  disclosure guidance (three-tier loading model, <500 line recommendation).
  Added ${CLAUDE_SKILL_DIR} variable documentation.
- README.md (bundle): Updated spec relationship section to reflect 30+
  adopter ecosystem, noted metadata.version as spec-standard rather than
  Claude-only, added cross-surface fragmentation note for API-deployed
  skills.
- README.md (root): Expanded platform support table with Claude API,
  Agent SDK, GitHub Copilot/VS Code, and Cursor. Added 30+ adopter
  ecosystem note. Added Skills API row to comparison table.
- MANIFEST.yaml: Added api to designed_for surfaces, added compatible_with
  block listing Claude API, Agent SDK, GitHub Copilot, Cursor, and
  agentskills.io ecosystem. Bumped bundle to 4.4.0.
- evals.json: Not updated (stale — does not yet cover API surface or
  30+ adopter ecosystem context).

## 4.3.0 — 2026-03-06
- SKILL.md: Simplified the core protocol for portability. Made handoff
  notes optional surface-specific artifacts instead of a default bundle
  requirement, changed git commit output to inline-by-default with optional
  `git_commit.txt`, and replaced exact `designed_for` model targeting with
  surface/capability-oriented compatibility guidance.
- README.md: Reworked the guide to be less Claude-centric in the default
  path, added explicit Codex loading guidance, clarified that handoff notes
  are mainly for stateless chat transitions, and documented inline commit
  message output as the default lightweight workflow.
- evals.json: Updated eval expectations so chat handoff remains validated
  where appropriate, but `handoff.md` and `git_commit.txt` are no longer
  universal success criteria. Relaxed compatibility expectations to allow
  capability-oriented `designed_for` metadata instead of vendor/model-locked
  targets.
- MANIFEST.yaml: Bumped bundle version to 4.3.0, updated compatibility
  metadata to describe target surfaces and capabilities instead of a single
  exact model, and advanced per-file revisions for the changed bundle files.

## 4.2.1 — 2026-02-28
- README.md (bundle): Added pi0/skillman (JS/TS) alongside existing
  chrisvoncsefalvay/skillman (Python) in ecosystem references. Added
  research subsection with Xu & Yan (2026) agent skills survey paper.
- README.md (root): Added pi0/skillman to related projects alongside
  existing Python skillman reference.
- CHANGELOG.md: Renumbered all post-3.0.0 entries to align with git tag
  v4.0.0. Merged former 4.1.0 and 4.2.0 into single 4.0.0 entry matching
  the tagged release.

## 4.2.0 — 2026-02-28
- README.md (root): Rewrote with explicit value statement, before/after
  comparison, platform support matrix with tested/untested status,
  comparison table against git tags, filename suffixes, and Skillman,
  and "when not to use this" guidance.
- AGENTS.md: New file. Repo-level guide for AI agents with repository
  structure, pre/post-change protocols, key rules, and testing
  instructions.
- CONTRIBUTING.md: New file. Contribution guide with versioning protocol
  for bundle changes and code style expectations.
- .github/ISSUE_TEMPLATE/compatibility-report.yml: New file. Structured
  issue template for cross-platform test results.
- validate.sh: Added sha256sum fallback for Linux portability. Script
  now auto-detects shasum (macOS) or sha256sum (Linux) at startup.
- README.md (bundle): Updated validate.sh dependency description to
  include sha256sum.

## 4.1.0 — 2026-02-28
- Adopted semver for bundle versioning. Updated SKILL.md spec to replace
  integer-only rule with semver for bundle_version and integer for per-file
  revision counts. Updated MANIFEST.yaml, CHANGELOG.md, and README examples
  to use semver throughout.
- README.md (root): Added Skillman reference to related projects.
- README.md (bundle): Added Skillman to ecosystem references.
- CHANGELOG.md: Retroactively mapped all prior releases to semver,
  aligned with git tag v4.0.0.

## 4.0.0 — 2026-02-27
- SKILL.md: Added Gemini CLI to frontmatter constraint table and
  cross-platform considerations section with three-tier discovery,
  install path, and management commands. Switched default frontmatter_mode
  to minimal for maximum cross-platform portability. Added git commit
  message generation (step 6) to session close protocol and required
  per-file handoff summaries. Refined the model so internal headers are
  used when safe, strict-format files are manifest-only, `MANIFEST.yaml`
  is not self-listed, and the bundle itself ships in minimal frontmatter
  mode for maximum portability.
- README.md: Added Gemini CLI to quick start surface table. Added Gemini
  Gems workflow guidance with tracking instructions, example prompt, and
  limitations. Added Gemini ecosystem references. Added local hash
  validation section, clarified that the checked-in directory is the
  canonical cross-platform source bundle and that strict-format files
  rely on manifest-only version tracking.
- evals.json: Added evals 9-13: Gemini CLI compatibility bootstrap,
  Gemini Gems prompt extraction, git commit message generation, handoff
  with per-file changes, local hash validation. Aligned all expectations
  with minimal frontmatter mode, manifest-only tracking for strict-format
  files, and the manifest control-file rule. Now 13 evals total.
- validate.sh: New file. Hardened for portable update-mode rewrites and
  locale-stable hash verification against MANIFEST.yaml.

## 3.0.0 — 2026-02-10
- All files: Renamed bundle from skill-versioning to skill-provenance.
  All internal references, frontmatter, and manifest entries updated.
- evals.json: Added 3 new evals (6, 7, 8) covering cross-platform
  Codex bootstrap, frontmatter_mode toggling, and compatibility block
  generation. All 8 evals now aligned with 2.0.0 SKILL.md capabilities.
- Prepared for public release on GitHub under snapsynapse org.

## 2.0.0 — 2026-02-10
- SKILL.md: Added cross-platform interoperability section (Codex, Copilot,
  agentskills.io). Added compatibility block to manifest spec. Expanded
  file_role values (reference, asset, agents). Documented SKILL.md frontmatter
  constraints per platform with compatibility table. Made description and
  problem statement platform-agnostic. Added cross-platform notes for Codex
  and GitHub Copilot surfaces.
- README.md: Added references section (official docs, blog posts, ecosystem
  projects). Added cross-platform quick-start note. Clarified that evals
  and scripts travel with the bundle.
- evals.json: Added eval 4 (conflict detection), eval 5 (chat handoff), and
  improved cross-platform framing for existing evals.
- validate.sh: Not yet present in this release.

## 1.0.0 — 2026-02-09
- Initial public release of the skill-versioning metaskill.

## Unreleased - 2026-09-08
- assistant-guide.txt, assistant-guide-manifest.txt, and
  .github/scripts/release-surface-check.sh: Added root trust mirrors for the
  served GuideCheck files and enforce byte parity at the release surface.
  The canonical skill bundle and `.skill` archive remain unchanged.

## Unreleased - 2026-09-12
- docs/state-of-skill-versioning-2026.md: Added the observer's dated signed
  manifests, signing key, and full history endpoint as sources, recorded that
  the manifests cannot retroactively freeze the 2026-08-27 figure, and
  recorded a 2026-09-12 recompute of 66 of 1,203 unchanged labels that does
  not reproduce the reported 14.2 percent. The canonical skill bundle and
  `.skill` archive remain unchanged.

## Unreleased - 2026-09-23
- index.html, README.md, and docs/state-of-skill-versioning-2026.md: Replaced
  the unreproduced 14.2 percent drift figure with the observer-confirmed 66 of
  1,210 (5.5 percent) to 2026-09-13, recorded the observer's recipe, the 839
  retracted events, a 2026-09-24 recompute on the mutable history, and
  verification that the per-file `url` and `eventId` gaps are closed. Refs #4.
- index.html and sitemap.xml: Corrected the platform stat to 4 tested of 8
  supported, matching the README platform table, and aligned the visible
  update date, JSON-LD dateModified, article modified time, and sitemap lastmod.
- index.html: Contained the comparison table and before/after panels at 768px
  and below so the page no longer scrolls horizontally on phones (observed
  595px document width at a 375px viewport before the fix, none after).
  The canonical skill bundle and `.skill` archive remain unchanged.
- index.html: Updated the ClawHub download signal to 1,700+ (1.7k all-time
  observed 2026-09-24) and removed the ProSkills 8.41/10 score, which dates
  from 2026-04-08 and has no current listing to verify against.
- README.md: Stated the governability rationale in "What problem it solves"
  without claiming safety.
- docs/standards-integration-status.md and ROADMAP.md: Added a dated
  standards integration status note covering agentskills#46, #254, #380, and
  AI Catalog, the smallest unresolved gap, and the minimal provenance
  contract, including the observed limit that unlisted extra files are not
  detected by the current validator.
