---
name: setup-nextjs-project
description: Configure a Next.js project that has already wired the software-dev-agentic submodule. Copies the web CLAUDE-template.md, prompts for placeholder values, and creates an agents.local stub.
user-invocable: false
tools: Read, Bash
---

Configure a freshly wired Next.js project for software-dev-agentic. Called by `setup-worker`.

## Steps

### 1 — Confirm the repo URL

Ask the user:
> "Which software-dev-agentic repo should I use? Default: `https://github.com/handharr-labs/software-dev-agentic`"

If the user says "default" or provides no URL, use `https://github.com/handharr-labs/software-dev-agentic`.

### 2 — Add submodule

```bash
git submodule add <STARTER_KIT_URL> .claude/software-dev-agentic
```

### 3 — Run the setup script

```bash
.claude/software-dev-agentic/scripts/setup-symlinks.sh --platform=web
```

This symlinks all agents, skills, hooks, and reference for the web platform into `.claude/`, copies `CLAUDE.md` from the template, and creates `settings.local.json`. Re-running is safe.

### 4 — Copy CLAUDE-template.md

```bash
cp .claude/software-dev-agentic/lib/platforms/web/CLAUDE-template.md CLAUDE.md
```

### 5 — Prompt for placeholder values

Tell the user:
> "I've created `CLAUDE.md` from the web template. Fill in the `## Stack` section with your project's decisions — agents read this every session so they pick up your choices automatically:
>
> | Concern | Decision |
> |---|---|
> | Backend type | local-db (Next.js owns the DB) or remote-api (external API) |
> | ORM | Prisma / Drizzle / Kysely / none |
> | Auth | NextAuth / Clerk / Lucia / Better Auth / none |
> | Styling | Tailwind+shadcn / Tailwind / Chakra / MUI / CSS Modules |
> | Testing | Vitest / Jest |
> | Deployment | Vercel / Docker / AWS |
>
> Also fill in `[AppName]` and `[One-line description...]` at the top of the file."

### 6 — Create agents.local stub

Create `.claude/agents.local/extensions/arch-review-worker.md`:

```markdown
# arch-review-worker — project-specific rules

> Additive rules for this project. Baseline: `.claude/software-dev-agentic/lib/core/agents/auditor/arch-review-worker.md`.

<!-- Add project-specific audit rules below -->
```

### 7 — Stage and summarize

```bash
git add .gitmodules .claude/ CLAUDE.md
```

Tell the user what was done:
- `.claude/software-dev-agentic/` — submodule pointing to the starter kit repo
- `.claude/{agents,skills,hooks}` — symlinks into the submodule
- `CLAUDE.md` — copied from template (fill in all `[placeholder]` values before starting work)
- `.claude/agents.local/extensions/arch-review-worker.md` — stub for project-specific arch rules
