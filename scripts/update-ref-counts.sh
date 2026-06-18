#!/usr/bin/env bash
# update-ref-counts.sh
# Rewrites ## section headings in reference docs with accurate <!-- N --> line counts.
#
# N = lines from the ## heading up to (but not including) the next ## heading, or EOF.
# Agents use this as: Read(file, offset=heading_line, limit=N)
#
# Usage:
#   scripts/update-ref-counts.sh              — all reference docs under cipherpol-aegis/
#   scripts/update-ref-counts.sh <file> ...   — specific files only
#
# Called automatically by scripts/hooks/pre-commit for staged reference files.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

update_file() {
  local file="$1"
  python3 - "$file" <<'PYEOF'
import re, sys

path = sys.argv[1]
with open(path) as f:
    lines = f.readlines()

out = []
i = 0
changed = False

while i < len(lines):
    line = lines[i]
    if re.match(r'^## ', line):
        # Count lines from this heading to the next ## heading (exclusive) or EOF
        j = i + 1
        while j < len(lines) and not re.match(r'^## ', lines[j]):
            j += 1
        count = j - i  # heading line + all content lines before the next ##

        # Strip any existing annotation, write updated one
        stripped = re.sub(r'\s*<!--\s*\d+\s*-->', '', line.rstrip())
        new_line = f"{stripped} <!-- {count} -->\n"
        if new_line != line:
            changed = True
        line = new_line

    out.append(line)
    i += 1

if changed:
    with open(path, 'w') as f:
        f.writelines(out)
    print(f"  updated  {path}")
else:
    print(f"  ok       {path}")
PYEOF
}

cd "$REPO_ROOT"

# ── Specific files passed as arguments ───────────────────────────────────────
if [ $# -gt 0 ]; then
  for file in "$@"; do
    [[ "$file" == *.md ]] || continue
    update_file "$file"
  done
  exit 0
fi

# ── All reference docs under cipherpol-aegis/ ────────────────────────────────
total=0
while IFS= read -r -d '' file; do
  update_file "$file"
  total=$((total + 1))
done < <(find cipherpol-aegis -path "*/reference/*.md" -print0 | sort -z)

echo ""
echo "$total reference file(s) processed."
