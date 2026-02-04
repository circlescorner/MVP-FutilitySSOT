# APPEND TO: docs/USAGE_AI_PATCH_AUTHOR.md
# SECTION: Best Practices + Authorization Gates (REQUIRED)

-------------------------------------------------------------------------------

## 8) Best practices for keeping the system aligned (for humans + AI)

This system stays stable only if changes are made deliberately and consistently.

### 8.1 Human best practices (user / maintainers)

1) **One intention per patch**
   - Each patch should have one clear goal (clarify X, unify Y, update Z).
   - Avoid “mega-patches” that touch many unrelated sections.

2) **Prefer replace-over-append when canon evolves**
   - If newer language supersedes older language, remove the old language.
   - Do not leave multiple “canon versions” inside the document.

3) **Keep structure predictable**
   - Preserve the top-level numbered sections unless you explicitly decide to reorganize.
   - If you reorganize, do it in a dedicated patch and document the reason in the logs.

4) **Maintain a clean Change Summary + Superseded log**
   - Every meaningful patch must update:
     - Change Summary (what changed)
     - Parts Removed / Superseded (what was removed and why)
   - These logs are the human audit trail. Keep entries short and factual.

5) **Avoid duplicate patch files**
   - Keep only one authoritative patch series in the repo root.
   - Archive old “patch words” files separately (do not keep multiple competing `.patch` files with similar names in root).

6) **Use the PR diff as the reality check**
   - Always review the PR diff before merging.
   - If the diff is too large or touches unexpected areas, reject and request a narrower patch.

7) **Version discipline**
   - When a patch establishes new canon (v3.5, v3.6…), update the master’s version markers consistently.
   - Avoid half-version ambiguity (don’t call two different states “v3.4”).

8) **Do not allow unreviewed auto-merge**
   - This repo’s workflow creates PRs only.
   - Keep it that way unless you explicitly decide to enable auto-merge later.

### 8.2 AI best practices (AI MUST FOLLOW)

1) **Ask clarifying questions when the request is under-specified**
   - If multiple interpretations would produce different diffs, stop and ask.
   - Keep questions bounded (<=3) and preferably multiple-choice.

2) **Make the smallest safe change**
   - Patch only the sections required to satisfy the user’s request.
   - Do not refactor wording across the entire document unless asked.

3) **Resolve contradictions deliberately**
   - When replacing canon, remove the obsolete text.
   - If removal would harm context, consolidate by rewriting one unified section.

4) **Never guess policy**
   - If something looks like a policy decision (budget, lanes, security stance, workflow rules),
     do not invent. Ask or quote existing canon.

5) **Keep MASTER human-readable**
   - The final doc should read like a single cohesive plan.
   - Avoid “patch-note voice” in the main body; put patch-note voice only in the logs.

-------------------------------------------------------------------------------

## 9) Authorization gate for major changes (NON-NEGOTIABLE)

This system requires explicit authorization before applying major changes.
AI MUST ask for authorization before outputting a patch if the requested change is “major.”

### 9.1 What counts as a “major change” (MajorChangeClass)

A change is MAJOR if it does any of the following:

A) **Alters the project’s scope or mission**
- example: shifting from “patch compiler” into “truth engine”
- example: introducing new long-term objectives not already in MASTER

B) **Changes core architecture or control semantics**
- compute ladder redesign (lane meanings, what runs where)
- confirm/go semantics (what GO does, merge policy)
- stage contracts (outputs, gates, confidence levels)

C) **Changes security posture or trust boundaries**
- token storage policy changes
- protected zones changes
- changes that would allow automation to bypass human review

D) **Changes the workflow automation contract**
- patch discovery rules
- patch sequencing rules
- anything that changes how GitHub Actions applies patches or creates PRs

E) **Large-scale reorganization**
- renumbering or restructuring major sections (Option 1B style changes)
- rewriting more than ~25% of the document in one patch

### 9.2 Required AI behavior for MajorChangeClass

If the request appears MAJOR, AI MUST:

1) STOP before writing a patch.
2) Output ONLY a short authorization request containing:
   - a 1–2 sentence description of the detected major change
   - the exact areas it will affect (sections/headings)
   - the risk of proceeding without confirmation
   - a YES/NO question to authorize the patch

Format for the authorization request (AI MUST follow):

AUTHORIZATION REQUIRED:
- Proposed major change: <one sentence>
- Affected areas: <list of sections/headings>
- Risk: <one sentence>
Authorize this major patch? (YES/NO)

Only if the user replies YES may the AI proceed to output the unified diff patch.

### 9.3 Minor changes (no authorization required)

Minor changes include:
- clarifying wording without altering meaning
- fixing contradictions where newer canon is already clearly stated
- typo fixes, formatting, consistency edits
- adding a small subsection that the user explicitly requested and that does not alter scope/architecture

For minor changes, AI may output the patch immediately (still must follow all other rules).

-------------------------------------------------------------------------------

## 10) Optional safety: “Major Change Marker” (human helper)

For large changes, the user may include this line in their request:

MAJOR_CHANGE_AUTH_REQUIRED: YES

When present, AI MUST treat the request as MajorChangeClass even if it might otherwise be borderline.

-------------------------------------------------------------------------------
# End of Best Practices + Authorization Gates