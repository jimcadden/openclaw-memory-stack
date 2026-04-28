# Research-Optimized Memory Configuration

This document explains the tuning choices in `research_optimized.json` and how they differ from the general-purpose `full_stack.json` defaults.

---

## At a Glance

| Setting | General-Purpose | Research-Optimized | Why |
|---------|----------------|-------------------|-----|
| Embedding provider | `local` | `openai` | Better recall on technical/academic content |
| Temporal decay halfLife | 30 days | 365 days | Research findings stay relevant for months |
| MMR lambda | 0.7 | 0.4 | Prioritize diverse results over redundant top hits |
| extraPaths | none | `~/research`, `~/papers` | Index research material outside the workspace |
| Wiki URL ingest | off | on | Import web sources directly into wiki |
| Wiki compiled digest prompt | off | on | Inject top wiki knowledge into agent context |

---

## Detailed Rationale

### 1. Embedding Provider (`provider: "openai"`)

**Config path:** `agents.defaults.memorySearch.provider`

The default `local` provider uses a ~0.6GB GGUF model optimized for size and speed. For general assistant tasks, it's fine. For research, API-based embeddings significantly outperform on:

- Technical jargon (AI architectures, protocols, academic terms)
- Cross-domain semantic matching ("attention mechanism" ↔ "self-attention heads")
- Long-tail concepts that small models haven't seen enough of

**Alternatives:**
- `openai` — Fast, high quality, requires `OPENAI_API_KEY`
- `gemini` — Supports multimodal (image/audio) indexing, requires `GEMINI_API_KEY`
- `voyage` — Strong on technical content, requires `VOYAGE_API_KEY`
- `bedrock` — No API key (uses AWS credential chain)

**Switching providers triggers a full reindex.** Plan accordingly.

See: [Memory Search Providers](/concepts/memory-search)

### 2. Temporal Decay (`halfLifeDays: 365`)

**Config path:** `agents.defaults.memorySearch.query.hybrid.temporalDecay`

Default is 30 days — a note from last month scores at 50% weight. This makes sense for a personal assistant (today's grocery list > last month's). For research:

- A paper you read 3 months ago is just as relevant today
- Foundational concepts discovered early shouldn't fade
- Research builds cumulatively; older findings inform newer ones

At 365 days, a 6-month-old note retains ~70% of its weight. Set to even higher or disable entirely (`enabled: false`) if your research spans years.

**Note:** `MEMORY.md` and non-dated files in `memory/` are never decayed regardless of this setting.

### 3. MMR Lambda (`lambda: 0.4`)

**Config path:** `agents.defaults.memorySearch.query.hybrid.mmr`

MMR (Maximal Marginal Relevance) balances relevance vs. diversity in results:
- `lambda: 1.0` = pure relevance (may return 5 near-identical snippets)
- `lambda: 0.0` = pure diversity (may miss the most relevant hit)
- `lambda: 0.7` = general-purpose default
- **`lambda: 0.4` = research-optimized**

When you search "agent memory architecture," you want results spanning:
- Different papers or sources
- Different architectural approaches
- Different time periods of your research
- Different angles (theory, implementation, evaluation)

Lower lambda ensures this spread.

### 4. Extra Paths (`extraPaths`)

**Config path:** `agents.defaults.memorySearch.extraPaths`

By default, memory only indexes the agent workspace. Research material often lives elsewhere:

```json
"extraPaths": ["~/research", "~/papers"]
```

- Paths can be absolute or workspace-relative
- Directories are scanned recursively for `.md` files
- Adjust these paths to match your actual research directory structure

**For broader indexing** (non-Markdown files, advanced scanning), consider the QMD backend instead. QMD supports reranking, query expansion, and indexing directories with its own scanner.

### 5. Wiki URL Ingest (`allowUrlIngest: true`)

**Config path:** `plugins.entries.memory-wiki.config.ingest.allowUrlIngest`

Allows importing web pages directly into wiki source pages:

```bash
openclaw wiki ingest https://arxiv.org/abs/2401.12345
```

Useful for building a research knowledge base from online sources with full provenance tracking.

### 6. Compiled Digest Prompt (`includeCompiledDigestPrompt: true`)

**Config path:** `plugins.entries.memory-wiki.config.context.includeCompiledDigestPrompt`

When enabled, a compact snapshot of top wiki pages, claims, and contradictions is injected into the agent's context at session start. This means the agent always has a high-level view of the research knowledge base without needing to explicitly search.

**Tradeoff:** Uses additional context tokens. Worth it for research where the wiki accumulates meaningful structured knowledge.

---

## Optional Upgrades

### QMD Backend

For maximum research recall, consider switching from the builtin SQLite engine to QMD:

```json
{
  "agents": {
    "defaults": {
      "memorySearch": {
        "provider": "qmd"
      }
    }
  }
}
```

QMD adds:
- **Reranking** — re-scores results with a cross-encoder for higher precision
- **Query expansion** — "transformer attention" also finds "multi-head self-attention"
- **Extra collections** — index directories outside the workspace with named collections

The recommended pattern from the docs: **QMD for recall + memory-wiki in bridge mode for structured knowledge.**

See: [QMD Memory Engine](/concepts/memory-qmd)

### Multimodal Indexing (Gemini only)

Index images (architecture diagrams, screenshots) alongside text:

```json
{
  "agents": {
    "defaults": {
      "memorySearch": {
        "provider": "gemini",
        "model": "gemini-embedding-2-preview",
        "multimodal": {
          "enabled": true,
          "modalities": ["image"]
        }
      }
    }
  }
}
```

**Note:** Only applies to files in `extraPaths`. Requires `gemini-embedding-2-preview` model.

See: [Memory Configuration Reference](/reference/memory-config)

### Lower Promotion Thresholds

Default deep phase thresholds (minScore=0.8, minRecallCount=3, minUniqueQueries=3) are strict. Research insights may only surface once before going dormant. If important findings aren't getting promoted, use CLI overrides:

```bash
openclaw memory promote --min-score 0.6 --min-recall-count 1 --apply
```

**Note:** Promotion thresholds are internal phase policy and not directly user-configurable in `openclaw.json`. Use CLI flags for manual overrides.

---

## Quick Reference: Config Paths

| Setting | Path |
|---------|------|
| Embedding provider | `agents.defaults.memorySearch.provider` |
| Embedding model | `agents.defaults.memorySearch.model` |
| Extra index paths | `agents.defaults.memorySearch.extraPaths` |
| Session transcript indexing | `agents.defaults.memorySearch.experimental.sessionMemory` |
| Hybrid search | `agents.defaults.memorySearch.query.hybrid` |
| MMR diversity | `agents.defaults.memorySearch.query.hybrid.mmr` |
| Temporal decay | `agents.defaults.memorySearch.query.hybrid.temporalDecay` |
| Dreaming | `plugins.entries.memory-core.config.dreaming` |
| Wiki plugin | `plugins.entries.memory-wiki.config` |
| Wiki vault mode | `plugins.entries.memory-wiki.config.vaultMode` |
| Wiki bridge settings | `plugins.entries.memory-wiki.config.bridge` |
| Wiki digest prompt | `plugins.entries.memory-wiki.config.context.includeCompiledDigestPrompt` |
