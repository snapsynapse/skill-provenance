#!/usr/bin/env bash
# Focused regression tests for validate.sh manifest hash handling.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
VALIDATOR="$ROOT_DIR/skill-provenance/validate.sh"
TEST_DIR="$(mktemp -d "${TMPDIR:-/tmp}/skill-provenance-validate-test.XXXXXX")"
trap 'rm -rf "$TEST_DIR"' EXIT

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

printf 'payload\n' > "$TEST_DIR/payload.txt"
valid_hash="$(hash_file "$TEST_DIR/payload.txt")"

write_manifest "    hash: sha256:$valid_hash"
expect_pass "$VALIDATOR" "$TEST_DIR"

write_manifest "    hash: null"
expect_pass "$VALIDATOR" "$TEST_DIR"
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

echo "validate.sh hash-state regression tests passed"
