

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

