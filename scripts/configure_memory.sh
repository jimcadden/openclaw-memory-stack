#!/usr/bin/env bash
# configure_memory.sh - Apply memory system configuration

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Configuring Memory System ==="
echo

# Check if config patches exist
if [[ ! -d "$SKILL_DIR/assets/config_patches" ]]; then
  echo "❌ Config patches not found"
  exit 1
fi

echo "→ Backing up current config..."
cp ~/.openclaw/config.json ~/.openclaw/config.json.backup."$(date +%s)"
echo "  ✅ Backup saved"
echo

echo "→ Available config patches:"
echo "  1. memory_search.json - Enable session memory, MMR, temporal decay"
echo "  2. dreaming.json - Enable nightly dreaming (3am ET)"
echo "  3. memory_wiki.json - Enable wiki bridge mode with dashboards"
echo "  4. full_stack.json - Apply all patches (general-purpose)"
echo "  5. research_optimized.json - Full stack tuned for research (recommended for research bots)"
echo "  6. qmd_research.json - QMD backend + wiki bridge (optional, max research recall)"
echo

read -p "Select patch to apply (1-6): " -n 1 -r
echo

case $REPLY in
  1)
    PATCH="memory_search.json"
    ;;
  2)
    PATCH="dreaming.json"
    ;;
  3)
    PATCH="memory_wiki.json"
    ;;
  4)
    PATCH="full_stack.json"
    ;;
  5)
    PATCH="research_optimized.json"
    ;;
  6)
    PATCH="qmd_research.json"
    ;;
  *)
    echo "Invalid selection"
    exit 1
    ;;
esac

echo "→ Selected: $PATCH"
echo
echo "Config to apply:"
cat "$SKILL_DIR/assets/config_patches/$PATCH"
echo

echo "⚠️  To apply this config:"
echo "  1. Use the 'gateway' tool with action='config.patch'"
echo "  2. Pass the JSON above as the 'raw' parameter"
echo "  3. Gateway will hot-reload if possible, or schedule a restart"
echo "  4. Note: Gateway restart requires manual approval from Jim"
echo
echo "Example (for agents):"
echo "  gateway(action='config.patch', raw='<paste JSON here>')"

