#!/usr/bin/env bash
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
export KMS_DB_PATH="$PLUGIN_ROOT/chroma"
export PYTHONPATH="$PLUGIN_ROOT"
export KMS_ENABLE_LOGGING="${KMS_ENABLE_LOGGING:-false}"
export KMS_LOG_MAX_MB="${KMS_LOG_MAX_MB:-10}"

# Kill stale KMS server processes from older plugin versions.
for _pid in $(pgrep -f "kms.application.mcp_server" 2>/dev/null); do
  lsof -p "$_pid" 2>/dev/null | grep -q "$PLUGIN_ROOT" || kill "$_pid" 2>/dev/null
done

if ! python3 -c "import chromadb, yaml, mcp" 2>/dev/null; then
  echo "[kms] Installing dependencies (one-time)..." >&2
  pip3 install -q -r "$PLUGIN_ROOT/kms/requirements.txt" >&2 \
    || { echo "[kms] ERROR: pip install failed. Run: pip install chromadb PyYAML mcp" >&2; exit 1; }
fi

exec python3 -m kms.application.mcp_server
