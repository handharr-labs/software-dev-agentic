#!/usr/bin/env bash
# build-plugin.sh
# Discovers plugins in lib/plugins/ and runs each plugin's build.sh.
#
# Usage:
#   scripts/build-plugin.sh                  # build all plugins
#   scripts/build-plugin.sh --target=cipherpol-aegis
#   scripts/build-plugin.sh --target=cipherpol-8
#
# Output: dist/plugins/<plugin-name>/
# Test:   claude --plugin-dir dist/plugins/cipherpol-aegis

set -euo pipefail

export SUBMODULE="$(cd "$(dirname "$0")/.." && pwd)"
export VERSION="$(cat "$SUBMODULE/VERSION")"

# ── Args ──────────────────────────────────────────────────────────────────────

TARGET=""
for arg in "$@"; do
  case "$arg" in
    --target=*) TARGET="${arg#--target=}" ;;
  esac
done

# ── Discover and run ──────────────────────────────────────────────────────────

ran=0
for build_script in "$SUBMODULE/lib/plugins"/*/build.sh; do
  [ -f "$build_script" ] || continue
  plugin_name="$(basename "$(dirname "$build_script")")"
  if [ -n "$TARGET" ] && [ "$plugin_name" != "$TARGET" ]; then
    continue
  fi
  chmod +x "$build_script"
  bash "$build_script"
  ran=$((ran + 1))
done

if [ "$ran" -eq 0 ]; then
  if [ -n "$TARGET" ]; then
    echo "Error: no plugin named '$TARGET' found in lib/plugins/"
    echo "Available: $(ls "$SUBMODULE/lib/plugins/" | tr '\n' ' ')"
  else
    echo "Error: no plugins found in lib/plugins/"
  fi
  exit 1
fi

# ── Stage marketplace ─────────────────────────────────────────────────────────

git -C "$SUBMODULE" add "$SUBMODULE/.claude-plugin/marketplace.json" 2>/dev/null || true

echo ""
echo "Done. Version: $VERSION"
echo ""
echo "Next steps:"
echo "  Test locally:  claude --plugin-dir dist/plugins/cipherpol-aegis"
echo "  Distribute:    git add dist/plugins/ .claude-plugin/marketplace.json && git commit -m 'chore(plugin): build $VERSION'"
