---
platform: flutter
discipline: engineering
topic: domain
pattern: domain_enum
---

## Theory

Business-level constants. Place in `domain/enums/`.

**Rules:**
- Raw `String` values only when needed for direct API mapping
- No UI strings — display formatting belongs in presentation

## Code Pattern

```dart
// domain/enums/leave_status.dart
enum LeaveStatus {
  pending,
  approved,
  rejected,
  cancelled;

  bool get isTerminal =>
      this == approved || this == rejected || this == cancelled;
}
```
