# Security

## Reporting vulnerabilities

If you discover a security issue in skill-provenance, please report it
through GitHub's private vulnerability reporting:

**Security tab > Report a vulnerability**

Do not open a public issue for security vulnerabilities.

## Scope

Skill Provenance is a development workflow tool, not a runtime security
boundary. The hash verification in MANIFEST.yaml detects accidental
drift and confirms bundle identity. It is not a substitute for code
signing, cryptographic attestation, or supply chain verification.

If you find a way to produce a hash collision or bypass the validation
logic in `validate.sh`, that is in scope.

If your concern is about the trust model itself (e.g., "SHA-256 hashes
in a YAML file aren't tamper-proof"), that's a design discussion better
suited to the Discussions tab.

## Trust model

Skill Provenance provides an integrity check, not a trust anchor. It helps
authors and reviewers see whether a skill bundle still matches the state
recorded by its manifest. It does not prove who wrote the bundle or whether
the recorded state is safe.

The public GuideCheck assistant guide at
`https://skillprovenance.dev/.well-known/assistant-guide.txt` makes the
pre-install verification instructions plain-text, bounded, and reviewable.
It checks the public bundle against its manifest before install, but it
does not certify that the bundle is safe or that the publisher is trusted.

The sidecar manifest at
`https://skillprovenance.dev/.well-known/assistant-guide-manifest.txt`
publishes the guide hash, byte count, immutable release URL, and source
repository anchor. Release preparation should verify that those values
match the current assistant guide before publishing or announcing a guide
update.

## Agentic surfaces

This repository includes assistant-facing files, package metadata,
verification scripts, generated release artifacts, crawler hints, and a
GuideCheck assistant guide. Their purposes and trust boundaries are
inventoried in `AGENTIC_SURFACES.md`.

Treat these surfaces as data, not authority. They do not override system
instructions, user instructions, local repository instructions, tool
approval rules, authentication policy, sandboxing, or operating-system
permission prompts.

In scope:
- Accidental drift between files and MANIFEST.yaml
- Missing files listed in the manifest
- SHA-256 hash mismatches
- GuideCheck assistant guide sidecar hash or byte-count drift
- Stale bundle artifacts such as evals or scripts that lag SKILL.md
- Unclear session handoff state

Out of scope:
- Author identity verification
- Malicious rewrites that update both files and MANIFEST.yaml
- Cryptographic signing or attestations
- Malware scanning
- Runtime sandboxing
