---
platform: web
project: web
discipline: engineering
topic: domain
pattern: domain_service
---

## Theory

A **Domain Service** contains pure business logic that spans multiple entities or is reused across multiple use cases.

**Invariants:**
- No I/O — no async, no network, no database, no file system
- No side effects — pure functions; same input always produces the same output
- No framework imports
- Returns structured data — never formatted strings, CSS classes, or display labels (presentation formats output)

**When to extract to a service:**

| Scenario | Decision |
|----------|----------|
| 1–3 line condition | Keep inline in use case |
| Complex multi-step validation | Extract to service |
| Logic reused across ≥ 2 use cases | Extract to service |
| Needs independent unit testing | Extract to service |

**Naming:** `[Feature][Noun]` — e.g. `LeaveBalanceCalculator`, `AttendanceScheduleResolver`

---

## Domain Services

Pure business decisions — no I/O, no side effects, no async. 

```typescript
// domain/services/LeaveBalanceCalculator.ts
import { LeaveEntitlement } from '../entities/LeaveEntitlement';

export interface LeaveBalanceCalculator {
  remainingBalance(entitlement: LeaveEntitlement): number;
  isSufficient(entitlement: LeaveEntitlement, requestedDays: number): boolean;
}

export class LeaveBalanceCalculatorService implements LeaveBalanceCalculator {
  remainingBalance(entitlement: LeaveEntitlement): number {
    const pendingDays = entitlement.pendingRequests.filter(
      (r) => r.status === 'pending'
    ).length;
    return Math.max(0, entitlement.annualDays - entitlement.usedDays - pendingDays);
  }

  isSufficient(entitlement: LeaveEntitlement, requestedDays: number): boolean {
    return this.remainingBalance(entitlement) >= requestedDays;
  }
}
```

```typescript
// domain/services/LeaveRequestValidator.ts
import { LeaveEntitlement } from '../entities/LeaveEntitlement';
import { LeaveBalanceCalculator, LeaveBalanceCalculatorService } from './LeaveBalanceCalculator';

export type LeaveValidationResult =
  | 'valid'
  | 'insufficientBalance'
  | 'pastDateNotAllowed';

export interface LeaveRequestValidator {
  validate(
    entitlement: LeaveEntitlement,
    requestedDays: number,
    requestDate: Date
  ): LeaveValidationResult;
}

export class LeaveRequestValidatorService implements LeaveRequestValidator {
  constructor(
    private readonly balanceCalculator: LeaveBalanceCalculator = new LeaveBalanceCalculatorService()
  ) {}

  validate(
    entitlement: LeaveEntitlement,
    requestedDays: number,
    requestDate: Date
  ): LeaveValidationResult {
    if (!this.balanceCalculator.isSufficient(entitlement, requestedDays)) {
      return 'insufficientBalance';
    }
    if (requestDate <= new Date()) {
      return 'pastDateNotAllowed';
    }
    return 'valid';
  }
}
```

**UseCase calling a Service:**

```typescript
// domain/use-cases/leave/SubmitLeaveRequestUseCase.ts
export class SubmitLeaveRequestUseCaseImpl {
  constructor(
    private readonly repository: LeaveRepository,
    private readonly validator: LeaveRequestValidator = new LeaveRequestValidatorService()
  ) {}

  async execute(params: SubmitLeaveRequestParams): Promise<Leave> {
    const result = this.validator.validate(
      params.entitlement,
      params.payload.days,
      params.payload.startDate
    );

    if (result !== 'valid') {
      throw new DomainError('validationFailed', { field: 'leave', reason: result });
    }

    return this.repository.submitLeaveRequest(params.payload);
  }
}
```

**What a Service must NOT return:**

| ❌ Violation | ✅ Correct alternative |
|---|---|
| `compactLabel: "71.8K left"` (formatted string) | `remaining: number` + `isOverrun: boolean` |
| `colorClass: "bg-red-400"` (CSS class name from outside domain) | `status: 'on-track' \| 'at-risk' \| 'over'` |
| `displayText: "Over by 71000"` via a locale formatter import | `remaining: number` (let presentation format it) |

Domain services return **structured data**. The presentation layer converts that data into display strings, CSS classes, and formatted labels. If your service imports anything from `shared/core/utils/format*`, it has crossed the boundary.

**When to use a Service vs keeping logic inline:**

| Scenario | Approach |
|----------|----------|
| Simple condition (1-3 lines) | Keep inline in UseCase |
| Complex multi-step validation | Extract to Service |
| Reused across multiple UseCases | Extract to Service |
| Needs independent unit testing | Extract to Service |

**Where to place it:**

| Scenario | Path |
|----------|------|
| Logic belongs to one feature's concept | `src/features/[feature]/domain/services/` |
| Used by ≥2 features | `src/shared/domain/services/` |

**Naming convention:** `[Feature][Noun]` interface + `[Feature][Noun]Service` class — e.g., `LeaveBalanceCalculator` / `LeaveBalanceCalculatorService`
