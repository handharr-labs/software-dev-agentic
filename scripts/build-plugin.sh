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

  echo "  kms          served by sda-kms plugin (install separately)"
  echo "  → test: claude --plugin-dir $out"

  # ── Upsert marketplace.json entry ────────────────────────────────────────────
  local marketplace="$SUBMODULE/.claude-plugin/marketplace.json"
  local plugin_name="sda-${platform}"
  local description
  description="Builder, detective, tracker, auditor personas for ${platform}"

  python3 - "$marketplace" "$plugin_name" "$platform" "$description" "$VERSION" <<'PYEOF'
import json, sys
marketplace_path, plugin_name, platform, description, version = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5]
with open(marketplace_path) as f:
    m = json.load(f)
plugins = m.setdefault("plugins", [])
existing = next((p for p in plugins if p["name"] == plugin_name), None)
if existing:
    existing["source"] = f"./dist/plugins/{platform}"
    existing["description"] = description
    existing["version"] = version
else:
    plugins.append({
        "name": plugin_name,
        "source": f"./dist/plugins/{platform}",
        "description": description,
        "category": "development-workflows",
        "version": version,
    })
with open(marketplace_path, "w") as f:
    json.dump(m, f, indent=2)
print(f"  marketplace   {'updated' if existing else 'added'} entry: {plugin_name}@{version}")
PYEOF
}

# ── KMS plugin ───────────────────────────────────────────────────────────────

build_kms() {
  local out="$SUBMODULE/dist/plugins/kms"
  echo ""
  echo "Building plugin: kms → dist/plugins/kms"

  rm -rf "$out"
  mkdir -p "$out/.claude-plugin"

  # Manifest
  cat > "$out/.claude-plugin/plugin.json" <<MANIFEST
{
  "name": "sda-kms",
  "description": "software-dev-agentic KMS — knowledge MCP server for Clean Architecture projects",
  "version": "${VERSION}",
  "author": {
    "name": "Jurnal Engineering"
  }
}
MANIFEST
  echo "  manifest     sda-kms@${VERSION}"

  # KMS Python package + launcher (exclude runtime db — chroma lives at $PLUGIN_ROOT/chroma)
  cp -r "$SUBMODULE/kms" "$out/kms"
  rm -rf "$out/kms/db"
  cat > "$out/kms/server.sh" <<'LAUNCHER'
#!/usr/bin/env bash
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
export KMS_DB_PATH="$PLUGIN_ROOT/chroma"
export PYTHONPATH="$PLUGIN_ROOT"

if ! python3 -c "import chromadb, yaml, mcp" 2>/dev/null; then
  echo "[kms] Installing dependencies (one-time)..." >&2
  pip3 install -q -r "$PLUGIN_ROOT/kms/requirements.txt" >&2 \
    || { echo "[kms] ERROR: pip install failed. Run: pip install chromadb PyYAML mcp" >&2; exit 1; }
fi

exec python3 -m kms.application.mcp_server
LAUNCHER
  chmod +x "$out/kms/server.sh"

  # ChromaDB
  if [ -d "$SUBMODULE/kms/db" ]; then
    cp -r "$SUBMODULE/kms/db" "$out/chroma"
    echo "  chroma       bundled from kms/db"
  else
    echo "  chroma       ⚠ missing — run: /kms-seed"
  fi

  # MCP template — same for all platforms, points to sda-kms
  cat > "$out/kms/project-mcp-template.json" <<'MCP_TEMPLATE'
{
  "mcpServers": {
    "kms": {
      "command": "bash",
      "args": [
        "-c",
        "latest=$(ls -v \"$HOME/.claude/plugins/cache/sda/sda-kms\" 2>/dev/null | tail -1) && exec bash \"$HOME/.claude/plugins/cache/sda/sda-kms/$latest/kms/server.sh\""
      ]
    }
  }
}
MCP_TEMPLATE
  echo "  mcp-template project-mcp-template.json written"

  # Marketplace entry
  local marketplace="$SUBMODULE/.claude-plugin/marketplace.json"
  python3 - "$marketplace" "$VERSION" <<'PYEOF'
import json, sys
marketplace_path, version = sys.argv[1], sys.argv[2]
with open(marketplace_path) as f:
    m = json.load(f)
plugins = m.setdefault("plugins", [])
existing = next((p for p in plugins if p["name"] == "sda-kms"), None)
if existing:
    existing["source"] = "./dist/plugins/kms"
    existing["version"] = version
else:
    plugins.append({
        "name": "sda-kms",
        "source": "./dist/plugins/kms",
        "description": "KMS knowledge MCP server for Clean Architecture projects",
        "category": "development-workflows",
        "version": version,
    })
with open(marketplace_path, "w") as f:
    json.dump(m, f, indent=2)
print(f"  marketplace   {'updated' if existing else 'added'} entry: sda-kms@{version}")
PYEOF

  echo "  → test: claude --plugin-dir $out"
}

# ── Entry ────────────────────────────────────────────────────────────────────

if [ "$PLATFORM" = "all" ]; then
  build_kms
  for p in "$SUBMODULE/lib/platforms"/*/; do
    build_platform "$(basename "$p")"
  done
elif [ "$PLATFORM" = "kms" ]; then
  build_kms
else
  build_platform "$PLATFORM"
fi

echo ""
echo "Done. Version: $VERSION"
echo ""
echo "Next steps:"
echo "  Test locally:  claude --plugin-dir dist/plugins/<platform>"
echo "  Distribute:    git add dist/plugins/ && git commit -m 'chore(plugin): build $VERSION'"
