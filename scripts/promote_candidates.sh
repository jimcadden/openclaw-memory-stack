#!/usr/bin/env bash
# promote_candidates.sh - Review and optionally apply dreaming promotion candidates

set -euo pipefail

APPLY="${1:-}"
MIN_SCORE="${2:-0.8}"
LIMIT="${3:-10}"

echo "=== Promotion Candidates (minScore=$MIN_SCORE, limit=$LIMIT) ==="
echo

if [[ "$APPLY" == "--apply" ]]; then
  echo "⚠️  Applying promotions to MEMORY.md..."
  openclaw memory promote --limit "$LIMIT" --min-score "$MIN_SCORE" --apply
  echo "✅ Promotions applied"
else
  echo "→ Preview mode (use --apply to commit)"
  openclaw memory promote --limit "$LIMIT" --min-score "$MIN_SCORE"
fi

echo
echo "=== Done ==="
