#!/usr/bin/env bash
set -euo pipefail

# Futility’s — MASTER patch applier
# Applies 0001..0004 sequentially after normalizing docs/master.md -> docs/MASTER.md
# and fixing END MASTER xv3 -> END MASTER v3.

die() { echo "ERROR: $*" >&2; exit 1; }
info() { echo "==> $*"; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

need_cmd git
need_cmd grep
need_cmd tail

# Ensure we are in a git repo
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "Not inside a git repository."

# Ensure patch files exist
PATCHES=(
  "0001-master-v3.1.patch"
  "0002-master-v3.2.patch"
  "0003-master-v3.3.patch"
  "0004-master-v3.4.patch"
)

for p in "${PATCHES[@]}"; do
  [[ -f "$p" ]] || die "Missing patch file: $p (expected in repo root)"
done

# Detect master file path (your repo currently shows docs/master.md)
MASTER_LOWER="docs/master.md"
MASTER_UPPER="docs/MASTER.md"

if [[ -f "$MASTER_UPPER" ]]; then
  MASTER="$MASTER_UPPER"
elif [[ -f "$MASTER_LOWER" ]]; then
  MASTER="$MASTER_LOWER"
else
  die "Could not find master file at docs/master.md or docs/MASTER.md"
fi

# Create a new branch so nothing happens on main directly
BRANCH="apply-master-patches-$(date +%Y%m%d-%H%M%S)"
info "Creating branch: $BRANCH"
git switch -c "$BRANCH" >/dev/null 2>&1 || die "Failed to create/switch branch."

# Make sure working tree is clean enough (allow untracked, but no modifications)
if ! git diff --quiet || ! git diff --cached --quiet; then
  die "Working tree has uncommitted changes. Commit or stash before running."
fi

# Normalize file name to docs/MASTER.md if needed
if [[ "$MASTER" == "$MASTER_LOWER" ]]; then
  info "Renaming docs/master.md -> docs/MASTER.md"
  git mv "$MASTER_LOWER" "$MASTER_UPPER"
  MASTER="$MASTER_UPPER"
fi

# Fix END MASTER marker typo if present
info "Normalizing END MASTER marker if needed"
# Use perl if available; otherwise sed
if command -v perl >/dev/null 2>&1; then
  perl -pi -e 's/END MASTER xv3/END MASTER v3/g' "$MASTER"
else
  # macOS/Linux sed compatibility: try GNU then BSD style
  sed -i 's/END MASTER xv3/END MASTER v3/g' "$MASTER" 2>/dev/null || \
  sed -i '' 's/END MASTER xv3/END MASTER v3/g' "$MASTER"
fi

# Ensure newline at EOF
info "Ensuring newline at end-of-file"
last_byte="$(tail -c 1 "$MASTER" | od -An -t u1 | tr -d ' ')"
if [[ "$last_byte" != "10" ]]; then
  printf '\n' >> "$MASTER"
fi

# Commit preflight normalization (so failures later are easy to revert)
info "Committing preflight normalization"
git add "$MASTER"
if git diff --cached --quiet; then
  info "No preflight changes to commit."
else
  git commit -m "Preflight: normalize master filename + END MASTER marker" >/dev/null
fi

# Check each patch applies cleanly
info "Checking patches with git apply --check"
for p in "${PATCHES[@]}"; do
  info "Check: $p"
  git apply --check "$p" || die "Patch failed --check: $p. Your master content likely diverges from expected context."
done

# Apply patches sequentially
info "Applying patches"
for p in "${PATCHES[@]}"; do
  info "Apply: $p"
  git apply "$p" || die "Patch failed to apply: $p"
done

# Commit patched master
info "Committing patched master"
git add "$MASTER"
git commit -m "Fold v3.1-v3.4 canon patches into MASTER" >/dev/null

# Push branch
info "Pushing branch to origin: $BRANCH"
git push -u origin "$BRANCH"

info "DONE."
info "Next: open a PR on GitHub from branch '$BRANCH' into 'main'."

# Optional: open PR automatically if gh is available & authenticated
if command -v gh >/dev/null 2>&1; then
  info "gh detected. Attempting to create PR (if authenticated)..."
  set +e
  gh pr create --title "Update MASTER to v3.4 canon" \
    --body "Applied 0001..0004 patches to fold v3.1-v3.4 canon into docs/MASTER.md." \
    --base main --head "$BRANCH"
  set -e
  info "If PR creation failed, run: gh auth login (then re-run the gh pr create command)."
fi
