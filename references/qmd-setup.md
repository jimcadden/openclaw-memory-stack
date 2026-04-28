# QMD Backend Setup (Optional)

QMD is a local-first search sidecar that replaces the builtin SQLite engine with reranking, query expansion, and extended directory indexing. This is an **optional upgrade** — the builtin engine works fine for most setups. Consider QMD when you need maximum research recall.

## When to use QMD

Choose QMD over the builtin engine when:
- You need **reranking** for higher-precision results
- You want **query expansion** ("transformer attention" → also finds "self-attention heads")
- You need to **index directories outside the workspace** (papers, project docs, team notes)
- You want **session transcript search** via QMD's own collection system
- You prefer **fully local search** with no API keys

If the builtin engine with hybrid search meets your needs, skip this.

## Prerequisites

1. Install QMD:
   ```bash
   npm install -g @tobilu/qmd
   # or
   bun install -g @tobilu/qmd
   ```

2. Verify QMD is on the gateway's PATH:
   ```bash
   which qmd
   ```
   If OpenClaw runs as a service, you may need a symlink:
   ```bash
   sudo ln -s ~/.bun/bin/qmd /usr/local/bin/qmd
   ```

3. SQLite must allow extensions (`brew install sqlite` on macOS)

4. Supported: macOS, Linux (Windows via WSL2)

## Configuration

Apply `qmd_research.json` from the config patches, or set manually:

```json
{
  "memory": {
    "backend": "qmd",
    "qmd": {
      "paths": [
        { "name": "research", "path": "~/research", "pattern": "**/*.md" },
        { "name": "papers", "path": "~/papers", "pattern": "**/*.md" }
      ],
      "sessions": {
        "enabled": true
      }
    }
  }
}
```

### Key settings

| Setting | Path | Description |
|---------|------|-------------|
| Backend selection | `memory.backend` | Set to `"qmd"` |
| Extra directories | `memory.qmd.paths[]` | Named collections for dirs outside workspace |
| Session indexing | `memory.qmd.sessions.enabled` | Index past conversation transcripts |
| Search timeout | `memory.qmd.limits.timeoutMs` | Default 4000ms; increase for slow hardware |
| Search scope | `memory.qmd.scope` | Controls which chat types can search (default: direct + channel) |

### How it works

- OpenClaw creates QMD collections from workspace memory files + configured `paths`
- Runs `qmd update` + `qmd embed` on boot and every 5 minutes
- Default workspace collection tracks `MEMORY.md` + `memory/` tree
- Boot refresh runs in background (doesn't block chat startup)
- If QMD fails entirely, falls back to builtin SQLite engine automatically

### Model overrides

QMD auto-downloads GGUF models (~2GB) on first use. Override with environment variables:

```bash
export QMD_EMBED_MODEL="hf:Qwen/Qwen3-Embedding-0.6B-GGUF/Qwen3-Embedding-0.6B-Q8_0.gguf"
export QMD_RERANK_MODEL="/path/to/reranker.gguf"
export QMD_GENERATE_MODEL="/path/to/generator.gguf"
```

## Recommended pattern: QMD + memory-wiki bridge

The docs recommend this as the ideal local-first setup:

- **QMD** handles recall, semantic search, reranking, and query expansion
- **memory-wiki** in bridge mode compiles structured knowledge pages from QMD's artifacts

Each layer stays focused:
- QMD keeps raw notes, session exports, and extra collections searchable
- memory-wiki compiles stable entities, claims, dashboards, and source pages

The `qmd_research.json` config patch sets up this exact pattern.

## Verification

After applying config and restarting:

```bash
# Check QMD is detected
openclaw memory status --deep

# Force initial index build
openclaw memory index --force --verbose

# Test a search
openclaw memory search "your research topic"
```

## Troubleshooting

| Issue | Fix |
|-------|-----|
| QMD not found | Ensure binary is on gateway's PATH; symlink if running as service |
| First search very slow | Normal — QMD downloads GGUF models on first use; pre-warm with `qmd query "test"` |
| Search times out | Increase `memory.qmd.limits.timeoutMs` (try 120000 for slow hardware) |
| Empty results in groups | Check `memory.qmd.scope` — default only allows direct + channel sessions |
| `ENAMETOOLONG` errors | Keep temp repos under hidden dirs or outside QMD roots |

## Related docs

- [QMD Memory Engine](https://docs.openclaw.ai/concepts/memory-qmd)
- [Memory Configuration Reference](https://docs.openclaw.ai/reference/memory-config)
