[![Validate bundle](https://github.com/snapsynapse/skill-provenance/actions/workflows/validate.yml/badge.svg)](https://github.com/snapsynapse/skill-provenance/actions/workflows/validate.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/snapsynapse/skill-provenance/blob/main/LICENSE)
[![Latest release](https://img.shields.io/github/v/release/snapsynapse/skill-provenance)](https://github.com/snapsynapse/skill-provenance/releases/latest)
[![ClawHub](https://img.shields.io/badge/ClawHub-skill--provenance-blue)](https://clawhub.ai/snapsynapse/skill-provenance)
[![ProSkills.md](https://img.shields.io/badge/ProSkills.md-8.41%2F10-brightgreen)](https://proskills.md)
[![ClawHub installs](https://img.shields.io/badge/ClawHub-333%20installs-blue)](https://clawhub.ai/snapsynapse/skill-provenance)

# Skill Provenance

Version identity and integrity verification for Agent Skills.

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
worse — a modified bundle that no one can verify. Skill Provenance
keeps version identity, staleness detection, and hash-based integrity
verification *inside the bundle* so it survives every transition.

**For authors:** Know what version you're working on, what's stale, and
what changed — across Chat, Code, Cowork, API, and non-Claude platforms.

**For teams:** Know which copy is current when the same skill is installed
in five places across three platforms.

**For trust:** Verify that a downloaded or shared bundle matches its
recorded state before installing it. SHA-256 hashes in the manifest
catch tampering and accidental drift alike.

| Approach | Tracks versions | Detects staleness | Cross-session | Cross-platform | Integrity |
|---|---|---|---|---|---|
| **Git tags** | Yes | No | No (requires repo access) | No | No |
| **Filename suffixes** (`_v5`) | Poorly | No | No | No | No |
| **Skillman** | Pins versions | No | Consumer-side only | No | No |
| **Skills API** (`/v1/skills`) | Upload timestamps | No | Single surface only | No | No |
| **Skill Provenance** | Yes (semver) | Yes | Yes (manifest travels) | Yes | Yes (SHA-256) |


## Quick install

**Claude Code (Plugin):**
```shell
/plugin marketplace add snapsynapse/skill-provenance
/plugin install skill-provenance@snapsynapse-skill-provenance
```

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

Then tell the agent:
> "Use the skill-provenance skill to bootstrap this bundle."


## What it does

**When you open a session**, it reads the manifest, checks that all files are present, verifies hashes, flags anything stale, and tells you what needs attention.

**When you close a session**, it updates internal version headers where applicable, recomputes manifest hashes, appends to the changelog, and flags any files that should have been updated but weren't.

**When you hand off between sessions**, it can generate a handoff note with current state, accomplishments, stale files, and next steps when you're crossing a stateless boundary like Chat. In filesystem-native workflows, the manifest and changelog are usually enough.

**When you need a commit message**, it can produce one inline by default, with a `git_commit.txt` file only when you explicitly want that convenience.

**When you have deployed copies**, it can record optional deployment metadata in the manifest so API uploads, settings installs, and local directory copies can be traced without replacing platform-native version systems.


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
.claude-plugin/plugin.json       <- Claude Code plugin manifest
skills/skill-provenance/         <- Symlink to skill-provenance/ (plugin discovery)
skill-provenance.skill           <- Install this in Claude Settings -> Skills
skill-provenance/                <- Canonical source bundle (metadata mode)
  SKILL.md                       <- The skill definition (what the agent reads)
  README.md                      <- User guide: workflows, worked example, troubleshooting
  MANIFEST.yaml                  <- File inventory with roles, versions, hashes
  CHANGELOG.md                   <- Recent in-bundle history (last 5 entries)
  evals.json                     <- 22 core evaluation scenarios
  evals-distribution.json        <- 4 supplemental packaging/deployment evals
  validate.sh                    <- Local hash verification script
  package.sh                     <- Zero-dependency helper for derived copies
CHANGELOG.md                     <- Full append-only repo history
AGENTS.md                        <- Guide for agents working on this repo
CONTRIBUTING.md                  <- How to contribute
```

The directory is the canonical cross-platform source bundle. The `.skill` file is a Claude-compatible ZIP wrapper around it. The `.claude-plugin/` directory and `skills/` symlink make this repo double as a Claude Code plugin without restructuring the existing bundle.


## Evals

30 evaluation scenarios across two files: 26 core workflow evals in
[evals.json](skill-provenance/evals.json) and 4 supplemental
distribution/package evals in
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
