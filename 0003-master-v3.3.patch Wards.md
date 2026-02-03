
  

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
