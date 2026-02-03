#!/usr/bin/env bash
set -euo pipefail

die() { echo "ERROR: $*" >&2; exit 1; }
info() { echo "==> $*"; }

PATCHES=(
  "0001-master-v3.1.patch"
  "0002-master-v3.2.patch"
  "0003-master-v3.3.patch"
  "0004-master-v3.4.patch"
)

for p in "${PATCHES[@]}"; do
  [[ -f "$p" ]] || die "Missing patch file in repo root: $p"
done

MASTER_LOWER="docs/master.md"
MASTER_UPPER="docs/MASTER.md"

if [[ -f "$MASTER_UPPER" ]]; then
  MASTER="$MASTER_UPPER"
elif [[ -f "$MASTER_LOWER" ]]; then
  MASTER="$MASTER_LOWER"
else
  die "Master not found at docs/master.md or docs/MASTER.md"
fi

# Stop if already upgraded (prevents PR spam after merge)
if grep -q "MASTER v3\.4" "$MASTER" 2>/dev/null; then
  info "MASTER already contains 'MASTER v3.4' — no changes required."
  exit 0
fi

info "Normalize master filename + END marker"
mkdir -p docs

if [[ "$MASTER" == "$MASTER_LOWER" ]]; then
  git mv "$MASTER_LOWER" "$MASTER_UPPER"
  MASTER="$MASTER_UPPER"
fi

# Fix your observed typo (xv3 -> v3). Also tolerates "x v3" just in case.
perl -pi -e 's/END MASTER x?v3/END MASTER v3/g' "$MASTER" || true

# Ensure newline at EOF
python3 - <<'PY'
p="docs/MASTER.md"
with open(p,'rb') as f:
    b=f.read()
if not b.endswith(b'\n'):
    with open(p,'ab') as f:
        f.write(b'\n')
PY

info "Sanitize patch files (strip any junk before first 'diff --git')"
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

sanitize_patch() {
  local in="$1"
  local out="$2"
  # Keep everything starting from the first "diff --git" line.
  awk 'BEGIN{p=0} /^diff --git /{p=1} {if(p) print}' "$in" > "$out"
  # Validate header exists
  grep -q '^diff --git ' "$out" || return 1
  return 0
}

SANITIZED=()
for p in "${PATCHES[@]}"; do
  out="$TMPDIR/$p"
  if ! sanitize_patch "$p" "$out"; then
    die "Patch '$p' is missing a 'diff --git' header. It is not a valid unified diff as uploaded."
  fi
  SANITIZED+=("$out")
done

info "Apply sanitized patches sequentially (check+apply in order)"
for sp in "${SANITIZED[@]}"; do
  info "Check: $(basename "$sp")"
  git apply --check "$sp" || die "git apply --check failed for $(basename "$sp") (context mismatch after prior patches)"
  info "Apply: $(basename "$sp")"
  git apply "$sp" || die "git apply failed for $(basename "$sp")"
done

info "Done. Changes are in working tree; PR step will commit them."
