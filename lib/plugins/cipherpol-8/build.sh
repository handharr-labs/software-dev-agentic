#!/usr/bin/env bash
# lib/plugins/cipherpol-8/build.sh
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
cp -r "$SUBMODULE/kms" "$out/kms"
rm -rf "$out/kms/db"

# ── Launcher script ───────────────────────────────────────────────────────────
cat > "$out/kms/server.sh" <<'LAUNCHER'
#!/usr/bin/env bash
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
export KMS_DB_PATH="$PLUGIN_ROOT/chroma"
export PYTHONPATH="$PLUGIN_ROOT"
export CP8_ENABLE_LOGGING="${CP8_ENABLE_LOGGING:-false}"
export CP8_LOG_MAX_MB="${CP8_LOG_MAX_MB:-10}"

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
LAUNCHER
chmod +x "$out/kms/server.sh"

# ── ChromaDB ──────────────────────────────────────────────────────────────────
if [ -d "$SUBMODULE/kms/db" ]; then
  cp -r "$SUBMODULE/kms/db" "$out/chroma"
  echo "  chroma       bundled from kms/db"
else
  echo "  chroma       ⚠ missing — run: /kms-seed"
fi

# ── MCP template ──────────────────────────────────────────────────────────────
cat > "$out/kms/project-mcp-template.json" <<'MCP_TEMPLATE'
{
  "mcpServers": {
    "kms": {
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
