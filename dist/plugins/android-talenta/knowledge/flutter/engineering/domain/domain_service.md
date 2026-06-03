---
platform: flutter
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

Pure synchronous functions — no I/O, no async, no side effects. Encapsulate domain logic that is too complex to inline in a use case or is reused by multiple use cases.

**Rules:**
- No `@injectable` unless dependencies need to be injected
- Returns structured data — never formatted strings or display text
- Presentation layer formats service output for display

**When to extract to a service:**

| Scenario | Action |
|---|---|
| 1–3 line condition | Keep inline in use case |
| Complex multi-step validation | Service |
| Reused by ≥ 2 use cases | Service |
| Needs unit testing in isolation | Service |

## Code Pattern

```dart
// domain/services/leave_balance_calculator.dart
import '../entities/leave_entitlement_entity.dart';

class LeaveBalanceCalculator {
  int remainingDays(LeaveEntitlementEntity entitlement) {
    final pendingDays = entitlement.pendingRequests
        .where((r) => r.status == LeaveStatus.pending)
        .fold(0, (sum, r) => sum + r.days);
    final remaining =
        entitlement.annualDays - entitlement.usedDays - pendingDays;
    return remaining < 0 ? 0 : remaining;
  }

  bool isSufficient(LeaveEntitlementEntity entitlement, int requestedDays) =>
      remainingDays(entitlement) >= requestedDays;
}
```
