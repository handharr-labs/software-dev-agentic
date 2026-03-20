# PM–Engineer Collaboration Guide

How the PM and engineer collaborate using GitHub Issues + Claude Code locally.

---

## Section A — Semi-Automated (Current Setup)

### How It Works

```
PM creates GitHub Issue on github.com
  → Engineer gets notified (email / GitHub notification)
  → Engineer runs /pickup-issue NNN in Claude Code
      → fetches title + body from GitHub
      → creates issues/NNN-slug.md locally
      → checks out feat/issue-NNN-slug branch
      → updates issues/000-backlog.md
  → Engineer implements locally with Claude Code
  → Engineer pushes PR linked to GitHub Issue #NNN
```

For engineer-initiated work the flow is:

```
Engineer runs /create-issue "add dark mode"
  → gh issue create on GitHub  (gets #34)
  → creates issues/034-add-dark-mode.md
  → checks out feat/issue-034-add-dark-mode
  → updates issues/000-backlog.md
```

---

### PM Workflow: Creating Good GitHub Issues

1. Go to the repo on github.com → **Issues** → **New issue**
2. Write a clear **title** (e.g. `Add export to CSV button on transaction list`)
3. In the **body**, include:
   - **Goal** — what the user should be able to do
   - **Acceptance Criteria** — bullet list of conditions that must be true
   - **Notes** — any edge cases, design links, or constraints
4. Add a label if relevant (`bug`, `enhancement`, `chore`)
5. Submit — the engineer will be notified and pick it up

**Good issue body template for PM:**

```markdown
## Goal
[What this accomplishes for the user]

## Acceptance Criteria
- [ ] ...
- [ ] ...

## Notes
[Edge cases, Figma link, constraints — optional]
```

---

### Engineer Workflow

1. **Get notified** — GitHub sends an email when a new issue is opened (check Settings → Notifications on github.com)
2. **Pick it up** — in Claude Code:
   ```
   /pickup-issue 35
   ```
   Claude Code fetches the issue, creates the local file and branch automatically.
3. **Implement** — invoke the right agent:
   - New feature/screen → `feature-scaffolder`
   - Backend + DB → `backend-scaffolder`
   - Bug fix → `debug-agent`
4. **Push PR** — always put `Closes #NNN` as the **first line** of the PR body so GitHub auto-closes the issue on merge:
   ```
   Closes #35

   ## Summary
   ...
   ```
   > Without `Closes #NNN`, the GitHub Issue stays open after merge and must be closed manually.

---

### One-Time Setup (engineer)

```bash
gh auth login   # authenticate GitHub CLI (only needed once)
```

Verify with: `gh auth status`

---

## Section B — Fully-Automated (Future)

> Enable this when an Anthropic API key is available. Cost estimate: ~$0.01–0.05 per task with Claude Sonnet, likely < $5/month.

### What's Needed

| Item | Where |
|------|-------|
| Anthropic API key | [console.anthropic.com](https://console.anthropic.com) → API Keys |
| GitHub Actions secret | Repo → Settings → Secrets → `ANTHROPIC_API_KEY` |
| Workflow file | `.github/workflows/claude.yml` (see below) |

### How to Enable

1. Get an API key from `console.anthropic.com`
2. Add it as a GitHub Actions secret named `ANTHROPIC_API_KEY`
3. Create `.github/workflows/claude.yml` with the config below
4. From that point, Claude will automatically respond to new issues and `@claude` mentions in PRs

### `.github/workflows/claude.yml` (ready to copy-paste)

```yaml
name: Claude Code

on:
  issue_comment:
    types: [created]
  issues:
    types: [opened, assigned]
  pull_request_review_comment:
    types: [created]

permissions:
  contents: write
  issues: write
  pull-requests: write

jobs:
  claude:
    if: |
      (github.event_name == 'issue_comment' && contains(github.event.comment.body, '@claude')) ||
      (github.event_name == 'pull_request_review_comment' && contains(github.event.comment.body, '@claude')) ||
      (github.event_name == 'issues' && github.event.action == 'assigned' &&
       github.event.assignee.login == 'claude')
    runs-on: ubuntu-latest
    steps:
      - uses: anthropics/claude-code-action@beta
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

### PM Workflow (Fully Automated)

Once enabled, the PM can:
- Open a GitHub Issue and assign it to `claude` → Claude implements it automatically and opens a PR
- Comment `@claude fix the typo in line 42` on a PR → Claude applies the fix
- Comment `@claude add error handling here` on an issue → Claude responds with analysis or a PR

### Cost Estimate

| Usage | Estimate |
|-------|----------|
| Simple bug fix | ~$0.01–0.02 |
| New feature scaffold | ~$0.05–0.15 |
| 20 tasks/month | ~$1–3/month |
| 100 tasks/month | ~$5–15/month |

Actual cost depends on context size. Monitor via `console.anthropic.com` → Usage.
