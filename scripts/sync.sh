#!/usr/bin/env bash
# sync.sh
# Pull the latest web-agentic updates and re-run symlink setup.
# Run from the project root whenever you want to adopt new agents/skills.
#
# Usage:
#   .claude/web-agentic/scripts/sync.sh
#
# What it does:
#   1. git pull inside the submodule
#   2. Re-runs setup-symlinks.sh (link_if_absent is idempotent — safe to re-run)
#   3. Reminds you to commit the updated submodule pointer

set -euo pipefail

SUBMODULE="$(cd "$(dirname "$0")/.." && pwd)"

echo "Pulling latest web-agentic..."
git -C "$SUBMODULE" pull

echo ""
echo "Re-running symlink setup..."
"$SUBMODULE/scripts/setup-symlinks.sh"

echo ""
echo "Submodule updated. To lock in this version:"
echo "  git add .claude/web-agentic"
echo "  git commit -m 'chore: bump web-agentic to $(git -C "$SUBMODULE" rev-parse --short HEAD)'"
