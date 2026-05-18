#!/usr/bin/env bash
# clean-ai.sh — Remove AI config and compiled skill artifacts from the project.
#
# Usage:
#   software-dev-agentic/scripts/clean-ai.sh --ai=copilot --platform=ios-talenta
#   software-dev-agentic/scripts/clean-ai.sh --ai=gemini  --platform=web

set -euo pipefail

SUBMODULE="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_ROOT="$(cd "$SUBMODULE/.." && pwd)"

# ── Parse args ────────────────────────────────────────────────────────────────

AI=""
PLATFORM=""
for arg in "$@"; do
  case "$arg" in
    --ai=*)       AI="${arg#--ai=}" ;;
    --platform=*) PLATFORM="${arg#--platform=}" ;;
  esac
done

if [ -z "$AI" ]; then
  echo "Error: --ai is required. Options: copilot, gemini"
  exit 1
fi

if [ -z "$PLATFORM" ]; then
  echo "Error: --platform is required. Options: ios, web, flutter, android"
  exit 1
fi

# ── Resolve Phase 1 target ────────────────────────────────────────────────────

case "$AI" in
  copilot) TARGET="$PROJECT_ROOT/.github/copilot-instructions.md" ;;
  gemini)  TARGET="$PROJECT_ROOT/GEMINI.md" ;;
  *)
    echo "Error: unknown AI '$AI'. Options: copilot, gemini"
    exit 1
    ;;
esac

# ── Confirm ───────────────────────────────────────────────────────────────────

echo "This will remove all $AI config and compiled skill artifacts for platform: $PLATFORM."
printf "  Proceed? [y/N]: "
read -r confirm
case "$confirm" in
  y|Y|yes|YES) ;;
  *) echo "  Aborted."; exit 0 ;;
esac

# ── Phase 1 — Remove main config file ────────────────────────────────────────

if [ -f "$TARGET" ]; then
  rm "$TARGET"
  echo "  removed  $TARGET"
else
  echo "  skip (not found)  $TARGET"
fi

# ── Helpers ───────────────────────────────────────────────────────────────────

_get_skill_name() {
  awk '
    BEGIN { in_fm=0 }
    /^---/ { in_fm++; if (in_fm > 1) exit; next }
    in_fm == 1 && /^name:/ { sub(/^name:[[:space:]]*/, ""); print; exit }
  ' "$1"
}

# ── Phase 2 — Gemini ──────────────────────────────────────────────────────────

_clean_gemini_phase2() {
  # .agents/skills/ is entirely ours — remove all symlinks we created
  local skills_target="$PROJECT_ROOT/.agents/skills"
  if [ -d "$skills_target" ]; then
    rm -rf "$skills_target"
    echo "  removed  .agents/skills/"
  else
    echo "  skip (not found)  .agents/skills/"
  fi

  # .gemini/commands/ is entirely ours — remove the directory
  local cmds_target="$PROJECT_ROOT/.gemini/commands"
  if [ -d "$cmds_target" ]; then
    rm -rf "$cmds_target"
    echo "  removed  .gemini/commands/"
  else
    echo "  skip (not found)  .gemini/commands/"
  fi
}

# ── Phase 2 — Copilot (surgical — .github/ may have user files) ───────────────

_clean_copilot_phase2() {
  # Remove generated agent files (T/U skills from platform flat + core)
  for dir in "$SUBMODULE/lib/platforms/$PLATFORM/skills" "$SUBMODULE/lib/core/skills"; do
    [ -d "$dir" ] || continue
    for skill_dir in "$dir"/*/; do
      [ "$(basename "$skill_dir")" = "contract" ] && continue
      local skill_file="$skill_dir/SKILL.md"
      [ -f "$skill_file" ] || continue
      local name
      name="$(_get_skill_name "$skill_file")"
      [ -n "$name" ] || name="$(basename "$skill_dir")"
      local agent_file="$PROJECT_ROOT/.github/agents/$name.agent.md"
      if [ -f "$agent_file" ]; then
        rm "$agent_file"
        echo "  removed  .github/agents/$name.agent.md"
      fi
    done
  done

  # Remove generated instructions files (Type A contract skills)
  local contract_dir="$SUBMODULE/lib/platforms/$PLATFORM/skills/contract"
  if [ -d "$contract_dir" ]; then
    for skill_dir in "$contract_dir"/*/; do
      [ -d "$skill_dir" ] || continue
      local skill_file="$skill_dir/SKILL.md"
      [ -f "$skill_file" ] || continue
      local name
      name="$(_get_skill_name "$skill_file")"
      [ -n "$name" ] || name="$(basename "$skill_dir")"
      local instr_file="$PROJECT_ROOT/.github/instructions/$name.instructions.md"
      if [ -f "$instr_file" ]; then
        rm "$instr_file"
        echo "  removed  .github/instructions/$name.instructions.md"
      fi
    done
  fi
}

# ── Phase 2 — Dispatch ────────────────────────────────────────────────────────

case "$AI" in
  gemini)  _clean_gemini_phase2 ;;
  copilot) _clean_copilot_phase2 ;;
esac

echo ""
echo "Done. $AI artifacts removed."
