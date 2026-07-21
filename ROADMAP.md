# Roadmap

## Now

- Publish the prepared 6.0.0 manifest-boundary hardening release after
  review: constrained inventory grammar, path containment, duplicate-path
  rejection, symlink rejection, and package-boundary revalidation.
- Ship a standalone zero-install verifier and bootstrap path for authors
  who do not use the Claude Code plugin.
- Refresh the July 2026 ecosystem evidence before publishing the State of
  Skill Versioning report or reusing competitive claims.
- Confirm the GitHub Actions Marketplace listing and document the supported
  stable action reference.
- Dogfood manifests across portfolio skills and add a verified-adopters loop.

## Later

- **Multi-bundle workspace support**: Track multiple skill bundles in a
  monorepo with a single plugin instance.
- **Detached manifest signatures**: Add an optional interoperable trust layer
  without turning the zero-dependency integrity checker into a PKI client.
- **Registry and package-manager interop**: Preserve portable bundle identity
  while leaving install resolution and consumer lockfiles to their owners.

## Not Yet

- **MCP server**: Programmatic verify/audit endpoint for CI pipelines
  and external tooling.
- **PostToolUse hook for auto-hash**: Automatically recompute SHA-256
  in MANIFEST.yaml when SKILL.md is edited. Deferred until there is a safe
  design that avoids silent manifest churn and preserves stale-file intent.
