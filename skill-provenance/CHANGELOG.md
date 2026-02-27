# Changelog

## v4 — 2026-02-27
- SKILL.md: Added Gemini CLI to frontmatter constraint table and
  cross-platform considerations section with three-tier discovery,
  install path, and management commands. Added git commit message
  generation (step 6) to session close protocol and required per-file
  handoff summaries. Refined the model so internal headers are used
  when safe, strict-format files are manifest-only, `MANIFEST.yaml`
  is not self-listed, and the bundle itself ships in minimal
  frontmatter mode for maximum portability.
- README.md: Added Gemini CLI to quick start surface table, Gemini Gems
  workflow guidance, local hash validation, and Gemini ecosystem
  references. Clarified that the checked-in directory is the canonical
  cross-platform source bundle and that strict-format files rely on
  manifest-only version tracking.
- evals.json: Added evals 9-13: Gemini CLI compatibility, Gemini Gems
  prompt extraction, git commit message generation, handoff with
  per-file changes, local hash validation. Aligned expectations with
  minimal frontmatter mode, manifest-only tracking for strict-format
  files, and the manifest control-file rule. Now 13 evals total.
- validate.sh: New file. Hardened for portable update-mode rewrites and
  locale-stable hash verification against MANIFEST.yaml.
- CHANGELOG.md: This entry.

## v3 — 2026-02-10
- All files: Renamed bundle from skill-versioning to skill-provenance.
  All internal references, frontmatter, and manifest entries updated.
- evals.json: Added 3 new evals (6, 7, 8) covering cross-platform
  Codex bootstrap, frontmatter_mode toggling, and compatibility block
  generation. All 8 evals now aligned with v2 SKILL.md capabilities.
- Prepared for public release on GitHub under snapsynapse org.

## v2 — 2026-02-10
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

## v1 — 2026-02-10
- Bootstrap from initial design session. Created SKILL.md with session
  protocol, manifest spec, changelog spec, version header spec, and
  cross-surface considerations. Created README.md with worked example
  and porting workflows. Created evals.json with 5 structural evals.
- No content from prior sessions — this was the first versioned release.
