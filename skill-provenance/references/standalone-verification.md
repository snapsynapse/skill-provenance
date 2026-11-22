# Standalone verification and bootstrap

Use this path when the Skill Provenance plugin is not installed. The
standalone wrapper delegates manifest parsing to the canonical
`validate.sh` and verifies that script against a pinned SHA-256 before
running it. The digest, not a mutable version label, is the execution gate.

## Verify without installing the plugin

Download the wrapper from its immutable release tag, check its SHA-256, and
inspect it before running it. Stop if the second command does not print
`OK`. Use `sha256sum -c` where `shasum` is absent.

Literal
```shell
curl -fsSLo /tmp/skill-provenance-verify.sh https://raw.githubusercontent.com/snapsynapse/skill-provenance/refs/tags/v7.0.2/verify.sh
echo "a8b77531d61b072a35af67a1e4c302217c08f58f62947ad342864a4757572dad  /tmp/skill-provenance-verify.sh" | shasum -a 256 -c
sed -n '1,220p' /tmp/skill-provenance-verify.sh
```

Replace: TARGET_SKILL_DIRECTORY -> the local directory containing `SKILL.md` and `MANIFEST.yaml`

Customize
```shell
bash /tmp/skill-provenance-verify.sh TARGET_SKILL_DIRECTORY
```

Exit code `0` means every pinned file is present and matches. Exit code `1`
means the manifest is invalid, a file is missing, or a hash mismatches. Exit
code `2` means the target has no `MANIFEST.yaml`.

The wrapper uses a repository-local canonical validator when present and
byte-identical to its pin. Otherwise it downloads the validator from the
immutable release tag named in the wrapper and refuses to execute it unless
the pinned digest matches. This verifies the validator bytes, not publisher
identity or runtime safety.

The validator that judges a bundle must never come from that bundle. Do not
run a `validate.sh` found inside a bundle someone else published, even when
its manifest lists the script with a matching hash: it is one of the files
under review and can print any result. Point the wrapper, or another trusted
copy of the validator, at the bundle instead.

## Bootstrap without installing the plugin

The bootstrap path is deliberately a prompt rather than an automatic rewrite.
Initial version choice, source-file treatment, and safe frontmatter mode can
require judgment that a shell script should not make silently.

Replace: TARGET_SKILL_DIRECTORY -> the local directory containing the Agent Skill bundle

Customize
```text
Audit and bootstrap the Agent Skill bundle at TARGET_SKILL_DIRECTORY for portable provenance.

First inventory every bundle file and read SKILL.md completely. Preserve stable filenames and existing content. Determine the initial semver bundle version from existing release or changelog evidence; if it cannot be established, ask me one concise question before writing.

Create MANIFEST.yaml beside SKILL.md with a normalized relative path, role, integer per-file revision, and SHA-256 for every tracked file. Do not list MANIFEST.yaml inside itself. Reject absolute paths, dot or parent components, duplicate paths, symlinks, quoted path scalars, and implicit missing hashes. Use hash: null only for an explicit opt-out.

Create CHANGELOG.md with a human-written initial entry that names every created or changed file and preserves any known history. Keep SKILL.md frontmatter compatible with its target loaders; use manifest-only version identity when extra frontmatter is unsafe.

Before reporting success, run the standalone Skill Provenance verifier, report its exit code and checked-file count, and show the complete proposed diff. Do not commit, push, install, publish, deploy, or replace source material unless I separately authorize it.
```

After bootstrap, keep the full bundle together. A later session should treat
the manifest and changelog as the portable source of identity and intent.
