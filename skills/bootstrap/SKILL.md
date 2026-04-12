---
description: >
  Add version tracking to an existing unversioned skill bundle. Use when
  you have a skill project with SKILL.md but no MANIFEST.yaml, no version
  headers, and no changelog. Creates the initial manifest, adds version
  metadata to files, and generates the first changelog entry. Triggers on:
  "bootstrap this skill", "add versioning", "start tracking versions",
  "create a manifest", "this skill has no versioning".
---

# Skill Provenance: Bootstrap

Add provenance tracking to an existing unversioned skill bundle. This is
a one-time operation that creates the initial manifest, version headers,
and changelog.

## When to use

Run `/skill-provenance:bootstrap` when you have a skill directory that
contains a `SKILL.md` but lacks `MANIFEST.yaml`. This is the entry point
for adopting Skill Provenance on an existing project.

If the bundle already has a `MANIFEST.yaml`, use `/skill-provenance:open`
instead.

## Protocol

1. **Inventory all files.** Read the directory structure yourself — do not
   ask the user to list files. Identify:
   - `SKILL.md` (required — if missing, this isn't a skill bundle)
   - Evals files (e.g., `evals.json`)
   - Scripts (e.g., `generate.js`, `validate.sh`)
   - Output artifacts (`.docx`, `.pdf`)
   - Source material provided by the user
   - Any other files present

2. **Propose version numbers.** Ask the user what version to assign. If
   there's a handoff note, git history, or other context suggesting prior
   versions, propose a number based on that history. Default to `1.0.0`
   for the bundle and `1` for individual files if no history exists.

3. **Add internal version headers** to files that can safely carry YAML
   frontmatter. Use the `metadata` block pattern for SKILL.md:

   ```yaml
   ---
   name: skill-name
   description: What the skill does.
   metadata:
     skill_bundle: skill-name
     file_role: skill
     version: 1
     version_date: 2026-04-11
     previous_version: null
     change_summary: Initial versioned release.
   ---
   ```

   For files that cannot safely carry frontmatter (`.json`, `.sh`,
   binaries), the manifest tracks their version — no modification needed.

4. **Determine frontmatter mode.** Ask the user about their target
   platforms:
   - If targeting only Claude Code / agentskills.io-compatible clients:
     use `frontmatter_mode: metadata` (includes the metadata block).
   - If targeting Codex, Gemini CLI, or other strict platforms: use
     `frontmatter_mode: minimal` (name + description only in SKILL.md;
     manifest is the sole version record).
   - If unsure: default to `metadata` — it's more expressive and can
     always be stripped later with a packaging script.

5. **Generate MANIFEST.yaml.** Include:
   - `bundle`, `bundle_version`, `bundle_date`, `description`
   - `compatibility` section based on user's target platforms
   - `files` list with `path`, `role`, `version`, `hash` (SHA-256), `note`
   - Leave `deployments` empty unless the user mentions existing installs.

6. **Generate CHANGELOG.md.** Create a single entry summarizing known
   history. If the user has context about prior changes, incorporate it.
   Otherwise:

   ```markdown
   # Changelog

   ## 1.0.0 — 2026-04-11
   - Initial versioned release. All files inventoried and hashed.
   - SKILL.md: [brief description of current state]
   - evals.json: [N evals covering X]
   ```

7. **Deliver the versioned bundle.** Provide all new and modified files.
   Summarize what was created and any decisions for the user to confirm.

## File roles

Assign these roles in the manifest based on file type:

| Role | Files |
|------|-------|
| `skill` | SKILL.md |
| `evals` | evals.json, evals-*.json |
| `script` | .js, .py, .sh scripts |
| `output` | .docx, .pdf rendered artifacts |
| `handoff` | handoff notes |
| `source` | user-provided material (tracked, not versioned) |
| `reference` | documentation in references/ |
| `asset` | templates, images, fonts in assets/ |

## Conventions referenced

- **Version identity lives inside files** when their format allows it,
  and always in the manifest.
- **MANIFEST.yaml is not self-listed.** It tracks other files only.
- **Per-file versions are integers.** Bundle version is semver.
- **Hashes are SHA-256** of file contents.
- **Filenames never contain version numbers.** Version lives in metadata
  and the manifest, not in `SKILL_v5.md`.

For the full spec: https://skillprovenance.dev
