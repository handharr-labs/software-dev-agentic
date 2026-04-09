# CLAUDE.md

**[AppName]** — [One-line description of what the app does].
Stack: Next.js 15 App Router + React 19 · [Database, e.g. PostgreSQL · Supabase] · [ORM, e.g. Drizzle · Prisma] · [Auth, e.g. Supabase Auth · NextAuth · Clerk] · [UI, e.g. Tailwind + shadcn/ui] · [Tests, e.g. Vitest]

## Dev Commands
```bash
npm run dev | build | lint | test
[ORM push command, e.g. npx drizzle-kit push OR npx prisma db push]
[ORM studio command if available, e.g. npx drizzle-kit studio]  # DB browser (optional)
```

## Structure
Feature slices: `src/features/{auth,[feature-a],[feature-b],...}` · `src/shared/{domain,presentation,core,di}` · `src/lib/` · `src/app/`
Arch docs: `.claude/reference/` · DI/arch rules: `.claude/docs/`

## Workflow
Before any work: `/create-issue [title]` → wait for instruction → invoke agent

Agents: `feature-scaffolder` · `backend-scaffolder` · `debug-agent` · `test-writer` · `arch-reviewer` · `/simplify` · `.claude/skills/`

Issue rule: On `fix/`|`feature/` branch → add feedback to current issue. On `main` → create new issue.

## Code Principles
CLEAN · DRY · SOLID (SRP, OCP, LSP, ISP, DIP). Wire deps via `src/shared/di/`.
