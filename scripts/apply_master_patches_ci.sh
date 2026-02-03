#!/usr/bin/env bash
set -euo pipefail

die() { echo "ERROR: $*" >&2; exit 1; }
info() { echo "==> $*"; }

# Canonical master path normalization
MASTER_LOWER="docs/master.md"
MASTER_UPPER="docs/MASTER.md"

# Ledger of what patch number has been applied (kept in-repo so CI knows)
LEDGER_DIR=".futilitys"
LEDGER_FILE="${LEDGER_DIR}/patch_ledger.txt"

# Discover patches dynamically in repo root: 0001-*.patch, 0002-*.patch, ...
# (Your rule: as long as a patch name number is greater than the patch before, it should work.)
mapfile -t ALL_PATCHES < <(ls -1 [0-9][0-9][0-9][0-9]-*.patch 2>/dev/null | sort || true)

if [[ ${#ALL_PATCHES[@]} -eq 0 ]]; then
  info "No patches found matching ####-*.patch in repo root. Nothing to do."
  exit 0
fi

# Normalize MASTER filename
if [[ -f "$MASTER_UPPER" ]]; then
  MASTER="$MASTER_UPPER"
elif [[ -f "$MASTER_LOWER" ]]; then
  info "Renaming ${MASTER_LOWER} -> ${MASTER_UPPER} for canonical path"
  mkdir -p docs
  git mv -f "$MASTER_LOWER" "$MASTER_UPPER" || mv -f "$MASTER_LOWER" "$MASTER_UPPER"
  MASTER="$MASTER_UPPER"
else
  die "Could not find ${MASTER_LOWER} or ${MASTER_UPPER}. Create docs/MASTER.md first."
fi

# Read last-applied patch number from ledger.
# If ledger doesn't exist, bootstrap:
# - If your MASTER is already at v3.4 AND a 0004 patch exists, assume 0004 already applied (your stated current state).
# - Otherwise start at 0000.
LAST_APPLIED="0000"
if [[ -f "$LEDGER_FILE" ]]; then
  LAST_APPLIED="$(head -n 1 "$LEDGER_FILE" | tr -d '\r' | sed 's/[^0-9].*$//')"
  [[ "$LAST_APPLIED" =~ ^[0-9]{4}$ ]] || die "Ledger file ${LEDGER_FILE} is invalid. Expected a 4-digit number on line 1."
else
  if grep -q "END MASTER v3\.4" "$MASTER" && ls -1 0004-*.patch >/dev/null 2>&1; then
    LAST_APPLIED="0004"
  fi
fi

info "Last applied patch number: ${LAST_APPLIED}"

# Filter patches strictly greater than LAST_APPLIED (numeric compare)
last_num=$((10#$LAST_APPLIED))
TO_APPLY=()
for p in "${ALL_PATCHES[@]}"; do
  n="${p:0:4}"
  [[ "$n" =~ ^[0-9]{4}$ ]] || continue
  num=$((10#$n))
  if (( num > last_num )); then
    TO_APPLY+=("$p")
  fi
done

if [[ ${#TO_APPLY[@]} -eq 0 ]]; then
  info "No new patches > ${LAST_APPLIED}. Nothing to do."
  exit 0
fi

info "Patches to apply (in order):"
printf '  - %s\n' "${TO_APPLY[@]}"

# Apply sequentially with CRLF-safe sanitation
SANITIZED_DIR="$(mktemp -d)"
trap 'rm -rf "$SANITIZED_DIR"' EXIT

highest_applied="$LAST_APPLIED"

for p in "${TO_APPLY[@]}"; do
  bn="$(basename "$p")"
  n="${bn:0:4}"

  # sanitize CRLF -> LF (git apply fails on CRLF diffs sometimes)
  sp="${SANITIZED_DIR}/${bn}"
  sed 's/\r$//' "$p" > "$sp"

  info "Check: ${bn}"
  git apply --check "$sp" || die "git apply --check failed for ${bn} (context mismatch or invalid diff)."

  info "Apply: ${bn}"
  git apply "$sp" || die "git apply failed for ${bn}"

  highest_applied="$n"
done

# Update ledger so future runs only apply higher-numbered patches
mkdir -p "$LEDGER_DIR"
echo "$highest_applied" > "$LEDGER_FILE"

info "Updated ledger: ${LEDGER_FILE} = ${highest_applied}"
info "Done."
