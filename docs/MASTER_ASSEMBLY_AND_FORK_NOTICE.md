# FILE: docs/MASTER_ASSEMBLY_AND_FORK_NOTICE.md
# Futility’s — MASTER Assembly & Planned Fork Notice (Attached Statement)

This statement explains (1) how the MASTER is assembled today, and (2) the planned fork point where the
Git patcher platform remains stable as its own track while SSOT-seeking work forks off once the platform is proven.

===============================================================================

## 1) Current system state (what exists today)

Today, Futility’s is a Git-based patch compilation and review system.

- The system assembles the authoritative MASTER by:
  1) Accepting change intent as chat/paste ("patch words" or direct instructions).
  2) Converting that intent into a deterministic unified-diff patch.
  3) Uploading the patch to the repo (commit to main).
  4) GitHub Actions applying patches sequentially to `docs/MASTER.md`.
  5) Automatically opening a PR with the resulting updated MASTER.
  6) A human reviewing and merging the PR.

In short:
- The MASTER is not "written by chat."
- The MASTER is "compiled by patch series + PR review."

Operational truth for this stage:
- "Merged PR to docs/MASTER.md" is the only authoritative change mechanism.

===============================================================================

## 2) How the MASTER is assembled (explicit assembly model)

### Inputs
- Untrusted: chat text, notes, "patch words" documents, brainstorms
- Trusted: patch files (`000X-*.patch`) and merged PR diffs

### Assembly pipeline (current)
1) A change request is formulated by a human (and optionally assisted by AI).
2) AI may draft a patch, but only as a proposal.
3) The output is a real unified-diff patch targeting `docs/MASTER.md`.
4) Patches are numbered and applied in deterministic order (0001, 0002, ...).
5) Each successful run results in a PR.
6) Only merged PRs modify the authoritative MASTER.

### Required invariants
- The final MASTER must remain cohesive and non-contradicting.
- Later changes override earlier ones by deleting/replacing superseded text.
- The end-of-document Change Summary and Parts Removed / Superseded log must be maintained.

===============================================================================

## 3) Why this assembly model exists (the platform thesis)

The Git patcher is the minimum stable platform that proves the hardest requirement for SSOT:
deterministic, auditable, review-gated evolution.

This platform is not "the final SSOT."
It is the reliable engine that will enable SSOT without collapsing into:
- contradictions
- untraceable edits
- unverifiable "AI truth"

If the patcher cannot remain stable, SSOT cannot safely be built on it.

===============================================================================

## 4) Planned fork notice (the intentional split)

There is an intentional future fork point:

- Track A: "MASTER Assembler Platform" (Git patcher)
- Track B: "SSOT-Seeking System" (capture/claim/evidence/verification/publish)

The fork exists to prevent mission drift and to keep the patcher platform stable while SSOT capabilities evolve.

### Track A — MASTER Assembler Platform (continues)
Purpose:
- maintain deterministic patch compilation
- maintain PR-based gates and audit trail
- remain stable, boring, dependable

This track must not be destabilized by experimental SSOT logic.

### Track B — SSOT-Seeking System (forks from platform)
Purpose:
- build SSOT features on top of the stable patcher foundation
- introduce record types, evidence, verification workflow, and publication semantics
- remain honest about truth gates and provenance

This track can evolve more aggressively, but must preserve determinism and review.

===============================================================================

## 5) Fork point criteria (when the fork is allowed)

The fork should occur only after Track A is stable by measurable criteria.

Minimum stability criteria for Track A:
- patch workflow runs reliably (no fragile manual steps)
- patches apply deterministically with predictable failure modes
- PR creation is consistent
- master assembly remains cohesive after multiple cycles
- the authorization gate for major changes is enforced
- audit trail and logs are consistently maintained

Only when these are met is the platform considered "stable enough to fork."

===============================================================================

## 6) Current state vs next stages vs fork points (map)

### CURRENT (NOW) — Stage A: Git Patcher Platform
- Goal: reliable patch->PR->merge pipeline
- Output: cohesive MASTER assembled via deterministic patches
- Truth: Git + PR review, not AI judgement

### NEXT (NEAR) — Stage B: Structured Patching Platform
- Goal: PatchOps hybrid (structured ops + diff preview)
- Harden deterministic edit semantics and protected zones
- Still a patch platform, not SSOT

### FORK POINT (WHEN STABLE) — Split into Track A + Track B
- Track A freezes into a stable platform cadence
- Track B begins SSOT-seeking work without destabilizing Track A

### AFTER FORK — Stage C/D/E (SSOT track only)
- Introduce Capture/Claim/Evidence record types
- Add verification workflows + publish gates
- Publish SSOT artifacts backed by evidence and human verification

===============================================================================

## 7) AI behavior rule for the fork notice (non-negotiable)

When a user request tries to push beyond the current patcher platform:

- AI MUST classify it as a "fork-stage" request.
- AI MUST ask for explicit authorization before producing a patch that:
  - expands mission beyond patch compilation
  - introduces SSOT truth/verification semantics as current capabilities
  - changes the platform into "more than the patcher" prematurely

AI may:
- propose SSOT ideas as "Track B design notes"
- propose future-stage sections labeled as future
but must not rewrite the current platform’s mission without authorization.

===============================================================================

END MASTER ASSEMBLY & FORK NOTICE