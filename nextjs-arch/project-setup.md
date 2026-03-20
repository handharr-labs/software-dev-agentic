## Project Setup Checklist

Things that are **intentionally left open** in this starter kit because they are project-specific decisions. Go through this list at the start of every new project. Each item affects generated code, DI wiring, or agent behavior.

> Items marked **REQUIRED** must be decided before writing any feature code.
> Items marked **OPTIONAL** can be deferred but should be revisited before the first production deploy.

---

### 1. Styling / UI Library — REQUIRED

The starter kit has no opinion on styling. Pick one and stick to it.

| Option | When to choose |
|--------|---------------|
| **Tailwind CSS** | Utility-first, zero runtime, best for custom designs |
| **shadcn/ui** | Tailwind + Radix UI — copy-paste component library, highly recommended |
| **Chakra UI** | Component library with a theme system, good for fast prototyping |
| **MUI (Material UI)** | Enterprise-grade, lots of components, heavier bundle |
| **CSS Modules** | Zero dependency, scoped styles, no utility classes |

**What to do after choosing:**
- Install the library and configure it in `app/layout.tsx`
- Update `feature-scaffolder` agent's View component template to match the library's component names (e.g., `<Button>` vs `<button className="btn">`)
- Create a `src/presentation/common/` folder for shared UI primitives (Button, Input, Modal, etc.)

**Decision log:** <!-- Record your choice here -->

---

### 2. Database / ORM — REQUIRED for full-stack, skip for frontend-only

The DB data source layer is generated as ORM-agnostic stubs. Fill in the impl when the ORM is chosen.

| Option | When to choose |
|--------|---------------|
| **Prisma** | Schema-first, strong TypeScript types, great DX, most popular |
| **Drizzle ORM** | SQL-like syntax, lightweight, type-safe without code generation |
| **Kysely** | Query builder (not ORM), gives full SQL control with types |
| **pg / mysql2 (raw)** | Full control, no abstraction, more boilerplate |

**What to do after choosing:**
1. Install the ORM and create `src/lib/db.ts` — see `database.md` Section 17.7 for the singleton pattern
2. Replace `type DbClient = unknown` in all `*DbDataSourceImpl.ts` files with the actual ORM client type
3. Implement all `throw new Error('Not implemented')` stubs in `*DbDataSourceImpl.ts`
4. Fill in ORM-specific error codes in `DbErrorMapperImpl` (e.g., Prisma `P2025` → `DomainError.notFound`)
5. Set `DATABASE_URL` in `.env.local`

**Decision log:** <!-- Record your choice here -->

---

### 3. Authentication — REQUIRED if the app has any protected routes

| Option | When to choose |
|--------|---------------|
| **NextAuth.js (Auth.js v5)** | Built for Next.js, supports OAuth + credentials + email magic link |
| **Clerk** | Hosted auth, zero backend config, drop-in UI components, paid above free tier |
| **Lucia** | Lightweight, bring-your-own database, full control over sessions |
| **Better Auth** | Modern alternative to NextAuth, more flexible session handling |
| **Custom JWT** | Full control, more work, only if none of the above fit |

**What to do after choosing:**
1. Create `src/lib/auth.ts` — auth config (providers, callbacks, session strategy)
2. Update `src/lib/safe-action.ts` — replace `getServerSession(authOptions)` with your auth provider's session getter
3. Create auth middleware in `middleware.ts` — protect routes at the edge
4. Add `(auth)/login/page.tsx` — login page (already in project structure)
5. Decide: JWT vs database sessions (database sessions require a `sessions` table)

**Decision log:** <!-- Record your choice here -->

---

### 4. Environment Variables

Set up `.env.local` before running the project. Never commit this file.

```bash
# .env.local — copy this block and fill in values

# --- Frontend-only mode ---
API_BASE_URL=https://api.yourbackend.com          # server-side (not exposed to browser)
NEXT_PUBLIC_API_BASE_URL=https://api.yourbackend.com  # client-side (exposed to browser)

# --- Full-stack mode ---
DATABASE_URL=                                     # connection string for your ORM

# --- Auth ---
NEXTAUTH_SECRET=                                  # generate: openssl rand -base64 32
NEXTAUTH_URL=http://localhost:3000                # your app's base URL

# --- Optional: third-party services ---
# STRIPE_SECRET_KEY=
# STRIPE_WEBHOOK_SECRET=
# RESEND_API_KEY=
```

**Rules:**
- Variables without `NEXT_PUBLIC_` prefix are server-only — safe for secrets
- Variables with `NEXT_PUBLIC_` are bundled into the client — never put secrets here
- `container.server.ts` uses `process.env.API_BASE_URL` (no prefix)
- `container.client.ts` uses `process.env.NEXT_PUBLIC_API_BASE_URL`

---

### 5. Error Monitoring — OPTIONAL

Unhandled errors in production need somewhere to go.

| Option | Notes |
|--------|-------|
| **Sentry** | Most popular, Next.js SDK available, free tier generous |
| **Highlight.io** | Session replay + errors, good free tier |
| **Axiom** | Log-based, works well with Vercel |

**What to do after choosing:**
- Wrap `app/layout.tsx` with the provider (if needed)
- Add the SDK to `src/core/Logger` so all caught errors flow through one place
- Set `SENTRY_DSN` (or equivalent) in environment variables

---

### 6. Feature Flags — OPTIONAL

If the project needs gradual rollout or A/B testing.

| Option | Notes |
|--------|-------|
| **Vercel Feature Flags** | Zero-config on Vercel, edge-evaluated |
| **Unleash** | Self-hosted, open source |
| **LaunchDarkly** | Enterprise, more complex |
| **Plain env vars** | Simplest — `NEXT_PUBLIC_FEATURE_NEW_DASHBOARD=true` |

---

### 7. Deployment Target — OPTIONAL (affects config)

| Target | Notes |
|--------|-------|
| **Vercel** | Zero-config for Next.js, recommended default |
| **Docker / self-hosted** | Set `output: 'standalone'` in `next.config.ts` |
| **AWS (Amplify / ECS)** | Requires custom build config |

**What to do:**
- Vercel: connect repo, set environment variables in dashboard, done
- Docker: add `Dockerfile` and set `output: 'standalone'` in `next.config.ts`

---

### 8. Testing Framework — REQUIRED before writing tests

The architecture docs reference both Vitest and Jest. Pick one.

| Option | When to choose |
|--------|---------------|
| **Vitest** | Recommended — faster, native ESM, compatible with Vite toolchain |
| **Jest** | Battle-tested, wider ecosystem, required if using Create React App or older setups |

**What to do after choosing:**
- Install and configure (`vitest.config.ts` or `jest.config.ts`)
- Add a `__tests__/utils/queryClientWrapper.tsx` — required for all ViewModel hook tests
- The `create-mock` skill generates `vi.fn()` by default — update to `jest.fn()` if using Jest

---

### 9. Linting & Formatting — OPTIONAL but strongly recommended

| Tool | Config file |
|------|------------|
| **ESLint** | `.eslintrc.json` — Next.js ships with `eslint-config-next` |
| **Prettier** | `.prettierrc` — add `prettier-plugin-tailwindcss` if using Tailwind |
| **TypeScript strict mode** | `tsconfig.json` — set `"strict": true` (should already be on) |

**Recommended ESLint additions:**
```json
{
  "rules": {
    "no-restricted-imports": ["error", {
      "patterns": [
        { "group": ["*/data/*"], "message": "Presentation must not import from data layer directly." }
      ]
    }]
  }
}
```

This enforces the dependency rule at the linter level — presentation cannot import data implementations.

---

### Summary Table

| Decision | Status | Blocking |
|----------|--------|---------|
| Styling / UI library | ☐ Not decided | Feature UI code |
| Database / ORM | ☐ Not decided | Full-stack features |
| Authentication | ☐ Not decided | Protected routes |
| Environment variables | ☐ Not set | Running locally |
| Testing framework | ☐ Not decided | Writing any tests |
| Error monitoring | ☐ Not decided | Production deploy |
| Feature flags | ☐ Not decided | Gradual rollout |
| Deployment target | ☐ Not decided | First deploy |
| Linting & formatting | ☐ Not configured | Code consistency |

Copy this table into your project's `CLAUDE.md` or `README.md` and check off items as you go.
