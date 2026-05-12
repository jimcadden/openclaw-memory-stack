# Wiki-Dreaming Integration

**Status:** Implemented 2026-05-12  
**Architecture Decision:** Option A - Conversations as First-Class Research Artifacts

## The Problem

The memory subsystem had two parallel pipelines that didn't interact:

**Dreaming Pipeline:**
```
Session transcripts → Light sleep (extract candidates)
                   → Deep sleep (promote to MEMORY.md)
```

**Wiki Pipeline:**
```
Raw sources → Read/extract → wiki_apply (create syntheses)
```

**Result:** Valuable insights from conversations (like discussions about identity as IPI defense, Zero Trust requirements for agent harnesses) sat in dream logs instead of enriching wiki entities.

## The Solution: Wiki-Aware Dreaming

Dreaming becomes the process that mines conversations for wiki-worthy knowledge, creating a feedback loop between session transcripts and the research knowledge base.

### Flow

1. **Light Sleep (Wiki-Aware Extraction)**
   - Extract candidates from session transcripts
   - Query wiki: "Does this relate to existing entities/syntheses?"
   - Enrich candidates with wiki context
   - Tag candidates: `strengthen_claim`, `contradiction`, `new_concept`, `personal_note`

2. **Deep Sleep (Wiki Integration)**
   - **High confidence (>0.75) + strengthen_claim:** Auto-file as conversation evidence to wiki
   - **Contradiction flagged:** Create review item
   - **New concept suggested:** Flag for human review (don't auto-create entities)
   - **Personal notes:** Promote to MEMORY.md only

3. **REM Sleep (Cross-Wiki Pattern Detection)**
   - Look for patterns across wiki pages
   - Suggest missing cross-references
   - Identify gaps: "OAuth 2.0 mentioned 5 times, no entity page"

### Evidence Schema Extension

Wiki pages support conversation evidence alongside source evidence:

```yaml
claims:
  - text: "Identity enables attack lifecycle disruption"
    evidence:
      - kind: source
        sourceId: nist-sp-800-207
        path: sources/nist-sp-800-207-zero-trust-architecture.md
        lines: "42-48"
        weight: 1.0
        confidence: 0.95
      - kind: conversation  # <-- NEW
        path: memory/.dreams/session-corpus/2026-05-03.txt
        lines: "114-118"
        context: "Discussion with Jim about identity as IPI defense"
        weight: 0.8
        confidence: 0.75
```

## Entity vs Synthesis Distinction

**This was the source of confusion:** everything was being filed as syntheses.

### Create an Entity Page When:
- It's a core concept referenced across multiple sources/syntheses
- It needs a canonical definition (technologies, protocols, platforms, security models)
- Other pages will link to it with `[[Entity Name]]`
- Examples: `[[Kagenti]]`, `[[SPIFFE]]`, `[[MCP]]`, `[[Kubernetes]]`, `[[OAuth 2.0]]`

### Create a Synthesis When:
- You're integrating insights from multiple sources
- You're analyzing relationships, comparisons, or implications
- It's a one-time deep dive or thematic exploration
- Examples: "Kagenti MCP Security Architecture", "Workload Identity Claude vs OpenClaw"

**Location:**
- Entity pages: `/entities/` directory in wiki vault
- Syntheses: `/syntheses/` directory in wiki vault

## Karpathy Layer 2 Model

The wiki vault IS Karpathy's Layer 2:

**Layer 1: Raw Sources** (immutable, read-only)
- Lives in `~/workspaces/research/sources/`
- Academic papers, blog posts, transcripts, documentation
- Never modified by the LLM
- Ingested once, referenced forever

**Layer 2: The Wiki** (LLM-maintained, persistent)
- Lives in `/home/claw/.openclaw/workspace/wiki/`
- Two types of pages:
  - **Entities** (`entities/`) — canonical pages for core concepts
  - **Syntheses** (`syntheses/`) — analyses integrating multiple sources
- Cross-referenced via wikilinks (`[[Entity Name]]`)
- Use `wiki_apply` to create/update with structured claims and evidence

**Layer 3: The Schema** (AGENTS.md, TOOLS.md, SOUL.md)
- Defines workflows, conventions, and how you maintain the wiki

## Automated Dream Mining

### Wiki Dream Miner Skill

A skill that automatically mines dream logs for wiki-worthy insights:

**What it does:**
1. Scans past N days of dream logs (default: 7)
2. Extracts candidates with confidence ≥ 0.75 and substantive technical content
3. Matches candidates to existing wiki entities/syntheses
4. Auto-files conversation evidence for claims that are strengthened
5. Reports summary of pages enriched

**Configuration:**
```yaml
lookbackDays: 7
minConfidence: 0.75
minLength: 50
wikiSearchThreshold: 0.7
dryRun: false
```

**Cron Setup:**
```yaml
schedule: "0 4 * * 0"  # Sundays at 4:00 AM ET
payload:
  kind: agentTurn
  message: "Run wiki-dream-miner skill to enrich wiki with past week's conversation insights"
sessionTarget: isolated
delivery:
  mode: announce
  channel: telegram
```

### Guardrails

- Minimum confidence: 0.75 for auto-filing to wiki
- Only strengthen existing claims (no auto-entity creation)
- Audit trail: conversation evidence clearly marked with provenance
- Separate rendering: conversation evidence visually distinct from source evidence

## Benefits

1. **Conversations become first-class research artifacts** — Your thinking process is captured alongside formal sources
2. **Evidence compounds automatically** — Wiki pages strengthen as discussions reinforce claims
3. **Emergent insights get captured** — Novel connections from conversations don't disappear
4. **Scales with wiki growth** — Automatic enrichment prevents manual curation bottleneck

## Real-World Validation

**May 2026 Scan Results (15 days):**
- 2 high-value candidates identified and filed
- Zero Trust Architecture entity enriched with:
  - Identity as IPI defense discussion (confidence 0.80)
  - Agent harness ZTA requirements checklist (confidence 0.78)
- ~47,000 lines filtered as noise (operational chatter, already-captured content)

## Implementation Status

**Current:** Manual execution via `wiki-dream-miner` skill  
**Automated:** Weekly cron job configured (Sundays 4am ET)  
**Future:** Native integration into OpenClaw memory-core dreaming pipeline

## Related

- `ingestion-workflows.md` — Source ingestion process
- `primer.md` — Memory architecture overview
- Architecture decision: `memory/2026-05-12/wiki-dreaming-architecture-decision.md` (research workspace)
- Scan results: `memory/2026-05-12/wiki-dream-miner-scan-results.md` (research workspace)
