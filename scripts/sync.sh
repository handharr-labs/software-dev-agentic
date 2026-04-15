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
git -C "$PROJECT_ROOT" submodule update --remote .claude/software-dev-agentic

echo ""
echo "Re-running symlink setup..."
"$SUBMODULE/scripts/setup-symlinks.sh" --platform="$PLATFORM"

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
if grep -qs '\.delegated-\*' "$GITIGNORE" 2>/dev/null; then
  echo "skip  .gitignore (.delegated-* already present)"
else
  printf '\n# Claude Code — delegation flags and session state\n.claude/.delegated-*\n.claude/.session-id\n.claude/runs/\n' >> "$GITIGNORE"
  echo "patch .gitignore (added .delegated-*, .session-id, runs/)"
fi
if ! grep -qs '\.claude/runs/' "$GITIGNORE" 2>/dev/null; then
  printf '.claude/.session-id\n.claude/runs/\n' >> "$GITIGNORE"
  echo "patch .gitignore (added .session-id, runs/)"
fi

# ── settings.local.json ───────────────────────────────────────────────────────

echo ""
SETTINGS_FILE="$PROJECT_ROOT/.claude/settings.local.json"
if [ ! -f "$SETTINGS_FILE" ]; then
  echo "skip  settings.local.json (not found)"
elif grep -q 'require-feature-orchestrator' "$SETTINGS_FILE"; then
  echo "skip  settings.local.json (require-feature-orchestrator already present)"
else
  RESULT=$(python3 - "$SETTINGS_FILE" "$PROJECT_ROOT/.claude" <<'EOF'
import sys, re

settings_file, claude_dir = sys.argv[1], sys.argv[2]
hook_cmd = claude_dir + "/hooks/require-feature-orchestrator.sh"
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
    echo "patch settings.local.json (added require-feature-orchestrator hook)"
  else
    echo "warn  settings.local.json — could not auto-patch, add manually:"
    echo "      { \"type\": \"command\", \"command\": \"$PROJECT_ROOT/.claude/hooks/require-feature-orchestrator.sh\" }"
  fi
fi

# ── CLAUDE.md — Feature Directories (iOS — outside managed block) ─────────────

echo ""
PLATFORM_TEMPLATE="$SUBMODULE/lib/platforms/$PLATFORM/CLAUDE-template.md"
if [ -f "$CLAUDE_MD" ] && [ -f "$PLATFORM_TEMPLATE" ] && ! grep -q '## Feature Directories' "$CLAUDE_MD"; then
  FEAT_DIRS=$(python3 -c "
import sys, re
content = open('$PLATFORM_TEMPLATE').read()
m = re.search(r'## Feature Directories\s+\x60\x60\x60\s*(.*?)\s*\x60\x60\x60', content, re.DOTALL)
print(m.group(1).strip() if m else '')
")
  if [ -n "$FEAT_DIRS" ]; then
    printf '\n## Feature Directories\n\n```\n%s\n```\n' "$FEAT_DIRS" >> "$CLAUDE_MD"
    echo "patch CLAUDE.md (added ## Feature Directories)"
    if echo "$FEAT_DIRS" | grep -q '\[AppName\]'; then
      APP_NAME=""
      printf "  App name (replaces [AppName]): "
      read -r APP_NAME
      if [ -n "$APP_NAME" ]; then
        sed -i.bak "s/\[AppName\]/$APP_NAME/g" "$CLAUDE_MD" && rm "$CLAUDE_MD.bak"
        echo "  ✓  Replaced [AppName] with '$APP_NAME'"
      fi
    fi
  fi
else
  echo "skip  CLAUDE.md Feature Directories (already present or template not found)"
fi

echo ""
echo "Submodule updated. To lock in this version:"
echo "  git add .claude/software-dev-agentic"
echo "  git commit -m 'chore: bump software-dev-agentic to $(git -C "$SUBMODULE" rev-parse --short HEAD)'"
