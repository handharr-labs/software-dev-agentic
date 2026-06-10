#!/usr/bin/env bash
# install-plugin.sh — Add the sda marketplace and install sda-core + sda-kms.
#
# Usage:
#   scripts/install-plugin.sh --platform=<id> [--project=<id>]
#
# Available platforms and projects: see sda.json in the repo root
# --project defaults to the current directory name if not specified

set -euo pipefail

SCRIPTS="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPTS/.." && pwd)"
REPO="hndhr/software-dev-agentic"
MARKETPLACE="sda"
PLATFORMS_FILE="$REPO_ROOT/sda.json"
PROJECT_ROOT="$PWD"

# ── Args ──────────────────────────────────────────────────────────────────────

PLATFORM_ID=""
PROJECT_ID=""
for arg in "$@"; do
  case "$arg" in
    --platform=*) PLATFORM_ID="${arg#--platform=}" ;;
    --project=*)  PROJECT_ID="${arg#--project=}" ;;
  esac
done

if [ -z "$PLATFORM_ID" ]; then
  echo "Error: --platform is required."
  echo ""
  python3 -c "
import json
data = json.load(open('$PLATFORMS_FILE'))
print('Available platforms:')
for p in data['platforms']:
    print(f\"  {p['id']:<20} {p['label']}\")
print()
print('Known projects (--project):')
for p in data['projects']:
    print(f\"  {p['id']:<20} {p['label']}\")
"
  exit 1
fi

# ── Validate platform + resolve KMS id ───────────────────────────────────────

KMS_ID="$(python3 -c "
import json, sys
data = json.load(open('$PLATFORMS_FILE'))
match = next((p for p in data['platforms'] if p['id'] == '$PLATFORM_ID'), None)
if not match:
    ids = [p['id'] for p in data['platforms']]
    print(f'Error: unknown platform \"$PLATFORM_ID\". Available: {ids}', file=sys.stderr)
    sys.exit(1)
print(match['kms_id'])
" 2>&1)" || { echo "$KMS_ID"; exit 1; }

PLATFORM_LABEL="$(python3 -c "
import json
data = json.load(open('$PLATFORMS_FILE'))
match = next(p for p in data['platforms'] if p['id'] == '$PLATFORM_ID')
print(match['label'])
")"

# ── Resolve project id + kms_id ───────────────────────────────────────────────

if [ -z "$PROJECT_ID" ]; then
  PROJECT_ID="$(basename "$PROJECT_ROOT")"
  echo ""
  echo "No --project specified, using directory name: $PROJECT_ID"
fi

# Resolve project kms_id (falls back to project id if not in known list)
PROJECT_KMS_ID="$(python3 -c "
import json, sys
data = json.load(open('$PLATFORMS_FILE'))
match = next((p for p in data['projects'] if p['id'] == '$PROJECT_ID'), None)
if not match:
    known = [(p['id'], p.get('kms_id', p['id']), p['label']) for p in data['projects']]
    print(f'Note: \"$PROJECT_ID\" is not in the known projects list in sda.json.', file=sys.stderr)
    print(f'      Known: {[p[0] for p in known]}', file=sys.stderr)
    print(f'      Add it to sda.json if this is a permanent project.', file=sys.stderr)
    print('$PROJECT_ID')
else:
    print(match.get('kms_id', match['id']))
" 2>/dev/null)" || PROJECT_KMS_ID="$PROJECT_ID"

echo ""
echo "Platform: $PLATFORM_LABEL ($PLATFORM_ID → kms: $KMS_ID)"
echo "Project:  $PROJECT_ID (kms: $PROJECT_KMS_ID)"

# ── Marketplace + plugins ─────────────────────────────────────────────────────

echo ""
echo "Adding marketplace: $MARKETPLACE → $REPO"
claude plugin marketplace add "$REPO"

echo ""
echo "Installing sda-core (scope: project)"
claude plugin install "sda-core@${MARKETPLACE}" --scope project

echo ""
echo "Installing sda-kms (scope: project)"
claude plugin install "sda-kms@${MARKETPLACE}" --scope project

# ── settings.local.json — SDA_PLATFORM + skillListingBudgetFraction ──────────

echo ""
SETTINGS_LOCAL="$PROJECT_ROOT/.claude/settings.local.json"
mkdir -p "$PROJECT_ROOT/.claude"

python3 - "$SETTINGS_LOCAL" "$KMS_ID" "$PROJECT_KMS_ID" <<'PYEOF'
import json, os, sys
path, kms_id, project_kms_id = sys.argv[1], sys.argv[2], sys.argv[3]
data = {}
if os.path.exists(path):
    with open(path) as f:
        data = json.load(f)
data.setdefault("env", {})["SDA_PLATFORM"] = kms_id
data["env"]["SDA_PROJECT"] = project_kms_id
data["skillListingBudgetFraction"] = 0.03
with open(path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
print(f"patch .claude/settings.local.json (SDA_PLATFORM={kms_id}, SDA_PROJECT={project_kms_id})")
PYEOF

# ── CLAUDE.md — managed section ───────────────────────────────────────────────

echo ""
CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"
BEGIN_MARKER="<!-- BEGIN software-dev-agentic -->"
END_MARKER="<!-- END software-dev-agentic -->"
MANAGED_BLOCK="$BEGIN_MARKER
**Platform:** $PLATFORM_ID
**Project:** $PROJECT_ID
$END_MARKER"

if [ ! -f "$CLAUDE_MD" ]; then
  printf '%s\n' "$MANAGED_BLOCK" > "$CLAUDE_MD"
  echo "write CLAUDE.md (created with managed section)"
elif grep -qF "$BEGIN_MARKER" "$CLAUDE_MD"; then
  python3 -c "
import re
with open('$CLAUDE_MD') as f:
    content = f.read()
block = '''$MANAGED_BLOCK'''
content = re.sub(r'<!-- BEGIN software-dev-agentic -->.*?<!-- END software-dev-agentic -->', block, content, flags=re.DOTALL)
with open('$CLAUDE_MD', 'w') as f:
    f.write(content)
print('patch CLAUDE.md (managed section updated)')
"
else
  printf '\n%s\n' "$MANAGED_BLOCK" >> "$CLAUDE_MD"
  echo "patch CLAUDE.md (managed section appended)"
fi

# ── .gitignore — agentic-state ────────────────────────────────────────────────

echo ""
GITIGNORE="$PROJECT_ROOT/.gitignore"
if grep -qs 'agentic-state' "$GITIGNORE" 2>/dev/null; then
  echo "skip  .gitignore (agentic-state/ already present)"
else
  printf '\n# Claude Code — agentic state\n.claude/agentic-state/\n' >> "$GITIGNORE"
  echo "patch .gitignore (added agentic-state/)"
fi

# ── .mcp.json — KMS MCP server ────────────────────────────────────────────────

echo ""
PLUGIN_CACHE="$HOME/.claude/plugins/cache/$MARKETPLACE/sda-kms"
LATEST_VERSION="$(ls "$PLUGIN_CACHE" 2>/dev/null | sort -t. -k1,1n -k2,2n -k3,3n | tail -1)"

if [ -n "$LATEST_VERSION" ] && [ -f "$PLUGIN_CACHE/$LATEST_VERSION/kms/server.sh" ]; then
  PROJECT_MCP="$PROJECT_ROOT/.mcp.json"
  KMS_CMD="latest=\$(ls \"$PLUGIN_CACHE\" 2>/dev/null | sort -t. -k1,1n -k2,2n -k3,3n | tail -1) && exec bash \"$PLUGIN_CACHE/\$latest/kms/server.sh\""
  python3 - "$PROJECT_MCP" "$KMS_CMD" <<'PYEOF'
import json, sys, os
mcp_path, kms_cmd = sys.argv[1], sys.argv[2]
data = {}
if os.path.exists(mcp_path):
    with open(mcp_path) as f:
        data = json.load(f)
data.setdefault("mcpServers", {})["kms"] = {
    "command": "bash",
    "args": ["-c", kms_cmd]
}
with open(mcp_path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
print("patch .mcp.json (kms → version-agnostic launcher)")
PYEOF
else
  echo "skip  .mcp.json (sda-kms not found in plugin cache — re-run after install completes)"
fi

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "Done. $PLATFORM_LABEL · $PROJECT_ID configured."
echo ""
echo "Next steps:"
echo "  1. Run /reload-plugins in Claude Code to activate"
echo "  2. Run /kms-seed to seed platform knowledge"
echo "  3. Start with: /developer-build-feature"
