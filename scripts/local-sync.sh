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
# settings.local.json hook injection) is identical to sync.sh.

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
  "$CLAUDE_DIR/agents.local/extensions" \
  "$CLAUDE_DIR/skills.local/extensions"

# ── Copy helpers ──────────────────────────────────────────────────────────────

copy_agents() {
  local src_dir="$1"
  [ -d "$src_dir" ] || return 0
  while IFS= read -r agent; do
    [ -f "$agent" ] || continue
    name="$(basename "$agent")"
    cp -f "$agent" "$CLAUDE_DIR/agents/$name"
    echo "  copy  $name"
  done < <(find "$src_dir" -name "*.md" -type f)
}

copy_skills() {
  local src_dir="$1"
  [ -d "$src_dir" ] || return 0
  for skill_dir in "$src_dir"/*/; do
    [ -d "$skill_dir" ] || continue
    name="$(basename "$skill_dir")"
    cp -rf "$skill_dir" "$CLAUDE_DIR/skills/$name"
    echo "  copy  $name"
  done
}

copy_reference() {
  local src_dir="$1"
  [ -d "$src_dir" ] || return 0
  for ref in "$src_dir"/*.md; do
    [ -f "$ref" ] || continue
    name="$(basename "$ref")"
    cp -f "$ref" "$CLAUDE_DIR/reference/$name"
    echo "  copy  $name"
  done
}

# ── 1. Core agents/skills/reference ──────────────────────────────────────────

echo ""
echo "1/3 Copying core..."
copy_agents "$SUBMODULE/lib/core/agents"
copy_skills "$SUBMODULE/lib/core/skills"
copy_reference "$SUBMODULE/lib/core/reference/clean-arch"

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
if grep -qs '\.delegated-\*' "$GITIGNORE" 2>/dev/null; then
  echo "skip  .gitignore (.delegated-* already present)"
else
  printf '\n# Claude Code — delegation flags and session state\n.claude/.delegated-*\n.claude/.session-id\n.claude/runs/\n' >> "$GITIGNORE"
  echo "patch .gitignore (added .delegated-*, .session-id, runs/)"
fi
if ! grep -qs '\.claude/runs/' "$GITIGNORE" 2>/dev/null; then
  printf '.claude/.session-id\n.claude/runs/\n' >> "$GITIGNORE"
  echo "patch .gitignore (added .session-id, runs/)"
fi

# ── settings.local.json ───────────────────────────────────────────────────────

echo ""
SETTINGS_FILE="$CLAUDE_DIR/settings.local.json"
if [ ! -f "$SETTINGS_FILE" ]; then
  if [ -f "$PLATFORM_DIR/settings-template.json" ]; then
    cp "$PLATFORM_DIR/settings-template.json" "$SETTINGS_FILE"
    echo "copy  .claude/settings.local.json"
    echo ""
    echo "  ⚠  Edit .claude/settings.local.json — replace PROJECT_ROOT with your .claude path"
  else
    echo "skip  settings.local.json (no template for platform $PLATFORM)"
  fi
elif grep -q 'require-feature-orchestrator' "$SETTINGS_FILE"; then
  echo "skip  settings.local.json (require-feature-orchestrator already present)"
else
  RESULT=$(python3 - "$SETTINGS_FILE" "$CLAUDE_DIR" <<'EOF'
import sys, re

settings_file, claude_dir = sys.argv[1], sys.argv[2]
hook_cmd = claude_dir + "/hooks/require-feature-orchestrator.sh"
content = open(settings_file).read()

pattern = r'("matcher"\s*:\s*"Write\|Edit"(?:[^[]*?)"hooks"\s*:\s*\[)'
match = re.search(pattern, content, re.DOTALL)
if not match:
    print("warn")
    sys.exit(0)

indent_match = re.match(r'\n(\s*)', content[match.end():])
indent = indent_match.group(1) if indent_match else "          "
new_hook = f'\n{indent}{{"type": "command", "command": "{hook_cmd}"}},'
open(settings_file, "w").write(content[:match.end()] + new_hook + content[match.end():])
print("patched")
EOF
  )
  if [ "$RESULT" = "patched" ]; then
    echo "patch settings.local.json (added require-feature-orchestrator hook)"
  else
    echo "warn  settings.local.json — could not auto-patch, add manually:"
    echo "      { \"type\": \"command\", \"command\": \"$CLAUDE_DIR/hooks/require-feature-orchestrator.sh\" }"
  fi
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

# ── CLAUDE.md — Feature Directories (iOS — outside managed block) ─────────────

echo ""
if [ -f "$CLAUDE_MD" ] && [ -f "$TEMPLATE" ] && ! grep -q '## Feature Directories' "$CLAUDE_MD"; then
  FEAT_DIRS=$(python3 -c "
import sys, re
content = open('$TEMPLATE').read()
m = re.search(r'## Feature Directories\s+\x60\x60\x60\s*(.*?)\s*\x60\x60\x60', content, re.DOTALL)
print(m.group(1).strip() if m else '')
")
  if [ -n "$FEAT_DIRS" ]; then
    printf '\n## Feature Directories\n\n```\n%s\n```\n' "$FEAT_DIRS" >> "$CLAUDE_MD"
    echo "patch CLAUDE.md (added ## Feature Directories)"
    if echo "$FEAT_DIRS" | grep -q '\[AppName\]'; then
      APP_NAME=""
      printf "  App name (replaces [AppName]): "
      read -r APP_NAME
      if [ -n "$APP_NAME" ]; then
        sed -i.bak "s/\[AppName\]/$APP_NAME/g" "$CLAUDE_MD" && rm "$CLAUDE_MD.bak"
        echo "  ✓  Replaced [AppName] with '$APP_NAME'"
      fi
    fi
  fi
else
  echo "skip  CLAUDE.md Feature Directories (already present or template not found)"
fi

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "Done. $PROJECT_ROOT synced to $(git -C "$SUBMODULE" rev-parse --short HEAD) ($PLATFORM)."
