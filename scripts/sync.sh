#!/usr/bin/env bash
# sync.sh
# Pull the latest software-dev-agentic updates and re-run symlink setup.
# Run from the project root whenever you want to adopt new agents/skills.
#
# Usage:
#   .claude/software-dev-agentic/scripts/sync.sh --platform=web
#   .claude/software-dev-agentic/scripts/sync.sh --platform=ios

set -euo pipefail

SUBMODULE="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_ROOT="$(cd "$SUBMODULE/../.." && pwd)"
CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"

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

TEMPLATE="$SUBMODULE/lib/platforms/$PLATFORM/CLAUDE-template.md"
BEGIN_MARKER="<!-- BEGIN software-dev-agentic:$PLATFORM -->"
END_MARKER="<!-- END software-dev-agentic:$PLATFORM -->"

echo "Pulling latest software-dev-agentic..."
if grep -qsF 'software-dev-agentic' "$PROJECT_ROOT/.gitmodules" 2>/dev/null; then
  git -C "$PROJECT_ROOT" submodule update --remote .claude/software-dev-agentic
else
  echo "  (plain clone detected — using git pull)"
  git -C "$SUBMODULE" pull
fi

LOCKFILE="$PROJECT_ROOT/.claude/config/installed-packages"

# ── Helpers ───────────────────────────────────────────────────────────────────

read_pkg() { grep "^${2}=" "$1" 2>/dev/null | cut -d= -f2-; }

link_if_absent() {
  local target="$1" link="$2"
  if [ -e "$link" ] || [ -L "$link" ]; then
    echo "  skip  $(basename "$link")"
  else
    ln -s "$target" "$link"
    echo "  link  $(basename "$link")"
  fi
}

find_agent() {
  local name="$1" found
  found="$(find "$SUBMODULE/lib/platforms/$PLATFORM/agents" -name "$name.md" -type f 2>/dev/null | head -1)"
  [ -n "$found" ] && { echo "$found"; return; }
  find "$SUBMODULE/lib/core/agents" -name "$name.md" -type f 2>/dev/null | head -1
}

find_skill() {
  local name="$1"
  if [ -d "$SUBMODULE/lib/platforms/$PLATFORM/skills/contract/$name" ]; then
    echo "$SUBMODULE/lib/platforms/$PLATFORM/skills/contract/$name"
  elif [ -d "$SUBMODULE/lib/platforms/$PLATFORM/skills/$name" ]; then
    echo "$SUBMODULE/lib/platforms/$PLATFORM/skills/$name"
  elif [ -d "$SUBMODULE/lib/core/skills/$name" ]; then
    echo "$SUBMODULE/lib/core/skills/$name"
  fi
}

link_agent() {
  local name="$1" src link rel
  src="$(find_agent "$name")"
  [ -z "$src" ] && { echo "  warn  agent '$name' not found — skipping"; return; }
  link="$PROJECT_ROOT/.claude/agents/$name.md"
  rel="$(python3 -c "import os; print(os.path.relpath('$src', '$(dirname "$link")'))" 2>/dev/null || echo "$src")"
  link_if_absent "$rel" "$link"
}

link_skill() {
  local name="$1" src link rel
  src="$(find_skill "$name")"
  [ -z "$src" ] && { echo "  warn  skill '$name' not found — skipping"; return; }
  link="$PROJECT_ROOT/.claude/skills/$name"
  rel="$(python3 -c "import os; print(os.path.relpath('$src', '$(dirname "$link")'))" 2>/dev/null || echo "$src")"
  link_if_absent "$rel" "$link"
}

# ── Package-aware sync ────────────────────────────────────────────────────────

echo ""
if [ ! -f "$LOCKFILE" ]; then
  echo "No installed-packages lockfile found — falling back to setup-symlinks.sh"
  echo "(Run setup-packages.sh first to enable package-aware sync)"
  "$SUBMODULE/scripts/setup-symlinks.sh" --platform="$PLATFORM"
else
  echo "Re-syncing installed packages..."
  echo ""

  # Collect expected agent and skill names from installed packages
  expected_agents=()
  expected_skills=()

  while IFS= read -r line; do
    [[ "$line" =~ ^pkg=(.+)$ ]] || continue
    pkg_name="${BASH_REMATCH[1]}"
    pkg_file=""
    [ -f "$SUBMODULE/packages/$pkg_name.pkg" ] && pkg_file="$SUBMODULE/packages/$pkg_name.pkg"
    [ -f "$SUBMODULE/lib/platforms/$PLATFORM/packages/$pkg_name.pkg" ] && pkg_file="$SUBMODULE/lib/platforms/$PLATFORM/packages/$pkg_name.pkg"
    if [ -z "$pkg_file" ]; then
      echo "  warn  package '$pkg_name' not found in submodule — skipping"
      continue
    fi
    for a in $(read_pkg "$pkg_file" agents); do expected_agents+=("$a"); done
    for s in $(read_pkg "$pkg_file" skills); do expected_skills+=("$s"); done
  done < "$LOCKFILE"

  # Link missing agents and skills
  echo "  Linking..."
  for agent in "${expected_agents[@]}"; do link_agent "$agent"; done
  for skill in "${expected_skills[@]}"; do link_skill "$skill"; done

  # Remove stale agent symlinks (point into submodule but not in expected set)
  echo ""
  echo "  Cleaning stale symlinks..."
  stale_found=false
  for link in "$PROJECT_ROOT/.claude/agents/"*.md; do
    [ -L "$link" ] || continue
    target="$(readlink "$link")"
    [[ "$target" == *"software-dev-agentic"* ]] || continue
    name="$(basename "$link" .md)"
    if [ ! -e "$link" ]; then
      rm "$link"; echo "  remove  $name.md (dangling)"; stale_found=true; continue
    fi
    in_expected=false
    for e in "${expected_agents[@]}"; do [ "$e" = "$name" ] && in_expected=true && break; done
    if ! $in_expected; then
      rm "$link"; echo "  remove  $name.md (not in installed packages)"; stale_found=true
    fi
  done
  for link in "$PROJECT_ROOT/.claude/skills/"*/; do
    [ -L "$link" ] || continue
    target="$(readlink "$link")"
    [[ "$target" == *"software-dev-agentic"* ]] || continue
    name="$(basename "$link")"
    if [ ! -e "$link" ]; then
      rm "$link"; echo "  remove  $name (dangling)"; stale_found=true; continue
    fi
    in_expected=false
    for e in "${expected_skills[@]}"; do [ "$e" = "$name" ] && in_expected=true && break; done
    if ! $in_expected; then
      rm "$link"; echo "  remove  $name (not in installed packages)"; stale_found=true
    fi
  done
  $stale_found || echo "  clean"
fi

# ── Sync managed section in CLAUDE.md ────────────────────────────────────────

echo ""
if [ ! -f "$CLAUDE_MD" ]; then
  echo "skip  CLAUDE.md sync (file not found — run setup-symlinks.sh first)"
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
SHARED_SETTINGS="$PROJECT_ROOT/.claude/settings.json"
if [ ! -f "$SHARED_SETTINGS" ]; then
  echo "skip  settings.json (not found)"
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

# ── .claude/config/feature-dirs ──────────────────────────────────────────────
# setup-symlinks.sh (called above) handles creation and migration.
# This check just confirms the file is present after setup.

echo ""
FEATURE_DIRS_FILE="$PROJECT_ROOT/.claude/config/feature-dirs"
if [ -f "$FEATURE_DIRS_FILE" ]; then
  echo "skip  .claude/config/feature-dirs (already exists)"
else
  echo "warn  .claude/config/feature-dirs — not found after setup, delegation hook will not guard any directories"
  echo "      Run: .claude/software-dev-agentic/scripts/setup-symlinks.sh --platform=$PLATFORM"
fi

echo ""
if grep -qsF 'software-dev-agentic' "$PROJECT_ROOT/.gitmodules" 2>/dev/null; then
  echo "Submodule updated. To lock in this version:"
  echo "  git add .claude/software-dev-agentic"
  echo "  git commit -m 'chore: bump software-dev-agentic to $(git -C "$SUBMODULE" rev-parse --short HEAD)'"
else
  echo "Updated to $(git -C "$SUBMODULE" rev-parse --short HEAD)."
fi
