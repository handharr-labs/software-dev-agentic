#!/usr/bin/env bash
# Hook: Require delegation to feature-orchestrator for feature directory edits on feat/* branches
# Event: PreToolUse on Write|Edit
# Input: JSON on stdin with keys: session_id, tool_name, tool_input
#
# Config: .claude/config/feature-dirs — one path fragment per line, # comments ignored.
# Flag:   .claude/agentic-state/delegation.json — written by feature-orchestrator at session start,
#         cleared at end. Session-scoped: a new session_id wipes all stale entries automatically.
# Session: .claude/agentic-state/.session-id — tracks the active session; updated on session boundary.
#
# Block condition: any branch except main/develop + file matches a feature dir + no delegation entry

# Disable guard — exits 0 immediately if listed in .claude/config/disabled-hooks
_hook_name="$(basename "$0" .sh)"
_disabled_file="$(dirname "$0")/../config/disabled-hooks"
if [ -f "$_disabled_file" ] && grep -qx "$_hook_name" "$_disabled_file" 2>/dev/null; then exit 0; fi
unset _hook_name _disabled_file

set -euo pipefail

INPUT=$(cat)

TOOL=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null || true)

if [[ "$TOOL" != "Write" && "$TOOL" != "Edit" ]]; then
  exit 0
fi

# Session boundary detection — wipe stale delegation entries when session_id changes
PROJECT_ROOT_EARLY=$(git rev-parse --show-toplevel 2>/dev/null || true)
if [[ -n "$PROJECT_ROOT_EARLY" ]]; then
  CURRENT_SESSION=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('session_id',''))" 2>/dev/null || true)
  SESSION_FILE="$PROJECT_ROOT_EARLY/.claude/agentic-state/.session-id"
  if [[ -n "$CURRENT_SESSION" ]]; then
    STORED_SESSION=$(cat "$SESSION_FILE" 2>/dev/null || true)
    if [[ "$CURRENT_SESSION" != "$STORED_SESSION" ]]; then
      # New session — clear all entries in delegation.json
      python3 -c "
import json, os, sys
f = sys.argv[1]
if os.path.exists(f):
    tmp = f + '.tmp'
    json.dump({}, open(tmp, 'w'), indent=2)
    os.replace(tmp, f)
" "$PROJECT_ROOT_EARLY/.claude/agentic-state/delegation.json" 2>/dev/null || true
      echo "$CURRENT_SESSION" > "$SESSION_FILE"
    fi
  fi
fi

# Not a feat/* or feature/* branch — allow
BRANCH=$(git branch --show-current 2>/dev/null || true)
if [[ "$BRANCH" == "main" || "$BRANCH" == "develop" ]]; then
  exit 0
fi

FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); ti=d.get('tool_input',{}); print(ti.get('file_path', ti.get('path','')))" 2>/dev/null || true)

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# Parse feature directories from .claude/config/feature-dirs
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || true)
FEATURE_DIRS_FILE="$PROJECT_ROOT/.claude/config/feature-dirs"

if [[ ! -f "$FEATURE_DIRS_FILE" ]]; then
  exit 0
fi

FEATURE_DIRS=$(grep -v '^\s*#' "$FEATURE_DIRS_FILE" | grep -v '^\s*$' 2>/dev/null || true)

if [[ -z "$FEATURE_DIRS" ]]; then
  exit 0
fi

# Check if file path matches a feature directory fragment
IS_FEATURE_FILE=false
while IFS= read -r dir; do
  [[ -z "$dir" ]] && continue
  if [[ "$FILE_PATH" == *"$dir"* ]]; then
    IS_FEATURE_FILE=true
    break
  fi
done <<< "$FEATURE_DIRS"

if [[ "$IS_FEATURE_FILE" == false ]]; then
  exit 0
fi

# Delegation check — read from delegation.json; allow if entry exists and is fresh (< 4h)
BRANCH_SLUG=$(echo "$BRANCH" | tr '/' '-')
DELEGATION_FILE="$PROJECT_ROOT/.claude/agentic-state/delegation.json"
FLAG_TIME=$(python3 -c "
import json, os, sys
f, slug = sys.argv[1], sys.argv[2]
if not os.path.exists(f): print(0); exit()
d = json.load(open(f))
print(d.get(slug, 0))
" "$DELEGATION_FILE" "$BRANCH_SLUG" 2>/dev/null || echo 0)

NOW=$(date +%s)
AGE=$((NOW - FLAG_TIME))
if [[ "$FLAG_TIME" -gt 0 && "$AGE" -lt 14400 ]]; then
  exit 0
fi
# No entry or stale (> 4h) — fall through to block

# Block — agent must stop and surface to user; must not resolve autonomously
echo "BLOCKED: Feature directory edit on feat/* or feature/* branch requires delegation."
echo ""
echo "  Branch : $BRANCH"
echo "  File   : $FILE_PATH"
echo "  Reason : No active delegation for this branch (missing or stale > 4h)"
echo ""
echo "STOP. Do not proceed. Do not write the delegation entry yourself."
echo "Use AskUserQuestion with exactly these three options and wait for the user's selection:"
echo ""
echo "  Option 1: \"Plan first with feature-planner (review before writing)\""
echo "             Invoke feature-planner to produce a reviewable plan.md before any code is written."
echo "             No files are modified. After review, run feature-orchestrator to execute."
echo ""
echo "  Option 2: \"Delegate to feature-orchestrator (execute now)\""
echo "             Invoke feature-orchestrator to coordinate this feature build across all layers."
echo ""
echo "  Option 3: \"Proceed inline (bypass delegation)\""
echo "             Only if the user explicitly wants to continue without the orchestrator."
echo ""
echo "Take no further action until the user selects an option."
exit 2
