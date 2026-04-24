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

link_reference() {
  local src_dir="$1"
  local rel_prefix="$2"
  local dest_base="${3:-$PROJECT_ROOT/.claude/reference}"
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
    link_reference "$subdir" "../$rel_prefix/$subname" "$dest_base/$subname"
  done
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
    link="${link%/}"
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
  # Prune dangling hook symlinks
  for link in "$PROJECT_ROOT/.claude/hooks/"*.sh; do
    [ -L "$link" ] || continue
    if [ ! -e "$link" ]; then
      rm "$link"; echo "  remove  $(basename "$link") (dangling hook)"; stale_found=true
    fi
  done
  # Prune dangling reference symlinks (recursive — reference/ has subdirs)
  if [ -d "$PROJECT_ROOT/.claude/reference" ]; then
    while IFS= read -r link; do
      if [ ! -e "$link" ]; then
        rm "$link"; echo "  remove  ${link#$PROJECT_ROOT/.claude/} (dangling reference)"; stale_found=true
      fi
    done < <(find "$PROJECT_ROOT/.claude/reference" -type l)
  fi

  $stale_found || echo "  clean"

  # Re-link reference files (always — reference/ is not tracked by the lockfile)
  echo ""
  echo "  Re-linking reference..."
  CLAUDE_DIR="$PROJECT_ROOT/.claude"
  REL_BASE="../software-dev-agentic/lib"
  link_reference "$SUBMODULE/lib/platforms/$PLATFORM/reference" "$REL_BASE/platforms/$PLATFORM/reference"
  link_reference "$SUBMODULE/lib/core/reference" "$REL_BASE/core/reference"
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

# ── settings.local.json — migrate stale PROJECT_ROOT/hooks/ placeholder ───────

echo ""
LOCAL_SETTINGS="$PROJECT_ROOT/.claude/settings.local.json"
if [ -f "$LOCAL_SETTINGS" ] && grep -q 'PROJECT_ROOT/hooks/' "$LOCAL_SETTINGS"; then
  python3 - "$LOCAL_SETTINGS" <<'PYEOF'
import sys, re
f = sys.argv[1]
content = open(f).read()
fixed = re.sub(r'PROJECT_ROOT/hooks/', '.claude/hooks/', content)
if fixed != content:
    open(f, 'w').write(fixed)
    print("  migrate  settings.local.json (PROJECT_ROOT/hooks/ → .claude/hooks/)")
PYEOF
else
  echo "skip  settings.local.json migration (not needed)"
fi

# ── settings.json ─────────────────────────────────────────────────────────────

echo ""
SHARED_SETTINGS="$PROJECT_ROOT/.claude/settings.json"
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

echo ""
if grep -qsF 'software-dev-agentic' "$PROJECT_ROOT/.gitmodules" 2>/dev/null; then
  echo "Submodule updated. To lock in this version:"
  echo "  git add .claude/software-dev-agentic"
  echo "  git commit -m 'chore: bump software-dev-agentic to $(git -C "$SUBMODULE" rev-parse --short HEAD)'"
else
  echo "Updated to $(git -C "$SUBMODULE" rev-parse --short HEAD)."
fi
