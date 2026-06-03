#!/usr/bin/env bash
# build-plugin.sh
# Builds a platform-specific Claude Code plugin from lib/ source.
#
# Output: dist/plugins/<platform>/
# Test:   claude --plugin-dir dist/plugins/<platform>
# All:    scripts/build-plugin.sh --platform=all
#
# Usage:
#   software-dev-agentic/scripts/build-plugin.sh --platform=<platform>

set -euo pipefail

SUBMODULE="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(cat "$SUBMODULE/VERSION")"

# ── Args ─────────────────────────────────────────────────────────────────────

PLATFORM=""
for arg in "$@"; do
  case "$arg" in
    --platform=*) PLATFORM="${arg#--platform=}" ;;
  esac
done

if [ -z "$PLATFORM" ]; then
  echo "Error: --platform is required."
  echo "Usage: $0 --platform=<platform>|all"
  echo "Available: $(ls "$SUBMODULE/lib/platforms/" | tr '\n' ' ')"
  exit 1
fi

# ── Build one platform ────────────────────────────────────────────────────────

build_platform() {
  local platform="$1"
  local platform_dir="$SUBMODULE/lib/platforms/$platform"

  if [ ! -d "$platform_dir" ]; then
    echo "Error: platform '$platform' not found at $platform_dir"
    return 1
  fi

  local out="$SUBMODULE/dist/plugins/$platform"
  echo ""
  echo "Building plugin: $platform → dist/plugins/$platform"

  rm -rf "$out"
  mkdir -p "$out/.claude-plugin" "$out/agents" "$out/skills"

  # ── Manifest ────────────────────────────────────────────────────────────────
  cat > "$out/.claude-plugin/plugin.json" <<MANIFEST
{
  "name": "sda-${platform}",
  "description": "software-dev-agentic for ${platform} — builder, detective, tracker, auditor, installer personas",
  "version": "${VERSION}",
  "author": {
    "name": "Jurnal Engineering"
  }
}
MANIFEST
  echo "  manifest     sda-${platform}@${VERSION}"

  # ── Agents — flatten all (no subfolders → bare name resolution) ─────────────
  # Core agents: recurse persona subdirs, output flat so names stay bare
  find "$SUBMODULE/lib/core/agents" -name "*.md" -type f | while read -r src; do
    cp "$src" "$out/agents/$(basename "$src")"
  done
  # Platform agents: copy last so they overwrite core on name collision
  if [ -d "$platform_dir/agents" ]; then
    find "$platform_dir/agents" -name "*.md" -type f | while read -r src; do
      cp "$src" "$out/agents/$(basename "$src")"
    done
  fi
  local agent_count
  agent_count=$(find "$out/agents" -name "*.md" | wc -l | tr -d ' ')
  echo "  agents       $agent_count files (flat)"

  # ── Skills ──────────────────────────────────────────────────────────────────
  # 1. Core toolkit skills
  for skill_dir in "$SUBMODULE/lib/core/skills"/*/; do
    [ -d "$skill_dir" ] || continue
    cp -r "$skill_dir" "$out/skills/$(basename "$skill_dir")"
  done

  # 2. Platform contract skills (strip the contract/ grouping — lands flat)
  if [ -d "$platform_dir/skills/contract" ]; then
    for skill_dir in "$platform_dir/skills/contract"/*/; do
      [ -d "$skill_dir" ] || continue
      cp -r "$skill_dir" "$out/skills/$(basename "$skill_dir")"
    done
  fi

  # 3. Platform-only skills
  for skill_dir in "$platform_dir/skills"/*/; do
    [ -d "$skill_dir" ] || continue
    local name
    name="$(basename "$skill_dir")"
    [ "$name" = "contract" ] && continue
    [ -d "$out/skills/$name" ] && continue  # core takes precedence
    cp -r "$skill_dir" "$out/skills/$name"
  done

  local skill_count
  skill_count=$(ls "$out/skills" | wc -l | tr -d ' ')
  echo "  skills       $skill_count dirs"

  # ── Hooks ────────────────────────────────────────────────────────────────────
  local hook_scripts=()
  for f in "$SUBMODULE/lib/core/hooks"/*.sh; do
    [ -f "$f" ] && hook_scripts+=("$f")
  done
  if [ -d "$platform_dir/hooks" ]; then
    for f in "$platform_dir/hooks"/*.sh; do
      [ -f "$f" ] && hook_scripts+=("$f")
    done
  fi

  if [ ${#hook_scripts[@]} -gt 0 ]; then
    mkdir -p "$out/hooks/scripts"
    for src in "${hook_scripts[@]}"; do
      local filename
      filename="$(basename "$src")"
      # Rewrite PROJECT_ROOT derivation — plugin scripts use $CLAUDE_PROJECT_DIR
      sed 's|PROJECT_ROOT="$(cd "$(dirname "$0")/\.\./\.\." && pwd)"|PROJECT_ROOT="${CLAUDE_PROJECT_DIR}"|g' \
        "$src" > "$out/hooks/scripts/$filename"
      chmod +x "$out/hooks/scripts/$filename"
    done
    echo "  hooks        ${#hook_scripts[@]} scripts → hooks/hooks.json needs manual wiring"
    echo "               see: https://code.claude.com/docs/en/plugins-reference#hooks"
  fi

  echo "  → test: claude --plugin-dir $out"

  # ── KMS — copy package, seed ChromaDB, wire MCP ──────────────────────────────
  local knowledge_dir="$SUBMODULE/lib/core/knowledge"
  if [ -d "$knowledge_dir" ]; then
    if ! command -v python3 &>/dev/null; then
      echo "  kms          SKIP (python3 not found — install Python 3 to enable KMS)"
    else
      # Copy kms/ Python package into plugin.
      cp -r "$SUBMODULE/kms" "$out/kms"

      # Launcher — uses ${CLAUDE_PLUGIN_ROOT} injected by Claude Code at runtime.
      # Falls back to dirname-based resolution for local --plugin-dir testing.
      cat > "$out/kms/server.sh" <<'LAUNCHER'
#!/usr/bin/env bash
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
export KMS_DB_PATH="$PLUGIN_ROOT/chroma"
export PYTHONPATH="$PLUGIN_ROOT"

# Auto-install deps on first run — no-op if already satisfied.
if ! python3 -c "import chromadb, yaml" 2>/dev/null; then
  echo "[kms] Installing dependencies (one-time)..." >&2
  pip3 install -q -r "$PLUGIN_ROOT/kms/requirements.txt" >&2 \
    || { echo "[kms] ERROR: pip install failed. Run: pip install chromadb PyYAML" >&2; exit 1; }
fi

exec python3 -m kms.application.mcp_server
LAUNCHER
      chmod +x "$out/kms/server.sh"

      # Seed ChromaDB — skip if lib/core/knowledge tree hash unchanged.
      # Cache dir ($cache_dir) survives rm -rf $out so successive builds don't re-seed.
      local cache_dir="$SUBMODULE/dist/.kms_seeds/$platform"
      local marker="$cache_dir/.tree"
      local tree_hash stored_hash=""
      tree_hash="$(git -C "$SUBMODULE" rev-parse HEAD:lib/core/knowledge 2>/dev/null || echo "unknown")"
      [ -f "$marker" ] && stored_hash="$(cat "$marker")"

      if [ "$tree_hash" = "$stored_hash" ] && [ -d "$cache_dir/chroma" ]; then
        cp -r "$cache_dir/chroma" "$out/chroma"
        echo "  kms          seed skipped (lib/core/knowledge unchanged) — restored from cache"
      elif python3 -c "import chromadb" 2>/dev/null; then
        echo "  kms          seeding ChromaDB from lib/core/knowledge/ ..."
        PYTHONPATH="$SUBMODULE" python3 -m kms.scripts.seed_kms \
          --knowledge-dir "$knowledge_dir" \
          --db-path "$out/chroma" 2>&1 | sed 's/^/               /'
        mkdir -p "$cache_dir"
        rm -rf "$cache_dir/chroma"
        cp -r "$out/chroma" "$cache_dir/chroma"
        echo "$tree_hash" > "$marker"
        echo "  kms          seeded → chroma/ (cache updated)"
      else
        echo "  kms          SKIP seed (chromadb not installed — run: pip install chromadb PyYAML)"
      fi

      # Wire MCP server via .mcp.json — auto-applied when plugin is active.
      # ${CLAUDE_PLUGIN_ROOT} is injected by Claude Code at runtime.
      cat > "$out/.mcp.json" <<'MCP'
{
  "mcpServers": {
    "kms": {
      "command": "bash",
      "args": ["${CLAUDE_PLUGIN_ROOT}/kms/server.sh"]
    }
  }
}
MCP
      echo "  kms          .mcp.json → mcpServers.kms wired (auto-applied on plugin enable)"
    fi
  else
    echo "  kms          SKIP (lib/core/knowledge/ not found)"
  fi

  # ── Upsert marketplace.json entry ────────────────────────────────────────────
  local marketplace="$SUBMODULE/.claude-plugin/marketplace.json"
  local plugin_name="sda-${platform}"
  local description
  description="Builder, detective, tracker, auditor personas for ${platform}"

  python3 - "$marketplace" "$plugin_name" "$platform" "$description" <<'PYEOF'
import json, sys
marketplace_path, plugin_name, platform, description = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
with open(marketplace_path) as f:
    m = json.load(f)
plugins = m.setdefault("plugins", [])
existing = next((p for p in plugins if p["name"] == plugin_name), None)
if existing:
    existing["source"] = f"./dist/plugins/{platform}"
    existing["description"] = description
else:
    plugins.append({
        "name": plugin_name,
        "source": f"./dist/plugins/{platform}",
        "description": description,
        "category": "development-workflows"
    })
with open(marketplace_path, "w") as f:
    json.dump(m, f, indent=2)
print(f"  marketplace   {'updated' if existing else 'added'} entry: {plugin_name}")
PYEOF
}

# ── Entry ────────────────────────────────────────────────────────────────────

if [ "$PLATFORM" = "all" ]; then
  for p in "$SUBMODULE/lib/platforms"/*/; do
    build_platform "$(basename "$p")"
  done
else
  build_platform "$PLATFORM"
fi

echo ""
echo "Done. Version: $VERSION"
echo ""
echo "Next steps:"
echo "  Test locally:  claude --plugin-dir dist/plugins/<platform>"
echo "  Distribute:    git add dist/plugins/ && git commit -m 'chore(plugin): build $VERSION'"
