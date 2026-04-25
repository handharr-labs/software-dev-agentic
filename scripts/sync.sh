#!/usr/bin/env bash
# sync.sh
# Pull the latest software-dev-agentic updates and re-link all agents/skills/hooks/reference.
# Run from the project root whenever you want to adopt new agents/skills.
#
# Usage:
#   .claude/software-dev-agentic/scripts/sync.sh --platform=web
#   .claude/software-dev-agentic/scripts/sync.sh --platform=ios

set -euo pipefail

SUBMODULE="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_ROOT="$(cd "$SUBMODULE/../.." && pwd)"

# ── Parse --platform ─────────────────────────────────────────────────────────

PLATFORM=""
for arg in "$@"; do
  case "$arg" in
    --platform=*) PLATFORM="${arg#--platform=}" ;;
  esac
done

# Auto-detect platform from existing skill symlink when --platform is omitted
if [ -z "$PLATFORM" ]; then
  SKILL_LINK="$PROJECT_ROOT/.claude/skills/domain-create-entity"
  if [ -L "$SKILL_LINK" ]; then
    TARGET=$(readlink "$SKILL_LINK")
    case "$TARGET" in
      *platforms/ios*)     PLATFORM="ios" ;;
      *platforms/web*)     PLATFORM="web" ;;
      *platforms/flutter*) PLATFORM="flutter" ;;
    esac
  fi
fi

if [ -z "$PLATFORM" ]; then
  echo "Error: could not detect platform. Pass it explicitly:"
  echo "  $0 --platform=web|ios|flutter"
  exit 1
fi

echo "Platform: $PLATFORM"

# ── Pull latest ───────────────────────────────────────────────────────────────

echo "Pulling latest software-dev-agentic..."
if grep -qsF 'software-dev-agentic' "$PROJECT_ROOT/.gitmodules" 2>/dev/null; then
  git -C "$PROJECT_ROOT" submodule update --remote .claude/software-dev-agentic
else
  echo "  (plain clone detected — using git pull)"
  git -C "$SUBMODULE" pull
fi

# ── Re-link everything ────────────────────────────────────────────────────────

echo ""
"$SUBMODULE/scripts/setup-symlinks.sh" --platform="$PLATFORM"

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
if grep -qsF 'software-dev-agentic' "$PROJECT_ROOT/.gitmodules" 2>/dev/null; then
  echo "Submodule updated. To lock in this version:"
  echo "  git add .claude/software-dev-agentic"
  echo "  git commit -m 'chore: bump software-dev-agentic to $(git -C "$SUBMODULE" rev-parse --short HEAD)'"
else
  echo "Updated to $(git -C "$SUBMODULE" rev-parse --short HEAD)."
fi
