#!/usr/bin/env bash
# scripts/plugin-lib.sh
# Shared build helpers sourced by lib/plugins/*/build.sh.
# Expects $SUBMODULE, $VERSION, $PLUGIN_DIR, and $out to be set by the caller.

# ── Config helpers ────────────────────────────────────────────────────────────

# Read a top-level string field from build.config.json
config_field() {
  python3 -c "import json,sys; d=json.load(open('$PLUGIN_DIR/build.config.json')); print(d.get('$1',''))"
}

# Read an include array (list of glob patterns) for a given key
config_include() {
  python3 -c "
import json, sys
d = json.load(open('$PLUGIN_DIR/build.config.json'))
for p in d.get('include', {}).get('$1', []):
    print(p)
"
}

# ── Standard include processors ───────────────────────────────────────────────

# Copy all .md files matching include.agents patterns — flattened into out/agents/
# Patterns may contain shell globs (e.g. lib/core/*/agents) — unquoted expansion handles them.
copy_agents() {
  mkdir -p "$out/agents"
  while IFS= read -r pattern; do
    for dir in $SUBMODULE/$pattern; do
      [ -d "$dir" ] || continue
      find "$dir" -name "*.md" -type f 2>/dev/null | while read -r src; do
        cp "$src" "$out/agents/$(basename "$src")"
      done
    done
  done < <(config_include "agents")
  local count
  count=$(find "$out/agents" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  echo "  agents       $count files (flat)"
}

# Copy all skill dirs matching include.skills patterns into out/skills/
copy_skills() {
  mkdir -p "$out/skills"
  while IFS= read -r pattern; do
    for skill_dir in $SUBMODULE/$pattern; do
      [ -d "$skill_dir" ] || continue
      [ -f "$skill_dir/SKILL.md" ] || continue  # skip grouping dirs (orchestrators/, procedures/)
      local name
      name="$(basename "$skill_dir")"
      [ -d "$out/skills/$name" ] && continue  # first match wins
      cp -r "$skill_dir" "$out/skills/$name"
    done
  done < <(config_include "skills")
  local count
  count=$(ls "$out/skills" 2>/dev/null | wc -l | tr -d ' ')
  echo "  skills       $count dirs"
}

# Copy reference dirs matching include.reference patterns into out/reference/<persona>/
# e.g. lib/core/aegis/reference/** -> out/reference/shared/**
copy_reference() {
  mkdir -p "$out/reference"
  while IFS= read -r pattern; do
    for ref_dir in $SUBMODULE/$pattern; do
      [ -d "$ref_dir" ] || continue
      find "$ref_dir" -mindepth 1 -type f -name "*.md" -print -quit | grep -q . || continue  # skip empty
      local persona
      persona="$(basename "$(dirname "$ref_dir")")"
      mkdir -p "$out/reference/$persona"
      cp -r "$ref_dir"/. "$out/reference/$persona/"
    done
  done < <(config_include "reference")
  local count
  count=$(find "$out/reference" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  echo "  reference    $count files"
}

# ── Manifest ──────────────────────────────────────────────────────────────────

write_manifest() {
  local name="$1" description="$2"
  mkdir -p "$out/.claude-plugin"
  cat > "$out/.claude-plugin/plugin.json" <<MANIFEST
{
  "name": "${name}",
  "description": "${description}",
  "version": "${VERSION}",
  "author": {
    "name": "Jurnal Engineering"
  }
}
MANIFEST
  echo "  manifest     ${name}@${VERSION}"
}

# ── Marketplace ───────────────────────────────────────────────────────────────

update_marketplace() {
  local name="$1" source="$2" description="$3"
  python3 - "$SUBMODULE/.claude-plugin/marketplace.json" "$name" "$source" "$description" "$VERSION" <<'PYEOF'
import json, sys
marketplace_path, name, source, description, version = sys.argv[1:]
with open(marketplace_path) as f:
    m = json.load(f)
plugins = m.setdefault("plugins", [])
existing = next((p for p in plugins if p["name"] == name), None)
if existing:
    existing["source"] = source
    existing["version"] = version
else:
    plugins.append({
        "name": name,
        "source": source,
        "description": description,
        "category": "development-workflows",
        "version": version,
    })
with open(marketplace_path, "w") as f:
    json.dump(m, f, indent=2)
print(f"  marketplace   {'updated' if existing else 'added'} entry: {name}@{version}")
PYEOF
}
