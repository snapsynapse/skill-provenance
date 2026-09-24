#!/usr/bin/env bash
# validate.sh — Verify or update bundle hashes against MANIFEST.yaml
# Zero dependencies beyond bash, shasum or sha256sum, and awk.
#
# Usage:
#   ./validate.sh [path/to/bundle]          Verify hashes (default)
#   ./validate.sh --update [path/to/bundle] Recompute and write hashes
#   ./validate.sh --allow-unlisted [...]    Report unlisted files without failing
#   ./validate.sh --help                    Show usage
#
#   If no path given, uses the directory containing this script.
#   MANIFEST.yaml is treated as the control file and is not self-hashed.
#   The files inventory uses a constrained line-oriented grammar: `files:` at
#   column 1, `  - path: <unquoted-relative-path>`, and `    hash: <value>`.
#   General YAML path syntax, absolute or non-normalized paths, duplicate paths,
#   and manifest-listed symlinks fail closed.
#
#   Every other entry beneath the bundle root must be listed. Unlisted files,
#   symlinks, and special files are reported as UNLISTED and fail the run
#   unless --allow-unlisted is given. Only the root MANIFEST.yaml is exempt.
#   Unlisted symlinks are reported but never followed. Update mode never adds
#   unlisted files to the manifest.
#
#   If the manifest carries an optional validated_against block, a summary
#   is reported after the hash results. Attestation is informational only:
#   it never changes the exit code. Integrity gates, attestation informs.
#
# Exit codes:
#   0 = all files present and hashes match (verify) or updated (update)
#   1 = mismatches, missing files, or unlisted files found
#   2 = MANIFEST.yaml not found

export LC_ALL=C
export LANG=C

set -euo pipefail

MODE="verify"
ALLOW_UNLISTED=0
BUNDLE_DIR=""
UPDATES_FILE=""
TEMP_MANIFEST=""
LISTED_FILE=""
WALKED_FILE=""

usage() {
  cat <<'EOF'
Usage:
  ./validate.sh [path/to/bundle]          Verify hashes (default)
  ./validate.sh --update [path/to/bundle] Recompute and write hashes
  ./validate.sh --allow-unlisted [...]    Report unlisted files without failing
  ./validate.sh --help                    Show usage
EOF
}

cleanup() {
  if [ -n "$UPDATES_FILE" ] && [ -f "$UPDATES_FILE" ]; then
    rm -f "$UPDATES_FILE"
  fi
  if [ -n "$TEMP_MANIFEST" ] && [ -f "$TEMP_MANIFEST" ]; then
    rm -f "$TEMP_MANIFEST"
  fi
  if [ -n "$LISTED_FILE" ] && [ -f "$LISTED_FILE" ]; then
    rm -f "$LISTED_FILE"
  fi
  if [ -n "$WALKED_FILE" ] && [ -f "$WALKED_FILE" ]; then
    rm -f "$WALKED_FILE"
  fi
}

trap cleanup EXIT

# Parse arguments
for arg in "$@"; do
  case "$arg" in
    --update)
      MODE="update"
      ;;
    --allow-unlisted)
      ALLOW_UNLISTED=1
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      if [ -z "$BUNDLE_DIR" ]; then
        BUNDLE_DIR="$arg"
      else
        echo "ERROR: unexpected argument: $arg"
        usage
        exit 1
      fi
      ;;
  esac
done

BUNDLE_DIR="${BUNDLE_DIR:-$(cd "$(dirname "$0")" && pwd)}"
MANIFEST="$BUNDLE_DIR/MANIFEST.yaml"

# Detect available SHA-256 command (macOS uses shasum, Linux uses sha256sum)
if command -v shasum >/dev/null 2>&1; then
  sha256_hash() { shasum -a 256 "$1" | awk '{print $1}'; }
elif command -v sha256sum >/dev/null 2>&1; then
  sha256_hash() { sha256sum "$1" | awk '{print $1}'; }
else
  echo "ERROR: neither shasum nor sha256sum found"
  exit 1
fi

if [ ! -f "$MANIFEST" ]; then
  echo "ERROR: MANIFEST.yaml not found in $BUNDLE_DIR"
  exit 2
fi

errors=0
checked=0
skipped=0
updated=0
unlisted=0
manifest_errors=0

if [ "$MODE" = "update" ]; then
  UPDATES_FILE=$(mktemp "${TMPDIR:-/tmp}/skill-provenance-updates.XXXXXX")
  TEMP_MANIFEST=$(mktemp "${TMPDIR:-/tmp}/skill-provenance-manifest.XXXXXX")
fi

# Collect all path/hash pairs from MANIFEST.yaml
declare -a paths=()
declare -a expected_hashes=()
declare -a hash_states=()
declare -a path_states=()
current_path=""
current_hash=""
current_hash_state="missing"
current_hash_count=0
current_path_state="valid"
in_files=0
files_section_count=0
file_entry_count=0

classify_path() {
  local candidate="$1"

  case "$candidate" in
    ""|" "*|*" "|*'#'*|\"*|\'*|\&*|\**|\!*|\|*|\>*|\[*|\{*|\%*|\@*|\`*)
      echo "unsupported"
      return
      ;;
    /*|.|./*|*/.|*/./*|..|../*|*/..|*/../*|*//*|*/|*\\*)
      echo "unsafe"
      return
      ;;
  esac

  if [[ "$candidate" == *$'\t'* ]] || [[ "$candidate" == *$'\r'* ]]; then
    echo "unsupported"
    return
  fi

  echo "valid"
}

path_has_symlink_component() {
  local candidate="$1"
  local component=""
  local current="$BUNDLE_DIR"
  local old_ifs="$IFS"
  declare -a components=()

  IFS='/' read -r -a components <<< "$candidate"
  IFS="$old_ifs"
  for component in "${components[@]}"; do
    current="$current/$component"
    if [ -L "$current" ]; then
      return 0
    fi
  done
  return 1
}

append_current_entry() {
  if [ -z "$current_path" ]; then
    return
  fi
  paths+=("$current_path")
  expected_hashes+=("$current_hash")
  path_states+=("$current_path_state")
  file_entry_count=$((file_entry_count + 1))
  if [ "$current_hash_count" -gt 1 ]; then
    hash_states+=("duplicate")
  else
    hash_states+=("$current_hash_state")
  fi
}

while IFS= read -r line; do
  if [ "$line" = "files:" ]; then
    append_current_entry
    current_path=""
    in_files=1
    files_section_count=$((files_section_count + 1))
    if [ "$files_section_count" -gt 1 ]; then
      echo "INVALID  manifest (duplicate files section)"
      manifest_errors=$((manifest_errors + 1))
    fi
    continue
  fi

  if [ "$in_files" -eq 1 ] &&
     [[ "$line" =~ ^[^[:space:]#] ]] &&
     ! [[ "$line" =~ ^[[:space:]]*-[[:space:]]*path: ]] &&
     ! [[ "$line" =~ ^[[:space:]]*hash: ]]; then
    append_current_entry
    current_path=""
    in_files=0
  fi

  if [ "$in_files" -eq 1 ] && [[ "$line" =~ ^\ \ -\ path:\ (.+)$ ]]; then
    append_current_entry
    current_path="${BASH_REMATCH[1]}"
    current_hash=""
    current_hash_state="missing"
    current_hash_count=0
    current_path_state="$(classify_path "$current_path")"

    for ((existing_i = 0; existing_i < ${#paths[@]}; existing_i++)); do
      existing_path="${paths[$existing_i]}"
      if [ "$existing_path" = "$current_path" ]; then
        current_path_state="duplicate"
        break
      fi
    done
  elif [ "$in_files" -eq 1 ] && [[ "$line" =~ ^[[:space:]]*-[[:space:]]*path: ]]; then
    append_current_entry
    echo "INVALID  manifest (file path entries must use exactly: two spaces, '- path: ', then an unquoted path)"
    manifest_errors=$((manifest_errors + 1))
    current_path=""
  elif [ -n "$current_path" ] && [[ "$line" =~ ^\ \ \ \ hash:\ (.*)$ ]]; then
    current_hash_count=$((current_hash_count + 1))
    hash_value="${BASH_REMATCH[1]}"
    if [ "$hash_value" = "null" ]; then
      current_hash=""
      current_hash_state="null"
    elif [[ "$hash_value" =~ ^sha256:([a-f0-9]{64})$ ]]; then
      current_hash="${BASH_REMATCH[1]}"
      current_hash_state="valid"
    else
      current_hash=""
      current_hash_state="malformed"
    fi
  elif [ -n "$current_path" ] && [[ "$line" =~ ^[[:space:]]*hash: ]]; then
    echo "INVALID  $current_path (hash fields must use exactly four spaces, 'hash: ', then a value)"
    manifest_errors=$((manifest_errors + 1))
    current_hash_state="malformed"
  fi
done < "$MANIFEST"
# Last entry
append_current_entry

if [ "$files_section_count" -eq 0 ]; then
  echo "INVALID  manifest (missing files section)"
  manifest_errors=$((manifest_errors + 1))
elif [ "$file_entry_count" -eq 0 ]; then
  echo "INVALID  manifest (files section has no valid path entries)"
  manifest_errors=$((manifest_errors + 1))
fi

# Process each file
for ((i = 0; i < ${#paths[@]}; i++)); do
  path="${paths[$i]}"
  expected="${expected_hashes[$i]}"
  hash_state="${hash_states[$i]}"
  path_state="${path_states[$i]}"

  case "$path_state" in
    unsafe)
      echo "INVALID  $path (path must be normalized and relative, without '.', '..', empty, trailing-slash, or backslash components)"
      errors=$((errors + 1))
      continue
      ;;
    unsupported)
      echo "INVALID  $path (unsupported path scalar; use an unquoted path without comments or surrounding whitespace)"
      errors=$((errors + 1))
      continue
      ;;
    duplicate)
      echo "INVALID  $path (duplicate path entry in manifest)"
      errors=$((errors + 1))
      continue
      ;;
  esac

  filepath="$BUNDLE_DIR/$path"

  if path_has_symlink_component "$path"; then
    echo "INVALID  $path (manifest paths may not contain symlink components)"
    errors=$((errors + 1))
    checked=$((checked + 1))
    continue
  fi

  if [ ! -f "$filepath" ]; then
    echo "MISSING  $path"
    errors=$((errors + 1))
    checked=$((checked + 1))
    continue
  fi

  if [ "$hash_state" = "duplicate" ]; then
    echo "INVALID  $path (multiple hash fields in manifest)"
    errors=$((errors + 1))
    continue
  fi

  if [ "$hash_state" = "null" ]; then
    echo "SKIP     $path (hash explicitly set to null)"
    skipped=$((skipped + 1))
    continue
  fi

  actual=$(sha256_hash "$filepath")

  if [ "$MODE" = "update" ]; then
    if [ "$hash_state" != "valid" ] || [ "$actual" != "$expected" ]; then
      printf '%s\t%s\n' "$path" "$actual" >> "$UPDATES_FILE"
      if [ "$hash_state" = "valid" ]; then
        echo "UPDATED  $path"
      else
        echo "REPAIRED $path ($hash_state hash)"
      fi
      updated=$((updated + 1))
    else
      echo "OK       $path"
    fi
  else
    if [ "$hash_state" != "valid" ]; then
      echo "INVALID  $path ($hash_state hash; use hash: null for an intentional opt-out)"
      errors=$((errors + 1))
    elif [ "$actual" = "$expected" ]; then
      echo "OK       $path"
    else
      echo "MISMATCH $path"
      echo "  expected: $expected"
      echo "  actual:   $actual"
      errors=$((errors + 1))
    fi
  fi
  checked=$((checked + 1))
done

# Every entry beneath the bundle root must be listed in the files inventory,
# so the manifest proves what is absent as well as what is present. The walk
# uses bash globbing only, stays Bash 3.2 compatible, records symlinks without
# following them, and fails closed on a directory it cannot enumerate rather
# than silently skipping its contents.
declare -a walked_kinds=()
declare -a walked_paths=()
walk_errors=0

walk_bundle_dir() {
  local rel="$1"
  local dir="$BUNDLE_DIR"
  local entry=""
  local name=""
  local child=""
  local -a entries=()

  if [ -n "$rel" ]; then
    dir="$BUNDLE_DIR/$rel"
  fi
  if [ ! -r "$dir" ] || [ ! -x "$dir" ]; then
    echo "INVALID  ${rel:-bundle root} (directory cannot be enumerated for unlisted files)"
    walk_errors=$((walk_errors + 1))
    return
  fi

  entries=("$dir"/*)
  for entry in ${entries[@]+"${entries[@]}"}; do
    name="${entry##*/}"
    child="${rel:+$rel/}$name"
    if [ -z "$rel" ] && [ "$name" = "MANIFEST.yaml" ]; then
      continue
    fi
    if [ -L "$entry" ]; then
      walked_kinds+=("symlink")
      walked_paths+=("$child")
    elif [ -d "$entry" ]; then
      walk_bundle_dir "$child"
    elif [ -f "$entry" ]; then
      walked_kinds+=("file")
      walked_paths+=("$child")
    else
      walked_kinds+=("special")
      walked_paths+=("$child")
    fi
  done
}

report_unlisted() {
  local kind="$1"
  local path="$2"
  local shown="$path"

  # Escape control characters so a crafted filename cannot forge report lines.
  if [[ "$path" == *[[:cntrl:]]* ]]; then
    shown="$(printf '%q' "$path")"
  fi
  case "$kind" in
    symlink)
      echo "UNLISTED $shown (symlink, not followed)"
      ;;
    special)
      echo "UNLISTED $shown (not a regular file, not read)"
      ;;
    *)
      echo "UNLISTED $shown"
      ;;
  esac
  unlisted=$((unlisted + 1))
}

shopt_state="$(shopt -p dotglob nullglob || true)"
shopt -s dotglob nullglob
walk_bundle_dir ""
eval "$shopt_state"

LISTED_FILE=$(mktemp "${TMPDIR:-/tmp}/skill-provenance-listed.XXXXXX")
WALKED_FILE=$(mktemp "${TMPDIR:-/tmp}/skill-provenance-walked.XXXXXX")
for ((i = 0; i < ${#paths[@]}; i++)); do
  printf '%s\n' "${paths[$i]}" >> "$LISTED_FILE"
done
for ((i = 0; i < ${#walked_paths[@]}; i++)); do
  # Manifest paths are read line by line, so a name containing a newline can
  # never be listed. Report it directly instead of passing it to awk.
  if [[ "${walked_paths[$i]}" == *$'\n'* ]]; then
    report_unlisted "${walked_kinds[$i]}" "${walked_paths[$i]}"
  else
    printf '%s\t%s\n' "${walked_kinds[$i]}" "${walked_paths[$i]}" >> "$WALKED_FILE"
  fi
done

if ! unlisted_entries="$(awk '
    FILENAME == ARGV[1] { listed[$0] = 1; next }
    {
      split_at = index($0, "\t")
      if (!(substr($0, split_at + 1) in listed)) print
    }
  ' "$LISTED_FILE" "$WALKED_FILE")"; then
  echo "INVALID  bundle root (unlisted-file comparison failed)"
  walk_errors=$((walk_errors + 1))
  unlisted_entries=""
fi

while IFS= read -r entry_line; do
  [ -n "$entry_line" ] || continue
  report_unlisted "${entry_line%%$'\t'*}" "${entry_line#*$'\t'}"
done <<< "$unlisted_entries"

errors=$((errors + walk_errors))
if [ "$ALLOW_UNLISTED" -eq 0 ]; then
  errors=$((errors + unlisted))
fi

errors=$((errors + manifest_errors))

if [ "$MODE" = "update" ] && [ "$updated" -gt 0 ] && [ "$errors" -eq 0 ]; then
  awk -v updates_file="$UPDATES_FILE" '
    BEGIN {
      while ((getline line < updates_file) > 0) {
        split(line, fields, "\t")
        replacements[fields[1]] = fields[2]
      }
      close(updates_file)
      current_path = ""
      replaced = 0
      in_files = 0
    }
    function flush_missing_hash() {
      if (current_path != "" &&
          (current_path in replacements) &&
          !replaced) {
        print "    hash: sha256:" replacements[current_path]
      }
    }
    {
      line = $0
      if (line == "files:") {
        in_files = 1
        print line
        next
      }
      if (in_files && line ~ /^[^[:space:]#]/) {
        flush_missing_hash()
        current_path = ""
        replaced = 0
        in_files = 0
      }
      if (in_files && line ~ /^  - path: /) {
        flush_missing_hash()
        current_path = line
        sub(/^  - path: /, "", current_path)
        replaced = 0
      }
      if (in_files && current_path != "" &&
          (current_path in replacements) &&
          line ~ /^    hash: /) {
        line = "    hash: sha256:" replacements[current_path]
        replaced = 1
      }
      print line
    }
    END {
      flush_missing_hash()
    }
  ' "$MANIFEST" > "$TEMP_MANIFEST"
  mv "$TEMP_MANIFEST" "$MANIFEST"
  TEMP_MANIFEST=""
fi

# Report optional validated_against attestation entries. Informational only:
# nothing here touches $errors or the exit code. Integrity gates, attestation
# informs — a stale or absent attestation is a signal to re-validate, not a
# reason to fail the pin.
report_attestation() {
  awk '
    !in_va && /^bundle_version:/ {
      current = $0
      sub(/^bundle_version:[[:space:]]*/, "", current)
      sub(/[[:space:]]*(#.*)?$/, "", current)
    }
    /^validated_against:/ { in_va = 1; next }
    in_va && /^[A-Za-z_]/ { in_va = 0 }
    in_va && /^[[:space:]]*-[[:space:]]*/ {
      n++
      if ($0 ~ /^[[:space:]]*-[[:space:]]*bundle_version:/) {
        ver[n] = $0
        sub(/^[[:space:]]*-[[:space:]]*bundle_version:[[:space:]]*/, "", ver[n])
        sub(/[[:space:]]*(#.*)?$/, "", ver[n])
      } else {
        invalid_start[n] = 1
      }
      next
    }
    in_va && n > 0 && /^[[:space:]]*(harness|model|date|result):[[:space:]]*/ {
      key = $0
      sub(/^[[:space:]]*/, "", key)
      val = key
      sub(/:.*$/, "", key)
      sub(/^[A-Za-z_]*:[[:space:]]*/, "", val)
      sub(/[[:space:]]*$/, "", val)
      field[n, key] = val
      next
    }
    END {
      if (n == 0) exit 0
      print ""
      matched = 0
      for (i = 1; i <= n; i++) {
        bad = ""
        if (invalid_start[i] || ver[i] == "") bad = bad " bundle_version"
        if (field[i, "harness"] == "") bad = bad " harness"
        if (field[i, "result"] != "pass" &&
            field[i, "result"] != "partial" &&
            field[i, "result"] != "fail") bad = bad " result"
        if (field[i, "date"] !~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/) bad = bad " date"
        if (bad != "") {
          invalid[i] = 1
          print "ATTEST   malformed record " i " (invalid or missing:" bad ")"
        }
      }
      for (i = 1; i <= n; i++) {
        if (!invalid[i] && ver[i] == current) {
          matched++
          line = "ATTEST   bundle " ver[i] " validated against: " field[i, "harness"]
          if (field[i, "model"] != "") line = line " / " field[i, "model"]
          if (field[i, "result"] != "") line = line " (" field[i, "result"]
          if (field[i, "date"] != "") line = line ", " field[i, "date"]
          if (field[i, "result"] != "") line = line ")"
          print line
        }
      }
      if (matched == 0) {
        last = ver[n]
        if (last == "") last = "unknown"
        print "ATTEST   stale: no valid validated_against entry for bundle " current " (last recorded: " last ")"
      }
      print "         attestation is informational; it never gates integrity"
    }
  ' "$MANIFEST"
}

report_attestation

echo ""
if [ "$MODE" = "update" ]; then
  echo "Checked $checked files, skipped $skipped, unlisted $unlisted, updated $updated"
  if [ "$errors" -gt 0 ]; then
    echo "Errors: $errors"
    exit 1
  fi
  if [ "$updated" -gt 0 ]; then
    echo "MANIFEST.yaml updated."
  else
    echo "All hashes already current."
  fi
else
  echo "Checked $checked files, skipped $skipped, unlisted $unlisted, errors $errors"
  if [ "$errors" -gt 0 ]; then
    if [ "$unlisted" -gt 0 ] && [ "$ALLOW_UNLISTED" -eq 0 ]; then
      echo "Unlisted entries fail verification; list them in MANIFEST.yaml or remove them."
    fi
    exit 1
  fi
  if [ "$skipped" -gt 0 ]; then
    echo "All pinned hashes verified; $skipped explicit hash opt-out(s) were not hashed."
  else
    echo "All hashes verified."
  fi
  if [ "$unlisted" -gt 0 ]; then
    echo "WARNING: $unlisted unlisted entr(ies) allowed by --allow-unlisted were not verified."
  fi
fi
