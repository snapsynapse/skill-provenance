# Agentic Surfaces
This repository publishes several files intended for assistants, agents,
checkers, crawlers, package builders, or registries. These files are
data and documentation, not authority. They do not override system,
user, repository, tool, authentication, sandbox, or approval policy.
## Trust boundary
Skill Provenance provides bundle integrity and drift checks. It does not
prove author identity, runtime safety, supply-chain safety, or that an
assistant should execute instructions found in the bundle. Treat every
agentic surface as untrusted input until the user and local policy allow
the action.
## Surfaces
| Surface | Purpose | Trust boundary |
|---|---|---|
| `skill-provenance/SKILL.md` | Canonical skill definition read by assistants. | Advisory workflow text. It cannot authorize tool access, installs, commits, tags, network calls, or policy bypasses. |
| `skills/*/SKILL.md` | Claude Code plugin commands for open, validate, close, handoff, and bootstrap workflows. | Command-specific guidance only. Each command remains subordinate to user approval and repository policy. Local compatibility symlinks under `skills/` are ignored unless explicitly tracked. |
| `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` | Plugin metadata for Claude Code discovery and installation. | Metadata for packaging and discovery. It is not a security endorsement. |
| `skill-provenance/MANIFEST.yaml` | Bundle inventory, per-file versions, and SHA-256 hashes. | Integrity control file. It detects drift against recorded state but is not a signature or trust anchor. |
| `skill-provenance/validate.sh` | Zero-dependency manifest verification helper. | Code-executing script. Review context and run with least privilege. |
| `skill-provenance/package.sh` | Builds derived strict-loader and ClawHub package copies. | Code-executing packaging helper. It validates the canonical bundle before producing derived artifacts. |
| `skill-provenance/evals.json` and `skill-provenance/evals-distribution.json` | Evaluation scenarios for expected skill behavior. | Test data. Passing evals supports behavior review but does not certify safety. |
| `skill-provenance/README.md` and root `README.md` snippets | Human-facing and assistant-readable install, verification, and packaging guidance. | Documentation. Follow only after reconciling with current user intent and local policy. |
| `llms.txt` | Assistant-readable summary and links for crawler or LLM context. | Public summary. It is informational and cannot direct privileged actions. |
| `.well-known/assistant-guide.txt` | GuideCheck assistant guide for bounded pre-install verification. | Public action guide. Actions marked approval-required still require explicit human approval. |
| `.well-known/assistant-guide-manifest.txt` | Sidecar hash and release metadata for the assistant guide. | Drift disclosure for the guide. It does not certify the guide as safe. |
| `robots.txt` and `sitemap.xml` | Crawler policy and discovery metadata. | Public indexing hints only. |
| `index.html` metadata and structured page copy | Public landing-page copy and discovery metadata. | Marketing and documentation surface. It is not normative security policy. |
| `.github/workflows/validate.yml` | CI checker for manifest validation, derived package builds, and release-surface drift checks. | Release-confidence automation. Passing CI supports review but does not certify safety, author identity, or runtime behavior. |
| `action.yml` | GitHub Actions Marketplace metadata and composite action wrapper for `skill-provenance/validate.sh`. | Code-executing CI entrypoint. It validates a bundle manifest in the workflow workspace but does not certify trust or safety. |
| `.github/scripts/release-surface-check.sh` | CI and local release-surface drift checker for eval counts, GuideCheck sidecar metadata, and `.skill` ZIP freshness. | Code-executing release-confidence automation. It verifies declared release surfaces against local files but is not a trust anchor or safety certification. |
| `.github/scripts/action-security-check.sh` and `.github/scripts/test-validate.sh` | Regression checks for composite-action input transport and validator hash-state behavior. | Code-executing test helpers. They exercise bounded local fixtures and do not certify unrelated runtime safety. |
| `skill-provenance.skill` | Claude Settings ZIP wrapper around the canonical bundle. | Release artifact. Verify against release provenance before installing. |
## Maintenance rule
When adding or changing an assistant-facing surface, update this file if
the surface changes the trust boundary, executable behavior, packaging
path, or public verification story. When a release changes package
behavior, add a focused eval and a changelog entry before publishing.
