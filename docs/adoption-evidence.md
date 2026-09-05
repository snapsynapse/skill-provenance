# Adoption evidence

Updated: 2026-09-05

## Purpose

This document defines what Skill Provenance may report as verified adoption.
It prevents discovery signals from being overstated as production use and gives
adopters a low-friction way to submit reproducible evidence.

## Evidence classes

| Class | Required evidence | Permitted claim |
|---|---|---|
| Verified adoption | Identified repository or organization, Skill Provenance version, installation surface, use case, and a public reproducible reference or explicit owner confirmation | Verified adopter on the named version and surface |
| Compatibility report | Platform and model, Skill Provenance version, outcome, and enough steps or output to reproduce the test | Reported compatibility test |
| Distribution | Attributed registry listing, redistribution, catalog entry, fork, or package mirror | Distribution or discovery signal |
| Interest | Stars, views, downloads, search impressions, referrals, or issue engagement | Interest signal only |
| Unknown | Missing version, identity, surface, or reproducible evidence | Unknown; do not count as adoption |

Downloads, listings, forks, redistributions, and search visibility do not by
themselves establish installation, continued use, or production adoption.

## Submission path

Use the repository's Compatibility Report issue form for a platform test or an
adoption report. Public evidence is preferred. If evidence cannot be public,
the maintainer may record an owner-confirmed adoption without exposing private
details, but must label the evidence boundary.

Every accepted report records:

- adopter or project identity;
- Skill Provenance version or commit;
- installation or execution surface;
- observed use case and outcome;
- evidence URL or owner-confirmation date;
- classification from the table above;
- date last verified.

## Current ledger

As of 2026-09-05, the repository has external distribution and compatibility
signals but no entry that satisfies the verified-adoption contract above.
Verified adopter count: 0. This is not a claim that nobody uses the project; it
means qualifying evidence has not yet been recorded.

| Adopter | Version | Surface | Evidence | Last verified |
|---|---|---|---|---|
| None recorded | Unknown | Unknown | Unknown | 2026-09-05 |
