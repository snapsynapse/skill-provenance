# Skill Provenance

Version tracking for [Agent Skills](https://agentskills.io) across sessions, surfaces, and platforms.

If you build or maintain Claude skills (or skills for Gemini CLI, Codex, Copilot, or any platform that uses the agentskills.io standard), you've hit this problem: you upload a SKILL.md to a new session and can't tell if it's the latest version, or you update the skill definition but forget to update the evals, or you hand off a skill project and the next session has no idea what changed.

Skill Provenance solves this with three conventions:

1. Version identity travels with the bundle: **inside files when practical, and always in the manifest**.
2. A **changelog** travels with the skill bundle.
3. A **manifest** lists all files so any session can verify completeness and detect staleness.

It's a metaskill — a skill that manages other skills. Load it alongside your skill project and it handles the bookkeeping at session boundaries.


## Quick install

Download `skill-provenance.skill` from the [latest release](https://github.com/snapsynapse/skill-provenance/releases) and install it:

`claude.ai` → Profile icon → `Settings` → `Skills` → `Add Skill` → select the file.

The skill is now available in every Claude conversation. To use it, tell Claude:

> "Use the skill-provenance skill to bootstrap this bundle."

For Codex or Gemini CLI, use the checked-in [`skill-provenance/`](skill-provenance/) directory directly. The bundle now ships with minimal `SKILL.md` frontmatter, so the same source works across Claude, Codex, and Gemini CLI.


## What it does

**When you open a session**, it reads the manifest, checks that all files are present, verifies hashes, flags anything stale, and tells you what needs attention before you start working.

**When you close a session**, it updates internal version headers where applicable, recomputes manifest hashes, appends to the changelog, and flags any files that should have been updated but weren't.

**When you hand off between sessions**, it generates a handoff note with current state, accomplishments, stale files, and next steps — because Chat sessions don't persist and the next instance of Claude has no memory of what you did.


## What's in this repo

```
skill-provenance.skill           ← Install this in Claude Settings → Skills
skill-provenance/
├── SKILL.md                     ← The skill definition (what Claude reads)
├── README.md                    ← User guide: workflows, worked example, troubleshooting
├── MANIFEST.yaml                ← File inventory with roles, versions, hashes
├── CHANGELOG.md                 ← Change history
├── evals.json                   ← 13 evaluation scenarios
└── validate.sh                  ← Local hash verification script
```

The `skill-provenance/` directory contains the same files that are inside the `.skill` ZIP. If you prefer working with loose files (Claude Code, git repos, Obsidian vaults), use the directory. If you prefer the packaged format (Claude Chat, Settings UI), use the `.skill` file.

The directory is the canonical cross-platform source bundle. The `.skill` file is a Claude-compatible packaging wrapper around it.


## Cross-platform compatibility

The skill works on any platform that supports the agentskills.io standard. Different platforms have different rules about what's allowed in SKILL.md frontmatter:

| Platform | SKILL.md frontmatter |
|---|---|
| **Claude** | `name`, `description`, plus `metadata` block for version info |
| **Gemini CLI (Google)** | `name` and `description` only — version info lives in manifest only |
| **Codex (OpenAI)** | `name` and `description` only — version info lives in manifest only |
| **GitHub Copilot** | Follows agentskills.io spec |

The manifest tracks a `frontmatter_mode` (`claude` or `minimal`) so the skill knows whether to embed version info in SKILL.md or keep it manifest-only.

This repository now ships in `frontmatter_mode: minimal` for maximum portability.


## Usage guide

See the full [README.md](skill-provenance/README.md) inside the skill bundle for:

- Step-by-step bootstrap walkthrough with a worked example
- Surface-to-surface porting workflows (Chat → Code, Code → Chat, etc.)
- Troubleshooting common issues (macOS `.skill` extraction, version conflicts, stale files)
- Reference links to Agent Skills documentation and ecosystem


## Evals

The `evals.json` file contains 13 evaluation scenarios:

1. **Bootstrap** — versioning an existing unversioned bundle
2. **Open session** — detecting missing and stale files on load
3. **Save session** — updating artifacts on close
4. **Conflict detection** — handling version header vs. manifest disagreements
5. **Chat handoff** — packaging for session-to-session transitions
6. **Codex bootstrap** — cross-platform with minimal frontmatter mode
7. **Frontmatter mode toggle** — switching from claude to minimal mode
8. **Compatibility block** — recording cross-platform test results
9. **Gemini CLI compatibility** — bootstrapping for Gemini CLI with minimal frontmatter
10. **Gemini Gems prompt extraction** — generating Gem update summaries
11. **Git commit message** — generating commit messages for git-bound bundles
12. **Handoff with per-file changes** — detailed change summaries in handoff notes
13. **Local hash validation** — using validate.sh for pre-upload verification

These are structured prompts with expected behaviors. Upload them alongside the skill to test it, or use them as a reference for how the skill should behave.


## Related projects

- **[Skillman](https://github.com/chrisvoncsefalvay/skillman)** — Python CLI that installs and locks agent skills from GitHub repos (`skills.toml` + `skills.lock`). Skillman is a consumer-side package manager; skill-provenance is an author-side versioning tool. They operate at different lifecycle stages and don't conflict on disk — use skill-provenance to version your bundle during development, and Skillman to distribute and pin it for consumers.


## License

[MIT](LICENSE)


## Contributing

Issues and PRs welcome. If you're testing the skill on platforms other than Claude (Gemini CLI, Codex, Copilot, Cursor, etc.), compatibility reports are especially valuable — open an issue with the platform, model, what worked, and what didn't.
