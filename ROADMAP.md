# Roadmap

## Now (plugin v0.2.0)

- Five focused plugin skills: open, validate, close, handoff, bootstrap
- Dedicated validate command for hash and inventory checks without the
  full open-session protocol
- Monolithic skill preserved via symlink
- Marketplace submission

## Later

- **Optional `bin/` CLI**: Standalone shell commands for hash verification
  outside Claude Code sessions.
- **Multi-bundle workspace support**: Track multiple skill bundles in a
  monorepo with a single plugin instance.

## Not Yet

- **MCP server**: Programmatic verify/audit endpoint for CI pipelines
  and external tooling.
- **PostToolUse hook for auto-hash**: Automatically recompute SHA-256
  in MANIFEST.yaml when SKILL.md is edited. Deferred until there is a safe
  design that avoids silent manifest churn and preserves stale-file intent.
