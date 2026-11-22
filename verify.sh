#!/usr/bin/env bash
# Standalone entrypoint for Skill Provenance verification.
# It delegates all manifest parsing to the canonical validate.sh after
# verifying that validator against the pinned SHA-256 below.
# The download URL names the immutable release tag that carries those exact
# validator bytes, never a branch, so a published wrapper keeps working after
# later releases change the validator.

set -euo pipefail

export LC_ALL=C
export LANG=C

VALIDATOR_SHA256="8d03a6899490b886312d6170813e91d2fe3f0bb703acb45baa4cbc25edd66142"
VALIDATOR_SOURCE_URL="https://raw.githubusercontent.com/snapsynapse/skill-provenance/refs/tags/v7.1.0/skill-provenance/validate.sh"
TARGET_DIR="."
TARGET_SET=0
END_OF_OPTIONS=0
DOWNLOADED_VALIDATOR=""
declare -a VALIDATOR_ARGS=()

usage() {
  printf '%s\n' \
    "Usage: ./verify.sh [--strict] [--expect-manifest-sha256=HEX] [--] [path/to/skill-bundle]" \
    "" \
    "Downloads the canonical Skill Provenance validator when it is not" \
    "available beside this script, verifies its pinned SHA-256, and then" \
    "runs it against the target bundle. The target defaults to the current" \
    "directory." \
    "" \
    "  --strict                         Fail on hash: null opt-outs. Use it for" \
    "                                   a bundle someone else published." \
    "  --expect-manifest-sha256=HEX     Fail unless MANIFEST.yaml has this digest," \
    "                                   obtained outside the bundle."
}

cleanup() {
  if [ -n "$DOWNLOADED_VALIDATOR" ] && [ -f "$DOWNLOADED_VALIDATOR" ]; then
    rm -f "$DOWNLOADED_VALIDATOR"
  fi
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

sha256_hash() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    fail "neither shasum nor sha256sum found"
  fi
}

# Only verification options are passed through. The wrapper never updates a
# manifest and never relaxes the inventory check.
for arg in "$@"; do
  if [ "$END_OF_OPTIONS" -eq 0 ]; then
    case "$arg" in
      --)
        END_OF_OPTIONS=1
        continue
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      --strict|--expect-manifest-sha256=*)
        VALIDATOR_ARGS+=("$arg")
        continue
        ;;
      -*)
        usage >&2
        exit 1
        ;;
    esac
  fi
  if [ "$TARGET_SET" -eq 1 ]; then
    usage >&2
    exit 1
  fi
  TARGET_DIR="$arg"
  TARGET_SET=1
done

trap cleanup EXIT

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOCAL_VALIDATOR="$SCRIPT_DIR/skill-provenance/validate.sh"

if [ -f "$LOCAL_VALIDATOR" ]; then
  ACTUAL_SHA256="$(sha256_hash "$LOCAL_VALIDATOR")"
  if [ "$ACTUAL_SHA256" != "$VALIDATOR_SHA256" ]; then
    fail "local validator hash mismatch (expected $VALIDATOR_SHA256, actual $ACTUAL_SHA256)"
  fi
  VALIDATOR="$LOCAL_VALIDATOR"
else
  command -v curl >/dev/null 2>&1 || fail "curl is required when the canonical validator is not available locally"
  DOWNLOADED_VALIDATOR="$(mktemp "${TMPDIR:-/tmp}/skill-provenance-validator.XXXXXX")"
  # HTTPS only, including redirects, with time and size limits so a hostile
  # or broken endpoint cannot hang the run or fill the disk before the digest
  # check rejects what it sent.
  curl -fsSL --proto '=https' --proto-redir '=https' --tlsv1.2 \
    --max-time 60 --max-filesize 1048576 \
    "$VALIDATOR_SOURCE_URL" -o "$DOWNLOADED_VALIDATOR"
  ACTUAL_SHA256="$(sha256_hash "$DOWNLOADED_VALIDATOR")"
  if [ "$ACTUAL_SHA256" != "$VALIDATOR_SHA256" ]; then
    fail "downloaded validator hash mismatch (expected $VALIDATOR_SHA256, actual $ACTUAL_SHA256)"
  fi
  VALIDATOR="$DOWNLOADED_VALIDATOR"
fi

bash "$VALIDATOR" ${VALIDATOR_ARGS[@]+"${VALIDATOR_ARGS[@]}"} -- "$TARGET_DIR"
