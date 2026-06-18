#!/usr/bin/env bash
# Launch the KMS Dashboard local web UI.
#
# Usage:
#   bash scripts/kms-dashboard.sh [port]
#
# Reads from dist/.kms_seeds/.shared/chroma (shared seed).
# Writes dashboard:{timestamp} to dist/.kms_seeds/.version on every upsert,
# signalling build-plugin.sh to skip file-based reseed.
#
# Run '/kms-seed' first if the shared DB doesn't exist.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PORT="${1:-5173}"

SHARED_CHROMA="$REPO_ROOT/dist/.kms_seeds/.shared/chroma"

if [ ! -d "$SHARED_CHROMA" ]; then
  echo "Shared ChromaDB not found at dist/.kms_seeds/.shared/chroma"
  echo "Run: /kms-seed"
  exit 1
fi

if ! command -v python3 &>/dev/null; then
  echo "ERROR: python3 not found."
  exit 1
fi

if ! python3 -c "import chromadb, yaml" 2>/dev/null; then
  echo "Installing KMS dependencies (one-time)..."
  pip3 install -q -r "$REPO_ROOT/cipherpol-8-kms/requirements.txt" \
    || { echo "ERROR: pip install failed. Run: pip install chromadb PyYAML"; exit 1; }
fi

export KMS_DB_PATH="$SHARED_CHROMA"
export KMS_REPO_ROOT="$REPO_ROOT"

URL="http://localhost:$PORT"

# Open browser (macOS / Linux)
if command -v open &>/dev/null; then
  open "$URL" &
elif command -v xdg-open &>/dev/null; then
  xdg-open "$URL" &
fi

echo "KMS Dashboard → $URL"
echo "  DB:   $KMS_DB_PATH"
echo "  Ctrl+C to stop."

PYTHONPATH="$REPO_ROOT" python3 -m kms.dashboard.server "$PORT"
