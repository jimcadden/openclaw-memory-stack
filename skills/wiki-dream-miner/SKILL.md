# Wiki Dream Miner Skill

## Purpose

Mine recent dreaming logs for wiki-worthy conversation fragments and auto-file them as conversation evidence to relevant wiki entities/syntheses.

Implements the wiki-aware dreaming architecture (Option A) using existing OpenClaw tools.

## When to Use

- **Manual:** Run when you want to enrich wiki with recent conversation insights
- **Cron:** Set up nightly after dreaming completes (e.g., 3:30am ET)
- **Backfill:** Process historical dream logs to extract valuable fragments

## How It Works

### Step 1: Read Recent Dream Logs

Scan `memory/dreaming/light/*.md` and `memory/dreaming/deep/*.md` from the past N days (default: 7).

Extract candidates that have:
- Confidence score
- Evidence reference to session corpus
- Substantive text (not "Good morning" / "Test 123")

### Step 2: Filter for Wiki-Worthiness

**Keep candidates that:**
- Confidence >= 0.75
- Text contains technical/research content
- Length > 50 chars
- Not purely operational ("I'll update the config...")

**Skip candidates that:**
- Confidence < 0.75
- Trivial exchanges (greetings, acknowledgments)
- Pure process notes (dreaming metadata, empty results)

### Step 3: Match to Wiki Pages

For each wiki-worthy candidate:

1. **Search wiki** with candidate text
2. Find relevant entities/syntheses (score > 0.7)
3. **Read those pages** to understand existing claims
4. **Determine relationship:**
   - Strengthens existing claim → auto-file as evidence
   - Contradicts claim → flag for review (don't auto-file)
   - New concept → suggest entity creation (don't auto-file)
   - No match → skip

### Step 4: File Conversation Evidence

For candidates that strengthen existing claims:

Use `wiki_apply` to add conversation evidence:

```yaml
evidence:
  - kind: conversation
    path: memory/.dreams/session-corpus/YYYY-MM-DD.txt
    lines: "114-118"
    context: "Brief human-readable context from conversation"
    weight: 0.8
    confidence: 0.75
```

### Step 5: Report Results

Output summary:
- X candidates processed
- Y filed as wiki evidence
- Z flagged for review
- List of enriched wiki pages

## Configuration

```yaml
lookbackDays: 7          # How far back to scan dream logs
minConfidence: 0.75      # Minimum confidence for auto-filing
minLength: 50            # Minimum candidate text length
wikiSearchThreshold: 0.7 # Minimum search score for wiki match
dryRun: false            # Set true to preview without filing
```

## Cron Setup Example

```yaml
schedule:
  kind: cron
  expr: "30 3 * * *"     # 3:30am ET, after dreaming completes
  tz: "America/New_York"
payload:
  kind: agentTurn
  message: "Run the wiki-dream-miner skill to enrich wiki with last night's insights"
sessionTarget: isolated
delivery:
  mode: announce
  channel: telegram
  to: "5328644515"
```

## Manual Usage

Just ask:
- "Mine recent dream logs for wiki insights"
- "Run wiki dream miner for the past week"
- "Backfill dream logs from May 1-10 into wiki"

## Safety Guardrails

1. **No entity creation** - Only strengthen existing claims, don't create new pages
2. **Contradiction flagging** - Don't auto-file if it contradicts existing claims
3. **Audit trail** - Every conversation evidence block includes full provenance
4. **Dry run mode** - Preview changes before filing
5. **Confidence threshold** - Only high-confidence (>0.75) candidates auto-file

## Future Enhancements

- **Human review queue** - Flagged contradictions/new concepts go to review list
- **Cross-reference suggestions** - "This candidate mentions [[OAuth 2.0]] 5 times, suggest creating entity?"
- **Evidence deduplication** - Don't file the same conversation fragment twice
- **Session thread awareness** - Track which thread/channel conversation came from

## Related

- Architecture decision: `memory/2026-05-12/wiki-dreaming-architecture-decision.md`
- AGENTS.md wiki workflow section
- Karpathy Layer 2 model
