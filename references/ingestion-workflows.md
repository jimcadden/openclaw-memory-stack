# Ingestion Workflows

How to move external sources (articles, papers, web content) into the memory system.

## Default Workflow: Ingest + Synthesize

When the user shares a source, the default action is both:

1. **Ingest the raw source** into the wiki `sources/` layer (full preservation)
2. **Write a synthesis** with structured claims into `syntheses/` (high-signal knowledge)

This gives full-text search over the original material AND structured claims for tracking and retrieval.

## How to Route by Intent

| User says | Action |
|-----------|--------|
| "Read this and save it" | Ingest raw source + write synthesis |
| "Save this for later" | Ingest raw source only (no synthesis) |
| "What does this say about X?" | Read, answer the question, ingest + save key findings |
| "Add this to our research on [topic]" | Ingest, synthesize, link to relevant entity/concept pages |
| "Summarize this" | Write synthesis to daily notes or wiki (no raw ingest unless URL) |

## By Source Type

### Web Articles and Blog Posts

```bash
# Ingest via CLI (creates source page with provenance)
openclaw wiki ingest https://example.com/article

# Then synthesize
openclaw wiki apply synthesis "Article Title" \
  --body "Key findings..." \
  --source-id source.article-slug
```

Or conversationally: the agent reads the URL with `web_fetch`, creates the source page, then writes a synthesis with structured claims.

### PDFs and Academic Papers

The memory system indexes Markdown, not PDFs. Convert first:

```bash
# Pandoc (preserves structure)
pandoc paper.pdf -o ~/papers/paper-name.md

# pdftotext (simpler)
pdftotext paper.pdf ~/papers/paper-name.md
```

Then either:
- Drop into an indexed `extraPaths` folder for automatic indexing
- Ask the agent to ingest + synthesize from the converted Markdown

### Pasted Text / Excerpts

When the user pastes content directly in chat:
1. Save the excerpt as a wiki source page
2. Write a synthesis or add to an existing concept/entity page
3. Key findings flow into daily notes from the discussion

### Research Directories (Bulk)

For large collections, point the index at the directory:

**Builtin engine:**
```json
{
  "agents": {
    "defaults": {
      "memorySearch": {
        "extraPaths": ["~/research", "~/papers"]
      }
    }
  }
}
```

**QMD:**
```json
{
  "memory": {
    "qmd": {
      "paths": [
        { "name": "papers", "path": "~/papers", "pattern": "**/*.md" }
      ]
    }
  }
}
```

Directories are scanned recursively for `.md` files. New files are picked up automatically on the next index cycle (QMD: every 5 minutes; builtin: on-demand or `openclaw memory index --force`).

## Wiki Vault Structure

Sources flow through the wiki vault like this:

```
sources/     ← Raw imported material (full text, provenance tracked)
     ↓
syntheses/   ← Structured summaries with claims and evidence
     ↓
entities/    ← People, systems, projects, tools
concepts/    ← Ideas, patterns, methodologies, theories
     ↓
reports/     ← Auto-generated dashboards (contradictions, open questions, stale pages)
```

## Parallel Memory Paths

External sources also flow through the memory system in parallel:

```
Source ingested
  ├→ Wiki: sources/ → syntheses/ → entities/concepts/
  ├→ Discussion: daily notes (memory/YYYY-MM-DD.md)
  ├→ Session transcripts (auto-indexed if sessionMemory enabled)
  └→ Dreaming: promotes durable findings → MEMORY.md
```

All paths are searchable via `memory_search corpus=all`.

## Best Practices

- **Always ingest the raw source** when a URL or full text is available — information lost is gone forever
- **Write syntheses with claims** so findings are trackable and contestable
- **Link syntheses to entities/concepts** to build a connected knowledge graph
- **Let dreaming handle promotion** — don't manually copy findings to MEMORY.md unless they're urgent
- **Run `wiki lint`** after meaningful wiki changes to surface contradictions and open questions
- **Use `wiki compile`** after bulk imports for fresh dashboards and digests
