#!/usr/bin/env bash
set -euo pipefail

die() { echo "ERROR: $*" >&2; exit 1; }
info() { echo "==> $*"; }

MASTER_LOWER="docs/master.md"
MASTER_UPPER="docs/MASTER.md"

# Find MASTER
if [[ -f "$MASTER_UPPER" ]]; then
  MASTER="$MASTER_UPPER"
elif [[ -f "$MASTER_LOWER" ]]; then
  MASTER="$MASTER_LOWER"
else
  die "Master not found at docs/master.md or docs/MASTER.md"
fi

info "Normalize master filename + END marker"
mkdir -p docs

if [[ "$MASTER" == "$MASTER_LOWER" ]]; then
  git mv "$MASTER_LOWER" "$MASTER_UPPER"
  MASTER="$MASTER_UPPER"
fi

# Fix typo variants (xv3 -> v3) if present
perl -pi -e 's/END MASTER x?v3/END MASTER v3/g' "$MASTER" || true

# Ensure newline at EOF
python3 - <<'PY'
p="docs/MASTER.md"
with open(p,'rb') as f:
    b=f.read()
if b and not b.endswith(b'\n'):
    with open(p,'ab') as f:
        f.write(b'\n')
PY

# Discover patches dynamically in repo root
mapfile -t PATCHES < <(ls -1 [0-9][0-9][0-9][0-9]-*.patch 2>/dev/null | sort || true)

if [[ ${#PATCHES[@]} -eq 0 ]]; then
  info "No patch files found matching ####-*.patch in repo root — nothing to do."
  exit 0
fi

info "Sanitize patch files (strip any junk before first 'diff --git')"
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

sanitize_patch() {
  local in="$1"
  local out="$2"
  awk 'BEGIN{p=0} /^diff --git /{p=1} {if(p) print}' "$in" > "$out"
  grep -q '^diff --git ' "$out" || return 1
  return 0
}

info "Apply patches in ascending order; skip ones already applied"
for p in "${PATCHES[@]}"; do
  bn="$(basename "$p")"
  sp="$TMPDIR/$bn"

  if ! sanitize_patch "$p" "$sp"; then
    die "Patch '$bn' is missing a 'diff --git' header. Not a valid unified diff."
  fi

  info "Check: $bn"
  if git apply --check "$sp" >/dev/null 2>&1; then
    info "Apply: $bn"
    git apply "$sp" || die "git apply failed for $bn"
    continue
  fi

  # If reverse-check passes, it means the patch is already in the file(s); skip it.
  if git apply --reverse --check "$sp" >/dev/null 2>&1; then
    info "Skip (already applied): $bn"
    continue
  fi

  die "Patch '$bn' does not apply cleanly and is not already applied (context mismatch)."
done

info "Done. If any changes were made, the PR step will commit them."
