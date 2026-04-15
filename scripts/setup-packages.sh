#!/usr/bin/env bash
# setup-packages.sh
# Interactive package installer for software-dev-agentic.
# Presents available packages for the chosen platform, lets the user choose,
# then symlinks only the selected agents and skills. Core package always installed.
#
# Usage (run from the downstream project root):
#   .claude/software-dev-agentic/scripts/setup-packages.sh --platform=web
#   .claude/software-dev-agentic/scripts/setup-packages.sh --platform=ios
#
# Re-running is safe — existing symlinks are never overwritten.

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
CORE_PACKAGES_DIR="$SUBMODULE/packages"
PLATFORM_PACKAGES_DIR="$PLATFORM_DIR/packages"

if [ ! -d "$PLATFORM_DIR" ]; then
  echo "Error: platform '$PLATFORM' not found at $PLATFORM_DIR"
  exit 1
fi

# ── Helpers ───────────────────────────────────────────────────────────────────

bold()   { printf '\033[1m%s\033[0m' "$*"; }
green()  { printf '\033[32m%s\033[0m' "$*"; }
yellow() { printf '\033[33m%s\033[0m' "$*"; }
cyan()   { printf '\033[36m%s\033[0m' "$*"; }

link_if_absent() {
  local target="$1"
  local link="$2"
  if [ -e "$link" ] || [ -L "$link" ]; then
    echo "  skip  $(basename $link)"
  else
    ln -s "$target" "$link"
    echo "  $(green "link")  $(basename $link)"
  fi
}

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
  if [ -d "$PLATFORM_DIR/skills/$name" ]; then
    echo "$PLATFORM_DIR/skills/$name"
  elif [ -d "$SUBMODULE/lib/core/skills/$name" ]; then
    echo "$SUBMODULE/lib/core/skills/$name"
  fi
}

link_agent() {
  local name="$1"
  local src link rel
  src="$(find_agent "$name")"
  if [ -z "$src" ]; then
    echo "  $(yellow "warn")  agent '$name' not found — skipping"
    return
  fi
  link="$CLAUDE_DIR/agents/$name.md"
  # Relative path from .claude/agents/ to the source
  rel="$(python3 -c "import os; print(os.path.relpath('$src', '$CLAUDE_DIR/agents'))" 2>/dev/null || \
        realpath --relative-to="$CLAUDE_DIR/agents" "$src" 2>/dev/null || \
        echo "$src")"
  link_if_absent "$rel" "$link"
}

link_skill() {
  local name="$1"
  local src link rel
  src="$(find_skill "$name")"
  if [ -z "$src" ]; then
    echo "  $(yellow "warn")  skill '$name' not found — skipping"
    return
  fi
  link="$CLAUDE_DIR/skills/$name"
  rel="$(python3 -c "import os; print(os.path.relpath('$src', '$CLAUDE_DIR/skills'))" 2>/dev/null || \
        realpath --relative-to="$CLAUDE_DIR/skills" "$src" 2>/dev/null || \
        echo "$src")"
  link_if_absent "$rel" "$link"
}

install_pkg() {
  local pkg_file="$1"
  local pkg_name agents skills
  pkg_name="$(read_pkg "$pkg_file" name)"
  echo ""
  echo "  Installing $(bold "$pkg_name")..."
  agents="$(read_pkg "$pkg_file" agents)"
  skills="$(read_pkg "$pkg_file" skills)"
  for agent in $agents; do link_agent "$agent"; done
  for skill in $skills; do link_skill "$skill"; done
}

# ── Directory setup ───────────────────────────────────────────────────────────

echo ""
echo "$(bold "software-dev-agentic package installer") (platform: $PLATFORM)"
echo "────────────────────────────────────────────────────────"

for dir in "$CLAUDE_DIR/agents" "$CLAUDE_DIR/skills" "$CLAUDE_DIR/reference"; do
  if [ -L "$dir" ]; then
    echo "convert  $dir (directory symlink → real directory)"
    rm "$dir"; mkdir -p "$dir"
  fi
done
mkdir -p \
  "$CLAUDE_DIR/agents" "$CLAUDE_DIR/skills" "$CLAUDE_DIR/reference" \
  "$CLAUDE_DIR/agents.local/extensions" "$CLAUDE_DIR/skills.local/extensions"

# ── Local overrides ───────────────────────────────────────────────────────────

for agent in "$CLAUDE_DIR/agents.local"/*.md; do
  [ -f "$agent" ] || continue
  name="$(basename "$agent")"
  [ -e "$CLAUDE_DIR/agents/$name" ] || [ -L "$CLAUDE_DIR/agents/$name" ] && continue
  ln -s "../agents.local/$name" "$CLAUDE_DIR/agents/$name"
  echo "  $(green "link")  $name (local override)"
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

# ── Hooks ─────────────────────────────────────────────────────────────────────

echo ""
echo "Installing hooks..."
mkdir -p "$CLAUDE_DIR/hooks"
for hooks_src in "$SUBMODULE/lib/core/hooks" "$PLATFORM_DIR/hooks"; do
  [ -d "$hooks_src" ] || continue
  for hook in "$hooks_src/"*.sh; do
    [ -f "$hook" ] || continue
    chmod +x "$hook"
    name="$(basename "$hook")"
    dest="$CLAUDE_DIR/hooks/$name"
    if [ -e "$dest" ]; then
      echo "  skip  $name"
    else
      cp "$hook" "$dest"
      chmod +x "$dest"
      echo "  copy  $name"
    fi
  done
done

# ── Settings ─────────────────────────────────────────────────────────────────

echo ""
if [ -f "$CLAUDE_DIR/settings.local.json" ]; then
  echo "skip  settings.local.json (already exists)"
elif [ -f "$PLATFORM_DIR/settings-template.json" ]; then
  cp "$PLATFORM_DIR/settings-template.json" "$CLAUDE_DIR/settings.local.json"
  echo "copy  settings.local.json"
  echo "  $(yellow "⚠")  Replace PROJECT_ROOT in settings.local.json with: $CLAUDE_DIR"
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

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "────────────────────────────────────────────────────────"
echo "$(green "Done.") software-dev-agentic ($PLATFORM) packages installed."
echo ""
echo "Next steps:"
echo "  1. Fill in CLAUDE.md placeholders"
echo "  2. Edit .claude/settings.local.json — replace PROJECT_ROOT"
echo "  3. git add .claude/ && git commit -m 'chore: wire software-dev-agentic ($PLATFORM)'"
