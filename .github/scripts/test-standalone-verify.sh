#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
test_root="$(mktemp -d "${TMPDIR:-/tmp}/skill-provenance-standalone-test.XXXXXX")"
trap 'rm -rf "$test_root"' EXIT

expect_status() {
  local expected="$1"
  shift
  local actual

  set +e
  "$@" >/dev/null 2>&1
  actual="$?"
  set -e

  [ "$actual" -eq "$expected" ] || {
    echo "FAIL: expected exit $expected, got $actual for: $*" >&2
    exit 1
  }
}

"$repo_root/verify.sh" "$repo_root/skill-provenance" >/dev/null

mkdir -p "$test_root/clean/skill-provenance"
cp "$repo_root/verify.sh" "$test_root/clean/verify.sh"
cp "$repo_root/skill-provenance/validate.sh" "$test_root/clean/skill-provenance/validate.sh"
"$test_root/clean/verify.sh" "$repo_root/skill-provenance" >/dev/null

mkdir -p "$test_root/tampered/skill-provenance"
cp "$repo_root/verify.sh" "$test_root/tampered/verify.sh"
cp "$repo_root/skill-provenance/validate.sh" "$test_root/tampered/skill-provenance/validate.sh"
printf '\n# tampered\n' >> "$test_root/tampered/skill-provenance/validate.sh"

if "$test_root/tampered/verify.sh" "$repo_root/skill-provenance" >"$test_root/tampered.out" 2>&1; then
  echo "FAIL: standalone verifier accepted a validator with the wrong hash" >&2
  exit 1
fi

grep -q "local validator hash mismatch" "$test_root/tampered.out" || {
  echo "FAIL: standalone verifier did not explain the pinned-validator failure" >&2
  exit 1
}

mock_bin="$test_root/mock-bin"
mkdir -p "$mock_bin"
{
  printf '%s\n' '#!/usr/bin/env bash'
  printf '%s\n' 'set -eu'
  printf '%s\n' 'output=""'
  printf '%s\n' 'while [ "$#" -gt 0 ]; do'
  printf '%s\n' '  case "$1" in'
  printf '%s\n' '    -o) output="$2"; shift 2 ;;'
  printf '%s\n' '    *) shift ;;'
  printf '%s\n' '  esac'
  printf '%s\n' 'done'
  printf '%s\n' '[ -n "$output" ]'
  printf '%s\n' 'cp "$MOCK_CURL_SOURCE" "$output"'
} > "$mock_bin/curl"
chmod +x "$mock_bin/curl"

mkdir -p "$test_root/download" "$test_root/download-tmp"
cp "$repo_root/verify.sh" "$test_root/download/verify.sh"

PATH="$mock_bin:$PATH" \
MOCK_CURL_SOURCE="$repo_root/skill-provenance/validate.sh" \
TMPDIR="$test_root/download-tmp" \
  "$test_root/download/verify.sh" "$repo_root/skill-provenance" >/dev/null

tampered_download="$test_root/tampered-download.sh"
cp "$repo_root/skill-provenance/validate.sh" "$tampered_download"
printf '\ntouch "$EXECUTION_SENTINEL"\n' >> "$tampered_download"
execution_sentinel="$test_root/downloaded-validator-executed"

if PATH="$mock_bin:$PATH" \
  MOCK_CURL_SOURCE="$tampered_download" \
  EXECUTION_SENTINEL="$execution_sentinel" \
  TMPDIR="$test_root/download-tmp" \
  "$test_root/download/verify.sh" "$repo_root/skill-provenance" >"$test_root/download-tampered.out" 2>&1; then
  echo "FAIL: standalone verifier accepted a downloaded validator with the wrong hash" >&2
  exit 1
fi

grep -q "downloaded validator hash mismatch" "$test_root/download-tampered.out" || {
  echo "FAIL: standalone verifier did not explain the downloaded-validator pin failure" >&2
  exit 1
}
[ ! -e "$execution_sentinel" ] || {
  echo "FAIL: standalone verifier executed a downloaded validator before checking its hash" >&2
  exit 1
}

mkdir -p "$test_root/no manifest"
expect_status 2 env \
  PATH="$mock_bin:$PATH" \
  MOCK_CURL_SOURCE="$repo_root/skill-provenance/validate.sh" \
  TMPDIR="$test_root/download-tmp" \
  "$test_root/download/verify.sh" "$test_root/no manifest"

cp -R "$repo_root/skill-provenance" "$test_root/hash mismatch bundle"
printf '\nfixture drift\n' >> "$test_root/hash mismatch bundle/README.md"
expect_status 1 env \
  PATH="$mock_bin:$PATH" \
  MOCK_CURL_SOURCE="$repo_root/skill-provenance/validate.sh" \
  TMPDIR="$test_root/download-tmp" \
  "$test_root/download/verify.sh" "$test_root/hash mismatch bundle"

if find "$test_root/download-tmp" -type f -print -quit | grep -q .; then
  echo "FAIL: standalone verifier left a downloaded validator in TMPDIR" >&2
  exit 1
fi

# The wrapper never treats an empty or option-shaped value as "use the
# default directory", passes only verification options through, and applies
# --strict to the target.
expect_status 1 "$repo_root/verify.sh" ""
expect_status 1 "$repo_root/verify.sh" --update "$repo_root/skill-provenance"
expect_status 1 "$repo_root/verify.sh" --allow-unlisted "$repo_root/skill-provenance"
expect_status 1 "$repo_root/verify.sh" "$repo_root/skill-provenance" "$repo_root/skill-provenance"
expect_status 2 "$repo_root/verify.sh" -- --help
expect_status 0 "$repo_root/verify.sh" -- "$repo_root/skill-provenance"
expect_status 0 "$repo_root/verify.sh" --strict "$repo_root/skill-provenance"

mkdir "$test_root/null bundle"
printf 'payload\n' > "$test_root/null bundle/payload.txt"
printf 'bundle: test\nfiles:\n  - path: payload.txt\n    hash: null\n' > "$test_root/null bundle/MANIFEST.yaml"
expect_status 0 "$repo_root/verify.sh" "$test_root/null bundle"
expect_status 1 "$repo_root/verify.sh" --strict "$test_root/null bundle"
expect_status 1 "$repo_root/verify.sh" \
  "--expect-manifest-sha256=0000000000000000000000000000000000000000000000000000000000000000" \
  "$test_root/null bundle"

echo "Standalone verifier enforces local and downloaded pins, preserves exit codes, and cleans temporary validators"
