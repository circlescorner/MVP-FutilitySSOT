===============================================================================
FUTILITY'S — ROADMAP
===============================================================================

This document describes the implementation phases and capability evolution
of Futility's from initial prototype to full SSOT engine.

===============================================================================
PART A: IMPLEMENTATION PHASES (GRANULAR, ACHIEVABLE)
===============================================================================

-------------------------------------------------------------------------------
PHASE 0: INFRASTRUCTURE FOUNDATION
-------------------------------------------------------------------------------
Status: [ ] Pending
Goal: Empty but configured server, accessible via HTTPS

Deliverables:
  [ ] DigitalOcean droplet provisioned (~2GB)
  [ ] Domain configured with HTTPS (circlescorner.xyz or similar)
  [ ] Basic SSH access verified
  [ ] Git repository connected
  [ ] Tailscale configured for admin access

Success criteria:
  - Can SSH to server
  - HTTPS responds at domain
  - Git clone/push works

Estimated cost: ~$12/month (droplet) + ~$1/month (domain)

-------------------------------------------------------------------------------
PHASE 1: FUNCTIONAL BAREBONES
-------------------------------------------------------------------------------
Status: [→] CURRENT
Goal: Minimal working input → process → PR pipeline

Deliverables:
  [ ] Private login system (PIN auth)
  [ ] HTTPS web interface skeleton
  [ ] Text input acceptance (chat box)
  [ ] File upload acceptance (documents, photos)
  [ ] Basic text normalization (no LLM required)
  [ ] Git branch creation
  [ ] Commit generation
  [ ] PR opening via gh CLI
  [ ] Basic audit logging (who submitted what, when)

Success criteria:
  - User can log in with PIN
  - User can paste text or upload file
  - System creates a PR with submitted content
  - Audit log shows the submission

Note: No LLM required. This proves the pipeline works.

-------------------------------------------------------------------------------
PHASE 2: DEV SANDBOX
-------------------------------------------------------------------------------
Status: [ ] Pending
Goal: Isolated environment for testing changes

Deliverables:
  [ ] Docker container OR separate droplet for sandbox
  [ ] Fresh clone capability (isolated from production)
  [ ] Change testing before PR creation
  [ ] Format/lint checks (if applicable)
  [ ] Sandbox success required before PR

Success criteria:
  - Changes tested in sandbox before PR
  - Sandbox failure blocks PR creation
  - Production system unaffected by sandbox operations

Note: This becomes "staging" once system is stable.

-------------------------------------------------------------------------------
PHASE 3: CLAIM EXTRACTION (ADD AI)
-------------------------------------------------------------------------------
Status: [ ] Pending
Goal: AI-assisted interpretation of input

Deliverables:
  [ ] API integration (Claude Haiku or similar)
  [ ] Claim extraction from text input
  [ ] Asset mention detection
  [ ] Structured ClaimProposal output
  [ ] Confidence estimation
  [ ] Question generation (when needed)

Success criteria:
  - Input text produces structured claims
  - Assets are identified and linked
  - Confidence levels assigned
  - Questions are relevant and bounded

-------------------------------------------------------------------------------
PHASE 4: ASSET RESOLUTION
-------------------------------------------------------------------------------
Status: [ ] Pending
Goal: Normalize messy references to canonical assets

Deliverables:
  [ ] Asset database (SQLite)
  [ ] Alias/nickname tracking
  [ ] Location tracking
  [ ] Asset creation from new mentions
  [ ] Reference normalization ("red pump" → PUMP-247-A)

Success criteria:
  - Messy references resolve to asset IDs
  - New equipment creates asset stubs
  - Aliases accumulate over time

-------------------------------------------------------------------------------
PHASE 5: SSOT DATABASE
-------------------------------------------------------------------------------
Status: [ ] Pending
Goal: Persistent storage for verified facts

Deliverables:
  [ ] SQLite database schema
  [ ] Captures table (raw intake)
  [ ] Claims table (extracted claims)
  [ ] Facts table (verified SSOT)
  [ ] Assets table (equipment registry)
  [ ] Audit log table
  [ ] Full capture chain linkage

Success criteria:
  - All data persists across restarts
  - Capture → Claim → Fact chain is queryable
  - Audit trail is complete

-------------------------------------------------------------------------------
PHASE 6: VERIFICATION GATES
-------------------------------------------------------------------------------
Status: [ ] Pending
Goal: Confidence scoring and human review

Deliverables:
  [ ] Confidence scoring (C0-C3)
  [ ] Contradiction detection
  [ ] Confirm Screen UI
  [ ] Approval workflow
  [ ] Dispute mechanism
  [ ] SSOT-Verified vs SSOT-Standing tiers

Success criteria:
  - Claims require approval before becoming facts
  - Contradictions are flagged
  - Disputes can be filed and resolved

-------------------------------------------------------------------------------
PHASE 7: SSOT EXPLORER
-------------------------------------------------------------------------------
Status: [ ] Pending
Goal: Browse and search all SSOT content

Deliverables:
  [ ] Web interface for browsing SSOT
  [ ] Filter by asset type, location, date
  [ ] Search across all facts
  [ ] View capture chains
  [ ] Access original documents/photos
  [ ] Field Guide embedded view

Success criteria:
  - All SSOT content is browsable
  - Can drill into any fact's sources
  - Original files are retrievable

-------------------------------------------------------------------------------
PHASE 8: DOCUMENT/PHOTO INTAKE
-------------------------------------------------------------------------------
Status: [ ] Pending
Goal: Accept and process documents and photos

Deliverables:
  [ ] PDF text extraction (OCR for scans)
  [ ] Photo OCR (nameplates, labels)
  [ ] Original file preservation
  [ ] Chunking large documents
  [ ] Linking extracted content to assets
  [ ] File retrieval interface

Success criteria:
  - PDFs uploaded and text extracted
  - Photos processed for text content
  - Original files always retrievable
  - Extracted claims go through normal pipeline

-------------------------------------------------------------------------------
PHASE 9: OBSIDIAN EXPORT
-------------------------------------------------------------------------------
Status: [ ] Pending
Goal: Mobile-friendly Field Guide export

Deliverables:
  [ ] Obsidian vault generation
  [ ] Curated content selection
  [ ] Mobile-friendly formatting
  [ ] Links back to full Explorer
  [ ] Automated or on-demand export

Success criteria:
  - Obsidian vault contains Field Guide content
  - Usable on mobile devices
  - Updated when SSOT changes

-------------------------------------------------------------------------------
PHASE 10: MECHANIC FEEDBACK
-------------------------------------------------------------------------------
Status: [ ] Pending
Goal: Capture feedback on system performance

Deliverables:
  [ ] 👍👎 buttons on interactions
  [ ] Optional comment field
  [ ] Feedback aggregation
  [ ] Weekly summary reports
  [ ] Bad behavior pattern detection

Success criteria:
  - Feedback captured with zero effort
  - Patterns identified weekly
  - System improves based on feedback

-------------------------------------------------------------------------------
PHASE 11: BULLETIN BOARD
-------------------------------------------------------------------------------
Status: [ ] Pending
Goal: AI-generated analysis and trends

Deliverables:
  [ ] Trend detection across SSOT
  [ ] Knowledge gap identification
  [ ] Near-miss/safety observation highlighting
  [ ] Periodic report generation
  [ ] Clear "AI analysis" labeling

Success criteria:
  - Useful insights generated automatically
  - Clearly labeled as AI analysis
  - Based on SSOT facts

-------------------------------------------------------------------------------
PHASE 12: PROVE VIABILITY
-------------------------------------------------------------------------------
Status: [ ] Pending
Goal: Demonstrate system works end-to-end

Deliverables:
  [ ] End-to-end workflow runs reliably
  [ ] Budget enforcement working
  [ ] Confirm screen functional
  [ ] Protected zones enforced
  [ ] Error handling robust
  [ ] Documentation matches implementation

Success criteria:
  - System runs for a week without intervention
  - Multiple mechanics have used it
  - At least one useful fact in SSOT

-------------------------------------------------------------------------------
PHASE 13: STRESS TEST
-------------------------------------------------------------------------------
Status: [ ] Pending
Goal: Identify weaknesses under load

Deliverables:
  [ ] Bot agents simulating mechanic input
  [ ] Concurrent request handling tested
  [ ] Edge cases documented
  [ ] Performance bottlenecks identified
  [ ] Failure modes documented

Success criteria:
  - System handles expected load
  - Failure modes are understood
  - Recovery procedures documented

===============================================================================
PART B: CAPABILITY EVOLUTION (CONCEPTUAL STAGES)
===============================================================================

These stages describe what the system CAN DO, not implementation tasks.

-------------------------------------------------------------------------------
STAGE A: GIT PATCHER (Phases 0-5)
-------------------------------------------------------------------------------
What it does:
  - Accepts text input
  - Creates Git commits and PRs
  - Maintains audit trail

Trust model:
  - Human reviews every PR

Scope:
  - Git repositories only
  - No claim verification yet

-------------------------------------------------------------------------------
STAGE B: CLAIM VERIFICATION (Phases 6-7)
-------------------------------------------------------------------------------
What it does:
  - Extracts claims from input
  - Scores confidence
  - Detects contradictions
  - Requires approval for SSOT entry

Trust model:
  - Claims are verified before becoming facts
  - Disputes can challenge any fact

Scope:
  - Knowledge management begins
  - Still Git-backed

-------------------------------------------------------------------------------
STAGE C: DOCUMENT INTEGRATION (Phases 8-9)
-------------------------------------------------------------------------------
What it does:
  - Accepts PDFs and photos
  - Extracts text and links to assets
  - Preserves original files
  - Exports to Obsidian

Trust model:
  - Same verification for all sources
  - Original documents always accessible

Scope:
  - Factory documentation ingested
  - Mobile access via Obsidian

-------------------------------------------------------------------------------
STAGE D: OPERATIONAL SSOT (Phases 10-13)
-------------------------------------------------------------------------------
What it does:
  - Full SSOT with verification
  - Mechanic feedback integration
  - AI-generated analysis
  - Stress-tested for production use

Trust model:
  - Verified + Standing tiers
  - Continuous improvement via feedback
  - Human oversight maintained

Scope:
  - Factory-wide knowledge management
  - Daily operational use

-------------------------------------------------------------------------------
STAGE E: MATURE SSOT (FUTURE)
-------------------------------------------------------------------------------
What it does:
  - Predictive analysis
  - Automated knowledge gap detection
  - Integration with sensors/CMMS/ERP
  - Multi-factory support

Trust model:
  - Same core principles
  - Extended automation where safe

Scope:
  - Organizational memory
  - Cross-system integration

===============================================================================
REALISTIC TIMELINE EXPECTATIONS
===============================================================================

The first 3-6 months will feel like shouting into a void.

Month 1-2:
  - Infrastructure setup
  - Basic pipeline working
  - You're the only user
  - SSOT is nearly empty

Month 3-4:
  - Claim extraction working
  - Asset resolution improving
  - A few well-documented systems emerge
  - First demo to other mechanics

Month 5-6:
  - SSOT has real content
  - Field Guide is useful for some equipment
  - Word starts to spread (or doesn't)
  - You learn what works and what doesn't

Month 7+:
  - System proves value (or needs redesign)
  - Adoption grows (or stalls)
  - Knowledge compounds (or stagnates)

The value compounds over time. Early investment pays off later.

===============================================================================
FORK MILESTONE
===============================================================================

When Phase 12 is complete and system is stable:

  Branch A: Continue as factory SSOT tool
  Branch B: Generalize for other use cases (if desired)

Branch A is the goal. Branch B is optional future.

===============================================================================
ESTIMATED COSTS
===============================================================================

Infrastructure (monthly):
  - 2GB Droplet: $12
  - Domain: ~$1
  - Object storage (if used): $5
  Subtotal: ~$18/month

API costs (variable, depends on usage):
  - Light usage (10-20 requests/day): $5-15/month
  - Medium usage (50+ requests/day): $30-50/month
  Your $5/day cap = $150/month maximum

Realistic total: $25-50/month for meaningful usage.

===============================================================================
END ROADMAP
===============================================================================
