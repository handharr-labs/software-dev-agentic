---
name: installer-setup-project
description: Configure an iOS project that has already wired the software-dev-agentic submodule. Copies the iOS CLAUDE-template.md, prompts for placeholder values, and creates an agents.local stub.
user-invocable: false
tools: Read, Bash
---

Configure a freshly wired iOS project for software-dev-agentic. Called by `installer-setup`.

## Steps

### 1 — Copy CLAUDE-template.md

```bash
cp software-dev-agentic/lib/platforms/ios-talenta/CLAUDE-template.md CLAUDE.md
```

### 2 — Prompt for placeholder values

Tell the user:
> "I've created `CLAUDE.md` from the iOS template. Please fill in:
> - `[AppName]` — your Xcode project/target name (e.g. `Talenta`)
> - `[One-line description]` — what the app does
> - `[version]` — minimum iOS deployment target (e.g. `14.0`)
> - `[App]` — used in path references (e.g. `Talenta/Shared/`, `TalentaTests/`)
> - `[Device]` — simulator name for the build command (e.g. `iPhone 16`)"

### 3 — Create agents.local stub

Create `.claude/agents.local/extensions/auditor-arch-review-worker.md`:

```markdown
# auditor-arch-review-worker — project-specific rules

> Additive rules for this project. Baseline: `software-dev-agentic/lib/core/agents/auditor/auditor-arch-review-worker.md`.

<!-- Add project-specific audit rules below -->
```

### 4 — Stage and summarize

```bash
git add .claude/ CLAUDE.md
```

Tell the user what was done:
- `CLAUDE.md` — copied from iOS template (fill in all `[placeholder]` values before starting work)
- `.claude/agents.local/extensions/auditor-arch-review-worker.md` — stub for project-specific arch rules
