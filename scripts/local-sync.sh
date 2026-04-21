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
  [ -d "$src_dir" ] || return 0
  for ref in "$src_dir"/*.md; do
    [ -f "$ref" ] || continue
    name="$(basename "$ref")"
    dest="$CLAUDE_DIR/reference/$name"
    [ -L "$dest" ] && rm -f "$dest"  # replace symlinks (broken or stale) with real file
    cp -f "$ref" "$dest"
    echo "  copy  $name"
  done
  if [ -d "$src_dir/contract" ]; then
    mkdir -p "$CLAUDE_DIR/reference/contract"
    for ref in "$src_dir/contract"/*.md; do
      [ -f "$ref" ] || continue
      name="$(basename "$ref")"
      dest="$CLAUDE_DIR/reference/contract/$name"
      [ -L "$dest" ] && rm -f "$dest"
      cp -f "$ref" "$dest"
      echo "  copy  contract/$name"
    done
  fi
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
if grep -qs 'agentic-state' "$GITIGNORE" 2>/dev/null; then
  echo "skip  .gitignore (agentic-state/ already present)"
else
  printf '\n# Claude Code — agentic state (delegation flags, session state, run artifacts)\n.claude/agentic-state/\n' >> "$GITIGNORE"
  echo "patch .gitignore (added agentic-state/)"
fi

# ── settings.json ─────────────────────────────────────────────────────────────

echo ""
HOOK_CMD=".claude/hooks/require-feature-orchestrator.sh"
SHARED_SETTINGS="$CLAUDE_DIR/settings.json"
if [ ! -f "$SHARED_SETTINGS" ]; then
  cat > "$SHARED_SETTINGS" <<EOF
{
    "hooks": {
        "PreToolUse": [
            {
                "matcher": "Write|Edit",
                "hooks": [
                    {
                        "type": "command",
                        "command": "$HOOK_CMD"
                    }
                ]
            }
        ]
    }
}
EOF
  echo "create settings.json (with require-feature-orchestrator hook)"
elif grep -q 'require-feature-orchestrator' "$SHARED_SETTINGS"; then
  echo "skip  settings.json (require-feature-orchestrator already present)"
else
  RESULT=$(python3 - "$SHARED_SETTINGS" "$HOOK_CMD" <<'EOF'
import sys, re

settings_file, hook_cmd = sys.argv[1], sys.argv[2]
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
    echo "patch settings.json (added require-feature-orchestrator hook)"
  else
    echo "warn  settings.json — could not auto-patch, add manually:"
    echo "      { \"type\": \"command\", \"command\": \"$HOOK_CMD\" }"
  fi
fi

LOCAL_SETTINGS="$CLAUDE_DIR/settings.local.json"
if [ ! -f "$LOCAL_SETTINGS" ] && [ -f "$PLATFORM_DIR/settings-template.jsonc" ]; then
  cp "$PLATFORM_DIR/settings-template.jsonc" "$LOCAL_SETTINGS"
  echo "copy  .claude/settings.local.json"
fi

# ── .claude/config/feature-dirs ──────────────────────────────────────────────
# Must run before CLAUDE.md sync — the sync step removes ## Feature Directories
# from the managed block, so migration must read CLAUDE.md while it still exists.

echo ""
FEATURE_DIRS_FILE="$CLAUDE_DIR/config/feature-dirs"
if [ -f "$FEATURE_DIRS_FILE" ]; then
  echo "skip  .claude/config/feature-dirs (already exists)"
else
  # Migrate from old path if present (v3.9.x upgrade path)
  if [ -f "$CLAUDE_DIR/feature-dirs" ]; then
    mv "$CLAUDE_DIR/feature-dirs" "$FEATURE_DIRS_FILE"
    echo "migrate .claude/config/feature-dirs (from .claude/feature-dirs)"
  fi
fi
if [ ! -f "$FEATURE_DIRS_FILE" ]; then
  # Migrate from CLAUDE.md ## Feature Directories if present
  MIGRATED_DIRS=""
  if [ -f "$CLAUDE_MD" ] && grep -q '## Feature Directories' "$CLAUDE_MD" 2>/dev/null; then
    MIGRATED_DIRS=$(python3 -c "
import sys, re
content = open('$CLAUDE_MD').read()
m = re.search(r'## Feature Directories\s+\x60\x60\x60\s*(.*?)\s*\x60\x60\x60', content, re.DOTALL)
if m:
    for line in m.group(1).splitlines():
        line = line.strip()
        if line and not line.startswith('#'):
            print(line)
" 2>/dev/null || true)
  fi

  if [ -n "$MIGRATED_DIRS" ]; then
    printf '# Path fragments guarded by the delegation hook (one per line)\n%s\n' "$MIGRATED_DIRS" > "$FEATURE_DIRS_FILE"
    echo "migrate .claude/config/feature-dirs (from CLAUDE.md ## Feature Directories)"
  else
    case "$PLATFORM" in
      web)
        printf '# Path fragments guarded by the delegation hook (one per line)\nsrc\n' > "$FEATURE_DIRS_FILE"
        ;;
      ios)
        printf '# Path fragments guarded by the delegation hook (one per line)\n[AppName]/Module\n[AppName]/Shared\n[AppName]Tests/Module\n[AppName]Tests/Shared\n' > "$FEATURE_DIRS_FILE"
        ;;
      *)
        printf '# Path fragments guarded by the delegation hook (one per line)\n' > "$FEATURE_DIRS_FILE"
        ;;
    esac
    echo "create .claude/config/feature-dirs"
  fi

  if grep -q '\[AppName\]' "$FEATURE_DIRS_FILE" 2>/dev/null; then
    echo "  ⚠  Replace [AppName] in .claude/config/feature-dirs with your app target name"
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

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "Done. $PROJECT_ROOT synced to $(git -C "$SUBMODULE" rev-parse --short HEAD) ($PLATFORM)."
