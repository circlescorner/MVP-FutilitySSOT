# FILE: docs/USAGE_AI_PATCH_AUTHOR.md
# Futility’s — MASTER Patch Author Manual (for AI + humans)

This file teaches an AI (and any collaborator) how to propose changes to the canonical spec in `docs/MASTER.md`
using **real git unified-diff patches** that can be applied by the repo’s GitHub Actions workflow.

-------------------------------------------------------------------------------

## 0) What this system is

- `docs/MASTER.md` is the **canonical** specification document.
- Changes are not made by direct manual editing.
- Changes are proposed as **unified diff patch files** (`*.patch`) committed to the repo.
- GitHub Actions automatically:
  - normalizes master filename (if needed)
  - applies patches sequentially
  - opens a PR that updates `docs/MASTER.md`
- A human reviews the PR and merges it.

Goal: evolve the MASTER into a single cohesive, human-readable document that reflects the latest canon.

-------------------------------------------------------------------------------

## 1) Canon rules for changes (AI MUST FOLLOW)

### R1 — No scope creep
Do NOT add new goals, new systems, or new features not requested by the user.
You may only:
- clarify wording
- reorganize structure (when requested)
- correct contradictions
- integrate new canon decisions the user explicitly provides
- remove superseded concepts when later canon overrides them

### R2 — Later canon overrides earlier canon
If a new change conflicts with older text, you MUST:
- remove or replace the older conflicting text
- ensure the final `docs/MASTER.md` reads as one cohesive thought

Do NOT “append and leave contradictions.”

### R3 — Minimal necessary change
Prefer the smallest diff that achieves the requested change.
Avoid rewriting unrelated sections.

### R4 — Deterministic, patchable edits
Your output MUST be a valid unified diff patch that applies using `git apply`.
The patch MUST target `docs/MASTER.md` only, unless the user explicitly requests other files.

### R5 — Update the end-of-document logs
At the end of `docs/MASTER.md`, there is a required section for:
- Change Summary
- Parts Removed / Superseded

Any patch that alters content MUST update those logs with concise entries.

### R6 — Do not include secrets
Never include passwords, tokens, private keys, or personal identifying information.
Never invent credentials.

-------------------------------------------------------------------------------

## 2) Required patch output format (AI MUST OUTPUT ONLY THIS)

Your response MUST be a single unified diff patch, starting with:

diff --git a/docs/MASTER.md b/docs/MASTER.md

The patch must include valid hunk headers like:

@@ -old_line,old_count +new_line,new_count @@

Do not include explanation text before or after the diff.
Do not wrap the diff in narrative.
Do not output multiple alternative patches.

-------------------------------------------------------------------------------

## 3) Patch naming & sequencing rules (repo convention)

Patches are applied in numeric order. Use a 4-digit prefix:

- 0001-...
- 0002-...
- 0003-...

For new patches, choose the next number:

- 0005-master-v3.5.patch
- 0006-master-clarify-lanes.patch

Patches should live in the repo root (unless the repo policy changes later).

-------------------------------------------------------------------------------

## 4) How to design a good patch (AI guidance)

### Step A — Read the user request carefully
Extract the exact change requested.
Do not assume additional desired changes.

### Step B — Read the entire `docs/MASTER.md`
Identify:
- which section(s) contain the relevant content
- what text must be removed/replaced to avoid contradictions
- whether the requested change affects headings, definitions, or policies

### Step C — Plan the minimal diff
Common safe edit patterns:
1) Replace a paragraph under a section
2) Replace an entire numbered section body (keep header)
3) Delete a conflicting subsection and integrate the updated canon in one place
4) Add a new short subsection only if needed to preserve coherence

### Step D — Implement the diff
- Keep edits localized
- Maintain the doc’s style/voice
- Ensure the final document reads naturally
- Update end-of-document logs

### Step E — Sanity check (AI self-check before output)
- Does the patch only touch docs/MASTER.md?
- Does it remove/replace any conflicting older content?
- Does it keep the document cohesive?
- Does it update Change Summary and Parts Removed / Superseded?
- Is the diff valid unified format?

-------------------------------------------------------------------------------

## 5) Copy/paste prompt to use with an AI (user will paste full MASTER)

Use this prompt verbatim (fill in the placeholders):

---BEGIN AI PROMPT---

YOU ARE: FUTILITY’S — MASTER PATCH AUTHOR

CONTEXT:
- The canonical spec is in docs/MASTER.md.
- All changes MUST be proposed as a REAL git unified diff patch that applies with: git apply
- Later canon overrides earlier canon. If you change a concept, you MUST remove or replace older conflicting text.
- Do NOT add scope or invent new ideas. Only implement my requested change.
- Output MUST be ONLY a unified diff patch for docs/MASTER.md (no commentary).

TASK (what I want changed):
<PASTE THE CHANGE REQUEST HERE>

INPUT (entire current docs/MASTER.md):
<PASTE ENTIRE docs/MASTER.md HERE>

OUTPUT REQUIREMENTS:
- Output ONLY a unified diff beginning with:
  diff --git a/docs/MASTER.md b/docs/MASTER.md
- Make minimal necessary edits.
- Ensure the final document is cohesive and non-contradicting.
- Update the end-of-document logs:
  - Change Summary
  - Parts Removed / Superseded
- Do not modify other files.

NOW PRODUCE THE PATCH.

---END AI PROMPT---

-------------------------------------------------------------------------------

## 6) Example “good change request” phrasing (helps AI produce clean diffs)

- “Unify the compute ladder into one canon definition and remove the older duplicate ladder text.”
- “Rewrite the confirm screen section to include approval toggles for paid escalation.”
- “Replace the budget caps paragraph to reflect the updated $5/day split while keeping the rest unchanged.”
- “Remove contradictory Lane 2 descriptions and keep only the newer policy wording.”

-------------------------------------------------------------------------------

## 7) Non-negotiable constraints recap (AI TL;DR)

- One file: docs/MASTER.md
- One output: a single valid unified diff patch
- No scope creep
- Remove/replace superseded ideas (no contradictions)
- Update end-of-document logs
- No secrets

-------------------------------------------------------------------------------
# End of AI Patch Author Manual