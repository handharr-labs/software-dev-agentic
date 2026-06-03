#!/usr/bin/env bash
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
export KMS_DB_PATH="$PLUGIN_ROOT/chroma"
export KMS_KNOWLEDGE_DIR="$PLUGIN_ROOT/knowledge"
export PYTHONPATH="$PLUGIN_ROOT"

# Auto-install deps on first run — no-op if already satisfied.
if ! python3 -c "import chromadb, yaml, mcp" 2>/dev/null; then
  echo "[kms] Installing dependencies (one-time)..." >&2
  pip3 install -q -r "$PLUGIN_ROOT/kms/requirements.txt" >&2 \
    || { echo "[kms] ERROR: pip install failed. Run: pip install chromadb PyYAML mcp" >&2; exit 1; }
fi

exec python3 -m kms.application.mcp_server
