# Next.js StarterKit

> **For AI agents**: If a user asks you to "set up a project using this starter kit" or similar, jump to the [AI Project Setup](#ai-project-setup) section at the bottom and follow it step by step before generating any code.

---

## What This Is

A Clean Architecture starter kit for Next.js 15 projects. It gives you a proven layer structure, a full set of patterns and conventions, and Claude agents + skills to scaffold any layer in seconds.

It supports two modes — both share the same domain layer:

| Mode | When to use |
|------|-------------|
| **Frontend-only** | Next.js calls an external backend API you don't own |
| **Full-stack** | Next.js owns the database and business logic end-to-end |

You can also mix both in the same project — one feature calls an external API, another reads from your own database.

---

## Architecture at a Glance

```
┌──────────────────────────────────────────────────────────┐
│  PRESENTATION LAYER                                       │
│  View Components · ViewModel Hooks · Server Actions      │
└────────────────────────┬─────────────────────────────────┘
                         │ depends on
┌────────────────────────▼─────────────────────────────────┐
│  DOMAIN LAYER  (pure TypeScript — zero external imports) │
│  Entities · Repository Interfaces · Use Cases · Services │
└────────────────────────┬─────────────────────────────────┘
                         │ implemented by
┌────────────────────────▼─────────────────────────────────┐
│  DATA LAYER                                               │
│  RemoteDataSource (Axios) · DbDataSource (ORM)           │
│  Repository Impls · DTOs / DB Records · Mappers          │
└──────────────────────────────────────────────────────────┘
```

**Frontend-only read**: Server Component → UseCase → RemoteDataSourceImpl → External API

**Full-stack mutation**: Client Component → `useAction(serverAction)` → Server Action → UseCase → DbDataSourceImpl → Database

---

## Tech Stack

| Concern | Library |
|---------|---------|
| Framework | Next.js 15 (App Router) + React 19 |
| Language | TypeScript 5.5+ (strict mode) |
| Server state | TanStack Query |
| Global state | Zustand |
| HTTP client | Axios + axios-retry |
| Server Actions | next-safe-action + Zod |
| Testing | Vitest (or Jest) + React Testing Library |
| Styling | **Project-specific** — see Heads Up below |
| Database / ORM | **Project-specific** — see Heads Up below |
| Authentication | **Project-specific** — see Heads Up below |

---

## Architecture Docs

| File | Contents |
|------|----------|
| `reference/overview.md` | Core principles, layer diagram, dependency rule |
| `reference/domain.md` | Entities, repository interfaces, use cases, services, domain errors |
| `reference/data.md` | DTOs, mappers, data sources, repository impl, Axios networking |
| `reference/presentation.md` | Component patterns, ViewModel hooks, state conventions |
| `reference/navigation.md` | App Router structure, route constants, middleware |
| `reference/di.md` | DI containers, server/client split, DIContext |
| `reference/error-handling.md` | Error flow, error types, error boundaries |
| `reference/utilities.md` | StorageService, DateService, Logger, Validator, etc. |
| `reference/testing.md` | Test pyramid, unit/integration/component test patterns |
| `reference/ssr.md` | Server vs client rendering decision table |
| `reference/modular.md` | Turborepo package structure for large-scale apps |
| `reference/project.md` | Project layout, naming conventions, design decisions |
| `reference/server-actions.md` | **Full-stack** — next-safe-action, auth guard, cache revalidation |
| `reference/database.md` | **Full-stack** — DB DataSource, ORM-agnostic repository, DB mappers |
| `reference/api-routes.md` | **Full-stack** — Route Handlers (webhooks, file upload, external API) |
| `reference/project-setup.md` | Detailed setup guide for each project-specific decision |

## Agents & Skills

| Agents (`.claude/agents/`) | When to invoke |
|---------------------------|---------------|
| `feature-scaffolder` | New feature end-to-end — all layers + DI |
| `arch-reviewer` | Audit a file or feature for Clean Architecture violations |
| `test-writer` | Generate tests for any layer |
| `debug-agent` | Trace a runtime error through the layers to its root cause |
| `backend-scaffolder` | **Full-stack** — Server Action + UseCase + DB DataSource + Repository |

| Skills (`.claude/skills/`) | Trigger |
|---------------------------|---------|
| `new-feature` | `/new-feature` |
| `new-entity` | `/new-entity` |
| `new-usecase` | `/new-usecase` |
| `new-viewmodel` | `/new-viewmodel` |
| `write-tests` | `/write-tests` |
| `ssr-check` | `/ssr-check` |
| `wire-di` | `/wire-di` |
| `create-mock` | `/create-mock` |
| `scaffold-service` | `/scaffold-service` |
| `scaffold-repository` | `/scaffold-repository` |
| `integration-test` | `/integration-test` |
| `create-issue` | `/create-issue` |
| `pickup-issue` | `/pickup-issue NNN` — pick up a PM-created GitHub Issue |
| `new-server-action` | `/new-server-action` — **Full-stack** |
| `new-db-repository` | `/new-db-repository` — **Full-stack** |
| `setup-nextjs-project` | `/setup-nextjs-project` — wire submodule + symlinks for a new project |

---

## Heads Up — Project-Specific Decisions

These are **intentionally left undefined** in this starter kit. They must be decided per project. None of them affect the architecture layers — only the implementation details at the edges.

| Decision | Why it's left open | What to decide |
|----------|--------------------|---------------|
| **Styling / UI library** | Every project has different design requirements | Tailwind + shadcn/ui (recommended), Chakra UI, MUI, or plain CSS Modules |
| **Database / ORM** | DB choice depends on scale, hosting, team familiarity | Prisma (recommended for DX), Drizzle, Kysely, or raw SQL |
| **Authentication** | Auth strategy depends on user type and provider | NextAuth.js/Auth.js v5, Clerk, Lucia, or Better Auth |
| **Testing framework** | Vitest vs Jest depends on existing toolchain | Vitest (recommended for new projects), Jest for legacy setups |
| **Error monitoring** | Depends on hosting and budget | Sentry, Highlight.io, or Axiom |
| **Deployment target** | Affects `next.config.ts` output and env var strategy | Vercel (zero-config), Docker (`output: standalone`), or cloud provider |
| **Environment variables** | Values differ per project | See `.env.local` template in `project-setup.md` |

> Full details, options, and setup steps for each decision: `reference/project-setup.md`

---

## AI Project Setup

> **Read this section when a user says something like:**
> - "Set up a project using this starter kit"
> - "Bootstrap a new project with this architecture"
> - "Help me start a new Next.js project with this"
> - "Initialize the starter kit for [project name]"

Follow these steps in order. Do not generate any feature code until all clarifications are collected.

---

### Step 1 — Understand the project

Ask the user:

1. **Project name** — what is this project called?
2. **Mode** — is this frontend-only (Next.js calls an external API), full-stack (Next.js owns the database), or both?
3. **First feature** — what is the first thing users will do in the app? (e.g., "log in and view a dashboard", "create an employee record")

---

### Step 2 — Resolve project-specific decisions

For each item below, ask the user or infer from context. Record the answers — they affect what you generate.

**Styling / UI library**
- Ask: "Which UI library do you want to use? Tailwind + shadcn/ui, Chakra UI, MUI, or something else?"
- Default recommendation: Tailwind CSS + shadcn/ui

**Database / ORM** (full-stack mode only)
- Ask: "Which ORM or database client? Prisma, Drizzle, Kysely, or raw SQL?"
- Default recommendation: Prisma

**Authentication** (if the app has protected routes)
- Ask: "Do you need authentication? If yes, which provider — NextAuth.js/Auth.js, Clerk, Lucia, or custom?"
- If unsure: "Do users need to log in?"

**Testing framework**
- Ask: "Vitest or Jest for tests?"
- Default recommendation: Vitest

If the user says "I don't know" or "you decide" for any item, use the default recommendation and note it.

---

### Step 3 — Read the relevant architecture docs

Before generating anything, read:

```
Read: reference/overview.md
Read: reference/di.md
Read: reference/project.md
```

If full-stack mode:
```
Read: reference/server-actions.md
Read: reference/database.md
```

---

### Step 4 — Set up the project scaffold

Generate or instruct the user to run the following in order:

1. **Create Next.js app** (if starting fresh):
   ```bash
   npx create-next-app@latest [project-name] --typescript --tailwind --eslint --app --src-dir --import-alias "@/*"
   ```

2. **Install core dependencies**:
   ```bash
   # Always:
   npm install axios axios-retry @tanstack/react-query zustand zod

   # Full-stack only:
   npm install next-safe-action

   # Chosen ORM (full-stack only — install the chosen one):
   npm install prisma @prisma/client        # Prisma
   # or: npm install drizzle-orm            # Drizzle

   # Chosen auth (install the chosen one):
   npm install next-auth@beta               # Auth.js v5
   # or: npm install @clerk/nextjs          # Clerk
   # or: npm install lucia                  # Lucia

   # Testing:
   npm install -D vitest @vitejs/plugin-react @testing-library/react @testing-library/jest-dom
   # or: npm install -D jest @types/jest ts-jest @testing-library/react @testing-library/jest-dom
   ```

3. **Create the folder structure** matching `reference/project.md` Section 12.1

4. **Create `.env.local`** with the template from `reference/project-setup.md` Section 4

5. **Add the starter kit as a git submodule and create symlinks:**
   ```bash
   git submodule add https://github.com/handharr-labs/web-agentic .claude/web-agentic
   cd .claude
   ln -s web-agentic/agents     agents
   ln -s web-agentic/docs       docs
   ln -s web-agentic/hooks      hooks
   ln -s web-agentic/reference reference
   ln -s web-agentic/skills     skills
   cd ..
   chmod +x .claude/web-agentic/hooks/*.sh
   cp .claude/web-agentic/settings-template.json .claude/settings.local.json
   # Edit .claude/settings.local.json — replace PROJECT_ROOT with $(pwd)/.claude
   ```

   > **Why submodule + symlinks instead of copying?**
   > Updates to agents, skills, and arch docs flow from a single place. Run `cd .claude/web-agentic && git pull` to get the latest — no manual re-copying across projects.

   > **Tip:** You can automate this entire step with the `/setup-nextjs-project` skill once the starter kit is wired.

   **What hooks do:**
   | Hook | Event | Effect |
   |------|-------|--------|
   | `block-impl-import-in-presentation.sh` | PreToolUse Write/Edit | Blocks `*RepositoryImpl`/`*DataSourceImpl` imports in presentation layer (exit 2) |
   | `lint-on-edit.sh` | PostToolUse Write/Edit | Runs `npm run lint --fix` on every `.ts`/`.tsx` file written |
   | `check-use-server.sh` | PostToolUse Write | Warns when `'use server'` is missing from action files |

5a. **Copy and customize `CLAUDE.md`** (or let `/setup-nextjs-project` do it):
   ```bash
   cp docs/web-agentic/nextjs/CLAUDE-template.md CLAUDE.md
   ```
   Then open `CLAUDE.md` and replace every `[placeholder]`:
   - `[AppName]` — your project name (e.g. `Talenta`, `Expenzo`)
   - `[One-line description...]` — what the app does in one sentence
   - `[Database]`, `[ORM]`, `[Auth]`, `[UI library]`, `[Test framework]` — your chosen stack (see Step 2)
   - `[ORM push/studio commands]` — replace or delete if not using a DB ORM
   - `src/features/{auth,[feature-a],[feature-b],...}` — list your actual feature names once known

6. **Generate the seed files** — see the full manifest below.

7. **Create `src/lib/safe-action.ts`** (full-stack only) — use template from `reference/server-actions.md` Section 16.2

---

### Seed Files Manifest

These are the files that must exist before any agent or skill can run correctly. They are the foundation everything else builds on. Generate each one from the template referenced — do not invent new patterns.

**Legend:** `[both]` = frontend-only and full-stack · `[fe]` = frontend-only only · `[fs]` = full-stack only

#### DI Layer — `src/di/`

| File | Mode | Template |
|------|------|----------|
| `container.server.ts` | `[both]` | `reference/di.md` Section 7.1 |
| `container.client.ts` | `[both]` | `reference/di.md` Section 7.2 |
| `DIContext.tsx` | `[both]` | `reference/di.md` Section 7.2 |

> Start with empty containers (no features wired yet). The pattern must be correct — `server-only` / `client-only` guards, factory vs singleton distinction. Every future `/wire-di` invocation adds to these files.

#### Domain Errors — `src/domain/errors/`

| File | Mode | Template |
|------|------|----------|
| `DomainError.ts` | `[both]` | `reference/domain.md` Section 3.5 |
| `errorMessages.ts` | `[both]` | `reference/error-handling.md` Section 8.3 |

> Every layer depends on `DomainError`. Generate this before anything else.

#### Networking — `src/data/networking/`

| File | Mode | Template |
|------|------|----------|
| `HTTPClient.ts` | `[fe]` `[both]` | `reference/data.md` Section 4.5 |
| `NetworkError.ts` | `[fe]` `[both]` | `reference/data.md` Section 4.5 |
| `AxiosHTTPClient.ts` | `[fe]` `[both]` | `reference/data.md` Section 4.5 |
| `TokenProvider.ts` | `[fe]` `[both]` | `reference/data.md` Section 4.5 |
| `TokenRefreshService.ts` | `[fe]` `[both]` | `reference/data.md` Section 4.5 |

> Skip this group if the project is full-stack only with no external API calls.

#### Error Mapper — `src/data/mappers/`

| File | Mode | Template |
|------|------|----------|
| `ErrorMapper.ts` | `[fe]` `[both]` | `reference/data.md` Section 4.2 |

> Required by every `RepositoryImpl`. Without it, `/scaffold-repository` will generate broken imports.

#### Shared DTOs — `src/data/dtos/`

| File | Mode | Template |
|------|------|----------|
| `APIResponse.ts` | `[fe]` `[both]` | `reference/data.md` Section 4.1 |
| `PaginatedDTO.ts` | `[fe]` `[both]` | `reference/data.md` Section 4.1 |

#### Shared Domain Entities — `src/domain/entities/`

| File | Mode | Template |
|------|------|----------|
| `PaginatedResult.ts` | `[both]` | `reference/domain.md` Section 3.1 |

#### Routing — `src/presentation/navigation/`

| File | Mode | Template |
|------|------|----------|
| `routes.ts` | `[both]` | `reference/navigation.md` Section 6.2 |

> Start with an empty `ROUTES` object. Features add to it as they are scaffolded.

#### App Entry — `src/app/`

| File | Mode | Template |
|------|------|----------|
| `layout.tsx` | `[both]` | `reference/di.md` Section 7.3 |
| `error.tsx` | `[both]` | `reference/error-handling.md` Section 8.2 |

#### Full-Stack Only — `src/lib/`

| File | Mode | Template |
|------|------|----------|
| `safe-action.ts` | `[fs]` | `reference/server-actions.md` Section 16.2 |
| `db.ts` | `[fs]` | `reference/database.md` Section 17.7 |
| `auth.ts` | `[fs]` | Depends on chosen auth provider — stub with `// TODO` if not yet decided |

#### Full-Stack Only — DB Error Mapper — `src/data/mappers/db/`

| File | Mode | Template |
|------|------|----------|
| `DbErrorMapper.ts` | `[fs]` | `reference/database.md` Section 17.6 |

#### Core Utilities (Seed) — `src/core/`

These two are needed from day one. Everything else in `utilities.md` is on-demand.

| File | Mode | Template |
|------|------|----------|
| `core/logger/Logger.ts` | `[both]` | `reference/utilities.md` Section 9.4 |
| `core/utils/nullSafety.ts` | `[both]` | `reference/utilities.md` Section 9.3 |

> `Logger` is already used by `AxiosHTTPClient` for dev-mode request/response logging — it must exist before the networking seed files are generated. `nullSafety` (`orZero`, `orEmpty`, `orEmptyArray`, etc.) is used in mappers and anywhere nullable values are handled.

#### Token Storage — `src/core/storage/`

Required by the DI containers. `container.server.ts` imports `ServerTokenStorage`; `container.client.ts` imports `LocalStorageTokenProvider`.

| File | Mode | Template |
|------|------|----------|
| `core/storage/ServerTokenStorage.ts` | `[both]` | `reference/di.md` Section 7.1 |
| `core/storage/LocalStorageTokenProvider.ts` | `[both]` | `reference/di.md` Section 7.2 |

> Without these, the DI containers will have broken imports on creation. Generate them alongside the networking seed files.

#### On-Demand Utilities — generate when first needed, not on setup

These live in `utilities.md` but are **not** seed files. Generate them the first time a feature needs them.

| File | Generate when... | Template |
|------|-----------------|----------|
| `core/storage/StorageService.ts` | First feature stores user preferences or app state | `reference/utilities.md` Section 9.1 |
| `core/date/DateService.ts` | First feature formats or compares dates | `reference/utilities.md` Section 9.2 |
| `core/network/NetworkMonitor.ts` | App needs to show offline/online state | `reference/utilities.md` Section 9.5 |
| `core/validation/Validator.ts` | Client-side form validation needed (frontend-only; full-stack uses Zod instead) | `reference/utilities.md` Section 9.6 |
| `core/image/ImageCache.ts` | Programmatic image prefetching needed | `reference/utilities.md` Section 9.7 |

> Do not generate these upfront. Generating unused infrastructure adds dead code and creates false `// TODO` stubs.

#### Testing Utilities — `__tests__/utils/`

| File | Mode | Template |
|------|------|----------|
| `queryClientWrapper.tsx` | `[both]` | `reference/testing.md` Section 10.3 |

> Required by every ViewModel hook test. Generate once, reuse everywhere.

---

**After generating all seed files, verify:**
- `container.server.ts` has `import 'server-only'` at the top
- `container.client.ts` has `import 'client-only'` at the top
- `DomainError.ts` exists and exports the `DomainError` class
- `DIContext.tsx` exports both `DIProvider` and `useDI`
- All `// TODO` stubs are noted for the user

---

### Step 5 — Confirm and hand off

After setup, tell the user:

- What was created and what still needs their input (e.g., `.env.local` values, ORM schema)
- Which project-specific decisions were deferred (with a link to `reference/project-setup.md`)
- The first command to scaffold a feature: `/new-feature` or `@backend-scaffolder`
- Any `// TODO` stubs that need to be filled in before the app can run (e.g., `DbDataSourceImpl`, `lib/db.ts`, auth config)

---

## Updating the Starter Kit

After the submodule is wired (Step 5 above), pull updates from the web-agentic repo at any time:

```bash
cd .claude/web-agentic && git pull && cd ../..
git add .claude/web-agentic
git commit -m "chore: bump reference starter kit"
```

This updates all 5 linked directories (agents, docs, hooks, reference, skills) in one operation across every project that uses the submodule.
