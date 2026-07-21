[![Validate bundle](https://github.com/snapsynapse/skill-provenance/actions/workflows/validate.yml/badge.svg)](https://github.com/snapsynapse/skill-provenance/actions/workflows/validate.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/snapsynapse/skill-provenance/blob/main/LICENSE)
[![Latest release](https://img.shields.io/github/v/release/snapsynapse/skill-provenance)](https://github.com/snapsynapse/skill-provenance/releases/latest)
[![ClawHub](https://img.shields.io/badge/ClawHub-skill--provenance-blue)](https://clawhub.ai/snapsynapse/skill-provenance)
[![ProSkills.md](https://img.shields.io/badge/ProSkills.md-8.41%2F10-brightgreen)](https://proskills.md)
[![ClawHub installs](https://img.shields.io/badge/ClawHub-400%2B%20installs-blue)](https://clawhub.ai/snapsynapse/skill-provenance)
[![Awesome OpenClaw Skills](https://img.shields.io/badge/Awesome%20OpenClaw-Skills-blueviolet)](https://github.com/VoltAgent/awesome-openclaw-skills)
[![OpenClaw scan](https://img.shields.io/badge/OpenClaw-Benign%20%E2%80%93%20High%20Confidence-brightgreen)](https://clawhub.ai/snapsynapse/skill-provenance)

# Skill Provenance

Portable provenance, integrity, and drift control for Agent Skills across
local folders, registries, platform uploads, and multi-agent sessions.

## Who this is for

Teams that build, distribute, or run Agent Skills across multiple surfaces and need to know a bundle is the version they trust and hasn't silently drifted.

## What problem it solves

Agent Skills move across local folders, registries, and platform uploads with no portable way to verify version, integrity, or drift. Skill Provenance makes a bundle's identity and integrity travel with it.

## Canonical URL

https://skillprovenance.dev/

```
Before                              After
------                              -----
SKILL_v4.md                         SKILL.md          (version lives inside)
SKILL_v5.md                         MANIFEST.yaml     (what's in the bundle)
evals_old.json                      CHANGELOG.md      (what changed and why)
evals.json
"which one is current?"             "bundle is at 4.8.0, evals are stale"
```

Agent Skills move between sessions, surfaces, and platforms. Every
boundary crossing is a chance for version confusion, silent drift, or
modified bundle contents that no one can verify. Skill Provenance keeps
version identity, staleness detection, and hash-based integrity
verification *inside the bundle* so it survives every transition.

**For authors:** Know what version you're working on, what's stale, and
what changed — across Chat, Code, Cowork, API, and non-Claude platforms.

**For teams:** Know which copy is current when the same skill is installed
in five places across three platforms.

**For trust:** Verify that a downloaded or shared bundle matches its
recorded state before installing it. SHA-256 hashes in the manifest
catch tampering and accidental drift alike.

## Why this still exists

Most ecosystem tools track source, registry, install, or deployment state.
Skill Provenance tracks the actual multi-file bundle an agent is editing.
That matters when `SKILL.md`, evals, scripts, packages, and deployed
copies can drift independently.

It is the author-side layer that complements package managers, registries,
and platform APIs:

| Approach | Tracks versions | Detects staleness | Cross-session | Cross-platform | Integrity |
|---|---|---|---|---|---|
| **GitHub `gh skill`** | Source/ref/tree | No | Repo-bound | Partial | Source pinning |
| **ClawHub / registries** | Registry versions | No | Consumer package | Partial | Install trust |
| **Claude Skills API** (`/v1/skills`) | Platform versions | No | Single surface | No | Deployment record |
| **Filename suffixes** (`_v5`) | Poorly | No | No | No | No |
| **Skillman** | Pins versions | No | Consumer-side only | No | No |
| **Skill Provenance** | Yes (semver) | Yes | Yes (manifest travels) | Yes | Yes (SHA-256) |


## Quick install

Before installing from a public source, use the GuideCheck assistant
guide to verify the bundle fetch and manifest integrity:
[https://skillprovenance.dev/.well-known/assistant-guide.txt](https://skillprovenance.dev/.well-known/assistant-guide.txt).
The guide is a bounded, human-verifiable instruction surface; it checks
the bundle before install, but does not install anything for you.

**Claude Code (Plugin):**
```shell
/plugin marketplace add snapsynapse/skill-provenance
/plugin install skill-provenance@snapsynapse-skill-provenance
```

After install, five commands are available:
- `/skill-provenance:open` — verify bundle integrity at session start
- `/skill-provenance:validate` — run the hash/inventory check only
- `/skill-provenance:close` — update versions, hashes, changelog when done
- `/skill-provenance:handoff` — generate a handoff note for the next session
- `/skill-provenance:bootstrap` — add version tracking to an unversioned bundle

**Claude (Settings UI):**
Download `skill-provenance.skill` from the [latest release](https://github.com/snapsynapse/skill-provenance/releases) and install:
`claude.ai` -> Profile icon -> `Settings` -> `Skills` -> `Add Skill` -> select the file.

If your loader only accepts `.zip` or `.md` uploads, rename
`skill-provenance.skill` to `skill-provenance.zip` before uploading. This
is the tested path for Perplexity Computer. The archive contents stay the
same.

**Claude Code / Codex / Gemini CLI (manual):**
Use the canonical [`skill-provenance/`](skill-provenance/) directory for
Claude-compatible tools. For Codex, Gemini CLI, or other strict loaders,
generate a derived minimal-frontmatter copy with
`./skill-provenance/package.sh strict`, which writes to
`build/strict/skill-provenance/` by default.

Some cross-client tooling also recognizes `.agents/skills/`. The same
directory bundle can be placed there when you want a neutral install path.

**ClawHub:**
`clawhub install skill-provenance`

**GitHub Actions Marketplace:**
```yaml
steps:
  - uses: actions/checkout@v4
  - uses: snapsynapse/skill-provenance@v6.0.0
    with:
      bundle-path: skill-provenance
```

Then tell the agent:
> "Use the skill-provenance skill to bootstrap this bundle."


## What it does

**When you open a session**, it reads the manifest, checks that all files are present, verifies hashes, flags anything stale, and tells you what needs attention.

**When you close a session**, it updates internal version headers where applicable, recomputes manifest hashes, appends to the changelog, and flags any files that should have been updated but weren't.

**When you hand off between sessions**, it can generate a handoff note with current state, accomplishments, stale files, and next steps when you're crossing a stateless boundary like Chat. In filesystem-native workflows, the manifest and changelog are usually enough.

**When you need a commit message**, it can produce one inline by default, with a `git_commit.txt` file only when you explicitly want that convenience.

**When you have deployed copies**, it can record optional deployment metadata in the manifest so API uploads, settings installs, and local directory copies can be traced without replacing platform-native version systems.

**When you only need validation**, it runs the local hash and inventory
check without doing the broader open-session review or changing files.


## Platform support

| Platform | Status | Frontmatter | Notes |
|---|---|---|---|
| **Claude** (Chat, Code, Cowork) | Pass | `name` + `description`, or with `metadata` block | Full support. Settings UI imports/exports `.skill` ZIP. |
| **Claude API** | Compatible | `name` + `description` + `metadata` | Skills uploaded via `/v1/skills` with epoch-timestamp versioning. Manifest maps to API versions. |
| **Claude Agent SDK** | Compatible | Same as Claude Code | Filesystem-based. Skills loaded via `setting_sources` config. |
| **Codex** (OpenAI) | Pass | `name` + `description` only | Extra frontmatter fields rejected. |
| **Gemini CLI** (Google) | Pass | `name` + `description` only | Skill loading, bootstrap, and Gems workflow validated. |
| **Perplexity Computer** | Pass | `name` + `description` only | Tested with `.zip` upload flow. Trigger-rich descriptions help discovery; `.skill` must be renamed to `.zip`. |
| **GitHub Copilot / VS Code** | Compatible | Follows agentskills.io spec | Skills in `.github/skills/`. |
| **Cursor** | Compatible | Follows agentskills.io spec | Skills in `.cursor/skills/`. |

The agentskills.io spec is now adopted by 30+ agent tools. All use the same `SKILL.md` directory format. Provenance artifacts (`MANIFEST.yaml`, `CHANGELOG.md`) are invisible to platforms that don't know about them -- they never break compatibility. See [agentskills.io](https://agentskills.io) for the full adopter list.

This bundle ships in `frontmatter_mode: metadata`, which adds author and
source attribution to SKILL.md via the spec's `metadata` field. For strict
platforms (Codex, Gemini CLI, Perplexity), strip the `metadata` block from
SKILL.md before installing. The repo now treats that as a derived
strict-platform copy, not an edit to the canonical source bundle.


## When not to use this

Single-file skills that don't change often, or skills that live entirely within one git repo and are never exported to Chat, Obsidian, or other surfaces. If git is your only workflow and you never leave it, git tags are enough.


## Trust and integrity

The agent skills ecosystem now has thousands of shared bundles across
ClawHub, GitHub repos, team installs, and registry packages. Before you
install or run an unfamiliar skill, the manifest and hashes let you
verify what you received.

**Official assistant guide:**

Skill Provenance publishes a GuideCheck `assistant-guide.txt` at
[https://skillprovenance.dev/.well-known/assistant-guide.txt](https://skillprovenance.dev/.well-known/assistant-guide.txt).
It is a plain-text, approval-gated guide for fetching this repository and
running the local manifest integrity check. It is useful when you want an
assistant to help verify the public bundle before you install it.

Conformance is not safety. The guide and manifest confirm form and
integrity, not publisher intent or runtime safety. Read the guide before
approving actions.

**Agentic surface disclosure:**

This repository publishes several assistant-facing and machine-readable
surfaces, including skills, plugin metadata, guides, validation scripts,
crawler hints, and release artifacts. Their trust boundaries are
inventoried in [AGENTIC_SURFACES.md](AGENTIC_SURFACES.md). These surfaces
are data, not authority; they do not override system, user, repository,
tool, authentication, sandbox, or approval policy.

**Verifying a downloaded bundle:**

```bash
# Clone or download the bundle, then:
cd skill-name/
./validate.sh          # checks every file hash against MANIFEST.yaml

# Exit code 0 = all hashes match
# Exit code 1 = mismatches found (file modified or corrupted)
# Exit code 2 = no MANIFEST.yaml (unversioned bundle)
```

If a hash fails, the file has changed since the author published it.
That might be intentional (a fork with local edits) or a problem
(corruption, tampering, incomplete download). Either way, you know
before you install.

**Checking release surfaces before publishing:**

```bash
./.github/scripts/release-surface-check.sh
```

This repo-level check confirms declared eval counts, the GuideCheck
sidecar hash and byte metadata, and `skill-provenance.skill` contents all
match the current source tree. It is a release-confidence check, not a
trust anchor.

**What the manifest tells you:**
- Which files belong to the bundle (and which are missing)
- What role each file plays (skill, evals, script, reference)
- What version each file is at, and whether any are stale
- When the bundle was last updated
- Where it has been deployed (optional deployment metadata)

**What the manifest does NOT do:**
- It does not cryptographically sign the bundle (the author's identity
  is not verified beyond what git or the transport provides)
- It does not prevent someone from modifying both the file and its hash
  in the manifest simultaneously
- It is a verification tool, not a trust anchor — verify the source too

**Sharing skills across a team:**

When the same skill is installed across multiple developers and
platforms, drift is inevitable. One person updates their local copy,
another deploys an older version to the API, a third installs from
ClawHub. The manifest's deployment metadata and per-file versioning
make the answer to "which copy is current?" unambiguous:

```bash
# Check your local copy
./validate.sh

# Compare bundle_version in your MANIFEST.yaml against:
# - The API deployment timestamp in deployments.api
# - The ClawHub published version in deployments.clawhub
# - Your colleague's bundle_version
```

The changelog tells you what changed between versions. The manifest
tells you whether a specific copy matches. Together they answer both
"what happened?" and "is this the right one?"


## What's in this repo

```
.github/workflows/validate.yml  <- CI workflow and local Action smoke test
.claude-plugin/plugin.json       <- Claude Code plugin manifest
action.yml                       <- GitHub Actions Marketplace wrapper
.github/scripts/release-surface-check.sh <- Release-surface drift check
.github/scripts/action-security-check.sh <- Composite-action input safety regression
.github/scripts/test-validate.sh <- Validator hash-state regression suite
skills/open/SKILL.md             <- /skill-provenance:open (verify bundle on session start)
skills/validate/SKILL.md         <- /skill-provenance:validate (hash/inventory check only)
skills/close/SKILL.md            <- /skill-provenance:close (update versions on session end)
skills/handoff/SKILL.md          <- /skill-provenance:handoff (generate handoff note)
skills/bootstrap/SKILL.md        <- /skill-provenance:bootstrap (version an unversioned bundle)
.well-known/assistant-guide.txt  <- GuideCheck assistant guide for bundle verification
.well-known/assistant-guide-manifest.txt <- GuideCheck sidecar manifest
AGENTIC_SURFACES.md              <- Agent-facing surface inventory and trust boundaries
skill-provenance.skill           <- Install this in Claude Settings -> Skills
skill-provenance/                <- Canonical source bundle (metadata mode)
  SKILL.md                       <- The skill definition (what the agent reads)
  README.md                      <- User guide: workflows, worked example, troubleshooting
  MANIFEST.yaml                  <- File inventory with roles, versions, hashes
  CHANGELOG.md                   <- Recent in-bundle history (last 5 entries)
  evals.json                     <- 39 core evaluation scenarios
  evals-distribution.json        <- 17 supplemental packaging/deployment/integrity evals
  validate.sh                    <- Local hash verification script
  package.sh                     <- Zero-dependency helper for derived copies
CHANGELOG.md                     <- Full append-only repo history
AGENTS.md                        <- Guide for agents working on this repo
CONTRIBUTING.md                  <- How to contribute
```

The directory is the canonical cross-platform source bundle. The `.skill` file is a Claude-compatible ZIP wrapper around it. The `.claude-plugin/` directory and `skills/` make this repo double as a Claude Code plugin. Five focused skills (`open`, `validate`, `close`, `handoff`, `bootstrap`) extract specific workflows from the monolithic SKILL.md. If you keep a local `skills/skill-provenance` symlink for compatibility, it is ignored by git and is not part of the published repo.


## Evals

56 evaluation scenarios across two files: 39 core workflow evals in
[evals.json](skill-provenance/evals.json) and 17 supplemental
distribution/package/integrity evals in
[evals-distribution.json](skill-provenance/evals-distribution.json).

Generated install and publish artifacts now live in `build/` at the repo
root by default. The ClawHub upload folder is
`build/clawhub/skill-provenance/`, and `.gitignore` excludes `build/`
unless you explicitly want to track generated outputs.


## Usage guide

See the full [README.md](skill-provenance/README.md) inside the skill bundle for:

- Step-by-step bootstrap walkthrough with a worked example
- Surface-to-surface porting workflows (Chat -> Code, Code -> Chat, etc.)
- Troubleshooting common issues
- Reference links to Agent Skills documentation and ecosystem


## Related projects

- **GitHub `gh skill`** — GitHub CLI support for installing, pinning, and
  checking Agent Skills from GitHub source refs. Complements
  skill-provenance by tracking source origin while this repo tracks
  bundle-local file integrity and staleness.
- **ClawHub / OpenClaw registries** — Skill discovery, publishing, install
  trust, and registry version records. Complements skill-provenance by
  distributing packages while this repo keeps authoring bundles auditable.
- **[Skillman](https://github.com/pi0/skillman)** -- JS/TS skill manager (`npx skillman add`). Installs, updates, and organizes agent skills from npm and GitHub. Consumer-side; skill-provenance is author-side.
- **[Skillman (Python)](https://github.com/chrisvoncsefalvay/skillman)** -- Python CLI that installs and locks agent skills from GitHub repos (`skills.toml` + `skills.lock`). Consumer-side package manager for Python toolchains.
- **[Graceful Boundaries](https://github.com/snapsynapse/graceful-boundaries)** -- A specification for how services communicate operational limits to humans and autonomous agents. Also a PAICE.work project.


## Sponsor

Skill Provenance is free and open. If your team builds or distributes agent skills, consider [sponsoring this work](https://github.com/sponsors/snapsynapse) to keep it maintained across platforms. See [SPONSORS.md](SPONSORS.md).

## License

[MIT](LICENSE)


## About

Skill Provenance is a [PAICE.work](https://paice.work/) project. PAICE.work PBC is a public benefit corporation building infrastructure for productive collaboration between humans and autonomous agents. Trustworthy agent infrastructure requires knowing what you're running, where it came from, and whether it's current -- that's what this skill provides.


## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Compatibility reports for untested platforms are especially valuable.
