# Skill Provenance

A metaskill for version tracking across [Agent Skills](https://agentskills.io) sessions, surfaces, and platforms.

You upload a SKILL.md to a new session and can't tell if it's the latest version. You update the skill definition but forget to update the evals. You hand off a skill project and the next session has no idea what changed. Git tracks *that something changed* — Skill Provenance tracks *what it means*.

```
Before                              After
──────                              ─────
SKILL_v4.md                         SKILL.md          (version lives inside)
SKILL_v5.md                         MANIFEST.yaml     (what's in the bundle)
evals_old.json                      CHANGELOG.md      (what changed and why)
evals.json
"which one is current?"             "bundle is at 4.2.1, evals are stale"
```


## How it compares

| Approach | Tracks versions | Detects staleness | Cross-session | Cross-platform | Tracks intent |
|---|---|---|---|---|---|
| **Git tags** | Yes | No | No (requires repo access) | No | No |
| **Filename suffixes** (`_v5`) | Poorly | No | No | No | No |
| **Skillman** | Pins versions | No | Consumer-side only | No | No |
| **Skill Provenance** | Yes (semver) | Yes | Yes (manifest travels) | Yes | Yes (changelog) |

Git tags work when everyone has repo access. Filename suffixes break as soon as you rename. Skillman pins versions for consumers. Skill Provenance fills the gap for authors: it tracks version identity, staleness, and intent *inside the bundle* so it survives session boundaries, surface transitions, and platform changes.

**When not to use this:** Single-file skills that don't change often, or skills that live entirely within one git repo and are never exported to Chat, Obsidian, or other surfaces. If git is your only workflow and you never leave it, git tags are enough.


## Platform support

| Platform | Status | Frontmatter | Notes |
|---|---|---|---|
| **Claude** (Chat, Code, Cowork) | Pass | `name` + `description`, or with `metadata` block | Full support. Settings UI imports/exports `.skill` ZIP. |
| **Codex** (OpenAI) | Pass | `name` + `description` only | Extra frontmatter fields rejected. Co-authored v4. |
| **Gemini CLI** (Google) | Partial | `name` + `description` only | Skill loading works. Gems workflow untested. |
| **GitHub Copilot** | Untested | Follows agentskills.io spec | Should work — [compatibility reports welcome](CONTRIBUTING.md). |
| **Cursor** | Untested | Follows agentskills.io spec | Should work — [compatibility reports welcome](CONTRIBUTING.md). |

This bundle ships in `frontmatter_mode: minimal` for maximum portability.


## Quick install

**Claude (Settings UI):**
Download `skill-provenance.skill` from the [latest release](https://github.com/snapsynapse/skill-provenance/releases) and install:
`claude.ai` → Profile icon → `Settings` → `Skills` → `Add Skill` → select the file.

**Claude Code / Codex / Gemini CLI:**
Use the [`skill-provenance/`](skill-provenance/) directory directly. Same source works across all platforms.

**ClawHub:**
`clawhub install skill-provenance`

Then tell the agent:
> "Use the skill-provenance skill to bootstrap this bundle."


## What it does

**When you open a session**, it reads the manifest, checks that all files are present, verifies hashes, flags anything stale, and tells you what needs attention.

**When you close a session**, it updates internal version headers where applicable, recomputes manifest hashes, appends to the changelog, and flags any files that should have been updated but weren't.

**When you hand off between sessions**, it generates a handoff note with current state, accomplishments, stale files, and next steps.


## What's in this repo

```
skill-provenance.skill           ← Install this in Claude Settings → Skills
skill-provenance/                ← Canonical source bundle (use this for Code/Codex/Gemini)
├── SKILL.md                     ← The skill definition (what the agent reads)
├── README.md                    ← User guide: workflows, worked example, troubleshooting
├── MANIFEST.yaml                ← File inventory with roles, versions, hashes
├── CHANGELOG.md                 ← Change history
├── evals.json                   ← 13 evaluation scenarios
└── validate.sh                  ← Local hash verification script
AGENTS.md                        ← Guide for agents working on this repo
CONTRIBUTING.md                  ← How to contribute
```

The directory is the canonical cross-platform source bundle. The `.skill` file is a Claude-compatible ZIP wrapper around it.


## Evals

13 evaluation scenarios covering bootstrap, session open/close, conflict detection, handoff, cross-platform compatibility, and more. See [evals.json](skill-provenance/evals.json) for the full list.


## Usage guide

See the full [README.md](skill-provenance/README.md) inside the skill bundle for:

- Step-by-step bootstrap walkthrough with a worked example
- Surface-to-surface porting workflows (Chat → Code, Code → Chat, etc.)
- Troubleshooting common issues
- Reference links to Agent Skills documentation and ecosystem


## Related projects

- **[Skillman](https://github.com/pi0/skillman)** — JS/TS skill manager (`npx skillman add`). Installs, updates, and organizes agent skills from npm and GitHub. Consumer-side; skill-provenance is author-side.
- **[Skillman (Python)](https://github.com/chrisvoncsefalvay/skillman)** — Python CLI that installs and locks agent skills from GitHub repos (`skills.toml` + `skills.lock`). Consumer-side package manager for Python toolchains.


## License

[MIT](LICENSE)


## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Compatibility reports for untested platforms are especially valuable.
