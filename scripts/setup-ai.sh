#!/usr/bin/env bash
# setup-ai.sh — Generate AI config and compile lib/ skills for another AI platform.
# Safe to re-run — skips existing generated files.
#
# Usage:
#   software-dev-agentic/scripts/setup-ai.sh --ai=copilot --platform=ios-talenta [--app-name=MyApp]
#   software-dev-agentic/scripts/setup-ai.sh --ai=gemini  --platform=web [--app-name=MyApp]

set -euo pipefail

SUBMODULE="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_ROOT="$(cd "$SUBMODULE/.." && pwd)"

# ── Parse args ────────────────────────────────────────────────────────────────

AI=""
PLATFORM=""
APP_NAME=""

for arg in "$@"; do
  case "$arg" in
    --ai=*)       AI="${arg#--ai=}" ;;
    --platform=*) PLATFORM="${arg#--platform=}" ;;
    --app-name=*) APP_NAME="${arg#--app-name=}" ;;
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

TEMPLATE="$SUBMODULE/lib/ai-platforms/$AI/template.md"
if [ ! -f "$TEMPLATE" ]; then
  echo "Error: no template for '$AI' at $TEMPLATE"
  exit 1
fi

# ── Resolve output path per AI ─────────────────────────────────────────────────

case "$AI" in
  copilot)
    OUTPUT="$PROJECT_ROOT/.github/copilot-instructions.md"
    mkdir -p "$PROJECT_ROOT/.github"
    ;;
  gemini)
    OUTPUT="$PROJECT_ROOT/GEMINI.md"
    ;;
  *)
    echo "Error: unknown AI '$AI'. Options: copilot, gemini"
    exit 1
    ;;
esac

# ── Prompt before overwrite ───────────────────────────────────────────────────

if [ -f "$OUTPUT" ]; then
  printf "  '%s' already exists. Overwrite? [y/N]: " "$(basename "$OUTPUT")"
  read -r confirm
  case "$confirm" in
    y|Y|yes|YES) ;;
    *) echo "  Skipped."; exit 0 ;;
  esac
fi

# ── Prompt for app name if missing ────────────────────────────────────────────

if [ -z "$APP_NAME" ]; then
  printf "  App name (replaces [APP_NAME] in template): "
  read -r APP_NAME
fi

# ── Generate ──────────────────────────────────────────────────────────────────

echo "Generating $AI config (platform: $PLATFORM)..."

# Substitute placeholders
sed \
  -e "s/\[APP_NAME\]/${APP_NAME:-MyApp}/g" \
  -e "s/\[PLATFORM\]/$PLATFORM/g" \
  "$TEMPLATE" > "$OUTPUT"

echo "  wrote  $OUTPUT"

# ── Helpers ───────────────────────────────────────────────────────────────────

# Extract a single-line frontmatter field value from a SKILL.md
_get_field() {
  local file="$1" field="$2"
  awk "
    BEGIN { in_fm=0 }
    /^---/ { in_fm++; if (in_fm > 1) exit; next }
    in_fm == 1 && /^${field}:/ {
      sub(/^${field}:[[:space:]]*/, \"\")
      print; exit
    }
  " "$file"
}

# Extract description (handles both inline and block scalar |/>)
_get_description() {
  awk '
    BEGIN { in_fm=0; in_desc=0 }
    /^---/ { in_fm++; if (in_fm > 1) exit; next }
    in_fm == 1 && /^description:/ {
      val = $0; sub(/^description:[[:space:]]*/, "", val)
      if (val == "|" || val == ">" || val == ">-" || val == "|-") { in_desc = 1; next }
      gsub(/"/, "\\\"", val); print val; exit
    }
    in_fm == 1 && in_desc && /^[[:space:]]/ {
      sub(/^[[:space:]]+/, ""); gsub(/"/, "\\\""); print; exit
    }
    in_fm == 1 && in_desc { exit }
  ' "$1"
}

# Extract skill body (everything after closing ---)
_get_body() {
  awk 'BEGIN{f=0} /^---/{f++; if(f==2){found=1; next}} found{print}' "$1"
}

# Derive Copilot applyTo glob from skill name prefix
_derive_glob() {
  case "$1" in
    domain-*) echo "**/Domain/**" ;;
    data-*)   echo "**/Data/**" ;;
    pres-*)   echo "**/Presentation/**" ;;
    test-*)   echo "**/*Test*" ;;
    *)        echo "**" ;;
  esac
}

# ── Phase 2 — Gemini ──────────────────────────────────────────────────────────

_link_gemini_skills() {
  local contract_dir="$SUBMODULE/lib/platforms/$PLATFORM/skills/contract"
  [ -d "$contract_dir" ] || return 0
  mkdir -p "$PROJECT_ROOT/.agents/skills"
  for skill_dir in "$contract_dir"/*/; do
    [ -d "$skill_dir" ] || continue
    local name
    name="$(basename "$skill_dir")"
    local target="$PROJECT_ROOT/.agents/skills/$name"
    if [ -e "$target" ]; then
      echo "  skip (exists)  .agents/skills/$name"
    else
      ln -s "$skill_dir" "$target"
      echo "  linked  .agents/skills/$name"
    fi
  done
}

_write_gemini_toml() {
  local skill_dir="$1"
  local skill_file="$skill_dir/SKILL.md"
  [ -f "$skill_file" ] || return 0

  local user_invocable
  user_invocable="$(_get_field "$skill_file" "user-invocable")"
  [ "$user_invocable" = "true" ] || return 0

  local name desc body toml_file
  name="$(_get_field "$skill_file" "name")"
  [ -n "$name" ] || name="$(basename "$skill_dir")"
  desc="$(_get_description "$skill_file")"
  body="$(_get_body "$skill_file")"
  toml_file="$PROJECT_ROOT/.gemini/commands/$name.toml"

  if [ -f "$toml_file" ]; then
    echo "  skip (exists)  .gemini/commands/$name.toml"
    return 0
  fi

  printf 'description = "%s"\nprompt = """\n%s\n"""\n' "$desc" "$body" > "$toml_file"
  echo "  wrote  .gemini/commands/$name.toml"
}

_generate_gemini_commands() {
  mkdir -p "$PROJECT_ROOT/.gemini/commands"

  local flat_dir="$SUBMODULE/lib/platforms/$PLATFORM/skills"
  if [ -d "$flat_dir" ]; then
    for skill_dir in "$flat_dir"/*/; do
      [ "$(basename "$skill_dir")" = "contract" ] && continue
      _write_gemini_toml "$skill_dir"
    done
  fi

  local core_dir="$SUBMODULE/lib/core/skills"
  if [ -d "$core_dir" ]; then
    for skill_dir in "$core_dir"/*/; do
      _write_gemini_toml "$skill_dir"
    done
  fi
}

# ── Phase 2 — Copilot ─────────────────────────────────────────────────────────

_write_copilot_agent() {
  local skill_dir="$1"
  local skill_file="$skill_dir/SKILL.md"
  [ -f "$skill_file" ] || return 0

  local user_invocable
  user_invocable="$(_get_field "$skill_file" "user-invocable")"
  [ "$user_invocable" = "true" ] || return 0

  local name desc body out_file
  name="$(_get_field "$skill_file" "name")"
  [ -n "$name" ] || name="$(basename "$skill_dir")"
  desc="$(_get_description "$skill_file")"
  body="$(_get_body "$skill_file")"
  out_file="$PROJECT_ROOT/.github/agents/$name.agent.md"

  if [ -f "$out_file" ]; then
    echo "  skip (exists)  .github/agents/$name.agent.md"
    return 0
  fi

  printf -- '---\nname: %s\ndescription: "%s"\n---\n%s\n' "$name" "$desc" "$body" > "$out_file"
  echo "  wrote  .github/agents/$name.agent.md"
}

_generate_copilot_agents() {
  mkdir -p "$PROJECT_ROOT/.github/agents"

  local flat_dir="$SUBMODULE/lib/platforms/$PLATFORM/skills"
  if [ -d "$flat_dir" ]; then
    for skill_dir in "$flat_dir"/*/; do
      [ "$(basename "$skill_dir")" = "contract" ] && continue
      _write_copilot_agent "$skill_dir"
    done
  fi

  local core_dir="$SUBMODULE/lib/core/skills"
  if [ -d "$core_dir" ]; then
    for skill_dir in "$core_dir"/*/; do
      _write_copilot_agent "$skill_dir"
    done
  fi
}

_generate_copilot_instructions() {
  local contract_dir="$SUBMODULE/lib/platforms/$PLATFORM/skills/contract"
  [ -d "$contract_dir" ] || return 0
  mkdir -p "$PROJECT_ROOT/.github/instructions"

  for skill_dir in "$contract_dir"/*/; do
    [ -d "$skill_dir" ] || continue
    local skill_file="$skill_dir/SKILL.md"
    [ -f "$skill_file" ] || continue

    local name body glob out_file
    name="$(_get_field "$skill_file" "name")"
    [ -n "$name" ] || name="$(basename "$skill_dir")"
    body="$(_get_body "$skill_file")"
    glob="$(_derive_glob "$name")"
    out_file="$PROJECT_ROOT/.github/instructions/$name.instructions.md"

    if [ -f "$out_file" ]; then
      echo "  skip (exists)  .github/instructions/$name.instructions.md"
      continue
    fi

    printf -- '---\napplyTo: "%s"\n---\n%s\n' "$glob" "$body" > "$out_file"
    echo "  wrote  .github/instructions/$name.instructions.md"
  done
}

# ── Phase 2 — Compile skills ──────────────────────────────────────────────────

echo ""
echo "Compiling skills for $AI (platform: $PLATFORM)..."

case "$AI" in
  gemini)
    _link_gemini_skills
    _generate_gemini_commands
    ;;
  copilot)
    _generate_copilot_agents
    _generate_copilot_instructions
    ;;
esac

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "Done. $AI is configured for $PLATFORM."
echo ""
case "$AI" in
  copilot)
    echo "Next steps:"
    echo "  1. Review .github/copilot-instructions.md"
    echo "  2. Review .github/agents/ and .github/instructions/"
    echo "  3. git add .github/ && git commit -m 'chore: add copilot config ($PLATFORM)'"
    ;;
  gemini)
    echo "Next steps:"
    echo "  1. Review GEMINI.md — Gemini will auto-import .claude/reference/ via @import"
    echo "  2. Review .gemini/commands/ and .agents/skills/"
    echo "  3. git add GEMINI.md .gemini/ .agents/ && git commit -m 'chore: add gemini config ($PLATFORM)'"
    ;;
esac
