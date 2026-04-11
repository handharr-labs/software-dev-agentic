#!/usr/bin/env bash
# setup-symlinks.sh
# Run once from the project root after adding software-dev-agentic as a submodule.
# Links core agents/skills/reference + the chosen platform's agents/skills/reference
# into .claude/agents/, .claude/skills/, .claude/reference/ and .claude/hooks/.
#
# Usage:
#   .claude/software-dev-agentic/scripts/setup-symlinks.sh --platform=web
#   .claude/software-dev-agentic/scripts/setup-symlinks.sh --platform=ios
#
# Re-running is safe — link_if_absent never overwrites existing files.
# Priority order: agents.local > platform > core  (first link wins)

set -euo pipefail

SUBMODULE="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_ROOT="$(cd "$SUBMODULE/../.." && pwd)"
CLAUDE_DIR="$PROJECT_ROOT/.claude"

# ── Parse --platform ─────────────────────────────────────────────────────────

PLATFORM=""
for arg in "$@"; do
  case "$arg" in
    --platform=*) PLATFORM="${arg#--platform=}" ;;
  esac
done

if [ -z "$PLATFORM" ]; then
  echo "Error: --platform is required."
  echo "Usage: $0 --platform=web|ios|flutter"
  exit 1
fi

PLATFORM_DIR="$SUBMODULE/platforms/$PLATFORM"
if [ ! -d "$PLATFORM_DIR" ]; then
  echo "Error: platform '$PLATFORM' not found at $PLATFORM_DIR"
  exit 1
fi

echo "Setting up software-dev-agentic (platform: $PLATFORM)..."

# ── Helpers ───────────────────────────────────────────────────────────────────

link_if_absent() {
  local target="$1"
  local link="$2"
  if [ -e "$link" ] || [ -L "$link" ]; then
    echo "  skip  $link"
  else
    ln -s "$target" "$link"
    echo "  link  $(basename $link)"
  fi
}

convert_dir_symlink() {
  local dir="$1"
  if [ -L "$dir" ]; then
    echo "  convert  $dir (directory symlink → real directory)"
    rm "$dir"
    mkdir -p "$dir"
  fi
}

# ── Directories ───────────────────────────────────────────────────────────────

echo ""
echo "Preparing .claude/ directories..."
convert_dir_symlink "$CLAUDE_DIR/agents"
convert_dir_symlink "$CLAUDE_DIR/skills"
convert_dir_symlink "$CLAUDE_DIR/reference"
mkdir -p \
  "$CLAUDE_DIR/agents" \
  "$CLAUDE_DIR/skills" \
  "$CLAUDE_DIR/reference" \
  "$CLAUDE_DIR/agents.local/extensions" \
  "$CLAUDE_DIR/skills.local/extensions"

# ── Link function (local > platform > core) ───────────────────────────────────

link_agents() {
  local src_dir="$1"
  local rel_prefix="$2"
  [ -d "$src_dir" ] || return 0
  while IFS= read -r agent; do
    [ -f "$agent" ] || continue
    name="$(basename "$agent")"
    rel_path="${agent#$src_dir/}"
    link_if_absent "$rel_prefix/$rel_path" "$CLAUDE_DIR/agents/$name"
  done < <(find "$src_dir" -name "*.md" -type f)
}

link_skills() {
  local src_dir="$1"
  local rel_prefix="$2"
  [ -d "$src_dir" ] || return 0
  for skill_dir in "$src_dir"/*/; do
    [ -d "$skill_dir" ] || continue
    name="$(basename "$skill_dir")"
    link_if_absent "$rel_prefix/$name" "$CLAUDE_DIR/skills/$name"
  done
}

link_reference() {
  local src_dir="$1"
  local rel_prefix="$2"
  [ -d "$src_dir" ] || return 0
  for ref in "$src_dir"/*.md; do
    [ -f "$ref" ] || continue
    name="$(basename "$ref")"
    link_if_absent "$rel_prefix/$name" "$CLAUDE_DIR/reference/$name"
  done
}

# Relative paths from .claude/agents/ or .claude/skills/ to submodule
REL_CORE="../software-dev-agentic/core"
REL_PLATFORM="../software-dev-agentic/platforms/$PLATFORM"

# ── 1. Local overrides (highest priority) ────────────────────────────────────

echo ""
echo "1/3 Linking local overrides..."
link_agents "$CLAUDE_DIR/agents.local" "../agents.local"
link_skills "$CLAUDE_DIR/skills.local" "../skills.local"

# ── 2. Platform agents/skills/reference ──────────────────────────────────────

echo ""
echo "2/3 Linking platform: $PLATFORM..."
link_agents "$PLATFORM_DIR/agents" "$REL_PLATFORM/agents"
link_skills "$PLATFORM_DIR/skills" "$REL_PLATFORM/skills"
link_reference "$PLATFORM_DIR/reference" "$REL_PLATFORM/reference"

# ── 3. Core agents/skills/reference (fallback) ───────────────────────────────

echo ""
echo "3/3 Linking core..."
link_agents "$SUBMODULE/core/agents" "$REL_CORE/agents"
link_skills "$SUBMODULE/core/skills" "$REL_CORE/skills"
link_reference "$SUBMODULE/core/reference/clean-arch" "$REL_CORE/reference/clean-arch"

# ── Hooks ─────────────────────────────────────────────────────────────────────

echo ""
echo "Making hooks executable..."
if [ -d "$PLATFORM_DIR/hooks" ]; then
  chmod +x "$PLATFORM_DIR/hooks/"*.sh 2>/dev/null || true
fi

# ── Settings ──────────────────────────────────────────────────────────────────

echo ""
if [ -f "$CLAUDE_DIR/settings.local.json" ]; then
  echo "skip  .claude/settings.local.json (already exists)"
elif [ -f "$PLATFORM_DIR/settings-template.json" ]; then
  cp "$PLATFORM_DIR/settings-template.json" "$CLAUDE_DIR/settings.local.json"
  echo "copy  .claude/settings.local.json"
  echo ""
  echo "  ⚠  Edit .claude/settings.local.json — replace PROJECT_ROOT with your .claude path"
fi

# ── CLAUDE.md ─────────────────────────────────────────────────────────────────

echo ""
if [ -f "$PROJECT_ROOT/CLAUDE.md" ]; then
  echo "skip  CLAUDE.md (already exists)"
elif [ -f "$PLATFORM_DIR/CLAUDE-template.md" ]; then
  cp "$PLATFORM_DIR/CLAUDE-template.md" "$PROJECT_ROOT/CLAUDE.md"
  echo "copy  CLAUDE.md (from $PLATFORM CLAUDE-template.md)"
  echo ""
  echo "  ⚠  Edit CLAUDE.md — fill in [AppName] and stack placeholders"
fi

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "Done. software-dev-agentic ($PLATFORM) is wired."
echo ""
echo "Next steps:"
echo "  1. Fill in CLAUDE.md placeholders"
echo "  2. Edit .claude/settings.local.json — replace PROJECT_ROOT"
echo "  3. git add .claude/ && git commit -m 'chore: wire software-dev-agentic ($PLATFORM)'"
