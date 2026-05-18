---
name: installer-update
description: Sync software-dev-agentic to the latest version and verify the full installation — runs sync.sh then checks submodule, symlinks, CLAUDE.md markers, settings, and GitHub CLI auth.
user-invocable: true
tools: Bash, Read, Glob
---

You are a self-contained update runner. Execute every step below in order without stopping. Collect all results, then print a single combined report at the end.

## Step 1 — Detect platform

```bash
readlink .claude/skills/domain-create-entity 2>/dev/null
```

Classify the output:
- Contains `platforms/ios-talenta` → `ios`
- Contains `platforms/web` → `web`
- Contains `platforms/flutter-mobile-talenta` → `flutter`
- No output or unknown → ask the user: "Which platform is this project? web / ios / flutter"

## Step 2 — Run sync

```bash
software-dev-agentic/scripts/sync.sh --platform=<platform>
```

Capture exit code. If non-zero, record as sync failure and skip to Step 3 without stopping.

After sync succeeds, read the new version:

```bash
cat software-dev-agentic/VERSION
```

## Step 3 — Verify submodule

```bash
git submodule status software-dev-agentic
git -C software-dev-agentic rev-list --count HEAD..origin/main
```

- Pass: submodule present and count is 0
- Warn: count > 0 → "N commits behind origin/main"
- Fail: submodule missing or not initialized

## Step 4 — Verify agents symlinks

```bash
find .claude/agents -maxdepth 1 -name "*.md" -type l | while read f; do
  [ -e "$f" ] || echo "broken: $f"
done
```

- Pass: at least 1 agent linked, no broken symlinks
- Warn: broken symlinks found
- Fail: `.claude/agents/` missing or empty

## Step 5 — Verify skills symlinks

```bash
find .claude/skills -maxdepth 1 -mindepth 1 -type l | while read f; do
  [ -e "$f" ] || echo "broken: $f"
done
```

- Pass: at least 1 skill linked, no broken symlinks
- Warn: broken symlinks found
- Fail: `.claude/skills/` missing or empty

## Step 6 — Verify CLAUDE.md managed markers

Read `CLAUDE.md` from the project root. Check for both:
- `<!-- BEGIN software-dev-agentic -->`
- `<!-- END software-dev-agentic -->`

- Pass: both markers present
- Warn: one marker present but not the other
- Fail: no markers found

## Step 7 — Verify settings.local.json

```bash
[ -f .claude/settings.local.json ] && echo "exists" || echo "missing"
grep -c "PROJECT_ROOT" .claude/settings.local.json || true
```

- Pass: file exists, no `PROJECT_ROOT` placeholder
- Warn: file exists but still contains `PROJECT_ROOT` placeholder
- Fail: file missing

## Step 8 — Verify GitHub CLI auth

```bash
gh auth status 2>&1
```

- Pass: output contains "Logged in"
- Fail: not logged in or `gh` not installed

## Report

Print a single combined report:

```
software-dev-agentic update
──────────────────────────────────────────
✓  sync         v4.0.0 installed · platform: ios
✗  sync         failed — check sync.sh output above
✓  submodule    present (abc1234) · up to date
⚠  submodule    3 commits behind origin/main
✓  agents       18 linked
⚠  skills       2 broken symlinks — run: software-dev-agentic/scripts/setup-symlinks.sh
✓  CLAUDE.md    managed markers found
⚠  settings     PROJECT_ROOT placeholder not replaced — edit .claude/settings.local.json
✓  gh auth      logged in
──────────────────────────────────────────
1 error · 2 warnings
```

Rules:
- `✓` pass · `⚠` non-blocking warning · `✗` blocking error
- Each line: symbol · category (padded to 12 chars) · message · fix command if applicable
- Summary line at bottom: count of errors and warnings (omit if all pass)
- If all checks pass: print `All checks passed.` instead of the summary line
