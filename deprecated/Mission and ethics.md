# FILE: docs/MISSION_AND_ETHICS.md
# Futility’s — Mission & Ethics (Golden Rules)

This document states the philosophy, ethics, and non-negotiable pillars required for Futility’s to remain functional.
If these rules are violated, the system will drift, contradict itself, or become unsafe/unreviewable.

===============================================================================

## 1) Mission (why this exists)

Futility’s exists to turn messy human intent (chat, paste, notes) into audited, reviewable, deterministic change in Git.

- Conversation is input, not truth.
- The MASTER is the canonical plan.
- Patches are the only way canon evolves.
- Review is sacred.
- Determinism is safety.

Primary outcome:
- A cohesive, human-readable MASTER that can evolve without collapsing into contradiction.

===============================================================================

## 2) The ethics of the system (what we refuse to do)

Futility’s is built around restraint:

- We refuse silent changes.
- We refuse unreviewed publication.
- We refuse “AI authority.”
- We refuse scope creep disguised as “helpfulness.”
- We refuse to hide tradeoffs, risk, or cost.

The system is not here to be clever.
It is here to be correct, auditable, and maintainable.

===============================================================================

## 3) Golden pillars (non-negotiable)

### PILLAR A — Truth is compiled, not spoken
- Chat is untrusted.
- The MASTER is the result of intentional, reviewed compilation.
- If it is not in the MASTER, it is not canon.

### PILLAR B — Determinism over vibes
- The executor is deterministic.
- Changes are expressed as real diffs, applied by tools, not by interpretation.
- If a change cannot be expressed deterministically, it must be redesigned or blocked.

### PILLAR C — Human gate is sacred
- No direct push to main.
- PRs are required.
- The human reviewer is the final authority.
- AI proposes; humans decide.

### PILLAR D — Canon must be cohesive
- Later canon overrides earlier canon.
- Contradictions are not allowed to persist.
- The MASTER must read like one coherent plan, not a pile of historical fragments.

### PILLAR E — Minimal change, maximum clarity
- Each patch should change only what is necessary.
- Avoid broad rewrites unless explicitly authorized.
- Prefer targeted replacements over sweeping “style edits.”

### PILLAR F — Auditability is mandatory
Every attempt must leave a trace:
- patch files are stored
- PR diffs show what changed
- Change Summary / Parts Removed logs are updated
- failures are recorded, not hidden

If something cannot be audited, it is not allowed.

### PILLAR G — Budget and compute discipline
- Escalation must be justified.
- Spending must be explicit.
- “Worth it” must be measured, not assumed.
- No hidden API calls, no silent paid compute.

===============================================================================

## 4) The “do not compromise” rules (hard safety boundaries)

1) Never commit secrets (tokens, passwords, private keys).
2) Never bypass the confirm/review gate.
3) Never rewrite history to hide mistakes.
4) Never allow AI to run git directly.
5) Never blur boundaries between:
   - proposal vs execution
   - draft vs canon
   - opinion vs policy

===============================================================================

## 5) Scope integrity (how we prevent drift)

This system survives by staying honest about scope.

- If a request expands mission/architecture, it is a MAJOR CHANGE.
- Major changes require explicit authorization before patching.
- If a request conflicts with existing canon, the patch must unify and remove superseded text.
- If a request is ambiguous, stop and ask <=3 questions.

The MASTER is not a brainstorming canvas.
It is a compiled spec.

===============================================================================

## 6) The role of AI (assistive, not authoritative)

AI is treated as:
- a draft generator
- a contradiction detector
- a structured editor
- a patch author

AI is NOT:
- the final decision maker
- the publisher
- the security authority
- the source of truth

AI must never present its output as “the system decided.”
Only the human reviewer decides.

===============================================================================

## 7) Operating creed (simple, repeatable)

These are the phrases the system lives by:

- “Conversation is untrusted.”
- “Canon is compiled.”
- “PRs are the gate.”
- “Deterministic execution only.”
- “No secrets in git.”
- “No contradictions in master.”
- “Spend is explicit.”
- “Auditability or it didn’t happen.”

===============================================================================

## 8) Failure philosophy (how we handle mistakes)

Mistakes are normal. Hidden mistakes are fatal.

When something fails:
- record it
- explain it
- patch it
- keep the trail

The system must prefer:
- safe failure over unsafe success
- asking questions over guessing
- blocked status over silent drift

===============================================================================

## 9) Commitment (what the maintainer agrees to)

By using Futility’s, the maintainer agrees:

- to review PRs before merging
- to keep changes small and intentional
- to require authorization for major shifts
- to treat audit logs as sacred
- to protect trust boundaries and secrets

If this commitment is not acceptable, the system will degrade.

===============================================================================

END MISSION & ETHICS