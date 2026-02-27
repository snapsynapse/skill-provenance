# Changelog

## v4 — 2026-02-27
- SKILL.md: Added Gemini CLI to frontmatter constraint table and
  cross-platform considerations section. Documented three-tier skill
  discovery, installation path, and management commands. Updated
  frontmatter_mode comment to list Gemini CLI alongside Codex.
- README.md: Added Gemini CLI to quick start surface table. Added
  Gemini Gems workflow section with tracking instructions, example
  prompt, and limitations. Added Gemini ecosystem references.
- evals.json: Added eval 9 (Gemini CLI compatibility bootstrap) and
  eval 10 (Gemini Gems prompt extraction). Now 10 evals total.
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
