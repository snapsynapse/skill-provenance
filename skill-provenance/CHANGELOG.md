# Changelog

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
  links, support articles). Added spec relationship section. Simplified
  bootstrap prompt (Claude inventories files itself). Fixed macOS .skill
  extraction instructions (Archive Utility won't open .skill, unzip -d
  required). Added troubleshooting for unzip destination behavior.
- evals.json: Not updated — did not yet cover cross-platform scenarios,
  compatibility block generation, or frontmatter_mode toggling.

## 1.0.0 — 2026-02-10
- Bootstrap from initial design session. Created SKILL.md with session
  protocol, manifest spec, changelog spec, version header spec, and
  cross-surface considerations. Created README.md with worked example
  and porting workflows. Created evals.json with 5 structural evals.
- No content from prior sessions — this was the first versioned release.
