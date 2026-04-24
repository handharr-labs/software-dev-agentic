#!/usr/bin/env bash
# local-sync.sh
# Push the latest software-dev-agentic agents/skills/reference/hooks into a
# local project that does NOT use the submodule pattern. Files are COPIED
# (not symlinked) and always overwrite the destination to pick up the latest
# changes. No git submodule operations are performed.
#
# Run this script directly from the software-dev-agentic repo:
#
#   scripts/local-sync.sh --platform=ios --project=/path/to/project
#   scripts/local-sync.sh --platform=web --project=/path/to/project
#
# All other behaviour (CLAUDE.md managed-section sync, .gitignore patch,
# settings.json hook injection) is identical to sync.sh.

set -euo pipefail

SUBMODULE="$(cd "$(dirname "$0")/.." && pwd)"

# ── Parse args ────────────────────────────────────────────────────────────────

PLATFORM=""
PROJECT_ROOT=""
for arg in "$@"; do
  case "$arg" in
    --platform=*) PLATFORM="${arg#--platform=}" ;;
    --project=*)  PROJECT_ROOT="${arg#--project=}" ;;
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
CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"

echo "Syncing software-dev-agentic → $PROJECT_ROOT (platform: $PLATFORM)..."

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

# ── Copy helpers ──────────────────────────────────────────────────────────────

copy_agents() {
  local src_dir="$1"
  [ -d "$src_dir" ] || return 0
  while IFS= read -r agent; do
    [ -f "$agent" ] || continue
    name="$(basename "$agent")"
    dest="$CLAUDE_DIR/agents/$name"
    [ -L "$dest" ] && rm -f "$dest"  # replace symlinks (broken or stale) with real file
    cp -f "$agent" "$dest"
    echo "  copy  $name"
  done < <(find "$src_dir" -name "*.md" -type f)
}

copy_skills() {
  local src_dir="$1"
  [ -d "$src_dir" ] || return 0
  for skill_dir in "$src_dir"/*/; do
    [ -d "$skill_dir" ] || continue
    name="$(basename "$skill_dir")"
    [ "$name" = "contract" ] && continue
    dest="$CLAUDE_DIR/skills/$name"
    [ -L "$dest" ] && rm -f "$dest"  # replace symlinks (broken or stale) with real file
    cp -rf "$skill_dir" "$dest"
    echo "  copy  $name"
  done
  if [ -d "$src_dir/contract" ]; then
    for skill_dir in "$src_dir/contract"/*/; do
      [ -d "$skill_dir" ] || continue
      name="$(basename "$skill_dir")"
      dest="$CLAUDE_DIR/skills/$name"
      [ -L "$dest" ] && rm -f "$dest"
      cp -rf "$skill_dir" "$dest"
      echo "  copy  $name"
    done
  fi
}

copy_reference() {
  local src_dir="$1"
  local dest_base="${2:-$CLAUDE_DIR/reference}"
  [ -d "$src_dir" ] || return 0
  for ref in "$src_dir"/*.md; do
    [ -f "$ref" ] || continue
    name="$(basename "$ref")"
    dest="$dest_base/$name"
    [ -L "$dest" ] && rm -f "$dest"
    cp -f "$ref" "$dest"
    echo "  copy  ${dest#$CLAUDE_DIR/reference/}"
  done
  for subdir in "$src_dir"/*/; do
    [ -d "$subdir" ] || continue
    subname="$(basename "$subdir")"
    mkdir -p "$dest_base/$subname"
    copy_reference "$subdir" "$dest_base/$subname"
  done
}

# ── 1. Core agents/skills/reference ──────────────────────────────────────────

echo ""
echo "1/3 Copying core..."
copy_agents "$SUBMODULE/lib/core/agents"
copy_skills "$SUBMODULE/lib/core/skills"
copy_reference "$SUBMODULE/lib/core/reference"

# ── 2. Platform agents/skills/reference (overwrites core where names collide) ─

echo ""
echo "2/3 Copying platform: $PLATFORM..."
copy_agents "$PLATFORM_DIR/agents"
copy_skills "$PLATFORM_DIR/skills"
copy_reference "$PLATFORM_DIR/reference"

# ── 3. Hooks (core first, platform overwrites) ───────────────────────────────

echo ""
echo "3/3 Copying hooks..."

copy_hooks() {
  local src_dir="$1"
  [ -d "$src_dir" ] || return 0
  for hook in "$src_dir/"*.sh; do
    [ -f "$hook" ] || continue
    name="$(basename "$hook")"
    cp -f "$hook" "$CLAUDE_DIR/hooks/$name"
    chmod +x "$CLAUDE_DIR/hooks/$name"
    echo "  copy  $name"
  done
}

copy_hooks "$SUBMODULE/lib/core/hooks"
copy_hooks "$PLATFORM_DIR/hooks"

# ── .gitignore ────────────────────────────────────────────────────────────────

echo ""
GITIGNORE="$PROJECT_ROOT/.gitignore"
if grep -qs 'agentic-state' "$GITIGNORE" 2>/dev/null; then
  echo "skip  .gitignore (agentic-state/ already present)"
else
  printf '\n# Claude Code — agentic state (delegation flags, session state, run artifacts)\n.claude/agentic-state/\n' >> "$GITIGNORE"
  echo "patch .gitignore (added agentic-state/)"
fi

# ── settings.json ─────────────────────────────────────────────────────────────

echo ""
SHARED_SETTINGS="$CLAUDE_DIR/settings.json"
if grep -q 'require-feature-orchestrator' "$SHARED_SETTINGS" 2>/dev/null; then
  RESULT=$(python3 - "$SHARED_SETTINGS" <<'EOF'
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
    echo "patch settings.json (removed require-feature-orchestrator hook)"
  else
    echo "warn  settings.json — could not auto-remove hook, remove manually"
  fi
else
  echo "skip  settings.json (require-feature-orchestrator not present)"
fi

LOCAL_SETTINGS="$CLAUDE_DIR/settings.local.json"
if [ ! -f "$LOCAL_SETTINGS" ] && [ -f "$PLATFORM_DIR/settings-template.jsonc" ]; then
  cp "$PLATFORM_DIR/settings-template.jsonc" "$LOCAL_SETTINGS"
  echo "copy  .claude/settings.local.json"
fi

# ── CLAUDE.md ─────────────────────────────────────────────────────────────────

TEMPLATE="$PLATFORM_DIR/CLAUDE-template.md"
BEGIN_MARKER="<!-- BEGIN software-dev-agentic:$PLATFORM -->"
END_MARKER="<!-- END software-dev-agentic:$PLATFORM -->"

echo ""
if [ ! -f "$CLAUDE_MD" ]; then
  if [ -f "$TEMPLATE" ]; then
    cp "$TEMPLATE" "$CLAUDE_MD"
    echo "copy  CLAUDE.md (from $PLATFORM CLAUDE-template.md)"
    if grep -q '\[AppName\]' "$CLAUDE_MD"; then
      APP_NAME=""
      printf "  App name (replaces [AppName] in CLAUDE.md): "
      read -r APP_NAME
      if [ -n "$APP_NAME" ]; then
        sed -i.bak "s/\[AppName\]/$APP_NAME/g" "$CLAUDE_MD" && rm "$CLAUDE_MD.bak"
        echo "  ✓  Replaced [AppName] with '$APP_NAME'"
      else
        echo "  ⚠  Fill in [AppName] placeholders in CLAUDE.md"
      fi
    fi
  fi
elif ! grep -qF "$BEGIN_MARKER" "$CLAUDE_MD"; then
  echo "skip  CLAUDE.md sync (no managed section markers found)"
  echo "      Add: $BEGIN_MARKER ... $END_MARKER"
elif [ ! -f "$TEMPLATE" ]; then
  echo "skip  CLAUDE.md sync (no CLAUDE-template.md for platform $PLATFORM)"
else
  managed_tmp="$(mktemp)"
  awk "/^${BEGIN_MARKER}$/{found=1} found{print} /^${END_MARKER}$/{found=0}" "$TEMPLATE" > "$managed_tmp"

  awk -v begin="$BEGIN_MARKER" -v end="$END_MARKER" -v src="$managed_tmp" '
    $0 == begin { while ((getline line < src) > 0) print line; skip=1; next }
    $0 == end   { skip=0; next }
    !skip        { print }
  ' "$CLAUDE_MD" > "$CLAUDE_MD.tmp" && mv "$CLAUDE_MD.tmp" "$CLAUDE_MD"

  rm -f "$managed_tmp"
  echo "sync  CLAUDE.md (managed section updated)"
fi

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "Done. $PROJECT_ROOT synced to $(git -C "$SUBMODULE" rev-parse --short HEAD) ($PLATFORM)."
