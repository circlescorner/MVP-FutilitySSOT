===============================================================================
FUTILITY'S — SPEC PATCH MANUAL (FOR AI + HUMANS)
===============================================================================

This document teaches how to propose changes to the canonical specification
in docs/MASTER.md using git unified-diff patches.

===============================================================================
0) WHAT THIS SYSTEM IS
===============================================================================

- docs/MASTER.md is the CANONICAL specification document
- Changes are proposed as unified diff patches
- Patches are reviewed via PR before merging
- A human reviews and merges

Goal: Evolve the MASTER into a single cohesive, human-readable document
that reflects the latest decisions without contradictions.

===============================================================================
1) CANON RULES FOR CHANGES
===============================================================================

R1 — NO SCOPE CREEP
-------------------
Do NOT add new goals, systems, or features not requested.

You may only:
  - Clarify wording
  - Reorganize structure (when requested)
  - Correct contradictions
  - Integrate new decisions the user explicitly provides
  - Remove superseded concepts when later canon overrides them

R2 — LATER CANON OVERRIDES EARLIER
----------------------------------
If a new change conflicts with older text:
  - REMOVE or REPLACE the older conflicting text
  - Ensure the final document reads as one cohesive thought

Do NOT "append and leave contradictions."

R3 — MINIMAL NECESSARY CHANGE
-----------------------------
Prefer the smallest diff that achieves the requested change.
Avoid rewriting unrelated sections.

R4 — DETERMINISTIC, PATCHABLE EDITS
-----------------------------------
Output must be a valid unified diff patch that applies using git apply.
The patch must target docs/MASTER.md unless explicitly told otherwise.

R5 — UPDATE END-OF-DOCUMENT LOGS
--------------------------------
At the end of docs/MASTER.md, there are sections for:
  - CHANGE LOG

Any patch that alters content must update these logs with concise entries.

R6 — NO SECRETS
---------------
Never include passwords, tokens, private keys, or personal identifying info.
Never invent credentials.

===============================================================================
2) REQUIRED PATCH OUTPUT FORMAT
===============================================================================

Output must be a single unified diff patch, starting with:

    diff --git a/docs/MASTER.md b/docs/MASTER.md

The patch must include valid hunk headers like:

    @@ -old_line,old_count +new_line,new_count @@

Do not include explanation text before or after the diff.
Do not wrap the diff in narrative.
Do not output multiple alternative patches.

===============================================================================
3) PATCH NAMING AND SEQUENCING
===============================================================================

Patches are applied in numeric order. Use a 4-digit prefix:

    0001-...
    0002-...
    0003-...

For new patches, choose the next number:

    0005-master-v4.1.patch
    0006-master-clarify-assets.patch

===============================================================================
4) HOW TO DESIGN A GOOD PATCH
===============================================================================

STEP A — Read the request carefully
  Extract the exact change requested.
  Do not assume additional desired changes.

STEP B — Read the entire docs/MASTER.md
  Identify:
    - Which sections contain relevant content
    - What text must be removed/replaced to avoid contradictions
    - Whether the change affects headings, definitions, or policies

STEP C — Plan the minimal diff
  Common safe patterns:
    1. Replace a paragraph under a section
    2. Replace an entire numbered section body (keep header)
    3. Delete conflicting subsection and integrate updated canon in one place
    4. Add new short subsection only if needed for coherence

STEP D — Implement the diff
  - Keep edits localized
  - Maintain the document's style/voice
  - Ensure final document reads naturally
  - Update change log

STEP E — Self-check before output
  - Does the patch only touch docs/MASTER.md?
  - Does it remove/replace conflicting older content?
  - Does it keep the document cohesive?
  - Does it update the change log?
  - Is the diff valid unified format?

===============================================================================
5) EXAMPLE CHANGE REQUEST PHRASING
===============================================================================

Good phrasing that produces clean diffs:

  "Update the escalation tiers to remove Lane 2 and renumber."

  "Add a new section for photo intake between sections 2 and 3."

  "Replace the question discipline text with the scoring system."

  "Remove the contradictory budget caps and keep only the $5/day version."

===============================================================================
6) BEST PRACTICES FOR HUMANS
===============================================================================

1. ONE INTENTION PER PATCH
   Each patch should have one clear goal.
   Avoid "mega-patches" that touch many unrelated sections.

2. PREFER REPLACE OVER APPEND
   If newer language supersedes older language, remove the old.
   Do not leave multiple "canon versions" inside the document.

3. KEEP STRUCTURE PREDICTABLE
   Preserve top-level numbered sections unless explicitly reorganizing.
   If reorganizing, do it in a dedicated patch.

4. MAINTAIN CHANGE LOG
   Every meaningful patch updates the change log.
   Keep entries short and factual.

5. AVOID DUPLICATE PATCHES
   Keep one authoritative patch series.
   Archive old patches separately.

6. USE THE PR DIFF AS REALITY CHECK
   Review the PR diff before merging.
   If too large or touches unexpected areas, reject and request narrower patch.

7. VERSION DISCIPLINE
   When a patch establishes new canon (v4.1, v4.2...), update version markers.
   Avoid calling two different states the same version.

===============================================================================
7) BEST PRACTICES FOR AI
===============================================================================

1. ASK CLARIFYING QUESTIONS
   If multiple interpretations would produce different diffs, stop and ask.
   Keep questions bounded (≤3) and preferably multiple-choice.

2. MAKE THE SMALLEST SAFE CHANGE
   Patch only sections required to satisfy the request.
   Do not refactor wording across entire document unless asked.

3. RESOLVE CONTRADICTIONS DELIBERATELY
   When replacing canon, remove obsolete text.
   If removal would harm context, consolidate by rewriting one unified section.

4. NEVER GUESS POLICY
   If something looks like a policy decision (budget, lanes, security),
   do not invent. Ask or quote existing canon.

5. KEEP MASTER HUMAN-READABLE
   Final doc should read like a single cohesive plan.
   Avoid "patch-note voice" in main body; put it only in logs.

===============================================================================
8) AUTHORIZATION FOR MAJOR CHANGES
===============================================================================

Some changes require explicit authorization before patching.

8.1 WHAT COUNTS AS MAJOR
------------------------
A change is MAJOR if it:

  A. Alters project scope or mission
     - Shifting from "patch compiler" to "truth engine"
     - Introducing new long-term objectives

  B. Changes core architecture
     - Compute tier redesign
     - Pipeline stage changes
     - Storage model changes

  C. Changes security or trust boundaries
     - Token storage policy
     - Protected zones
     - Bypassing human review

  D. Changes workflow automation
     - How patches are discovered or applied
     - PR creation process

  E. Large-scale reorganization
     - Renumbering major sections
     - Rewriting >25% of document

8.2 REQUIRED BEHAVIOR FOR MAJOR CHANGES
---------------------------------------
If the request appears MAJOR, stop before writing a patch.

Output an authorization request:

    AUTHORIZATION REQUIRED:
    - Proposed major change: <one sentence>
    - Affected areas: <list of sections>
    - Risk: <one sentence>
    Authorize this major patch? (YES/NO)

Only if user replies YES may you proceed with the patch.

8.3 MINOR CHANGES (NO AUTHORIZATION)
------------------------------------
Minor changes include:
  - Clarifying wording without altering meaning
  - Fixing contradictions where newer canon is clear
  - Typo fixes, formatting, consistency
  - Small subsections explicitly requested

For minor changes, output the patch immediately.

===============================================================================
9) AI PROMPT TEMPLATE
===============================================================================

Use this prompt when requesting a patch:

---BEGIN PROMPT---

YOU ARE: FUTILITY'S — MASTER PATCH AUTHOR

CONTEXT:
- The canonical spec is in docs/MASTER.md.
- All changes MUST be proposed as a git unified diff patch.
- Later canon overrides earlier canon. Remove conflicting text.
- Do NOT add scope or invent new ideas. Only implement the requested change.
- Output MUST be ONLY a unified diff patch (no commentary).

TASK (what I want changed):
<PASTE CHANGE REQUEST HERE>

INPUT (current docs/MASTER.md):
<PASTE ENTIRE DOCS/MASTER.MD HERE>

OUTPUT REQUIREMENTS:
- Output ONLY a unified diff beginning with:
  diff --git a/docs/MASTER.md b/docs/MASTER.md
- Make minimal necessary edits.
- Ensure final document is cohesive and non-contradicting.
- Update the change log.
- Do not modify other files.

NOW PRODUCE THE PATCH.

---END PROMPT---

===============================================================================
10) NON-NEGOTIABLE CONSTRAINTS (SUMMARY)
===============================================================================

- One file: docs/MASTER.md (unless explicitly told otherwise)
- One output: a single valid unified diff patch
- No scope creep
- Remove/replace superseded ideas (no contradictions)
- Update change log
- No secrets
- Request authorization for major changes

===============================================================================
END PATCH MANUAL
===============================================================================
