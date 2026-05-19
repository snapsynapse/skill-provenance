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

In scope:
- Accidental drift between files and MANIFEST.yaml
- Missing files listed in the manifest
- SHA-256 hash mismatches
- Stale bundle artifacts such as evals or scripts that lag SKILL.md
- Unclear session handoff state

Out of scope:
- Author identity verification
- Malicious rewrites that update both files and MANIFEST.yaml
- Cryptographic signing or attestations
- Malware scanning
- Runtime sandboxing
