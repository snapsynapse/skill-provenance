# Roadmap

## Now

- Collect compatibility and verified-adoption reports using the tracked
  evidence contract. Keep verified adoption at zero until a report satisfies
  the identity, version, surface, and reproducibility requirements.
- Reconcile the separately published ClawHub copy after its user-controlled
  license attestation and upload boundary are completed.
- Dogfood manifests across portfolio skills and invite qualifying adopters to
  use the repository issue form.
- Use the dated skill-version drift evidence for targeted registry and
  toolmaker interop, keeping reported observations distinct from live metrics.
- Pin third-party GitHub Actions to immutable commits and design proportional
  `main` branch governance in separately reviewed changes.

## Adoption evidence gate

After the 6.3.0 release is public, measure verified adopters, GitHub Agent
Skill discovery, registry interest, and interop responses before adding a new
service surface. Lack of evidence should defer expansion rather than create a
parallel monitoring or packaging system.

## Later

- **Multi-bundle workspace support**: Track multiple skill bundles in a
  monorepo with a single plugin instance.
- **Detached manifest signatures**: Add an optional interoperable trust layer
  without turning the zero-dependency integrity checker into a PKI client.
- **Release identity attestations**: After stable subjects are reviewed, bind
  their digests to the repository, workflow identity, and release ref, then
  verify from a clean download.
- **Registry and package-manager interop**: Preserve portable bundle identity
  while leaving install resolution and consumer lockfiles to their owners.
- **Signing and citation publication**: Sign future commits and release tags
  after account-level setup. Consider one Zenodo record only after choosing
  the archival subject; add a DOI to `CITATION.cff` only after it resolves.
- **OpenSSF programs**: Re-run Scorecard after material gaps are addressed and
  begin Best Practices review only after the release-provenance story is
  coherent. Do not publish a badge from the 2026-09-05 local baseline.

## Not Yet

- **MCP server**: Programmatic verify/audit endpoint for CI pipelines
  and external tooling.
- **PostToolUse hook for auto-hash**: Automatically recompute SHA-256
  in MANIFEST.yaml when SKILL.md is edited. Deferred until there is a safe
  design that avoids silent manifest churn and preserves stale-file intent.
