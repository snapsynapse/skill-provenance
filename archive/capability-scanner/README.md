---
skill_bundle: capability-scanner
file_role: reference
version: 1
version_date: 2026-03-07
previous_version: null
change_summary: Initial README.
---

# capability-scanner

Monitors the AI ecosystem for new features, providers, capabilities, and pricing changes relevant to the [AI Capability Reference](https://github.com/snapsynapse/ai-capability-reference). Applies editorial judgment based on the project's ontology, scope rules, and inclusion criteria. Files GitHub issues for candidates that warrant additions or updates.

## How It Works

This is a two-part system:

| Component | What it does | When it runs |
|---|---|---|
| **Skill** (`SKILL.md`) | Encodes editorial rules, ontology, capability taxonomy, assessment format | Loaded on demand — by the recurring task or manually by the user |
| **Recurring task** | Scans the web, applies the skill's framework, files GitHub issues | Every 3 days at 8:00 AM MST |

## Quick Reference

| Action | What to say |
|---|---|
| Run a scan now | "Load the capability-scanner skill and run a scan now" |
| Assess a specific item | "Load the capability-scanner skill and assess [description]" |
| Change frequency | "Change the AI Capability Reference Scanner to run [daily/weekly]" |
| Stop the scanner | "Delete the AI Capability Reference Scanner scheduled task" |
| Refresh GitHub token | "Update the capability-scanner GitHub token to [new token]" |
| Update editorial rules | "Update the capability-scanner skill to match the current repo governance docs" |

## Bundle Contents

| File | Role | Description |
|---|---|---|
| `SKILL.md` | skill | Editorial decision framework and scanning instructions |
| `OPERATIONS.md` | reference | Full operations guide, troubleshooting, maintenance |
| `README.md` | reference | This file |
| `CHANGELOG.md` | — | Version history |
| `MANIFEST.yaml` | — | Bundle integrity and version tracking |

## Provenance

This bundle follows the [[skill-provenance]] protocol. Version identity is tracked in `MANIFEST.yaml`. Changes are logged in `CHANGELOG.md`. See `OPERATIONS.md` for maintenance procedures.

## Dependencies

- **Runtime:** `cron_tracking/capability-scanner/github-token.txt` (fine-grained GitHub PAT)
- **Repository:** [snapsynapse/ai-capability-reference](https://github.com/snapsynapse/ai-capability-reference)
- **Metaskill:** [[skill-provenance]] (for version tracking)
