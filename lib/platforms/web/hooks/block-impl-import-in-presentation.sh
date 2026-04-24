#!/usr/bin/env bash
# Hook: Block *RepositoryImpl / *DataSourceImpl imports in presentation layer
# Event: PreToolUse on Write|Edit
# Input: JSON on stdin with keys: tool_name, tool_input

set -euo pipefail

INPUT=$(cat)

TOOL=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null || true)

if [[ "$TOOL" != "Write" && "$TOOL" != "Edit" ]]; then
  exit 0
fi

FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); ti=d.get('tool_input',{}); print(ti.get('file_path', ti.get('path','')))" 2>/dev/null || true)

# Only check files in presentation or app directories
if ! echo "$FILE_PATH" | grep -qE '(src/features/[^/]+/presentation/|src/app/)'; then
  exit 0
fi

CONTENT=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); ti=d.get('tool_input',{}); print(ti.get('content', ti.get('new_string','')))" 2>/dev/null || true)

if echo "$CONTENT" | grep -qE "import.*\b(RepositoryImpl|DataSourceImpl)\b"; then
  echo "BLOCKED: Presentation layer must not import *RepositoryImpl or *DataSourceImpl directly."
  echo "Use the DI container (useDI() / container.server.ts) to access implementations via their interfaces."
  echo "File: $FILE_PATH"
  exit 2
fi

exit 0
