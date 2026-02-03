*** 0003-master-v3.3.patch
diff --git a/docs/MASTER.md b/docs/MASTER.md
index 3333333..4444444 100644
--- a/docs/MASTER.md
+++ b/docs/MASTER.md
@@ -1,6 +1,6 @@
 ===============================================================================
 
-FUTILITY’S — CHAT→PATCH→GIT COMPILER (MASTER v3.2)
+FUTILITY’S — CHAT→PATCH→GIT COMPILER (MASTER v3.3)
 
 Purpose: "Smart patching" system that turns chat/paste into audited git PRs.
 
@@ -86,7 +86,7 @@ Rules:
 
 
 7) BUDGET MANAGER (DAILY LIMITS + "WORTH IT")
 ---------------------------------------------
 
 Budget types tracked daily:
 
   - local compute minutes (burst worker droplet time)
 
   - external API token spend
@@ -94,6 +94,50 @@ Budgets are enforced at two levels:
 
 Hard rule:
 
   - The system MUST NOT exceed hourly or daily budgets without explicit user confirmation
     on the confirm screen.
 
+"WORTH-IT" POLICY (MECHANICAL GATE)
+
+Replace vague “worth it” with a required scorecard.
+
+For any paid escalation (Lane 1/2/3/4), compute:
+
+WorthItScore = (ExpectedGain * RiskWeight) / EstimatedCost
+
+Where:
+
+- ExpectedGain: predicted confidence improvement (e.g., C1->C3 > C1->C2)
+- RiskWeight: higher for protected zones, many files, core pipeline, auth/CI changes
+- EstimatedCost: projected dollars for the lane action (include spin-up minimums)
+
+Rules:
+
+- If WorthItScore < threshold: do NOT escalate; ask better questions or reduce scope.
+- Threshold increases as remaining daily budget decreases.
+- Lane 3 and Lane 4 ALWAYS require explicit user approval regardless of score.
+
+DAILY BUDGET CAPS (v3.3 CANON)
+
+Daily hard cap: $5/day total.
+
+Split into lane-category sub-caps (default):
+
+- Local Burst (Lane 1–2): $3.00/day
+- Runpod (Lane 3):        $1.50/day
+- External API (Lane 4):  $0.50/day
+
+Rules:
+
+- System must not exceed any sub-cap without explicit approval on confirm screen.
+- Any single job projected to exceed remaining cap requires explicit approval.
+- If approval not granted: system must propose a cheaper alternative.
+
@@ -112,31 +156,101 @@ Lane 0: ALWAYS-ON 1GB CONTROL PLANE (BORING, DETERMINISTIC)
   - best for: orchestration, bounded questions, repo targeting preflight, git plumbing
   - limitations: do not attempt “real reasoning” or heavy transforms here
 
 
-Lane 1: SINGLE HELPER BURST (DEFAULT “REAL WORK”)
+Lane 1: SINGLE HELPER BURST (DEFAULT “REAL WORK”)
 
   Trigger when:
 
     - patch touches multiple files
 
     - patch includes code formatting/lint
 
     - Stage 2 confidence < C2 but close
 
     - repo needs sandbox apply to confirm
 
   Purpose:
 
     - sandbox apply (fresh clone / isolated working dir)
     - formatting / lint / tests (deterministic checks)
     - repo-wide operations that exceed safe base-load capacity
+
+  Panel Review (roles) runs in Lane 1 by default:
+
+    - philosopher / architect / security / coach
+    - each role outputs a bounded memo:
+        * intent_interpretation (1–2 sentences)
+        * risks (max 3 bullets)
+        * recommended_plan (max 5 bullets)
+        * one_best_question (optional; max 1)
+        * confidence_0_100
+        * blocker (yes/no)
+
+    - reducer outputs exactly ONE:
+        * ExecutionRequest
+        * NeedsClarification (<=3 multiple-choice questions)
+        * Blocked package (what is missing + why it matters + cheapest unblock)
+
+    - No debate loops. No multi-round back-and-forth between roles.
 
 
-Escalation beyond SINGLE HELPER (requires confirmation):
+Lane 2: STRONGER LOCAL BURST (TRY HARDER BEFORE GPU/API)
 
-  If the system believes it needs more than 1 helper OR a larger helper tier than policy allows
-  OR external API calls, it must request explicit user confirmation with a cost/benefit summary.
+  - Recommended topology: 2×8GB ephemeral helpers
+  - Trigger when (any true):
+      * Lane 1 still < C2 after one pass
+      * multiple plausible plans exist and choice is risky
+      * apply/check failures need non-trivial repair
+      * protected-zone changes are explicitly requested and require deeper critique
+
+  - Constraints:
+      * one Lane 2 attempt per job (no loops)
+      * produce reduced single canonical artifact (ExecutionRequest or Blocked package)
 
 
-External API (last resort; requires confirmation):
+Lane 3: RUNPOD GPU BURST (WORTH-IT GATED, REQUIRES APPROVAL)
+
+  - Purpose:
+      * deep reasoning / long-context synthesis / heavy transforms
+      * run “big local model” inference using GPU resources
+      * resolve complex patch repair cases that Lane 2 cannot fix safely
+
+  - Hard rule:
+      * Lane 3 MUST NOT run automatically.
+      * Lane 3 requires an explicit “Approve Runpod spend” toggle on the confirm screen.
+
+  - Trigger gate (ALL must be true):
+      * Lane 1 attempted (unless change_class is trivial DOC_ONLY)
+      * Lane 2 attempted OR explicitly skipped with a written reason
+      * System can name the blockage precisely (specific missing reasoning/tool capability)
+      * System predicts Runpod materially improves confidence OR reduces risk
+      * Estimated cost fits remaining budget OR user approves extra spend
+
+  - Required outputs:
+      * Must address Panel Review memos explicitly
+      * Must output exactly ONE of:
+          - ExecutionRequest (ready)
+          - NeedsClarification (<=3 multiple-choice questions)
+          - Blocked package (what is missing + why it matters + cheapest unblock)
+
+
+Lane 4: EXTERNAL MODEL API (LAST RESORT, REQUIRES APPROVAL)
 
   Trigger ONLY when ALL are true:
 
-    - local chain remains uncertain (Stage 2 FAIL or < C2)
-
-    - chain states WHY uncertainty exists (specific missing reasoning)
-
-    - chain predicts API materially improves confidence
-
-    - budget allows
+    1. Lane 3 was attempted and still blocked OR Lane 3 is unavailable
+    2. System states WHY uncertainty remains (specific missing reasoning)
+    3. System predicts API materially improves the outcome vs Lane 3
+    4. User approves “Approve API spend” on confirm screen
 
   Note:
 
     - API is used to resolve ambiguity / improve plan, not to bypass gates
 
@@ -156,6 +270,18 @@ Confirm screen must include:
 
 New required toggles:
 
+  - “Approve Runpod spend” (only shown if Lane 3 recommended)
+  - “Approve API spend” (only shown if Lane 4 recommended)
+
 Hard rule:
 
-  - Without the relevant approval toggle enabled, the system MUST downgrade:
+  - Without the relevant approval toggle enabled, the system MUST downgrade:
 
     - ask questions
 
     - reduce scope
 
     - use cheaper lane
 
     - or stop at Draft (C0/C1)
 
@@ -226,6 +352,33 @@ PATCH ENTRY LOG
 - Applied: MASTER v3.1 (Compute Ladder alignment inside core sections)
 - Applied: MASTER v3.2 (Sandbox + single helper default + hourly/daily caps + GO semantics)
+- Applied: MASTER v3.3 (Lane 3 Runpod + Lane 4 API + Worth-It gate + Panel Review + $5/day sub-caps)
 
 CHANGE SUMMARY
 
 - v3.2: Added segregated sandbox as default safety mechanism.
 - v3.2: Default compute model shifted to “single helper” burst; escalation beyond that requires explicit confirmation.
 - v3.2: Budget enforcement clarified as hourly + daily caps requiring confirm-screen approval to exceed.
 - v3.2: Confirm primary action renamed/defined as GO (creates PR; no auto-merge).
+
+- v3.3: Lanes redefined: Lane 2 (2×8GB) “try harder locally”, Lane 3 Runpod GPU burst, Lane 4 external API last resort.
+- v3.3: Added required WorthItScore scorecard for paid escalation; Lane 3/4 always require explicit approval.
+- v3.3: Added $5/day total cap with per-category sub-caps (Local Burst / Runpod / API).
+- v3.3: Panel Review role memos formalized with strict reducer outputs (ExecutionRequest / NeedsClarification / Blocked).
+
+PARTS REMOVED / SUPERSEDED
+
+- Superseded v3.2’s generic “external API last resort” wording with explicit Lane 4 semantics and required approval toggle.
+- Superseded v3.2’s “escalation beyond single helper” blanket wording with explicit Lane 2/3/4 ladder and gates.
 
 PARTS REMOVED / SUPERSEDED
 
 - Removed the claim that the 1GB always-on node “runs a kinda dumb local LLM” as a default capability statement.
 - Superseded the prior default “swarm burst” description as a default lane; swarm is no longer default behavior in v3.2.
 
 ===============================================================================
 
-END MASTER v3.2
+END MASTER v3.3
 
 ===============================================================================