#!/usr/bin/env bash
# local-setup-symlinks.sh
# Non-submodule version of setup-symlinks.sh. Copies core agents/skills/reference +
# the chosen platform's agents/skills/reference into .claude/ of a local project.
# Files are COPIED (not symlinked) — use when the project does not use the submodule pattern.
#
# Run this script directly from the software-dev-agentic repo:
#
#   scripts/local-setup-symlinks.sh --platform=web --project=/path/to/project
#   scripts/local-setup-symlinks.sh --platform=ios --project=/path/to/project
#
# Re-running is safe — existing files are never overwritten.
# Priority order: agents.local > platform > core  (first copy wins)

set -euo pipefail

SUBMODULE="$(cd "$(dirname "$0")/.." && pwd)"

# ── Parse args ────────────────────────────────────────────────────────────────

PLATFORM=""
PROJECT_ROOT=""
APP_NAME=""
for arg in "$@"; do
  case "$arg" in
    --platform=*)  PLATFORM="${arg#--platform=}" ;;
    --project=*)   PROJECT_ROOT="${arg#--project=}" ;;
    --app-name=*)  APP_NAME="${arg#--app-name=}" ;;
  esac
done

if [ -z "$PLATFORM" ]; then
  echo "Error: --platform is required."
  echo "Usage: $0 --platform=web|ios|flutter --project=/path/to/project"
  exit 1
fi

if [ -z "$PROJECT_ROOT" ]; then
  echo "Error: --project is required."
  echo "Usage: $0 --platform=web|ios|flutter --project=/path/to/project"
  exit 1
fi

PLATFORM_DIR="$SUBMODULE/lib/platforms/$PLATFORM"
if [ ! -d "$PLATFORM_DIR" ]; then
  echo "Error: platform '$PLATFORM' not found at $PLATFORM_DIR"
  exit 1
fi

if [ ! -d "$PROJECT_ROOT" ]; then
  echo "Error: project directory not found: $PROJECT_ROOT"
  exit 1
fi

CLAUDE_DIR="$PROJECT_ROOT/.claude"

echo "Setting up software-dev-agentic → $PROJECT_ROOT (platform: $PLATFORM)..."

# ── Helpers ───────────────────────────────────────────────────────────────────

copy_if_absent() {
  local src="$1"
  local dest="$2"
  if [ -e "$dest" ]; then
    echo "  skip  $(basename "$dest")"
  else
    cp -f "$src" "$dest"
    echo "  copy  $(basename "$dest")"
  fi
}

# ── Directories ───────────────────────────────────────────────────────────────

echo ""
echo "Preparing .claude/ directories..."
mkdir -p \
  "$CLAUDE_DIR/agents" \
  "$CLAUDE_DIR/skills" \
  "$CLAUDE_DIR/reference" \
  "$CLAUDE_DIR/hooks" \
  "$CLAUDE_DIR/config" \
  "$CLAUDE_DIR/agents.local/extensions" \
  "$CLAUDE_DIR/skills.local/extensions" \
  "$CLAUDE_DIR/agentic-state/runs"

# ── Copy functions ────────────────────────────────────────────────────────────

copy_agents() {
  local src_dir="$1"
  [ -d "$src_dir" ] || return 0
  while IFS= read -r agent; do
    [ -f "$agent" ] || continue
    name="$(basename "$agent")"
    copy_if_absent "$agent" "$CLAUDE_DIR/agents/$name"
  done < <(find "$src_dir" -name "*.md" -type f)
}

copy_skills() {
  local src_dir="$1"
  [ -d "$src_dir" ] || return 0
  for skill_dir in "$src_dir"/*/; do
    [ -d "$skill_dir" ] || continue
    name="$(basename "$skill_dir")"
    [ "$name" = "contract" ] && continue
    if [ -e "$CLAUDE_DIR/skills/$name" ]; then
      echo "  skip  $name"
    else
      cp -rf "$skill_dir" "$CLAUDE_DIR/skills/$name"
      echo "  copy  $name"
    fi
  done
  if [ -d "$src_dir/contract" ]; then
    for skill_dir in "$src_dir/contract"/*/; do
      [ -d "$skill_dir" ] || continue
      name="$(basename "$skill_dir")"
      if [ -e "$CLAUDE_DIR/skills/$name" ]; then
        echo "  skip  $name"
      else
        cp -rf "$skill_dir" "$CLAUDE_DIR/skills/$name"
        echo "  copy  $name"
      fi
    done
  fi
}

copy_reference() {
  local src_dir="$1"
  [ -d "$src_dir" ] || return 0
  # Flat .md files
  for ref in "$src_dir"/*.md; do
    [ -f "$ref" ] || continue
    name="$(basename "$ref")"
    copy_if_absent "$ref" "$CLAUDE_DIR/reference/$name"
  done
  # Subdirectories — each preserved as a subdir in .claude/reference/
  for subdir in "$src_dir"/*/; do
    [ -d "$subdir" ] || continue
    subname="$(basename "$subdir")"
    mkdir -p "$CLAUDE_DIR/reference/$subname"
    for ref in "$subdir"*.md; do
      [ -f "$ref" ] || continue
      name="$(basename "$ref")"
      copy_if_absent "$ref" "$CLAUDE_DIR/reference/$subname/$name"
    done
  done
}

copy_hooks() {
  local src_dir="$1"
  [ -d "$src_dir" ] || return 0
  for hook in "$src_dir/"*.sh; do
    [ -f "$hook" ] || continue
    name="$(basename "$hook")"
    copy_if_absent "$hook" "$CLAUDE_DIR/hooks/$name"
    chmod +x "$CLAUDE_DIR/hooks/$name" 2>/dev/null || true
  done
}

# ── 1. Local overrides (highest priority) ────────────────────────────────────

echo ""
echo "1/3 Copying local overrides..."
copy_agents "$CLAUDE_DIR/agents.local"
copy_skills "$CLAUDE_DIR/skills.local"

# ── 2. Platform agents/skills/reference ──────────────────────────────────────

echo ""
echo "2/3 Copying platform: $PLATFORM..."
copy_agents "$PLATFORM_DIR/agents"
copy_skills "$PLATFORM_DIR/skills"
copy_reference "$PLATFORM_DIR/reference"

# ── 3. Core agents/skills/reference (fallback) ───────────────────────────────

echo ""
echo "3/3 Copying core..."
copy_agents "$SUBMODULE/lib/core/agents"
copy_skills "$SUBMODULE/lib/core/skills"
copy_reference "$SUBMODULE/lib/core/reference"

# ── .gitignore ────────────────────────────────────────────────────────────────

echo ""
GITIGNORE="$PROJECT_ROOT/.gitignore"
if grep -qs 'agentic-state' "$GITIGNORE" 2>/dev/null; then
  echo "skip  .gitignore (agentic-state/ already present)"
else
  printf '\n# Claude Code — agentic state (delegation flags, session state, run artifacts)\n.claude/agentic-state/\n' >> "$GITIGNORE"
  echo "patch .gitignore (added agentic-state/)"
fi

# ── Hooks ─────────────────────────────────────────────────────────────────────

echo ""
echo "Copying hooks..."
copy_hooks "$SUBMODULE/lib/core/hooks"
copy_hooks "$PLATFORM_DIR/hooks"

# ── Settings ──────────────────────────────────────────────────────────────────

echo ""
SETTINGS_FILE="$CLAUDE_DIR/settings.local.json"
if [ ! -f "$SETTINGS_FILE" ]; then
  if [ -f "$PLATFORM_DIR/settings-template.json" ]; then
    cp "$PLATFORM_DIR/settings-template.json" "$SETTINGS_FILE"
    echo "copy  .claude/settings.local.json"
    echo ""
    echo "  ⚠  Edit .claude/settings.local.json — replace PROJECT_ROOT with your .claude path"
  fi
elif grep -q 'require-feature-orchestrator' "$SETTINGS_FILE"; then
  RESULT=$(python3 - "$SETTINGS_FILE" <<'EOF'
import sys, re
f = sys.argv[1]
content = open(f).read()
cleaned = re.sub(r',?\s*\{\s*"type"\s*:\s*"command"\s*,\s*"command"\s*:\s*"[^"]*require-feature-orchestrator[^"]*"\s*\}', '', content)
if cleaned != content:
    open(f, 'w').write(cleaned)
    print("removed")
else:
    print("warn")
EOF
  )
  if [ "$RESULT" = "removed" ]; then
    echo "patch settings.local.json (removed require-feature-orchestrator hook)"
  else
    echo "warn  settings.local.json — could not auto-remove hook, remove manually"
  fi
else
  echo "skip  settings.local.json (require-feature-orchestrator not present)"
fi

# ── CLAUDE.md ─────────────────────────────────────────────────────────────────

echo ""
if [ ! -f "$PLATFORM_DIR/CLAUDE-template.md" ]; then
  echo "skip  CLAUDE.md (no template for $PLATFORM)"
elif [ -f "$PROJECT_ROOT/CLAUDE.md" ]; then
  MARKER="<!-- BEGIN software-dev-agentic:$PLATFORM -->"
  if grep -qF "$MARKER" "$PROJECT_ROOT/CLAUDE.md"; then
    echo "skip  CLAUDE.md ($PLATFORM block already present)"
  else
    BLOCK=$(sed -n "/<!-- BEGIN software-dev-agentic:$PLATFORM -->/,/<!-- END software-dev-agentic:$PLATFORM -->/p" "$PLATFORM_DIR/CLAUDE-template.md")
    printf '\n%s\n' "$BLOCK" >> "$PROJECT_ROOT/CLAUDE.md"
    echo "append CLAUDE.md ($PLATFORM block)"
  fi
else
  cp "$PLATFORM_DIR/CLAUDE-template.md" "$PROJECT_ROOT/CLAUDE.md"
  echo "copy  CLAUDE.md (from $PLATFORM CLAUDE-template.md)"
fi

if [ -f "$PROJECT_ROOT/CLAUDE.md" ] && grep -q '\[AppName\]' "$PROJECT_ROOT/CLAUDE.md"; then
  if [ -z "$APP_NAME" ]; then
    printf "  App name (replaces [AppName] in CLAUDE.md): "
    read -r APP_NAME
  fi
  if [ -n "$APP_NAME" ]; then
    sed -i.bak "s/\[AppName\]/$APP_NAME/g" "$PROJECT_ROOT/CLAUDE.md" && rm "$PROJECT_ROOT/CLAUDE.md.bak"
    echo "  ✓  Replaced [AppName] with '$APP_NAME'"
  else
    echo "  ⚠  Fill in [AppName] placeholders in CLAUDE.md"
  fi
fi

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "Done. software-dev-agentic ($PLATFORM) wired into $PROJECT_ROOT."
echo ""
echo "Next steps:"
echo "  1. Fill in CLAUDE.md placeholders"
echo "  2. Edit .claude/settings.local.json — replace PROJECT_ROOT"
echo "  3. git add .claude/ && git commit -m 'chore: wire software-dev-agentic ($PLATFORM)'"
