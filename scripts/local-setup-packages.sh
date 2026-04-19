#!/usr/bin/env bash
# local-setup-packages.sh
# Non-submodule version of setup-packages.sh. Interactive package installer that
# copies only selected agents and skills into .claude/ of a local project.
# Files are COPIED (not symlinked) — use when the project does not use the submodule pattern.
#
# Run this script directly from the software-dev-agentic repo:
#
#   scripts/local-setup-packages.sh --platform=web --project=/path/to/project
#   scripts/local-setup-packages.sh --platform=ios --project=/path/to/project
#
# Re-running is safe — existing files are never overwritten.

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
CORE_PACKAGES_DIR="$SUBMODULE/packages"
PLATFORM_PACKAGES_DIR="$PLATFORM_DIR/packages"

if [ ! -d "$PLATFORM_DIR" ]; then
  echo "Error: platform '$PLATFORM' not found at $PLATFORM_DIR"
  exit 1
fi

if [ ! -d "$PROJECT_ROOT" ]; then
  echo "Error: project directory not found: $PROJECT_ROOT"
  exit 1
fi

CLAUDE_DIR="$PROJECT_ROOT/.claude"

# ── Helpers ───────────────────────────────────────────────────────────────────

bold()   { printf '\033[1m%s\033[0m' "$*"; }
green()  { printf '\033[32m%s\033[0m' "$*"; }
yellow() { printf '\033[33m%s\033[0m' "$*"; }
cyan()   { printf '\033[36m%s\033[0m' "$*"; }

read_pkg() {
  local file="$1"
  local field="$2"
  grep "^${field}=" "$file" 2>/dev/null | cut -d= -f2-
}

# Resolve an agent name to its source path (platform takes priority over core)
find_agent() {
  local name="$1"
  local found
  found="$(find "$PLATFORM_DIR/agents" -name "$name.md" -type f 2>/dev/null | head -1)"
  if [ -n "$found" ]; then echo "$found"; return; fi
  found="$(find "$SUBMODULE/lib/core/agents" -name "$name.md" -type f 2>/dev/null | head -1)"
  if [ -n "$found" ]; then echo "$found"; fi
}

find_skill() {
  local name="$1"
  if [ -d "$PLATFORM_DIR/skills/contract/$name" ]; then
    echo "$PLATFORM_DIR/skills/contract/$name"
  elif [ -d "$PLATFORM_DIR/skills/$name" ]; then
    echo "$PLATFORM_DIR/skills/$name"
  elif [ -d "$SUBMODULE/lib/core/skills/$name" ]; then
    echo "$SUBMODULE/lib/core/skills/$name"
  fi
}

copy_agent() {
  local name="$1"
  local src dest
  src="$(find_agent "$name")"
  if [ -z "$src" ]; then
    echo "  $(yellow "warn")  agent '$name' not found — skipping"
    return
  fi
  dest="$CLAUDE_DIR/agents/$name.md"
  if [ -e "$dest" ]; then
    echo "  skip  $name"
  else
    cp -f "$src" "$dest"
    echo "  $(green "copy")  $name"
  fi
}

copy_skill() {
  local name="$1"
  local src dest
  src="$(find_skill "$name")"
  if [ -z "$src" ]; then
    echo "  $(yellow "warn")  skill '$name' not found — skipping"
    return
  fi
  dest="$CLAUDE_DIR/skills/$name"
  if [ -e "$dest" ]; then
    echo "  skip  $name"
  else
    cp -rf "$src" "$dest"
    echo "  $(green "copy")  $name"
  fi
}

install_pkg() {
  local pkg_file="$1"
  local pkg_name agents skills
  pkg_name="$(read_pkg "$pkg_file" name)"
  echo ""
  echo "  Installing $(bold "$pkg_name")..."
  agents="$(read_pkg "$pkg_file" agents)"
  skills="$(read_pkg "$pkg_file" skills)"
  for agent in $agents; do copy_agent "$agent"; done
  for skill in $skills; do copy_skill "$skill"; done
}

# ── Directory setup ───────────────────────────────────────────────────────────

echo ""
echo "$(bold "software-dev-agentic package installer") (platform: $PLATFORM)"
echo "────────────────────────────────────────────────────────"

mkdir -p \
  "$CLAUDE_DIR/agents" "$CLAUDE_DIR/skills" "$CLAUDE_DIR/reference" \
  "$CLAUDE_DIR/hooks" "$CLAUDE_DIR/config" \
  "$CLAUDE_DIR/agents.local/extensions" "$CLAUDE_DIR/skills.local/extensions" \
  "$CLAUDE_DIR/agentic-state/runs"

# ── Local overrides ───────────────────────────────────────────────────────────

for agent in "$CLAUDE_DIR/agents.local"/*.md; do
  [ -f "$agent" ] || continue
  name="$(basename "$agent")"
  [ -e "$CLAUDE_DIR/agents/$name" ] && continue
  cp -f "$agent" "$CLAUDE_DIR/agents/$name"
  echo "  $(green "copy")  $name (local override)"
done

# ── Core (always installed) ───────────────────────────────────────────────────

install_pkg "$CORE_PACKAGES_DIR/core.pkg"

# ── Core agent group selection ────────────────────────────────────────────────

echo ""
echo "$(bold "Core agent groups:")"
echo ""

core_groups=(builder detective auditor)
core_group_pkgs=()
for group in "${core_groups[@]}"; do
  pkg_file="$CORE_PACKAGES_DIR/$group.pkg"
  [ -f "$pkg_file" ] && core_group_pkgs+=("$pkg_file")
done

if [ ${#core_group_pkgs[@]} -gt 0 ]; then
  i=1
  for pkg_file in "${core_group_pkgs[@]}"; do
    pkg_name="$(read_pkg "$pkg_file" name)"
    pkg_desc="$(read_pkg "$pkg_file" description)"
    printf "  $(cyan "[%d]") %-12s %s\n" "$i" "$pkg_name" "$pkg_desc"
    i=$((i + 1))
  done

  echo ""
  echo "  Enter group numbers (e.g. $(bold "1 2")), $(bold "all"), or $(bold "none"):"
  printf "  > "
  read -r core_selection
  echo ""

  if [ "$core_selection" = "none" ]; then
    echo "  No core agent groups selected."
  elif [ "$core_selection" = "all" ]; then
    for pkg_file in "${core_group_pkgs[@]}"; do install_pkg "$pkg_file"; done
  else
    for num in $core_selection; do
      if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#core_group_pkgs[@]}" ]; then
        install_pkg "${core_group_pkgs[$((num - 1))]}"
      else
        echo "  $(yellow "warn")  '$num' is not a valid option — skipping"
      fi
    done
  fi
fi

# ── Platform package selection ────────────────────────────────────────────────

echo ""
echo "$(bold "Available packages for $PLATFORM:")"
echo ""

optional_pkgs=()
if [ -d "$PLATFORM_PACKAGES_DIR" ]; then
  for pkg_file in "$PLATFORM_PACKAGES_DIR"/*.pkg; do
    [ -f "$pkg_file" ] || continue
    optional_pkgs+=("$pkg_file")
  done
fi

if [ ${#optional_pkgs[@]} -eq 0 ]; then
  echo "  (no optional packages defined for $PLATFORM)"
else
  i=1
  for pkg_file in "${optional_pkgs[@]}"; do
    pkg_name="$(read_pkg "$pkg_file" name)"
    pkg_desc="$(read_pkg "$pkg_file" description)"
    printf "  $(cyan "[%d]") %-16s %s\n" "$i" "$pkg_name" "$pkg_desc"
    i=$((i + 1))
  done

  echo ""
  echo "  Enter package numbers (e.g. $(bold "1 2")), $(bold "all"), or $(bold "none"):"
  printf "  > "
  read -r selection
  echo ""

  if [ "$selection" = "none" ]; then
    echo "  No optional packages selected."
  elif [ "$selection" = "all" ]; then
    for pkg_file in "${optional_pkgs[@]}"; do install_pkg "$pkg_file"; done
  else
    for num in $selection; do
      if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#optional_pkgs[@]}" ]; then
        install_pkg "${optional_pkgs[$((num - 1))]}"
      else
        echo "  $(yellow "warn")  '$num' is not a valid option — skipping"
      fi
    done
  fi
fi

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
echo "Installing hooks..."
for hooks_src in "$SUBMODULE/lib/core/hooks" "$PLATFORM_DIR/hooks"; do
  [ -d "$hooks_src" ] || continue
  for hook in "$hooks_src/"*.sh; do
    [ -f "$hook" ] || continue
    name="$(basename "$hook")"
    dest="$CLAUDE_DIR/hooks/$name"
    # Hooks are always overwritten — they are toolkit files users should not edit,
    # and re-running the script is the upgrade path for hook changes (e.g. guard updates).
    cp "$hook" "$dest"
    chmod +x "$dest"
    echo "  $(green "copy")  $name"
  done
done

# ── Settings ─────────────────────────────────────────────────────────────────

echo ""
SETTINGS_FILE="$CLAUDE_DIR/settings.local.json"
if [ ! -f "$SETTINGS_FILE" ]; then
  if [ -f "$PLATFORM_DIR/settings-template.json" ]; then
    cp "$PLATFORM_DIR/settings-template.json" "$SETTINGS_FILE"
    echo "copy  settings.local.json"
    echo "  $(yellow "⚠")  Replace PROJECT_ROOT in settings.local.json with: $CLAUDE_DIR"
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

echo ""
if [ -f "$PROJECT_ROOT/CLAUDE.md" ]; then
  echo "skip  CLAUDE.md (already exists)"
elif [ -f "$PLATFORM_DIR/CLAUDE-template.md" ]; then
  cp "$PLATFORM_DIR/CLAUDE-template.md" "$PROJECT_ROOT/CLAUDE.md"
  echo "copy  CLAUDE.md"

  if grep -q '\[AppName\]' "$PROJECT_ROOT/CLAUDE.md"; then
    if [ -z "$APP_NAME" ]; then
      printf "  App name (replaces [AppName] in CLAUDE.md): "
      read -r APP_NAME
    fi
    if [ -n "$APP_NAME" ]; then
      sed -i.bak "s/\[AppName\]/$APP_NAME/g" "$PROJECT_ROOT/CLAUDE.md" && rm "$PROJECT_ROOT/CLAUDE.md.bak"
      echo "  $(green "✓")  Replaced [AppName] with '$APP_NAME'"
    else
      echo "  $(yellow "⚠")  Fill in [AppName] placeholders in CLAUDE.md"
    fi
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
    echo "  $(yellow "⚠")  Replace [AppName] in .claude/config/feature-dirs with your app target name"
  fi
fi

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "────────────────────────────────────────────────────────"
echo "$(green "Done.") software-dev-agentic ($PLATFORM) packages installed into $PROJECT_ROOT."
echo ""
echo "Next steps:"
echo "  1. Fill in CLAUDE.md placeholders"
echo "  2. Edit .claude/settings.local.json — replace PROJECT_ROOT"
echo "  3. git add .claude/ && git commit -m 'chore: wire software-dev-agentic ($PLATFORM)'"
