#!/usr/bin/env bash
set -euo pipefail

die() { echo "ERROR: $*" >&2; exit 1; }
info() { echo "==> $*"; }

# Required patch files (repo root)
PATCHES=(
  "0001-master-v3.1.patch"
  "0002-master-v3.2.patch"
  "0003-master-v3.3.patch"
  "0004-master-v3.4.patch"
)

for p in "${PATCHES[@]}"; do
  [[ -f "$p" ]] || die "Missing patch file: $p (must exist in repo root)"
done

# Master path normalization
MASTER_LOWER="docs/master.md"
MASTER_UPPER="docs/MASTER.md"

if [[ -f "$MASTER_UPPER" ]]; then
  MASTER="$MASTER_UPPER"
elif [[ -f "$MASTER_LOWER" ]]; then
  MASTER="$MASTER_LOWER"
else
  die "Master file not found at docs/master.md or docs/MASTER.md"
fi

# If MASTER already says v3.4, do nothing (prevents infinite re-run PR spam)
if grep -q "MASTER v3\.4" "$MASTER" 2>/dev/null; then
  info "MASTER already appears to be v3.4; nothing to do."
  exit 0
fi

info "Normalizing master filename + END marker"
mkdir -p docs

# Rename to docs/MASTER.md to match patch targets
if [[ "$MASTER" == "$MASTER_LOWER" ]]; then
  git mv "$MASTER_LOWER" "$MASTER_UPPER"
  MASTER="$MASTER_UPPER"
fi

# Fix END MASTER typo(s)
# - your screenshot shows END MASTER xv3, but we normalize any of these:
#   END MASTER xv3 -> END MASTER v3
#   END MASTER x v3 -> END MASTER v3 (just in case)
perl -pi -e 's/END MASTER x?v3/END MASTER v3/g' "$MASTER" || true

# Ensure newline at EOF (helps patch apply)
python3 - <<'PY'
import os
p="docs/MASTER.md"
with open(p,'rb') as f:
    b=f.read()
if not b.endswith(b'\n'):
    with open(p,'ab') as f:
        f.write(b'\n')
PY

# Commit preflight normalization if changed
if ! git diff --quiet; then
  git add "$MASTER"
  git commit -m "Preflight: normalize MASTER path + END marker" || true
fi

info "Checking patches (git apply --check)"
for p in "${PATCHES[@]}"; do
  git apply --check "$p" || die "Patch failed --check: $p (master content mismatch)"
done

info "Applying patches sequentially"
for p in "${PATCHES[@]}"; do
  git apply "$p" || die "Patch failed to apply: $p"
done

# Commit changes
git add "$MASTER"
git commit -m "Fold v3.1-v3.4 canon into MASTER" || die "Nothing to commit after patch apply?"

# Create a branch and push it
BRANCH="auto/apply-master-patches-${GITHUB_RUN_ID:-manual}"
info "Creating branch $BRANCH and pushing"

# If we committed on main (Actions checkout), we need to move commits onto a new branch.
git switch -c "$BRANCH"
git push -u origin "$BRANCH" --force

# Open PR (idempotent: if one already exists, don't die)
info "Creating PR (or leaving if already exists)"
if command -v gh >/dev/null 2>&1; then
  # If a PR already exists for this head branch, gh exits nonzero; we tolerate that.
  set +e
  gh pr create \
    --title "Update MASTER to v3.4 canon (auto)" \
    --body "Automated application of 0001..0004 patches onto docs/MASTER.md." \
    --base "main" \
    --head "$BRANCH"
  set -e
else
  info "gh not available; PR not auto-created."
fi

info "Done."
