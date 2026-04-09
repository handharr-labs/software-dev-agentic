#!/usr/bin/env bash
# setup-symlinks.sh
# Run once from the project root after adding web-agentic as a submodule.
# Creates .claude/agents/ and .claude/skills/ as symlink-only directories.
# Local overrides (agents.local/, skills.local/) are respected — shared files
# are never linked if a local file with the same name already exists.
#
# Usage:
#   .claude/web-agentic/scripts/setup-symlinks.sh
#
# Re-running is safe — link_if_absent never overwrites existing files.

set -euo pipefail

SUBMODULE="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_ROOT="$(cd "$SUBMODULE/../.." && pwd)"
CLAUDE_DIR="$PROJECT_ROOT/.claude"

# ── Helpers ─────────────────────────────────────────────────────────────────

link_if_absent() {
  local target="$1"   # symlink target (relative path from the link location)
  local link="$2"     # symlink path to create

  if [ -e "$link" ] || [ -L "$link" ]; then
    echo "  skip  $link (already exists)"
  else
    ln -s "$target" "$link"
    echo "  link  $link → $target"
  fi
}

# ── Directories ──────────────────────────────────────────────────────────────

echo "Setting up .claude/ directories..."
mkdir -p \
  "$CLAUDE_DIR/agents" \
  "$CLAUDE_DIR/skills" \
  "$CLAUDE_DIR/agents.local/extensions" \
  "$CLAUDE_DIR/skills.local/extensions"

# ── Agents ───────────────────────────────────────────────────────────────────

echo ""
echo "Linking agents..."

# Local agents first — override takes priority
for agent in "$CLAUDE_DIR/agents.local"/*.md; do
  [ -f "$agent" ] || continue
  name="$(basename "$agent")"
  link_if_absent "../agents.local/$name" "$CLAUDE_DIR/agents/$name"
done

# Shared agents — skip if local override already linked
for agent in "$SUBMODULE/agents"/*.md; do
  [ -f "$agent" ] || continue
  name="$(basename "$agent")"
  link_if_absent "../../$(realpath --relative-to="$CLAUDE_DIR/agents" "$agent")" "$CLAUDE_DIR/agents/$name"
done

# ── Skills ───────────────────────────────────────────────────────────────────

echo ""
echo "Linking skills..."

# Local skills first — override takes priority
for skill_dir in "$CLAUDE_DIR/skills.local"/*/; do
  [ -d "$skill_dir" ] || continue
  name="$(basename "$skill_dir")"
  link_if_absent "../skills.local/$name" "$CLAUDE_DIR/skills/$name"
done

# Shared skills — skip if local override already linked
for skill_dir in "$SUBMODULE/skills"/*/; do
  [ -d "$skill_dir" ] || continue
  name="$(basename "$skill_dir")"
  link_if_absent "../../$(realpath --relative-to="$CLAUDE_DIR/skills" "$skill_dir")" "$CLAUDE_DIR/skills/$name"
done

# ── Hooks ────────────────────────────────────────────────────────────────────

echo ""
echo "Making hooks executable..."
chmod +x "$SUBMODULE/hooks/"*.sh

# ── Settings ─────────────────────────────────────────────────────────────────

echo ""
if [ -f "$CLAUDE_DIR/settings.local.json" ]; then
  echo "skip  .claude/settings.local.json (already exists)"
else
  cp "$SUBMODULE/settings-template.json" "$CLAUDE_DIR/settings.local.json"
  echo "copy  .claude/settings.local.json (from settings-template.json)"
  echo ""
  echo "  ⚠  Edit .claude/settings.local.json — replace PROJECT_ROOT with:"
  echo "     $(pwd)/.claude"
fi

# ── Done ─────────────────────────────────────────────────────────────────────

echo ""
echo "Done. web-agentic is wired."
echo ""
echo "Next steps:"
echo "  1. Fill in CLAUDE.md placeholders (copy from .claude/web-agentic/CLAUDE-template.md if needed)"
echo "  2. Edit .claude/settings.local.json — replace PROJECT_ROOT"
echo "  3. git add .claude/ && git commit -m 'chore: wire web-agentic submodule'"
