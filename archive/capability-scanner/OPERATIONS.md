---
skill_bundle: capability-scanner
file_role: reference
version: 1
version_date: 2026-03-07
previous_version: null
change_summary: Initial operations guide.
---

# Capability Scanner — Operations Guide

## System Overview

The AI Capability Reference Scanner is a two-part system:

1. **The Skill** (`SKILL.md`) — An editorial decision framework encoding the project's scope rules, ontology, inclusion criteria, and assessment format. Reusable instructions any agent can load and follow.
2. **The Recurring Task** — A scheduled background agent that runs every 3 days. It loads the skill, scans the AI ecosystem for changes, applies the editorial framework, and creates GitHub issues for candidates that pass the filter.

Neither part works alone. The skill provides judgment without action. The task provides action without judgment. Together they form a closed loop:

```
scan → assess → file → log → notify
```

### Relationship Diagram

```
┌──────────────────────────────────────────────────┐
│              Recurring Task (every 3 days)        │
│                                                   │
│  1. Load capability-scanner skill                 │
│  2. Search web for AI announcements               │
│  3. Apply skill's filter criteria                 │
│  4. Produce structured assessments                │
│  5. Create GitHub issues via PAT                  │
│  6. Append to scan log                            │
│  7. Send notification (if findings exist)         │
│                                                   │
│  Inputs:     SKILL.md (editorial rules)           │
│              github-token.txt (API access)        │
│              scan-log.md (history)                 │
│                                                   │
│  Outputs:    GitHub issues on the repo            │
│              scan-log.md entries                   │
│              In-app notifications                  │
└──────────────────────────────────────────────────┘
```

### File Locations

| Item | Location | Purpose |
|---|---|---|
| Skill definition | `capability-scanner/SKILL.md` | Editorial framework, ontology, assessment format |
| Operations guide | `capability-scanner/OPERATIONS.md` | Human and agent troubleshooting (this file) |
| Manifest | `capability-scanner/MANIFEST.yaml` | Bundle integrity and version tracking |
| Changelog | `capability-scanner/CHANGELOG.md` | Version history |
| README | `capability-scanner/README.md` | Quick orientation |
| GitHub PAT | `cron_tracking/capability-scanner/github-token.txt` | Authentication for issue creation |
| Scan log | `cron_tracking/capability-scanner/scan-log.md` | Append-only history of every scan |
| Fallback findings | `cron_tracking/capability-scanner/findings.md` | Created only when GitHub is unavailable |

---

## The Skill

### What It Contains

The skill encodes everything an agent needs to make editorial decisions about the AI Capability Reference:

- **Project context** — What the repo is, who it serves, what platforms are tracked
- **Inclusion criteria** — Rules for when a provider, product, implementation, capability, or plan should be added
- **Ontology** — The six entity types (Capability, Implementation, Model, Provider, Plan, Model-Access) and how to classify candidates
- **Capability taxonomy** — The seven groups (Understand, Respond, Create, Work With My Stuff, Act For Me, Connect, Access Context) with specific capability slugs
- **Scanning instructions** — Step-by-step process for gathering signals, filtering, assessing, and filing issues
- **Quality rules** — Five editorial guardrails
- **Data schema reference** — The markdown format used in `data/platforms/` files

### When It Is Used

The skill is loaded in two contexts:

- **Automatically by the recurring task** — Every 3 days the background agent loads it before scanning.
- **Manually by a human** — Ask Perplexity Computer to "load the capability-scanner skill and assess [some announcement or topic]" at any time. Useful for ad-hoc evaluation.

### How to Update the Skill

If the project's scope, ontology, tracked platforms, or editorial criteria change, the skill should be updated to match. The canonical sources of truth are the repo's governance documents:

- `SCOPE.md` — Inclusion/exclusion rules
- `ONTOLOGY.md` — Entity types and relationships
- `CAPABILITY_TAXONOMY.md` — Capability groups and slugs
- `data/_schema.md` — Data format for platform files
- `PROJECT_GOALS.md` — Audience, philosophy, and information model

> [!important] Provenance
> When updating the skill, follow the [[skill-provenance]] protocol: bump the version in SKILL.md metadata, update MANIFEST.yaml with new hashes, and append to CHANGELOG.md.

---

## The Recurring Task

### Schedule

| Property | Value |
|---|---|
| Frequency | Every 3 days |
| Time | 8:00 AM MST (15:00 UTC) |
| Task ID | `d06402a4` |
| Mode | Background (isolated agent, no conversation history) |

### Execution Flow

Each run follows this sequence:

1. **Load the skill** — Reads `capability-scanner/SKILL.md` for editorial rules
2. **Gather signals** — Searches official blogs, tech press, and pricing pages for AI product changes in the last 7 days
3. **Filter for relevance** — Applies the skill's pass/skip criteria to each signal
4. **Assess candidates** — Produces a structured assessment for each passing signal
5. **Deduplicate** — Searches existing open issues on the repo before creating new ones
6. **Create GitHub issues** — Uses `curl` with the fine-grained PAT
7. **Log the scan** — Appends a summary to `scan-log.md`
8. **Notify** — Sends an in-app notification if ADD or UPDATE candidates were found; stays silent otherwise

### GitHub Authentication

The task uses a fine-grained GitHub Personal Access Token (PAT):

| Property | Value |
|---|---|
| Token location | `cron_tracking/capability-scanner/github-token.txt` |
| Scope | `snapsynapse/ai-capability-reference` only |
| Permission | Issues (read and write) only |
| Private repo access | None |
| Method | `curl` against GitHub REST API |

> [!warning] Token Expiration
> The PAT has a finite expiration. When it expires, the scanner falls back to saving findings locally and sends a notification. See [[#The GitHub token expired]] for refresh instructions.

### Issue Format

**Title patterns:**
- `[Scanner] Add: Feature Name`
- `[Scanner] Update: Feature Name — What changed`
- `[Scanner] Watch: Feature Name`

**Body:** Full structured assessment in markdown (entity type, capability mapping, relevance, scope assessment, recommendation, evidence URLs, urgency level).

**Labels:** `scanner` (if the label exists on the repo).

---

## Troubleshooting — Human

### The scanner hasn't created any issues recently

Check the scan log first. Read `cron_tracking/capability-scanner/scan-log.md`. If recent entries exist but show "0 candidates found," the ecosystem was quiet — this is normal.

If the log has no recent entries, the recurring task may have stopped. Ask Perplexity Computer:

> "List my scheduled tasks"

It should show the AI Capability Reference Scanner. If missing, re-create it.

### Issues are being created but they seem wrong

The skill's editorial criteria may need updating. Check whether the repo's `SCOPE.md`, `ONTOLOGY.md`, or `CAPABILITY_TAXONOMY.md` have changed since the skill was last updated. If so:

> "Update the capability-scanner skill to match the current repo governance docs"

### The scanner created a duplicate issue

The task searches open issues before creating new ones, but keyword search may miss near-duplicates. Close the duplicate on GitHub. If it keeps happening for a specific feature, the search pattern may need adjustment.

### I want to change the scan frequency

> "Change the AI Capability Reference Scanner to run [daily / weekly / every N days]"

### I want to run a scan right now

> "Load the capability-scanner skill and run a scan now"

This executes the full process in-conversation rather than waiting for the next scheduled run.

### I want to evaluate a specific announcement

> "Load the capability-scanner skill and assess [paste or describe the announcement]"

### The GitHub token expired

1. The scanner will save findings to `cron_tracking/capability-scanner/findings.md` and notify you
2. Create a new token at [github.com/settings/tokens?type=beta](https://github.com/settings/tokens?type=beta)
   - Repository: `snapsynapse/ai-capability-reference` only
   - Permission: Issues — Read and write
3. Tell Perplexity Computer:

> "Update the capability-scanner GitHub token to [new token]"

### I want to add or remove a tracked platform

1. Update the repo's `SCOPE.md`
2. Ask Perplexity Computer:

> "Update the capability-scanner skill — [platform] has been added/removed"

3. The next scan will use the updated criteria

### I want to stop the scanner entirely

> "Delete the AI Capability Reference Scanner scheduled task"

This removes the recurring task. The skill remains in your library for manual use.

---

## Troubleshooting — Agents

> [!note]
> This section is written for AI agents that load this skill or execute the recurring task.

### Before scanning

1. Load the `capability-scanner` skill. All editorial rules are in SKILL.md.
2. Read `cron_tracking/capability-scanner/scan-log.md` to determine when the last scan ran and what was found. This prevents re-filing issues for the same announcements.
3. Verify the GitHub token exists at `cron_tracking/capability-scanner/github-token.txt`. If missing, skip issue creation and save findings to `cron_tracking/capability-scanner/findings.md`.

### During scanning

1. Search broadly first, then filter. Better to find 20 signals and filter down to 3 than to miss something by searching too narrowly.
2. Determine the entity type BEFORE assessing scope. "What kind of thing is this?" comes before "Does it belong?"
3. Always check for existing open issues before creating new ones:
   ```
   GET /search/issues?q=repo:snapsynapse/ai-capability-reference+is:issue+is:open+KEYWORD
   ```
4. If GitHub API returns 401/403, the token is expired/revoked. Do not retry. Save to fallback file and notify user.
5. If GitHub API returns 422, try creating the issue without labels. If still failing, save to fallback.

### After scanning

1. Always append to the scan log, even if nothing was found. An empty scan is still a data point.
2. Only send a notification if ADD or UPDATE candidates were found.
3. Do not modify the skill file. If criteria seem outdated, note it in the scan log and notify the user.

### Failure Mode Reference

| Symptom | Likely Cause | Action |
|---|---|---|
| Token file missing | File deleted or path changed | Save to fallback, notify user |
| GitHub API 401 | Token expired or revoked | Save to fallback, notify user to refresh |
| GitHub API 403 | Token lacks permission | Save to fallback, notify user |
| GitHub API 422 | Invalid issue body or label | Retry without labels; if still failing, save to fallback |
| GitHub API 404 | Repo name wrong or deleted | Save to fallback, notify user |
| No search results | Quiet period or queries too narrow | Log as empty scan, do not notify |
| 10+ candidates | Major event (e.g., Google I/O) | Process all, note unusual volume in log |
| Skill not found | Skill removed from library | Notify user to re-save the skill |

---

## Maintenance Checklists

### Monthly

- [ ] Check `scan-log.md` for consistent entries (~10 per month expected)
- [ ] Review open `[Scanner]` issues on GitHub — close addressed or stale items
- [ ] Verify GitHub PAT expiration date — rotate before it expires

### When the Repo Changes

- [ ] `SCOPE.md` changed → Update skill's inclusion criteria and tracked platforms
- [ ] `ONTOLOGY.md` changed → Update skill's entity types section
- [ ] `CAPABILITY_TAXONOMY.md` changed → Update skill's capability taxonomy
- [ ] `data/_schema.md` changed → Update skill's data schema reference
- [ ] New platform added → Add to skill's tracked platforms list

> [!important]
> After any skill update, follow [[skill-provenance]] protocol: bump version, update manifest, append changelog.

### When Perplexity Computer Changes

The recurring task depends on these tools:

- `search_web` — gathering signals
- `fetch_url` — reading official pages
- `bash` with `curl` — GitHub API calls
- `send_notification` — alerting the user

If any of these change behavior, the task instructions may need adjustment. The skill itself is tool-agnostic.

---

## Architecture Decision Records

### Why a skill + recurring task?

The editorial judgment is complex (ontology, scope rules, capability taxonomy, six entity types, five quality rules). Embedding all of that in a task description would make it fragile and hard to update. Separating "what to decide" (skill) from "when to run" (task) means:

- The skill can be updated independently of the schedule
- The skill can be invoked manually for ad-hoc assessments
- The task instructions stay short and focused on execution
- Other agents or workflows can reuse the same editorial framework

### Why `curl` + PAT instead of the GitHub connector?

The GitHub OAuth connector requests access to all repositories including private ones. A fine-grained PAT scoped to a single public repo with only Issues permission provides minimum necessary access. The tradeoff is manual token rotation.

### Why every 3 days?

Most significant feature launches are announced with lead time, and pricing changes rarely happen without notice. Every 3 days balances coverage against resource usage. Adjustable at any time.

### Why background mode?

The scanner does not need conversation history or user interaction during execution. Background mode keeps it isolated and allows it to run when the user is not active.
