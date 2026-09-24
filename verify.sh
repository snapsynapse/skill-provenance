#!/usr/bin/env bash
# Standalone entrypoint for Skill Provenance verification.
# It delegates all manifest parsing to the canonical validate.sh after
# verifying that validator against the pinned SHA-256 below.

set -euo pipefail

export LC_ALL=C
export LANG=C

VALIDATOR_SHA256="aaeac06ba392fd9d2283ec24a8e490d924df3f5f2cd9cd2f85604ff9a5063497"
VALIDATOR_SOURCE_URL="https://raw.githubusercontent.com/snapsynapse/skill-provenance/main/skill-provenance/validate.sh"
TARGET_DIR="."
DOWNLOADED_VALIDATOR=""

usage() {
  printf '%s\n' \
    "Usage: ./verify.sh [path/to/skill-bundle]" \
    "" \
    "Downloads the canonical Skill Provenance validator when it is not" \
    "available beside this script, verifies its pinned SHA-256, and then" \
    "runs it against the target bundle. The target defaults to the current" \
    "directory."
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

case "$#" in
  0)
    ;;
  1)
    case "$1" in
      --help|-h)
        usage
        exit 0
        ;;
      *)
        TARGET_DIR="$1"
        ;;
    esac
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac

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
  curl -fsSL "$VALIDATOR_SOURCE_URL" -o "$DOWNLOADED_VALIDATOR"
  ACTUAL_SHA256="$(sha256_hash "$DOWNLOADED_VALIDATOR")"
  if [ "$ACTUAL_SHA256" != "$VALIDATOR_SHA256" ]; then
    fail "downloaded validator hash mismatch (expected $VALIDATOR_SHA256, actual $ACTUAL_SHA256)"
  fi
  VALIDATOR="$DOWNLOADED_VALIDATOR"
fi

bash "$VALIDATOR" "$TARGET_DIR"
