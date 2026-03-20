---
name: create-mock
description: Scaffold a mock implementation of any interface for use in tests. Generates a Mock class with jest.fn() / vi.fn() for every method.
allowed-tools: Read, Write, Glob, Grep
---

Create a mock implementation of an interface for this Next.js Clean Architecture project's test suite.

First, ask me:
1. Interface name to mock (e.g. `EmployeeRepository`, `EmployeeMapper`, `HTTPClient`)
2. File path of the interface (so I can read the exact method signatures)

Then:

**Step 1 — Read the interface file**

Read the interface at the provided path. Extract every method signature: name, parameters (with types), and return type.

Also check `__tests__/mocks/` for an existing mock of this interface — if one exists, update it rather than creating a new file.

**Step 2 — Generate the mock**

Output file: `__tests__/mocks/Mock[InterfaceName].ts`

```typescript
import { vi } from 'vitest'; // or: import { jest } from '@jest/globals';
import type { [InterfaceName] } from '@/[path-to-interface]';

export class Mock[InterfaceName] implements [InterfaceName] {
  [methodOne] = vi.fn<Parameters<[InterfaceName]['[methodOne]']>, ReturnType<[InterfaceName]['[methodOne]']>>();
  [methodTwo] = vi.fn<Parameters<[InterfaceName]['[methodTwo]']>, ReturnType<[InterfaceName]['[methodTwo]']>>();
  // one line per method
}
```

**Rules:**
- Every method in the interface gets a `vi.fn()` (or `jest.fn()`) property — no method may be missing
- Use `implements [InterfaceName]` so TypeScript enforces completeness
- Type each `vi.fn()` with `Parameters<...>` and `ReturnType<...>` for type-safe `.mockResolvedValue()` calls in tests
- Do not add any logic — mocks are pure stubs
- Class name: `Mock[InterfaceName]` (always `Mock` prefix, no `Impl` suffix)

**Step 3 — Show usage example**

After generating the mock, show a minimal usage snippet:

```typescript
// In your test file:
import { Mock[InterfaceName] } from '@/__tests__/mocks/Mock[InterfaceName]';

let mock: Mock[InterfaceName];

beforeEach(() => {
  mock = new Mock[InterfaceName]();
});

it('example', async () => {
  mock.[methodOne].mockResolvedValue([expectedValue]);
  // ... call the system under test
  expect(mock.[methodOne]).toHaveBeenCalledWith([expectedArgs]);
});
```

**Reminder:** Import the mock in every test file that needs it. Do not instantiate the real implementation in unit tests.
