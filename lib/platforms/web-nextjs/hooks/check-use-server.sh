#!/usr/bin/env bash
# Hook: Warn when 'use server' is missing from action files
# Event: PostToolUse on Write
# Non-blocking (exits 0 with a warning message)

set -euo pipefail

INPUT=$(cat)

TOOL=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null || true)

if [[ "$TOOL" != "Write" ]]; then
  exit 0
fi

FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); ti=d.get('tool_input',{}); print(ti.get('file_path', ti.get('path','')))" 2>/dev/null || true)

# Only check action files: presentation/actions/*.ts
if ! echo "$FILE_PATH" | grep -qE 'presentation/actions/[^/]+\.ts$'; then
  exit 0
fi

if [[ ! -f "$FILE_PATH" ]]; then
  exit 0
fi

# Check first 3 lines for 'use server'
FIRST_LINES=$(head -3 "$FILE_PATH" 2>/dev/null || true)

if ! echo "$FIRST_LINES" | grep -q "'use server'"; then
  echo "WARNING: $FILE_PATH is a Server Action file but is missing 'use server' in the first 3 lines."
  echo "Add  'use server';  as the very first line of this file."
fi

exit 0
