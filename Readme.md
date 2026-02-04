# Futility's — Single Source of Truth Engine

**A knowledge management system that captures operational information, verifies it through human review, and publishes it as trusted, auditable documentation.**

---

## The Problem

Factory operations rely on information that is:
- Scattered across manuals, tribal knowledge, and people's heads
- Often outdated, conflicting, or simply unavailable when needed
- Lost when experienced personnel leave
- Impossible to verify or trace to its source

When a mechanic needs an answer at 2 AM, they shouldn't have to guess.

---

## The Solution

Futility's creates a **single source of truth** for operational knowledge:

```
Capture → Verify → Publish → Access
```

| Stage | What Happens |
|-------|--------------|
| **Capture** | Mechanics submit observations, notes, and questions via chat or file upload |
| **Verify** | Claims are extracted, evidence is linked, humans approve what becomes "truth" |
| **Publish** | Verified facts enter the SSOT database with full audit trail |
| **Access** | Anyone can browse, search, and retrieve trusted information instantly |

---

## Key Principles

1. **Conversation is not truth** — Chat is input, not output. Everything is unverified until reviewed.
2. **Truth is compiled** — Only facts that pass through verification gates become authoritative.
3. **Humans decide** — AI assists with extraction and organization; humans approve what's real.
4. **Full audit trail** — Every fact traces back to its source. Every decision is logged.
5. **Mechanics come first** — The system must be useful with zero friction, or no one will use it.

---

## What Gets Built

### Phase 1: Foundation (Current)
- Secure web interface for capturing information
- PIN-based authentication
- Text and file intake (PDFs, photos, documents)
- Git-backed storage with automatic commits
- Basic dashboard and browsing

### Phase 2-6: Verification System
- Claim extraction from captured content
- Asset resolution (linking mentions to equipment)
- Confidence scoring and contradiction detection
- Human approval workflow
- Dispute mechanism

### Phase 7+: Full SSOT
- Searchable knowledge explorer
- Curated field guide for mobile use
- AI-generated trend analysis
- Integration with existing systems

See [docs/ROADMAP.md](docs/ROADMAP.md) for the complete implementation plan.

---

## Documentation

| Document | Purpose |
|----------|---------|
| [docs/MASTER.md](docs/MASTER.md) | Complete technical specification |
| [docs/PRINCIPLES.md](docs/PRINCIPLES.md) | Philosophy and non-negotiable rules |
| [docs/ROADMAP.md](docs/ROADMAP.md) | Implementation phases with checkpoints |
| [GAMEPLAN.md](GAMEPLAN.md) | Step-by-step setup guide for beginners |
| [SETUP_REQUIREMENTS.md](SETUP_REQUIREMENTS.md) | Prerequisites and authorization checklist |

---

## Quick Start

**Prerequisites:** GitHub account, DigitalOcean account ($12/month)

```bash
# On a fresh Ubuntu 22.04 droplet:
curl -sSL https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/install.sh -o install.sh
bash install.sh
```

The installation wizard handles everything: server setup, dependencies, application deployment, and HTTPS configuration.

**Time to deploy:** ~30 minutes
**Monthly cost:** ~$15-25 (infrastructure + light AI usage)

---

## Project Status

| Component | Status |
|-----------|--------|
| Specification | ✅ Complete |
| Installation wizard | ✅ Complete |
| Basic capture system | ✅ Complete |
| Verification workflow | 🔲 Phase 2 |
| SSOT Explorer | 🔲 Phase 3 |
| Field Guide export | 🔲 Phase 4 |

---

## Why "Futility's"?

Because maintaining accurate documentation in a factory has historically felt futile — information decays, people leave, systems change, and no one has time to keep up.

This system is designed to make that futility... less futile.

---

## License

Internal use. Not currently open source.

---

**Owner:** Gondor
**Version:** 4.0
**Last Updated:** February 2026
