*** 0004-master-v3.4.patch
diff --git a/docs/MASTER.md b/docs/MASTER.md
index 4444444..5555555 100644
--- a/docs/MASTER.md
+++ b/docs/MASTER.md
@@ -1,6 +1,6 @@
 ===============================================================================
 
-FUTILITY’S — CHAT→PATCH→GIT COMPILER (MASTER v3.3)
+FUTILITY’S — CHAT→PATCH→GIT COMPILER (MASTER v3.4)
 
 Purpose: "Smart patching" system that turns chat/paste into audited git PRs.
 
@@ -44,6 +44,42 @@ B) PATCHGIT Mode (fast paste envelope):
 
     ---END---
 
+2.1) PATCH REPRESENTATION (HYBRID CANON)
+---------------------------------------
+
+Canon rule:
+
+- The system MUST maintain TWO representations of every proposed change:
+
+  (1) Executor-facing: PatchOps (structured JSON operations)
+      - canonical input to the deterministic executor
+      - MUST be fully validated before execution
+
+  (2) Human-facing: DiffPreview (unified diff)
+      - shown on the Confirm Screen
+      - produced from sandbox apply whenever non-trivial
+      - included in PR body when useful
+
+Consequence:
+
+- LLMs MAY propose PatchOps.
+- The deterministic system MUST validate PatchOps and generate DiffPreview via sandbox apply.
+- The executor MUST NOT accept freeform “edit this paragraph” instructions directly.
+
@@ -70,6 +106,14 @@ Stage 1 Output: PatchProposal
 
   - per-target ops (create/append/replace/modify)
 
   - patch payload (markdown/code)
 
+  - PatchOps (structured JSON operations) when proposing executable edits
+
+  - DiffPreview request intent (so the system can generate unified diff via sandbox apply)
+
   - questions_needed (<=3)
 
   - self-declared risk flags
 
@@ -132,6 +176,42 @@ Lane 4: EXTERNAL MODEL API (LAST RESORT, REQUIRES APPROVAL)
 
   Note:
 
     - API is used to resolve ambiguity / improve plan, not to bypass gates.
 
+8.1) PATCHOPS DETERMINISTIC EDIT SEMANTICS (v3.4 CANON)
+------------------------------------------------------
+
+Executor supports a small, safe set of deterministic operations.
+
+v1 REQUIRED operations (minimum viable, safe):
+
+1. CREATE_FILE(path, content)
+2. REPLACE_FILE(path, content)
+3. APPEND_FILE(path, content)
+4. REPLACE_BLOCK(path, block_id, content)  (marker-bounded replacement)
+
+v1 NOT ALLOWED by default:
+
+- fuzzy “modify” (semantic edits without strict boundaries)
+- “search and replace” without strict context bounds
+- arbitrary regex replace
+- AST-based code transforms
+
+REPLACE_BLOCK semantics (canon):
+
+- Files MAY contain explicit markers defining editable regions:
+
+<!-- FUTILITYS:BEGIN <block_id> -->
+... existing content ...
+<!-- FUTILITYS:END <block_id> -->
+
+- REPLACE_BLOCK replaces ONLY the content between the markers for <block_id>.
+- If markers are missing, the operation MUST FAIL safely and return a Blocked package
+  OR request clarification (<=3 questions), never guessing.
+
@@ -146,10 +226,13 @@ Show:
 
   - Intent summary (what Conductor believes you meant)
 
   - Targets list (explicit)
 
-  - Diff preview (collapsed + expandable)
+  - PatchOps summary (operations + affected paths)
+
+  - Diff preview (collapsed + expandable; from sandbox apply whenever non-trivial)
 
   - Confidence level (C0..C3) + reasons
 
   - Spend summary (droplets used / API used)
 
@@ -169,20 +252,63 @@ Given ExecutionRequest:
 
   - acquire lock (one job at a time)
 
   - pull latest main
 
   - allocate next patch number NNN
 
   - write patches/NNN-*.md (raw intake + final payload + metadata)
 
   - append HISTORY.md
 
-  - apply file edits (create/append/replace/modify)
+  - apply file edits via PatchOps ONLY (deterministic operations)
 
   - branch -> commit -> push -> PR
 
+GitHub PR creation (canon):
+
+  - PR creation SHOULD use GitHub CLI (“gh”) as the primary mechanism:
+      * create branch
+      * commit changes
+      * push branch
+      * create PR via gh CLI
+
 Failure handling:
 
   - abort safely; do not partially publish
 
   - record full logs + reason in audit
 
+10.1) SQLITE + ARTIFACTS (STORAGE MODEL)
+---------------------------------------
+
+Canon decision:
+
+- SQLite is the default job metadata store for v1.
+- Artifacts (patch bundles, logs, diff previews, attachments) are stored as files,
+  referenced by SQLite.
+
+SQLite stores:
+
+- job_id, timestamps, user/session id
+- stage outputs (PatchProposal / GateVerdict / ExecutionRequest)
+- confidence level (C0..C3)
+- lane used (0..4) + worth-it score + budget deltas
+- repo refs (repo url, base branch, commit hashes)
+- execution status + error reasons
+- artifact references (paths or object keys)
+
+Artifacts store (choose per deployment; both supported):
+
+Option A — Droplet disk (simplest):
+
+- Store artifacts under /var/lib/futilitys/artifacts/<job_id>/
+- Pros: zero extra services, simplest for MVP
+- Cons: durability depends on backups/snapshots
+
+Option B — Object storage (recommended for durable audit history):
+
+- Store artifacts in object storage (e.g., DigitalOcean Spaces) and reference object keys
+- Pros: durable, scalable for long-term audit retention
+- Cons: small monthly base cost
+
+Recommended MVP default:
+
+- SQLite + droplet disk artifacts
+- Enable object storage when audit retention needs grow
+
@@ -242,6 +368,32 @@ PATCH ENTRY LOG
 - Applied: MASTER v3.1 (Compute Ladder alignment inside core sections)
 - Applied: MASTER v3.2 (Sandbox + single helper default + hourly/daily caps + GO semantics)
 - Applied: MASTER v3.3 (Lane 3 Runpod + Lane 4 API + Worth-It gate + Panel Review + $5/day sub-caps)
+- Applied: MASTER v3.4 (PatchOps hybrid + deterministic edit semantics + gh CLI PRs + SQLite/artifacts storage model)
 
 CHANGE SUMMARY
 
 - v3.2: Added segregated sandbox as default safety mechanism.
 - v3.2: Default compute model shifted to “single helper” burst; escalation beyond that requires explicit confirmation.
 - v3.2: Budget enforcement clarified as hourly + daily caps requiring confirm-screen approval to exceed.
 - v3.2: Confirm primary action renamed/defined as GO (creates PR; no auto-merge).
 
 - v3.3: Lanes redefined: Lane 2 (2×8GB) “try harder locally”, Lane 3 Runpod GPU burst, Lane 4 external API last resort.
 - v3.3: Added required WorthItScore scorecard for paid escalation; Lane 3/4 always require explicit approval.
 - v3.3: Added $5/day total cap with per-category sub-caps (Local Burst / Runpod / API).
 - v3.3: Panel Review role memos formalized with strict reducer outputs (ExecutionRequest / NeedsClarification / Blocked).
+
+- v3.4: Patch representation canonized as hybrid: PatchOps (executor) + DiffPreview (human) generated via sandbox apply.
+- v3.4: Deterministic edit semantics locked down (CREATE_FILE/REPLACE_FILE/APPEND_FILE/REPLACE_BLOCK; no fuzzy modify).
+- v3.4: PR creation standardized via GitHub CLI (gh) as the primary mechanism.
+- v3.4: SQLite + artifacts storage model specified (droplet disk default; optional object storage).
 
 PARTS REMOVED / SUPERSEDED
 
 - Superseded v3.2’s generic “external API last resort” wording with explicit Lane 4 semantics and required approval toggle.
 - Superseded v3.2’s “escalation beyond single helper” blanket wording with explicit Lane 2/3/4 ladder and gates.
+- Superseded any prior “modify” operation language that implied fuzzy/semantic edits without strict boundaries; executor now requires deterministic PatchOps.
 
 PARTS REMOVED / SUPERSEDED
 
 - Removed the claim that the 1GB always-on node “runs a kinda dumb local LLM” as a default capability statement.
 - Superseded the prior default “swarm burst” description as a default lane; swarm is no longer default behavior in v3.2.
 
 ===============================================================================
 
-END MASTER v3.3
+END MASTER v3.4
 
 ===============================================================================