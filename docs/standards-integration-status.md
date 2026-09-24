# Standards integration status

Status: Evidence note, observed 2026-09-24

## Purpose

This note records where Skill Provenance stands in external Agent Skills
standards work, using public thread state only. It separates the kinds of
evidence that are easy to conflate, identifies the smallest unresolved gap,
and states the minimal contract an adopter or specification could carry.
It does not claim adoption, and it does not treat inactivity as rejection.

## Evidence classes

| Class | Meaning | Current state |
|---|---|---|
| Normative incorporation | A specification requires or defines the mechanism | None |
| Informative reference | A specification cites the mechanism or project as prior art | None |
| Maintainer engagement | A specification maintainer responds on the substance | Yes, agentskills#46 |
| Compatibility | Works within a specification without changes to it | Yes, agentskills.io format; provenance files are invisible to loaders that do not know them |
| Distribution | Listed or redistributed by a registry or catalog | ClawHub v6.3.0; Awesome OpenClaw Skills |
| Verified adoption | Per [adoption evidence](adoption-evidence.md) | 0 as of 2026-09-05 |

## Thread state

| Thread | Kind | State | Last activity | Skill Provenance contribution |
|---|---|---|---|---|
| [agentskills#46](https://github.com/agentskills/agentskills/issues/46) | Issue: versioning and locking | Open | 2026-08-27 | Prior-art comment 2026-07-02; attestation-versus-integrity comment 2026-07-16 |
| [agentskills#254](https://github.com/agentskills/agentskills/pull/254) | Pull request: `.well-known` URI discovery spec | Open, unmerged since 2026-03-16 | 2026-09-17 | Prior-art comment 2026-07-16 with an offer to draft informative text |
| [agentskills#380](https://github.com/agentskills/agentskills/pull/380) | Pull request: optional versioning in the `.well-known` index | Open; author moved discussion to #254 | 2026-07-16 | Review comment 2026-07-16 |
| [ai-catalog Discussion #85](https://github.com/Agent-Card/ai-catalog/discussions/85) | Discussion: per-resource integrity and version-bound validation attestations | Open, no replies | 2026-07-16 | Opened by this project |

Maintainer response on agentskills#46 (2026-07-09) agreed that integrity,
attestation, and behavioral pinning are separate concerns, stated that #254
relies on domain ownership and TLS, and pointed to AI Catalog as the more
targeted venue.

In AI Catalog, the current trust-model work is happening in issues rather
than in Discussion #85. [Issue #69](https://github.com/Agent-Card/ai-catalog/issues/69)
records that the specification's integrity check conflates a provenance
source digest with a digest of the served artifact, with a proposed
entry-level content digest and a counterargument that the digest must sit
inside the signed payload. Related open work includes
[#108](https://github.com/Agent-Card/ai-catalog/issues/108) (bind signed
trust manifests to release coordinates) and
[#117](https://github.com/Agent-Card/ai-catalog/issues/117) (group trust
metadata by contributor), active on 2026-09-23. This project has not
participated in those issues.

## What the specifications already cover

The #254 draft requires one `digest` per index entry: the SHA-256 of the
served artifact's raw bytes, either a `SKILL.md` file or an archive.
Clients must verify it after download and must not use content that fails.
That is transport integrity, rooted in domain ownership and TLS.

It does not cover the files after an archive is unpacked, a bundle that
reaches an agent without the index (pasted into a chat, copied between
surfaces, handed to another agent), or which files belong to the bundle.
Those are the cases Skill Provenance addresses.

## Smallest unresolved gap

Neither specification text references a post-extraction, per-resource
integrity layer, and no citable reference for one exists outside this
repository's implementation. The offer on #254 to draft informative text
has not been delivered. #254 itself is unmerged, so there is not yet
normative text for such a paragraph to attach to.

## Minimal provenance contract

The smallest contract that survives the boundary crossings above:

- A companion manifest beside `SKILL.md`, never inside it, so it costs no
  prompt tokens and is ignored by loaders that do not know it.
- One entry per bundle file: relative path and SHA-256 of its bytes. A
  listed file that is missing is a failure, and so is an unlisted file:
  the inventory is complete, with only the manifest itself exempt. The
  reference validator enforces this from bundle 7.0.0 (released
  2026-09-23); 6.3.0 and earlier verify only what they list, a gap observed
  2026-09-24.
- A verifier that fails closed on mismatch, missing inventory, unlisted
  entries, unsafe or ambiguous paths, and symlinks, with distinct outcomes
  for match, drift, and no manifest.
- Optional, never gating: a release label (`bundle_version`) and
  environment attestations (`validated_against`) bound to one release.

This composes with the #254 index digest rather than replacing it. The
index digest verifies what was served; the manifest verifies what was
unpacked and what traveled without the index. Neither proves publisher
identity, intent, or runtime safety.

## Measurement boundary

Thread states are public observations from 2026-09-24 and will change.
Recheck each thread before citing this note. Absence of a reply is recorded
as absence, not as a decision by any maintainer.
