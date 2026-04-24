---
name: doctor
description: Audit the software-dev-agentic setup in a downstream project — checks submodule, symlinks, CLAUDE.md markers, settings, and GitHub CLI auth.
user-invocable: true
tools: Bash, Read, Glob
---

You are a setup auditor. Run each check below in order, collect results, then print a single formatted report. Do not auto-fix anything — only diagnose and suggest.

## Checks

### 1. Submodule present

```bash
git submodule status .claude/software-dev-agentic
```

- Pass: submodule is present and initialized (line starts with a commit hash)
- Fail: missing or not initialized

If present, capture the current local commit hash. Then check if it's behind remote:

```bash
git -C .claude/software-dev-agentic fetch --quiet origin main 2>/dev/null
git -C .claude/software-dev-agentic rev-list --count HEAD..origin/main
```

- Pass: count is 0 (up to date)
- Warn: count > 0 → "N commits behind origin/main"

### 2. Agents symlinks

```bash
ls .claude/agents/
```

Count `.md` files. Then check for broken symlinks:

```bash
find .claude/agents -maxdepth 1 -name "*.md" -type l | while read f; do
  [ -e "$f" ] || echo "broken: $f"
done
```

- Pass: at least 1 agent linked, no broken symlinks
- Warn: broken symlinks found
- Fail: `.claude/agents/` missing or empty

### 3. Skills symlinks

Same as agents but for `.claude/skills/`:

```bash
ls .claude/skills/
find .claude/skills -maxdepth 1 -mindepth 1 -type l | while read f; do
  [ -e "$f" ] || echo "broken: $f"
done
```

- Pass: at least 1 skill linked, no broken symlinks
- Warn: broken symlinks found
- Fail: `.claude/skills/` missing or empty

### 4. CLAUDE.md managed markers

Read `CLAUDE.md` from the project root. Check for both:
- `<!-- BEGIN software-dev-agentic -->`
- `<!-- END software-dev-agentic -->`

- Pass: both markers present
- Warn: one marker present but not the other
- Fail: no markers found (sync.sh won't be able to update the shared section)

### 5. settings.local.json

Check `.claude/settings.local.json` exists:

```bash
[ -f .claude/settings.local.json ] && echo "exists" || echo "missing"
```

If it exists, check for the placeholder value:

```bash
grep -c "PROJECT_ROOT" .claude/settings.local.json || true
```

- Pass: file exists, no `PROJECT_ROOT` placeholder
- Warn: file exists but still contains `PROJECT_ROOT` placeholder
- Fail: file missing

### 6. GitHub CLI auth

```bash
gh auth status 2>&1
```

- Pass: output contains "Logged in"
- Fail: not logged in or `gh` not installed

---

## Report format

Print a report using this format:

```
software-dev-agentic doctor
──────────────────────────────────────────
✓  submodule    present (abc1234) · up to date
⚠  submodule    3 commits behind origin/main — run: .claude/software-dev-agentic/scripts/sync.sh
✓  agents       9 linked
✗  skills       .claude/skills/ missing — run: .claude/software-dev-agentic/scripts/setup-symlinks.sh
✓  CLAUDE.md    managed markers found
⚠  settings     PROJECT_ROOT placeholder not replaced — edit .claude/settings.local.json
✓  gh auth      logged in
──────────────────────────────────────────
1 error · 1 warning
```

Rules:
- `✓` green check for pass
- `⚠` warning for non-blocking issues
- `✗` error for failures that will break functionality
- Each line: symbol · category (padded to 12 chars) · message · suggested fix command if applicable
- Summary line at the bottom: count of errors and warnings (omit if all pass)
- If all checks pass: print `All checks passed.` instead of the summary line
