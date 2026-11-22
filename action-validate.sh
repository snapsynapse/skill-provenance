#!/usr/bin/env bash
# Entry point for the Skill Provenance composite action.
#
# Inputs arrive only through environment variables set in action.yml, never
# through expression interpolation inside a shell command. The bundle path is
# passed after `--`, so an empty or option-shaped value fails instead of
# selecting some other directory or changing validator behavior.
#
# Environment:
#   BUNDLE_PATH               Directory containing MANIFEST.yaml (required)
#   STRICT                    "true" to fail on hash: null opt-outs
#   EXPECTED_MANIFEST_SHA256  Optional manifest digest obtained out of band
#   GITHUB_OUTPUT             Set by the runner; receives manifest-sha256

set -euo pipefail

export LC_ALL=C
export LANG=C

ACTION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALIDATOR="$ACTION_DIR/skill-provenance/validate.sh"
BUNDLE_PATH="${BUNDLE_PATH-}"
STRICT="${STRICT-false}"
EXPECTED_MANIFEST_SHA256="${EXPECTED_MANIFEST_SHA256-}"

declare -a validator_args=()

case "$STRICT" in
  true)
    validator_args+=(--strict)
    ;;
  false|"")
    ;;
  *)
    echo "ERROR: strict must be true or false"
    exit 1
    ;;
esac

if [ -n "$EXPECTED_MANIFEST_SHA256" ]; then
  validator_args+=("--expect-manifest-sha256=$EXPECTED_MANIFEST_SHA256")
fi

if [ -z "$BUNDLE_PATH" ]; then
  echo "ERROR: bundle-path is empty"
  exit 1
fi

set +e
output="$("$VALIDATOR" ${validator_args[@]+"${validator_args[@]}"} -- "$BUNDLE_PATH")"
status="$?"
set -e

printf '%s\n' "$output"

# Publish the digest of the manifest that was checked. A later job or a
# required reviewer can compare it with a value recorded outside the bundle.
manifest_sha256="$(
  printf '%s\n' "$output" |
    awk '/^Manifest sha256:[a-f0-9]+$/ { sub(/^Manifest sha256:/, ""); digest = $0 } END { print digest }'
)"
if [ -n "${GITHUB_OUTPUT-}" ] && [[ "$manifest_sha256" =~ ^[a-f0-9]{64}$ ]]; then
  printf 'manifest-sha256=%s\n' "$manifest_sha256" >> "$GITHUB_OUTPUT"
fi

exit "$status"
