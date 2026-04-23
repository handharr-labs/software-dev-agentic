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
APP_NAME=""
for arg in "$@"; do
  case "$arg" in
    --platform=*) PLATFORM="${arg#--platform=}" ;;
    --app-name=*) APP_NAME="${arg#--app-name=}" ;;
  esac
done

if [ -z "$PLATFORM" ]; then
  echo "Error: --platform is required."
  echo "Usage: $0 --platform=web|ios|flutter"
  exit 1
fi

PLATFORM_DIR="$SUBMODULE/lib/platforms/$PLATFORM"
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
  "$CLAUDE_DIR/config" \
  "$CLAUDE_DIR/agents.local/extensions" \
  "$CLAUDE_DIR/skills.local/extensions" \
  "$CLAUDE_DIR/agentic-state/runs"

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
    [ "$name" = "contract" ] && continue
    [ "$name" = "extensions" ] && continue
    link_if_absent "$rel_prefix/$name" "$CLAUDE_DIR/skills/$name"
  done
  if [ -d "$src_dir/contract" ]; then
    for skill_dir in "$src_dir/contract"/*/; do
      [ -d "$skill_dir" ] || continue
      name="$(basename "$skill_dir")"
      link_if_absent "$rel_prefix/contract/$name" "$CLAUDE_DIR/skills/$name"
    done
  fi
}

link_reference() {
  local src_dir="$1"
  local rel_prefix="$2"
  local dest_base="${3:-$CLAUDE_DIR/reference}"
  [ -d "$src_dir" ] || return 0
  for ref in "$src_dir"/*.md; do
    [ -f "$ref" ] || continue
    name="$(basename "$ref")"
    link_if_absent "$rel_prefix/$name" "$dest_base/$name"
  done
  for subdir in "$src_dir"/*/; do
    [ -d "$subdir" ] || continue
    subname="$(basename "$subdir")"
    mkdir -p "$dest_base/$subname"
    link_reference "$subdir" "$rel_prefix/$subname" "$dest_base/$subname"
  done
}

# Relative paths from .claude/agents/ or .claude/skills/ to submodule
REL_CORE="../software-dev-agentic/lib/core"
REL_PLATFORM="../software-dev-agentic/lib/platforms/$PLATFORM"

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
link_agents "$SUBMODULE/lib/core/agents" "$REL_CORE/agents"
link_skills "$SUBMODULE/lib/core/skills" "$REL_CORE/skills"
link_reference "$SUBMODULE/lib/core/reference" "$REL_CORE/reference"

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
echo "Linking hooks..."
if [ -d "$PLATFORM_DIR/hooks" ]; then
  mkdir -p "$CLAUDE_DIR/hooks"
  for hook in "$PLATFORM_DIR/hooks/"*.sh; do
    [ -f "$hook" ] || continue
    chmod +x "$hook"
    name="$(basename "$hook")"
    link_if_absent "$REL_PLATFORM/hooks/$name" "$CLAUDE_DIR/hooks/$name"
  done
fi

CORE_HOOKS_DIR="$SUBMODULE/lib/core/hooks"
if [ -d "$CORE_HOOKS_DIR" ]; then
  mkdir -p "$CLAUDE_DIR/hooks"
  for hook in "$CORE_HOOKS_DIR/"*.sh; do
    [ -f "$hook" ] || continue
    chmod +x "$hook"
    name="$(basename "$hook")"
    link_if_absent "$REL_CORE/hooks/$name" "$CLAUDE_DIR/hooks/$name"
  done
fi

# ── Settings ──────────────────────────────────────────────────────────────────

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
elif [ -f "$LOCAL_SETTINGS" ] && grep -q 'PROJECT_ROOT/hooks/' "$LOCAL_SETTINGS"; then
  # Migrate: old template used literal PROJECT_ROOT placeholder — replace with correct relative path
  python3 - "$LOCAL_SETTINGS" <<'PYEOF'
import sys, re
f = sys.argv[1]
content = open(f).read()
fixed = re.sub(r'PROJECT_ROOT/hooks/', '.claude/hooks/', content)
if fixed != content:
    open(f, 'w').write(fixed)
    print("  migrate  settings.local.json (PROJECT_ROOT/hooks/ → .claude/hooks/)")
PYEOF
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

# ── .claude/config/feature-dirs ──────────────────────────────────────────────

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
  if [ -f "$PROJECT_ROOT/CLAUDE.md" ] && grep -q '## Feature Directories' "$PROJECT_ROOT/CLAUDE.md" 2>/dev/null; then
    MIGRATED_DIRS=$(python3 -c "
import sys, re
content = open('$PROJECT_ROOT/CLAUDE.md').read()
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
        if [ -n "$APP_NAME" ]; then
          sed -i.bak "s/\[AppName\]/$APP_NAME/g" "$FEATURE_DIRS_FILE" && rm "$FEATURE_DIRS_FILE.bak"
        fi
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

# ── Lockfile ──────────────────────────────────────────────────────────────────

LOCKFILE="$CLAUDE_DIR/config/installed-packages"
if [ ! -f "$LOCKFILE" ]; then
  {
    echo "# Managed by setup-symlinks.sh — do not edit manually"
    echo "platform=$PLATFORM"
    # Core packages
    for pkg_file in "$SUBMODULE/packages"/*.pkg; do
      [ -f "$pkg_file" ] || continue
      pkg_name="$(grep "^name=" "$pkg_file" | cut -d= -f2-)"
      echo "pkg=$pkg_name"
    done
    # Platform packages
    if [ -d "$PLATFORM_DIR/packages" ]; then
      for pkg_file in "$PLATFORM_DIR/packages"/*.pkg; do
        [ -f "$pkg_file" ] || continue
        pkg_name="$(grep "^name=" "$pkg_file" | cut -d= -f2-)"
        echo "pkg=$pkg_name"
      done
    fi
  } > "$LOCKFILE"
  echo "write .claude/config/installed-packages (all packages)"
else
  echo "skip  .claude/config/installed-packages (already exists)"
fi

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "Done. software-dev-agentic ($PLATFORM) is wired."
echo ""
echo "Next steps:"
echo "  1. Fill in CLAUDE.md placeholders"
echo "  2. git add .claude/ && git commit -m 'chore: wire software-dev-agentic ($PLATFORM)'"
