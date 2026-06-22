#!/usr/bin/env bash
# cipherpol-9/plugin/build.sh
# Builds cipherpol-9 — generic plan-then-build agents and skills.
# Called by scripts/build-plugin.sh. Expects $SUBMODULE and $VERSION to be set.

set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SUBMODULE/scripts/plugin-lib.sh"

NAME="$(config_field name)"
DESCRIPTION="$(config_field description)"
out="$SUBMODULE/dist/plugins/$NAME"

echo ""
echo "Building plugin: $NAME → dist/plugins/$NAME"

rm -rf "$out"

write_manifest "$NAME" "$DESCRIPTION"
copy_agents
copy_skills
copy_reference

echo "  → test: claude --plugin-dir $out"

update_marketplace "$NAME" "./dist/plugins/$NAME" "$DESCRIPTION"
