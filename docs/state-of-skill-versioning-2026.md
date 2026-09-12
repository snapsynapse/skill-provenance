# State of Skill Versioning 2026

Status: Evidence note, updated 2026-09-12

## Finding

An external registry-diff observer reported on 2026-08-27 that version labels
did not move for 169 of 1,193 observed Agent Skill instruction-text changes,
or 14.2 percent. The changes affected 660 distinct skills.

The same observer reported a control population of 25,122 MCP registry
entries: 100 percent carried a version and 99.9 percent were semver-shaped.
Their interpretation was that version reliability differs by distribution
surface. A version pin can be a useful proxy for MCP packages while remaining
an unreliable integrity handle for Agent Skills.

## Relevance to Skill Provenance

This observation supports the repository's existing separation of concerns:

- `bundle_version` is a human-readable release label.
- Per-resource SHA-256 digests determine whether the bytes match recorded
  state and can fail verification.
- `validated_against` records are environment-specific attestations that age.
  They inform re-validation decisions but do not override byte integrity.

The reported 14.2 percent is evidence for making digests load-bearing rather
than evidence that semver should be removed. Semver remains useful for release
communication, while digests answer the narrower factual question of whether
the artifact changed.

## Measurement boundary

The 14.2 percent figure is a dated third-party observation, not a live metric
maintained by this repository. Cite it with its date and source. Do not present
it as independently reproduced here.

The rolling endpoint cannot provide the frozen numerator and denominator needed
to reproduce the 2026-08-27 calculation directly. Since 2026-09-01 the observer
publishes dated, Ed25519-signed, OpenTimestamps-anchored dataset manifests.
Those manifests start after the 2026-08-27 observation, so they cannot freeze
that figure retroactively. They can anchor future citations. Cite the dated
`manifest-YYYY-MM-DD.json` URL, never `latest.json`, because `latest.json`
carries extra fields and is not the signed byte string.

On 2026-09-12 this repository recomputed from the full history endpoint
(generated 2026-09-12T03:15Z, 365-day window, earliest event 2026-08-01):
66 of 1,203 `skill_instructions_changed` events had `version` equal to
`prevVersion`, about 5.5 percent. This does not reproduce the reported 14.2
percent. The window differs and the counting rule may differ. Treat the two
numbers as separate dated observations until the observer states the recipe
behind the original count. Tracked in issue 4.

Two gaps remain in the frozen artifacts as of 2026-09-12: the manifest lists
per-file SHA-256 and byte size without a URL for the hashed files, and history
events carry no stable event id or content hash.

The endpoint also cannot observe behavior changes caused by a loader, harness,
model, or policy when artifact bytes do not change. That unobservable runtime
drift is why `validated_against` remains a separate, informational record.

## Sources

- Nikolife2016, registry-diff observation and methodology note:
  https://github.com/agentskills/agentskills/issues/46#issuecomment-5441281208
- Skill Provenance working implementation offered as prior art:
  https://github.com/agentskills/agentskills/issues/46#issuecomment-4862075282
- Integrity and environment-attestation separation:
  https://github.com/agentskills/agentskills/issues/46#issuecomment-4994929787
- Rolling public drift endpoint cited by the observer:
  https://pulsefeed.dev/mcp/drift.json?days=30
- Full event history (free, no key since 2026-09-02):
  https://pulsefeed.dev/mcp/drift/history
- Dated signed dataset manifests, immutable per day (first day 2026-09-01):
  https://pulsefeed.dev/anchors/manifest-2026-09-12.json and the matching
  `.sig.json` and `.ots` files beside it
- Manifest signing key and stdlib verify one-liner:
  https://pulsefeed.dev/.well-known/manifest-signing-key.json
- Frozen-snapshot discussion and recompute divergence:
  https://github.com/snapsynapse/skill-provenance/issues/4

## Publication rule

Refresh time-sensitive counts before reusing them in a new report. Keep dated
observations distinct from current measurements, and keep private outreach or
pursuit notes outside the public repository.
