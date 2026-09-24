# State of Skill Versioning 2026

Status: Evidence note, updated 2026-09-23

## Finding

An external registry-diff observer's full event history, recomputed here and
confirmed by the observer on 2026-09-17, showed version labels unmoved for 66
of 1,210 Agent Skill instruction-text changes to 2026-09-13, or 5.5 percent.

The observer originally reported on 2026-08-27 that 169 of 1,193 changes, or
14.2 percent, had no version movement, affecting 660 distinct skills. That
figure was read off a rolling 30-day feed without a published method, and the
observer has since stated it cannot be reproduced. It is retained here only as
the dated original claim and should not be cited as a finding.

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

The reproduced 5.5 percent is evidence for making digests load-bearing rather
than evidence that semver should be removed. Any nonzero rate means a label
alone cannot answer whether bytes changed. Semver remains useful for release
communication, while digests answer the narrower factual question of whether
the artifact changed.

## Measurement boundary

The 5.5 percent figure is a dated observation, not a live metric maintained by
this repository. Cite it with its date, the history endpoint, and the recipe
below. The 14.2 percent figure is not reproduced and must not be presented as a
finding.

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
percent.

On 2026-09-17 the observer stated the recipe on issue 4: a
`skill_instructions_changed` event counts as "label did not move" when
`version == prevVersion`. The observer's recompute over the full history to
2026-09-13 gave 66 of 1,210, or 5.5 percent, matching this repository's
count. The observer confirmed the 14.2 percent was read off the rolling feed
on 2026-08-27, was never published with a method, and cannot be reproduced.

The history is not frozen. The observer retracted 839 false
`skill_instructions_changed` events caused by a 2026-09-17 source format
change, recorded as appended retraction lines that the endpoint excludes by
default. A 2026-09-24 recompute (history generated 2026-09-24T01:25Z, series
start 2026-07-30) gave 122 of 1,419, about 8.6 percent, and 122 of 1,285 for
events dated to 2026-09-13, so earlier windows have also changed. Recompute
before reuse and cite a dated manifest rather than a rolling count.

The two frozen-artifact gaps recorded on 2026-09-12 are closed. Verified here
on 2026-09-24 against `manifest-2026-09-23.json` (Ed25519 signature valid):
every `files[]` entry carries a `url` and `encoding: "gzip"`, and one fetched
file's decoded SHA-256 and byte size matched its entry. History events carry
an `eventId` whose recipe is published in the response as `idRecipe`.

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
