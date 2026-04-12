---
description: >
  Update version tracking when finishing work on a skill bundle. Use when
  you're done editing a skill project and need to bump version headers,
  recompute manifest hashes, update the changelog, flag stale files, or
  prepare a commit message. Triggers on: "close the session", "update
  versions", "save the bundle", "I'm done editing", "prepare to commit",
  "wrap up this skill session".
---

# Skill Provenance: Close

Update all version-tracking artifacts when finishing a skill editing session.
This ensures the bundle leaves the session in a consistent, verifiable state.

## When to use

Run `/skill-provenance:close` after you've finished editing files in a skill
bundle and before committing, packaging, or handing off.

## Protocol

1. **Identify changed files.** Compare the current state of each file
   against its hash in `MANIFEST.yaml`. If `validate.sh --update` exists,
   the user can run it for reliable hash recomputation. Otherwise, compute
   SHA-256 for each file and compare against the manifest.

2. **Update internal version headers.** For each changed file that carries
   YAML frontmatter with version metadata:
   - Increment `version` by 1.
   - Set `version_date` to today.
   - Set `previous_version` to the old version number.
   - Write a `change_summary` (1-3 sentences describing what changed, not
     just that something changed).

3. **Update MANIFEST.yaml.** For every changed versioned file:
   - Update `version` to match the new internal version.
   - Recompute and update `hash`.
   - For files that don't carry internal headers (JSON, scripts, binaries),
     the manifest `version` field is authoritative — increment it there.
   - Bump `bundle_version` (semver): PATCH for fixes/docs, MINOR for new
     features, MAJOR for breaking changes.
   - Update `bundle_date` to today.
   - If the user deployed or reinstalled the skill this session, update
     relevant `deployments` metadata.

4. **Update CHANGELOG.md.** Add a new entry at the top:
   - Use the new `bundle_version` and today's date as the heading.
   - Name every file that changed and what changed in it.
   - **Flag staleness explicitly.** If a versioned file was changed but a
     dependent file was not updated (e.g., SKILL.md changed but evals.json
     wasn't updated to match), say so in the entry.

5. **Deliver.** Provide the user with the changed files plus updated
   `MANIFEST.yaml` and `CHANGELOG.md`.

6. **Git commit message.** If the bundle is in a git repo, provide a
   ready-to-use commit message:

   ```
   bundle-name MAJOR.MINOR.PATCH: one-line summary

   - file1.md: what changed
   - file2.json: what changed
   - Stale: file3.js (not updated this session)
   ```

   Return the message inline. Only write a `git_commit.txt` file if the
   user explicitly asks for one.

## Conventions referenced

- **Per-file versions are integers.** Bundle version is semver.
- **change_summary is required** for every version after v1. Describe
  what changed, not just that something changed.
- **previous_version creates a chain** so any session can trace lineage.
- **MANIFEST.yaml is not self-listed.** It tracks other files only.
- **Hashes are SHA-256** of file contents.

For the full spec: https://skillprovenance.dev
