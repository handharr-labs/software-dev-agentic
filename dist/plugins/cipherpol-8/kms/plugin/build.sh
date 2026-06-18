#!/usr/bin/env bash
# cipherpol-8-kms/plugin/build.sh
# Builds cipherpol-8 — ChromaDB MCP server for KMS knowledge retrieval.
# Called by scripts/build-plugin.sh. Expects $SUBMODULE and $VERSION to be set.

set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SUBMODULE/scripts/plugin-lib.sh"

NAME="$(config_field name)"
DESCRIPTION="$(config_field description)"
out="$SUBMODULE/dist/plugins/$NAME"

echo ""
echo "Building plugin: $NAME → dist/plugins/$NAME"

rm -rf "$out"
mkdir -p "$out/.claude-plugin"

write_manifest "$NAME" "$DESCRIPTION"

# ── KMS package ───────────────────────────────────────────────────────────────
cp -r "$SUBMODULE/cipherpol-8-kms" "$out/kms"
rm -rf "$out/kms/db"

# ── Launcher script ───────────────────────────────────────────────────────────
cat > "$out/kms/server.sh" <<'LAUNCHER'
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
LAUNCHER
chmod +x "$out/kms/server.sh"

# ── ChromaDB ──────────────────────────────────────────────────────────────────
if [ -d "$SUBMODULE/cipherpol-8-kms/db" ]; then
  cp -r "$SUBMODULE/cipherpol-8-kms/db" "$out/chroma"
  echo "  chroma       bundled from cipherpol-8-kms/db"
else
  echo "  chroma       ⚠ missing — run: /kms-seed"
fi

# ── MCP template ──────────────────────────────────────────────────────────────
cat > "$out/kms/project-mcp-template.json" <<'MCP_TEMPLATE'
{
  "mcpServers": {
    "cp8": {
      "command": "bash",
      "args": [
        "-c",
        "latest=$(ls \"$HOME/.claude/plugins/cache/cipherpol/cipherpol-8\" 2>/dev/null | sort -t. -k1,1n -k2,2n -k3,3n | tail -1) && exec bash \"$HOME/.claude/plugins/cache/cipherpol/cipherpol-8/$latest/kms/server.sh\""
      ],
      "env": {
        "CP8_ENABLE_LOGGING": "false",
        "CP8_LOG_MAX_MB": "10"
      }
    }
  }
}
MCP_TEMPLATE
echo "  mcp-template project-mcp-template.json written"
echo "  → test: claude --plugin-dir $out"

update_marketplace "$NAME" "./dist/plugins/$NAME" "$DESCRIPTION"
