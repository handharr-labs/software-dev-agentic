---
name: scaffold-service
description: Create a domain service for pure business logic. Use when business rules are too complex for a single use case or need to be shared across multiple use cases.
allowed-tools: Read, Write, Glob
---

Scaffold a domain service for this Next.js Clean Architecture project.

First, ask me:
1. Service name (e.g. `LeaveBalanceCalculator`, `PayrollRounder`, `OvertimeEligibilityChecker`)
2. Methods needed — for each method: name, parameters (name + type), return type
3. Business rule this service enforces (describe in plain language)
4. Which feature *owns* this concept? (or is it cross-feature / shared?)

Then:

**Step 1 — Confirm the service belongs in the domain layer**

A domain service is the right choice when:
- The logic is pure (no I/O, no HTTP, no database)
- The logic involves multiple domain concepts (entities, value objects)
- The rule needs to be reused across more than one use case

If the logic only applies to one use case, put it directly in that use case's `execute()` instead.

Use the answer to question 4 to resolve the output path:

| Ownership | Output path |
|-----------|-------------|
| Belongs to one feature's concept | `src/features/[feature]/domain/services/[Feature][Noun].ts` |
| Used by ≥2 features | `src/shared/domain/services/[Feature][Noun].ts` |

Place the service in the feature that *owns the concept*, not the feature that calls it.

**Step 2 — Generate the service**

Output file: (feature-aware path from the table above)

```typescript
// Domain layer — zero external imports (no react, no next, no axios, no data layer)

export interface [Feature][Noun] {
  [methodName](params: [ParamType]): [ReturnType];
  // one line per method
}

export class [Feature][Noun]Service implements [Feature][Noun] {
  [methodName](params: [ParamType]): [ReturnType] {
    // pure business logic only
    // [describe the rule being enforced]
  }
}
```

**Enforced rules — violating any of these is a domain layer violation:**
- No `async` / `await` — services are synchronous pure functions
- No `import` from `react`, `next`, `axios`, or any `src/data/` or `src/presentation/` path
- No network calls, no filesystem access, no DOM access
- Parameters and return types use only domain entities, primitives, or value objects

**Step 3 — Default parameter injection (for testability)**

If the service depends on another service, use constructor default parameter injection:

```typescript
export class [Feature][Noun]Service implements [Feature][Noun] {
  constructor(
    private readonly dependency: SomeDependency = new SomeDependencyImpl()
  ) {}
}
```

This makes the service usable without DI wiring while still being overridable in tests.

**Step 4 — Reminders**

After generating, remind me:
- Add a unit test co-located at `[same-dir]/[Feature][Noun].test.ts` targeting 100% branch coverage
- If the service has complex logic, run `/create-mock` for the interface so use cases that inject it can be tested in isolation
- If this service will be injected into a use case, update the use case's constructor signature
