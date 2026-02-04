===============================================================================
FUTILITY'S — SSOT ENGINE SPECIFICATION (MASTER v4.0)
===============================================================================

Purpose: Capture messy human input, verify claims through gates, publish
         audited operational knowledge as Single Source of Truth.

Scope: Factory knowledge management system with Git as initial substrate.

Owner: Gondor

===============================================================================
0) PRIME DIRECTIVES (NON-NEGOTIABLE)
===============================================================================

D0.1  Single interface: users interact with ONE chat endpoint (Conductor).
D0.2  Conversation is untrusted input. Truth exists only as compiled artifacts.
D0.3  Human authority is sacred. AI proposes; humans verify and approve.
D0.4  Confirm screen required before any publication.
D0.5  Executor is deterministic code. LLMs never run Git directly.
D0.6  Budgeted escalation applies to compute only, NEVER to mechanic usage.
D0.7  Full auditability: every attempt produces a trace, even failures.

===============================================================================
1) SSOT DATA MODEL
===============================================================================

SSOT is a DATABASE of verified facts, not a document.

1.1 SSOT TIERS
--------------
SSOT-Verified:
  - Multiple independent sources, OR
  - Mechanic quorum + supervisor approval, OR
  - Physical evidence (nameplate, test result, photo)
  - Display: clean, no caveats

SSOT-Standing:
  - Single credible source, unchallenged
  - Display: marked "(single source)"
  - Promotable to Verified when corroborated

Both tiers are treated as truth. The marker is transparency about provenance.

1.2 TRIBAL KNOWLEDGE (OPTIONAL FUTURE)
--------------------------------------
Unverified but useful information:
  - Tips, observations, hearsay
  - Clearly labeled "unverified"
  - Searchable but excluded from Field Guide
  - Promotable to SSOT when evidence accumulates

1.3 FACT STRUCTURE
------------------
Every SSOT fact contains:
  - claim_text: The verified statement
  - asset_id: Linked canonical asset (if applicable)
  - confidence_tier: Verified | Standing
  - sources: List of capture IDs that support this fact
  - created_at, updated_at: Timestamps
  - disputed: Boolean (if under challenge)

===============================================================================
2) INTAKE SOURCES
===============================================================================

CRITICAL: Adoption is the biggest hurdle. Input methods must be EASY — old
grumpy mechanic easy. Hands are dirty, time is short, patience is zero.

2.1 VOICE INPUT (MVP REQUIRED)
------------------------------
- Primary intake method — talk, don't type
- Uses browser Web Speech API (Chrome/Safari mobile)
- Big microphone button, one tap to start
- Transcribes to text field for review before submit
- Works without internet (browser-native)
- Fallback: type manually

2.2 PHOTO CAPTURE (MVP REQUIRED)
--------------------------------
- Direct camera access from mobile browser
- One tap to open camera, snap, submit
- Use for: nameplates, gauges, problems, parts
- OCR extracts text (nameplates, labels)
- Original photo always preserved
- Links to asset automatically when possible

2.3 CHAT/TEXT MESSAGES
----------------------
- Secondary intake method (for those who prefer typing)
- Captured verbatim with timestamp and user ID
- Processed for claim extraction
- Original text always preserved

2.4 DOCUMENT UPLOADS (PDF, TXT, etc.)
--------------------------------------
- Text extracted via OCR (scanned) or direct extraction (digital)
- Chunked into logical sections
- Each section becomes a capture with source = "Document X, pages Y-Z"
- ORIGINAL FILE ALWAYS PRESERVED and retrievable
- Claims extracted from sections go through normal evaluation

2.5 CAPTURE STRUCTURE
---------------------
Every capture contains:
  - capture_id: Unique identifier (CAP-XXXXX)
  - raw_input: Original text/file reference
  - input_type: chat | document | photo
  - user_id: Who submitted
  - timestamp: When submitted
  - extracted_claims: Structured claims derived from input
  - asset_links: Resolved asset references
  - file_reference: Path to original file (if applicable)

===============================================================================
3) ASSET RESOLUTION
===============================================================================

3.1 ASSET RESOLVER (REQUIRED PRE-PIPELINE STEP)
-----------------------------------------------
Before any claim evaluation:
  - Normalizes messy references ("the red pump" → PUMP-247-A)
  - Resolves aliases, nicknames, locations
  - Links to canonical asset IDs
  - Creates new asset stubs when unknown equipment mentioned

Asset Resolver does NOT:
  - Assert truth
  - Evaluate claims
  - Make verification decisions

Asset Resolver DOES:
  - Improve context quality
  - Enable fact accumulation per asset
  - Reduce orphan fragments

3.2 ASSET STRUCTURE
-------------------
Every asset contains:
  - asset_id: Canonical identifier
  - aliases: Known nicknames/references
  - asset_type: pump | motor | tank | chiller | etc.
  - location: Physical location (if known)
  - facts: Linked SSOT facts about this asset
  - photos: Linked photos
  - documents: Linked source documents
  - status: active | decommissioned | unknown

===============================================================================
4) PROCESSING PIPELINE
===============================================================================

    Intake
       ↓
    Asset Resolution
       ↓
    Stage 1: INTERPRET (claim extraction, hypothesis building)
       ↓
    Stage 2: GATE (confidence scoring, risk assessment)
       ↓
    Stage 3: FIT (validation, sandbox testing if code-related)
       ↓
    CONFIRM SCREEN (human review required)
       ↓
    EXECUTOR (deterministic publication)
       ↓
    SSOT DATABASE + AUDIT TRAIL

4.1 STAGE 1: INTERPRET
----------------------
- Extracts explicit claims from capture
- Identifies assets mentioned
- Produces structured ClaimProposal:
  * claim_text
  * asset_references
  * evidence_type (observation | hearsay | document | measurement)
  * confidence_estimate
- May ask ≤3 bounded questions (see Question Discipline)

4.2 STAGE 2: GATE
-----------------
- Assesses claim confidence
- Checks for contradictions with existing SSOT
- Evaluates evidence strength
- Produces GateVerdict:
  * PASS / FAIL / NEEDS_REVIEW
  * confidence_level: C0-C3
  * contradiction_flags
  * escalation_recommendation

Confidence Levels:
  C0: Intent unclear, needs questions
  C1: Claim understood, insufficient evidence
  C2: Reasonable evidence, likely accurate
  C3: Strong evidence, ready for SSOT

4.3 STAGE 3: FIT
----------------
- Validates claim fits existing knowledge structure
- For code/config changes: sandbox apply and test
- Generates preview of what will change
- Produces ExecutionRequest:
  * final_claim
  * affected_assets
  * confidence_level
  * change_preview

4.4 CONFIRM SCREEN
------------------
Required before any SSOT modification.

Must display:
  - Claim summary (what will be added/changed)
  - Evidence summary (where this came from)
  - Affected assets
  - Confidence level + reasoning
  - Contradiction warnings (if any)

Buttons:
  - APPROVE: Add to SSOT
  - DISPUTE: Flag for review
  - REVISE: Return for more evidence
  - CANCEL: Discard

4.5 EXECUTOR
------------
Deterministic publication:
  - Writes fact to SSOT database
  - Links to source captures
  - Updates asset records
  - Records full audit trail
  - For Git-based changes: branch → commit → PR

===============================================================================
5) OUTPUTS
===============================================================================

5.1 SSOT EXPLORER (PRIMARY)
---------------------------
Full database interface:
  - Browse by asset type, location, date
  - Search across all facts
  - Filter by confidence tier, source type
  - View any fact's full capture chain
  - Access original documents/photos

For each asset, shows:
  - All verified facts
  - Knowledge gaps (what's unknown)
  - Linked photos and documents
  - Dispute status

5.2 FIELD GUIDE (EMBEDDED VIEW)
-------------------------------
Curated view for quick reference:
  - Shows only publishable assets (sufficient facts)
  - Organized by equipment type/area
  - Specs, procedures, known issues
  - Strips out low-value facts

Embedded WITHIN SSOT Explorer:
  - Default view shows Field Guide content
  - "Show all SSOT" expands to raw facts
  - Same URL, different detail level

Exportable to Obsidian:
  - Mobile-friendly format
  - Just the meat and potatoes
  - Links back to Explorer for more detail

Publication Threshold:
  - Asset has positive identification
  - At least 3 verified facts
  - At least one useful fact (spec, procedure, failure mode)

5.3 BULLETIN BOARD
------------------
AI-generated analysis (clearly labeled):
  - Trends ("Chiller issues up 40% this month")
  - Knowledge gaps ("No specs recorded for Area C pumps")
  - Near-misses and safety observations
  - Training topics based on common questions

Rules:
  - Explicitly labeled as AI analysis
  - Links to supporting SSOT facts
  - Updated periodically (daily/weekly)
  - Not authoritative, just informative

===============================================================================
6) QUESTION DISCIPLINE
===============================================================================

Mechanics have ~5 seconds of patience. Respect it.

6.1 QUESTION VALUE SCORING
--------------------------
Before asking any question, compute score:
  +2 if answer is observable right now
  +2 if answer splits hypotheses (changes next step)
  +1 if low effort (yes/no, multiple choice)
  −2 if user just said "don't know" or "just noticed"
  −2 if requires measurement, lookup, or memory

Ask ONLY if score ≥ 3.

6.2 QUESTION BUDGET
-------------------
- Max 1-2 questions per interaction
- Prefer multiple choice over open-ended
- Never chain more than one follow-up round
- If still uncertain: escalate to model reasoning, not more questions

6.3 DON'T ASK — INFER
---------------------
If the system can infer from:
  - Asset type and known failure modes
  - Historical data for this equipment
  - Similar past cases

→ Infer and label it as inference. Don't ask.

Example:
  "This pump type has a history of cavitation when suction strainers clog.
   That's one likely cause." (No question needed)

===============================================================================
7) DISPUTE MECHANISM
===============================================================================

Any SSOT fact can be disputed, including "official" sources.

7.1 FILING A DISPUTE
--------------------
Any mechanic can dispute any fact:
  - Select fact
  - State disagreement
  - Optionally provide counter-evidence

Disputed facts are marked but not removed.

7.2 DISPUTE RESOLUTION
----------------------
Resolution paths:
  1. Supervisor reviews and decides
  2. Counter-evidence proves original wrong
  3. Mechanic quorum agrees with dispute

Resolution actions:
  - Uphold: Original fact remains, dispute recorded
  - Revise: Fact updated with new information
  - Remove: Fact removed from SSOT (audit trail kept)

7.3 MANUFACTURER OVERRIDE
-------------------------
Official documents (manuals, specs) can be wrong for site conditions.
Dispute mechanism allows site-specific overrides:
  - Original: "Change oil every 1000 hours" (manufacturer)
  - Override: "Change oil every 500 hours" (site-specific, approved)
  - Both recorded, override takes precedence

===============================================================================
8) MECHANIC FEEDBACK
===============================================================================

8.1 INTERACTION FEEDBACK
------------------------
After every bot response:
  [👍] [👎] [Add comment...]

Rules:
  - Zero effort required
  - Never mandatory
  - No rewards (prevents gaming)
  - Anonymous aggregation

8.2 FEEDBACK USAGE
------------------
Aggregated for:
  - Identifying bad bot behavior patterns
  - Improving prompts and rules
  - Weekly summary reports
  - Bad Behavior Log maintenance

8.3 MECHANIC VOTING ON CLAIMS
-----------------------------
Scale (1-5):
  1 = Absolutely wrong
  2 = Looks wrong
  3 = Unsure / maybe
  4 = Seems right
  5 = Absolutely correct

Votes influence:
  - Confidence scoring
  - Review priority
  - Promotion eligibility

Votes never directly edit SSOT.

===============================================================================
9) COMPUTE AND ESCALATION
===============================================================================

CRITICAL: Budget applies to ESCALATION ONLY, never to mechanic usage.
Mechanics may interact 24/7 without restriction.

9.1 ESCALATION TIERS
--------------------
Tier 0: CONTROL PLANE (always-on, ~2GB droplet)
  - UI, auth, job queue, orchestration
  - Asset resolution, basic claim extraction
  - No heavy inference
  - Cost: ~$12/month fixed

Tier 1: API (cheap model)
  - Simple interpretation tasks
  - Claude Haiku / GPT-4o-mini
  - Cost: ~$0.001 per request

Tier 2: API (capable model)
  - Complex reasoning, Panel Review
  - Claude Sonnet
  - Cost: ~$0.02 per request

Tier 3: GPU BURST (future, if needed)
  - Runpod for local large model inference
  - Only if API costs become prohibitive
  - Requires explicit approval

9.2 ESCALATION LOGIC
--------------------
Default path:
  1. Try Tier 0 (deterministic, rule-based)
  2. If uncertain: Tier 1 (cheap API)
  3. If still uncertain: Tier 2 (capable API)
  4. If blocked: surface to human, don't guess

WorthItScore (for Tier 2+):
  (ExpectedGain × RiskWeight) / EstimatedCost
  - Threshold increases as budget depletes
  - Tier 2+ requires score above threshold OR explicit approval

9.3 BUDGET CAPS (CONFIGURABLE)
------------------------------
Default daily caps:
  - Tier 1 (cheap API): $2.00/day
  - Tier 2 (capable API): $2.00/day
  - Tier 3 (GPU): $1.00/day (when enabled)
  - Total: $5.00/day

Overages require explicit approval on Confirm Screen.

===============================================================================
10) STORAGE MODEL
===============================================================================

10.1 DATABASE
-------------
SQLite for MVP (upgradeable to PostgreSQL later).

Tables:
  - captures (raw intake)
  - claims (extracted claims)
  - facts (verified SSOT)
  - assets (equipment registry)
  - disputes (challenges to facts)
  - votes (mechanic feedback)
  - audit_log (all actions)
  - jobs (processing state)

10.2 ARTIFACT STORAGE
---------------------
Original files stored on disk or object storage:
  /var/lib/futilitys/artifacts/
    ├── documents/
    │   └── <doc_id>/<original_filename>
    ├── photos/
    │   └── <photo_id>/<original_filename>
    └── exports/
        └── <export_id>/

Database stores references, files stored separately.

10.3 ESTIMATED STORAGE
----------------------
- 200 PDFs × 20MB = 4GB
- 1000 photos × 2MB = 2GB
- Database + metadata = <1GB
- Total: ~10GB for substantial deployment
- Cost: ~$0.50/month on object storage

===============================================================================
11) SAFETY AND SECURITY
===============================================================================

11.1 PROTECTED ZONES
--------------------
Higher confidence required for:
  - Executor code changes
  - Auth configuration
  - Automation workflows
  - Budget/policy settings

11.2 HARD RULES
---------------
- Secrets never committed to Git
- No direct push to main (PR only)
- No history rewriting
- Job serialization lock (prevent race conditions)
- Size limits on uploads

11.3 SSOT AUDITOR (FUTURE)
--------------------------
Governance role that:
  - Monitors SSOT changes and promotions
  - Watches for drift, shortcuts, unjustified certainty
  - Can flag/block but cannot approve
  - Enforces "compiled truth only" discipline

===============================================================================
12) AI CURATION RULES
===============================================================================

AI may organize and present SSOT content for human consumption.

12.1 ALLOWED OPERATIONS
-----------------------
- Group: Put related facts together
- Order: Arrange by logical priority
- Format: Convert bullets to tables, etc.
- Summarize (extractive): "3 failures logged" with links
- Hide: Exclude low-value content from Field Guide
- Label: Add metadata like "last updated"

12.2 PROHIBITED OPERATIONS
--------------------------
- Infer cause: "Probably failed due to..."
- Add context: "This type typically..."
- Merge contradictions: Pick one of conflicting facts
- Extrapolate: "If this, then probably..."
- Invent: Any statement not traceable to SSOT

12.3 THE KEY TEST
-----------------
Can every sentence in the output link back to specific SSOT facts?
  - If yes: allowed
  - If no: prohibited

===============================================================================
13) BAD BEHAVIOR CORRECTION
===============================================================================

13.1 BAD BEHAVIOR LOG
---------------------
Track patterns of unwanted AI behavior:
  - "Kept asking about color when I needed specs"
  - "Assumed electrical failure without evidence"
  - "Used nickname instead of asset ID"

13.2 RULE INJECTION
-------------------
Patterns become explicit rules:
  - "Do not ask about physical appearance unless relevant"
  - "Never assume failure mode without evidence"
  - "Always use asset ID, nicknames in parentheses only"

Rules injected into system prompts.

13.3 REVIEW CYCLE
-----------------
Weekly:
  - Review 👎 feedback
  - Identify patterns
  - Add/update rules
  - Test improvements

===============================================================================
CHANGE LOG
===============================================================================
v4.0 (2026-02-04): Complete consolidation
  - Unified SSOT data model (Verified + Standing tiers)
  - Added document/photo intake with original preservation
  - Added Asset Resolver as required step
  - Added Question Value Scoring system
  - Added Dispute mechanism for challenging facts
  - Added Mechanic feedback (👍👎) system
  - Simplified escalation (API-first, GPU optional)
  - Added AI Curation rules
  - Added Bad Behavior correction system
  - Consolidated from multiple scattered documents

v3.4: PatchOps + DiffPreview hybrid, SQLite storage, gh CLI
v3.3: Runpod Lane 3, WorthItScore, $5/day budget
v3.2: Segregated sandbox, helper worker constraints
v3.1: Compute ladder formalization

===============================================================================
END MASTER v4.0
===============================================================================
