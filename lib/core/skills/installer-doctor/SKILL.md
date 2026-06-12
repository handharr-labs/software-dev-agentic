---
name: installer-doctor
description: Audit the CipherPol plugin setup in a downstream project — checks plugin installation, marketplace config, settings, CLAUDE.md markers, and GitHub CLI auth.
user-invocable: true
allowed-tools: Bash, Read, Glob
---

Audit the plugin setup. Collect all results, then print a single formatted report. Do not auto-fix — only diagnose and suggest.

## Checks

### 1. Plugin installed

```bash
cat .claude/settings.json 2>/dev/null
```

Check both `cipherpol-aegis` and `cipherpol-8` are in `enabledPlugins` and installed.

```bash
claude plugin list 2>/dev/null | grep cipherpol || true
```

- Pass: both `cipherpol-aegis` and `cipherpol-8` present in `settings.json` and installed
- Warn: present in `settings.json` but not yet installed — run the install command
- Fail: either plugin missing from `settings.json`

### 2. Marketplace configured

Check `~/.claude/settings.json` (global) for `extraKnownMarketplaces`:

- Pass: `hndhr/software-dev-agentic` present
- Fail: missing — run: `claude plugin marketplace add hndhr/software-dev-agentic`

### 3. skillListingBudgetFraction set

```bash
grep "skillListingBudgetFraction" .claude/settings.json 2>/dev/null || true
```

- Pass: present (recommended: 0.03)
- Warn: missing — skill descriptions will be truncated; add `"skillListingBudgetFraction": 0.03` to `.claude/settings.json`

### 4. CLAUDE.md managed markers

Check `CLAUDE.md` for `<!-- BEGIN software-dev-agentic -->` and `<!-- END software-dev-agentic -->`.

- Pass: both present
- Warn: one present but not the other
- Fail: neither present

### 5. .gitignore — agentic-state

```bash
grep -q "agentic-state" .gitignore && echo "present" || echo "missing"
```

- Pass: `.claude/agentic-state/` in `.gitignore`
- Warn: missing — add `.claude/agentic-state/` to `.gitignore`

### 6. GitHub CLI auth

```bash
gh auth status 2>&1
```

- Pass: contains "Logged in"
- Fail: not logged in or `gh` not installed

## Report format

```
CipherPol doctor
──────────────────────────────────────────
✓  plugin        cipherpol-aegis@10.12.0 + cipherpol-8@10.12.0 installed
✓  marketplace   hndhr/software-dev-agentic configured
⚠  budget        skillListingBudgetFraction missing — add 0.03 to .claude/settings.json
✓  CLAUDE.md     managed markers found
✓  .gitignore    agentic-state/ present
✓  gh auth       logged in
──────────────────────────────────────────
1 warning
```

Rules:
- `✓` pass · `⚠` warning (non-blocking) · `✗` error (breaks functionality)
- Each line: symbol · category (padded to 14 chars) · message · fix command if applicable
- Summary: error + warning counts. If all pass: `All checks passed.`
