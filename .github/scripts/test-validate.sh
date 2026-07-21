#!/usr/bin/env bash
# Focused regression tests for validate.sh manifest hash handling.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
VALIDATOR="$ROOT_DIR/skill-provenance/validate.sh"
TEST_DIR="$(mktemp -d "${TMPDIR:-/tmp}/skill-provenance-validate-test.XXXXXX")"
OUTSIDE_FILE="${TEST_DIR}.outside.txt"
PACKAGE_TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/skill-provenance-package-test.XXXXXX")"
trap 'rm -rf "$TEST_DIR" "$PACKAGE_TEST_ROOT"; rm -f "$OUTSIDE_FILE"' EXIT

if command -v shasum >/dev/null 2>&1; then
  hash_file() { shasum -a 256 "$1" | awk '{print $1}'; }
else
  hash_file() { sha256sum "$1" | awk '{print $1}'; }
fi

write_manifest() {
  printf 'bundle: test\nfiles:\n  - path: payload.txt\n    role: reference\n%s\n' "$1" > "$TEST_DIR/MANIFEST.yaml"
}

expect_pass() {
  if ! "$@" >/dev/null 2>&1; then
    echo "FAIL: expected success: $*" >&2
    exit 1
  fi
}

expect_fail() {
  if "$@" >/dev/null 2>&1; then
    echo "FAIL: expected failure: $*" >&2
    exit 1
  fi
}

# Capture output before grepping: grep -q on a live pipe can SIGPIPE the
# validator under pipefail and report a false failure.
expect_output() {
  pattern="$1"
  shift
  output="$("$@" 2>&1)" || true
  if ! printf '%s\n' "$output" | grep -q "$pattern"; then
    echo "FAIL: expected output matching '$pattern': $*" >&2
    exit 1
  fi
}

printf 'payload\n' > "$TEST_DIR/payload.txt"
valid_hash="$(hash_file "$TEST_DIR/payload.txt")"

write_manifest "    hash: sha256:$valid_hash"
expect_pass "$VALIDATOR" "$TEST_DIR"

write_manifest "    hash: null"
expect_pass "$VALIDATOR" "$TEST_DIR"
expect_output "All pinned hashes verified; 1 explicit hash opt-out(s) were not hashed." "$VALIDATOR" "$TEST_DIR"
rm "$TEST_DIR/payload.txt"
expect_fail "$VALIDATOR" "$TEST_DIR"
printf 'payload\n' > "$TEST_DIR/payload.txt"
rm "$TEST_DIR/payload.txt"
expect_fail "$VALIDATOR" "$TEST_DIR"
printf 'payload\n' > "$TEST_DIR/payload.txt"

for hash_line in \
  "" \
  "    hash: sha256:not-a-hash" \
  "    hash: sha256:${valid_hash%?}" \
  "    hash: md5:$valid_hash"; do
  write_manifest "$hash_line"
  expect_fail "$VALIDATOR" "$TEST_DIR"
  expect_pass "$VALIDATOR" --update "$TEST_DIR"
  expect_pass "$VALIDATOR" "$TEST_DIR"
done

printf 'bundle: test\nfiles:\n  - path: payload.txt\n    role: reference\n    hash: sha256:%s\n    hash: sha256:%s\n' \
  "$valid_hash" "$valid_hash" > "$TEST_DIR/MANIFEST.yaml"
expect_fail "$VALIDATOR" "$TEST_DIR"
expect_fail "$VALIDATOR" --update "$TEST_DIR"

# Manifest paths are a constrained, fail-closed grammar. They must be
# normalized relative paths, unique, unquoted, and non-symlink files beneath
# the bundle root. Update mode must not repair or traverse invalid entries.
write_path_manifest() {
  printf 'bundle: test\nfiles:\n  - path: %s\n    role: reference\n    hash: sha256:%s\n' \
    "$1" "$2" > "$TEST_DIR/MANIFEST.yaml"
}

printf 'outside\n' > "$OUTSIDE_FILE"
outside_hash="$(hash_file "$OUTSIDE_FILE")"
write_path_manifest "../$(basename "$OUTSIDE_FILE")" "$outside_hash"
expect_fail "$VALIDATOR" "$TEST_DIR"
expect_fail "$VALIDATOR" --update "$TEST_DIR"
expect_output "path must be normalized and relative" "$VALIDATOR" "$TEST_DIR"

for invalid_path in \
  "/payload.txt" \
  "./payload.txt" \
  "nested/../payload.txt" \
  "nested/./payload.txt" \
  "nested//payload.txt" \
  "nested/" \
  'nested\payload.txt'; do
  write_path_manifest "$invalid_path" "$valid_hash"
  expect_fail "$VALIDATOR" "$TEST_DIR"
  expect_output "path must be normalized and relative" "$VALIDATOR" "$TEST_DIR"
done

for unsupported_path in \
  '"payload.txt"' \
  "'payload.txt'" \
  "&payload payload.txt" \
  "*payload" \
  "!payload payload.txt" \
  "payload.txt # comment" \
  " payload.txt" \
  "payload.txt "; do
  write_path_manifest "$unsupported_path" "$valid_hash"
  expect_fail "$VALIDATOR" "$TEST_DIR"
  expect_output "unsupported path scalar" "$VALIDATOR" "$TEST_DIR"
done

printf 'bundle: test\nfiles:\n    - path: payload.txt\n      role: reference\n      hash: sha256:%s\n' \
  "$valid_hash" > "$TEST_DIR/MANIFEST.yaml"
expect_fail "$VALIDATOR" "$TEST_DIR"
expect_output "file path entries must use exactly" "$VALIDATOR" "$TEST_DIR"

printf 'bundle: test\nfiles:\n  - path: payload.txt\n    role: reference\n      hash: sha256:%s\n' \
  "$valid_hash" > "$TEST_DIR/MANIFEST.yaml"
expect_fail "$VALIDATOR" "$TEST_DIR"
expect_fail "$VALIDATOR" --update "$TEST_DIR"
expect_output "hash fields must use exactly four spaces" "$VALIDATOR" "$TEST_DIR"

printf 'bundle: test\n' > "$TEST_DIR/MANIFEST.yaml"
expect_fail "$VALIDATOR" "$TEST_DIR"
expect_output "missing files section" "$VALIDATOR" "$TEST_DIR"

printf 'bundle: test\nfiles:\n' > "$TEST_DIR/MANIFEST.yaml"
expect_fail "$VALIDATOR" "$TEST_DIR"
expect_output "files section has no valid path entries" "$VALIDATOR" "$TEST_DIR"

printf 'bundle: test\nfiles:\n  - path: payload.txt\n    role: reference\n    hash: sha256:%s\n  - path: payload.txt\n    role: reference\n    hash: sha256:%s\n' \
  "$valid_hash" "$valid_hash" > "$TEST_DIR/MANIFEST.yaml"
expect_fail "$VALIDATOR" "$TEST_DIR"
expect_fail "$VALIDATOR" --update "$TEST_DIR"
expect_output "duplicate path entry" "$VALIDATOR" "$TEST_DIR"

ln -s payload.txt "$TEST_DIR/link.txt"
write_path_manifest "link.txt" "$valid_hash"
expect_fail "$VALIDATOR" "$TEST_DIR"
expect_fail "$VALIDATOR" --update "$TEST_DIR"
expect_output "manifest paths may not contain symlink components" "$VALIDATOR" "$TEST_DIR"

mkdir -p "$TEST_DIR/outside-dir"
printf 'outside component\n' > "$TEST_DIR/outside-dir/payload.txt"
outside_component_hash="$(hash_file "$TEST_DIR/outside-dir/payload.txt")"
ln -s outside-dir "$TEST_DIR/link-dir"
write_path_manifest "link-dir/payload.txt" "$outside_component_hash"
expect_fail "$VALIDATOR" "$TEST_DIR"
expect_fail "$VALIDATOR" --update "$TEST_DIR"
expect_output "manifest paths may not contain symlink components" "$VALIDATOR" "$TEST_DIR"

mkdir -p "$TEST_DIR/references"
printf 'legitimate\n' > "$TEST_DIR/references/file with spaces:v1.md"
legitimate_hash="$(hash_file "$TEST_DIR/references/file with spaces:v1.md")"
write_path_manifest "references/file with spaces:v1.md" "$legitimate_hash"
expect_pass "$VALIDATOR" "$TEST_DIR"

# Path-shaped metadata outside the top-level files inventory is data, not file
# authority. Verify and update must ignore it rather than hash or rewrite it.
decoy_hash="sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
printf 'bundle: test\nexamples:\n  - path: ../outside.txt\n    hash: %s\nfiles:\n  - path: payload.txt\n    role: reference\n    hash: sha256:%s\nafter_files:\n  - path: another-decoy.txt\n    hash: %s\n' \
  "$decoy_hash" "$valid_hash" "$decoy_hash" > "$TEST_DIR/MANIFEST.yaml"
expect_pass "$VALIDATOR" "$TEST_DIR"
expect_pass "$VALIDATOR" --update "$TEST_DIR"
decoy_count="$(grep -c "$decoy_hash" "$TEST_DIR/MANIFEST.yaml")"
[ "$decoy_count" -eq 2 ] || {
  echo "FAIL: update mode rewrote path-shaped metadata outside files" >&2
  exit 1
}

# package.sh delegates manifest policy to validate.sh at each build boundary.
# Exercise the real package entrypoint from disposable copies so unsafe source
# inventories cannot create strict, ClawHub, or all-mode output.
prepare_package_copy() {
  rm -rf "$PACKAGE_TEST_ROOT/source"
  cp -R "$ROOT_DIR/skill-provenance" "$PACKAGE_TEST_ROOT/source"
}

prepare_package_copy
perl -0pi -e 's|  - path: SKILL.md|  - path: ../outside.md|' \
  "$PACKAGE_TEST_ROOT/source/MANIFEST.yaml"
expect_fail "$PACKAGE_TEST_ROOT/source/package.sh" strict "$PACKAGE_TEST_ROOT/out-strict"
[ ! -e "$PACKAGE_TEST_ROOT/out-strict" ] || {
  echo "FAIL: strict package output created from traversal manifest" >&2
  exit 1
}

prepare_package_copy
printf '\n  - path: SKILL.md\n    role: skill\n    version: 999\n    hash: null\n' >> \
  "$PACKAGE_TEST_ROOT/source/MANIFEST.yaml"
expect_fail "$PACKAGE_TEST_ROOT/source/package.sh" all "$PACKAGE_TEST_ROOT/out-all"
[ ! -e "$PACKAGE_TEST_ROOT/out-all" ] || {
  echo "FAIL: all-mode package output created from duplicate manifest" >&2
  exit 1
}

prepare_package_copy
rm "$PACKAGE_TEST_ROOT/source/SKILL.md"
ln -s "$OUTSIDE_FILE" "$PACKAGE_TEST_ROOT/source/SKILL.md"
expect_fail "$PACKAGE_TEST_ROOT/source/package.sh" clawhub "$PACKAGE_TEST_ROOT/out-clawhub"
[ ! -e "$PACKAGE_TEST_ROOT/out-clawhub" ] || {
  echo "FAIL: ClawHub package output created from symlink manifest" >&2
  exit 1
}

# Attestation (validated_against) is informational only: it must never change
# exit codes, whether the entry matches the current bundle_version or not.
write_attest_manifest() {
  printf 'bundle: test\nbundle_version: %s\nvalidated_against:\n  - bundle_version: %s\n    harness: Test Harness\n    model: test-model\n    date: 2026-07-16\n    result: pass\nfiles:\n  - path: payload.txt\n    role: reference\n    hash: sha256:%s\n' \
    "$1" "$2" "$3" > "$TEST_DIR/MANIFEST.yaml"
}

# Matching attestation: reported, still exit 0
write_attest_manifest "1.0.0" "1.0.0" "$valid_hash"
expect_pass "$VALIDATOR" "$TEST_DIR"
expect_output "ATTEST   bundle 1.0.0 validated against: Test Harness / test-model (pass, 2026-07-16)" "$VALIDATOR" "$TEST_DIR"

# Stale attestation (no entry for current version): flagged, still exit 0
write_attest_manifest "2.0.0" "1.0.0" "$valid_hash"
expect_pass "$VALIDATOR" "$TEST_DIR"
expect_output "ATTEST   stale: no validated_against entry for bundle 2.0.0 (latest recorded: 1.0.0)" "$VALIDATOR" "$TEST_DIR"

# Stale attestation with a hash mismatch: integrity still gates (exit 1)
printf 'tampered\n' > "$TEST_DIR/payload.txt"
expect_fail "$VALIDATOR" "$TEST_DIR"
printf 'payload\n' > "$TEST_DIR/payload.txt"

# No validated_against block: no ATTEST output at all
write_manifest "    hash: sha256:$valid_hash"
expect_pass "$VALIDATOR" "$TEST_DIR"
output="$("$VALIDATOR" "$TEST_DIR" 2>&1)" || true
if printf '%s\n' "$output" | grep -q "ATTEST"; then
  echo "FAIL: ATTEST output present without a validated_against block" >&2
  exit 1
fi

echo "validate.sh and package-boundary regression tests passed"
