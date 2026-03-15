# Skill Provenance — Publish Checklist

Steps to publish an update from a fresh terminal.


## 1. Navigate to the repo

```bash
cd ~/Git/skill-provenance
```


## 2. Verify the bundle is clean

```bash
./skill-provenance/validate.sh skill-provenance/
```

All 5 files should show `OK`. If any show `MISMATCH`, run
`./skill-provenance/validate.sh --update skill-provenance/` to recompute,
then review what changed.


## 3. Rebuild the .skill ZIP

```bash
rm -f skill-provenance.skill
zip -r skill-provenance.skill skill-provenance/ -x "skill-provenance/.DS_Store"
```


## 4. Commit and push to GitHub

```bash
git add skill-provenance/ skill-provenance.skill README.md AGENTS.md CONTRIBUTING.md
git commit -m "skill-provenance X.Y.Z: summary of changes"
git push
```

Replace `X.Y.Z` with the new `bundle_version` from MANIFEST.yaml.
Only stage files you actually changed.


## 5. Tag and create GitHub release

```bash
gh release create vX.Y.Z \
  --title "vX.Y.Z — Short description" \
  --notes "$(cat <<'EOF'
## What's new

- Bullet points summarizing changes

## Install

**Claude Settings UI:** Download `skill-provenance.skill` below → Settings → Skills → Add Skill.

**Claude Code / Codex / Gemini CLI:** Use the `skill-provenance/` directory directly.

**ClawHub:** `clawhub install skill-provenance`
EOF
)" \
  --latest \
  skill-provenance.skill
```


## 6. Publish to ClawHub

```bash
clawhub publish skill-provenance/ \
  --slug skill-provenance \
  --name "Skill Provenance" \
  --version X.Y.Z \
  --changelog "Short changelog summary"
```


## 7. Verify both destinations

```bash
# GitHub
gh release view vX.Y.Z

# ClawHub
clawhub inspect skill-provenance
```

Confirm version numbers match in both places.


## Version bump reference

In MANIFEST.yaml, bump `bundle_version` according to:

| Change type | Bump | Example |
|---|---|---|
| Docs, typos, references | PATCH | 4.2.1 → 4.2.2 |
| New features, new files | MINOR | 4.2.1 → 4.3.0 |
| Breaking spec changes | MAJOR | 4.2.1 → 5.0.0 |

Per-file `version` integers in MANIFEST.yaml increment by 1 for each
file that changed. Don't forget to update `bundle_date` to today.
