---
platform: web
project: web
discipline: engineering
topic: testing
pattern: test_pyramid
---

## Theory

```
         ┌──────────────────┐
         │   E2E Tests      │  few — critical user journeys only
         └────────┬─────────┘
         ┌────────┴─────────┐
         │ Integration Tests│  moderate — repository + datasource wiring
         └────────┬─────────┘
         ┌────────┴─────────┐
         │   Unit Tests     │  many — use cases, mappers, domain services
         └──────────────────┘
```

**Distribution target:** unit-heavy, integration-light, e2e-minimal. A test suite with more e2e than unit tests is inverted — slow, brittle, and expensive to maintain.

| Layer | Test targets | What to assert |
|---|---|---|
| Domain | Use cases, domain services | Business rules, edge cases, error conditions |
| Data | Mappers, repository implementations | DTO → entity mapping correctness; error mapping from transport to domain |
| Presentation | StateHolder (ViewModel/BLoC) | State transitions for each event; correct use case calls; action emissions |
| UI | Screen rendering | Correct state → UI binding; event dispatch on user interaction |

---

## Test Pyramid

```
         ┌──────────────────┐
         │   E2E Tests      │  (Playwright — few, critical paths)
         │   Playwright     │
         └────────┬─────────┘
                  │
         ┌────────▼─────────┐
         │ Integration Tests │  (React Testing Library — component + hook tests)
         │ React Test Lib   │
         └────────┬─────────┘
                  │
    ┌─────────────▼────────────────┐
    │       Unit Tests              │  (Vitest — Services, Mappers, UseCases, hooks)
    │  Services / Mappers / Repos  │
    └──────────────────────────────┘
```

**Mocking strategy:**
- **MSW (Mock Service Worker)** for HTTP mocking in integration tests
- **Manual mocks** for repositories and use cases in unit tests
- **`vi.fn()`** for simple dependency mocking

## What to Test Per Layer

| Layer | What to test | What NOT to test |
|---|---|---|
| Domain (Services, UseCases) | Business rules, edge cases, pure function outputs | Framework wiring, HTTP calls |
| Data (Mappers, RepositoryImpl) | DTO → domain field mapping; error propagation | Real network responses |
| Presentation (ViewModel hooks) | State shape on mount; handler behavior; use case call counts | React rendering internals |
| UI (React Testing Library) | State → UI binding; event dispatch on interaction | Business logic, mapping |

## Service Tests

Highest priority. Pure input → output, no mocks needed.

```typescript
// __tests__/domain/services/LeaveBalanceCalculator.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { LeaveBalanceCalculatorService } from '@/domain/services/LeaveBalanceCalculator';

describe('LeaveBalanceCalculatorService', () => {
  let sut: LeaveBalanceCalculatorService;

  beforeEach(() => {
    sut = new LeaveBalanceCalculatorService();
  });

  it('returns correct remaining balance with no pending requests', () => {
    const entitlement = { annualDays: 12, usedDays: 5, pendingRequests: [] };
    expect(sut.remainingBalance(entitlement)).toBe(7);
  });

  it('caps remaining balance at zero when over-committed', () => {
    const entitlement = {
      annualDays: 12,
      usedDays: 10,
      pendingRequests: Array(5).fill({ status: 'pending' }),
    };
    expect(sut.remainingBalance(entitlement)).toBe(0);
  });

  it('returns true when balance is sufficient', () => {
    const entitlement = { annualDays: 12, usedDays: 5, pendingRequests: [] };
    expect(sut.isSufficient(entitlement, 3)).toBe(true);
  });
});

describe('LeaveRequestValidatorService', () => {
  it('returns insufficientBalance when balance is too low', () => {
    const validator = new LeaveRequestValidatorService();
    const entitlement = { annualDays: 5, usedDays: 5, pendingRequests: [] };
    expect(
      validator.validate(entitlement, 3, new Date(Date.now() + 86400_000))
    ).toBe('insufficientBalance');
  });

  it('returns pastDateNotAllowed when date is in the past', () => {
    const validator = new LeaveRequestValidatorService();
    const entitlement = { annualDays: 12, usedDays: 0, pendingRequests: [] };
    expect(
      validator.validate(entitlement, 1, new Date(2000, 0, 1))
    ).toBe('pastDateNotAllowed');
  });
});
```

## Test Naming Convention

Pattern: `it('[returns/emits/calls] [expected] when [condition]', ...)`

Examples:

- `it('returns correct remaining balance with no pending requests', ...)`
- `it('loads employees on mount', ...)`
- `it('calls data source and mapper on getEmployee', ...)`
- `it('maps all fields correctly', ...)`
- `it('uses injected child mapper for department', ...)`
- `it('updates search query on handleSearchChange', ...)`
