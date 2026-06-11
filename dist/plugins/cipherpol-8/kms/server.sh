#!/usr/bin/env bash
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
export KMS_DB_PATH="$PLUGIN_ROOT/chroma"
export PYTHONPATH="$PLUGIN_ROOT"
export CP8_ENABLE_LOGGING="${CP8_ENABLE_LOGGING:-false}"
export CP8_LOG_MAX_MB="${CP8_LOG_MAX_MB:-10}"

# Resolve python3 across common version managers without requiring a login shell.
_find_python3() {
  command -v python3 2>/dev/null && return
  local _candidates=(
    "$HOME/.pyenv/shims/python3"
    "$HOME/.asdf/shims/python3"
    "$HOME/.rye/shims/python3"
    "$HOME/.local/bin/python3"
    "$HOME/opt/miniconda3/bin/python3"
    "$HOME/miniconda3/bin/python3"
    "$HOME/anaconda3/bin/python3"
    "/opt/homebrew/bin/python3"
    "/usr/local/bin/python3"
    "/usr/bin/python3"
  )
  for _p in "${_candidates[@]}"; do [ -x "$_p" ] && echo "$_p" && return; done
}
PYTHON3=$(_find_python3)
[ -z "$PYTHON3" ] && { echo "[cp8] ERROR: python3 not found. Install Python 3.9+." >&2; exit 1; }

# Kill stale KMS server processes from older plugin versions.
for _pid in $(pgrep -f "kms.application.mcp_server" 2>/dev/null); do
  lsof -p "$_pid" 2>/dev/null | grep -q "$PLUGIN_ROOT" || kill "$_pid" 2>/dev/null
done

if ! "$PYTHON3" -c "import chromadb, yaml, mcp" 2>/dev/null; then
  echo "[cp8] Installing dependencies (one-time)..." >&2
  "$PYTHON3" -m pip install -q -r "$PLUGIN_ROOT/kms/requirements.txt" >&2 \
    || { echo "[cp8] ERROR: pip install failed. Run: pip install chromadb PyYAML mcp" >&2; exit 1; }
fi

exec "$PYTHON3" -m kms.application.mcp_server
