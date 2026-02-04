===============================================================================
FUTILITY'S — PRINCIPLES AND ETHICS
===============================================================================

This document defines the philosophy, ethics, and non-negotiable rules
that keep Futility's functional, trustworthy, and maintainable.

Violating these principles will cause the system to drift, contradict
itself, or become unsafe and unreviewable.

===============================================================================
1) MISSION
===============================================================================

Futility's exists to turn messy human knowledge into reliable, accessible,
audited operational truth.

The problem it solves:
  - Factory information is unreliable or unavailable
  - Tribal knowledge lives in people's heads
  - Official documents are often wrong or outdated
  - No one has time to maintain documentation
  - When you need an answer, you can't find it

The solution:
  - Capture information from daily work (chat, photos, observations)
  - Verify through evidence and human review
  - Publish as accessible, searchable truth
  - Maintain audit trail for everything

Primary outcome:
  - Mechanics can find reliable answers quickly
  - Knowledge survives personnel changes
  - Verification is built into the process

===============================================================================
2) CORE PHILOSOPHY
===============================================================================

P1. CONVERSATION IS NOT TRUTH
-----------------------------
Chat, notes, uploads, and observations are provisional and untrusted.
They are raw input, not verified output.
Treat all intake as "someone said this" until verified.

P2. TRUTH IS COMPILED
---------------------
Only artifacts produced through the verification pipeline are authoritative.
SSOT exists because evidence was evaluated and humans approved.
If it's not in SSOT, it's not official.

P3. LLMS PROPOSE, HUMANS DECIDE
-------------------------------
AI may draft, analyze, extract, and organize.
AI may NOT decide what is true.
Human review is the final gate.
The Confirm Screen is sacred.

P4. FULL AUDITABILITY
---------------------
Every attempt is logged, traceable, and reversible.
Every fact links to its source captures.
Every decision has a recorded reason.
If it can't be audited, it's not allowed.

P5. DETERMINISM OVER CONVENIENCE
--------------------------------
Verification follows explicit rules, not vibes.
Outputs are reproducible given the same inputs.
No system behavior depends on uncontrolled randomness.

P6. COST REFLECTS EPISTEMIC WEIGHT
----------------------------------
Verification costs (compute, human review) are visible and justified.
Escalation happens when "worth it," not by default.
Budget discipline prevents wasteful compute.

P7. HUMAN AUTHORITY PRESERVED
-----------------------------
Final responsibility remains with human operators.
The system assists; it does not replace judgment.
Mechanics and supervisors remain in control.

===============================================================================
3) GOLDEN RULES (NON-NEGOTIABLE)
===============================================================================

RULE A: Truth is compiled, not spoken
  - Chat is untrusted
  - SSOT is the result of reviewed compilation
  - If it's not in SSOT, it's not canon

RULE B: Determinism over vibes
  - The executor is deterministic
  - Changes are explicit, not interpreted
  - If it can't be expressed deterministically, it must be blocked

RULE C: Human gate is sacred
  - No publication without review
  - AI proposes; humans decide
  - The Confirm Screen cannot be bypassed

RULE D: Minimal change, maximum clarity
  - Each update should change only what's necessary
  - Avoid broad rewrites
  - Prefer targeted edits over sweeping changes

RULE E: Auditability is mandatory
  - Every change leaves a trace
  - Every fact links to sources
  - Failures are recorded, not hidden

RULE F: Budget discipline
  - Escalation must be justified
  - Spending is explicit
  - "Worth it" is measured, not assumed

===============================================================================
4) HARD SAFETY BOUNDARIES (DO NOT COMPROMISE)
===============================================================================

1. Never commit secrets (tokens, passwords, private keys)
2. Never bypass the confirm/review gate
3. Never rewrite history to hide mistakes
4. Never allow AI to execute Git commands directly
5. Never blur boundaries between:
   - Proposal vs execution
   - Draft vs verified
   - Opinion vs fact
   - Observation vs truth

===============================================================================
5) ETHICS OF THE SYSTEM
===============================================================================

Futility's is built around restraint.

WE REFUSE:
  - Silent changes (everything logged)
  - Unreviewed publication (gates required)
  - "AI authority" (AI assists, humans decide)
  - Scope creep disguised as helpfulness
  - Hidden tradeoffs, risks, or costs

The system is not here to be clever.
It is here to be correct, auditable, and maintainable.

===============================================================================
6) MECHANIC-FIRST DESIGN
===============================================================================

The system must work for grumpy mechanics who:
  - Have 5 seconds of patience
  - Won't read instructions
  - Don't want to learn new tools
  - Just need the right answer right now
  - Will stop using anything annoying

Design implications:
  - Questions must be worth asking (see Question Value Scoring)
  - Answers must be immediately useful
  - Field Guide must be frictionless
  - Chat must feel helpful, not interrogating

===============================================================================
7) QUESTION VALUE SCORING
===============================================================================

Before asking any question, compute score:

  +2 if answer is observable right now
  +2 if answer materially changes next step
  +1 if low effort (yes/no, multiple choice)
  −2 if user just said "don't know" or "just noticed"
  −2 if requires measurement, lookup, or memory

Ask ONLY if score ≥ 3.

Budget:
  - Max 1-2 questions per interaction
  - Prefer multiple choice
  - Never chain more than one follow-up

If uncertain: escalate to model reasoning, not more questions.

DON'T ASK — INFER:
  If the system can infer from asset type, history, or similar cases,
  infer and label it as inference. Don't ask.

===============================================================================
8) FAILURE PHILOSOPHY
===============================================================================

Mistakes are normal. Hidden mistakes are fatal.

When something fails:
  - Record it
  - Explain it
  - Fix it
  - Keep the trail

The system must prefer:
  - Safe failure over unsafe success
  - Asking questions over guessing
  - "I don't know" over confident wrong answers
  - Blocked status over silent drift

===============================================================================
9) AI ROLE
===============================================================================

AI IS:
  - A draft generator
  - A claim extractor
  - A contradiction detector
  - An organizer of information
  - A curation assistant

AI IS NOT:
  - The final decision maker
  - The publisher
  - The source of truth
  - A replacement for expertise

AI must never present its output as "the system decided."
Only human review decides.

===============================================================================
10) INFERENCE RULES
===============================================================================

AI may infer, but inferences must:

1. Be clearly labeled as inference
2. Include human-readable justification
3. Link to supporting evidence (if any)
4. Never be stated as verified fact
5. Be presented as "likely" or "possible," not "is"

Good: "Based on this pump type's failure history, cavitation is a likely cause."
Bad: "The cause is cavitation."

===============================================================================
11) MAINTAINER COMMITMENT
===============================================================================

By using Futility's, the maintainer agrees:

  - To review changes before approving
  - To keep updates small and intentional
  - To require authorization for major changes
  - To treat audit logs as sacred
  - To protect trust boundaries and secrets
  - To correct the system when it misbehaves

If this commitment is not acceptable, the system will degrade.

===============================================================================
12) OPERATING CREED
===============================================================================

These phrases define how the system operates:

  "Conversation is untrusted."
  "Truth is compiled."
  "Review is the gate."
  "Deterministic execution only."
  "No secrets in Git."
  "Audit trail or it didn't happen."
  "Spend is explicit."
  "Inference is labeled."
  "Mechanics come first."

===============================================================================
END PRINCIPLES
===============================================================================
