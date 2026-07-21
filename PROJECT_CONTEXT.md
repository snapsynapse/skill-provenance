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

## Current status (as of 2026-07-21 assessment)

- Bundle source is prepared for 6.0.0 manifest-boundary hardening. It is not
  committed, tagged, pushed, or published until the release workflow is
  explicitly authorized.
- The validator now fails closed on unsafe or ambiguous paths, duplicate
  entries, manifest-listed symlinks, and unsupported inventory syntax.
  Packaging reuses that validator policy at each derived-package boundary.
- Coverage is 39 core and 17 supplemental evals, 56 total, plus executable
  validator, action-input, packaging, and release-surface regression checks.
- Current adoption work remains the standalone verifier/bootstrap path,
  refreshed ecosystem evidence, dogfooding, badges, and targeted interop.
- Health verdict: healthy and actively maintained. See root `CLAUDE.md` for
  full agent-facing build, test, and release conventions.
