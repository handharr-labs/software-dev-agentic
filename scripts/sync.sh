#!/usr/bin/env bash
# sync.sh
# Pull the latest software-dev-agentic updates and re-link all agents/skills/hooks/reference.
# Run from the project root whenever you want to adopt new agents/skills.
#
# Usage:
#   software-dev-agentic/scripts/sync.sh --platform=web
#   software-dev-agentic/scripts/sync.sh --platform=ios-talenta
#   software-dev-agentic/scripts/sync.sh --platform=android-talenta
#   software-dev-agentic/scripts/sync.sh --platform=flutter-mobile-talenta
#   software-dev-agentic/scripts/sync.sh --platform=flutter-qontak-chat

set -euo pipefail

SUBMODULE="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_ROOT="$(cd "$SUBMODULE/.." && pwd)"

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
      *platforms/ios-talenta*)            PLATFORM="ios-talenta" ;;
      *platforms/android-talenta*)        PLATFORM="android-talenta" ;;
      *platforms/web*)                    PLATFORM="web" ;;
      *platforms/flutter-qontak-chat*)    PLATFORM="flutter-qontak-chat" ;;
      *platforms/flutter-mobile-talenta*) PLATFORM="flutter-mobile-talenta" ;;
    esac
  fi
fi

if [ -z "$PLATFORM" ]; then
  echo "Error: could not detect platform. Pass it explicitly:"
  echo "  $0 --platform=web|ios-talenta|android-talenta|flutter-mobile-talenta|flutter-qontak-chat"
  exit 1
fi

echo "Platform: $PLATFORM"

# ── Pull latest ───────────────────────────────────────────────────────────────

echo "Pulling latest software-dev-agentic..."
if grep -qsF 'software-dev-agentic' "$PROJECT_ROOT/.gitmodules" 2>/dev/null; then
  git -C "$PROJECT_ROOT" submodule update --init --remote software-dev-agentic
else
  echo "  (plain clone detected — using git pull)"
  git -C "$SUBMODULE" pull origin main
fi

# ── Re-link everything ────────────────────────────────────────────────────────

echo ""
"$SUBMODULE/scripts/setup-symlinks.sh" --platform="$PLATFORM"

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
if grep -qsF 'software-dev-agentic' "$PROJECT_ROOT/.gitmodules" 2>/dev/null; then
  echo "Submodule updated. To lock in this version:"
  echo "  git add software-dev-agentic"
  echo "  git commit -m 'chore: bump software-dev-agentic to $(git -C "$SUBMODULE" rev-parse --short HEAD)'"
else
  echo "Updated to $(git -C "$SUBMODULE" rev-parse --short HEAD)."
fi
