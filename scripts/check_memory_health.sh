#!/usr/bin/env bash
# check_memory_health.sh - Weekly memory health audit

set -euo pipefail

# Detect log path (differs by OS)
if [[ -d /tmp/openclaw ]]; then
  LOG_DIR="/tmp/openclaw"
elif [[ -d ~/Library/Logs/openclaw ]]; then
  LOG_DIR="$HOME/Library/Logs/openclaw"
else
  LOG_DIR="/tmp/openclaw"
fi
LOG_FILE="$LOG_DIR/openclaw-$(date +%Y-%m-%d).log"

echo "=== Memory Health Check ==="
echo

# Check overall status
echo "→ Memory status:"
openclaw memory status --json 2>/dev/null || {
  echo "⚠️  CLI timeout — checking gateway logs instead"
  if [[ -f "$LOG_FILE" ]]; then
    tail -20 "$LOG_FILE" | grep -i memory || echo "No recent memory logs"
  else
    echo "Log file not found: $LOG_FILE"
  fi
}

echo
echo "→ Checking for dirty workspaces:"
openclaw memory status | grep -i dirty || echo "✅ All clean"

echo
echo "→ Checking dreaming schedule:"
openclaw memory status | grep -i dreaming || echo "⚠️  Dreaming status not found"

echo
echo "→ Recent dreaming errors:"
if [[ -f "$LOG_FILE" ]]; then
  grep -i "dream\|cron" "$LOG_FILE" | tail -10 || echo "✅ No errors"
else
  echo "⚠️  Log file not found: $LOG_FILE"
fi

echo
echo "→ Session memory indexing:"
openclaw memory status | grep -i sessionMemory || echo "⚠️  sessionMemory not in sources"

echo
echo "=== Health check complete ==="
