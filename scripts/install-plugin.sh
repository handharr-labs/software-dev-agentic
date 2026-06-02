#!/usr/bin/env bash
# install-plugin.sh — Add the sda marketplace and install the platform plugin.
#
# Usage:
#   scripts/install-plugin.sh --platform=flutter-mobile-talenta

set -euo pipefail

SCRIPTS="$(cd "$(dirname "$0")" && pwd)"
REPO="hndhr/software-dev-agentic"
MARKETPLACE="sda"
RAW_BASE="https://raw.githubusercontent.com/${REPO}/main"

PLATFORM=""
for arg in "$@"; do
  case "$arg" in
    --platform=*) PLATFORM="${arg#--platform=}" ;;
  esac
done

if [ -z "$PLATFORM" ]; then
  echo "Error: --platform is required."
  echo "Usage: $0 --platform=<platform>"
  exit 1
fi

PLUGIN_NAME="sda-${PLATFORM}"
PROJECT_ROOT="$PWD"

# ── Marketplace + plugin ──────────────────────────────────────────────────────

echo ""
echo "Adding marketplace: $MARKETPLACE → $REPO"
claude plugin marketplace add "$REPO"

echo ""
echo "Installing plugin: $PLUGIN_NAME@$MARKETPLACE (scope: project)"
claude plugin install "${PLUGIN_NAME}@${MARKETPLACE}" --scope project

# ── settings.json — skillListingBudgetFraction ───────────────────────────────

SETTINGS_FILE="$PROJECT_ROOT/.claude/settings.json"
if [ -f "$SETTINGS_FILE" ] && ! grep -q "skillListingBudgetFraction" "$SETTINGS_FILE"; then
  python3 -c "
import json
with open('$SETTINGS_FILE') as f:
    s = json.load(f)
s['skillListingBudgetFraction'] = 0.03
with open('$SETTINGS_FILE', 'w') as f:
    json.dump(s, f, indent=2)
print('  skillListingBudgetFraction set to 0.03')
"
fi

# ── .gitignore — agentic-state ───────────────────────────────────────────────

echo ""
GITIGNORE="$PROJECT_ROOT/.gitignore"
if grep -qs 'agentic-state' "$GITIGNORE" 2>/dev/null; then
  echo "skip  .gitignore (agentic-state/ already present)"
else
  printf '\n# Claude Code — agentic state (delegation flags, session state, run artifacts)\n.claude/agentic-state/\n' >> "$GITIGNORE"
  echo "patch .gitignore (added agentic-state/)"
fi

# ── CLAUDE.md — apply platform template ──────────────────────────────────────

echo ""
TEMPLATE_URL="$RAW_BASE/lib/platforms/$PLATFORM/CLAUDE-template.md"
TEMPLATE_CONTENT="$(curl -fsSL "$TEMPLATE_URL" 2>/dev/null || true)"

if [ -z "$TEMPLATE_CONTENT" ]; then
  echo "skip  CLAUDE.md (no template for $PLATFORM)"
else
  BEGIN_MARKER="<!-- BEGIN software-dev-agentic"
  CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"

  if [ ! -f "$CLAUDE_MD" ]; then
    printf '%s\n' "$TEMPLATE_CONTENT" > "$CLAUDE_MD"
    echo "copy  CLAUDE.md (from $PLATFORM template)"
  elif grep -qF "$BEGIN_MARKER" "$CLAUDE_MD"; then
    # Extract just the managed block from template and replace in existing file
    BLOCK="$(echo "$TEMPLATE_CONTENT" | sed -n "/${BEGIN_MARKER}/,/END software-dev-agentic/p")"
    python3 -c "
import re, sys
with open('$CLAUDE_MD') as f:
    content = f.read()
block = '''$BLOCK'''
content = re.sub(r'<!-- BEGIN software-dev-agentic.*?END software-dev-agentic[^\n]*-->', block, content, flags=re.DOTALL)
with open('$CLAUDE_MD', 'w') as f:
    f.write(content)
"
    echo "sync  CLAUDE.md (managed section updated)"
  else
    printf '\n%s\n' "$TEMPLATE_CONTENT" >> "$CLAUDE_MD"
    echo "append CLAUDE.md ($PLATFORM block)"
  fi
fi

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "Done. Run /reload-plugins in Claude Code to activate."
echo "Then use: /developer-build-feature"
