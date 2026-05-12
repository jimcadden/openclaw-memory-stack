# OpenClaw Memory Stack

This repository contains the `memory-agent-primer` skill, providing an onboarding and operational guide for maintaining OpenClaw's advanced memory subsystem, including wiki-dreaming integration for research workflows.

## Overview
As the memory overseer, this toolset allows you to:
- Monitor memory health.
- Curate long-term facts in `MEMORY.md`.
- Oversee dreaming cycles.
- Maintain cross-session recall quality.
- **NEW (2026-05-12):** Enrich wiki knowledge base with conversation evidence via automated dream mining.

## Architecture
The memory subsystem utilizes a three-layer architecture to handle short-term logs, structured knowledge, and long-term curated facts. **The wiki vault implements Karpathy's Layer 2 model** — a persistent, LLM-maintained knowledge base sitting between raw sources and schema files.

```mermaid
graph TD
    A[Session Context] --> B[Short-Term Memory]
    B -->|Dreaming Promotion| C[Long-Term Memory]
    C -->|Bridge Mode| D[Wiki Vault]
    B -->|Conversation Evidence| D

    subgraph "Layer 1: Live"
    A
    end

    subgraph "Layer 2: Short-Term (~30 days)"
    B[memory/YYYY-MM-DD.md & Transcripts]
    end

    subgraph "Layer 3: Long-Term"
    C[MEMORY.md & SQLite Store]
    end

    subgraph "Karpathy Layer 2: Knowledge"
    D[Wiki Vault: Entities + Syntheses]
    end
```

## Wiki-Dreaming Integration (NEW)

**Conversations are first-class research artifacts.** The wiki dream miner automatically:
- Scans dream logs for high-confidence conversation fragments (≥0.75)
- Matches fragments to existing wiki entities/syntheses
- Auto-files conversation evidence to strengthen claims
- Runs weekly via cron (Sundays 4am ET)

See `references/wiki-dreaming-integration.md` for full architecture and rationale.

## Data Flow
The system processes information through a defined pipeline to ensure high-confidence recall.

```mermaid
sequenceDiagram
    participant S as Sessions
    participant D as Daily Notes
    participant E as Embedding Store
    participant Dr as Dreaming (3am ET)
    participant M as Long-Term Memory (MEMORY.md)

    S->>D: Write raw logs
    S->>E: Index transcripts
    Dr->>D: Light Sleep (Stage)
    Dr->>D: REM Sleep (Pattern Analysis)
    Dr->>M: Deep Sleep (Promote Candidates)
```

## Key Configuration

### Memory Search Settings
Configured in `agents.defaults.memorySearch`:
```json
{
  "provider": "local",
  "experimental": { "sessionMemory": true },
  "query": {
    "hybrid": {
      "enabled": true,
      "mmr": { "enabled": true, "lambda": 0.7 },
      "temporalDecay": { "enabled": true, "halfLifeDays": 30 }
    }
  }
}
```

### Dreaming Configuration
Configured in `plugins.entries.memory-core.config.dreaming`:
```json
{
  "enabled": true,
  "frequency": "0 3 * * *",
  "timezone": "America/New_York"
}
```

## Structure
- `SKILL.md`: Skill definition and entry point.
- `assets/`: Configuration patches for various memory modes.
- `scripts/`: Automation for health checks, reindexing, and promotion management.
- `references/`: Documentation on architecture, tuning, and workflows.

## Getting Started
For comprehensive setup and operational instructions, please refer to the `references/primer.md` file within this repository.
