#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
action_file="$repo_root/action.yml"
entrypoint="$repo_root/action-validate.sh"
test_root="$(mktemp -d "${TMPDIR:-/tmp}/skill-provenance-action-test.XXXXXX")"
trap 'rm -rf "$test_root"' EXIT

if command -v shasum >/dev/null 2>&1; then
  hash_file() { shasum -a 256 "$1" | awk '{print $1}'; }
else
  hash_file() { sha256sum "$1" | awk '{print $1}'; }
fi

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

# Every input reaches the shell through one environment mapping and nowhere
# else. An expression interpolated into a run line would be a script
# injection point.
check_input_transport() {
  local input="$1"
  local variable="$2"
  local count

  count="$(grep -Ec "\\\$\{\{[[:space:]]*inputs\.${input}[[:space:]]*\}\}" "$action_file" || true)"
  [ "$count" -eq 1 ] ||
    fail "$input must have exactly one expression reference, in the environment mapping"
  grep -Eq "^[[:space:]]*${variable}:[[:space:]]+\\\$\{\{[[:space:]]*inputs\.${input}[[:space:]]*\}\}[[:space:]]*$" "$action_file" ||
    fail "$input is not transported through the $variable environment variable"
}

check_input_transport "bundle-path" "BUNDLE_PATH"
check_input_transport "strict" "STRICT"
check_input_transport "expected-manifest-sha256" "EXPECTED_MANIFEST_SHA256"

if grep -E '^[[:space:]]*run:' "$action_file" | grep -q '\${{'; then
  fail "a run line interpolates an expression"
fi
grep -Eq "^[[:space:]]*run:[[:space:]]*'\"\\\$GITHUB_ACTION_PATH/action-validate.sh\"'[[:space:]]*$" "$action_file" ||
  fail "the action does not run the quoted action-validate.sh entry point"
[ -x "$entrypoint" ] || fail "action-validate.sh is missing or not executable"
grep -Fq -- '-- "$BUNDLE_PATH"' "$entrypoint" ||
  fail "action-validate.sh does not pass BUNDLE_PATH as a quoted argument after --"

run_action() {
  env -u GITHUB_OUTPUT "$@" "$entrypoint"
}

expect_action_status() {
  local expected="$1"
  local actual
  shift

  set +e
  run_action "$@" >/dev/null 2>&1
  actual="$?"
  set -e
  [ "$actual" -eq "$expected" ] ||
    fail "expected exit $expected, got $actual for: $*"
}

mkdir -p "$test_root/path with spaces"
cp -R "$repo_root/skill-provenance" "$test_root/path with spaces/bundle"
bundle="$test_root/path with spaces/bundle"
expect_action_status 0 BUNDLE_PATH="$bundle"

sentinel="$test_root/injected"
adversarial_path="\"; touch $sentinel; #"
set +e
run_action BUNDLE_PATH="$adversarial_path" >/dev/null 2>&1
adversarial_status="$?"
set -e
[ "$adversarial_status" -ne 0 ] || fail "adversarial bundle path unexpectedly validated"
[ ! -e "$sentinel" ] || fail "bundle-path shell payload executed"

# An empty or option-shaped bundle-path must fail. Before the entry point
# passed the path after --, an empty value validated the action's own bundle
# and --help exited zero, so a broken expression produced a green check.
expect_action_status 1 BUNDLE_PATH=""
expect_action_status 1
expect_action_status 2 BUNDLE_PATH="--help"
expect_action_status 2 BUNDLE_PATH="--allow-unlisted"
expect_action_status 2 BUNDLE_PATH="--update"

# strict accepts only true or false and fails a bundle with a null opt-out.
expect_action_status 0 BUNDLE_PATH="$bundle" STRICT=true
expect_action_status 0 BUNDLE_PATH="$bundle" STRICT=false
expect_action_status 1 BUNDLE_PATH="$bundle" STRICT=yes
mkdir "$test_root/nullbundle"
printf 'payload\n' > "$test_root/nullbundle/payload.txt"
printf 'bundle: test\nfiles:\n  - path: payload.txt\n    hash: null\n' > "$test_root/nullbundle/MANIFEST.yaml"
expect_action_status 0 BUNDLE_PATH="$test_root/nullbundle"
expect_action_status 1 BUNDLE_PATH="$test_root/nullbundle" STRICT=true

# expected-manifest-sha256 gates on a digest supplied by the workflow, and
# the checked digest is published as an output.
manifest_hash="$(hash_file "$bundle/MANIFEST.yaml")"
expect_action_status 0 BUNDLE_PATH="$bundle" EXPECTED_MANIFEST_SHA256="$manifest_hash"
expect_action_status 1 BUNDLE_PATH="$bundle" EXPECTED_MANIFEST_SHA256="$(hash_file "$bundle/SKILL.md")"
expect_action_status 1 BUNDLE_PATH="$bundle" EXPECTED_MANIFEST_SHA256="not-a-digest"

output_file="$test_root/github-output"
: > "$output_file"
env GITHUB_OUTPUT="$output_file" BUNDLE_PATH="$bundle" "$entrypoint" >/dev/null
[ "$(cat "$output_file")" = "manifest-sha256=$manifest_hash" ] ||
  fail "manifest-sha256 output is missing or wrong"

echo "Action input transport is shell-safe"
