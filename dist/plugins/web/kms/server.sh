#!/usr/bin/env bash
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
export KMS_DB_PATH="$PLUGIN_ROOT/chroma"
export PYTHONPATH="$PLUGIN_ROOT"
exec python3 -m kms.application.mcp_server
