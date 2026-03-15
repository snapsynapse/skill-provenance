# Changelog

## 1.1.0 — 2026-03-07

- SKILL.md (v2): Added provenance tracking via skill-provenance metaskill. Added `metadata` block with `skill_bundle`, `file_role`, `version`, `version_date`, `previous_version`, and `change_summary`. Fixed scan log path to `cron_tracking/capability-scanner/scan-log.md`.
- OPERATIONS.md (v1): New file. Comprehensive operations guide covering system overview, skill/task relationship, human and agent troubleshooting, maintenance checklists, and architecture decision records. Obsidian-friendly formatting with callouts and wikilinks.
- README.md (v1): New file. Quick orientation for the bundle.
- CHANGELOG.md (v1): New file. This changelog.
- MANIFEST.yaml (v1): New file. Bundle manifest with file inventory and hashes.

## 1.0.0 — 2026-03-07

- SKILL.md (v1): Initial skill definition. Editorial decision framework for the AI Capability Reference, encoding scope rules from SCOPE.md, ontology from ONTOLOGY.md, capability taxonomy from CAPABILITY_TAXONOMY.md, and data schema from data/_schema.md. Scanning instructions, quality rules, and structured assessment format.
- Recurring task created: Scheduled every 3 days at 8:00 AM MST. Scans official blogs, tech press, and pricing pages. Creates GitHub issues via fine-grained PAT scoped to `snapsynapse/ai-capability-reference` (Issues read/write only).
