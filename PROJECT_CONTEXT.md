# Project Context: Skill Provenance

## What this is

Skill Provenance is a metaskill (an Agent Skill about managing Agent Skills)
that adds portable version tracking, staleness detection, and SHA-256
integrity verification to Agent Skill bundles. It solves version confusion
when a skill bundle (`SKILL.md`, evals, scripts, docs) moves across local
folders, registries (ClawHub), platform uploads (Claude Settings UI), and
multi-agent sessions (Claude, Codex, Gemini CLI, OpenClaw agents).

Distributed as:
- A Claude Code plugin (`/plugin install skill-provenance@snapsynapse-skill-provenance`)
- A standalone `.skill` file for the Claude Settings UI (and Perplexity Computer,
  renamed to `.zip`)
- A GitHub Action (`action.yml`) for CI-side bundle validation
- Source on ClawHub and GitHub

## Audience

Authors and teams who build, distribute, or run Agent Skills across multiple
surfaces (Chat, Code, Cowork, API) and non-Claude platforms, and need to
know a bundle they're editing or installing is the version they trust and
hasn't silently drifted. Secondary audience: agents themselves (Claude,
Codex, Gemini CLI, OpenClaw) reading `AGENTS.md`/`CLAUDE.md`/`GEMINI.md` for
how to work on this repo, and the bundled `skill-provenance/SKILL.md` for
how to apply the versioning protocol to *other* skill bundles they touch.

## Style / tone

Direct, technical, no marketing fluff. README uses comparison tables against
adjacent tools (`gh skill`, ClawHub, Claude Skills API, Skillman) rather than
vague claims. Docs favor concrete before/after examples over abstract
description (see the `SKILL_v4.md` → `SKILL.md`/`MANIFEST.yaml` snippet in
`README.md`). Security-conscious: `SECURITY.md` exists, CI includes an
`action-security-check.sh`, and recent changelog entries are hardening fixes
(fail-closed hash verification, safe input transport) rather than features.

## Key URLs

- Canonical site: https://skillprovenance.dev/
- Repo: https://github.com/snapsynapse/skill-provenance
- ClawHub listing: https://clawhub.ai/snapsynapse/skill-provenance
- Assistant guide (pre-install verification): https://skillprovenance.dev/.well-known/assistant-guide.txt
- Releases: https://github.com/snapsynapse/skill-provenance/releases

## Current status (as of 2026-07-12 assessment)

- Bundle version 5.0.0, released 2026-07-10. Repo clean, `main` in sync with
  origin, CI green.
- Most recent work was hardening (manifest validation fail-closed, secure
  action input transport) rather than new-feature work — the core surface
  (open/validate/close/handoff/bootstrap skills, validate.sh, package.sh) is
  stable.
- Roadmap items not yet started: standalone `bin/` CLI, multi-bundle
  workspace support, MCP server, auto-hash PostToolUse hook.
- Health verdict: healthy / low-activity-but-maintained. See root
  `CLAUDE.md` for full agent-facing build/test/convention guidance.
