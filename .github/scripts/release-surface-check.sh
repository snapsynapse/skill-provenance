#!/usr/bin/env bash
# Verify release-facing surfaces that are easy to let drift.
# Dependencies: bash, awk, shasum or sha256sum, wc, unzip.

set -euo pipefail

export LC_ALL=C
export LANG=C

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT_DIR"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

if command -v shasum >/dev/null 2>&1; then
  sha256_hash() { shasum -a 256 "$1" | awk '{print $1}'; }
elif command -v sha256sum >/dev/null 2>&1; then
  sha256_hash() { sha256sum "$1" | awk '{print $1}'; }
else
  fail "neither shasum nor sha256sum found"
fi

count_evals() {
  awk '/"id"[[:space:]]*:/ { count++ } END { print count + 0 }' "$1"
}

manifest_value() {
  local key="$1"
  awk -v key="$key" '
    $0 ~ "^" key ":" {
      sub("^[^:]+:[[:space:]]*", "")
      print
      exit
    }
  ' .well-known/assistant-guide-manifest.txt
}

check_eval_counts() {
  local core_count
  local supplemental_count

  core_count="$(count_evals skill-provenance/evals.json)"
  supplemental_count="$(count_evals skill-provenance/evals-distribution.json)"

  [ "$core_count" -gt 0 ] || fail "no core evals found"
  [ "$supplemental_count" -gt 0 ] || fail "no supplemental evals found"

  grep -q "${core_count} core" README.md || fail "README.md does not mention ${core_count} core evals"
  grep -q "${supplemental_count} supplemental" README.md || fail "README.md does not mention ${supplemental_count} supplemental evals"
  grep -q "${core_count} core" AGENTS.md || fail "AGENTS.md does not mention ${core_count} core evals"
  grep -q "${supplemental_count} supplemental" AGENTS.md || fail "AGENTS.md does not mention ${supplemental_count} supplemental evals"
  grep -q "${core_count} core" CLAUDE.md || fail "CLAUDE.md does not mention ${core_count} core evals"
  grep -q "${supplemental_count} supplemental" CLAUDE.md || fail "CLAUDE.md does not mention ${supplemental_count} supplemental evals"

  echo "Eval counts OK: ${core_count} core, ${supplemental_count} supplemental"
}

check_assistant_guide_manifest() {
  local guide_hash
  local guide_bytes
  local manifest_hash
  local manifest_bytes

  [ -f .well-known/assistant-guide.txt ] || fail "assistant guide missing"
  [ -f .well-known/assistant-guide-manifest.txt ] || fail "assistant guide manifest missing"

  guide_hash="$(sha256_hash .well-known/assistant-guide.txt)"
  guide_bytes="$(wc -c < .well-known/assistant-guide.txt | awk '{print $1}')"
  manifest_hash="$(manifest_value guide-sha256)"
  manifest_bytes="$(manifest_value guide-bytes)"

  [ "$guide_hash" = "$manifest_hash" ] || fail "assistant guide hash drift: manifest $manifest_hash, actual $guide_hash"
  [ "$guide_bytes" = "$manifest_bytes" ] || fail "assistant guide byte drift: manifest $manifest_bytes, actual $guide_bytes"

  for key in guide-version immutable-release-url profile profile-version canonical-url repository-url; do
    [ -n "$(manifest_value "$key")" ] || fail "assistant guide manifest missing $key"
  done

  echo "Assistant guide sidecar OK: $guide_hash, $guide_bytes bytes"
}

check_skill_zip() {
  local archive="skill-provenance.skill"
  local path
  local archived_hash
  local source_hash

  [ -f "$archive" ] || fail "$archive missing"
  unzip -t "$archive" >/dev/null

  unzip -l "$archive" | awk '{ print $4 }' | grep -qx "skill-provenance/" ||
    fail "$archive does not contain the canonical skill-provenance/ directory"

  while IFS= read -r path; do
    [ -n "$path" ] || continue
    unzip -l "$archive" "skill-provenance/$path" | grep -q "skill-provenance/$path" ||
      fail "$archive missing skill-provenance/$path"
    archived_hash="$(unzip -p "$archive" "skill-provenance/$path" | sha256_hash -)"
    source_hash="$(sha256_hash "skill-provenance/$path")"
    [ "$archived_hash" = "$source_hash" ] ||
      fail "$archive has stale $path: archive $archived_hash, source $source_hash"
  done < <(
    awk '
      /^[[:space:]]*-[[:space:]]*path:[[:space:]]*/ {
        line = $0
        sub(/^[[:space:]]*-[[:space:]]*path:[[:space:]]*/, "", line)
        print line
      }
    ' skill-provenance/MANIFEST.yaml
  )

  echo ".skill archive matches canonical bundle"
  echo ".skill SHA-256: $(sha256_hash "$archive")"
}

check_eval_counts
check_assistant_guide_manifest
check_skill_zip
