#!/usr/bin/env bash
# Verify release-facing surfaces that are easy to let drift.
# Dependencies: bash, awk, shasum or sha256sum, wc, unzip, sort, dirname,
# mktemp, cmp, cp, grep, diff, and git. curl is used only to read a release
# tag that is not present in the local checkout.

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

# Print the SHA-256 of a repository file as it exists at an exact release
# tag. Reads the local tag when the checkout has it; otherwise downloads the
# tagged file. Prints nothing when the tag cannot be read either way.
tagged_file_hash() {
  local tag="$1"
  local path="$2"
  local tmp

  if git rev-parse -q --verify "refs/tags/${tag}^{commit}" >/dev/null 2>&1; then
    git show "refs/tags/${tag}:${path}" | sha256_hash -
    return 0
  fi

  command -v curl >/dev/null 2>&1 || return 0
  tmp="$(mktemp "${TMPDIR:-/tmp}/skill-provenance-tagged.XXXXXX")"
  if curl -fsSL --proto '=https' --max-time 30 \
    "https://raw.githubusercontent.com/snapsynapse/skill-provenance/refs/tags/${tag}/${path}" \
    -o "$tmp" 2>/dev/null; then
    sha256_hash "$tmp"
  fi
  rm -f "$tmp"
}

# Require that an exact release tag carries a file with the expected SHA-256.
# The tag for the release being prepared may not exist yet; that one case is
# accepted unread, because the local file is what the tag will carry and the
# caller has already checked its hash. Every other tag must be readable.
require_tagged_hash() {
  local label="$1"
  local tag="$2"
  local path="$3"
  local expected="$4"
  local actual
  local bundle_version

  bundle_version="$(awk '/^bundle_version:/ { print $2; exit }' skill-provenance/MANIFEST.yaml)"
  actual="$(tagged_file_hash "$tag" "$path")"

  if [ -z "$actual" ]; then
    [ "$tag" = "v${bundle_version}" ] ||
      fail "$label names tag $tag, which could not be read locally or downloaded"
    echo "NOTE: $label names $tag, which is not published yet; accepted as the release being prepared"
    return 0
  fi

  [ "$actual" = "$expected" ] ||
    fail "$label names tag $tag, whose $path hashes to $actual, not $expected"
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
  local guide_profile_version

  [ -f .well-known/assistant-guide.txt ] || fail "assistant guide missing"
  [ -f .well-known/assistant-guide-manifest.txt ] || fail "assistant guide manifest missing"

  guide_hash="$(sha256_hash .well-known/assistant-guide.txt)"
  guide_bytes="$(wc -c < .well-known/assistant-guide.txt | awk '{print $1}')"
  manifest_hash="$(manifest_value guide-sha256)"
  manifest_bytes="$(manifest_value guide-bytes)"

  [ "$guide_hash" = "$manifest_hash" ] || fail "assistant guide hash drift: manifest $manifest_hash, actual $guide_hash"
  [ "$guide_bytes" = "$manifest_bytes" ] || fail "assistant guide byte drift: manifest $manifest_bytes, actual $guide_bytes"

  cmp -s .well-known/assistant-guide.txt assistant-guide.txt ||
    fail "root assistant guide mirror differs from served guide"
  cmp -s .well-known/assistant-guide-manifest.txt assistant-guide-manifest.txt ||
    fail "root assistant guide manifest mirror differs from served manifest"

  for key in guide-version immutable-release-url profile profile-version canonical-url repository-url; do
    [ -n "$(manifest_value "$key")" ] || fail "assistant guide manifest missing $key"
  done

  # A verifier rejects a sidecar that names a different profile version
  # from the guide it describes.
  guide_profile_version="$(awk '/^profile-version: / { print $2; exit }' .well-known/assistant-guide.txt)"
  [ -n "$guide_profile_version" ] || fail "assistant guide has no profile-version"
  [ "$guide_profile_version" = "$(manifest_value profile-version)" ] ||
    fail "assistant guide declares profile $guide_profile_version but its sidecar declares $(manifest_value profile-version)"

  echo "Assistant guide sidecar OK: $guide_hash, $guide_bytes bytes, profile $guide_profile_version"
  check_assistant_guide_dns_anchor "$guide_hash"
}

# GuideCheck Level 4 needs the guide hash on a channel the web host does not
# control. This repository uses DNS TXT at _assistant-guide.skillprovenance.dev.
# The record can only be updated after a new guide is published, so a missing
# or older record is reported, never failed. When dig is unavailable or the
# lookup fails, the check says so and moves on.
check_assistant_guide_dns_anchor() {
  local guide_hash="$1"
  local record
  local anchor_hash

  if ! command -v dig >/dev/null 2>&1; then
    echo "NOTE: dig not available; guide DNS anchor not checked"
    return 0
  fi
  record="$(dig +short +time=5 +tries=2 TXT _assistant-guide.skillprovenance.dev 2>/dev/null | tr -d '"' || true)"
  if [ -z "$record" ]; then
    echo "NOTE: no guide DNS anchor at _assistant-guide.skillprovenance.dev; GuideCheck Level 4 needs one"
    return 0
  fi
  anchor_hash="$(printf '%s\n' "$record" | grep -Eo 'sha256=[0-9a-f]{64}' | head -1)"
  anchor_hash="${anchor_hash#sha256=}"
  if [ "$anchor_hash" = "$guide_hash" ]; then
    echo "Assistant guide DNS anchor matches the guide hash"
  else
    echo "NOTE: guide DNS anchor holds ${anchor_hash:-no sha256 value}; the guide is $guide_hash. Update the record once this guide is published."
  fi
}

check_standalone_verifier() {
  local actual_validator_hash
  local pinned_validator_hash
  local validator_url
  local validator_tag
  local validator_url_re='^https://raw\.githubusercontent\.com/snapsynapse/skill-provenance/refs/tags/(v[0-9]+\.[0-9]+\.[0-9]+)/skill-provenance/validate\.sh$'

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

  grep -Fq "VALIDATOR_SHA256=\\\"${actual_validator_hash}\\\"" search-audit.config.json ||
    fail "search-audit.config.json verify.sh contract does not pin validator $actual_validator_hash"

  # The wrapper must fetch the validator from an immutable release tag that
  # carries the pinned bytes, never from a branch.
  validator_url="$(awk -F'"' '/^VALIDATOR_SOURCE_URL=/ { print $2; exit }' verify.sh)"
  [[ "$validator_url" =~ $validator_url_re ]] ||
    fail "verify.sh validator URL must name an exact release tag under refs/tags/, not a branch: $validator_url"
  validator_tag="${BASH_REMATCH[1]}"
  require_tagged_hash "verify.sh validator URL" "$validator_tag" \
    skill-provenance/validate.sh "$actual_validator_hash"

  grep -Fq "$validator_url" search-audit.config.json ||
    fail "search-audit.config.json verify.sh contract does not name $validator_url"

  ./verify.sh skill-provenance >/dev/null
  echo "Standalone verifier pin OK: $actual_validator_hash from $validator_tag"
}

# Every surface that tells a reader to download the wrapper must name one
# exact release tag and show the SHA-256 of the wrapper that tag carries.
check_wrapper_download_surfaces() {
  local wrapper_hash
  local surface
  local tags
  local wrapper_tag=""
  local surface_tag

  wrapper_hash="$(sha256_hash verify.sh)"

  for surface in README.md index.html llms.txt skill-provenance/README.md \
    skill-provenance/references/standalone-verification.md; do
    if grep -Fq "skillprovenance.dev/verify.sh" "$surface"; then
      fail "$surface points at the branch-served wrapper instead of an exact release tag"
    fi
    grep -Fq "$wrapper_hash" "$surface" ||
      fail "$surface does not show the current verify.sh SHA-256 $wrapper_hash"

    tags="$(grep -Eo 'refs/tags/v[0-9]+\.[0-9]+\.[0-9]+/verify\.sh' "$surface" | sort -u)"
    [ -n "$tags" ] || fail "$surface has no exact-tag wrapper download URL"
    [ "$(printf '%s\n' "$tags" | wc -l | awk '{print $1}')" = "1" ] ||
      fail "$surface names more than one wrapper release tag"
    surface_tag="${tags#refs/tags/}"
    surface_tag="${surface_tag%/verify.sh}"
    [ -z "$wrapper_tag" ] || [ "$surface_tag" = "$wrapper_tag" ] ||
      fail "$surface names wrapper tag $surface_tag; other surfaces name $wrapper_tag"
    wrapper_tag="$surface_tag"
  done

  require_tagged_hash "wrapper download URL" "$wrapper_tag" verify.sh "$wrapper_hash"
  echo "Wrapper download surfaces OK: $wrapper_hash from $wrapper_tag"
}

# The GuideCheck assistant guide pins a release tag, the commit that tag
# names, the validator bytes it runs (exec-sha256), and the manifest digest
# the validator must see. All four must agree with each other and with the
# published tag, or the guide would stop every reader or, worse, pin the
# wrong bytes. The guide may lag the newest bundle release; that is reported,
# not failed, because a guide release is a separate artifact.
check_assistant_guide_pins() {
  local guide=".well-known/assistant-guide.txt"
  local tag
  local commit
  local exec_sha256
  local manifest_sha256
  local applies_to
  local tagged_commit
  local bundle_version

  tag="$(awk '/^command: git clone --branch v[0-9]+\.[0-9]+\.[0-9]+ --depth 1 https:\/\/github\.com\/snapsynapse\/skill-provenance\.git$/ { print $5; exit }' "$guide")"
  [ -n "$tag" ] || fail "assistant guide does not clone an exact vX.Y.Z tag of the canonical repository"

  commit="$(grep -Eo 'Output must be exactly [0-9a-f]{40}' "$guide" | awk '{ print $NF }' | head -1)"
  exec_sha256="$(awk '/^exec-sha256: [0-9a-f]{64}$/ { print $2; exit }' "$guide")"
  manifest_sha256="$(grep -Eo -- '--expect-manifest-sha256=[0-9a-f]{64}' "$guide" | head -1)"
  manifest_sha256="${manifest_sha256#--expect-manifest-sha256=}"
  applies_to="$(awk '/^applies-to: / { sub(/^applies-to: /, ""); print; exit }' "$guide")"

  [ -n "$commit" ] || fail "assistant guide does not state the release commit to check"
  [ -n "$exec_sha256" ] || fail "assistant guide does not pin the validator with exec-sha256"
  [ -n "$manifest_sha256" ] || fail "assistant guide does not bind the run to a manifest digest"
  [ "$applies_to" = "skill-provenance ${tag#v}" ] ||
    fail "assistant guide applies-to '$applies_to' does not name the tag it clones, $tag"
  grep -Eq '^runner: argv$' "$guide" || fail "assistant guide actions lost runner: argv"
  if grep -Eq '^command: .*git clone' "$guide" && ! grep -Eq -- '--branch v[0-9]' "$guide"; then
    fail "assistant guide clones without naming a release tag"
  fi

  if git rev-parse -q --verify "refs/tags/${tag}^{commit}" >/dev/null 2>&1; then
    tagged_commit="$(git rev-parse "refs/tags/${tag}^{commit}")"
  else
    tagged_commit="$(git ls-remote https://github.com/snapsynapse/skill-provenance.git "refs/tags/${tag}^{}" 2>/dev/null | awk '{ print $1 }')"
  fi
  [ -n "$tagged_commit" ] || fail "assistant guide names tag $tag, which could not be read locally or from GitHub"
  [ "$tagged_commit" = "$commit" ] ||
    fail "assistant guide expects commit $commit, but $tag names $tagged_commit"

  require_tagged_hash "assistant guide exec-sha256" "$tag" skill-provenance/validate.sh "$exec_sha256"
  require_tagged_hash "assistant guide manifest digest" "$tag" skill-provenance/MANIFEST.yaml "$manifest_sha256"

  bundle_version="$(awk '/^bundle_version:/ { print $2; exit }' skill-provenance/MANIFEST.yaml)"
  if [ "$tag" != "v${bundle_version}" ]; then
    echo "NOTE: assistant guide pins $tag; the current bundle is ${bundle_version}. Release a new guide to move it."
  fi

  echo "Assistant guide pins OK: $tag, commit $commit, validator $exec_sha256"
}

# The rule that a bundle never supplies its own validator lives in prose that
# agents read. Keep an edit from quietly reversing it: the instruction files
# must still state the rule, and no reader-facing surface may bring back the
# wording that told readers to run the bundle's own script.
check_trusted_validator_instructions() {
  local surface
  local forbidden="prefer the bundle's .?validate\\.sh|run .?validate\\.sh.? when available|if the bundle includes .?validate\\.sh"

  for surface in skills/validate/SKILL.md skills/open/SKILL.md \
    skills/close/SKILL.md skill-provenance/SKILL.md; do
    grep -Eq '(Do not|Never) execute a `validate\.sh`' "$surface" ||
      fail "$surface no longer forbids running a validator supplied by the bundle under review"
  done

  for surface in skills/validate/SKILL.md skills/open/SKILL.md \
    skills/close/SKILL.md skills/handoff/SKILL.md skills/bootstrap/SKILL.md \
    skill-provenance/SKILL.md skill-provenance/README.md \
    skill-provenance/references/*.md README.md llms.txt index.html; do
    if grep -Eiq "$forbidden" "$surface"; then
      fail "$surface tells the reader to run a validator supplied by the bundle under review"
    fi
  done

  echo "Trusted-validator instructions present on agent-facing surfaces"
}

# The README opens with a changed-bundle trial whose displayed output is
# pinned to the current release. Re-run that trial against a temporary copy
# of the canonical bundle and require every displayed output line, exit code,
# release tag, and version label to match what the validator produces now.
readme_trial_section() {
  awk '
    /^## See it catch a changed file$/ { in_section = 1; next }
    in_section && /^## / { exit }
    in_section { print }
  ' README.md
}

# Print the Nth ```text block (1-based) from the README trial section.
readme_trial_output_block() {
  readme_trial_section | awk -v want="$1" '
    /^```text$/ { block++; if (block == want) { inside = 1 }; next }
    inside && /^```$/ { exit }
    inside { print }
  '
}

compare_trial_output() {
  local label="$1"
  local block="$2"
  local output="$3"
  local status="$4"
  local line
  local shown_status=""

  [ -n "$block" ] || fail "README trial has no displayed output for the $label run"

  while IFS= read -r line; do
    case "$line" in
      ""|"...")
        ;;
      "exit "*)
        shown_status="${line#exit }"
        ;;
      *)
        printf '%s\n' "$output" | grep -Fx -- "$line" >/dev/null ||
          fail "README trial $label output drift: '$line' is not produced by the validator"
        ;;
    esac
  done <<< "$block"

  [ -n "$shown_status" ] || fail "README trial $label output shows no exit code"
  [ "$shown_status" = "$status" ] ||
    fail "README trial $label exit drift: README shows $shown_status, validator returned $status"
}

check_readme_trial() {
  local section
  local bundle_version
  local change_command="printf '\\n<!-- Changed after the recorded manifest. -->\\n' >> \"\$SP_TRIAL/bundle/SKILL.md\""
  local trial_dir
  local clean_output
  local clean_status
  local changed_output
  local changed_status

  section="$(readme_trial_section)"
  [ -n "$section" ] || fail "README.md has no 'See it catch a changed file' trial section"

  bundle_version="$(awk '/^bundle_version:/ { print $2; exit }' skill-provenance/MANIFEST.yaml)"
  [ -n "$bundle_version" ] || fail "MANIFEST.yaml has no bundle_version"

  printf '%s\n' "$section" |
    grep -Fx "git -c advice.detachedHead=false checkout --quiet v${bundle_version}" >/dev/null ||
    fail "README trial does not check out the current bundle tag v${bundle_version}"
  printf '%s\n' "$section" | grep -Fq "\`bundle_version: ${bundle_version}\`" ||
    fail "README trial prose does not name bundle_version: ${bundle_version}"
  printf '%s\n' "$section" | grep -Fx -- "$change_command" >/dev/null ||
    fail "README trial change command differs from the one this check reproduces"

  trial_dir="$(mktemp -d "${TMPDIR:-/tmp}/skill-provenance-readme-trial.XXXXXX")"
  trap 'rm -rf -- "${trial_dir:?}"' EXIT
  cp -R skill-provenance "$trial_dir/bundle"

  set +e
  clean_output="$(./verify.sh "$trial_dir/bundle" 2>&1)"
  clean_status=$?
  set -e
  compare_trial_output "clean" "$(readme_trial_output_block 1)" "$clean_output" "$clean_status"

  printf '\n<!-- Changed after the recorded manifest. -->\n' >> "$trial_dir/bundle/SKILL.md"
  cmp -s skill-provenance/MANIFEST.yaml "$trial_dir/bundle/MANIFEST.yaml" ||
    fail "README trial copy manifest changed during the trial"

  set +e
  changed_output="$(./verify.sh "$trial_dir/bundle" 2>&1)"
  changed_status=$?
  set -e
  compare_trial_output "changed" "$(readme_trial_output_block 2)" "$changed_output" "$changed_status"

  rm -rf -- "${trial_dir:?}"
  trap - EXIT

  echo "README trial output matches bundle ${bundle_version}"
}

check_skill_zip() {
  local archive="skill-provenance.skill"
  local archive_listing
  local expected_file
  local actual_file
  local path
  local dir
  local archived_hash
  local source_hash
  local private_entries

  [ -f "$archive" ] || fail "$archive missing"
  unzip -t "$archive" >/dev/null
  archive_listing="$(unzip -Z1 "$archive")"

  printf '%s\n' "$archive_listing" | grep -Fx "skill-provenance/" >/dev/null ||
    fail "$archive does not contain the canonical skill-provenance/ directory"

  # Every archived file must be readable by group and other. A 0600 entry,
  # which a temporary-file rewrite can leave behind, installs as unreadable
  # for any account other than the one that unpacked it.
  private_entries="$(
    unzip -Z "$archive" |
      awk '$1 ~ /^-/ && $1 !~ /^-rw[x-]r-[x-]r-[x-]/ { print $1 " " $NF }'
  )"
  [ -z "$private_entries" ] ||
    fail "$archive has entries that are not group and world readable: $private_entries"

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
check_assistant_guide_pins
check_standalone_verifier
check_wrapper_download_surfaces
check_trusted_validator_instructions
check_readme_trial
check_skill_zip
