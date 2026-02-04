===============================================================================
FUTILITY'S — SINGLE SOURCE OF TRUTH ENGINE
===============================================================================

A system that compiles messy human conversation into audited, versioned,
and verified operational knowledge.

    Intake → Interpret → Gate → Fit → Confirm → Execute

-------------------------------------------------------------------------------
STATUS
-------------------------------------------------------------------------------

Phase: 1 (Functional Barebones)
Owner: Gondor
Substrate: Git (initial), Factory SSOT (target)

-------------------------------------------------------------------------------
WHAT THIS IS
-------------------------------------------------------------------------------

Epistemic infrastructure for factory operations.

- Captures information from chat, documents, and photos
- Extracts claims and links them to assets
- Routes claims through verification gates
- Publishes verified truth with full audit trail
- Provides mechanics with reliable, accessible information

The system automates responsibility, not answers.

-------------------------------------------------------------------------------
WHAT THIS IS NOT
-------------------------------------------------------------------------------

- Not a chatbot (chat is intake, not output)
- Not an auto-coder (humans review all changes)
- Not AI that decides truth (AI proposes, humans verify)
- Not a replacement for expertise (it captures and organizes expertise)

-------------------------------------------------------------------------------
DOCUMENTATION
-------------------------------------------------------------------------------

docs/MASTER.md        The canonical technical specification
docs/PRINCIPLES.md    Philosophy, ethics, and non-negotiable rules
docs/ROADMAP.md       Implementation phases and capability evolution
docs/PATCH_MANUAL.md  How to propose changes to the spec

-------------------------------------------------------------------------------
CORE CONCEPTS
-------------------------------------------------------------------------------

SSOT Database:
  All verified facts, stored with full provenance.
  Two tiers:
    - SSOT-Verified: Multiple sources or approved
    - SSOT-Standing: Single credible source, unchallenged

Outputs:
  - SSOT Explorer: Browse/search everything, drill into capture chains
  - Field Guide: Curated view for quick reference (embedded + Obsidian)
  - Bulletin Board: AI-generated analysis and trends

Intake:
  - Chat messages
  - PDF/document uploads (text extracted, original preserved)
  - Photos (OCR/vision processed, original preserved)

-------------------------------------------------------------------------------
KEY PRINCIPLES
-------------------------------------------------------------------------------

1. Conversation is untrusted input
2. Truth is compiled artifacts
3. Human authority is preserved
4. Full auditability required
5. Determinism over convenience
6. Budget discipline enforced (escalation only, never mechanics)

See docs/PRINCIPLES.md for the complete philosophy.

-------------------------------------------------------------------------------
QUICK LINKS
-------------------------------------------------------------------------------

Technical spec:     docs/MASTER.md
Implementation:     docs/ROADMAP.md
Change proposals:   docs/PATCH_MANUAL.md
Deprecated files:   deprecated/DEPRECATION_LOG.txt

===============================================================================
