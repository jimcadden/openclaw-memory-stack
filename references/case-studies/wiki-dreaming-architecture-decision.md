# Wiki-Dreaming Integration Architecture Decision
**Date:** 2026-05-12  
**Decision:** Option A - Dreaming as Wiki Enrichment Engine

## The Vision

Dreaming becomes the process that mines conversations for wiki-worthy knowledge, creating a feedback loop between session transcripts and the research knowledge base.

## Current State (Separated Systems)

**Dreaming Pipeline:**
```
Session transcripts → Light sleep (extract candidates)
                   → Deep sleep (rank/promote to MEMORY.md)
                   → REM sleep (patterns)
```

**Wiki Pipeline:**
```
Raw sources → Read/extract → wiki_apply (create syntheses)
```

**Problem:** They don't interact. Valuable insights from conversations (like the May 3rd identity discussion) sit in dreaming logs instead of enriching wiki entities.

## Target Architecture

### Wiki-Aware Dreaming Flow

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

Wiki pages would support conversation evidence alongside source evidence:

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
      - kind: conversation
        path: memory/.dreams/session-corpus/2026-05-03.txt
        lines: "114-118"
        context: "Discussion with Jim about identity as IPI defense"
        weight: 0.8
        confidence: 0.75
```

## Benefits

1. **Conversations become first-class research artifacts** - Your thinking process is captured alongside formal sources
2. **Evidence compounds automatically** - Wiki pages strengthen as discussions reinforce claims
3. **Emergent insights get captured** - Novel connections from conversations don't disappear
4. **Scales with wiki growth** - Automatic enrichment prevents manual curation bottleneck

## Guardrails

- Minimum confidence: 0.75 for auto-filing to wiki
- Only strengthen existing claims (no auto-entity creation)
- Audit trail: conversation evidence clearly marked with provenance
- Separate rendering: conversation evidence visually distinct from source evidence

## Implementation Requirements

This requires changes to OpenClaw memory core:

1. **Wiki query capability in dreaming pipeline**
   - Light sleep needs `wiki_search` access
   - Entity/synthesis awareness during candidate extraction

2. **Wiki write capability from dreaming**
   - Deep sleep needs ability to call `wiki_apply` with conversation evidence
   - Structured evidence format support

3. **Conversation evidence schema**
   - Extend wiki evidence types to include `kind: conversation`
   - Support session corpus references

4. **Review/approval workflow** (future)
   - Queue for human review of suggested wiki updates
   - Audit log of dream-sourced wiki changes

## Migration Path

**Phase 1 (Current):** Document architecture decision, update AGENTS.md
**Phase 2:** Request feature in OpenClaw core or build as plugin
**Phase 3:** Backfill valuable conversation fragments from existing dream logs
**Phase 4:** Enable wiki-aware dreaming for future sessions

## Related

- Karpathy's Layer 2 model: LLM-maintained knowledge base
- Thread memory: Each thread has MEMORY.md, should it also enrich shared wiki?
- Bridge imports: Still valuable for search, but filtered from wiki vault proper
