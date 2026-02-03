

*** 0001-master-v3.1.patch
diff --git a/docs/MASTER.md b/docs/MASTER.md
index 1111111..2222222 100644
--- a/docs/MASTER.md
+++ b/docs/MASTER.md
@@ -1,6 +1,6 @@
 ===============================================================================
 
-FUTILITY’S — CHAT→PATCH→GIT COMPILER (MASTER v3)
+FUTILITY’S — CHAT→PATCH→GIT COMPILER (MASTER v3.1)
 
 Purpose: "Smart patching" system that turns chat/paste into audited git PRs.
 
@@ -20,7 +20,7 @@ D0.7 Auditability: every attempt produces a trace (even failures).
 Always-on Control Plane:
 
   - 1x 1GB droplet (always up)
 
   - Hosts: website UI, auth (PIN), job queue, orchestration, audit log
 
-  - Runs: "kinda dumb" local LLM for triage / drafts / light edits
+  - No expectation of running a capable LLM locally on 1GB; keep control plane stable and boring
 
   - Holds: DO API token, GitHub token, budget state, config
 
 
@@ -94,26 +94,30 @@ Budget behavior:
 
   - if budget low: prefer questions + local-only chain; avoid swarm; avoid API
 
 
 8) EXECUTION LANES (YOUR NEW ESCALATION LADDER)
 -----------------------------------------------
 
-Lane 0: ALWAYS-ON 1GB ("kinda dumb" local LLM)
-
-  - best for: drafting patch text, small doc changes, parsing PATCHGIT
-
-  - limitations: low reasoning depth; no heavy transforms; minimal checks
+Lane 0: ALWAYS-ON 1GB CONTROL PLANE (BORING, DETERMINISTIC)
+
+  - No expectation of running an intelligent LLM locally on 1GB
+  - best for: orchestration, bounded questions, repo targeting preflight, git plumbing
+  - limitations: do not attempt “real reasoning” or heavy transforms here
 
 
 Lane 1: MEDIUM BURST (single 2–8GB droplet)
 
   Trigger when:
 
     - patch touches multiple files
 
     - patch includes code formatting/lint
 
     - Stage 2 confidence < C2 but close
 
     - repo needs sandbox apply to confirm
 
   Purpose:
 
     - stronger local reasoning (bigger model) OR more RAM/CPU for tools
 
     - run deterministic checks
 
     - produce C2→C3 confidence
 
 
 Lane 2: SWARM BURST (either 2×8GB OR 4×4GB)
 
   Trigger when:
 
     - uncertainty remains after Lane 1
 
     - multiple competing plans exist
 
     - risk is high (many files, complex edits)
 
     - need multi-angle critique (planner vs critic vs fit)
@@ -136,11 +140,11 @@ Lane 3: EXTERNAL API (last resort)
 
   Trigger ONLY when ALL are true:
 
     - local chain remains uncertain (Stage 2 FAIL or < C2)
 
     - chain states WHY uncertainty exists (specific missing reasoning)
 
     - chain predicts API materially improves confidence
 
     - budget allows
 
   Note:
 
     - API is used to resolve ambiguity / improve plan, not to bypass gates
 
@@ -194,11 +198,47 @@ Even if targets are "any", the system protects itself via:
 
 12) FUTURE PLUGINS (NOT REQUIRED NOW)
 -------------------------------------
 
 - Swarm expansion at any stage: N agents → reducer → canonical output
 
 - Runpod escalation for hard reasoning (after Lane 3 if enabled)
 
 - Auto-merge for safe change classes (C4) — later, off by default
 
 
 ===============================================================================
 
-END MASTER v3
+13) CHANGE SUMMARY + PARTS REMOVED (APPEND-ONLY)
+-----------------------------------------------
+
+This section is append-only. Each applied patch MUST add a new entry here.
+
+CHANGE SUMMARY
+
+- v3.1: Control plane clarified as “boring, deterministic” with no expectation of capable local LLM on 1GB.
+- v3.1: Execution lanes text aligned so Lane 0 is deterministic control plane; burst lanes carry compute.
+
+PARTS REMOVED / SUPERSEDED
+
+- Removed the claim that the 1GB always-on node “runs a kinda dumb local LLM” as a default capability statement.
+
+PATCH ENTRY LOG
+
+- Applied: MASTER v3.1 (Compute Ladder alignment inside core sections)
+
+===============================================================================
+
+END MASTER v3.1
 
 ===============================================================================