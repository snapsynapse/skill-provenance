# Roadmap

## Current (plugin v0.1.0)

- Four focused plugin skills: open, close, handoff, bootstrap
- Monolithic skill preserved via symlink
- Marketplace submission

## Next

- **PostToolUse hook for auto-hash**: Automatically recompute SHA-256
  in MANIFEST.yaml when SKILL.md is edited. Deferred from v0.1 because
  it fires on every edit and has a high-risk failure mode if misconfigured.
- **Validate command**: Dedicated `/skill-provenance:validate` that runs
  hash checks without the full open protocol.

## Future

- **MCP server**: Programmatic verify/audit endpoint for CI pipelines
  and external tooling.
- **Optional `bin/` CLI**: Standalone shell commands for hash verification
  outside Claude Code sessions.
- **Multi-bundle workspace support**: Track multiple skill bundles in a
  monorepo with a single plugin instance.
