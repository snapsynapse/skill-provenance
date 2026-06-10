# Handoff: Skill Provenance adoption strategy

Date: 2026-06-09
Author: Claude (Fable 5) session with Sam, from competitive research run 2026-06-09
Status: Approved by Sam, ready for implementation
Audience: A Sonnet/Opus-level agent executing each phase. Each phase is independently implementable. Read this whole file before starting any phase.

## Why this exists

Skill Provenance solves cross-surface skill identity: when a skill moves between Claude Chat, Cowork, Claude Code, Gemini CLI, Codex, or any other surface, nothing today tells you what that skill is and whether it changed. The repo has been public for months with listings on community catalogs, but adoption has not happened. Research on 2026-06-09 found why, and what to do.

## Competitive state (verified 2026-06-09 via Perplexity sonar-pro)

- **Chainguard Agent Skills** (launched March 2026): ingests skills from skills.sh (expanding to ClawHub, SkillsMP), reviews against security rulesets, hardens via reconciliation agents, republishes with audit trail and provenance. Registry-side only.
- **JFrog Agent Skills Registry**: Artifactory-based versioned skills-as-artifacts, cryptographic signing, in-toto attestations. No public skill-level manifest or SKILL.md content-hash format beyond artifact checksums. Registry-side only.
- **Agensi, Anthropic official directory**: partial verification. Registry-side only.
- **agentskills/agentskills spec** (~20k stars, stewarded by the Agentic AI Foundation): SKILL.md defines no version or integrity fields. Governance is GitHub-based with topic working groups (security WG exists per public docs).

The strategic wedge: every competitor verifies provenance inside their registry walls. None of it travels with the bundle. A Chainguard-hardened skill pasted into Claude Chat carries no verifiable identity. Skill Provenance's MANIFEST.yaml is in-bundle and surface-portable. That position is unclaimed. It is also why no funded player has built it: a portable manifest commoditizes registry verification.

Prior outreach correction: Sam's past submissions went to curated lists (VoltAgent/awesome-openclaw-skills PR 397 merged; addyosmani/agent-skills issue 18 open) and possibly issues on other repos, NOT to agentskills/agentskills. The spec body has never seen this proposal. Before filing Phase 3, search agentskills/agentskills issues (all states, any author) for prior art on version/integrity fields, and search for any existing issue authored by snapsynapse across skill-related repos to link as history.

## Positioning (governs all phases)

Not "version tracking for skills". The frame is **portable skill identity**: the checksum that travels with the skill. Verification at point of use on any surface, vs competitors' verification at point of distribution. Security framing first: a skill is unsigned third-party instructions piped into an agent with tool access; registry verification dies the moment the skill leaves the registry.

## Phase 1: Reposition the public surface (1-2 sessions)

1. Rewrite README.md lead and landing page (index.html, llms.txt) around portable skill identity and the security frame above. Keep all existing technical content; this is a framing pass, not a rewrite of mechanics.
2. Add a comparison table (README + landing): Skill Provenance vs Chainguard Agent Skills vs JFrog Skills Registry vs registry badges. Axis: where verification happens (in-bundle vs registry), survives surface transfer (yes/no), works offline/air-gapped, open standard vs product.
3. Note: repo follows skill-provenance plugin conventions (MANIFEST.yaml, version headers, CHANGELOG). Use the skill-provenance:close skill (or follow CHANGELOG/MANIFEST conventions manually) when finishing the session. Repo has generated/static surface files (index.html, llms.txt, sitemap.xml); check for build scripts before editing outputs directly.
4. Constraints from global rules: bare https URLs, no www; Obsidian-compatible markdown; no em dashes.

## Phase 2: Ship the enforcer (2-3 sessions)

Goal: tooling creates de facto standards (semver won via npm, SPDX via scanners). Nobody adopts manifests by reading about them.

1. `skill-lint` CLI (the ROADMAP "Optional bin/ CLI" item, promoted to Now): validate MANIFEST.yaml schema, recompute SHA-256 per file, flag drift and stale evals, exit nonzero on mismatch. Shell or Node single-file preferred; zero heavy deps; runs anywhere.
2. GitHub Action wrapping the CLI: drop-in workflow, emits a status badge (shields.io endpoint or static badge committed by CI). Name suggestion: `skill-provenance/verify-action`.
3. Zero-install verify path: a short canonical prompt block (publish on landing page + README) that any agent on any surface can execute against a bundle's MANIFEST.yaml using only file reads and a sha256 utility. This is the cross-surface demo that makes the pitch concrete. Test it on at least Claude Code and one non-Claude surface (Gemini CLI or Codex) and record results in AGENTIC_SURFACES.md.
4. After shipping: offer PRs adding the action to 3-5 popular skill repos (pick from skills.sh top lists). Each merged PR is distribution. Per-repo confirmation with Sam before opening external PRs.

## Phase 3: Spec proposal at agentskills/agentskills (1 session)

1. File ONE issue (not a PR) at agentskills/agentskills proposing optional `version` and `integrity` fields in SKILL.md frontmatter, with a companion manifest (MANIFEST.yaml) as the extended form for multi-file bundles.
2. Frame: security and portability. Cite Chainguard and JFrog as evidence the ecosystem is already inventing incompatible registry-side versions of this; an in-spec optional field prevents fragmentation. Cite the shipped CLI/action (Phase 2) as a working implementation. Do not lead with skillprovenance.dev branding; lead with the problem and offer the implementation.
3. Locate the Agentic AI Foundation security working group (check agentskills.io and the repo's governance docs) and apply/join. A WG member proposing skill supply-chain provenance beats a drive-by issue. Surface contact paths to Sam if joining requires a human identity step.
4. Draft the issue text for Sam's review before posting. Posting is outward-facing: requires Sam's explicit go.

## Phase 4: Adoption conversations (Sam-led, agent-drafted)

Draft, do not send. All outreach goes out under Sam's name after his review.

1. Chainguard: pitch their audit trail emitting Skill Provenance manifests, so their hardening proof travels out of their walls. Complementary framing.
2. JFrog: in-toto attestation over a Skill Provenance manifest as the attested payload.
3. Registries (skills.sh, SkillsMP, ClawHub, claude-plugins.dev): display a provenance badge for skills shipping MANIFEST.yaml. One registry displaying it makes competitors need it.
4. Narrative content: threat-model post ("registry verification dies at the registry door") for dev.to/LinkedIn/SigSub via the promo-orchestrator and linkedin-post skills.

## Sequencing and dependencies

Phase 1 has no dependencies; do it first. Phase 2 is the critical path (Phases 3 and 4 both cite it). Phase 3 and 4 can run in parallel after Phase 2 ships. Re-verify the competitive facts above if more than ~6 weeks have passed; Chainguard and JFrog are moving.

## Done criteria

- Phase 1: README + landing lead with portable-identity framing; comparison table live.
- Phase 2: CLI verifies this repo's own bundle in CI; badge green; zero-install prompt proven on 2+ surfaces.
- Phase 3: issue posted (after Sam review) and WG contact made.
- Phase 4: three outreach drafts delivered to Sam.
