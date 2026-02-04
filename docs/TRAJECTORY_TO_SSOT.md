# FILE: docs/TRAJECTORY_TO_SSOT.md
# Futility’s — Trajectory to SSOT (Attached Statement for AI + Maintainers)

This statement describes the intended evolution of Futility’s from the current Git-based patch compiler into a full SSOT system.
It is binding guidance for AI behavior and for human maintainers when interpreting future changes.

===============================================================================

## 1) Current state (what Futility’s is right now)

Futility’s is currently a working concept establishing a rock solid "staging area" with all the services, systems, acoounts, connections, etc etc in order 

...incrementially working towards full scale SSOT system 

"txt/code normalization/formatting" + execution pipeline" whose purpose is to:

- accept messy human input (chat/paste)
- convert it into deterministic patch operations
- produce audited Git pull requests
- keep the MASTER document coherent and reviewable

At this stage:
- Futility’s is NOT a truth engine.
- Futility’s does not decide what is true.
- Futility’s compiles intent into reviewable Git changes.

The MASTER is the authoritative spec for this stage.

===============================================================================

## 2) North star (what SSOT means here)

SSOT means a system that can:

- capture untrusted observations (captures)
- extract explicit claims (structured statements)
- attach evidence links (citations, sources, photos, logs, chat references)
- route claims through human verification gates
- publish verified records as authoritative SSOT artifacts

SSOT is not "AI believes it."
SSOT is "a human-reviewed, evidence-backed record exists and is traceable."

SSOT requires:
- provenance
- audit trail
- versioned changes
- clear gates between untrusted input and published truth

===============================================================================

## 3) The intended evolution (the trajectory)

Futility’s evolves in deliberate stages. Each stage must be stable before moving on.
The Git patch compiler is intentionally the first working prototype because it proves the most important pillar:
deterministic, reviewable, reversible change.

Trajectory stages:

Phase 0 is establishing all that and getting to the point of an empty but configured and ready to go server, and can be accessed via https domain we own. 
phase 1 (functional barebones system concept, early dev phase) setup private login but https dev-skelton to build this mechanism input->process->serve better data. The minimum requirement for success are: website has login credentials, can accept txt and files, does not llm basic syntax/markdown/restructuring then uploading to git and open PR
phase 2 Dev sandbox. esablish a DO droplet or docker with specifially for executing and testing code (once system is stable this will become "staging" area for testing PRs prior to merge)
Phase 3 add bots
phase 4 add real database
phase 5 prove system viability with by establishing a repeatable, tunable system
phase 6 stress test system and identify weaknesses/flaws (do this via bot agents actually entering "mechanic chatter" and observe
phase xyz tbd

### Stage A — Git Patcher (NOW)
- Build a robust Chat → Patch → PR machine.
- Establish deterministic semantics, confirm/review gate, audit trail.
- Treat MASTER as the system’s current authoritative spec.
- Prove the workflow is usable and repeatable.

### Stage B — Structured Patching (NEXT)
- Introduce PatchOps (structured ops) as the executor’s internal truth.
- Generate DiffPreview for humans.
- Harden protected zones, safety checks, and cost/budget discipline.
- Expand the spec without expanding mission beyond patch compilation.

### Stage C — Records & Claims (BRIDGE TO SSOT)
- Introduce explicit record types (Capture, Claim, Evidence, Procedure, Asset).
- Maintain strict gates:
  - Capture is untrusted
  - Claim is a structured assertion derived from capture
  - Evidence is linked support
  - Published SSOT is verified output
- Add tooling that organizes knowledge without pretending to "know truth."

### Stage D — Verification Workflow (SSOT CORE)
- Add a human verification workflow (review queues, acceptance criteria).
- Require evidence citations for published records.
- Make auditability first-class: who verified, why, with what evidence.

### Stage E — SSOT Publication (MATURE)
- Publish verified SSOT artifacts as authoritative operational knowledge.
- Provide safe retrieval and update mechanisms.
- Maintain append-only audit history and patch-based evolution.

In every stage:
- determinism + review gates remain non-negotiable
- the system must remain maintainable and auditable

===============================================================================

## 4) Guardrails during evolution (what AI must never do)

AI must not collapse stages.

AI must never:
- claim SSOT behavior is present when it is not implemented
- treat unverified captures as truth
- bypass human verification gates
- silently expand scope (“helpful additions”) without explicit authorization
- rewrite the system’s mission without an approved major change

AI must always:
- keep the current stage honest
- propose changes as patches
- preserve auditability and deterministic semantics
- ask for authorization before major changes to mission/architecture

===============================================================================

## 5) The main principle (why this trajectory works)

SSOT is only trustworthy if it is built on a proven foundation:
- deterministic execution
- explicit gates
- human review
- traceable evidence

The Git patcher is the first stable foundation block.
Everything SSOT-like must be layered on top only after the patcher is reliable.

===============================================================================

## 6) Practical interpretation rule (for AI)

When a user request mentions SSOT concepts:

- If it is about anything about initial system setup- express it as 
- If it is about FUTURE SSOT: express it as a trajectory-stage proposal, not a current capability.
- If it requires crossing stages (patcher → SSOT workflow): classify as MAJOR CHANGE and request authorization before producing a patch.

===============================================================================

END TRAJECTORY STATEMENT
