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
