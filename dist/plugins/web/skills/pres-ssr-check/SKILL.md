---
name: pres-ssr-check
description: Determine whether a component should be a Server Component or Client Component, and verify the current file matches the correct pattern. Called by presentation-worker.
user-invocable: false
tools: Read, Grep
---

Evaluate a component file's Server vs Client Component decision.

**Decision table:**

| Component uses... | Verdict |
|-------------------|---------|
| `useState`, `useEffect`, event handlers | `'use client'` required |
| `useDI()`, TanStack Query hooks | `'use client'` required |
| `async/await` data fetch directly | Server Component (no directive) |
| Only receives props, no hooks | Server Component preferred |
| `cookies()`, `headers()` | Server Component |

**Workflow:**
1. Read the target file
2. Apply the decision table
3. If the current directive is wrong, report the correct directive and why
4. If `'use client'` is missing but hooks are used — flag as violation
5. If `'use client'` is present but no hooks are used — flag as unnecessary (but not a breaking violation)

**Check for violations:**
- `'use client'` in domain or data layer files → always a violation
- `'use server'` outside of `src/presentation/features/*/actions/` → always a violation

**Pattern:** `reference/ssr.md`

**Return:** verdict (Server Component / Client Component), reasoning, and any violations.
