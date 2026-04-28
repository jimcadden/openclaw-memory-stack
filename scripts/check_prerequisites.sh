#!/usr/bin/env bash
# check_prerequisites.sh - Validate environment for advanced memory system

set -euo pipefail

echo "=== Prerequisites Check ==="
echo

# Detect OS
OS="$(uname -s)"
echo "→ Operating system: $OS"
echo

# Check OpenClaw version
echo "→ OpenClaw version:"
openclaw --version || { echo "❌ OpenClaw not found"; exit 1; }
echo

# Check for required commands
echo "→ Checking required tools:"
for cmd in jq git node npm; do
  if command -v "$cmd" &> /dev/null; then
    echo "  ✅ $cmd"
  else
    echo "  ❌ $cmd (required)"
    exit 1
  fi
done
echo

# macOS-specific: check SQLite extensions support
if [[ "$OS" == "Darwin" ]]; then
  echo "→ macOS-specific checks:"
  if command -v brew &> /dev/null; then
    echo "  ✅ Homebrew available"
    if brew list sqlite &> /dev/null 2>&1; then
      echo "  ✅ Homebrew SQLite installed (allows extensions)"
    else
      echo "  ⚠️  Homebrew SQLite not installed (system SQLite blocks extensions)"
      echo "     Run: brew install sqlite"
    fi
  else
    echo "  ⚠️  Homebrew not found — system SQLite may not support extensions"
    echo "     Install Homebrew: https://brew.sh"
  fi
  echo
fi

# Check permissions
echo "→ Checking permissions:"
if [[ -w ~/.openclaw ]]; then
  echo "  ✅ ~/.openclaw writable"
else
  echo "  ❌ ~/.openclaw not writable"
  exit 1
fi
echo

# Check workspace
WORKSPACE="${OPENCLAW_WORKSPACE:-~/.openclaw/workspace}"
if [[ -d "$WORKSPACE" ]]; then
  echo "  ✅ Workspace exists: $WORKSPACE"
else
  echo "  ⚠️  Workspace not found: $WORKSPACE"
fi
echo

# Check memory system status
echo "→ Checking memory system:"
openclaw memory status 2>&1 | head -5 || echo "  ⚠️  Memory system not responding"

echo
echo "→ Note: memory-core and memory-wiki are built-in plugins."
echo "  They just need to be enabled in config."
echo

echo "=== Prerequisites check complete ==="
