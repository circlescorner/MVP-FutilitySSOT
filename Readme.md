[[===============================================================================
FUTILITY’S — SINGLE SOURCE OF TRUTH ENGINE v0.1 (full cycle git prototype)
README.md (Canonical Project Manifest + Roadmap)
Owner: Gondor
Status: Active Development (Phase 1)
===============================================================================


-------------------------------------------------------------------------------
1) CORE MISSION
-------------------------------------------------------------------------------

Futility’s exists to transform unstructured human conversation into audited,
versioned, reversible, institutionally reliable truth.

This system does not automate answers.
It automates responsibility.

Conversation is treated as raw, untrusted input.
Truth exists only as compiled, governed artifacts.

The initial substrate is Git.
Future substrates include knowledge bases, asset registries, procedures,
incident records, and operational state.

This repository implements the first working prototype of that vision.


-------------------------------------------------------------------------------
2) PHILOSOPHY AND PRINCIPLES
-------------------------------------------------------------------------------

P1. Conversation Is Not Truth
    Chat, notes, and uploads are provisional and untrusted.

P2. Truth Is Compiled
    Only artifacts produced by the governed pipeline are authoritative.

P3. LLMs Propose, Code Decides
    Models may draft and analyze.
    Deterministic systems execute and publish.

P4. Full Auditability
    Every attempt is logged, reversible, and traceable.

P5. Determinism Over Convenience
    No system behavior may depend on uncontrolled model randomness.

P6. Bounded Uncertainty
    Ambiguity is surfaced and resolved, not hidden.

P7. Cost Reflects Epistemic Weight
    Verification costs are visible, justified, and governed.

P8. Human Authority Preserved
    Final responsibility remains with human operators.


-------------------------------------------------------------------------------
3) SYSTEM OVERVIEW
-------------------------------------------------------------------------------

Futility’s is a Chat → Patch → Compile → Govern → Publish pipeline.

It converts human intent into structured, verified, and versioned truth artifacts.

The initial implementation targets Git repositories, producing Pull Requests
as the authoritative output.


High-Level Architecture:

    Intake (Chat / PATCHGIT / Upload)
        |
        v
    Stage 1: Interpret (Hypothesis Builder)
        |
        v
    Stage 2: Gate (Risk / Confidence / Budget)
        |
        v
    Stage 3: Fit (Sandbox / Validation)
        |
        v
    Confirm Screen (Human Authorization)
        |
        v
    Executor (Deterministic Compiler)
        |
        v
    Versioned Artifact (PR + Audit Trail)


-------------------------------------------------------------------------------
4) PIPELINE STAGES
-------------------------------------------------------------------------------

Stage 0: Intake
- Sources: chat, structured paste, uploads
- Treated as untrusted sensor input

Stage 1: Interpret
- Converts intent to PatchProposal
- Produces targets, operations, payload
- May ask <=3 bounded questions

Stage 2: Gate
- Risk analysis
- Confidence scoring (C0–C3)
- Panel review
- Budget evaluation

Stage 3: Fit
- Fresh sandbox clone
- Apply candidate changes
- Run checks/tests
- Generate diff preview

Stage 4: Confirm
- Human review
- Scope approval
- Cost approval

Stage 5: Execute
- Deterministic application
- Branch/commit/push
- PR creation
- Audit recording


-------------------------------------------------------------------------------
5) PATCH REPRESENTATION (HYBRID MODEL)
-------------------------------------------------------------------------------

All changes exist in two forms:

1) Internal (Executor-Facing): PatchOps JSON
2) External (Human-Facing): Unified Diff Preview

PatchOps is canonical.
Diffs are derived via sandbox apply.

LLMs never emit raw diffs directly to the executor.


Supported v1 Operations:

- CREATE_FILE(path, content)
- REPLACE_FILE(path, content)
- APPEND_FILE(path, content)
- REPLACE_BLOCK(path, block_id, content)

REPLACE_BLOCK requires explicit markers:

    <!-- FUTILITYS:BEGIN block_id -->
    ...
    <!-- FUTILITYS:END block_id -->

Fuzzy edits are prohibited by default.


-------------------------------------------------------------------------------
6) COMPUTE AND ESCALATION MODEL
-------------------------------------------------------------------------------

Lane 0: Control Plane (Always-On)
- Minimal droplet
- Deterministic orchestration
- No heavy inference

Lane 1: Single Helper Burst
- 2–4GB ephemeral
- Sandbox + checks + panel

Lane 2: Strong Local Burst
- 2x8GB ephemeral
- Deep local reasoning

Lane 3: GPU Burst (Runpod)
- Approval required
- Heavy reasoning only

Lane 4: External API
- Last resort
- Approval required

Escalation governed by WorthItScore:
(ExpectedGain * RiskWeight) / Cost


-------------------------------------------------------------------------------
7) STORAGE MODEL
-------------------------------------------------------------------------------

Metadata Store:
- SQLite (default)

Stores:
- Jobs
- Stage outputs
- Confidence
- Lane usage
- Costs
- Status
- Artifact references

Artifact Store:

Option A: Droplet Disk (Default MVP)
    /var/lib/futilitys/artifacts/<job_id>/

Option B: Object Storage (Optional)
    DigitalOcean Spaces or equivalent

Artifacts include:
- Logs
- Diffs
- Patch bundles
- Panel memos
- Error traces


-------------------------------------------------------------------------------
8) GIT INTEGRATION
-------------------------------------------------------------------------------

GitHub integration uses gh CLI.

Executor workflow:
- Create branch
- Commit changes
- Push branch
- Open PR

Rules:
- No direct push to main
- No history rewriting
- Tokens never committed
- Protected zones enforced


-------------------------------------------------------------------------------
9) BUDGET MANAGEMENT
-------------------------------------------------------------------------------

Tracked:
- Helper minutes
- GPU minutes
- API tokens

Default caps (configurable):
- Local burst: $3/day
- GPU: $1.50/day
- API: $0.50/day
- Total: $5/day

Overages require explicit approval.


-------------------------------------------------------------------------------
10) AUDITABILITY
-------------------------------------------------------------------------------

Every job records:

- Raw intake
- Stage outputs
- Questions and answers
- Confidence scores
- Lane decisions
- Costs
- Executor logs
- Final artifacts
- Failure traces

No silent failures.
No unlogged changes.


-------------------------------------------------------------------------------
11) SECURITY AND SAFETY
-------------------------------------------------------------------------------

Protected Zones:
- Executor code
- Auth configuration
- Secrets
- Automation workflows

Rules:
- Secrets never committed
- PR-only publishing
- Job serialization lock
- Size limits
- Sandbox-first execution


-------------------------------------------------------------------------------
12) DEVELOPMENT PHASES
-------------------------------------------------------------------------------

PHASE 1: Git SSOT Engine (Current)
- Complete Chat→PR compiler
- Stable audit trail
- Reliable sandbox
- Enforced budgets

PHASE 2: Generalized SSOT
- Non-Git substrates
- Knowledge compiler
- Evidence graph

PHASE 3: Real-World Integration
- Sensors
- CMMS
- ERP
- Logs

PHASE 4: Organizational Memory
- Drift detection
- Decision lineage
- Context preservation

PHASE 5: Autonomous Governance
- Predictive audits
- Auto-reconciliation


-------------------------------------------------------------------------------
13) FORK MILESTONE
-------------------------------------------------------------------------------

When Phase 1 is stable:

Branch A: Git Compiler Product
Branch B: Full SSOT Engine

Branch A funds and validates Branch B.


-------------------------------------------------------------------------------
14) KNOWN DECIDED SYSTEM CONFIGURATION
-------------------------------------------------------------------------------

- Git as initial truth substrate
- Hybrid PatchOps + Diff model
- gh CLI for PRs
- SQLite metadata store
- Artifact directory structure
- Deterministic executor
- Sandbox-first validation
- Budget-gated escalation
- Human confirm gate
- Marker-based block edits
- No fuzzy modify
- No LLM direct execution
- PR-only publishing
- Control plane + helper model


-------------------------------------------------------------------------------
15) CURRENTLY AMBIGUOUS / NEEDS CLARIFICATION
-------------------------------------------------------------------------------

A1. Exact PatchOps JSON schema (final field definitions)
A2. Plugin interface for new substrates
A3. Evidence weighting algorithms
A4. Authority delegation model
A5. Long-term data retention policy
A6. Cross-repo governance rules
A7. Multi-tenant isolation model
A8. Legal/compliance export formats
A9. Incident response workflow
A10. Distributed consensus model (future)
A11. Formal verification scope
A12. Knowledge contradiction resolution rules
A13. Access control granularity
A14. Disaster recovery topology
A15. Federation between instances


-------------------------------------------------------------------------------
16) HARDWARE / SYSTEMS REQUIRING FURTHER DEFINITION
-------------------------------------------------------------------------------

H1. Control plane sizing beyond MVP
H2. Helper droplet auto-scaling rules
H3. GPU provider redundancy
H4. Backup storage backend
H5. High-availability architecture
H6. Regional replication
H7. Cold storage tier
H8. On-prem deployment profile
H9. Edge intake nodes
H10. Long-term archive system
H11. Hardware security modules
H12. Dedicated audit nodes


-------------------------------------------------------------------------------
17) WHAT THIS PROJECT IS NOT
-------------------------------------------------------------------------------

- Not a chatbot
- Not an auto-coder
- Not prompt engineering
- Not generic DevOps automation
- Not SaaS AI tooling

It is epistemic infrastructure.


-------------------------------------------------------------------------------
18) ROLE OF THE MAINTAINER
-------------------------------------------------------------------------------

The maintainer (Gondor) acts as:

- Chief architect
- Final verifier
- Epistemic authority
- System guardian

Human judgment remains sovereign.


-------------------------------------------------------------------------------
19) CONTRIBUTION MODEL
-------------------------------------------------------------------------------

All contributions must:

- Preserve determinism
- Preserve auditability
- Preserve reversibility
- Preserve human authority
- Include tests and traces
- Document epistemic impact


-------------------------------------------------------------------------------
20) FINAL SUMMARY
-------------------------------------------------------------------------------

Futility’s is building the first practical system that compiles human intent
into institutional truth.

We begin with Git.
We prove governance.
We expand to knowledge.
We integrate reality.
We preserve memory.
We automate responsibility.

This repository contains the foundation.


===============================================================================
END README
===============================================================================]]