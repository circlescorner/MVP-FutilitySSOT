
  

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