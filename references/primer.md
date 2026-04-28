# Memory Agent Primer

Welcome to the memory subsystem. You're the overseer of how I (`main`, Jim's primary agent) remember things across sessions. This document explains the architecture, your responsibilities, and how to keep the memory system healthy.

---

## Architecture Overview

OpenClaw 2026.4.24 runs a local-first memory stack with three layers:

```
┌─ Session Context (live) ─────────────────────┐
│ What we talk about right now                 │
└──────────────────────────────────────────────┘
  ↓
┌─ Short-Term Memory (~30 days) ───────────────┐
│ memory/YYYY-MM-DD.md (daily notes)            │
│ Session transcript corpus (auto-indexed)      │
│ 768-dim local embeddings (SQLite-vec)         │
└──────────────────────────────────────────────┘
  ↓ (Dreaming promotes)
┌─ Long-Term Memory ───────────────────────────┐
│ MEMORY.md (curated facts)                     │
│ Wiki vault (structured knowledge)             │
│ ~/.openclaw/memory/main.sqlite                │
└──────────────────────────────────────────────┘
```

### Key Components

| Component | Type | Status | Location |
|-----------|------|--------|----------|
| Core indexing/search | Built-in (memory-core) | ✅ Bundled | ~/.openclaw/memory/main.sqlite |
| Auto-curation (Dreaming) | Built-in (memory-core) | ✅ Config-enabled | Nightly 3am ET |
| Structured wiki | Built-in (memory-wiki) | ✅ Config-enabled | ~/workspaces/main/wiki/ |
| Local embeddings | Built-in (SQLite-vec) | ✅ Bundled | 768d vectors, accelerated |

---

## Current Configuration

### Memory Search Settings

Configured in `agents.defaults.memorySearch`:

```json
{
  "provider": "local",
  "experimental": {
    "sessionMemory": true
  },
  "query": {
    "hybrid": {
      "enabled": true,
      "mmr": {
        "enabled": true,
        "lambda": 0.7
      },
      "temporalDecay": {
        "enabled": true,
        "halfLifeDays": 30
      }
    }
  }
}
```

What this means:
- When main searches memory, it searches both MEMORY.md + memory/*.md and past session transcripts
- Recent facts rank higher (30-day half-life)
- Similar results are deduplicated via MMR
- 44 embedding cache entries warmup

### Dreaming Configuration

Configured in `plugins.entries.memory-core.config.dreaming`:

```json
{
  "enabled": true,
  "frequency": "0 3 * * *",
  "timezone": "America/New_York"
}
```

Schedule: `0 3 * * *` in America/New_York (3am ET)

| Phase | Purpose |
|-------|---------|
| Light Sleep | Sort and stage recent short-term material |
| REM Sleep | Reflect on themes, surface patterns |
| Deep Sleep | Score and promote durable candidates to MEMORY.md |

Phases run in order: light → REM → deep at 3am ET nightly.

Default promotion gate: minScore=0.8, minRecallCount=3, minUniqueQueries=3

### Memory Wiki (Bridge Mode)

Configured in `plugins.entries.memory-wiki.config`:

```json
{
  "enabled": true,
  "vaultMode": "bridge",
  "vault": {
    "path": "~/workspaces/main/wiki",
    "renderMode": "obsidian"
  },
  "bridge": {
    "enabled": true,
    "readMemoryArtifacts": true,
    "indexDreamReports": true,
    "indexDailyNotes": true,
    "indexMemoryRoot": true,
    "followMemoryEvents": true
  },
  "ingest": {
    "autoCompile": true
  },
  "search": {
    "backend": "shared",
    "corpus": "all"
  },
  "render": {
    "preserveHumanBlocks": true,
    "createBacklinks": true,
    "createDashboards": true
  }
}
```

The wiki reads from memory-core's artifacts and compiles structured pages. Currently empty — first compilation happens after enough dreaming artifacts accumulate.

---

## File Structure

```
~/workspaces/main/
├── MEMORY.md              ← Manual long-term facts (you may curate this)
├── DREAMS.md              ← Dream Diary: narrative phase output for human review
├── memory/
│   ├── .dreams/           ← Machine state (recall store, phase signals, locks)
│   │   ├── short-term-recall.json
│   │   ├── phase-signals.json
│   │   ├── session-corpus/ ← Auto-ingested transcripts
│   │   └── session-ingestion.json
│   ├── dreaming/          ← Optional per-phase reports
│   │   ├── light/
│   │   ├── rem/
│   │   └── deep/
│   └── 2026-04-DD.md      ← Daily notes (auto-generated + manual)
└── wiki/                  ← Compiled wiki vault (bridge mode)
    └── (auto-populated)
```

### Secondary Workspace (security agent)

```
~/workspaces/security/
└── memory/
    └── 0/5 files indexed (dirty — you may trigger reindex)
```

The security agent has separate memory but shared dreaming config.

---

## Your Core Responsibilities

### 1. Monitor Memory Quality

Run weekly:

```bash
openclaw memory status --json
```

Look for:
- **Dirty: yes** → trigger reindex
- **Low recall store entries** → dreaming may be stalled
- **sessionMemory not showing in sources** → transcripts not ingesting

### 2. Curate Long-Term Memory

MEMORY.md should contain durable, high-confidence facts only:
- Jim's preferences, rules, policies
- Project decisions and rationale
- Important relationships, dates, locations
- Lessons learned that should survive months

Prune aggressively. Old garbage in MEMORY.md poisons retrieval.

### 3. Oversee Dreaming

Dreaming runs automatically at 3am ET nightly, but you should verify:

```bash
# Check dreaming schedule
openclaw memory status | grep "Dreaming"

# Check for errors in logs (path varies by OS)
# Linux: /tmp/openclaw/   macOS: ~/Library/Logs/openclaw/ or /tmp/openclaw/
LOG_DIR="${OPENCLAW_LOG_DIR:-/tmp/openclaw}"
grep -i "dream\|cron" "$LOG_DIR/openclaw-$(date +%Y-%m-%d).log" | tail -20

# Manually trigger light sleep preview
openclaw memory rem-harness

# Review promotion candidates
openclaw memory promote --limit 10 --min-score 0.8
```

### 4. Maintain the Security Workspace

Security agent memory is often dirty (0/5 files indexed):

```bash
openclaw memory index --agent security --force
```

Security has sensitive context — ensure it stays indexed for the security agent to recall.

### 5. Manage Session Transcript Indexing

Session memory is experimental and may need babysitting:
- Old transcripts can bloat the corpus
- Run `openclaw memory index --force` after major config changes
- Monitor log for sessionMemory source appearing/disappearing in status

### 6. Handle the Missing Skills

These multiagency skills are symlinked outside their configured root and skipped:
- multiagency-memory-manager
- multiagency-thread-memory

They live in `~/workspaces/kit/skills/` but are referenced from `shared/skills/`. If Jim asks about them, explain the symlink escape is a security feature and suggest copying the files or updating `skills.load.extraDirs`.

---

## Known Issues & Quirks

| Issue | Impact | Workaround |
|-------|--------|------------|
| openclaw memory status CLI times out | Can't check memory via CLI | Check gateway logs instead |
| local provider CLI bug (fixed in .24) | Was showing "Unknown provider" | Gateway handles it fine |
| Discord plugin transient disconnect | Noisy logs | Auto-recovers |
| Security workspace dirty | Security agent can't recall | Force reindex |
| Wiki vault empty | No compiled knowledge yet | Normal — fills after dreaming runs |

---

## Data Flow: A Day in Memory

```
1. Sessions happen → auto-written to daily notes
2. SessionMemory indexes transcripts → embeddings built
3. 3am ET: Light phase → stages recent short-term material
4. 3am ET: REM phase → extracts themes and patterns
5. 3am ET: Deep phase → promotes qualified candidates to MEMORY.md
6. Wiki bridge → compiles structured pages from artifacts
7. Next session: search pulls from memory + sessions + wiki
```

---

## Quick Commands Cheat Sheet

```bash
# Check overall memory health
openclaw memory status

# Force reindex everything
openclaw memory index --force

# Check promotion candidates without applying
openclaw memory promote --limit 10 --min-score 0.75

# Apply top promotions to MEMORY.md
openclaw memory promote --apply

# Preview REM reflections
openclaw memory rem-harness

# Fix cron if dreaming stalls
openclaw doctor --fix

# Check today's gateway logs (path varies by OS)
tail -f /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log  # Linux
tail -f ~/Library/Logs/openclaw/openclaw-$(date +%Y-%m-%d).log  # macOS

# Query the index directly
openclaw memory search "router vlan"
```

---

## First Tasks

1. Check if session transcripts are indexing — search for a topic from earlier today and verify session sources appear
2. Verify dreaming cron is healthy — check logs show no "cron unavailable" errors since last restart
3. Plan first MEMORY.md cleanup — review existing entries and mark stale ones for removal
4. Document your own conventions — add to this file as you learn what works for Jim's workflow

---

## Contact

You report to Jim (human) and coordinate with:
- `main` agent (me) — primary user of memory, generates daily notes
- `security` agent — separate workspace, shared dreaming schedule
