#!/usr/bin/env bash
# force_reindex.sh - Force reindex memory files for one or all agents

set -euo pipefail

AGENT="${1:-all}"

echo "=== Force Reindex ==="
echo

if [[ "$AGENT" == "all" ]]; then
  echo "→ Discovering agents..."
  # Get list of all agents from openclaw memory status or config
  AGENTS=$(openclaw memory status --json 2>/dev/null | jq -r '.agents | keys[]' 2>/dev/null || echo "main security")
  
  echo "Found agents: $AGENTS"
  echo
  
  for agent in $AGENTS; do
    echo "→ Reindexing $agent workspace..."
    if [[ "$agent" == "main" ]]; then
      openclaw memory index --force 2>&1 | head -5 || echo "⚠️  Failed to reindex $agent"
    else
      openclaw memory index --agent "$agent" --force 2>&1 | head -5 || echo "⚠️  Failed to reindex $agent"
    fi
    echo
  done
  
  echo "✅ All agents reindexed"
else
  echo "→ Reindexing $AGENT workspace..."
  if [[ "$AGENT" == "main" ]]; then
    openclaw memory index --force
  else
    openclaw memory index --agent "$AGENT" --force
  fi
  echo
  echo "✅ Reindex complete for $AGENT"
fi
