NOTE: Later patches supersede earlier text. This document is intended to read as one cohesive plan after all patches are applied.

===============================================================================
FUTILITY'S — CHAT→PATCH→GIT COMPILER (MASTER v3.4)
Purpose: "Smart patching" system that turns chat/paste into audited Git PRs.
Scope: Not truth-finding yet. This is a patch authoring + execution pipeline.
Owner: Gondor
===============================================================================

0) PRIME DIRECTIVES (NON-NEGOTIABLE)
-----------------------------------
D0.1 Single interface: user chats with ONE website bot ("Conductor").
D0.2 LLM chain may decide to execute once intent is explicit and gates pass.
D0.3 System may ask bounded questions to increase confidence (token hygiene).
D0.4 Confirm screen is REQUIRED before creating PR (default).
D0.5 Executor is deterministic code; LLMs never run Git directly.
D0.6 Budgeted escalation: spend compute/tokens only when it is "worth it".
D0.7 Auditability: every attempt produces a trace (even failures).

1) SYSTEM SHAPE (ONE BOT, TWO INPUT MODES)
-----------------------------------------
A) Chat Mode:
  - User: natural language instruction
  - System: asks minimal questions if needed, then proposes patch + executes after confirm

B) PATCHGIT Mode (fast paste envelope):
  - User pastes a structured block; system processes without needing chat
  - Example:

    PATCHGIT v1
    TITLE: ...
    SCOPE: ...
    TARGETS:
    - ...
    ---BEGIN---
    payload
    ---END---

2) DEPLOYMENT TOPOLOGY (DIGITALOCEAN-LED)
-----------------------------------------
Always-on Control Plane (stable, boring, always up):
  - 1x always-on droplet (minimal viable size)
  - Responsibilities:
    * host website UI (chat + PATCHGIT)
    * PIN auth + sessions
    * orchestration (3-stage chain control)
    * job queue + serialization lock
    * audit log + budget manager
    * Git plumbing (clone/pull/branch/commit/push/PR)
  - Holds: DO API token, GitHub token, budget state, config
  - No expectation of running an intelligent LLM locally on the always-on node.

Segregated Sandbox (default safety mechanism):
  - Goal: test/apply without risking the control plane or breaking the whole thing
  - Canon rule: any change that could plausibly break the patching system MUST be executed in a segregated sandbox first.
  - Sandbox model: isolated fresh clone / working dir; runs git apply + format/checks; only after sandbox success does the system push a branch + open PR.

Helper Worker (single extra, on-demand; ephemeral):
  - The system may scale up to ONE additional helper droplet for general processing.
  - Helper constraints:
    * at most 1 helper at a time (no swarm by default)
    * size target: 2–4GB (choose smallest that meets task requirements)
    * helper is ephemeral: created → used → destroyed
  - Helper is used for:
    * medium reasoning (bigger model via local inference if available)
    * formatting/linting/tests
    * repo-wide operations that exceed safe base-load capacity
    * sandbox apply if base-load sandbox would be too tight

Escalation beyond single helper (requires confirmation):
  - If the system believes it needs:
    * more than 1 helper, OR
    * a larger helper tier than policy allows, OR
    * external API calls,
    THEN it must request explicit user confirmation with a cost/benefit summary.

3) PIPELINE OVERVIEW (3 STAGES + EXECUTOR)
------------------------------------------
(all behind the Conductor)

Intake
  |
  v
Stage 1: INTERPRET (Plan + Draft)
  |
  v
Stage 2: GATE (Goal compliance + risk + confidence)
  |
  v
Stage 3: FIT (Repo/environment reality + execution plan)
  |
  v
CONFIRM SCREEN (required)
  |
  v
EXECUTOR (deterministic Git compiler) -> Branch -> Commit -> PR -> (optional merge later)

4) STAGE CONTRACTS (SWARM-READY INTERFACES)
-------------------------------------------
Each stage may be implemented by:
  - 1 model, OR
  - swarm (N models) + reducer
But MUST output one canonical artifact.

Stage 1 Output: PatchProposal
  - title, scope
  - explicit targets list (files)
  - PatchOps summary (structured JSON operations; validated)
  - human-facing DiffPreview (unified diff; from sandbox apply when non-trivial)
  - patch payload (markdown/code)
  - questions_needed (<=3)
  - self-declared risk flags

Stage 2 Output: GateVerdict
  - PASS/FAIL
  - confidence level C0..C3 (+ C4 optional later)
  - reasons + required_changes
  - escalation recommendation (none / medium / swarm / api)

Stage 3 Output: ExecutionRequest
  - final targets + final payload
  - checks_to_run (format/lint/tests as configured)
  - branch name / commit message / PR title/body
  - expected files changed
  - rollback note
  - lane selection (control plane vs burst worker vs swarm vs api)


Panel Review (roles) — required output contract (v3.3):
  - Preserves the philosopher / architect / security / coach pattern as "Panel Review".
  - Panel Review runs in Lane 1 by default, and may be re-run in Lane 2/3 if escalated.
  - Each role outputs a bounded memo:
    * intent_interpretation (1–2 sentences)
    * risks (max 3 bullets)
    * recommended_plan (max 5 bullets)
    * one_best_question (optional; max 1)
    * confidence_0_100
    * blocker (yes/no)
  - Reducer outputs exactly ONE:
    * ExecutionRequest
    * NeedsClarification (<=3 multiple-choice questions)
    * Blocked package (what is missing + why it matters + cheapest unblock)
  - No debate loops. No multi-round back-and-forth between roles.


5) CONFIDENCE LEVELS
--------------------
C0 Draft: intent unclear -> ask questions; do not execute
C1 Plan: intent understood; plan produced; no repo mutation
C2 Apply: likely to apply cleanly; may sandbox apply on burst worker
C3 Ship: sandbox apply succeeded (if required) + checks passed -> ready for PR
C4 Auto-merge (optional later): only for safe change classes; not enabled by default

6) QUESTION DISCIPLINE (TOKEN HYGIENE)
--------------------------------------
Rules:
  - ask only if answer changes diff materially or reduces risk meaningfully
  - max 3 questions per cycle
  - prefer multiple choice
  - if still ambiguous after 3: stop at C0 and ask user to restate

7) BUDGET MANAGER (v3.1 CANON)
------------------------------
Replace vague “worth it” with a required scorecard.

For any paid escalation (Lane 1/2/3/4), compute:

WorthItScore = (ExpectedGain * RiskWeight) / EstimatedCost

Where:
  - ExpectedGain: predicted confidence improvement (e.g., C1->C3 > C1->C2)
  - RiskWeight: higher for protected zones, many files, core pipeline, auth/CI changes
  - EstimatedCost: projected dollars for the lane action (include spin-up minimums)

Rules:
  - If WorthItScore < threshold: do NOT escalate; ask better questions or reduce scope.
  - Threshold increases as remaining daily budget decreases.
  - Lane 3 and Lane 4 ALWAYS require explicit user approval regardless of score.

Budget caps (v3.3 canon):
  - Daily hard cap: $5/day total.
  - Split into lane-category sub-caps (default):
    * Local Burst (Lane 1–2): $3.00/day
    * Runpod (Lane 3):        $1.50/day
    * External API (Lane 4):  $0.50/day

Hard rules:
  - The system must not exceed any sub-cap without explicit approval on the confirm screen.
  - Any single job projected to exceed remaining cap requires explicit approval.
  - If approval not granted: system must propose a cheaper alternative.

Audit requirement:
  - The audit log must record estimated vs actual spend per lane.

8) COMPUTE LADDER (v3.1 CANON)
------------------------------
Lane 0: ALWAYS-ON CONTROL PLANE (1GB, boring, deterministic)
  - No expectation of running an intelligent LLM locally.
  - Responsibilities:
    * UI (Chat + PATCHGIT)
    * auth + sessions (PIN)
    * queue + serialization lock
    * audit log + budget manager
    * repo metadata scan / file targeting preflight
    * generates bounded clarifying questions (NO LLM REQUIRED)
  - Allowed actions:
    * read-only repo inspection
    * prepare candidate plans
    * NEVER spins paid compute unless “worth-it” gates pass

Lane 1: SINGLE HELPER BURST (default “real work”)
  - Recommended size: 2–4GB (choose smallest that meets task needs)
  - Purpose:
    * sandbox apply (fresh clone / isolated working dir)
    * formatting / lint / tests (deterministic checks)
    * Panel Review memos + reducer (architect/security/philosopher/coach)
    * compile ops -> canonical executable patch artifact (e.g., unified diff)
  - Outcome target: reach C2 (Apply) or C3 (Ship-ready PR)

Lane 2: STRONGER LOCAL BURST (try harder before GPU/API)
  - Recommended topology: 2×8GB ephemeral helpers
  - Trigger when (any true):
    * Lane 1 still < C2 after one pass
    * multiple plausible plans exist and choice is risky
    * apply/check failures need non-trivial repair
    * protected-zone changes are explicitly requested and require deeper critique
  - Constraints:
    * one Lane 2 attempt per job (no loops)
    * produce reduced single canonical artifact (ExecutionRequest or Blocked package)

Lane 3: RUNPOD GPU BURST (worth-it gated; requires approval)
  - Purpose:
    * deep reasoning / long-context synthesis / heavy transforms
    * run “big local model” inference using GPU resources
    * resolve complex patch repair cases that Lane 2 cannot fix safely
  - Hard rule:
    * Lane 3 MUST NOT run automatically.
    * Lane 3 requires an explicit “Approve Runpod spend” toggle on the confirm screen.
  - Trigger gate (ALL must be true):
    * Lane 1 attempted (unless change_class is trivial DOC_ONLY)
    * Lane 2 attempted OR explicitly skipped with a written reason
    * system can name the blockage precisely (specific missing reasoning/tool capability)
    * system predicts Runpod materially improves confidence OR reduces risk
    * estimated cost fits remaining budget OR user approves extra spend
  - Required outputs:
    * must address Panel Review memos explicitly
    * must output exactly ONE of:
      - ExecutionRequest (ready)
      - NeedsClarification (<=3 multiple-choice questions)
      - Blocked package (what is missing + why it matters + cheapest unblock)

Lane 4: EXTERNAL MODEL API (last resort; requires approval)
  - Trigger ONLY when ALL are true:
    1. Lane 3 was attempted and still blocked OR Lane 3 is unavailable
    2. system states WHY uncertainty remains (specific missing reasoning)
    3. system predicts API materially improves the outcome vs Lane 3
    4. user approves “Approve API spend” on confirm screen
  - API is used to resolve ambiguity / improve plan, NOT to bypass gates.

GO / confirm semantics:
  - GO publishes only by creating a PR (default). Auto-merge remains later opt-in.

9) CONFIRM SCREEN (REQUIRED BEFORE PR)
--------------------------------------
Confirm screen is REQUIRED before creating a PR.

Must show (v3.4):
  - intent summary
  - explicit targets list
  - PatchOps summary (operations + affected paths)
  - DiffPreview (collapsed + expandable; from sandbox apply whenever non-trivial)
  - confidence level (C0..C3) + reasons
  - WorthItScore summary (inputs + threshold result)
  - spend summary (estimated vs actual where available) + remaining budget (daily + sub-caps)
  - approval toggles for any paid escalation (Runpod/API, etc.)

Approval toggles:
  - “Approve Runpod spend” (only shown if Lane 3 recommended)
  - “Approve API spend” (only shown if Lane 4 recommended)

Hard rule:
  - Without the relevant approval toggle enabled, the system MUST downgrade:
    * ask questions
    * reduce scope
    * use cheaper lane
    * or stop at Draft (C0/C1)

Buttons:
  - GO: proceed to execute (create branch, commit, push, open PR)
  - REVISE: return to Stage 1 with feedback
  - CANCEL: stop; nothing published

10) EXECUTOR (DETERMINISTIC PATCH COMPILER)
-------------------------------------------
Given ExecutionRequest:
  - acquire lock (one job at a time)
  - pull latest main
  - allocate next patch number NNN
  - write patches/NNN-*.md (raw intake + final payload + metadata)
  - append HISTORY.md
  - apply file edits (create/append/replace/modify)
  - create branch -> commit changes -> push branch
  - create PR via GitHub CLI (gh) as the primary mechanism

Failure handling:
  - abort safely; do not partially publish
  - record full logs + reason in audit

Patch representation — Hybrid Canon (v3.4):
  - The system MUST maintain TWO representations of every proposed change:
    (1) Executor-facing: PatchOps (structured JSON operations)
      * canonical input to the deterministic executor
      * MUST be fully validated before execution
    (2) Human-facing: DiffPreview (unified diff)
      * shown on the Confirm Screen
      * produced from sandbox apply whenever non-trivial
  - LLMs MAY propose PatchOps.
  - The deterministic system MUST validate PatchOps and generate DiffPreview via sandbox apply.
  - The executor MUST NOT accept freeform “edit this paragraph” instructions directly.

PatchOps — Deterministic Edit Semantics (v3.4):
  v1 REQUIRED operations (minimum viable, safe):
    1. CREATE_FILE(path, content)
    2. REPLACE_FILE(path, content)
    3. APPEND_FILE(path, content)
    4. REPLACE_BLOCK(path, block_id, content)  (marker-bounded replacement)

  v1 NOT ALLOWED by default:
    - fuzzy “modify” (semantic edits without strict boundaries)
    - “search and replace” without strict context bounds
    - arbitrary regex replace
    - AST-based code transforms

  REPLACE_BLOCK semantics (canon):
    - Files MAY contain explicit markers defining editable regions:
      <!-- FUTILITYS:BEGIN <block_id> -->
      ...existing content...
      <!-- FUTILITYS:END <block_id> -->
    - REPLACE_BLOCK replaces ONLY the content between the markers for <block_id>.
    - If markers are missing, the operation MUST FAIL safely and return a Blocked package
      OR request clarification (<=3 questions), never guessing.

Auditability — required trace items for Lane 3 (v3.3):
  - why Lane 3 was recommended (blockage + expected gain)
  - cost estimate + actual spend
  - panel memos + reducer output
  - final canonical artifact (ExecutionRequest / NeedsClarification / Blocked)
  - explicit record of user approval toggle state

11) SAFETY / "WON'T BREAK THE SYSTEM"
-------------------------------------
Even if targets are "any", the system protects itself via:
  - protected zones (require explicit user intent + higher confidence):
    * patch executor code
    * auth config/secrets
    * automation workflows
  - never commit secrets / tokens / private keys
  - never rewrite history
  - no direct push to main (PR only)
  - size bounds per patch (avoid accidental megadumps)
  - job serialization lock (prevents race/push conflicts)


12) STORAGE MODEL (SQLITE + ARTIFACTS) (v3.4 CANON)
---------------------------------------------------
Canon decision:
  - SQLite is the default job metadata store for v1.
  - “Artifacts” (patch bundles, logs, diff previews, attachments) are stored as files,
    referenced by SQLite.

SQLite stores:
  - job_id, timestamps, user/session id
  - stage outputs (PatchProposal / GateVerdict / ExecutionRequest)
  - confidence level (C0..C3)
  - lane used (0..4) + WorthItScore + budget deltas
  - repo refs (repo url, base branch, commit hashes)
  - execution status + error reasons
  - artifact references (paths or object keys)

Artifacts store (choose per deployment; both supported):
  Option A — Droplet disk (simplest):
    - Store artifacts under /var/lib/futilitys/artifacts/<job_id>/
    - Pros: zero extra services, simplest for MVP
    - Cons: durability depends on backups/snapshots

  Option B — Object storage (recommended for durable audit history):
    - Store artifacts in object storage (e.g., DigitalOcean Spaces) and reference object keys
    - Pros: durable, scalable for long-term audit retention
    - Cons: small monthly base cost

Recommended MVP default:
  - SQLite + droplet disk artifacts
  - Enable object storage when audit retention needs grow

Baseline cost notes (informational):
  - Always-on control plane + SQLite on droplet + artifacts on droplet disk (or object storage)
  - Burst compute (Lane 1/2), Runpod (Lane 3), and External API (Lane 4) remain governed by
    budget caps + WorthItScore + confirm toggles (v3.3).


13) FUTURE PLUGINS (NOT REQUIRED NOW)
-------------------------------------
- Swarm expansion at any stage: N agents → reducer → canonical output
- Runpod escalation for hard reasoning (after Lane 3 if enabled)
- Auto-merge for safe change classes (C4) — later, off by default


===============================================================================
CHANGE SUMMARY (AUTOGENERATED BY PATCH SERIES)
- v3.1: Reorganized MASTER into a single coherent structure; clarified no capable LLM is expected on the always-on node; folded in v3.1 compute ladder concepts.
- v3.2: Added segregated sandbox as default safety mechanism; defined single helper worker default; added GO semantics with explicit approval for extra spend beyond one helper.
- v3.3: Updated escalation ladder: Lane 3 = Runpod GPU burst (worth-it gated) and Lane 4 = external API (last resort); replaced vague worth-it with WorthItScore scorecard; replaced earlier budget cap with $5/day cap + lane sub-caps; formalized Panel Review role memos + reducer output contract; added required audit trace items for Lane 3.
- v3.4: Canonized Hybrid Patch representation (PatchOps JSON + DiffPreview unified diff); locked deterministic edit semantics (no fuzzy modify; marker-bounded REPLACE_BLOCK); standardized PR creation via GitHub CLI (gh); specified SQLite job metadata + artifacts storage model (droplet disk vs object storage); amended confirm screen to display PatchOps summary + DiffPreview + spend and approval toggles.
===============================================================================

PARTS REMOVED / SUPERSEDED (LOG)
- Superseded: freeform paragraph-edit semantics. Executor accepts only validated PatchOps operations; REPLACE_BLOCK requires explicit markers (v3.4).
- Superseded: any PR creation path that bypasses deterministic executor control. LLMs never run git or gh directly; executor uses gh CLI as the standard PR mechanism (v3.4).
===============================================================================

END MASTER v3.4
