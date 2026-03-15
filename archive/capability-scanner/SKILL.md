---
name: capability-scanner
description: >-
  Scan the AI ecosystem for new features, providers, capabilities, and pricing
  changes that may warrant additions or updates to the AI Capability Reference
  repository (snapsynapse/ai-capability-reference). Use when monitoring AI
  product announcements, evaluating whether a new feature or provider belongs
  in the reference, or assessing ecosystem changes against the project's
  ontology and scope rules. Applies editorial judgment based on the project's
  inclusion criteria, audience definition, and ontology-first design principles.
metadata:
  author: snapsynapse
  repository: https://github.com/snapsynapse/ai-capability-reference
  skill_bundle: capability-scanner
  file_role: skill
  version: 2
  version_date: 2026-03-07
  previous_version: 1
  change_summary: >-
    Added provenance tracking via skill-provenance metaskill.
    Added OPERATIONS.md, CHANGELOG.md, README.md, and MANIFEST.yaml.
    Moved version tracking to manifest. Updated scan log paths to
    cron_tracking/capability-scanner/ subdirectory.
---

# AI Capability Reference Scanner

## When to Use This Skill

Use this skill when you need to:

- Scan the AI ecosystem for new features, capabilities, providers, or pricing changes
- Evaluate whether a specific announcement warrants an addition or update to the AI Capability Reference
- Produce a structured assessment of a candidate addition against the project's editorial criteria
- Create a GitHub issue recommending an addition, update, or new provider entry

## Project Context

The AI Capability Reference is a community-maintained tracker of AI feature availability across subscription tiers. It serves educators, facilitators, AI learners, and professionals comparing what their current AI access enables.

Repository: https://github.com/snapsynapse/ai-capability-reference

### Tracked Platforms

The reference currently tracks these consumer-facing AI products:

- ChatGPT (OpenAI)
- Claude (Anthropic)
- Copilot (Microsoft)
- Gemini (Google)
- Perplexity
- Grok (xAI)
- Local/open-weight models (Llama, Mistral, DeepSeek, Qwen, Codestral)

### Platform Inclusion Criteria

Platforms are included when they hold greater than 1% share of commercially available LLM models, excluding enterprise-only platforms like Databricks and DataRobot. A provider is included when at least one of:

- The repo already tracks one of its products, implementations, or model-access records
- The provider is materially relevant to the audience (educators, learners, professionals)
- The provider represents an important comparison point in teaching or demos

### What Is Tracked

Consumer-facing AI product capabilities, with emphasis on:

- Which subscription tier unlocks access
- Which operating systems and surfaces are supported
- What limits and caveats apply
- Current release status (GA, beta, preview, deprecated)
- When information was last verified

### What Is NOT Tracked

- API-only capabilities (unless they have a consumer-facing interface)
- Enterprise-only platforms with no consumer tier
- Low-level technical specs (unless they are a primary driver of user choice)
- Developer tools with no end-user-facing product

## Ontology: Entity Types

Before evaluating any candidate, determine what kind of entity it is:

### 1. Capability

A plain-English thing a person wants to do. User-perspective, not implementation-perspective.

Examples: `search-the-web`, `speak-back-in-real-time`, `organize-work-in-projects`, `use-files-i-provide`, `generate-images`

### 2. Implementation (Surface)

The specific application, interface, or integration where capabilities are accessed.

Examples: `chatgpt-web`, `chatgpt-ios`, `claude-ai-web`, `copilot-windows`

### 3. Model

The specific engine powering the capability.

Examples: `gpt-4o`, `claude-3-5-sonnet`, `llama-3-70b`

### 4. Provider

The entity responsible for the model or implementation.

Examples: `openai`, `anthropic`, `google`, `meta`

### 5. Plan (Tier)

The commercial or access level that governs availability.

Examples: `free`, `plus`, `pro`, `team`, `enterprise`

### 6. Model-Access (Junction)

The specific combination of a Model available on a Plan via an Implementation. This is where actual feature tracking happens.

## Capability Taxonomy

The reference organizes capabilities into these groups:

1. **Understand**: `read-text-and-documents`, `see-images-and-screens`, `hear-audio-and-speech`
2. **Respond**: `write-and-explain`, `speak-back-in-real-time`
3. **Create**: `make-and-edit-documents`, `write-and-edit-code`, `generate-images`, `generate-video`
4. **Work With My Stuff**: `use-files-i-provide`, `organize-work-in-projects`, `remember-context-over-time`
5. **Act For Me**: `search-the-web`, `do-multi-step-research`, `take-actions-and-run-tools`
6. **Connect**: `connect-to-external-systems`, `build-reusable-ai-workflows`
7. **Access Context**: `use-it-on-my-surfaces`

## Scanning Instructions

### Step 1: Gather Signals

Search for recent AI product announcements across these source categories:

**Official blogs and changelogs** (primary sources):
- OpenAI blog (openai.com/blog)
- Anthropic blog/news (anthropic.com/news)
- Google AI blog (blog.google/technology/ai)
- Microsoft AI blog
- Perplexity blog
- xAI/Grok announcements
- Meta AI blog (for open-weight models)
- Mistral AI blog
- DeepSeek announcements

**Tech press** (secondary sources):
- The Verge, TechCrunch, Ars Technica, Wired
- Use for corroboration, not as sole evidence

**Product pricing/feature pages** (verification sources):
- chatgpt.com/pricing
- claude.ai/pricing
- gemini.google.com pricing
- copilot.microsoft.com pricing
- perplexity.ai/pro

Search for announcements within the last 7 days (or since the last scan). Use queries like:
- "[provider] new feature announcement [month] [year]"
- "[provider] pricing change [month] [year]"
- "[provider] new capability launch"
- "AI product updates this week"

### Step 2: Filter for Relevance

For each signal found, apply these filters:

**Pass**: The announcement describes one of:
- A new consumer-facing feature on a tracked platform
- A pricing or plan tier change on a tracked platform
- A new platform/surface for an existing feature (e.g., mobile launch)
- A status change (beta to GA, feature deprecated)
- A limit or constraint change (rate limits, regional availability)
- A new provider/product that meets the inclusion criteria

**Skip**: The announcement describes one of:
- An API-only change with no consumer-facing impact
- An internal infrastructure or model architecture improvement with no user-visible change
- A rumor, leak, or unconfirmed report without official sourcing
- An enterprise-only feature with no consumer tier
- A developer tool with no end-user product
- A minor UX tweak that does not affect capability availability

### Step 3: Assess Each Candidate

For each candidate that passes the filter, produce a structured assessment:

```
CANDIDATE: [Brief name]
ENTITY TYPE: [Capability | Implementation | Model | Provider | Plan | Model-Access]
PROVIDER: [Which provider]
PRODUCT: [Which product, if applicable]

WHAT CHANGED:
[1-2 sentence description of the change]

CAPABILITY MAPPING:
[Which capability taxonomy entries does this relate to?]

RELEVANCE TO AUDIENCE:
[Why would an educator, learner, or professional care?]

SCOPE ASSESSMENT:
- Meets inclusion criteria: [Yes/No + reason]
- Materially helps audience understand access: [Yes/No + reason]
- Changes what a user can do or compare: [Yes/No + reason]

RECOMMENDATION: [ADD | UPDATE | WATCH | SKIP]
- ADD: Should be added as a new entry
- UPDATE: An existing entry needs modification
- WATCH: Interesting but not yet actionable (e.g., announced but not shipped)
- SKIP: Does not meet inclusion criteria

EVIDENCE:
- [Source URL 1]
- [Source URL 2]

URGENCY: [HIGH | MEDIUM | LOW]
- HIGH: Already shipped, affects tracked platforms, impacts plan comparisons
- MEDIUM: Shipped but niche, or announced with firm date
- LOW: Announced without date, or minor change
```

### Step 4: Create GitHub Issue

For each candidate with recommendation ADD, UPDATE, or WATCH, create a GitHub issue on `snapsynapse/ai-capability-reference` with:

**Issue title format**:
- For ADD: `[Scanner] Add: [Feature/Provider Name]`
- For UPDATE: `[Scanner] Update: [Feature Name] — [What changed]`
- For WATCH: `[Scanner] Watch: [Feature/Provider Name]`

**Issue body**: Include the full structured assessment from Step 3, formatted in markdown.

**Labels** (if available): Use labels like `scanner`, `addition`, `update`, or `watch` as appropriate.

### Step 5: Track What Was Scanned

After each scan, save a brief log to `/home/user/workspace/cron_tracking/capability-scanner/scan-log.md` (append, do not overwrite) with:

```
## Scan: [Date]
- Sources checked: [list]
- Candidates found: [count]
- Issues created: [count with links]
- Skipped: [count with brief reasons]
```

## Quality Rules

1. **Never recommend adding something based solely on tech press** — always require an official source (vendor blog, help docs, pricing page, or official announcement).
2. **Prefer accuracy over completeness** — it is better to skip an uncertain candidate than to recommend adding unverified information.
3. **Apply the core rule**: Inclusion is not based on whether something exists. Inclusion is based on whether tracking it materially helps the project audience understand what an AI system can do, what access they already have, and what they would gain by changing tools, plans, or deployment modes.
4. **Watch for ontology drift** — do not recommend adding things that are really just a model family, a plan tier, or a vendor brand umbrella with no clear user-facing container.
5. **Respect the "useful truth over marketing truth" philosophy** — note real-world limits, caveats, and restrictions, not just headline features.

## Data Schema Reference

When recommending additions, reference the existing data format. Each platform feature file in `data/platforms/` follows this structure:

- YAML frontmatter: name, vendor, logo, status_page, pricing_page, last_verified
- Pricing table: Plan, Price, Notes
- Feature sections with: Category, Status, Gating, Launched, Verified, Checked
- Availability by plan: Plan, Available, Limits, Notes
- Platform support: Platform, Available, Notes
- Regional notes
- Talking point (presenter-ready sentence)
- Sources (official links)
- Changelog

### Category Values

`vision`, `image-gen`, `video-gen`, `voice`, `search`, `research`, `browser`, `coding`, `agents`, `local-files`, `cloud-files`, `integrations`, `video`, `other`

### Status Values

`ga`, `beta`, `preview`, `deprecated`

### Gating Values

`free`, `paid`, `invite`, `org-only`
