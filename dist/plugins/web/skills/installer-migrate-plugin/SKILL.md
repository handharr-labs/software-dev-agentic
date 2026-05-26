---
name: installer-migrate-plugin
description: Migrate a downstream project from the submodule path to the plugin path — removes the submodule and symlinks, installs the platform plugin, and verifies the result.
user-invocable: true
allowed-tools: Bash, Read
---

## Arguments

`$ARGUMENTS` — optional platform name (e.g. `flutter-mobile-talenta`). If omitted, detect from the existing submodule setup or ask.

## Step 1 — Detect platform

If `$ARGUMENTS` is provided, use it as `PLATFORM`.

Otherwise, detect from the existing submodule:

```bash
ls software-dev-agentic/lib/platforms/ 2>/dev/null
```

If the submodule is present, list available platforms and ask which one matches this project.

If the submodule is already removed, ask the user directly.

## Step 2 — Confirm

Show the user what will happen:

```
Migration plan for <PLATFORM>:
  1. Remove software-dev-agentic submodule
  2. Delete symlinks in .claude/agents/ and .claude/skills/
  3. Install sda-<PLATFORM> plugin (project scope)
  4. Patch .gitignore and CLAUDE.md
  5. Verify result
```

Ask for confirmation before proceeding.

## Step 3 — Remove submodule

```bash
git submodule deinit -f software-dev-agentic 2>/dev/null || true
git rm -f software-dev-agentic 2>/dev/null || true
```

Then remove the `.git/modules/software-dev-agentic` cache if it exists:

```bash
rm -rf .git/modules/software-dev-agentic
```

## Step 4 — Remove symlinks

```bash
find .claude/agents .claude/skills .claude/reference -type l -delete 2>/dev/null || true
```

Report how many symlinks were removed. Do not touch `agents.local/`, `skills.local/`, or `reference.local/` — those are project-specific overrides.

## Step 5 — Install plugin

```bash
curl -fsSL https://raw.githubusercontent.com/hndhr/software-dev-agentic/main/scripts/install-plugin.sh | bash -s -- --platform=<PLATFORM>
```

## Step 6 — Verify

Run these checks and report results:

```bash
# Plugin installed at project scope
grep -l "sda-<PLATFORM>" .claude/settings.json 2>/dev/null

# agentic-state in .gitignore
grep -q "agentic-state" .gitignore && echo "present" || echo "missing"

# CLAUDE.md has managed marker
grep -q "BEGIN software-dev-agentic" CLAUDE.md && echo "present" || echo "missing"

# No broken symlinks remain
find .claude/agents .claude/skills -type l 2>/dev/null | wc -l
```

Print a summary report:

```
installer-migrate-plugin
──────────────────────────────────────────
✓  submodule     removed
✓  symlinks      42 removed
✓  plugin        sda-<PLATFORM>@sda installed (project scope)
✓  .gitignore    agentic-state/ present
✓  CLAUDE.md     managed marker present
──────────────────────────────────────────
Migration complete. Run /reload-plugins in Claude Code to activate.
```

If any check fails, show `✗` with the suggested fix.
