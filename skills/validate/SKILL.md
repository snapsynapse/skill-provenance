---
description: >
  Run a focused validation check for a skill bundle. Use when the user asks
  to validate, verify hashes, check MANIFEST.yaml, confirm files are present,
  or distinguish a canonical bundle from a derived install or registry copy
  without opening or closing a full editing session.
---

# Skill Provenance: Validate

Run the hash and inventory check only. This is a narrow verification command,
not the full open-session or close-session protocol.

## When to use

Run `/skill-provenance:validate` when the user wants to know whether the
current bundle matches its `MANIFEST.yaml`, whether files are missing, or
whether a copy appears to be canonical or derived.

## Protocol

1. **Locate the bundle root.** Use the directory containing `MANIFEST.yaml`.
   If no manifest exists, report that the bundle is unversioned and suggest
   `/skill-provenance:bootstrap`.
2. **Run `validate.sh` when available.** Prefer:
   ```bash
   ./validate.sh
   ```
   If the script is not present, compute SHA-256 hashes for files listed in
   `MANIFEST.yaml` and compare them manually.
3. **Report validation results only.** Include:
   - File count checked
   - Missing files
   - Hash mismatches
   - Files skipped because no hash is recorded
   - Exit code or equivalent pass/fail result
4. **Identify copy type.** Use `MANIFEST.yaml` and local contents to say
   whether the copy appears to be:
   - a canonical source bundle
   - a strict-platform install copy
   - a registry or `.skill` package
   - incomplete or ambiguous
   A derived copy is valid if its own manifest describes exactly the files
   present. Do not treat missing development-only files as corruption unless
   the copy's manifest lists them.
5. **Do not mutate files.** Do not update hashes, bump versions, edit the
   changelog, create a handoff note, or run the close protocol. If the user
   asks to fix mismatches, recommend `/skill-provenance:close` or an explicit
   `validate.sh --update` workflow.

## Output

Keep the response concise:
```text
Bundle: my-skill 1.2.0
Copy type: canonical source bundle
Files: 7 checked, 0 missing, 0 mismatched, 0 skipped
Result: pass
```
If validation fails, name the specific files and explain that a mismatch
means the file no longer matches the recorded manifest state. This is an
integrity check, not a trust anchor.
