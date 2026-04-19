#!/usr/bin/env bash
# manage-packages.sh
# Interactive package and hook manager for software-dev-agentic.
# Shows current enabled/disabled state and lets the user toggle mid-run.
#
# Usage (run from the downstream project root):
#   .claude/software-dev-agentic/scripts/manage-packages.sh --platform=web
#   .claude/software-dev-agentic/scripts/manage-packages.sh --platform=ios

set -euo pipefail

SUBMODULE="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_ROOT="$(cd "$SUBMODULE/../.." && pwd)"
CLAUDE_DIR="$PROJECT_ROOT/.claude"

# ── Parse args ────────────────────────────────────────────────────────────────

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

PLATFORM_DIR="$SUBMODULE/lib/platforms/$PLATFORM"
CORE_PACKAGES_DIR="$SUBMODULE/packages"
PLATFORM_PACKAGES_DIR="$PLATFORM_DIR/packages"
DISABLED_PKGS_FILE="$CLAUDE_DIR/config/disabled-packages"
DISABLED_HOOKS_FILE="$CLAUDE_DIR/config/disabled-hooks"

if [ ! -d "$PLATFORM_DIR" ]; then
  echo "Error: platform '$PLATFORM' not found at $PLATFORM_DIR"
  exit 1
fi

# ── Color helpers ─────────────────────────────────────────────────────────────

bold()   { printf '\033[1m%s\033[0m' "$*"; }
green()  { printf '\033[32m%s\033[0m' "$*"; }
yellow() { printf '\033[33m%s\033[0m' "$*"; }
cyan()   { printf '\033[36m%s\033[0m' "$*"; }
red()    { printf '\033[31m%s\033[0m' "$*"; }
dim()    { printf '\033[2m%s\033[0m' "$*"; }

read_pkg() {
  local file="$1" field="$2"
  grep "^${field}=" "$file" 2>/dev/null | cut -d= -f2-
}

# ── State helpers ─────────────────────────────────────────────────────────────

pkg_is_enabled() {
  # A package is considered enabled if at least one of its symlinks exists
  local pkg_file="$1"
  local agents skills
  agents="$(read_pkg "$pkg_file" agents)"
  skills="$(read_pkg "$pkg_file" skills)"
  for agent in $agents; do
    [ -L "$CLAUDE_DIR/agents/$agent.md" ] && return 0
  done
  for skill in $skills; do
    [ -L "$CLAUDE_DIR/skills/$skill" ] && return 0
  done
  return 1
}

hook_is_enabled() {
  local name="$1"
  # Enabled unless listed in disabled-hooks
  if [ -f "$DISABLED_HOOKS_FILE" ] && grep -qx "$name" "$DISABLED_HOOKS_FILE" 2>/dev/null; then
    return 1
  fi
  return 0
}

# ── Symlink helpers ───────────────────────────────────────────────────────────

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

rel_path() {
  local src="$1" base="$2"
  python3 -c "import os; print(os.path.relpath('$src', '$base'))" 2>/dev/null || echo "$src"
}

link_if_absent() {
  local target="$1" link="$2"
  if [ -e "$link" ] || [ -L "$link" ]; then return 0; fi
  ln -s "$target" "$link"
}

# ── Package enable / disable ──────────────────────────────────────────────────

enable_pkg() {
  local pkg_file="$1"
  local pkg_name agents skills
  pkg_name="$(read_pkg "$pkg_file" name)"
  agents="$(read_pkg "$pkg_file" agents)"
  skills="$(read_pkg "$pkg_file" skills)"

  for agent in $agents; do
    local src; src="$(find_agent "$agent")"
    if [ -z "$src" ]; then
      echo "    $(yellow "warn")  agent '$agent' not found — skipping"
      continue
    fi
    link_if_absent "$(rel_path "$src" "$CLAUDE_DIR/agents")" "$CLAUDE_DIR/agents/$agent.md"
    echo "    $(green "link")  $agent"
  done

  for skill in $skills; do
    local src; src="$(find_skill "$skill")"
    if [ -z "$src" ]; then
      echo "    $(yellow "warn")  skill '$skill' not found — skipping"
      continue
    fi
    link_if_absent "$(rel_path "$src" "$CLAUDE_DIR/skills")" "$CLAUDE_DIR/skills/$skill"
    echo "    $(green "link")  $skill"
  done

  # Remove from disabled list
  if [ -f "$DISABLED_PKGS_FILE" ]; then
    local tmp; tmp="$(mktemp)"
    grep -vx "$pkg_name" "$DISABLED_PKGS_FILE" > "$tmp" 2>/dev/null || true
    mv "$tmp" "$DISABLED_PKGS_FILE"
  fi
}

disable_pkg() {
  local pkg_file="$1"
  local pkg_name agents skills
  pkg_name="$(read_pkg "$pkg_file" name)"
  agents="$(read_pkg "$pkg_file" agents)"
  skills="$(read_pkg "$pkg_file" skills)"

  for agent in $agents; do
    local link="$CLAUDE_DIR/agents/$agent.md"
    if [ -L "$link" ]; then
      rm "$link"
      echo "    $(red "unlink")  $agent"
    fi
  done

  for skill in $skills; do
    local link="$CLAUDE_DIR/skills/$skill"
    if [ -L "$link" ]; then
      rm "$link"
      echo "    $(red "unlink")  $skill"
    fi
  done

  # Record in disabled list so enable_pkg can re-create later
  mkdir -p "$(dirname "$DISABLED_PKGS_FILE")"
  grep -qx "$pkg_name" "$DISABLED_PKGS_FILE" 2>/dev/null || echo "$pkg_name" >> "$DISABLED_PKGS_FILE"
}

# ── Hook enable / disable ─────────────────────────────────────────────────────

enable_hook() {
  local name="$1"
  if [ -f "$DISABLED_HOOKS_FILE" ]; then
    local tmp; tmp="$(mktemp)"
    grep -vx "$name" "$DISABLED_HOOKS_FILE" > "$tmp" 2>/dev/null || true
    mv "$tmp" "$DISABLED_HOOKS_FILE"
  fi
  echo "  $(green "enable")   $name"
}

disable_hook() {
  local name="$1"
  mkdir -p "$(dirname "$DISABLED_HOOKS_FILE")"
  grep -qx "$name" "$DISABLED_HOOKS_FILE" 2>/dev/null || echo "$name" >> "$DISABLED_HOOKS_FILE"
  echo "  $(red "disable")  $name"
}

# ── Build package list ────────────────────────────────────────────────────────

all_pkg_files=()
for group in builder detective auditor; do
  pkg_file="$CORE_PACKAGES_DIR/$group.pkg"
  [ -f "$pkg_file" ] && all_pkg_files+=("$pkg_file")
done
if [ -d "$PLATFORM_PACKAGES_DIR" ]; then
  for pkg_file in "$PLATFORM_PACKAGES_DIR"/*.pkg; do
    [ -f "$pkg_file" ] || continue
    all_pkg_files+=("$pkg_file")
  done
fi

# ── Build hook list (only installed hooks) ────────────────────────────────────

all_hook_names=()
for hooks_src in "$SUBMODULE/lib/core/hooks" "$PLATFORM_DIR/hooks"; do
  [ -d "$hooks_src" ] || continue
  for hook in "$hooks_src/"*.sh; do
    [ -f "$hook" ] || continue
    name="$(basename "$hook" .sh)"
    if [ -f "$CLAUDE_DIR/hooks/$name.sh" ] || [ -L "$CLAUDE_DIR/hooks/$name.sh" ]; then
      all_hook_names+=("$name")
    fi
  done
done

# ── Header ────────────────────────────────────────────────────────────────────

echo ""
echo "$(bold "software-dev-agentic package manager") (platform: $(bold "$PLATFORM"))"
echo "────────────────────────────────────────────────────────"
echo "  $(green "✓") enabled · $(red "✗") disabled  |  enter numbers to toggle, $(bold "Enter") to skip"

# ── Packages ──────────────────────────────────────────────────────────────────

if [ ${#all_pkg_files[@]} -gt 0 ]; then
  echo ""
  echo "$(bold "Packages:")"
  echo ""

  i=1
  for pkg_file in "${all_pkg_files[@]}"; do
    pkg_name="$(read_pkg "$pkg_file" name)"
    pkg_desc="$(read_pkg "$pkg_file" description)"
    if pkg_is_enabled "$pkg_file"; then
      marker="$(green "✓")"
    else
      marker="$(red "✗")"
    fi
    printf "  [$(cyan "%d")] %s  %-16s %s\n" "$i" "$marker" "$(bold "$pkg_name")" "$(dim "$pkg_desc")"
    i=$((i + 1))
  done

  echo ""
  printf "  > "
  read -r pkg_selection

  if [ -n "$pkg_selection" ]; then
    echo ""
    for num in $pkg_selection; do
      if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#all_pkg_files[@]}" ]; then
        pkg_file="${all_pkg_files[$((num - 1))]}"
        pkg_name="$(read_pkg "$pkg_file" name)"
        if pkg_is_enabled "$pkg_file"; then
          echo "  Disabling $(bold "$pkg_name")..."
          disable_pkg "$pkg_file"
        else
          echo "  Enabling $(bold "$pkg_name")..."
          enable_pkg "$pkg_file"
        fi
      else
        echo "  $(yellow "warn")  '$num' is not a valid selection — skipping"
      fi
    done
  fi
fi

# ── Hooks ─────────────────────────────────────────────────────────────────────

if [ ${#all_hook_names[@]} -gt 0 ]; then
  echo ""
  echo "$(bold "Hooks:")"
  echo ""

  i=1
  for name in "${all_hook_names[@]}"; do
    if hook_is_enabled "$name"; then
      marker="$(green "✓")"
    else
      marker="$(red "✗")"
    fi
    printf "  [$(cyan "%d")] %s  %s\n" "$i" "$marker" "$name"
    i=$((i + 1))
  done

  echo ""
  printf "  > "
  read -r hook_selection

  if [ -n "$hook_selection" ]; then
    echo ""
    for num in $hook_selection; do
      if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#all_hook_names[@]}" ]; then
        name="${all_hook_names[$((num - 1))]}"
        if hook_is_enabled "$name"; then
          disable_hook "$name"
        else
          enable_hook "$name"
        fi
      else
        echo "  $(yellow "warn")  '$num' is not a valid selection — skipping"
      fi
    done
  fi
fi

# ── Done ─────────────────────────────────────────────────────────────────────

echo ""
echo "────────────────────────────────────────────────────────"
echo "$(green "Done.")"
echo ""
