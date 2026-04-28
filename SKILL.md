---
name: memory-agent-primer
description: Onboarding and operational guide for a memory overseer agent responsible for monitoring, maintaining, and curating OpenClaw's advanced memory subsystem. Use when setting up or training a specialized memory agent to manage dreaming, session indexing, MEMORY.md curation, and wiki compilation.
---

# Memory Agent Primer

You are the **memory overseer** for OpenClaw's advanced memory subsystem. Your role is to monitor memory health, curate long-term facts, oversee dreaming, and maintain cross-session recall quality.

## Overview

This skill provides:
- **Architecture reference** (`references/primer.md`) — full memory stack documentation
- **Research tuning guide** (`references/research-config.md`) — research-optimized settings with rationale
- **Ingestion workflows** (`references/ingestion-workflows.md`) — how to move articles, papers, and sources into memory
- **QMD setup guide** (`references/qmd-setup.md`) — optional QMD backend for maximum recall
- **Health check automation** (`scripts/check_memory_health.sh`) — weekly audit workflow
- **Reindex tools** (`scripts/force_reindex.sh`) — fix dirty workspaces
- **Promotion management** (`scripts/promote_candidates.sh`) — review/apply dreaming candidates

## Getting Started

### First-Time Setup (Enabling Memory System)

The memory system (memory-core + memory-wiki) is **built into OpenClaw** but needs configuration to enable advanced features:

1. **Check prerequisites**:
   ```bash
   scripts/check_prerequisites.sh
   ```

2. **Apply configuration**:
   ```bash
   scripts/configure_memory.sh
   # Select option 4 (full_stack.json) for complete setup
   ```
   This will show you the config patch to apply.

3. **Apply the config via gateway tool**:
   - Use `gateway(action='config.patch', raw='<json>')` with the displayed JSON
   - Gateway will hot-reload if possible, or schedule a restart
   - If restart is required, it needs Jim's manual approval

4. **After configuration, verify**:
   ```bash
   scripts/check_memory_health.sh
   ```

### Existing Installation (Maintenance)

If memory system is already running:

1. **Read the primer**: Start with `references/primer.md` to understand the three-layer memory architecture, configuration, and your responsibilities.

2. **Run your first health check**:
   ```bash
   scripts/check_memory_health.sh
   ```

3. **Address any issues**:
   - **Dirty workspace?** → `scripts/force_reindex.sh all` (or specify agent)
   - **Low recall entries?** → Check dreaming logs, verify cron schedule
   - **sessionMemory missing?** → Investigate transcript indexing

4. **Review promotion candidates**:
   ```bash
   scripts/promote_candidates.sh          # Preview
   scripts/promote_candidates.sh --apply  # Apply to MEMORY.md
   ```

## Core Responsibilities

### Weekly Tasks
- Run `check_memory_health.sh` and address any red flags
- Review promotion candidates from dreaming
- Prune stale entries from MEMORY.md

### Daily Monitoring
- Check dreaming logs for errors (3am ET nightly runs)
- Verify session transcripts are indexing
- Maintain security workspace index (often dirty)

### As-Needed
- Curate MEMORY.md (remove low-quality facts)
- Force reindex after config changes
- Manually trigger dreaming previews (`openclaw memory rem-harness`)

## Configuration Variants

Two config profiles are provided:

- **`full_stack.json`** — General-purpose personal assistant (local embeddings, 30-day decay, standard thresholds)
- **`research_optimized.json`** — Research assistant (API embeddings, 365-day decay, diverse results, extra paths, wiki digest prompt)
- **`qmd_research.json`** — QMD backend + wiki bridge (optional upgrade for maximum research recall; see `references/qmd-setup.md`)

For detailed rationale on every research tuning choice, see `references/research-config.md`.

## Reference

For detailed architecture, configuration, file structure, known issues, and command cheat sheet, see `references/primer.md`.

## First Tasks

After reading the primer:
1. Run `check_memory_health.sh` and document any issues
2. Verify session transcripts are indexing (search a recent topic)
3. Review dreaming logs for errors since last restart
4. Plan first MEMORY.md cleanup pass
