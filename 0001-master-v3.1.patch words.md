

COMPUTE LADDER (v3.1 CANON)

---------------------------

Always-on control plane:

  - 1x 1GB droplet hosts UI + orchestrator + queue + audit + git plumbing

  - No expectation of running a capable LLM locally on 1GB

  - Intelligence is normally offloaded to burst workers

  

Burst execution lanes:

  Lane 1 (medium single worker): spin up 2–8GB droplet for "real reasoning",

    sandbox apply, formatting, and repo checks, then destroy.

  Lane 2 (swarm workers): if still uncertain, spin up either:

    - 4×4GB (more parallel critique/votes) OR

    - 2×8GB (stronger per-agent capability)

    chosen by the orchestrator's cost/perf heuristic for the task.

  Lane 3 (API last resort): call external model API only if:

    - local chain remains uncertain AND

    - it can name the uncertainty AND

    - it predicts the API call will materially improve confidence AND

    - daily budget permits.

  

Confirm semantics:

  - Default: CONFIRM creates a PR only (no auto-merge).

  - Auto-merge is a later optional feature limited to safe change classes.

Daily budget:

  - $2/day total spend cap across burst minutes + API tokens.

  

  

===============================================================================

MASTER v3.2 — COMPUTE + SANDBOX + BUDGET + GO SEMANTICS (CANON)

===============================================================================

  

A) ALWAYS-ON CONTROL PLANE (BASE LOAD)

--------------------------------------

- 1x always-on droplet (size: minimal viable; no expectation of running an

  intelligent LLM locally)

- Responsibilities:

    * host website UI (chat + PATCHGIT)

    * PIN auth + sessions

    * orchestration (3-stage chain control)

    * job queue + serialization lock

    * audit log + budget manager

    * git plumbing (clone/pull/branch/commit/push/PR)

- The always-on node MUST remain stable and boring.

  

B) SEGREGATED SANDBOX (DEFAULT SAFETY MECHANISM)

-----------------------------------------------

Goal: test/apply without risking the control plane or "breaking the whole thing".

  

Canon rule:

- Any change that could plausibly break the patching system MUST be executed

  in a segregated sandbox environment first.

  

Implementation model (conceptual):

- The sandbox is logically isolated from the control plane's runtime.

- The sandbox runs git apply/format/checks against a fresh clone/working dir.

- Only after sandbox success does the system push a branch + open PR.

  

C) HELPER WORKER (SINGLE EXTRA, ON-DEMAND)

------------------------------------------

The system may scale up to ONE additional helper droplet for general processing.

  

Helper constraints:

- At most 1 helper at a time (no swarm by default).

- Helper size target: 2–4GB (choose smallest that meets task requirements).

- Helper is ephemeral: created → used → destroyed.

  

Helper is used for:

- medium reasoning (bigger model via local inference if available)

- formatting/linting/tests

- repo-wide operations that exceed safe base-load capacity

- sandbox apply if base-load sandbox would be too tight

  

D) ESCALATION BEYOND SINGLE HELPER (REQUIRES CONFIRMATION)

----------------------------------------------------------

If the system believes it needs:

- more than 1 helper, OR

- a larger helper tier than policy allows, OR

- external API calls,

THEN it must request explicit user confirmation with a cost/benefit summary.

  

E) BUDGET MANAGER (HARD CAPS)

-----------------------------

Budgets are enforced at two levels:

1) Hourly cap

2) Daily cap

  

Tracked spend categories:

- helper droplet runtime minutes

- optional external API token spend

  

Hard rule:

- The system MUST NOT exceed hourly or daily budgets without explicit user

  confirmation on the confirm screen.

  

F) "GO" SEMANTICS (CONFIRM SCREEN)

----------------------------------

Default workflow:

- The system prepares a Proposed Execution (plan + targets + diff preview

  + risk + confidence + projected cost).

- User sees confirm screen with a primary button:

      GO = proceed to execute (create branch, commit, push, open PR)

  

Important:

- GO publishes only by creating a PR (default).

- Auto-merge is not enabled by default and remains a later opt-in feature.

  

G) CONFIRMATION FOR EXTRA SPEND

-------------------------------

If projected cost exceeds remaining hourly/daily budget OR requires escalation

beyond 1 helper / calls external API:

- The confirm screen must show:

    * WHY escalation is needed

    * what it will cost (estimate)

    * what confidence gain is expected

    * an explicit "Approve extra spend" toggle

- Without that approval, the system must downgrade to a cheaper plan

  (more questions, smaller helper, smaller scope) or stop at Draft.

  

===============================================================================

END v3.2 CANON

==============================================================================


PATCHGIT v1

TITLE: MASTER v3.3 — Lane 3 = Runpod (worth-it gated), API becomes Lane 4, budget caps + confirm semantics

SCOPE: Update compute ladder + escalation policy so Lane 3 is Runpod GPU burst (only when worth it); external API is last-resort Lane 4; enforce $5/day caps by lane category.

TARGETS:

  

- docs/MASTER.md (append; if your repo uses a different master filename, apply this same patch to that file)  
    —BEGIN—

  

  

  

===============================================================================

  

MASTER v3.3 PATCH — LANE 3 RUNPOD + LANE 4 API + $5/DAY BUDGET CAPS (CANON)

  

  

This patch updates the compute escalation ladder and confirmation semantics:

  

- Lane 0 remains always-on 1GB control plane (NO LLM required; deterministic only)
- Lane 1 remains single helper burst (recommended default: 2–4GB)
- Lane 2 remains stronger local burst (recommended: 2×8GB) for “try harder” locally
- Lane 3 is now Runpod GPU burst (worth-it gated; requires explicit spend approval)
- Lane 4 is now External Model API (last resort; requires explicit spend approval)

  

  

This patch resolves prior ambiguity where “big model” could mean either “local bigger worker”

or “external API.” From now on:

  

- “Big compute” (GPU burst) == Lane 3 Runpod
- “Big external model” == Lane 4 API

  

  

  

  

  

A) EXECUTION LANES — UPDATED LADDER (v3.3 CANON)

  

  

Lane 0: ALWAYS-ON CONTROL PLANE (1GB, boring, deterministic)

  

- No expectation of running an intelligent LLM locally.
- Responsibilities:  
    

- UI (Chat + PATCHGIT)
- auth + sessions (PIN)
- queue + serialization lock
- audit log + budget manager
- repo metadata scan / file targeting preflight
- generates bounded clarifying questions (NO LLM REQUIRED)

-   
    
- Allowed actions:  
    

- read-only repo inspection
- prepare candidate plans
- NEVER spins paid compute unless “worth-it” gates pass

-   
    

  

  

Lane 1: SINGLE HELPER BURST (default “real work”)

  

- Recommended size: 2–4GB (choose smallest that meets task needs)
- Purpose:  
    

- sandbox apply (fresh clone / isolated working dir)
- formatting / lint / tests (deterministic checks)
- “Panel Review” role memos + reducer (architect/security/philosopher/coach)
- compile ops -> canonical executable patch artifact (e.g., unified diff)

-   
    
- Outcome target: reach C2 (Apply) or C3 (Ship-ready PR)

  

  

Lane 2: STRONGER LOCAL BURST (TRY HARDER BEFORE GPU/API)

  

- Recommended topology: 2×8GB ephemeral helpers
- Trigger when (any true):  
    

- Lane 1 still < C2 after one pass
- multiple plausible plans exist and choice is risky
- apply/check failures need non-trivial repair
- protected-zone changes are explicitly requested and require deeper critique

-   
    
- Constraints:  
    

- one Lane 2 attempt per job (no loops)
- produce reduced single canonical artifact (ExecutionRequest or Blocked package)

-   
    

  

  

Lane 3: RUNPOD GPU BURST (WORTH-IT GATED, REQUIRES APPROVAL)

  

- Purpose:  
    

- deep reasoning / long-context synthesis / heavy transforms
- run “big local model” inference using GPU resources
- resolve complex patch repair cases that Lane 2 cannot fix safely

-   
    
- Hard rule:  
    

- Lane 3 MUST NOT run automatically.
- Lane 3 requires an explicit “Approve Runpod spend” toggle on the confirm screen.

-   
    
- Trigger gate (ALL must be true):  
    

- Lane 1 attempted (unless change_class is trivial DOC_ONLY)
- Lane 2 attempted OR explicitly skipped with a written reason
- System can name the blockage precisely (specific missing reasoning/tool capability)
- System predicts Runpod materially improves confidence OR reduces risk
- Estimated cost fits remaining budget OR user approves extra spend

-   
    
- Required outputs:  
    

- Must address Panel Review memos (architect/security/philosopher/coach) explicitly
- Must output exactly ONE of:  
    

- ExecutionRequest (ready)
- NeedsClarification (<=3 multiple-choice questions)
- Blocked package (what is missing + why it matters + cheapest unblock)

-   
    

-   
    

  

  

Lane 4: EXTERNAL MODEL API (LAST RESORT, REQUIRES APPROVAL)

  

- Trigger ONLY when ALL are true:  
    

1. Lane 3 was attempted and still blocked OR Lane 3 is unavailable
2. System states WHY uncertainty remains (specific missing reasoning)
3. System predicts API materially improves the outcome vs Lane 3
4. User approves “Approve API spend” on confirm screen

-   
    
- API is used to resolve ambiguity / improve plan, NOT to bypass gates.

  

  

  

  

  

B) “WORTH-IT” POLICY — MECHANICAL GATE (v3.3 CANON)

  

  

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

  

  

  

  

  

C) CONFIRM SCREEN — UPDATED SPEND APPROVAL SEMANTICS (v3.3 CANON)

  

  

Confirm screen must include:

  

- Intent summary
- Explicit targets list
- Diff preview (from real sandbox apply whenever non-trivial)
- Confidence C0..C3 and reasons
- Spend summary + remaining budget

  

  

New required toggles:

  

- “Approve Runpod spend” (only shown if Lane 3 recommended)
- “Approve API spend” (only shown if Lane 4 recommended)

  

  

Hard rule:

  

- Without the relevant approval toggle enabled, the system MUST downgrade:  
    

- ask questions
- reduce scope
- use cheaper lane
- or stop at Draft (C0/C1)

-   
    

  

  

  

  

  

D) BUDGET MANAGER — $5/DAY CAPS BY CATEGORY (v3.3 CANON)

  

  

Daily hard cap: $5/day total.

  

Split into lane-category sub-caps (default):

  

- Local Burst (Lane 1–2): $3.00/day
- Runpod (Lane 3):        $1.50/day
- External API (Lane 4):  $0.50/day

  

  

Rules:

  

- System must not exceed any sub-cap without explicit approval on confirm screen.
- Any single job projected to exceed remaining cap requires explicit approval.
- If approval not granted: system must propose a cheaper alternative.

  

  

Note:

  

- Local burst spend is primarily compute runtime; Runpod and API are explicit line-items.
- The audit log must record estimated vs actual spend per lane.

  

  

  

  

  

E) PANEL REVIEW (ROLES) — REQUIRED OUTPUT CONTRACT (v3.3 CANON)

  

  

The “philosopher / architect / security / coach” pattern is preserved as “Panel Review.”

  

Panel Review runs in Lane 1 by default, and may be re-run in Lane 2/3 if escalated.

  

Each role outputs a bounded memo:

  

- intent_interpretation (1–2 sentences)
- risks (max 3 bullets)
- recommended_plan (max 5 bullets)
- one_best_question (optional; max 1)
- confidence_0_100
- blocker (yes/no)

  

  

Reducer outputs exactly ONE:

  

- ExecutionRequest
- NeedsClarification (<=3 multiple-choice questions)
- Blocked package (what is missing + why it matters + cheapest unblock)

  

  

No debate loops. No multi-round back-and-forth between roles.

  

  

  

  

F) AUDITABILITY — REQUIRED TRACE ITEMS FOR LANE 3 (v3.3 CANON)

  

  

If Lane 3 Runpod is used, audit trace MUST include:

  

- why Lane 3 was recommended (blockage + expected gain)
- cost estimate + actual spend
- panel memos + reducer output
- final canonical artifact (ExecutionRequest / NeedsClarification / Blocked)
- explicit record of user approval toggle state

  

  

  

===============================================================================

  

END MASTER v3.3 PATCH

  

  

—END—

PATCHGIT v1

TITLE: MASTER v3.4 — Canon PatchOps Hybrid (JSON plan + diff preview), Deterministic Modify Semantics, GH CLI PRs, SQLite+Artifacts Storage Plan

SCOPE: Amend MASTER to (1) define the “hybrid” patch representation, (2) lock down safe deterministic edit operations (no fuzzy modify; marker-bounded replace-block), (3) standardize GitHub PR creation via gh CLI, and (4) specify SQLite metadata + artifacts storage options/cost baseline.

TARGETS:

  

- docs/MASTER.md (append; if your repo uses a different master filename, apply this patch to that file)  
    —BEGIN—

  

  

  

===============================================================================

  

MASTER v3.4 PATCH — PATCHOPS HYBRID CANON + SAFE EDIT SEMANTICS + GH CLI + SQLITE/ARTIFACTS

  

  

This patch consolidates the following into the canonical MASTER plan:

  

1. “Hybrid” patch representation (JSON ops internally + unified diff preview externally).
2. Deterministic edit semantics (no fuzzy “modify”; marker-bounded block replacement).
3. GitHub PR creation via gh CLI (standard operational path).
4. SQLite for job metadata + artifacts storage model (droplet disk vs Spaces), plus baseline cost notes.

  

  

  

  

  

A) PATCH REPRESENTATION — HYBRID CANON (v3.4)

  

  

Goal: preserve safety and determinism while still providing human-reviewable diffs.

  

Canon rule:

  

- The system MUST maintain TWO representations of every proposed change:  
    (1) Executor-facing: PatchOps (structured JSON operations)  
    - canonical input to the deterministic executor  
    - MUST be fully validated before execution  
    (2) Human-facing: DiffPreview (unified diff)  
    - shown on the Confirm Screen  
    - included in PR body when useful  
    - produced from sandbox apply whenever non-trivial

  

  

Rationale:

  

- JSON PatchOps are easy to validate and gate (targets, operations, protected zones).
- Unified diffs are easy for humans to review and align with Git workflows.

  

  

Consequence:

  

- LLMs MAY propose PatchOps.
- The deterministic system MUST validate PatchOps and generate DiffPreview via sandbox apply.
- The executor MUST NOT accept freeform “edit this paragraph” instructions directly.

  

  

  

  

  

B) PATCHOPS — DETERMINISTIC EDIT SEMANTICS (v3.4)

  

  

The executor supports a small, safe set of deterministic operations.

  

v1 REQUIRED operations (minimum viable, safe):

  

1. CREATE_FILE(path, content)
2. REPLACE_FILE(path, content)
3. APPEND_FILE(path, content)
4. REPLACE_BLOCK(path, block_id, content)   <– marker-bounded replacement

  

  

v1 NOT ALLOWED by default:

  

- fuzzy “modify” (semantic edits without strict boundaries)
- “search and replace” without strict context bounds
- arbitrary regex replace
- AST-based code transforms

  

  

REPLACE_BLOCK semantics (canon):

  

- Files MAY contain explicit markers defining editable regions:

  

<!-- FUTILITYS:BEGIN <block_id> -->

  

- …existing content…

  

<!-- FUTILITYS:END <block_id> -->

  

-   
    
- REPLACE_BLOCK replaces ONLY the content between the markers for <block_id>.
- If markers are missing, the operation MUST FAIL safely and return a Blocked package  
    OR request clarification (<=3 questions), never guessing.

  

  

Optional later (not required now):

  

- PATCH_HUNKS(path, unified_diff) with strict context matching (git apply)
- AST transforms limited to specific languages + safe rules

  

  

  

  

  

C) GITHUB INTEGRATION — GH CLI STANDARD (v3.4)

  

  

Canon rule:

  

- PR creation SHOULD use GitHub CLI (“gh”) as the primary mechanism.

  

  

Executor PR workflow (canonical):

  

- create branch
- commit changes
- push branch
- create PR via gh CLI

  

  

Notes:

  

- The executor remains deterministic code; LLMs never run git or gh directly.
- Tokens/credentials are stored only on the control plane and never committed.
- PRs are always opened against the default base branch (e.g., main).
- No direct push to main; PR only.

  

  

  

  

  

D) SQLITE + ARTIFACTS — STORAGE MODEL (v3.4)

  

  

Canon decision:

  

- SQLite is the default job metadata store for v1.
- “Artifacts” (patch bundles, logs, diff previews, attachments) are stored as files,  
    referenced by SQLite.

  

  

SQLite stores:

  

- job_id, timestamps, user/session id
- stage outputs (PatchProposal / GateVerdict / ExecutionRequest)
- confidence level (C0..C3)
- lane used (0..4) + worth-it score + budget deltas
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

  

  

  

  

  

E) BASELINE COST NOTES (INFORMATIONAL, v3.4)

  

  

Baseline “serious but cheap” always-on setup typically includes:

  

- 1x small always-on control plane droplet
- SQLite on droplet
- artifacts on droplet disk OR object storage for long-term retention
- optional weekly backups for durability

  

  

Important:

  

- Burst compute (Lane 1/2), Runpod (Lane 3), and External API (Lane 4)  
    remain governed by budget caps + worth-it + confirm toggles as defined in v3.3.

  

  

  

  

  

F) CONFIRM SCREEN — REQUIRED DISPLAY ITEMS (AMENDED, v3.4)

  

  

Confirm screen MUST show:

  

- Intent summary
- Explicit targets list
- PatchOps summary (operations + affected paths)
- DiffPreview (collapsed + expandable; from sandbox apply whenever non-trivial)
- Confidence C0..C3 and reasons
- Spend summary (estimated vs actual where available)
- Approval toggles for any paid escalation (Runpod/API, etc.)

  

  

  

  

  

END MASTER v3.4 PATCH

  

  

—END—