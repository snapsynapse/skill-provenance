#!/usr/bin/env bash
# Verify release-facing surfaces that are easy to let drift.
# Dependencies: bash, awk, shasum or sha256sum, wc, unzip, sort, dirname,
# mktemp, cmp, and diff.

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
  local total_count

  core_count="$(count_evals skill-provenance/evals.json)"
  supplemental_count="$(count_evals skill-provenance/evals-distribution.json)"
  total_count="$((core_count + supplemental_count))"

  [ "$core_count" -gt 0 ] || fail "no core evals found"
  [ "$supplemental_count" -gt 0 ] || fail "no supplemental evals found"

  grep -q "${core_count} core" README.md || fail "README.md does not mention ${core_count} core evals"
  grep -q "${supplemental_count} supplemental" README.md || fail "README.md does not mention ${supplemental_count} supplemental evals"
  grep -q "${core_count} core" AGENTS.md || fail "AGENTS.md does not mention ${core_count} core evals"
  grep -q "${supplemental_count} supplemental" AGENTS.md || fail "AGENTS.md does not mention ${supplemental_count} supplemental evals"
  grep -q "${core_count} core" CLAUDE.md || fail "CLAUDE.md does not mention ${core_count} core evals"
  grep -q "${supplemental_count} supplemental" CLAUDE.md || fail "CLAUDE.md does not mention ${supplemental_count} supplemental evals"
  grep -q "${total_count} evaluation scenarios" README.md || fail "README.md does not mention ${total_count} total evals"
  grep -q "<div class=\"number warm\">${total_count}</div>" index.html || fail "index.html does not display ${total_count} total evals"

  echo "Eval counts OK: ${core_count} core, ${supplemental_count} supplemental, ${total_count} total"
}

check_release_tag_families() {
  local surface

  for surface in README.md index.html skill-provenance/README.md; do
    if grep -Eq 'releases/latest|@latest' "$surface"; then
      fail "$surface uses an ambiguous generic latest bundle reference"
    fi
  done

  grep -Eq 'releases/tag/v[0-9]+\.[0-9]+\.[0-9]+' README.md ||
    fail "README.md has no exact bundle release link"
  grep -Eq 'releases/tag/v[0-9]+\.[0-9]+\.[0-9]+' index.html ||
    fail "index.html has no exact bundle release link"
  grep -Eq '^immutable-release-url: https://github.com/snapsynapse/skill-provenance/releases/tag/guidecheck-[0-9]+\.[0-9]+\.[0-9]+$' .well-known/assistant-guide-manifest.txt ||
    fail "assistant guide manifest has no exact GuideCheck release link"

  echo "Release tag families use exact bundle and GuideCheck references"
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

check_standalone_verifier() {
  local actual_validator_hash
  local pinned_validator_hash

  [ -x verify.sh ] || fail "verify.sh missing or not executable"
  [ -x .github/scripts/test-standalone-verify.sh ] ||
    fail "standalone verifier regression test missing or not executable"

  actual_validator_hash="$(sha256_hash skill-provenance/validate.sh)"
  pinned_validator_hash="$(
    awk -F'"' '/^VALIDATOR_SHA256=/ { print $2; exit }' verify.sh
  )"

  [ -n "$pinned_validator_hash" ] || fail "verify.sh has no pinned validator SHA-256"
  [ "$actual_validator_hash" = "$pinned_validator_hash" ] ||
    fail "standalone verifier pin drift: wrapper $pinned_validator_hash, validator $actual_validator_hash"

  grep -q '^VALIDATOR_SOURCE_URL="https://raw.githubusercontent.com/snapsynapse/skill-provenance/main/skill-provenance/validate.sh"$' verify.sh ||
    fail "verify.sh canonical validator URL drift"

  ./verify.sh skill-provenance >/dev/null
  echo "Standalone verifier pin OK: $actual_validator_hash"
}

check_skill_zip() {
  local archive="skill-provenance.skill"
  local archive_listing
  local expected_listing
  local expected_file
  local actual_file
  local path
  local dir
  local archived_hash
  local source_hash

  [ -f "$archive" ] || fail "$archive missing"
  unzip -t "$archive" >/dev/null
  archive_listing="$(unzip -Z1 "$archive")"

  printf '%s\n' "$archive_listing" | grep -Fx "skill-provenance/" >/dev/null ||
    fail "$archive does not contain the canonical skill-provenance/ directory"

  expected_file="$(mktemp "${TMPDIR:-/tmp}/skill-provenance-expected.XXXXXX")"
  actual_file="$(mktemp "${TMPDIR:-/tmp}/skill-provenance-actual.XXXXXX")"
  trap 'rm -f "$expected_file" "$actual_file"' EXIT

  {
    printf '%s\n' "skill-provenance/" "skill-provenance/MANIFEST.yaml"
    while IFS= read -r path; do
      [ -n "$path" ] || continue
      printf '%s\n' "skill-provenance/$path"
      dir="$(dirname "$path")"
      while [ "$dir" != "." ]; do
        printf '%s\n' "skill-provenance/$dir/"
        dir="$(dirname "$dir")"
      done
    done < <(
      awk '
        /^[[:space:]]*-[[:space:]]*path:[[:space:]]*/ {
          line = $0
          sub(/^[[:space:]]*-[[:space:]]*path:[[:space:]]*/, "", line)
          print line
        }
      ' skill-provenance/MANIFEST.yaml
    )
  } | sort -u > "$expected_file"

  printf '%s\n' "$archive_listing" | sort -u > "$actual_file"
  if ! cmp -s "$expected_file" "$actual_file"; then
    echo "ERROR: $archive inventory differs from the canonical bundle" >&2
    diff -u "$expected_file" "$actual_file" >&2 || true
    exit 1
  fi

  while IFS= read -r path; do
    [ -n "$path" ] || continue
    printf '%s\n' "$archive_listing" | grep -Fx "skill-provenance/$path" >/dev/null ||
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

  rm -f "$expected_file" "$actual_file"
  trap - EXIT

  echo ".skill archive matches canonical bundle"
  echo ".skill SHA-256: $(sha256_hash "$archive")"
}

check_eval_counts
check_release_tag_families
check_assistant_guide_manifest
check_standalone_verifier
check_skill_zip
