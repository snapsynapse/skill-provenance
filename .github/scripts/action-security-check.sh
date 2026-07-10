#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
action_file="$repo_root/action.yml"
test_root="$(mktemp -d "${TMPDIR:-/tmp}/skill-provenance-action-test.XXXXXX")"
trap 'rm -rf "$test_root"' EXIT

input_reference_count="$(grep -Ec '\$\{\{[[:space:]]*inputs\.bundle-path[[:space:]]*\}\}' "$action_file" || true)"
if [[ "$input_reference_count" -ne 1 ]]; then
  echo "FAIL: bundle-path must have exactly one expression reference, in the environment mapping" >&2
  exit 1
fi

if ! grep -Eq '^[[:space:]]*BUNDLE_PATH:[[:space:]]+\$\{\{[[:space:]]*inputs\.bundle-path[[:space:]]*\}\}[[:space:]]*$' "$action_file"; then
  echo "FAIL: bundle-path is not transported through the BUNDLE_PATH environment variable" >&2
  exit 1
fi

if ! grep -Eq '^[[:space:]]*run:.*"\$BUNDLE_PATH"' "$action_file"; then
  echo "FAIL: the validation command does not pass BUNDLE_PATH as a quoted argument" >&2
  exit 1
fi

mkdir -p "$test_root/path with spaces"
cp -R "$repo_root/skill-provenance" "$test_root/path with spaces/bundle"
env GITHUB_ACTION_PATH="$repo_root" \
  BUNDLE_PATH="$test_root/path with spaces/bundle" \
  bash -c '"$GITHUB_ACTION_PATH/skill-provenance/validate.sh" "$BUNDLE_PATH"' >/dev/null

sentinel="$test_root/injected"
adversarial_path="\"; touch $sentinel; #"
if env GITHUB_ACTION_PATH="$repo_root" \
  BUNDLE_PATH="$adversarial_path" \
  bash -c '"$GITHUB_ACTION_PATH/skill-provenance/validate.sh" "$BUNDLE_PATH"' >/dev/null 2>&1; then
  echo "FAIL: adversarial bundle path unexpectedly validated" >&2
  exit 1
fi
if [ -e "$sentinel" ]; then
  echo "FAIL: bundle-path shell payload executed" >&2
  exit 1
fi

echo "Action input transport is shell-safe"
